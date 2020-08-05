// Kevin Li - 10:41 AM - 8/4/20

import ElegantColorPalette
import SwiftUI

// TODO: Prevent center node from being dragged.
// TODO: add api to expose the selected node
// TODO: add animation modifier for the swiftui color picker binding view

struct ThemePickerOverlay: View {

    let onThemeSelected: (AppTheme) -> Void
    let onFinalize: () -> Void

    @State private var selectedColor: PaletteColor? = nil
    @State private var showStartAnimation: Bool = false
    @State private var showExitAnimation: Bool = false

    var body: some View {
        ZStack {
            themePickerView
                .opacity(showStartAnimation ? 1 : 0)
            favoriteColorText
                .offset(y: showStartAnimation ? -20 : 40)
                .opacity((showStartAnimation && selectedColor == nil) ? 1 : 0)
                .scaleEffect((selectedColor == nil) ? 1 : 0)
            nextStepButton
                .scaleEffect((selectedColor == nil) ? 0 : 1)
                .opacity((selectedColor == nil) ? 0 : (showExitAnimation ? 0 : 1))
        }
        .background(overlayBackground)
        .onAppear(perform: startEntranceAnimation)
    }

}

private extension ThemePickerOverlay {

    var overlayBackground: some View {
        Color.black.opacity(showExitAnimation ? 0 : (showStartAnimation ? 0.7 : 1))
            .edgesIgnoringSafeArea(.all)
    }

    func startEntranceAnimation() {
        // 0.75 sec gives the other views enough time to load
        withAnimation(Animation.easeInOut(duration: 1).delay(0.75)) {
            showStartAnimation = true
        }
    }

}

private extension ThemePickerOverlay {

    var themePickerView: some View {
        ColorPaletteBindingView(selectedColor: .constant(nil),
                                colors: showExitAnimation ? [] : AppTheme.allPaletteColors)
            .didSelectColor { color in
                self.onThemeSelected(.theme(for: color))
                withAnimation(.easeInOut(duration: 0.5)) {
                    self.selectedColor = color
                }
            }
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
            .font(.system(size: 20, weight: .light))
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
