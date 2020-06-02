// Kevin Li - 1:40 PM - 6/1/20

import SwiftUI

extension View {

    func rotated(_ angle: Angle) -> some View {
        modifier(RotatedModifier(angle: angle))
    }

}

struct RotatedModifier: ViewModifier {

    @State private var size: CGSize = .zero
    var angle: Angle

    func body(content: Content) -> some View {
        let newFrame = CGRect(origin: .zero, size: size)
            .offsetBy(dx: -size.width / 2, dy: -size.height / 2)
            .applying(.init(rotationAngle: CGFloat(angle.radians)))
            .integral

        return content
            .fixedSize()
            .captureSize(in: $size)
            .rotationEffect(angle)
            .frame(width: newFrame.width, height: newFrame.height)
    }

}

private extension View {

    func captureSize(in binding: Binding<CGSize>) -> some View {
        modifier(SizeModifier())
            .onPreferenceChange(SizePreferenceKey.self) {
                binding.wrappedValue = $0
        }
    }

}

struct SizeModifier: ViewModifier {

    private var sizeView: some View {
        GeometryReader { geometry in
            Color.clear.preference(key: SizePreferenceKey.self, value: geometry.size)
        }
    }

    func body(content: Content) -> some View {
        content.overlay(sizeView)
    }

}

struct SizePreferenceKey: PreferenceKey {

    static var defaultValue: CGSize = .zero

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
    
}
