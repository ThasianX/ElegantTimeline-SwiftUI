// Kevin Li - 12:20 PM - 8/5/20

import ElegantColorPalette
import SpriteKit
import SwiftUI

struct StartupThemePicker: UIViewRepresentable {

    typealias UIViewType = ColorPaletteView

    @Binding var selectedColor: PaletteColor?
    let colors: [PaletteColor]
    let didSelectColor: (PaletteColor) -> Void

    let showExitAnimation: Bool
    let exitDuration: TimeInterval

    func makeUIView(context: Context) -> ColorPaletteView {
        ColorPaletteView(colors: colors, selectedColor: selectedColor)
            .didSelectColor(groupedCallback)
            .nodeStyle(NoNameNodeStyle())
            .canMoveFocusedNode(false)
            .rotation(multiplier: 5)
            .spawnConfiguration(widthRatio: 1, heightRatio: 1)
            .focus(speed: 1000)
    }

    private func groupedCallback(_ color: PaletteColor) {
        bindingCallback(color)
        didSelectColor(color)
    }

    private func bindingCallback(_ color: PaletteColor) {
        DispatchQueue.main.async {
            withAnimation(.easeInOut(duration: 0.5)) {
                self.selectedColor = color
            }
        }
    }

    func updateUIView(_ uiView: ColorPaletteView, context: Context) {
        if showExitAnimation {
            beginExitAnimation(forScene: uiView.paletteScene)
        }
    }

    private func beginExitAnimation(forScene scene: ColorPaletteScene) {
        guard let selectedNode = scene.selectedColorNode else { return }

        scaleAndFadeNode(selectedNode)

        scene.allColorNodes
            .filter { $0 != selectedNode }
            .forEach { node in
                pushNodeOutOfBounds(node)
            }
    }

    private func scaleAndFadeNode(_ node: ColorNode) {
        node.physicsBody?.isDynamic = false

        let scaleAction = SKAction.scale(to: 5, duration: exitDuration)
        let fadeAction = SKAction.fadeOut(withDuration: exitDuration)
        let scaleFadeAction = SKAction.group([scaleAction, fadeAction])
        node.run(scaleFadeAction)
    }

    private func pushNodeOutOfBounds(_ node: ColorNode) {
        // Basically makes the node not collide with anything -> pushes out of screen bounds
        node.physicsBody?.collisionBitMask = .zero

        let positionVector = CGVector(dx: node.position.x, dy: node.position.y)
        let pushVector = CGVector(dx: positionVector.dx*10, dy: positionVector.dy*10)
        node.physicsBody?.velocity = pushVector
    }

}

private struct NoNameNodeStyle: NodeStyle {

    func updateNode(configuration: Configuration) -> ColorNode {
        configuration.node
            .scaleFade(!configuration.isFirstShown,
                       scale: configuration.isPressed ? 0.9 : (configuration.isFocusing ? 1.3 : 1),
                       opacity: configuration.isPressed ? 0.3 : 1)
            .startUp(configuration.isFirstShown)
    }

}
