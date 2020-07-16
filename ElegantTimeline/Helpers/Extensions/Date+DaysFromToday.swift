// Kevin Li - 6:15 PM - 7/15/20

import Foundation

extension Date {

    static func daysFromToday(_ days: Int) -> Date {
        Date().addingTimeInterval(TimeInterval(60*60*24*days))
    }

}
