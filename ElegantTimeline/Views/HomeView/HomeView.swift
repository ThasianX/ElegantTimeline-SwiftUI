// Kevin Li - 4:07 PM - 7/2/20

import ElegantCalendar
import SwiftUI

fileprivate let listSideBarWidth: CGFloat = Constants.List.monthYearWidth + Constants.List.sideBarWidth + Constants.List.sideBarPadding
fileprivate let listWidthToShowInCalendar: CGFloat = 15
fileprivate let monthlyCalendarOffsetDistance: CGFloat = listSideBarWidth + listWidthToShowInCalendar

struct HomeView: View, HomeManagerDirectAccess {

    @ObservedObject var manager: HomeManager
    @GestureState var stateTransaction: PageScrollState.TransactionInfo

    init(manager: HomeManager) {
        self.manager = manager
        _stateTransaction = manager.scrollState.horizontalGestureState
    }

    var body: some View {
        horizontalPagingStack
            .environment(\.appTheme, appTheme)
            .contentShape(Rectangle())
            .frame(width: pageWidth, alignment: .leading)
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
                .frame(width: pageWidth - listWidthToShowInCalendar)
                .offset(x: calendarOffset)
                .zIndex(1)
            visitsPreviewView
            menuView
        }
        .environmentObject(scrollState)
    }

    var calendarOffset: CGFloat {
        var offset: CGFloat

        if activePage == .list && isSwipingRight {
            offset = monthlyCalendarOffsetDistance * delta
        } else if activePage == .monthlyCalendar {
            offset = listSideBarWidth
            if isSwipingLeft {
                offset -= listSideBarWidth * -delta
            }
        } else {
            offset = 0
        }

        return offset
    }

    var yearlyCalendarView: some View {
        YearlyCalendarView(calendarManager: yearlyCalendarManager)
            .theme(CalendarTheme(primary: appTheme.primary))
    }

    var monthlyCalendarView: some View {
        MonthlyCalendarView(calendarManager: monthlyCalendarManager)
            .theme(CalendarTheme(primary: appTheme.primary))
    }

    var visitsPreviewView: some View {
        VisitsPreviewView(visitsProvider: visitsProvider,
                          listScrollState: listScrollState)
    }

    var menuView: some View {
        MenuView(changeTheme: changeTheme)
    }

}

private extension HomeView {

    var pageOffset: CGFloat {
        var offset = -CGFloat(activePage.rawValue) * pageWidth

        switch activePage {
        case .yearlyCalendar:
            ()
        case .monthlyCalendar:
            offset -= listSideBarWidth
        case .list:
            // Because the monthly calendar's width is less than the pageWidth,
            // we have to account for that
            offset += listWidthToShowInCalendar
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

    var pagingGesture: some Gesture {
        DragGesture()
            .updating($stateTransaction) { value, state, _ in
                state.dragValue = value
            }
            .onChanged { value in
                self.scrollState.horizontalDragChanged(value)
            }
    }

    var gesturesToMask: GestureMask {
        if scrollState.canDrag {
            if activePage == .monthlyCalendar && isSwipingLeft {
                return .gesture
            } else {
                return .all
            }
        }
        return .subviews
    }

}
