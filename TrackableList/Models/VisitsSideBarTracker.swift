// Kevin Li - 9:58 PM - 6/1/20

import SwiftUI

class VisitsSideBarTracker: NSObject, ObservableObject {

    @Published var currentMonthYearComponent: DateComponents = .init()
    @Published var offset: CGFloat = .zero

    var listHeight: CGFloat!
    private let descendingDayComponents: [DateComponents]
    private let maxYForDayComponents: [DateComponents: CGFloat]

    private var tableView: UITableView!
    private var oldDelegate: UITableViewDelegate?

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

}

private extension UITableView {

    func withNearlyFullPageFooter(listHeight: CGFloat) -> UITableView {
        allowsSelection = false
        backgroundColor = .clear
        separatorStyle = .none
        separatorInset = .zero

        let footerHeightWhereOnlyLastCellIsVisible = listHeight - VisitPreviewConstants.blockHeight

        tableFooterView = UIView(frame: CGRect(x: 0, y: 0,
                                               width: screen.width,
                                               height: footerHeightWhereOnlyLastCellIsVisible))

        return self
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

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        setSideBarOffsetAndCorrespondingMonthYearComponent(scrollOffset: scrollView.contentOffset.y)
    }

    private func setSideBarOffsetAndCorrespondingMonthYearComponent(scrollOffset: CGFloat) {
        // To get the current index, we divide the current scroll offset by the height of the
        // day block, which is constant. By casting the result to an Int, we essentially perform
        // a floor operation, giving us the current day component's index
        let currentIndex = Int(scrollOffset / VisitPreviewConstants.blockHeight)
        // User may scroll beyond the top or bottom of the list, in which we don't want to offset the side bar
        guard currentIndex >= 0 && currentIndex < descendingDayComponents.endIndex else { return }

        let scrolledMonthYearComponent = descendingDayComponents[currentIndex].monthAndYear

        let maxY = maxYForDayComponents[scrolledMonthYearComponent]!
        let gapBetweenMaxYandCurrentScrollOffset = maxY - scrollOffset
        
        if listHeight > gapBetweenMaxYandCurrentScrollOffset {
            let isWithinShiftRangeToNextMonthAndYear = gapBetweenMaxYandCurrentScrollOffset <= VisitPreviewConstants.shiftRangeHeight
            if isWithinShiftRangeToNextMonthAndYear {
                let isNotLastCell = currentIndex < descendingDayComponents.endIndex-1
                if isNotLastCell {
                    // make it start offsetting to middle of screen if it's not last cell
                    let delta = (listHeight / 2) / VisitPreviewConstants.shiftRangeHeight
                    let factor = VisitPreviewConstants.shiftRangeHeight - gapBetweenMaxYandCurrentScrollOffset
                    offset = delta * factor
                }
            } else {
                // Not within shift range but near. Keep aligning the sideBar to the
                // center of the visible portion of the current monthAndYear's part
                // inside the list.
                offset = gapBetweenMaxYandCurrentScrollOffset / 2
            }
        } else {
            // We want the sideBar to be centered to the list if the current
            // monthAndYear's part inside the list is bigger than the visible
            // portion of the list on the screen
            if offset != listHeight / 2 {
                offset = listHeight / 2
            }
        }

        if currentMonthYearComponent != scrolledMonthYearComponent {
            withAnimation {
                currentMonthYearComponent = scrolledMonthYearComponent
            }
        }
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
