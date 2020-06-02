// Kevin Li - 2:30 PM - 6/1/20

import SwiftUI

struct DayPreviewBlock: View {
    @Environment(\.appTheme) private var appTheme: AppTheme

    private let timer = Timer.publish(every: VisitPreviewConstants.previewTime,
                                      on: .main, in: .common).autoconnect()
    @State var visitIndex = 0

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
            visitsPreviewList
                .animation(.easeInOut)
        }
        .onAppear(perform: setUpVisitsSlideShow)
        .onReceive(timer) { _ in
            self.shiftActivePreviewVisitIndex()
        }
    }

    private func setUpVisitsSlideShow() {
        if visits.count <= VisitPreviewConstants.numberOfCellsInBlock {
            // To reduce memory usage, we don't want the timer to fire when
            // visits count is less than or equal to the number
            // of visits allowed in a single slide
            timer.upstream.connect().cancel()
        }
    }

    private func shiftActivePreviewVisitIndex() {
        let startingVisitIndexOfNextSlide = visitIndex + VisitPreviewConstants.numberOfCellsInBlock
        let startingVisitIndexOfNextSlideIsValid = startingVisitIndexOfNextSlide < visits.count
        visitIndex = startingVisitIndexOfNextSlideIsValid ? startingVisitIndexOfNextSlide : 0
    }
}

private extension DayPreviewBlock {
    private var backgroundColor: Color {
        isFilled ? appTheme.primary : appTheme.complementary
    }

    private var visitsPreviewList: some View {
        VStack(spacing: 0) {
            ForEach(visits[range]) { visit in
                VisitPreviewCell(visit: visit)
            }
        }
    }
}

struct DayPreviewBlock_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DayPreviewBlock(visits: [], isFilled: false)
        }
    }
}
