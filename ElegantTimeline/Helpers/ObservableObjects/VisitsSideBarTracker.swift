// Kevin Li - 9:58 PM - 6/1/20

import SwiftUI

private enum ScrollDirection {

    case up
    case down

}

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

fileprivate let hiddenOffset: CGFloat = screen.height + 100

class VisitsSideBarTracker: NSObject, ObservableObject, UITableViewDirectAccess {

    @Published var currentDayComponent: DateComponents = .init()
    @Published var showFromTodayPopup: Bool = false

    @Published var monthYear1Component: DateComponents = .init()
    @Published var monthYear1Offset: CGFloat = .zero
    @Published var monthYear2Component: DateComponents = .init()
    @Published var monthYear2Offset: CGFloat = hiddenOffset

    private let indexForDayComponents: [DateComponents: Int]

    let listHeight: CGFloat = screen.height
    let descendingDayComponents: [DateComponents]
    private lazy var maxYForMonthYearComponents: [DateComponents: CGFloat] = {
        descendingDayComponents.pairWithMaxY
    }()

    var tableView: UITableView!

    private var isFastDraggingTimer: Timer? = nil
    private var isFastDragging: Bool = false

    @Published var shouldShowHeader: Bool = false
    @Published var shouldShowFooter: Bool = false
    @Published var headerFooterOffset: CGFloat = .zero

    var delegate: VisitsListDelegate?

    private var notifyDelegate: Bool = true

    lazy var startingOffset: CGFloat = {
        -VisitPreviewConstants.listTopPadding
    }()

    private func adjustedScrollOffset(_ scrollOffset: CGFloat) -> CGFloat {
        scrollOffset - startingOffset
    }

    init(descendingDayComponents: [DateComponents]) {
        self.descendingDayComponents = descendingDayComponents
        indexForDayComponents = descendingDayComponents.pairKeysWithIndex
    }

}

fileprivate let monthScrollDistance = VisitPreviewConstants.blockHeight * 30
fileprivate let tableViewContentOffsetDamping: CGFloat = 6

extension VisitsSideBarTracker {

    func attach(to tableView: UITableView) {
        if self.tableView == nil {
            tableView.delegate = self
            self.tableView = tableView

            setSideBarOffsetAndCorrespondingMonthYearComponent(scrollOffset: .zero)

            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.scrollViewDidEndDecelerating(self.tableView)
            }
        }
    }

    func scroll(to date: Date) {
        notifyDelegate = false
        let startOfTodayForDate = appCalendar.startOfDay(for: date)
        let startOfTodayForFirstDay = descendingDayComponents.first!.date

        // because the list is descending, we reverse the from and to date
        let index = Calendar.current.dateComponents([.day], from: startOfTodayForDate, to: startOfTodayForFirstDay).day!
        let boundedIndex = max(0, index)

        scrollTableView(to: cellOffset(for: boundedIndex), animated: false) { [unowned self] in
            self.scrollViewDidEndDecelerating(self.tableView)
            self.notifyDelegate = true
        }
    }

    private func cellOffset(for index: Int) -> CGFloat {
        startingOffset + (CGFloat(index) * VisitPreviewConstants.blockHeight)
    }

}

// MARK: Fast Scrolling
extension VisitsSideBarTracker {

    func fastScroll(translation: CGFloat) {
        isFastDragging = true
        scrollViewWillBeginDragging(tableView)

        isFastDraggingTimer?.invalidate()
        isFastDraggingTimer = .scheduledTimer(withTimeInterval: 0.01, repeats: true) { [unowned self] _ in
            self.animateTableViewContentOffset(by: translation, duration: 0.01)
        }
    }

    func fastDragDidEnd(translation: CGFloat) {
        guard isFastDragging else { return }

        isFastDraggingTimer?.invalidate()
        isFastDraggingTimer = nil

        isFastDragging = false

        // TODO: animate it to a translation that is at the top of the cell
        animateTableViewContentOffset(by: translation, duration: 0.1) { [unowned self] in
            self.scrollViewDidEndDecelerating(self.tableView)
        }
    }

    private func animateTableViewContentOffset(by offset: CGFloat, duration: Double, completion: (() -> Void)? = nil) {
        let newOffset = tableView.contentOffset.y + (offset / tableViewContentOffsetDamping)

        scrollTableView(to: newOffset, duration: duration, completion: completion)
    }

