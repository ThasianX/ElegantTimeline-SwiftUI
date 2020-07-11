// Kevin Li - 4:13 PM - 7/2/20

import Combine
import ElegantCalendar
import SwiftUI

let appCalendar = Calendar.current

class HomeManager: ObservableObject {

    @Published var canDrag: Bool = true
    @Published var scrollState: PageScrollState

    let calendarManager: ElegantCalendarManager
    let sideBarTracker: VisitsSideBarTracker

    let visitsProvider: VisitsProvider
    private var anyCancellable = Set<AnyCancellable>()

    init(visits: [Visit]) {
        visitsProvider = VisitsProvider(visits: visits)
        sideBarTracker = VisitsSideBarTracker(
            descendingDayComponents: visitsProvider.descendingDayComponents)
        calendarManager = ElegantCalendarManager(
            configuration: CalendarConfiguration(
                ascending: false,
                startDate: visitsProvider.descendingDayComponents.last!.date,
                endDate: visitsProvider.descendingDayComponents.first!.date,
                themeColor: .blackPearl))

        scrollState = PageScrollState(calendarManager: calendarManager)

        sideBarTracker.delegate = self

        calendarManager.datasource = self
        calendarManager.delegate = self

        scrollState.objectWillChange.sink { _ in
            self.objectWillChange.send()
        }.store(in: &anyCancellable)
    }

}

extension HomeManager: ElegantCalendarDataSource {

    func calendar(backgroundColorOpacityForDate date: Date) -> Double {
        Double((visitsProvider.visitsForDayComponents[date.dateComponents]?.count ?? 0) + 2) / 7.0
    }

    func calendar(viewForSelectedDate date: Date, dimensions size: CGSize) -> AnyView {
        VisitsListView(visits: visitsProvider.visitsForDayComponents[date.dateComponents] ?? [],
                              height: size.height).erased
    }

}

extension HomeManager: ElegantCalendarDelegate {

    func calendar(didSelectDate date: Date) {
        sideBarTracker.scroll(to: date)
    }

    func calendar(willDisplayMonth date: Date) {
        if !appCalendar.isDate(date, equalTo: sideBarTracker.currentDayComponent.date, toGranularities: [.month, .year]) {
            sideBarTracker.scroll(to: appCalendar.endOfMonth(for: date))
        }
    }

}

extension HomeManager: VisitsListDelegate {

    func listDidBeginScrolling() {
        canDrag = false
    }

    func listDidEndScrolling(dayComponent: DateComponents) {
        calendarManager.scrollToMonth(dayComponent.date, animated: false)
        canDrag = true
    }

    func listDidScrollToToday() {
        calendarManager.scrollToDay(Date(), animated: false)
    }

}
