// Kevin Li - 1:40 PM - 6/1/20

import SwiftUI

extension View {

    func rotated(_ angle: Angle) -> some View {
        modifier(RotatedModifier(angle: angle))
    }

}

struct RotatedModifier: ViewModifier {

    @State private var size: CGSize = .zero
    let angle: Angle

    func body(content: Content) -> some View {
        // The first calculation of `newFrame` where `size` is 0 doesn't matter.
        // It's after the `captureSize` modifier is called that `size`
        // gets updated to the correct `size` of `content`
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
