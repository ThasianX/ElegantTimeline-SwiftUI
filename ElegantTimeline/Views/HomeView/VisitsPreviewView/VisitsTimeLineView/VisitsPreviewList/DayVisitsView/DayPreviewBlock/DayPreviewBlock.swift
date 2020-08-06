// Kevin Li - 2:30 PM - 6/1/20

import SwiftUI

struct DayPreviewBlock: View {

    @Environment(\.appTheme) private var appTheme: AppTheme
    @Environment(\.autoTimer) private var autoTimer: AutoTimer
    @Environment(\.isSetup) private var isSetup: Bool

    @State private var visitIndex = 0

    let visits: [Visit]
    let isFilled: Bool

    private var range: Range<Int> {
        let exclusiveEndIndex = visitIndex + Constants.List.numberOfCellsInBlock
        guard visits.count > Constants.List.numberOfCellsInBlock &&
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
                    .padding(.horizontal, Constants.List.blockHorizontalPadding)
                    .animation(.easeInOut)
            }
        }
        .frame(height: Constants.List.blockHeight)
        .onReceive(autoTimer) { _ in
            if !self.isSetup {
                self.shiftActivePreviewVisitIndex()
            }
        }
    }

    private func shiftActivePreviewVisitIndex() {
        let startingVisitIndexOfNextSlide = visitIndex + Constants.List.numberOfCellsInBlock
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
            VStack(spacing: Constants.List.cellSpacing) {
                ForEach(visits[range]) { visit in
                    VisitPreviewCell(visit: visit,
                                     isBackgroundWhite: self.appTheme == ._white)
                        .transition(self.isSetup ? .identity : .slideFadeLeading)
                }
            }
            Spacer()
        }
        .frame(height: Constants.List.blockHeight)
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
