// Kevin Li - 2:30 PM - 6/1/20

import SwiftUI

struct DayPreviewBlock: View {

    @Environment(\.appTheme) private var appTheme: AppTheme
    @Environment(\.autoTimer) private var autoTimer: AutoTimer

    @State private var visitIndex = 0

    let visits: [Visit]
    let isFilled: Bool

    private var range: Range<Int> {
        let exclusiveEndIndex = visitIndex + VisitPreviewConstants.numberOfCellsInBlock
        guard visits.count > VisitPreviewConstants.numberOfCellsInBlock &&
            exclusiveEndIndex <= visits.count else {
            return visitIndex..<visits.count
        }
        return visitIndex..<exclusiveEndIndex
    }

    var body: some View {
        ZStack {
            backgroundColor
            if !visits.isEmpty {
                visitsPreviewList
                    .padding(.horizontal, VisitPreviewConstants.blockHorizontalPadding)
                    .animation(.easeInOut)
            }
        }
        .frame(height: VisitPreviewConstants.blockHeight)
        .onReceive(autoTimer) { _ in
            self.shiftActivePreviewVisitIndex()
        }
    }

    private func shiftActivePreviewVisitIndex() {
        let startingVisitIndexOfNextSlide = visitIndex + VisitPreviewConstants.numberOfCellsInBlock
        let startingVisitIndexOfNextSlideIsValid = startingVisitIndexOfNextSlide < visits.count
        visitIndex = startingVisitIndexOfNextSlideIsValid ? startingVisitIndexOfNextSlide : 0
    }

}

private extension DayPreviewBlock {

    var backgroundColor: Color {
        isFilled ? appTheme.primary : appTheme.complementary
    }

    var visitsPreviewList: some View {
        VStack(spacing: 0) {
            Spacer()
            VStack(spacing: VisitPreviewConstants.cellSpacing) {
                ForEach(visits[range]) { visit in
                    VisitPreviewCell(visit: visit)
                        .transition(.slideFadeLeading)
                }
            }
            Spacer()
        }
        .frame(height: VisitPreviewConstants.blockHeight)
    }

}

private extension AnyTransition {

    static var slideFadeLeading: AnyTransition {
        AnyTransition.asymmetric(insertion: AnyTransition.opacity.combined(with: .offset(x: 10)),
                                 removal: AnyTransition.opacity.combined(with: .offset(x: -10)))
    }

}

struct DayPreviewBlock_Previews: PreviewProvider {
    static var previews: some View {
        DarkThemePreview {
            DayPreviewBlock(visits: Visit.mocks(start: .daysFromToday(-1)), isFilled: true)
        }
    }
}
