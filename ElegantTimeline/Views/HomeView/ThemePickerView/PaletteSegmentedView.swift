// Kevin Li - 1:08 PM - 8/1/20

import ElegantColorPalette
import SwiftUI

enum PaletteSelection: String {
    case color = "COLOR"
    case bw = "B&W"
}

struct PaletteSegmentedView: View {

    @Binding var selectedPalette: PaletteSelection
    let selectedColor: PaletteColor?

    var body: some View {
        HStack(spacing: 16) {
            PaletteView(selectedPalette: $selectedPalette, palette: .color, selectedColor: selectedColor)
            PaletteView(selectedPalette: $selectedPalette, palette: .bw, selectedColor: selectedColor)
        }.backgroundPreferenceValue(PalettePreferenceKey.self) { preferences in
            GeometryReader { geometry in
                self.createUnderline(geometry, preferences)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
        }
    }

    private func createUnderline(_ geometry: GeometryProxy, _ preferences: [PalettePreferenceData]) -> some View {
        let p = preferences.first(where: { $0.palette == self.selectedPalette })

        let bounds = p != nil ? geometry[p!.bounds] : .zero

        return Rectangle()
            .fill(selectedColor?.color ?? .gray)
            .frame(width: bounds.size.width, height: 1)
            // offset to maxY to get the underline effect
            .offset(x: bounds.minX, y: bounds.maxY)
    }

}

struct PaletteView: View {

    @Binding var selectedPalette: PaletteSelection

    let palette: PaletteSelection
    let selectedColor: PaletteColor?

    private var isPaletteSelected: Bool {
        selectedPalette == palette
    }

    private var paletteColor: Color {
        isPaletteSelected ? (selectedColor?.color ?? .gray) : .gray
    }

    var body: some View {
        Text(palette.rawValue)
            .font(.system(size: 13, weight: .semibold))
            .tracking(1)
            .foregroundColor(paletteColor)
            .opacity(isPaletteSelected ? 1 : 0.5)
            .padding(.top, 20)
            .padding(.bottom, 2)
            .contentShape(Rectangle())
            .anchorPreference(
                key: PalettePreferenceKey.self,
                value: .bounds,
                transform: {
                    [PalettePreferenceData(palette: self.palette,
                                           bounds: $0)]
                }
            )
            .onTapGesture(perform: setSelectedPalette)
    }

    private func setSelectedPalette() {
        withAnimation(.easeInOut) {
            selectedPalette = palette
        }
    }

}

// https://swiftui-lab.com/communicating-with-the-view-tree-part-2/
struct PalettePreferenceKey: PreferenceKey {

    typealias Value = [PalettePreferenceData]

    static var defaultValue: [PalettePreferenceData] = []

    static func reduce(value: inout [PalettePreferenceData], nextValue: () -> [PalettePreferenceData]) {
        value.append(contentsOf: nextValue())
    }

}

struct PalettePreferenceData {

    let palette: PaletteSelection
    let bounds: Anchor<CGRect>

}

struct PaletteSegmentedView_Previews: PreviewProvider {
    static var previews: some View {
        PaletteSegmentedView(selectedPalette: .constant(.color), selectedColor: .bonoboGreen)
            .background(Color.black.edgesIgnoringSafeArea(.all))
            .previewLayout(.sizeThatFits)
    }
}
