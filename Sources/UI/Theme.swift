import SwiftUI

/// Central visual tokens. Hex values mirror Art/generate_art.py so code and art never drift.
enum Theme {
    // Palette
    static let ink       = Color(hex: 0x241C16)
    static let parchment = Color(hex: 0xE7D7B1)
    static let parchDk   = Color(hex: 0xC9B488)
    static let brass     = Color(hex: 0xC08A2E)
    static let brassHi   = Color(hex: 0xE6BE6A)
    static let brassDk   = Color(hex: 0x8A5E1E)
    static let copper    = Color(hex: 0xA85A34)
    static let rust      = Color(hex: 0x9E3B2A)
    static let patina    = Color(hex: 0x3E7C74)
    static let steam     = Color(hex: 0xF3ECDD)

    // Type — a characterful display face used with restraint + a clean utility face.
    // "Georgia" ships on iOS and reads as engraved/instrument-plate; swap for a custom
    // face later by dropping a .ttf in Resources and registering it in Info.plist.
    static func display(_ size: CGFloat) -> Font { .custom("Georgia-Bold", size: size) }
    static func body(_ size: CGFloat) -> Font { .system(size: size, weight: .medium, design: .rounded) }
}

/// Asset-catalog names. One source of truth so renames are caught by the compiler.
enum Art {
    static let bg = "bg_main"
    static let craneArm = "crane_arm"
    static let craneHook = "crane_hook"
    static let chainLink = "chain_link"
    static let gaugeFrame = "gauge_frame"
    static let gaugeNeedle = "gauge_needle"
    static let gearIcon = "gear_icon"
    static let gearIconDim = "gear_icon_dim"
    static let ribbon = "ribbon"
    static let btn = "btn_brass"
    static let btnSmall = "btn_brass_small"
    static let iconShare = "icon_share"
    static let iconSoundOn = "icon_sound_on"
    static let iconSoundOff = "icon_sound_off"
    static let iconClose = "icon_close"
    static let steam = "steam_puff"
    static let spark = "spark"
    static let dust = "dust"
    static let shareFrame = "sharecard_frame"
}

extension Color {
    init(hex: UInt32) {
        self.init(.sRGB,
                  red: Double((hex >> 16) & 0xFF) / 255,
                  green: Double((hex >> 8) & 0xFF) / 255,
                  blue: Double(hex & 0xFF) / 255,
                  opacity: 1)
    }
}
