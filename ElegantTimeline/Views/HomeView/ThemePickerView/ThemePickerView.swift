// Kevin Li - 12:51 PM - 8/1/20

import ElegantColorPalette
import SwiftUI

struct ThemePickerView: View, PageScrollStateDirectAccess {

    @EnvironmentObject var scrollState: PageScrollState

    @State private var selectedColor: PaletteColor?

    init(currentTheme: AppTheme) {
        let paletteColor = PaletteColor(name: currentTheme.name, uiColor: currentTheme.primaryuiColor)
        _selectedColor = State(initialValue: paletteColor)
    }

    // TODO: Fix the slight offset of this view. Should probably only change the app theme once i exit out of this view
    var body: some View {
        VStack(spacing: 0) {
            headerView
                .padding(.bottom, 20)
            separatorView
            if scrollState.activePage == .themePicker {
                paletteView
                    .edgesIgnoringSafeArea(.bottom)
            } else {
                Spacer()
            }
        }
        .padding(.top, 64)
        .frame(width: pageWidth, alignment: .center)
    }
}

private extension ThemePickerView {

    var headerView: some View {
        HStack {
            backButton
            Spacer()
            Text("THEMES")
                .font(.headline)
                .tracking(2)
            Spacer()
        }
        .padding(.horizontal, 32)
    }

    var backButton: some View {
        Button(action: {
            self.scrollState.scroll(to: .menu)
        }) {
            Image.arrowLeft
                .resizable()
                .frame(width: 20, height: 20)
                .foregroundColor(selectedColor!.color)
        }
    }

    var separatorView: some View {
        Rectangle()
            .fill(Color.gray)
            .opacity(0.3)
            .frame(height: 1)
            .padding(.horizontal, 32)
    }

    var paletteView: some View {
        ColorPaletteBindingView(
            selectedColor: $selectedColor,
            colors: AppTheme.allPaletteColors)
    }

}

private extension AppTheme {

    static let allPaletteColors = Self.allThemes.map { PaletteColor(name: $0.name, uiColor: $0.primaryuiColor) }

}
