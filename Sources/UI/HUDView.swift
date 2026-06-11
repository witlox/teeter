import SwiftUI

struct HUDView: View {
    @EnvironmentObject var model: GameViewModel

    var body: some View {
        VStack {
            HStack(alignment: .top) {
                // Height ribbon (the brag-in-progress). Source SVG is 360×108 (3.33:1);
                // keep the same aspect here so the chevron tails don't squash.
                ZStack {
                    Image(Art.ribbon).resizable().frame(width: 200, height: 60)
                    Text("\(model.height)")
                        .font(Theme.display(28)).foregroundColor(Theme.steam)
                }
                Spacer()
                // Sound toggle
                Button { model.soundOn.toggle() } label: {
                    Image(model.soundOn ? Art.iconSoundOn : Art.iconSoundOff)
                        .resizable().frame(width: 40, height: 40)
                }
            }
            .padding(.horizontal, 16).padding(.top, 8)

            Spacer()

            HStack(alignment: .bottom) {
                // Saves remaining, as lit/dim gears (1 by default, 3 once unlocked)
                HStack(spacing: 4) {
                    ForEach(Array(0..<model.catchCap), id: \.self) { i in
                        Image(i < model.catchesRemaining ? Art.gearIcon : Art.gearIconDim)
                            .resizable().frame(width: 26, height: 26)
                    }
                }
                Spacer()
                LeanGauge(lean: model.leanFraction).frame(width: 130, height: 86)
                Spacer()
                // Cash-out: "bank by not placing" — secondary, never the hero action
                Button { Haptics.success(); model.cashOut() } label: {
                    ZStack {
                        Image(Art.btnSmall).resizable().frame(width: 96, height: 60)
                        Text("FINISH").font(Theme.display(16)).foregroundColor(Theme.ink)
                    }
                }
            }
            .padding(.horizontal, 16).padding(.bottom, 18)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// THE signature instrument. Needle swings green(plumb) -> red(toppling).
///
/// Geometry note: in `gauge_frame` the axle sits 24px above the SVG bottom (cy=H-24
/// of H=170 → 14.1%); in `gauge_needle` the disc sits 12px above the SVG bottom
/// (cy=nH-12 of nH=120 → 10%). Both art assets have transparent margin below their
/// visual pivot. We have to compensate twice: (1) shift the needle UP so its disc
/// aligns with the gauge axle, and (2) rotate around the disc, not the image bottom.
struct LeanGauge: View {
    let lean: Double
    private let needleHeight: CGFloat = 70
    var body: some View {
        ZStack(alignment: .bottom) {
            Image(Art.gaugeFrame).resizable().aspectRatio(contentMode: .fit)
            Image(Art.gaugeNeedle).resizable().aspectRatio(contentMode: .fit)
                .frame(height: needleHeight)
                // Anchor at the disc: 10% above the needle image bottom → y=0.9 in UnitPoint.
                .rotationEffect(.degrees((lean - 0.5) * 170),
                                anchor: UnitPoint(x: 0.5, y: 0.9))
                // Disc to axle: gauge axle is ~14% above its bottom, needle disc ~10%.
                // At a ~85pt rendered gauge height the gap is ~5pt; lift the needle to close it.
                .offset(y: -5)
                .animation(.easeOut(duration: 0.12), value: lean)
        }
    }
}
