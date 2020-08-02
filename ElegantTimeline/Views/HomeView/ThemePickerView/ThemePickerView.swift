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

    // TODO: Should probably only change the app theme once i exit out of this view
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                headerView
                    .padding(.bottom, 20)
                separatorView
                paletteView
            }
            .padding(.top, 64)

            backGestureOverlay
        }
        .frame(width: pageWidth)
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
            colors: (scrollState.activePage == .themePicker) ? AppTheme.allPaletteColors : [])
    }

    var backGestureOverlay: some View {
        HStack {
            Rectangle()
                .fill(Color.clear)
                .frame(width: 30)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            if value.startLocation.x < 30 &&
                                value.translation.width > 20 {
                                self.scrollState.scroll(to: .menu)
                            }
                        }
                )
            Spacer()
        }
    }

}

private extension AppTheme {

    static let allPaletteColors = Self.allThemes.map { PaletteColor(name: $0.name, uiColor: $0.primaryuiColor) }

}
