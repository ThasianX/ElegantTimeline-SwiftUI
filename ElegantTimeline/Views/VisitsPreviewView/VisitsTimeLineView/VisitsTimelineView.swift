// Kevin Li - 2:13 PM - 6/26/20

import SwiftUI

struct VisitsTimelineView: View {

    let sideBarTracker: VisitsSideBarTracker
    let visitsProvider: VisitsProvider

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            self.monthYearSideBarView
            ZStack {
                self.quoteBackgroundView
                self.visitsPreviewList
            }
        }
        .contentShape(Rectangle())
        .gesture(timelineScrollGesture)
    }

}

private extension VisitsTimelineView {

    var monthYearSideBarView: some View {
        MonthYearSideBar(provider: sideBarTracker)
    }

    var quoteBackgroundView: some View {
        QuoteView(sideBarTracker: sideBarTracker)
    }

    var visitsPreviewList: some View {
        VisitsPreviewList(visitsProvider: visitsProvider,
                          sideBarTracker: sideBarTracker)
            .frame(height: screen.height)
    }

}

private extension VisitsTimelineView {

    var timelineScrollGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                guard abs(value.translation.width) < 20 else {
                    self.sideBarTracker.fastDragDidEnd(translation: -value.translation.height)
                    return
                }

                if value.startLocation.x < 50 && value.startLocation.y < screen.height-100 {
                    self.sideBarTracker.fastScroll(translation: -value.translation.height)
                }
            }
            .onEnded { value in
                self.sideBarTracker.fastDragDidEnd(translation: -value.translation.height)
            }
    }

}
