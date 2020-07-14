// Kevin Li - 4:13 PM - 7/2/20

import Combine
import ElegantCalendar
import SwiftUI

let appCalendar = Calendar.current

class HomeManager: ObservableObject {

    @Published var scrollState: PageScrollState = .init()
    @Published var canDrag: Bool = true

    let visitsProvider: VisitsProvider

    let sideBarTracker: VisitsSideBarTracker

    let yearlyCalendarManager: YearlyCalendarManager
    let monthlyCalendarManager: MonthlyCalendarManager

    private var anyCancellable: AnyCancellable?

    // TODO: Clean up this class later
    init(visits: [Visit]) {
        visitsProvider = VisitsProvider(visits: visits)
        sideBarTracker = VisitsSideBarTracker(
            descendingDayComponents: visitsProvider.descendingDayComponents)

        let configuration = CalendarConfiguration(
            ascending: false,
            startDate: visitsProvider.descendingDayComponents.last!.date,
            endDate: visitsProvider.descendingDayComponents.first!.date,
            themeColor: .mauvePurple)

        yearlyCalendarManager = YearlyCalendarManager(configuration: configuration)
        monthlyCalendarManager = MonthlyCalendarManager(configuration: configuration)

        scrollState.delegate = self

        sideBarTracker.delegate = self

        monthlyCalendarManager.datasource = self
        monthlyCalendarManager.delegate = self
        monthlyCalendarManager.communicator = self
        yearlyCalendarManager.communicator = self

        anyCancellable = scrollState.objectWillChange.sink { _ in
            self.objectWillChange.send()
        }
    }

}

extension HomeManager: MonthlyCalendarDataSource {

    func calendar(backgroundColorOpacityForDate date: Date) -> Double {
        Double((visitsProvider.visitsForDayComponents[date.dateComponents]?.count ?? 0) + 2) / 7.0
    }

    func calendar(viewForSelectedDate date: Date, dimensions size: CGSize) -> AnyView {
        VisitsListView(visits: visitsProvider.visitsForDayComponents[date.dateComponents] ?? [],
                              height: size.height).erased
    }

}

extension HomeManager: MonthlyCalendarDelegate {

    func calendar(didSelectDay date: Date) {
        sideBarTracker.scroll(to: date)
    }

    func calendar(willDisplayMonth date: Date) {
        guard sideBarTracker.currentDayComponent != DateComponents() else { return }

        if !appCalendar.isDate(date, equalTo: sideBarTracker.currentDayComponent.date, toGranularities: [.month, .year]) {
            sideBarTracker.scroll(to: appCalendar.endOfMonth(for: date))
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

extension HomeManager: PageScrollStateDelegate {

    func willDisplay(page: Page) {
        if page == .yearlyCalendar {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                self.yearlyCalendarManager.scrollToYear(self.monthlyCalendarManager.currentMonth)
            }
        }
    }

}

extension HomeManager: VisitsListDelegate {

    func listDidBeginScrolling() {
        canDrag = false
    }

    func listDidEndScrolling(dayComponent: DateComponents) {
        monthlyCalendarManager.scrollToMonth(dayComponent.date, animated: false)
        canDrag = true
    }

    func listDidScrollToToday() {
        monthlyCalendarManager.scrollToDay(Date(), animated: false)
    }

}
