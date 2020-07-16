// Kevin Li - 2:13 PM - 6/26/20

import SwiftUI

struct VisitsTimelineView: View {

    @Environment(\.appTheme) private var appTheme: AppTheme

    let listScrollState: ListScrollState
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
        MonthYearSideBar(state: listScrollState.monthYearSideBarState)
    }

    var quoteBackgroundView: some View {
        QuoteView(quoteState: listScrollState.quoteState)
    }

    var visitsPreviewList: some View {
        VisitsPreviewList(visitsProvider: visitsProvider,
                          listScrollState: listScrollState)
            .frame(height: screen.height)
    }

    var listContentMaskingView: some View {
        HStack(spacing: 0) {
            sideBarContentMaskingView
                .frame(width: Constants.List.sideBarWidth + Constants.List.sideBarPadding)
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
                    self.listScrollState.fastDragDidEnd(translation: translation)
                    return
                }

                if value.startLocation.x < Constants.List.monthYearWidth &&
                    value.startLocation.y < homeButtonThresholdLocation &&
                    self.contentOpacity != 0 {
                    self.listScrollState.fastScroll(translation: translation)
                }
            }
            .onEnded { value in
                self.listScrollState.fastDragDidEnd(translation: -value.translation.height)
            }
    }

}
