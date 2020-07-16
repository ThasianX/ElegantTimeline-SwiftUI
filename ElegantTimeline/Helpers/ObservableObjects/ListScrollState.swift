// Kevin Li - 9:58 PM - 6/1/20

import Combine
import SwiftUI

protocol VisitsListDelegate {

    func listDidBeginScrolling()
    func listDidEndScrolling(dayComponent: DateComponents)

    func listDidScrollToToday()

}

extension VisitsListDelegate {

    func listDidBeginScrolling() { }
    func listDidEndScrolling(dayComponent: DateComponents) { }

    func listDidScrollToToday() { }

}

class ListScrollState: NSObject, ObservableObject, UITableViewDirectAccess {

    @Published var currentDayComponent: DateComponents = .init()

    @Published var fromTodayPopupState: FromTodayPopupState = .init()
    @Published var monthYearSideBarState: MonthYearSideBarState

    let descendingDayComponents: [DateComponents]

    var tableView: UITableView!

    private var isFastDraggingTimer: Timer? = nil
    private var isFastDragging: Bool = false

    @Published var shouldShowHeader: Bool = false
    @Published var shouldShowFooter: Bool = false
    @Published var headerFooterOffset: CGFloat = .zero

    var delegate: VisitsListDelegate?

    private var notifyDelegate: Bool = true

    lazy var startingOffset: CGFloat = {
        -Constants.List.listTopPadding
    }()

    private func adjustedScrollOffset(_ scrollOffset: CGFloat) -> CGFloat {
        scrollOffset - startingOffset
    }

    private var cancellables = Set<AnyCancellable>()

    init(descendingDayComponents: [DateComponents]) {
        self.descendingDayComponents = descendingDayComponents
        monthYearSideBarState = MonthYearSideBarState(descendingDayComponents: descendingDayComponents)
        super.init()

        $currentDayComponent
            .sink(receiveValue: fromTodayPopupState.dayChanged)
            .store(in: &cancellables)
    }

}

fileprivate let monthScrollDistance = Constants.List.blockHeight * 30
fileprivate let tableViewContentOffsetDamping: CGFloat = 6

extension ListScrollState {

    func attach(to tableView: UITableView) {
        tableView.delegate = self
        self.tableView = tableView

        monthYearSideBarState.tableView = tableView
        monthYearSideBarState.setSideBarOffsetAndMonthYearComponent(
            scrollOffset: .zero,
            monthYearComponent: descendingDayComponents.first!.monthAndYear)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.scrollViewDidEndDecelerating(self.tableView)
        }
    }

    func scroll(to date: Date) {
        notifyDelegate = false
        let startOfTodayForDate = appCalendar.startOfDay(for: date)
        let startOfTodayForFirstDay = descendingDayComponents.first!.date

        // because the list is descending, we reverse the from and to date
        let index = appCalendar.dateComponents([.day], from: startOfTodayForDate, to: startOfTodayForFirstDay).day!
        let boundedIndex = max(0, index)

        scrollTableView(to: cellOffset(for: boundedIndex), animated: false) { [unowned self] in
            self.scrollViewDidEndDecelerating(self.tableView)
            self.notifyDelegate = true
        }
    }

    private func cellOffset(for index: Int) -> CGFloat {
        startingOffset + (CGFloat(index) * Constants.List.blockHeight)
    }

}

// MARK: Fast Scrolling
extension ListScrollState {

    func fastScroll(translation: CGFloat) {
        isFastDragging = true
        scrollViewWillBeginDragging(tableView)

        isFastDraggingTimer?.invalidate()
        isFastDraggingTimer = .scheduledTimer(withTimeInterval: 0.01, repeats: true) { [unowned self] _ in
            self.animateTableViewContentOffset(by: translation, snapToCell: false, duration: 0.01)
        }
    }

    func fastDragDidEnd(translation: CGFloat) {
        guard isFastDragging else { return }

        isFastDraggingTimer?.invalidate()
        isFastDraggingTimer = nil

        isFastDragging = false

        animateTableViewContentOffset(by: translation, snapToCell: true, duration: 0.1) { [unowned self] in
            self.scrollViewDidEndDecelerating(self.tableView)
        }
    }

    private func animateTableViewContentOffset(by offset: CGFloat, snapToCell: Bool, duration: Double, completion: (() -> Void)? = nil) {
        let newOffset = tableView.contentOffset.y + (offset / tableViewContentOffsetDamping)

        scrollTableView(to: newOffset, snapToCell: snapToCell, duration: duration, completion: completion)
    }

