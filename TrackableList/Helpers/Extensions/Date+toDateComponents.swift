// Kevin Li - 4:24 PM - 6/1/20

import Foundation

extension Date {

    var dateComponents: DateComponents {
        Calendar.current.dateComponents([.day, .month, .year], from: self)
    }
    
}