    private func scrollTableView(to offset: CGFloat, duration: Double? = nil, animated: Bool = true, completion: (() -> Void)? = nil) {
        let gapBetweenOffsetAndListEnd = listContentHeight - offset
        let differenceBetweenListHeightAndGapToEnd = listHeight - gapBetweenOffsetAndListEnd

        var newOffset: CGFloat = offset

        if newOffset < startingOffset {
            newOffset = startingOffset
        } else if differenceBetweenListHeightAndGapToEnd > startingOffset {
            newOffset = (listContentHeight - listHeight) - adjustedVerticalContentInset
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

extension VisitsSideBarTracker: FromTodayPopupProvider {

    var weeksFromCurrentMonthToToday: Int {
        let startOfToday = Calendar.current.startOfDay(for: Date())
        let startOfSelectedDate = Calendar.current.startOfDay(for: currentDayComponent.date)
        let weeks = Calendar.current.dateComponents([.weekOfYear], from: startOfToday, to: startOfSelectedDate).weekOfYear!
        return weeks > 0 ? 0 : abs(weeks)
    }

}

extension VisitsSideBarTracker: MonthYearSideBarProvider {}

extension VisitsSideBarTracker: ScrollToTodayProvider {

    func scrollToToday() {
        tableView.setContentOffset(.init(x: 0, y: cellOffset(for: 0)), animated: true)
    }

}

fileprivate let minDragDistanceToShowHeaderOrFooter: CGFloat = 80

extension VisitsSideBarTracker: UITableViewDelegate {

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        delegate?.listDidBeginScrolling()
        if weeksFromCurrentMonthToToday > 3 {
            DispatchQueue.main.async {
                withAnimation(.easeInOut) {
                    self.showFromTodayPopup = true
                }
            }
        }
    }

    // Kudos: https://stackoverflow.com/a/20943198/6074750
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let targetOffset = adjustedScrollOffset(targetContentOffset.pointee.y)
        let index = round(targetOffset / VisitPreviewConstants.blockHeight)

        targetContentOffset.pointee.y = cellOffset(for: Int(index))
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if notifyDelegate {
            delegate?.listDidEndScrolling(dayComponent: currentDayComponent)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            withAnimation(.easeInOut) {
                self.showFromTodayPopup = false
            }
        }
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
        determineHeaderAndFooterVisibilityAndOffset(scrollOffset: scrollOffset)
        setSideBarOffsetAndCorrespondingMonthYearComponent(scrollOffset: scrollOffset)
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

    private var isMonthYear1Active: Bool {
        monthYear1Offset < monthYear2Offset
    }

    private func setSideBarOffsetAndCorrespondingMonthYearComponent(scrollOffset: CGFloat) {
        // To get the current index, we divide the current scroll offset by the height of the
        // day block, which is constant. By casting the result to an Int, we essentially perform
        // a floor operation, giving us the current day component's index
        let currentIndex = min(max(Int(scrollOffset / VisitPreviewConstants.blockHeight), 0), descendingDayComponents.count-1)
        
        let scrolledDayComponent = descendingDayComponents[currentIndex]
        let scrolledMonthYearComponent = scrolledDayComponent.monthAndYear
        
        defer {
            withAnimation(.spring(response: 0.55, dampingFraction: 0.4)) {
                currentDayComponent = scrolledDayComponent
            }
        }

        let maxY = maxYForMonthYearComponents[scrolledMonthYearComponent]!

        let isCurrentMonthYearTheFirstMonthYearOfList = scrolledMonthYearComponent.isInSameMonthAndYear(as: descendingDayComponents.first!)
        let isCurrentMonthYearTheLastMonthYearOfList = scrolledMonthYearComponent.isInSameMonthAndYear(as: descendingDayComponents.last!)
        let isNextMonthYearTheLastMonthYearOfList = scrolledMonthYearComponent.subtractingMonth.isInSameMonthAndYear(as: descendingDayComponents.last!)

        if isCurrentMonthYearTheFirstMonthYearOfList {
            configureSideBarForFirstMonth(
                monthYearComponent: scrolledMonthYearComponent,
                scrollOffset: scrollOffset,
                maxY: maxY)
            if isCurrentMonthYearTheLastMonthYearOfList {
                monthYear2Offset = hiddenOffset
                return
            }
        } else if isCurrentMonthYearTheLastMonthYearOfList {
            configureSideBarForLastMonth(
                isTrailingMonth: false,
                monthYearComponent: scrolledMonthYearComponent,
                scrollOffset: scrollOffset,
                maxY: maxY)
            return
        } else {
            configureSideBarForLeadingMonth(
                monthYearComponent: scrolledMonthYearComponent,
                scrollOffset: scrollOffset,
                maxY: maxY)
        }

        if isNextMonthYearTheLastMonthYearOfList {
            configureSideBarForLastMonth(
                isTrailingMonth: true,
                monthYearComponent: scrolledMonthYearComponent,
                scrollOffset: scrollOffset,
                maxY: maxY)
        } else {
            configureSideBarForTrailingMonth(
                monthYearComponent: scrolledMonthYearComponent,
                scrollOffset: scrollOffset,
                maxY: maxY)
        }
    }

    private func configureSideBarForFirstMonth(
        monthYearComponent: DateComponents,
        scrollOffset: CGFloat,
        maxY: CGFloat) {
        let maxVisibleHeight = (maxY < listHeight) ? maxY : listHeight
        let centerOffset = maxVisibleHeight / 2

        let gapBetweenMaxYandCurrentScrollOffset = maxY - scrollOffset

        let offset: CGFloat
        if scrollOffset < 0 {
            offset = centerOffset - scrollOffset
        } else if maxVisibleHeight > gapBetweenMaxYandCurrentScrollOffset {
            let scrollDifference = maxVisibleHeight - gapBetweenMaxYandCurrentScrollOffset
            offset = centerOffset - scrollDifference
        } else {
            offset = centerOffset
        }

        if isMonthYear1Active {
            monthYear1Component = monthYearComponent
            monthYear1Offset = offset
        } else {
            monthYear2Component = monthYearComponent
            monthYear2Offset = offset
        }
    }

    private func configureSideBarForLastMonth(
        isTrailingMonth: Bool,
        monthYearComponent: DateComponents,
        scrollOffset: CGFloat,
        maxY: CGFloat) {
        let contentHeight: CGFloat
        if isTrailingMonth {
            contentHeight = listContentHeight - maxY
        } else {
            let previousMonthYearComponent = monthYearComponent.addingMonth
            let previousMaxY = maxYForMonthYearComponents[previousMonthYearComponent]!
            contentHeight = listContentHeight - previousMaxY
        }

        let maxVisibleHeight = (contentHeight < listHeight) ? contentHeight : listHeight
        let centerOffset = maxVisibleHeight / 2

        let gapBetweenMaxYandCurrentScrollOffset = maxY - scrollOffset

        let offset: CGFloat
        if isTrailingMonth {
            offset = centerOffset + gapBetweenMaxYandCurrentScrollOffset
        } else if !isTrailingMonth && maxVisibleHeight > gapBetweenMaxYandCurrentScrollOffset {
            let scrollDifference = maxVisibleHeight - gapBetweenMaxYandCurrentScrollOffset
            offset = centerOffset - scrollDifference
        } else {
            offset = centerOffset
        }
        
        if isMonthYear1Active {
            monthYear2Component = isTrailingMonth ? monthYearComponent.subtractingMonth : monthYearComponent
            monthYear2Offset = offset

            if !isTrailingMonth {
                monthYear1Offset = hiddenOffset
            }
        } else {
            monthYear1Component = isTrailingMonth ? monthYearComponent.subtractingMonth : monthYearComponent
            monthYear1Offset = offset

            if !isTrailingMonth {
                monthYear2Offset = hiddenOffset
            }
        }
    }

    private func configureSideBarForLeadingMonth(
        monthYearComponent: DateComponents,
        scrollOffset: CGFloat,
        maxY: CGFloat) {
        let gapBetweenMaxYandCurrentScrollOffset = maxY - scrollOffset

        let offset: CGFloat
        if listHeight > gapBetweenMaxYandCurrentScrollOffset {
            let scrollDifference = listHeight - gapBetweenMaxYandCurrentScrollOffset
            offset = listCenter - scrollDifference
        } else {
            offset = listCenter
        }

        if isMonthYear1Active {
            monthYear1Component = monthYearComponent
            monthYear1Offset = offset
        } else {
            monthYear2Component = monthYearComponent
            monthYear2Offset = offset
        }
    }

    private func configureSideBarForTrailingMonth(
        monthYearComponent: DateComponents,
        scrollOffset: CGFloat,
        maxY: CGFloat) {
        let gapBetweenMaxYandCurrentScrollOffset = maxY - scrollOffset

        if isMonthYear1Active {
            monthYear2Component = monthYearComponent.subtractingMonth
            monthYear2Offset = listCenter + gapBetweenMaxYandCurrentScrollOffset
        } else {
            monthYear1Component = monthYearComponent.subtractingMonth
            monthYear1Offset = listCenter + gapBetweenMaxYandCurrentScrollOffset
        }
    }

    private var listCenter: CGFloat {
        listHeight / 2
    }

    private var listContentHeight: CGFloat {
        tableView.contentSize.height
    }

}

private extension Array where Element == DateComponents {

    // We want to know the the max y for each monthYear.
    // This will allow us to properly animate the slide animation
    var pairWithMaxY: [DateComponents: CGFloat] {
        var currentOffset: CGFloat = .zero
        return reduce(into: [DateComponents: CGFloat]()) {
            currentOffset += VisitPreviewConstants.blockHeight
            $0[$1.monthAndYear, default: .zero] = currentOffset
        }
    }

}

private extension Array where Element == DateComponents {

    var pairKeysWithIndex: [Element: Int] {
        zip(indices, self).reduce(into: [DateComponents: Int]()) {
            // dict[dayComponent] = indexOfDayComponent
            $0[$1.1] = $1.0
        }
    }

}

extension DateComponents {

    var addingMonth: DateComponents {
        Calendar.current.date(byAdding: .month, value: 1, to: date)?.monthYearComponents ?? self
    }

    var subtractingMonth: DateComponents {
        Calendar.current.date(byAdding: .month, value: -1, to: date)?.monthYearComponents ?? self
    }

    func isInSameMonthAndYear(as components: DateComponents) -> Bool {
        monthAndYear == components.monthAndYear
    }

}
