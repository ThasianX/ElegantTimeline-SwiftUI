// Kevin Li - 4:13 PM - 7/2/20

import Combine
import ElegantCalendar
import SwiftUI

class HomeManager: ObservableObject {

    @Published var scrollState: PageScrollState = .init()
    @Published var appTheme: AppTheme = ._white
    @Published var calendarTheme: CalendarTheme = ._white

    let visitsProvider: VisitsProvider
    let listScrollState: ListScrollState

    let yearlyCalendarManager: YearlyCalendarManager
    let monthlyCalendarManager: MonthlyCalendarManager

    private var anyCancellable: AnyCancellable?

    init(visits: [Visit]) {
        visitsProvider = VisitsProvider(visits: visits)
        listScrollState = ListScrollState(
            descendingDayComponents: visitsProvider.descendingDayComponents)

        let configuration = CalendarConfiguration(
            ascending: false,
            startDate: visitsProvider.descendingDayComponents.last!.date,
            endDate: visitsProvider.descendingDayComponents.first!.date)

        yearlyCalendarManager = YearlyCalendarManager(configuration: configuration)
        monthlyCalendarManager = MonthlyCalendarManager(configuration: configuration)

        configureDelegatesAndPublishers()
    }

    private func configureDelegatesAndPublishers() {
        listScrollState.delegate = self

        monthlyCalendarManager.datasource = self
        monthlyCalendarManager.delegate = self
        monthlyCalendarManager.communicator = self
        yearlyCalendarManager.communicator = self

        scrollState
            .onPageChanged { [weak self] page in
                guard let `self` = self else { return }
                if page == .yearlyCalendar {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                        self.yearlyCalendarManager.scrollToYear(self.monthlyCalendarManager.currentMonth)
                    }
                }
            }

        anyCancellable = scrollState.objectWillChange.sink { _ in
            self.objectWillChange.send()
        }
    }

}

extension HomeManager: MonthlyCalendarDataSource {

    func calendar(backgroundColorOpacityForDate date: Date) -> Double {
        let visitCount = visitsProvider.visitsForDayComponents[date.dateComponents]?.count ?? minVisitCount
        return Double(visitCount) / Double(maxVisitCount)
    }

    func calendar(viewForSelectedDate date: Date, dimensions size: CGSize) -> AnyView {
        VisitsListView(visits: visitsProvider.visitsForDayComponents[date.dateComponents] ?? [],
                              height: size.height).erased
    }

}

extension HomeManager: MonthlyCalendarDelegate {

    func calendar(didSelectDay date: Date) {
        listScrollState.scroll(to: date)
    }

    func calendar(willDisplayMonth date: Date) {
        guard listScrollState.currentDayComponent != DateComponents() else { return }

        if !appCalendar.isDate(date, equalTo: listScrollState.currentDayComponent.date, toGranularities: [.month, .year]) {
            listScrollState.scroll(to: appCalendar.endOfMonth(for: date))
        }
    }

}

extension HomeManager: ElegantCalendarCommunicator {

    func scrollToMonthAndShowMonthlyView(_ month: Date) {
        scrollState.scroll(to: .monthlyCalendar)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
            self.monthlyCalendarManager.scrollToMonth(month)
        }
    }

    func showYearlyView() {
        scrollState.scroll(to: .yearlyCalendar)
    }

}

extension HomeManager: VisitsListDelegate {

    func listDidBeginScrolling() {
        scrollState.canDrag = false
    }

    func listDidEndScrolling(dayComponent: DateComponents) {
        monthlyCalendarManager.scrollToMonth(dayComponent.date, animated: false)
        scrollState.canDrag = true
    }

    func listDidScrollToToday() {
        monthlyCalendarManager.scrollToDay(Date(), animated: false)
    }

}

protocol HomeManagerDirectAccess: PageScrollStateDirectAccess {

    var manager: HomeManager { get }
    var scrollState: PageScrollState { get }

}

extension HomeManagerDirectAccess {

    var scrollState: PageScrollState {
        manager.scrollState
    }

    var appTheme: AppTheme {
        manager.appTheme
    }

    var calendarTheme: CalendarTheme {
        manager.calendarTheme
    }

    var visitsProvider: VisitsProvider {
        manager.visitsProvider
    }

    var listScrollState: ListScrollState {
        manager.listScrollState
    }

    var yearlyCalendarManager: YearlyCalendarManager {
        manager.yearlyCalendarManager
    }

    var monthlyCalendarManager: MonthlyCalendarManager {
        manager.monthlyCalendarManager
    }

    // I'm guessing this is how TimePage does their theme change as well. It just makes no sense to change the
    // theme of the app everytime a new color is selected in the theme picker view. That would cause way too much
    // lag in the app. The main problem I encountered was changing the theme of the calendar, which is UI intensive.
    // If I change the calendar theme in conjunction with the app's theme, the transition from the theme picker view
    // to the menu view becomes stuttery. Thus, the only solution is as you're transitioning from the theme picker to
    // the menu, change thhe list's theme, which is pretty fast. Only after that transition is complete then do you
    // change the calendar's theme. It's so quick that the user never even notices the slight pause in the main thread.
    func changeTheme(to theme: AppTheme) {
        manager.appTheme = theme
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.manager.calendarTheme = CalendarTheme(primary: theme.primary)
        }
    }

}

private extension CalendarTheme {

    static let _white = CalendarTheme(primary: Color(._white))

}
