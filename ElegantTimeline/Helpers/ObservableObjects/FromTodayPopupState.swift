// Kevin Li - 12:54 AM - 7/16/20

import SwiftUI

class FromTodayPopupState: ObservableObject {

    @Published var showFromTodayPopup: Bool = false
    @Published var weeksFromCurrentMonthToToday: Int = 0

    func dayChanged(_ dayComponent: DateComponents) {
        let startOfToday = appCalendar.startOfDay(for: Date())
        let startOfSelectedDate = appCalendar.startOfDay(for: dayComponent.date)
        let weeks = appCalendar.dateComponents([.weekOfYear], from: startOfToday, to: startOfSelectedDate).weekOfYear!
        weeksFromCurrentMonthToToday = weeks > 0 ? 0 : abs(weeks)
    }

    func didBeginDragging() {
        if weeksFromCurrentMonthToToday > 3 {
            DispatchQueue.main.async {
                withAnimation(.easeInOut) {
                    self.showFromTodayPopup = true
                }
            }
        }
    }

    func didEndDragging() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            withAnimation(.easeInOut) {
                self.showFromTodayPopup = false
            }
        }
    }

}
