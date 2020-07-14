// Kevin Li - 4:07 PM - 7/2/20

import ElegantCalendar
import SwiftUI

fileprivate let visibleListWidth: CGFloat = 15
fileprivate let monthlyCalendarShiftDelta: CGFloat = (VisitPreviewConstants.monthYearWidth + VisitPreviewConstants.sideBarWidth + VisitPreviewConstants.sideBarPadding) + visibleListWidth

struct HomeView: View, PageScrollStateDirectAccess {

    @ObservedObject var manager: HomeManager

    @GestureState var stateTransaction: PageScrollState.TransactionInfo

    var scrollState: PageScrollState {
        manager.scrollState
    }

    init(manager: HomeManager) {
        self.manager = manager

        _stateTransaction = manager.scrollState.horizontalGestureState
    }

    var pageOffset: CGFloat {
        var offset = -CGFloat(activePage.rawValue) * pageWidth

        switch activePage {
        case .yearlyCalendar:
            ()
        case .monthlyCalendar:
            offset -= monthlyCalendarShiftDelta - visibleListWidth
        case .list:
            offset += visibleListWidth
        case .menu:
            // Because the menu has a fraction of the screen's width,
            // we have to account for that in the offset
            offset += pageWidth * (1 - deltaCutoff)
        }

        return offset
    }

    var boundedTranslation: CGFloat {
        if (activePage == .yearlyCalendar && translation > 0) ||
            (activePage == .menu && translation < 0) {
            return 0
        }
        return translation
    }

    private var gesturesToMask: GestureMask {
        if manager.canDrag {
            if activePage == .monthlyCalendar && isSwipingLeft {
                return .gesture
            } else {
                return .all
            }
        }
        return .subviews
    }

    var body: some View {
        horizontalPagingStack
            .contentShape(Rectangle())  
            .frame(width: screen.width, alignment: .leading)
            .offset(x: pageOffset)
            .offset(x: boundedTranslation)
            .simultaneousGesture(pagingGesture, including: gesturesToMask)
    }

}

private extension HomeView {

    var horizontalPagingStack: some View {
        HStack(spacing: 0) {
            yearlyCalendarView
                .frame(width: pageWidth)
            monthlyCalendarView
                .frame(width: pageWidth - visibleListWidth)
                .offset(x: calendarOffset)
                .zIndex(1)
            visitsPreviewView
            menuView
        }
        .environmentObject(scrollState)
    }

    var calendarOffset: CGFloat {
        let offset: CGFloat

        if activePage == .list && isSwipingRight {
            offset = monthlyCalendarShiftDelta * (translation / screen.width)
        } else if activePage == .monthlyCalendar {
            if isSwipingLeft {
                offset = (monthlyCalendarShiftDelta - visibleListWidth) - (monthlyCalendarShiftDelta * (-translation / screen.width))
            } else {
                offset = monthlyCalendarShiftDelta - visibleListWidth
            }
        } else {
            offset = 0
        }

        return offset
    }

    var yearlyCalendarView: some View {
        YearlyCalendarView(calendarManager: manager.yearlyCalendarManager)
    }

    var monthlyCalendarView: some View {
        MonthlyCalendarView(calendarManager: manager.monthlyCalendarManager)
    }

    var visitsPreviewView: some View {
        VisitsPreviewView(visitsProvider: manager.visitsProvider,
                          sideBarTracker: manager.sideBarTracker)
    }

    var menuView: some View {
        MenuView()
    }

}

private extension HomeView {

    var pagingGesture: some Gesture {
        DragGesture()
            .updating($stateTransaction) { value, state, _ in
                state.dragValue = value
            }
            .onChanged { value in
                self.scrollState.horizontalDragChanged(value)
            }
    }

}
//
//struct HomeView_Previews: PreviewProvider {
//    static var previews: some View {
//        HomeView()
//    }
//}
