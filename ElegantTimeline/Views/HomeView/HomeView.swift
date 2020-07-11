// Kevin Li - 4:07 PM - 7/2/20

import ElegantCalendar
import SwiftUI

struct HomeView: View, PagesStateDirectAccess {

    @ObservedObject var manager: HomeManager

    @GestureState var stateTransaction: PageScrollState.TransactionInfo

    var scrollState: PageScrollState {
        manager.scrollState
    }

    var pageOffset: CGFloat {
        var offset = -CGFloat(activePage.rawValue) * pageWidth
        if activePage == .menu {
            // Because the menu has a fraction of the screen's width,
            // we have to account for that in the offset
            offset += pageWidth * (1 - deltaCutoff)
        }
        return offset
    }

    var boundedTranslation: CGFloat {
        if (activePage == .calendar && translation > 0) ||
            (activePage == .menu && translation < 0) {
            return 0
        }
        return translation
    }

    private var gesturesToMask: GestureMask {
        manager.canDrag ? .all : .subviews
    }

    init(manager: HomeManager) {
        self.manager = manager
        _stateTransaction = manager.scrollState.horizontalGestureState
    }

    var body: some View {
        horizontalPagingStack
            .frame(width: screen.width, alignment: .leading)
            .offset(x: pageOffset)
            .offset(x: boundedTranslation)
            .simultaneousGesture(pagingGesture, including: gesturesToMask)
    }

}

private extension HomeView {

    var horizontalPagingStack: some View {
        HStack(spacing: 0) {
            calendarView
                .frame(width: screen.width*2, alignment: .trailing)
            visitsPreviewView
                .frame(width: screen.width)
            menuView
                .contentShape(Rectangle())
                .frame(width: pageWidth * deltaCutoff)
        }
    }

    var calendarView: some View {
        VisitsCalendarView(calendarManager: manager.calendarManager)
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
