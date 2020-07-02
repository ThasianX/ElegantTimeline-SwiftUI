// Kevin Li - 9:58 PM - 6/1/20

import SwiftUI

private enum ScrollDirection {

    case up
    case down

}

class VisitsSideBarTracker: NSObject, ObservableObject {

    @Published var currentDayComponent: DateComponents = .init()
    @Published var isDragging: Bool = false

    @Published var monthYear1Component: DateComponents = .init()
    @Published var monthYear1Offset: CGFloat = .zero
    @Published var monthYear2Component: DateComponents = .init()
    @Published var monthYear2Offset: CGFloat = .zero

    private let indexForDayComponents: [DateComponents: Int]

    var listHeight: CGFloat!
    private let descendingDayComponents: [DateComponents]
    private let maxYForDayComponents: [DateComponents: CGFloat]

    private var tableView: UITableView!
    private var oldDelegate: UITableViewDelegate?

    private var previousMaxY: CGFloat = -VisitPreviewConstants.startShiftRangeHeight-1

    private var isFastDraggingTimer: Timer? = nil
    private var isFastDragging: Bool = false

    @Published var shouldShowHeader: Bool = false
    @Published var shouldShowFooter: Bool = false
    @Published var headerFooterOffset: CGFloat = .zero

    init(descendingDayComponents: [DateComponents]) {
        self.descendingDayComponents = descendingDayComponents
        indexForDayComponents = descendingDayComponents.pairKeysWithIndex
        maxYForDayComponents = descendingDayComponents.pairWithMaxY
    }

}

fileprivate let monthScrollDistance = VisitPreviewConstants.blockHeight * 30
fileprivate let tableViewContentOffsetDamping: CGFloat = 6

extension VisitsSideBarTracker {

    func attach(to tableView: UITableView) {
        if self.tableView == nil {
            self.tableView = tableView.withNearlyFullPageFooter

            oldDelegate = tableView.delegate
            tableView.delegate = self
        }
    }

    func setInitialScrollOffset() {
        setSideBarOffsetAndCorrespondingMonthYearComponent(scrollOffset: 0)
    }

    func scroll(to date: Date) {
        let startOfTodayForDate = Calendar.current.startOfDay(for: date)
        let startOfTodayForFirstDay = descendingDayComponents.first!.date

        // because the list is descending, we reverse the from and to date
        let index = Calendar.current.dateComponents([.day], from: startOfTodayForDate, to: startOfTodayForFirstDay).day!
        self.tableView.scrollToRow(at: IndexPath(row: index, section: 0), at: .top, animated: true)
    }

    func fastScroll(translation: CGFloat) {
        isFastDragging = true
        scrollViewWillBeginDragging(tableView)

        isFastDraggingTimer?.invalidate()
        isFastDraggingTimer = .scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
            self.animateTableViewContentOffset(by: translation, duration: 0.01)
        }
    }

    func fastDragDidEnd(translation: CGFloat) {
        guard isFastDragging else { return }

        isFastDraggingTimer?.invalidate()
        isFastDraggingTimer = nil

        isFastDragging = false
        scrollViewDidEndDecelerating(tableView)

        animateTableViewContentOffset(by: translation, duration: 0.1)
    }

    private func animateTableViewContentOffset(by offset: CGFloat, duration: Double) {
        var newOffset = tableView.contentOffset.y + (offset / tableViewContentOffsetDamping)
        let upperEnd = (CGFloat(descendingDayComponents.count - 6)*VisitPreviewConstants.blockHeight) // only for bigger phones

        if newOffset < -VisitPreviewConstants.listTopPadding {
            newOffset = .zero
        } else if newOffset > upperEnd {
            newOffset = upperEnd
        }

        animateTableView(to: newOffset, duration: duration)
    }

    private func animateTableView(to offset: CGFloat, duration: Double) {
        DispatchQueue.main.async {
            UIView.animate(
                withDuration: duration,
                delay: 0,
                options: .curveEaseInOut,
                animations: {
                    self.tableView.contentOffset.y = offset
                },
                completion: nil)
        }
    }

}

extension VisitsSideBarTracker: FromTodayPopupProvider {

    var weeksFromCurrentMonthToToday: Int {
        let startOfToday = Calendar.current.startOfDay(for: Date())
        let startOfSelectedDate = Calendar.current.startOfDay(for: currentDayComponent.date)
        return Calendar.current.dateComponents([.weekOfYear], from: startOfToday, to: startOfSelectedDate).weekOfYear!
    }

}

