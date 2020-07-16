// Kevin Li - 12:12 PM - 6/1/20

import Foundation

extension DateComponents: Comparable {

    public static func < (lhs: DateComponents, rhs: DateComponents) -> Bool {
        lhs.date < rhs.date
    }

    var date: Date {
        appCalendar.date(from: self) ?? Date.distantFuture
    }

}
