// Kevin Li - 2:13 PM - 6/26/20

import SwiftUI

struct VisitsTimelineView: View {

    @Environment(\.appTheme) private var appTheme: AppTheme

    let sideBarTracker: VisitsSideBarTracker
    let visitsProvider: VisitsProvider

    let contentOpacity: Double

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            monthYearSideBarView
                .opacity(contentOpacity)
            ZStack {
                quoteBackgroundView
                visitsPreviewList
                listContentMaskingView
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

    var listContentMaskingView: some View {
        HStack(spacing: 0) {
            sideBarContentMaskingView
                .frame(width: VisitPreviewConstants.sideBarWidth + VisitPreviewConstants.sideBarPadding)
            contentMaskingView(color: appTheme.primary)
        }
    }

    var sideBarContentMaskingView: some View {
        contentMaskingView(color: .black)
    }

    func contentMaskingView(color: Color) -> some View {
        color
            .edgesIgnoringSafeArea(.vertical)
            .opacity(1 - contentOpacity)
    }

}

fileprivate let homeButtonThresholdLocation: CGFloat = screen.height-100

private extension VisitsTimelineView {

    var timelineScrollGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                let translation = -value.translation.height

                guard abs(value.translation.width) < 20 else {
                    self.sideBarTracker.fastDragDidEnd(translation: translation)
                    return
                }

                if value.startLocation.x < VisitPreviewConstants.monthYearWidth &&
                    value.startLocation.y < homeButtonThresholdLocation &&
                    self.contentOpacity != 0 {
                    self.sideBarTracker.fastScroll(translation: translation)
                }
            }
            .onEnded { value in
                self.sideBarTracker.fastDragDidEnd(translation: -value.translation.height)
            }
    }

}
