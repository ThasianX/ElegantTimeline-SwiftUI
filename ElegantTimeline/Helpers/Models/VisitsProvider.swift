// Kevin Li - 11:43 PM - 7/10/20

import SwiftUI

struct VisitsProvider {

    let visitsForDayComponents: [DateComponents: [Visit]]
    let descendingDayComponents: [DateComponents]

    init(visits: [Visit]) {
        visitsForDayComponents = Dictionary(
            grouping: visits,
            by: { $0.arrivalDate.dateComponents }).visitsSortedAscByArrivalDate
        descendingDayComponents = visitsForDayComponents.descendingDatesWithGapsFilledIn
    }

}

private extension Dictionary where Value == [Visit] {

    var visitsSortedAscByArrivalDate: Dictionary {
        mapValues { $0.sortAscByArrivalDate }
    }

}

private extension Array where Element == Visit {

    var sortAscByArrivalDate: Array {
        sorted(by: { $0.arrivalDate < $1.arrivalDate })
    }

}

private extension Dictionary where Key == DateComponents {

    var descendingDatesWithGapsFilledIn: [Key] {
        Array(stride(from: keys.max()!,
                     through: keys.min()!,
                     by: -1)) // most recent to oldest
    }

}
