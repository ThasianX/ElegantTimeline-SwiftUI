// Kevin Li - 10:41 AM - 8/4/20

import ElegantColorPalette
import SwiftUI

struct StartupThemePickerOverlay: View {

    let onThemeSelected: (AppTheme) -> Void
    let onFinalize: () -> Void

    @State private var selectedColor: PaletteColor? = nil
    @State private var showStartAnimation: Bool = false
    @State private var showExitAnimation: Bool = false

    private var isThemeSelected: Bool {
        selectedColor != nil
    }

    var body: some View {
        content
            .background(overlayBackground)
            .onAppear(perform: startEntranceAnimation)
    }

}

// MARK: Content
fileprivate let exitAnimationDuration: TimeInterval = 0.5

private extension StartupThemePickerOverlay {

    var content: some View {
        ZStack {
            themePickerView
                .opacity(showStartAnimation ? 1 : 0)
            favoriteColorText
                .offset(y: showStartAnimation ? -20 : 40) // entrance sliding animation
                .scaleEffect(isThemeSelected ? 0 : 1) // not visible when user selects theme
                .opacity((showStartAnimation && !isThemeSelected) ? 1 : 0)
            nextStepButton
                // not visible when no theme is showing. when exiting, it should scale up and fade
                .scaleEffect(isThemeSelected ? (showExitAnimation ? 2 : 1) : 0)
                .opacity(isThemeSelected ? (showExitAnimation ? 0 : 1) : 0)
        }
    }

    var themePickerView: some View {
        StartupThemePicker(selectedColor: $selectedColor,
                    colors: AppTheme.allPaletteColors,
                    didSelectColor: didSelectColor,
                    showExitAnimation: showExitAnimation,
                    exitDuration: exitAnimationDuration)
    }

    func didSelectColor(_ paletteColor: PaletteColor) {
        onThemeSelected(.theme(for: paletteColor))
    }

    var favoriteColorText: some View {
        Text("What's your favorite color?")
            .font(.system(size: 20, weight: .light))
    }

    var nextStepButton: some View {
        Button(action: exitOverlay) {
            Image.arrowLeft
                .resizable()
                .frame(width: 25, height: 25)
                .padding(15)
                .rotated(Angle(degrees: 180))
                .foregroundColor(.white)
                .contentShape(Circle())
        }
    }

    func exitOverlay() {
        withAnimation(.easeInOut(duration: exitAnimationDuration)) {
            self.showExitAnimation = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + exitAnimationDuration*2) {
            self.onFinalize()
        }
    }

}

// MARK: Content Modifiers
fileprivate let startAnimationDuration: TimeInterval = 1
// 0.75 sec gives the other views enough time to load
fileprivate let startAnimationDelay: TimeInterval = 0.75

private extension StartupThemePickerOverlay {

    var overlayBackground: some View {
        Color.black.opacity(showExitAnimation ? 0 : (showStartAnimation ? 0.7 : 1))
            .edgesIgnoringSafeArea(.all)
    }

    func startEntranceAnimation() {
        withAnimation(Animation.easeInOut(duration: startAnimationDuration).delay(startAnimationDelay)) {
            showStartAnimation = true
        }
    }

}
