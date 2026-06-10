import SwiftUI

struct HUDView: View {
    @EnvironmentObject var model: GameViewModel

    var body: some View {
        VStack {
            HStack(alignment: .top) {
                // Height ribbon (the brag-in-progress)
                ZStack {
                    Image(Art.ribbon).resizable().frame(width: 170, height: 52)
                    Text("\(model.height)")
                        .font(Theme.display(26)).foregroundColor(Theme.steam)
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
struct LeanGauge: View {
    let lean: Double
    var body: some View {
        ZStack(alignment: .bottom) {
            Image(Art.gaugeFrame).resizable().aspectRatio(contentMode: .fit)
            Image(Art.gaugeNeedle).resizable().aspectRatio(contentMode: .fit)
                .frame(height: 70)
                .rotationEffect(.degrees((lean - 0.5) * 170), anchor: .bottom)
                .animation(.easeOut(duration: 0.12), value: lean)
        }
    }
}
