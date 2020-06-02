// Kevin Li - 7:31 PM - 5/25/20

import Foundation

extension Date {

    var timeOnlyWithPadding: String {
        Formatter.timeOnlyWithPadding.string(from: self)
    }

    var fullMonthWithYear: String {
        Formatter.fullMonthWithYear.string(from: self)
    }

    var abbreviatedDayOfWeek: String {
        Formatter.abbreviatedDayOfWeek.string(from: self)
    }

    var dayOfMonth: String {
        Formatter.dayOfMonth.string(from: self)
    }

}

extension Formatter {

    static let timeOnlyWithPadding: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }()

    static let fullMonthWithYear: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM y"
        return formatter
    }()

    static let abbreviatedDayOfWeek: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter
    }()

    static let dayOfMonth: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }()

}
