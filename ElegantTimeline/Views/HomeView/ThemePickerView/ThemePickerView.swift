// Kevin Li - 12:51 PM - 8/1/20

import ElegantColorPalette
import SwiftUI

struct ThemePickerView: View, PageScrollStateDirectAccess {

    @EnvironmentObject var scrollState: PageScrollState

    @State private var selectedPalette: PaletteSelection = .color
    @State private var selectedColor: PaletteColor? = nil

    let changeTheme: (AppTheme) -> Void

    // TODO: Fix the slight offset of this view
    var body: some View {
        VStack(spacing: 0) {
            headerView
                .padding(.bottom, 20)
            separatorView
            paletteWithSegmentedView
                .edgesIgnoringSafeArea(.bottom)
        }
        .padding(.top, 32)
        .frame(width: pageWidth, alignment: .center)
    }
}

private extension ThemePickerView {

    var headerView: some View {
        Text("THEMES")
            .font(.headline)
            .tracking(2)
    }

    var separatorView: some View {
        Rectangle()
            .fill(Color.gray)
            .opacity(0.3)
            .frame(height: 1)
            .padding(.horizontal, 32)
    }

    var paletteWithSegmentedView: some View {
        ZStack(alignment: .top) {
            paletteView
            paletteSegmentedView
        }
    }

    var paletteSegmentedView: some View {
        PaletteSegmentedView(selectedPalette: $selectedPalette,
                             selectedColor: selectedColor)
    }

    var paletteView: some View {
        ColorPaletteBindingView(
            selectedColor: $selectedColor,
            colors: isColorPaletteSelected ? PaletteColor.allColors : PaletteColor.allBwColors)
            .didSelectColor { self.changeTheme(self.appTheme(for: $0)) }
    }

    var isColorPaletteSelected: Bool {
        selectedPalette == .color
    }

    func appTheme(for paletteColor: PaletteColor) -> AppTheme {
        AppTheme(name: paletteColor.name,
                 primary: paletteColor.color,
                 complementary: paletteColor.color)
    }

}