    private func scrollTableView(to offset: CGFloat, snapToCell: Bool = false, duration: Double? = nil, animated: Bool = true, completion: (() -> Void)? = nil) {
        let gapBetweenOffsetAndListEnd = listContentHeight - offset
        let differenceBetweenListHeightAndGapToEnd = listHeight - gapBetweenOffsetAndListEnd

        let newOffset: CGFloat

        if offset < startingOffset {
            newOffset = startingOffset
        } else if differenceBetweenListHeightAndGapToEnd > startingOffset {
            newOffset = (listContentHeight - listHeight) - adjustedVerticalContentInset
        } else if snapToCell {
            newOffset = nearestCellOffset(for: offset)
        } else {
            newOffset = offset
        }

        DispatchQueue.main.async {
            if animated {
                UIView.animate(
                    withDuration: duration!,
                    delay: 0,
                    options: .curveEaseInOut,
                    animations: {
                        self.tableView.contentOffset.y = newOffset
                    },
                    completion: { _ in completion?() }
                )
            } else {
                UIView.performWithoutAnimation {
                    self.tableView.contentOffset.y = newOffset
                    completion?()
                }
            }
        }
    }

}

extension ListScrollState: ScrollToTodayProvider {

    func scrollToToday() {
        tableView.setContentOffset(.init(x: 0, y: cellOffset(for: 0)), animated: true)
    }

}

fileprivate let minDragDistanceToShowHeaderOrFooter: CGFloat = 80

extension ListScrollState: UITableViewDelegate {

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        delegate?.listDidBeginScrolling()
        fromTodayPopupState.didBeginDragging()
    }

    // Kudos: https://stackoverflow.com/a/20943198/6074750
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let targetOffset = adjustedScrollOffset(targetContentOffset.pointee.y)

        targetContentOffset.pointee.y = nearestCellOffset(for: targetOffset)
    }

    private func nearestCellOffset(for scrollOffset: CGFloat) -> CGFloat {
        let index = Int(round(scrollOffset / Constants.List.blockHeight))
        return cellOffset(for: index)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if notifyDelegate {
            delegate?.listDidEndScrolling(dayComponent: currentDayComponent)
        }

        fromTodayPopupState.didEndDragging()
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        // Not ideal but since the only time this is called is when the list
        // is scrolled back to today, this is fine
        if scrollView.contentOffset.y == cellOffset(for: 0) {
            delegate?.listDidScrollToToday()
        }

        if notifyDelegate {
            delegate?.listDidEndScrolling(dayComponent: currentDayComponent)
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if notifyDelegate {
            delegate?.listDidBeginScrolling()
        }

        let scrollOffset = adjustedScrollOffset(scrollView.contentOffset.y)

        let currentIndex = min(max(Int(scrollOffset / Constants.List.blockHeight), 0), descendingDayComponents.count-1)

        let scrolledDayComponent = descendingDayComponents[currentIndex]
        let scrolledMonthYearComponent = scrolledDayComponent.monthAndYear

        determineHeaderAndFooterVisibilityAndOffset(scrollOffset: scrollOffset)

        monthYearSideBarState.setSideBarOffsetAndMonthYearComponent(
            scrollOffset: scrollOffset,
            monthYearComponent: scrolledMonthYearComponent)

        withAnimation(.spring(response: 0.55, dampingFraction: 0.4)) {
            currentDayComponent = scrolledDayComponent
        }
    }

    private func determineHeaderAndFooterVisibilityAndOffset(scrollOffset: CGFloat) {
        determineHeaderVisibilityAndOffset(for: scrollOffset)
        determineFooterVisibilityAndOffset(for: scrollOffset)
    }

    private func determineHeaderVisibilityAndOffset(for offset: CGFloat) {
        withAnimation(.easeInOut(duration: 0.05)) {
            shouldShowHeader = offset < -minDragDistanceToShowHeaderOrFooter
            if shouldShowHeader {
                headerFooterOffset = -offset / 1.3
            } else {
                if !shouldShowFooter {
                    headerFooterOffset = 0
                }
            }
        }
    }

    private func determineFooterVisibilityAndOffset(for offset: CGFloat) {
        let maxVisibleHeight = (listContentHeight < listHeight) ? listContentHeight : listHeight
        let gapBetweenOffsetAndListEnd = listContentHeight - offset
        let differenceBetweenVisibleHeightAndGapToEnd = maxVisibleHeight - gapBetweenOffsetAndListEnd

        withAnimation(.easeInOut(duration: 0.05)) {
            shouldShowFooter = differenceBetweenVisibleHeightAndGapToEnd > minDragDistanceToShowHeaderOrFooter
            if shouldShowFooter {
                headerFooterOffset = -(differenceBetweenVisibleHeightAndGapToEnd - minDragDistanceToShowHeaderOrFooter) / 1.3
            } else {
                if !shouldShowHeader {
                    headerFooterOffset = 0
                }
            }
        }
    }

}
