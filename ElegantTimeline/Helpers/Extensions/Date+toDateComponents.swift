// Kevin Li - 4:24 PM - 6/1/20

import Foundation

extension Date {

    var dateComponents: DateComponents {
        appCalendar.dateComponents([.day, .month, .year], from: self)
    }

    var monthYearComponents: DateComponents {
        appCalendar.dateComponents([.month, .year], from: self)
    }
    
}