extension VisitsSideBarTracker: MonthYearSideBarProvider {}

extension VisitsSideBarTracker: ScrollToTodayProvider {

    func scrollToToday() {
        tableView.setContentOffset(.zero, animated: true)
    }

}

fileprivate let minDragDistanceToShowHeaderOrFooter: CGFloat = 80

extension VisitsSideBarTracker: UITableViewDelegate {

    override func responds(to aSelector: Selector!) -> Bool {
        super.responds(to: aSelector) || oldDelegate?.responds(to: aSelector) ?? false
    }

    override func forwardingTarget(for aSelector: Selector!) -> Any? {
        if aSelector != #selector(UITableViewDelegate.scrollViewDidScroll) {
            return oldDelegate
        }
        return nil
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if abs(weeksFromCurrentMonthToToday) > 3 {
            DispatchQueue.main.async {
                withAnimation(.easeInOut) {
                    self.isDragging = true
                }
            }
        }
    }

    // Kudos: https://stackoverflow.com/a/20943198/6074750
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let targetOffset = targetContentOffset.pointee.y
        var index = floor(targetOffset / VisitPreviewConstants.blockHeight)

        if (targetOffset - (floor(targetOffset / VisitPreviewConstants.blockHeight) * VisitPreviewConstants.blockHeight)) > VisitPreviewConstants.blockHeight {
            index += 1
        }

        targetContentOffset.pointee.y = index * VisitPreviewConstants.blockHeight
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            withAnimation(.easeInOut) {
                self.isDragging = false
            }
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollOffset = scrollView.contentOffset.y
        determineHeaderAndFooterVisibilityAndOffset(scrollOffset: scrollOffset)
        setSideBarOffsetAndCorrespondingMonthYearComponent(scrollOffset: scrollOffset)
    }

    private func determineHeaderAndFooterVisibilityAndOffset(scrollOffset: CGFloat) {
        determineHeaderVisibilityAndOffset(for: scrollOffset)
        determineFooterVisibilityAndOffset(for: scrollOffset)
    }

    private func determineHeaderVisibilityAndOffset(for offset: CGFloat) {
        guard tableView.isTracking else {
            withAnimation(.easeOut) {
                shouldShowHeader = false
                headerFooterOffset = .zero
            }
            return
        }

        withAnimation(.easeOut) {
            shouldShowHeader = offset < -minDragDistanceToShowHeaderOrFooter
        }

        if offset < 0 {
            headerFooterOffset = -offset / 1.5
        }
    }

    private func determineFooterVisibilityAndOffset(for offset: CGFloat) {
        guard tableView.isTracking else {
            withAnimation(.easeOut) {
                shouldShowFooter = false
                headerFooterOffset = .zero
            }
            return
        }

        let height = tableView.frame.size.height
        let gapBetweenOffsetAndListEnd = tableView.contentSize.height - offset
        let differenceBetweenListHeightAndGapToEnd = height - gapBetweenOffsetAndListEnd

        withAnimation(.easeOut) {
            shouldShowFooter = differenceBetweenListHeightAndGapToEnd > minDragDistanceToShowHeaderOrFooter
        }

        if differenceBetweenListHeightAndGapToEnd > 0 {
            headerFooterOffset = -differenceBetweenListHeightAndGapToEnd / 2
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

        let maxY = maxYForDayComponents[scrolledMonthYearComponent]!
        let gapBetweenMaxYandCurrentScrollOffset = maxY - scrollOffset

        if listHeight > gapBetweenMaxYandCurrentScrollOffset {
            let isCurrentMonthYearTheFirstMonthYearOfList = scrolledMonthYearComponent.isInSameMonthAndYear(as: descendingDayComponents.first!)
            let isCurrentMonthYearTheLastMonthYearOfList = scrolledMonthYearComponent.subtractingMonth.isInSameMonthAndYear(as: descendingDayComponents.last!)

            if isCurrentMonthYearTheFirstMonthYearOfList || isCurrentMonthYearTheLastMonthYearOfList {
                configureSideBarForEdges(
                    isFirst: isCurrentMonthYearTheFirstMonthYearOfList,
                    monthYearComponent: scrolledMonthYearComponent,
                    scrollOffset: scrollOffset,
                    maxY: maxY)
            } else {
                configureSideBarForTransition(
                    monthYearComponent: scrolledMonthYearComponent,
                    gapBetweenMaxYandCurrentScrollOffset: gapBetweenMaxYandCurrentScrollOffset)
            }
        } else {
            configureSideBarForScrolling(
                monthYearComponent: scrolledMonthYearComponent,
                gapBetweenMaxYandCurrentScrollOffset: gapBetweenMaxYandCurrentScrollOffset)
        }

        currentDayComponent = scrolledDayComponent
    }

    private func configureSideBarForEdges(
        isFirst: Bool,
        monthYearComponent: DateComponents,
        scrollOffset: CGFloat,
        maxY: CGFloat) {
        let gapBetweenMaxYandCurrentScrollOffset = maxY - scrollOffset

        if isFirst {
            let scrollDifference = maxY - gapBetweenMaxYandCurrentScrollOffset
            let centerOfFirstMonth = maxY / 2
            let leadingOffset = centerOfFirstMonth - scrollDifference

            let trailingOffset = gapBetweenMaxYandCurrentScrollOffset + listCenter

            monthYear1Component = monthYearComponent
            monthYear1Offset = leadingOffset

            monthYear2Component = monthYearComponent.subtractingMonth
            monthYear2Offset = trailingOffset
        } else {
            let scrollDifference = listHeight - gapBetweenMaxYandCurrentScrollOffset
            let leadingOffset = listCenter - scrollDifference

            let gapBetweenEndOfListAndMaxY = tableView.contentSize.height - maxY
            let trailingOffset = gapBetweenMaxYandCurrentScrollOffset + gapBetweenEndOfListAndMaxY/2

            if isMonthYear1Active {
                monthYear1Component = monthYearComponent
                monthYear1Offset = leadingOffset

                monthYear2Component = monthYearComponent.subtractingMonth
                monthYear2Offset = trailingOffset
            } else {
                monthYear2Component = monthYearComponent
                monthYear2Offset = leadingOffset

                monthYear1Component = monthYearComponent.subtractingMonth
                monthYear1Offset = trailingOffset
            }
        }
    }

    private func configureSideBarForTransition(
        monthYearComponent: DateComponents,
        gapBetweenMaxYandCurrentScrollOffset: CGFloat) {
        let scrollDifference = listHeight - gapBetweenMaxYandCurrentScrollOffset

        if isMonthYear1Active {
            monthYear1Component = monthYearComponent
            monthYear1Offset = listCenter - scrollDifference

            monthYear2Component = monthYearComponent.subtractingMonth
            monthYear2Offset = gapBetweenMaxYandCurrentScrollOffset + listCenter
        } else {
            monthYear2Component = monthYearComponent
            monthYear2Offset = listCenter - scrollDifference

            monthYear1Component = monthYearComponent.subtractingMonth
            monthYear1Offset = gapBetweenMaxYandCurrentScrollOffset + listCenter
        }
    }

    private func configureSideBarForScrolling(
        monthYearComponent: DateComponents,
        gapBetweenMaxYandCurrentScrollOffset: CGFloat) {
        if isMonthYear1Active {
            monthYear1Component = monthYearComponent
            monthYear1Offset = listCenter

            monthYear2Component = monthYearComponent.subtractingMonth
            monthYear2Offset = gapBetweenMaxYandCurrentScrollOffset + listCenter
        } else {
            monthYear2Component = monthYearComponent
            monthYear2Offset = listCenter

            monthYear1Component = monthYearComponent.subtractingMonth
            monthYear1Offset = gapBetweenMaxYandCurrentScrollOffset + listCenter
        }
    }

    private var listCenter: CGFloat {
        listHeight / 2
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

private extension UITableView {

    var withNearlyFullPageFooter: UITableView {
        showsVerticalScrollIndicator = false
        allowsSelection = false
        backgroundColor = .clear
        separatorStyle = .none
        scrollsToTop = false

        contentInset = UIEdgeInsets(top: -adjustedContentInset.top,
                                    left: -adjustedContentInset.left,
                                    bottom: -adjustedContentInset.bottom,
                                    right: -adjustedContentInset.right)


        tableHeaderView = UIView(frame: CGRect(x: 0, y: 0,
                                               width: screen.width,
                                               height: VisitPreviewConstants.listTopPadding))

        return self
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
        Calendar.current.date(byAdding: .month, value: 1, to: date)?.dateComponents ?? self
    }

    var subtractingMonth: DateComponents {
        Calendar.current.date(byAdding: .month, value: -1, to: date)?.dateComponents ?? self
    }

    func isInSameMonthAndYear(as components: DateComponents) -> Bool {
        monthAndYear == components.monthAndYear
    }

}
