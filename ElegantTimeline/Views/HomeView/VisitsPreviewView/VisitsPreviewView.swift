// Kevin Li - 9:06 AM - 6/1/20

import SwiftUI

struct VisitsPreviewView: View, PageScrollStateDirectAccess {

    @Environment(\.appTheme) private var appTheme: AppTheme
    @EnvironmentObject var scrollState: PageScrollState

    let visitsProvider: VisitsProvider
    let listScrollState: ListScrollState

    var body: some View {
        ZStack {
            timelineView
                .edgesIgnoringSafeArea(.all)

            fromTodayPopupView

            VStack {
                Spacer()
                scrollToTodayButton
                    .padding(.bottom, 75)
                    .opacity(contentOpacity)
            }

            HStack {
                Spacer()
                menuBarIndicator
                    .padding(.trailing)
                    .opacity(contentOpacity)
            }
        }
        .frame(width: pageWidth)
        .overlay(resizingOverlayView)
    }
    
}

private extension VisitsPreviewView {

    var timelineView: some View {
        VisitsTimelineView(listScrollState: listScrollState,
                           visitsProvider: visitsProvider,
                           contentOpacity: contentOpacity)
    }

    var fromTodayPopupView: some View {
        FromTodayPopupView(state: listScrollState.fromTodayPopupState)
    }

    var scrollToTodayButton: some View {
        ScrollBackToTodayButton(provider: listScrollState)
    }

    var menuBarIndicator: some View {
        MenuBarIndicator()
    }

    var resizingOverlayView: some View {
        ResizingOverlayView()
    }

}

fileprivate let centerMinOpacity: Double = 0
fileprivate let centerMaxOpacity: Double = 1
fileprivate let fadeShiftDelta: Double = 0.3

extension VisitsPreviewView {

    var contentOpacity: Double {
        if isSwipingLeft {
            // If we're at the last page and we're swiping left into the empty
            // space to the right, the center opacity should remain as it is
            guard activePage != .menu && activePage != .yearlyCalendar else { return centerMinOpacity }

            // swiping to menu page
            if activePage == .monthlyCalendar {
                // negation for clearer syntax
                let opacityToBeAdded = Double(-delta) - fadeShiftDelta
                return centerMinOpacity + opacityToBeAdded
            } else {
                // Now we know we're on the center page and we're swiping towards the menu page,
                // we don't want to subtract more opacity once fully faded
                guard abs(delta) <= deltaCutoff else { return centerMinOpacity }
                // negation for clearer syntax
                let opacityToBeRemoved = Double(-delta) * (centerMaxOpacity / Double(deltaCutoff)) + fadeShiftDelta
                return centerMaxOpacity - opacityToBeRemoved
            }
        } else if isSwipingRight {
            // If we're at the side page and we're swiping right into the empty
            // space to the left, the center opacity should remain as it is
            guard !activePage.isCalendar else { return centerMinOpacity }

            // swiping to side page
            if activePage == .list {
                let opacityToBeRemoved = Double(delta) + fadeShiftDelta
                return centerMaxOpacity - opacityToBeRemoved
            } else {
                // Now we know we're on the menu page and we're swiping towards the center page,
                // we don't want to add more opacity once fully visible
                guard delta <= deltaCutoff else { return centerMaxOpacity }

                let opacityToBeAdded = Double(delta) * (centerMaxOpacity / Double(deltaCutoff)) - fadeShiftDelta
                return centerMinOpacity + opacityToBeAdded
            }
        } else {
            // When the user isn't dragging anything and the center page is active, we want
            // the menu page to be fully faded. But when the menu page is active and there is no
            // drag, we want it to be fully visible
            return activePage == .list ? centerMaxOpacity : centerMinOpacity
        }
    }

}

