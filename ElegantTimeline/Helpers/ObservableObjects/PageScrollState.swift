// Kevin Li - 8:23 PM - 7/9/20

import ElegantCalendar
import ElegantPages
import SwiftUI

enum Page: Int {

    case yearlyCalendar = 0
    case monthlyCalendar = 1
    case list = 2
    case menu = 3

    var isCalendar: Bool {
        self == .yearlyCalendar || self == .monthlyCalendar
    }

}

fileprivate let regularTurnAnimation: Animation = .spring(response: 0.3, dampingFraction: 1)

fileprivate let calendarEarlySwipe = EarlyCutOffConfiguration(
    scrollResistanceCutOff: 40,
    pageTurnCutOff: 90,
    pageTurnAnimation: .interactiveSpring(response: 0.35, dampingFraction: 0.86, blendDuration: 0.25))
fileprivate let minDragDistance: CGFloat = calendarEarlySwipe.pageTurnCutOff / 5

protocol PageScrollStateDelegate {

    func willDisplay(page: Page)

}

class PageScrollState: ObservableObject {

    struct TransactionInfo {
        var dragValue: DragGesture.Value!
    }

    enum ScrollDirection {
        case left
        case right
    }

    @Published var activePage: Page = .list
    @Published var translation: CGFloat = .zero
    @Published var canDrag = true

    private var isDragging = false
    private var isTurningPage = false

    let pageWidth: CGFloat = screen.width
    let deltaCutoff: CGFloat = 0.8

    var delegate: PageScrollStateDelegate!

    func scroll(to page: Page) {
        if activePage.isCalendar && page.isCalendar {
            withAnimation(calendarEarlySwipe.pageTurnAnimation) {
                activePage = page
            }
            delegate.willDisplay(page: activePage)
        } else {
            withAnimation(regularTurnAnimation) {
                activePage = page
            }
            delegate.willDisplay(page: activePage)
        }
    }

    func horizontalDragChanged(_ value: DragGesture.Value) {
        let horizontalTranslation = value.translation.width
        guard abs(horizontalTranslation) > abs(value.translation.height) else {
            withAnimation(regularTurnAnimation) {
                translation = .zero
            }
            return
        }

        guard !isTurningPage else { return }

        if abs(horizontalTranslation) > minDragDistance {
            isDragging = true
        }

        if activePage == .yearlyCalendar || (activePage == .monthlyCalendar && horizontalTranslation > 0) {
            withAnimation(calendarEarlySwipe.pageTurnAnimation) {
                setTranslationForOffset(horizontalTranslation)
                turnPageIfNeededForChangingOffset(horizontalTranslation)
            }
        } else {
            withAnimation(regularTurnAnimation) {
                translation = horizontalTranslation
            }
        }
    }

    private func setTranslationForOffset(_ offset: CGFloat) {
        translation = isTurningPage ? .zero : (offset / calendarEarlySwipe.pageTurnCutOff) * calendarEarlySwipe.scrollResistanceCutOff
    }

    private func turnPageIfNeededForChangingOffset(_ offset: CGFloat) {
        // swiping right: from the monthly calendar to the yearly calendar
        if offset > 0 && offset > calendarEarlySwipe.pageTurnCutOff {
            guard activePage != .yearlyCalendar else { return }

            scroll(direction: .left)
        } else if offset < 0 && offset < -calendarEarlySwipe.pageTurnCutOff {
            guard activePage != .monthlyCalendar else { return }

            scroll(direction: .right)
        }
    }

    private func scroll(direction: ScrollDirection) {
        isTurningPage = true // Prevents user drag from continuing
        translation = .zero

        if direction == .left {
            activePage = .yearlyCalendar
        } else {
            activePage = .monthlyCalendar
        }

        delegate.willDisplay(page: activePage)
    }

    var horizontalGestureState: GestureState<TransactionInfo> {
        GestureState(initialValue: TransactionInfo()) { [weak self] (info, _) in
            self?.horizontalDragEnded(info.dragValue)
        }
    }

    private func horizontalDragEnded(_ value: DragGesture.Value) {
        guard isDragging else { return }
        guard !isTurningPage else {
            isTurningPage = false
            return
        }

        isDragging = false

        let horizontalTranslation = value.predictedEndTranslation.width

        if activePage == .yearlyCalendar || (activePage == .monthlyCalendar && horizontalTranslation > 0) {
            withAnimation(calendarEarlySwipe.pageTurnAnimation) {
                translation = .zero
            }
        } else {
            let pageTurnDelta = (horizontalTranslation / pageWidth).clamped(to: -1...1)
            let newIndex = Int((CGFloat(activePage.rawValue) - pageTurnDelta).rounded())

            withAnimation(regularTurnAnimation) {
                activePage = Page(rawValue: min(max(newIndex, Page.monthlyCalendar.rawValue), Page.menu.rawValue))!
                translation = .zero
            }

            delegate.willDisplay(page: activePage)
        }
    }

}

protocol PageScrollStateDirectAccess {

    var scrollState: PageScrollState { get }

}

extension PageScrollStateDirectAccess {

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

    var isSwipingLeft: Bool {
        translation < 0
    }

    var isSwipingRight: Bool {
        translation > 0
    }

}
