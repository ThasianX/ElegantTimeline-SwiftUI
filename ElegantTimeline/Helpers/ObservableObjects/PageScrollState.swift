// Kevin Li - 8:23 PM - 7/9/20

import Combine
import ElegantPages
import SwiftUI

enum Page: Int {

    case yearlyCalendar = 0
    case monthlyCalendar = 1
    case list = 2
    case menu = 3
    case themePicker = 4

    var isCalendar: Bool {
        self == .yearlyCalendar || self == .monthlyCalendar
    }

    var isMenuRelated: Bool {
        self == .menu || self == .themePicker
    }

}

fileprivate let regularTurnAnimation: Animation = .spring(response: 0.3, dampingFraction: 1)
fileprivate let menuTurnAnimation: Animation = .spring(response: 0.3, dampingFraction: 0.8)

fileprivate let calendarEarlySwipe = EarlyCutOffConfiguration(
    scrollResistanceCutOff: 40,
    pageTurnCutOff: 90,
    pageTurnAnimation: .interactiveSpring(response: 0.35, dampingFraction: 0.86, blendDuration: 0.25))
fileprivate let minDragDistance: CGFloat = calendarEarlySwipe.pageTurnCutOff / 5

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

    private var isEarlyPageTurn = false

    let pageWidth: CGFloat = screen.width
    let deltaCutoff: CGFloat = 0.8

    private var anyCancellable: AnyCancellable?

    func scroll(to page: Page) {
        if activePage.isCalendar && page.isCalendar {
            withAnimation(calendarEarlySwipe.pageTurnAnimation) {
                activePage = page
            }
        } else {
            withAnimation(page.isMenuRelated ? menuTurnAnimation : regularTurnAnimation) {
                activePage = page
            }
        }
    }

    func horizontalDragChanged(_ value: DragGesture.Value) {
        let horizontalTranslation = value.translation.width
        // This makes sure that nested vertical gestures that might have a bit of horizontal
        // translation don't affect paging.
        guard abs(horizontalTranslation) > abs(value.translation.height) else {
            withAnimation(regularTurnAnimation) {
                translation = .zero
            }
            return
        }

        // For early page turns, after the page turns and the user still has his finger
        // on the screen, this prevents another page turn when their finger is let go of.
        // Since there is no way to actually programatically end the gesture, this is
        // the workaround that I've chosen
        guard !isEarlyPageTurn else { return }

        // The early page turn animation should only occur for the calendar pages
        if isCalendarPageTurn(for: horizontalTranslation) {
            withAnimation(calendarEarlySwipe.pageTurnAnimation) {
                setAdjustedTranslationForOffset(horizontalTranslation)
                turnPageIfNeededForChangingOffset(horizontalTranslation)
            }
        } else {
            withAnimation(regularTurnAnimation) {
                translation = horizontalTranslation
            }
        }
    }

    private func setAdjustedTranslationForOffset(_ offset: CGFloat) {
        let resistanceAdjustedTranslation = (offset / calendarEarlySwipe.pageTurnCutOff) * calendarEarlySwipe.scrollResistanceCutOff
        translation = isEarlyPageTurn ? .zero : resistanceAdjustedTranslation
    }

    private func turnPageIfNeededForChangingOffset(_ offset: CGFloat) {
        let isSwipingTowardsYearlyCalendar = offset > 0
        let isSwipingTowardsMonthlyCalendar = offset < 0

        if isSwipingTowardsYearlyCalendar &&
            offset > calendarEarlySwipe.pageTurnCutOff {
            guard activePage != .yearlyCalendar else { return }

            scroll(direction: .left)
        } else if isSwipingTowardsMonthlyCalendar &&
            offset < -calendarEarlySwipe.pageTurnCutOff {
            guard activePage != .monthlyCalendar else { return }

            scroll(direction: .right)
        }
    }

    private func scroll(direction: ScrollDirection) {
        // As was said earlier, for an early page turn, during that
        // page turn process, `onDragChanged` will get called a few more times
        // because there is simply no way to programmatically end a gesture.
        // Setting `isEarlyPageTurn` to true prevents those intermediary
        // calls from actually modifying the code
        isEarlyPageTurn = true
        translation = .zero

        activePage = (direction == .left) ? .yearlyCalendar : .monthlyCalendar
    }

    // There is a bug where `onEnded` isn't called for the system supplied `DragGesture`
    // so implementing a custom `GestureState` helps resolve that issue.
    // So now, if you drag a page and do some other gesture at the same time, `onEnded`
    // is properly called, as it should be
    var horizontalGestureState: GestureState<TransactionInfo> {
        GestureState(initialValue: TransactionInfo()) { [weak self] (info, _) in
            self?.horizontalDragEnded(info.dragValue)
        }
    }

    private func horizontalDragEnded(_ value: DragGesture.Value) {
        // For an early page turn, all the hard work of turning the page and resetting
        // the translation is actually done in `scroll(direction:)`. So when the user
        // lets go of their drag gesture after the early page turn ends, all that needs
        // to be done in `onEnded` is to just reset that state and return
        guard !isEarlyPageTurn else {
            isEarlyPageTurn = false
            return
        }

        // `predictedEndTranslation` is used instead of `translation` to account for the
        // velocity that the user drags with
        let horizontalTranslation = value.predictedEndTranslation.width

        if isCalendarPageTurn(for: horizontalTranslation) {
            // Since this is a calendar page, this will only get called if
            // an early page turn isn't completed(user doesn't swipe the
            // necessary distance for a page turn). So this is just reset
            // back to whatever page the user swiped from
            withAnimation(calendarEarlySwipe.pageTurnAnimation) {
                translation = .zero
            }
        } else {
            // Because we're using the `predictedEndTranslation`, this can be quite a huge number
            // depending on the velocity so we want to cap the delta as a result
            let pageTurnDelta = (horizontalTranslation / pageWidth).clamped(to: -1...1)
            // For regular pages, as long as you swipe 50% of the way there, the page will turn
            let newIndex = Int((CGFloat(activePage.rawValue) - pageTurnDelta).rounded())

            withAnimation(regularTurnAnimation) {
                activePage = Page(rawValue: min(max(newIndex, Page.monthlyCalendar.rawValue), Page.menu.rawValue))!
                translation = .zero
            }
        }
    }

    private func isCalendarPageTurn(for offset: CGFloat) -> Bool {
        let isSwipingTowardsYearlyCalendar = offset > 0

        return activePage == .yearlyCalendar ||
            (activePage == .monthlyCalendar && isSwipingTowardsYearlyCalendar)
    }

}

extension PageScrollState {

    @discardableResult
    func onPageChanged(_ callback: ((Page) -> Void)?) -> Self {
        anyCancellable = $activePage.sink { page in
            callback?(page)
        }

        return self
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
        translation / pageWidth
    }

    var isSwipingLeft: Bool {
        translation < 0
    }

    var isSwipingRight: Bool {
        translation > 0
    }

}
