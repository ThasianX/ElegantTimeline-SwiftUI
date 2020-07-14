// Kevin Li - 9:56 PM - 7/13/20

import Foundation

extension Comparable {

    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }

}
