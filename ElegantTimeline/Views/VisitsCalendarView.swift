// Kevin Li - 4:09 PM - 7/2/20

import ElegantCalendar
import SwiftUI

struct VisitsCalendarView: View {

    let calendarManager: ElegantCalendarManager

    var body: some View {
        ElegantCalendarView(calendarManager: calendarManager)
    }

}
