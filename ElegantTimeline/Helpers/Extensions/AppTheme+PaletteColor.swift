// Kevin Li - 2:50 PM - 8/4/20

import ElegantColorPalette

extension AppTheme {

    static let allPaletteColors = Self.allThemes.map { PaletteColor(name: $0.name, uiColor: $0.primaryuiColor) }

    static func theme(for paletteColor: PaletteColor) -> AppTheme {
        Self.allThemes.first(where: { $0.name == paletteColor.name })!
    }

}
