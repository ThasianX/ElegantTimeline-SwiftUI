// Kevin Li - 12:51 PM - 8/1/20

import ElegantColorPalette
import SwiftUI

struct ThemePickerView: View, PageScrollStateDirectAccess {

    @EnvironmentObject var scrollState: PageScrollState

    @State private var selectedColor: PaletteColor?

    let changeTheme: (AppTheme) -> Void

    init(currentTheme: AppTheme, changeTheme: @escaping (AppTheme) -> Void) {
        let paletteColor = PaletteColor(name: currentTheme.name, uiColor: currentTheme.primaryuiColor)
        _selectedColor = State(initialValue: paletteColor)
        self.changeTheme = changeTheme
    }

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
        ZStack {
            Text("THEMES")
                .font(.headline)
                .tracking(2)
            HStack {
                backButton
                Spacer()
            }
        }
        .padding(.horizontal, 32)
    }

    var backButton: some View {
        Button(action: changeThemeAndReturnToMenu) {
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

    // Have to limit the actual width of the view that contains the drag gesture
    // because SKScene will cancel all internal touches whenever it sees that a
    // `DragGesture` layered on top of the SKScene is active.
    var backGestureOverlay: some View {
        HStack {
            Rectangle()
                .fill(Color.clear)
                .frame(width: 30)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            if value.translation.width > 20 {
                                self.changeThemeAndReturnToMenu()
                            }
                        }
                )
            Spacer()
        }
    }

    func changeThemeAndReturnToMenu() {
        scrollState.scroll(to: .menu)
        changeTheme(.theme(for: selectedColor!))
    }

}
