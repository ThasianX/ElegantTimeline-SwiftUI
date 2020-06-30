// Kevin Li - 1:38 PM - 6/1/20

import Foundation
import UIKit

struct VisitPreviewConstants {
    
    static let cellHeight: CGFloat = 30
    static let cellPadding: CGFloat = 9
    static let numberOfCellsInBlock: Int = 3

    static let previewTime: TimeInterval = 5

    static let sideBarWidth: CGFloat = 35
    static let sideBarPadding: CGFloat = 4

    static let blockHeight: CGFloat = (cellHeight + 2*cellPadding) * CGFloat(numberOfCellsInBlock)

    static func height(forBlockCount count: Int) -> CGFloat {
        return blockHeight * CGFloat(count)
    }

    static let blocksInEndShiftRange: CGFloat = 1
    static let endShiftRangeHeight: CGFloat = blockHeight * blocksInEndShiftRange

    static let blocksInStartShiftRange: CGFloat = 2
    static let startShiftRangeHeight: CGFloat = blockHeight * blocksInStartShiftRange

    static let blocksInShiftRange: CGFloat = Self.blocksInStartShiftRange + Self.blocksInEndShiftRange

    static let listTopPadding: CGFloat = statusBarHeight - 10

}
