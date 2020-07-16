// Kevin Li - 12:53 AM - 7/16/20

import SwiftUI

fileprivate let hiddenOffset: CGFloat = screen.height + 100

class MonthYearSideBarState: ObservableObject, UITableViewDirectAccess {

    @Published var monthYear1Component: DateComponents = .init()
    @Published var monthYear1Offset: CGFloat = .zero
    @Published var monthYear2Component: DateComponents = .init()
    @Published var monthYear2Offset: CGFloat = hiddenOffset

    private var isMonthYear1Active: Bool {
        monthYear1Offset < monthYear2Offset
    }

    let descendingDayComponents: [DateComponents]
    private lazy var maxYForMonthYearComponents: [DateComponents: CGFloat] = {
        descendingDayComponents.pairWithMaxY
    }()

    var tableView: UITableView!

    init(descendingDayComponents: [DateComponents]) {
        self.descendingDayComponents = descendingDayComponents
    }

    func setSideBarOffsetAndMonthYearComponent(scrollOffset: CGFloat, monthYearComponent: DateComponents) {
        let maxY = maxYForMonthYearComponents[monthYearComponent]!

        let isCurrentMonthYearTheFirstMonthYearOfList = monthYearComponent.isInSameMonthAndYear(as: descendingDayComponents.first!)
        let isCurrentMonthYearTheLastMonthYearOfList = monthYearComponent.isInSameMonthAndYear(as: descendingDayComponents.last!)
        let isNextMonthYearTheLastMonthYearOfList = monthYearComponent.subtractingMonth.isInSameMonthAndYear(as: descendingDayComponents.last!)

        if isCurrentMonthYearTheFirstMonthYearOfList {
            configureSideBarForFirstMonth(
                monthYearComponent: monthYearComponent,
                scrollOffset: scrollOffset,
                maxY: maxY)
            if isCurrentMonthYearTheLastMonthYearOfList {
                monthYear2Offset = hiddenOffset
                return
            }
        } else if isCurrentMonthYearTheLastMonthYearOfList {
            configureSideBarForLastMonth(
                isTrailingMonth: false,
                monthYearComponent: monthYearComponent,
                scrollOffset: scrollOffset,
                maxY: maxY)
            return
        } else {
            configureSideBarForLeadingMonth(
                monthYearComponent: monthYearComponent,
                scrollOffset: scrollOffset,
                maxY: maxY)
        }

        if isNextMonthYearTheLastMonthYearOfList {
            configureSideBarForLastMonth(
                isTrailingMonth: true,
                monthYearComponent: monthYearComponent,
                scrollOffset: scrollOffset,
                maxY: maxY)
        } else {
            configureSideBarForTrailingMonth(
                monthYearComponent: monthYearComponent,
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

}

private extension Array where Element == DateComponents {

    // We want to know the the max y for each monthYear.
    // This will allow us to properly animate the slide animation
    var pairWithMaxY: [DateComponents: CGFloat] {
        var currentOffset: CGFloat = .zero
        return reduce(into: [DateComponents: CGFloat]()) {
            currentOffset += Constants.List.blockHeight
            $0[$1.monthAndYear, default: .zero] = currentOffset
        }
    }

}

private extension DateComponents {

    var addingMonth: DateComponents {
        appCalendar.date(byAdding: .month, value: 1, to: date)?.monthYearComponents ?? self
    }

    var subtractingMonth: DateComponents {
        appCalendar.date(byAdding: .month, value: -1, to: date)?.monthYearComponents ?? self
    }

    func isInSameMonthAndYear(as components: DateComponents) -> Bool {
        monthAndYear == components.monthAndYear
    }

}
