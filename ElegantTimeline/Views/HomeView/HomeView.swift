// Kevin Li - 4:07 PM - 7/2/20

import ElegantColorPalette
import ElegantCalendar
import SwiftUI

fileprivate let listSideBarWidth: CGFloat = Constants.List.monthYearWidth + Constants.List.sideBarWidth + Constants.List.sideBarPadding
fileprivate let listWidthToShowInCalendar: CGFloat = 15
fileprivate let monthlyCalendarOffsetDistance: CGFloat = listSideBarWidth + listWidthToShowInCalendar

struct HomeView: View, HomeManagerDirectAccess {

    @ObservedObject var manager: HomeManager
    @GestureState var stateTransaction: PageScrollState.TransactionInfo

    @State private var isSetup: Bool = true

    init(manager: HomeManager) {
        self.manager = manager
        _stateTransaction = manager.scrollState.horizontalGestureState
    }

    var body: some View {
        ZStack {
            horizontalPagingStack
                .contentShape(Rectangle())
                .frame(width: pageWidth, alignment: .leading)
                .offset(x: pageOffset)
                .offset(x: boundedTranslation)
                .simultaneousGesture(pagingGesture, including: gesturesToMask)
            if isSetup {
                // The animations are all contained in the overlay. The state of
                // whether the overlay is active or not is just to conserve memory
                themePickerOverlay
            }
        }
    }

}

private extension HomeView {

    var horizontalPagingStack: some View {
        HStack(spacing: 0) {
            yearlyCalendarView
                .frame(width: pageWidth)
            monthlyCalendarView
                .frame(width: pageWidth - listWidthToShowInCalendar)
                .offset(x: monthlyCalendarOffset)
                .zIndex(2) // Should take overlapping precedence over the visits view
            visitsPreviewView
                .zIndex(1) // Should take overlapping precedence over the menu view
            menuView
                .offset(x: menuOffset)
            if !isSetup {
                // lazily setup the app's theme picker view after the setup
                themePickerView
                    .offset(x: themePickerOffset)
                    .zIndex(1) // Should take overlapping precedence over the menu and visits view
            }
        }
        .environmentObject(scrollState)
    }

    // Gives the monthly calendar the layering effect over the visits view
    // Also accounts for the slight bit of the visits view background that's visible
    var monthlyCalendarOffset: CGFloat {
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

    // Gives the menu a disappearing effect as the theme picker comes into view
    var menuOffset: CGFloat {
        (activePage == .themePicker) ? -pageWidth : 0
    }

    // Gives the theme picker the entrace effect as it becomes visible
    var themePickerOffset: CGFloat {
        var offset: CGFloat

        if activePage == .themePicker {
            offset = -(pageWidth * deltaCutoff) + listWidthToShowInCalendar
        } else {
            offset = 0
        }

        return offset
    }

    var yearlyCalendarView: some View {
        YearlyCalendarView(calendarManager: yearlyCalendarManager)
            .theme(calendarTheme)
    }

    var monthlyCalendarView: some View {
        MonthlyCalendarView(calendarManager: monthlyCalendarManager)
            .theme(calendarTheme)
    }

    var visitsPreviewView: some View {
        VisitsPreviewView(visitsProvider: visitsProvider,
                          listScrollState: listScrollState)
            .environment(\.appTheme, appTheme)
            .environment(\.isSetup, isSetup)
    }

    var menuView: some View {
        MenuView()
    }

    var themePickerView: some View {
        ThemePickerView(currentTheme: appTheme, changeTheme: changeTheme)
    }

    var themePickerOverlay: some View {
        ThemePickerOverlay(onThemeSelected: changeListTheme, onFinalize: hideOverlay)
    }

    func changeListTheme(_ appTheme: AppTheme) {
        manager.appTheme = appTheme
    }

    func hideOverlay() {
        manager.calendarTheme = CalendarTheme(primary: manager.appTheme.primary)
        isSetup = false
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
            // Accounts for leaving a bit of the list view background visible
            offset += pageWidth * (1 - deltaCutoff) + listWidthToShowInCalendar
        case .themePicker:
            // Offsets the tiny portion of the list view out of bounds. The `themePickerOffset`
            // accounts for the entrance animation
            offset += pageWidth
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
        if scrollState.canDrag && activePage != .themePicker {
            if activePage == .monthlyCalendar && isSwipingLeft {
                return .gesture
            } else {
                return .all
            }
        }
        return .subviews
    }

}
