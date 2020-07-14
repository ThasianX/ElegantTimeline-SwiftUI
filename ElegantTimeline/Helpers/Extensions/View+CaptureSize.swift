// Kevin Li - 9:49 PM - 6/3/20

import SwiftUI

extension View {

    func captureSize(in binding: Binding<CGSize>) -> some View {
        modifier(SizeModifier())
            .onPreferenceChange(SizePreferenceKey.self) { size in
                DispatchQueue.main.async {
                    binding.wrappedValue = size
                }
            }
    }

}

struct SizeModifier: ViewModifier {

    func body(content: Content) -> some View {
        content
            .overlay(sizeView)
    }

    private var sizeView: some View {
        GeometryReader { geometry in
            Color.clear.preference(key: SizePreferenceKey.self,
                                   value: geometry.size)
        }
    }

}

struct SizePreferenceKey: PreferenceKey {

    static var defaultValue: CGSize = .zero

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }

}
