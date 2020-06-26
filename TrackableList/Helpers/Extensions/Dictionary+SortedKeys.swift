// Kevin Li - 12:14 PM - 6/1/20

import Foundation

extension Dictionary where Key: Comparable {

    var ascendingKeys: [Key] {
        get {
            keys.sorted(by: { $0 < $1 })
        }
    }

    var descendingKeys: [Key] {
        get {
            keys.sorted(by: { $0 > $1 })
        }
    }

}
