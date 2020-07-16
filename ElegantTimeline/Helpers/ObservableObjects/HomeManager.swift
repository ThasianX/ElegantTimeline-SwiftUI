// Kevin Li - 4:13 PM - 7/2/20

import Combine
import ElegantCalendar
import SwiftUI

let appCalendar = Calendar.current

class HomeManager: ObservableObject {

    @Published var scrollState: PageScrollState = .init()
    @Published var appTheme: AppTheme = .royalBlue

    let visitsProvider: VisitsProvider
    let sideBarTracker: VisitsSideBarTracker

    let yearlyCalendarManager: YearlyCalendarManager
    let monthlyCalendarManager: MonthlyCalendarManager

    private var anyCancellable: AnyCancellable?

    init(visits: [Visit]) {
        visitsProvider = VisitsProvider(visits: visits)
        sideBarTracker = VisitsSideBarTracker(
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
        sideBarTracker.delegate = self

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

    var visitsProvider: VisitsProvider {
        manager.visitsProvider
    }

    var sideBarTracker: VisitsSideBarTracker {
        manager.sideBarTracker
    }

    var yearlyCalendarManager: YearlyCalendarManager {
        manager.yearlyCalendarManager
    }

    var monthlyCalendarManager: MonthlyCalendarManager {
        manager.monthlyCalendarManager
    }

    func changeTheme(to theme: AppTheme) {
        manager.appTheme = theme
    }

}
