// Kevin Li - 9:58 PM - 6/1/20

import SwiftUI

class VisitsSideBarTracker: NSObject, ObservableObject {

    @Published var currentDayComponent: DateComponents = .init()
    @Published var isDragging: Bool = false

    @Published var currentMonthYearComponent: DateComponents = .init()
    @Published var offset: CGFloat = .zero

    var listHeight: CGFloat!
    private let descendingDayComponents: [DateComponents]
    private let maxYForDayComponents: [DateComponents: CGFloat]

    private var tableView: UITableView!
    private var oldDelegate: UITableViewDelegate?

    private var previousMaxY: CGFloat = -VisitPreviewConstants.startShiftRangeHeight-1

    init(descendingDayComponents: [DateComponents]) {
        self.descendingDayComponents = descendingDayComponents
        maxYForDayComponents = descendingDayComponents.pairWithMaxY
    }

    func attach(to tableView: UITableView) {
        if self.tableView == nil {
            self.tableView = tableView.withNearlyFullPageFooter(listHeight: listHeight)

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

}

private extension VisitsSideBarTracker {

    var listCenter: CGFloat {
        listHeight / 2
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
        setSideBarOffsetAndCorrespondingMonthYearComponent(scrollOffset: scrollView.contentOffset.y)
    }

    private func setSideBarOffsetAndCorrespondingMonthYearComponent(scrollOffset: CGFloat) {
        // To get the current index, we divide the current scroll offset by the height of the
        // day block, which is constant. By casting the result to an Int, we essentially perform
        // a floor operation, giving us the current day component's index
        let currentIndex = Int(scrollOffset / VisitPreviewConstants.blockHeight)
        // User may scroll beyond the top or bottom of the list, in which we don't want to offset the side bar
        print("scrollviewdidscroll(scrollOffset): \(scrollOffset)")
        print("scrollviewdidscroll(index): \(currentIndex)")
        guard scrollOffset >= 0 && currentIndex < descendingDayComponents.endIndex else { return }

        let scrolledDayComponent = descendingDayComponents[currentIndex]
        let scrolledMonthYearComponent = scrolledDayComponent.monthAndYear

        let maxY = maxYForDayComponents[scrolledMonthYearComponent]!
        let gapBetweenMaxYandCurrentScrollOffset = maxY - scrollOffset

        if listHeight > gapBetweenMaxYandCurrentScrollOffset {
            let isWithinShiftRangeToNextMonthAndYear = gapBetweenMaxYandCurrentScrollOffset <= VisitPreviewConstants.endShiftRangeHeight
            if isWithinShiftRangeToNextMonthAndYear {
                let isNotLastCell = currentIndex < descendingDayComponents.endIndex-1
                if isNotLastCell {
                    // make it start offsetting to middle of screen if it's not last cell
                    // this is only the first half of the animation
                    let delta = VisitPreviewConstants.blocksInEndShiftRange * (listCenter / VisitPreviewConstants.blocksInShiftRange) / VisitPreviewConstants.endShiftRangeHeight
                    let factor = VisitPreviewConstants.endShiftRangeHeight - gapBetweenMaxYandCurrentScrollOffset
                    offset = delta * factor
                    previousMaxY = maxY
                }
            } else {
                // Not within shift range but near. Keep aligning the sideBar to the
                // center of the visible portion of the current monthAndYear's part
                // inside the list.
                offset = gapBetweenMaxYandCurrentScrollOffset / 2
            }
        } else {
            let gapBetweenCurrentScrollOffsetAndPreviousMaxY = scrollOffset - previousMaxY
            let isWithinShiftRangeFromLastMonthAndYear = abs(gapBetweenCurrentScrollOffsetAndPreviousMaxY) <= VisitPreviewConstants.startShiftRangeHeight

            if isWithinShiftRangeFromLastMonthAndYear {
                let isNotLastCell = currentIndex < descendingDayComponents.endIndex-1
                if isNotLastCell {
                    // second half of the animation to offset to the middle of the list
                    let delta = VisitPreviewConstants.blocksInStartShiftRange * (listCenter / VisitPreviewConstants.blocksInShiftRange) / VisitPreviewConstants.startShiftRangeHeight
                    let factor = VisitPreviewConstants.startShiftRangeHeight - (VisitPreviewConstants.startShiftRangeHeight - gapBetweenCurrentScrollOffsetAndPreviousMaxY)
                    offset = VisitPreviewConstants.endShiftRangeHeight + (delta * factor)
                }
            } else {
                // We want the sideBar to be centered to the list if the current
                // monthAndYear's part inside the list is bigger than the visible
                // portion of the list on the screen
                if offset != listHeight / 2 {
                    offset = listHeight / 2
                }
            }
        }

        if currentMonthYearComponent != scrolledMonthYearComponent {
            currentMonthYearComponent = scrolledMonthYearComponent
        }

        currentDayComponent = scrolledDayComponent
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

    func withNearlyFullPageFooter(listHeight: CGFloat) -> UITableView {
        allowsSelection = false
        backgroundColor = .clear
        separatorStyle = .none

        contentInset = UIEdgeInsets(top: -adjustedContentInset.top,
                                    left: -adjustedContentInset.left,
                                    bottom: -adjustedContentInset.bottom,
                                    right: -adjustedContentInset.right)

        let footerHeightWhereOnlyLastCellIsVisible = listHeight - VisitPreviewConstants.blockHeight

        // TODO: should include like quote
        tableHeaderView = UIView(frame: CGRect(x: 0, y: 0,
                                               width: screen.width,
                                               height: statusBarHeight))
        tableFooterView = UIView(frame: CGRect(x: 0, y: 0,
                                               width: screen.width,
                                               height: footerHeightWhereOnlyLastCellIsVisible))

        // TODO: remove the scroll indicator and add custom scroll indicator using the month year side bar as a scroll mechanism
        return self
    }

}
