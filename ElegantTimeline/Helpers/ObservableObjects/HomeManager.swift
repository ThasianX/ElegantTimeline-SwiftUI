// Kevin Li - 4:13 PM - 7/2/20

import Combine
import ElegantCalendar
import SwiftUI

let appCalendar = Calendar.current

class HomeManager: ObservableObject {

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

        sideBarTracker.delegate = self
        calendarManager.delegate = self
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

    // TODO: Need to fix this for calendar's scroll back to today. it seems like as it's scrolling back to today, it's like going through all the intermediate months
    func willDisplay(dayComponent: DateComponents) {
        calendarManager.scrollToMonth(dayComponent.date, animated: false)
    }

}
