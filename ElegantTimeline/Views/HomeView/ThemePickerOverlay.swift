// Kevin Li - 10:41 AM - 8/4/20

import ElegantColorPalette
import SwiftUI

// TODO: add animation for onappear like timepage
// TODO: Prevent center node from being dragged.
// TODO: disable timer when theme picker overlay is active
// TODO: add api to expose the selected node

struct ThemePickerOverlay: View {

    let onThemeSelected: (AppTheme) -> Void
    let onFinalize: () -> Void

    @State private var selectedColor: PaletteColor?
    @State private var showExitAnimation: Bool = false

    var body: some View {
        ZStack {
            themePickerView
            favoriteColorText
            nextStepButton
        }
        .background(Color.black.opacity(showExitAnimation ? 0 : 0.5).edgesIgnoringSafeArea(.all))
    }

}

private extension ThemePickerOverlay {

    var themePickerView: some View {
        ColorPaletteBindingView(selectedColor: $selectedColor,
                                colors: showExitAnimation ? [] : AppTheme.allPaletteColors)
            .didSelectColor { self.onThemeSelected(.theme(for: $0)) }
            .nodeStyle(NoNameNodeStyle())
    }

    var nextStepButton: some View {
        Button(action: exitOverlay) {
            Image.arrowLeft
                .resizable()
                .frame(width: 25, height: 25)
                .rotated(Angle(degrees: 180))
                .foregroundColor(.white)
                .contentShape(Circle())
        }
        .scaleEffect((selectedColor == nil) ? 0 : 1)
        .opacity((selectedColor == nil) ? 0 : (showExitAnimation ? 0 : 1))
        .animation(.easeInOut)
    }

    func exitOverlay() {
        withAnimation(.easeInOut(duration: 0.5)) {
            self.showExitAnimation = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.onFinalize()
        }
    }

    var favoriteColorText: some View {
        Text("What's your favorite color?")
            .font(.headline)
            .offset(y: -30)
            .scaleEffect((selectedColor == nil) ? 1 : 0)
            .opacity((selectedColor == nil) ? 1 : 0)
            .animation(.easeInOut)
    }

}

private struct NoNameNodeStyle: NodeStyle {

    func updateNode(configuration: Configuration) -> ColorNode {
        configuration.node
            .scaleFade(!configuration.isFirstShown,
                       scale: configuration.isPressed ? 0.9 : 1,
                       opacity: configuration.isPressed ? 0.3 : 1)
            .startUp(configuration.isFirstShown)
    }

}
