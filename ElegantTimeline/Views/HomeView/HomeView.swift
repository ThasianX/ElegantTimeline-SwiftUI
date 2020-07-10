// Kevin Li - 4:07 PM - 7/2/20

import ElegantCalendar
import SwiftUI

fileprivate let turnAnimation: Animation = .spring(response: 0.4, dampingFraction: 0.95)

struct HomeView: View, PagesStateDirectAccess {

    @ObservedObject var manager: HomeManager

    @State private var isTurningPage: Bool = false

    var pagesState: PagesState {
        manager.pagesState
    }

    private var pageOffset: CGFloat {
        var offset = -CGFloat(activePage) * pageWidth
        if activePage == pageCount-1 {
            // Because the menu has a fraction of the screen's width,
            // we have to account for that in the offset
            offset += pageWidth * (1 - deltaCutoff)
        }
        return offset
    }

    private var boundedTranslation: CGFloat {
        if (activePage == 0 && translation > 0) ||
            (activePage == pageCount-1 && translation < 0) {
            return 0
        }
        return translation
    }

    private var gesturesToMask: GestureMask {
        manager.canDrag ? .all : .subviews
    }

    var body: some View {
        horizontalPagingStack
            .frame(width: screen.width, alignment: .leading)
            .offset(x: pageOffset)
            .offset(x: boundedTranslation)
            // TODO: Look at PageView SwiftUI on github for howto deal with bug where onended isnt called
            .simultaneousGesture(pagingGesture, including: gesturesToMask)
    }

}

private extension HomeView {

    // TODO: Fix paging gesture. Sometimes, it stops when turning a page bc of taps or something
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
            .onChanged { value in
                let horizontalTranslation = value.translation.width
                if abs(horizontalTranslation) < abs(value.translation.height) { return }

                if self.manager.calendarManager.isShowingYearView {
                    self.pagesState.wasPreviousPageYearView = true
                    return
                }

                if self.wasPreviousPageYearView { return }

                if self.pagesState.activePage == 1 &&
                    horizontalTranslation > 0 { return }

                if abs(horizontalTranslation) > 20 {
                    self.isTurningPage = true
                }

                withAnimation(turnAnimation) {
                    self.pagesState.translation = horizontalTranslation
                }
            }.onEnded { value in
                self.pagesState.wasPreviousPageYearView = false
                guard self.isTurningPage else { return }
                let pageTurnDelta = value.translation.width / self.pageWidth
                let newIndex = Int((CGFloat(self.activePage) - pageTurnDelta).rounded())

                self.isTurningPage = false
                withAnimation(turnAnimation) {
                    self.pagesState.activePage = min(max(newIndex, 0), self.pageCount-1)
                    self.pagesState.translation = .zero
                }
            }
    }

}
//
//struct HomeView_Previews: PreviewProvider {
//    static var previews: some View {
//        HomeView()
//    }
//}
