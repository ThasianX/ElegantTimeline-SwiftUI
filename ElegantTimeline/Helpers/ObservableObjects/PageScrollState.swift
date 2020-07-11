// Kevin Li - 8:23 PM - 7/9/20

import ElegantCalendar
import SwiftUI

fileprivate let turnAnimation: Animation = .spring(response: 0.3, dampingFraction: 1.2)

enum Page: Int {

    case calendar = 1
    case list = 2
    case menu = 3

}

class PageScrollState: ObservableObject {

    struct TransactionInfo {
        var dragValue: DragGesture.Value!
    }

    @Published var activePage: Page = .list
    @Published var translation: CGFloat = .zero

    let pageWidth: CGFloat = screen.width
    let deltaCutoff: CGFloat = 0.8

    let calendarManager: ElegantCalendarManager

    private var wasPreviousPageYearView = false

    init(calendarManager: ElegantCalendarManager) {
        self.calendarManager = calendarManager
    }

    func horizontalDragChanged(_ value: DragGesture.Value) {
        let horizontalTranslation = value.translation.width
        if abs(horizontalTranslation) < abs(value.translation.height) { return }

        if calendarManager.isShowingYearView {
            wasPreviousPageYearView = true
            return
        } else if wasPreviousPageYearView {
            return
        }

        withAnimation(turnAnimation) {
            translation = horizontalTranslation
        }
    }

    var horizontalGestureState: GestureState<TransactionInfo> {
        GestureState(initialValue: TransactionInfo()) { [weak self] (info, _) in
            self?.horizontalDragEnded(info.dragValue)
        }
    }

    private func horizontalDragEnded(_ value: DragGesture.Value) {
        wasPreviousPageYearView = false

        let pageTurnDelta = value.translation.width / pageWidth
        let newIndex = Int((CGFloat(activePage.rawValue) - pageTurnDelta).rounded())

        withAnimation(turnAnimation) {
            self.activePage = Page(rawValue: min(max(newIndex, Page.calendar.rawValue), Page.menu.rawValue))!
            self.translation = .zero
        }
    }

}

protocol PagesStateDirectAccess {

    var scrollState: PageScrollState { get }

}

extension PagesStateDirectAccess {

    var activePage: Page {
        scrollState.activePage
    }

    var translation: CGFloat {
        scrollState.translation
    }

    var pageWidth: CGFloat {
        scrollState.pageWidth
    }

    var deltaCutoff: CGFloat {
        scrollState.deltaCutoff
    }

    var delta: CGFloat {
        translation / screen.width
    }

}
