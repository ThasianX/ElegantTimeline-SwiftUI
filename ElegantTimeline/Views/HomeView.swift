// Kevin Li - 4:07 PM - 7/2/20

import ElegantCalendar
import SwiftUI

fileprivate let turnAnimation: Animation = .spring(response: 0.4, dampingFraction: 0.95)

class PagesState: ObservableObject {

    @Published var activePage: Int
    @Published var translation: CGFloat = .zero

    let pageCount: Int
    let pageWidth: CGFloat = screen.width
    let deltaCutoff: CGFloat

    var wasPreviousPageYearView: Bool = false

    init(startingPage: Int, pageCount: Int, deltaCutoff: CGFloat) {
        activePage = startingPage
        self.pageCount = pageCount
        self.deltaCutoff = deltaCutoff
    }

}

protocol PagesStateDirectAccess {

    var pagesState: PagesState { get }

}

extension PagesStateDirectAccess {

    var activePage: Int {
        pagesState.activePage
    }

    var translation: CGFloat {
        pagesState.translation
    }

    var pageCount: Int {
        pagesState.pageCount
    }

    var pageWidth: CGFloat {
        pagesState.pageWidth
    }

    var deltaCutoff: CGFloat {
        pagesState.deltaCutoff
    }

    var wasPreviousPageYearView: Bool {
        pagesState.wasPreviousPageYearView
    }

    var delta: CGFloat {
        translation / screen.width
    }

    var isSwipingLeft: Bool {
        translation < 0
    }

    var isSwipingRight: Bool {
        translation > 0
    }

}

struct HomeView: View, PagesStateDirectAccess {

    let manager: HomeManager

    @State private var isTurningPage: Bool = false
    @ObservedObject var pagesState = PagesState(startingPage: 2,
                                                pageCount: 4,
                                                deltaCutoff: 0.8)

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

    var body: some View {
        horizontalPagingStack
            .frame(width: screen.width, alignment: .leading)
            .offset(x: pageOffset)
            .offset(x: boundedTranslation)
            .simultaneousGesture(pagingGesture, including: isTurningPage ? .gesture : .all)
    }

}

private extension HomeView {

    var horizontalPagingStack: some View {
        HStack(spacing: 0) {
            calendarView
                .frame(width: screen.width*2, alignment: .trailing)
            // TODO: Make some kind of variable that allows the page view to know whether or not to allow paging. When the preview list is scrolling, paging shouldn't be allowed. After the scrolling ends, then scroll to the expected month and enable paging
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
