// Kevin Li - 1:38 PM - 6/1/20

import Foundation
import UIKit

// TODO: Add app icon later

let screen = UIScreen.main.bounds
let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
let statusBarHeight = window?.windowScene?.statusBarManager?.statusBarFrame.height ?? .zero

let appCalendar = Calendar.current

struct Constants {

    struct Calendar {

        static let cellHeight: CGFloat = 30
        static let cellVerticalPadding: CGFloat = 5

    }

    struct List {

        static let numberOfBlocksOnScreen: Int = 6
        static let blockHeight: CGFloat = {
            let visibleListHeight = screen.height - Self.listTopPadding
            let blockHeight = visibleListHeight / CGFloat(Self.numberOfBlocksOnScreen)
            return blockHeight.floor(nearest: 0.5)
        }()
        static let blockHorizontalPadding: CGFloat = 12

        static let cellSpacing: CGFloat = 6
        static let numberOfCellsInBlock: Int = 3

        static let previewTime: TimeInterval = 4

        static let monthYearWidth: CGFloat = 30

        static let sideBarWidth: CGFloat = 35
        static let sideBarPadding: CGFloat = 4

        // TODO: Need to refine this for different phones
        static let listTopPadding: CGFloat = statusBarHeight - 18 // iphone 11

    }

}

private extension CGFloat {

    func floor(nearest: CGFloat) -> CGFloat {
        let intDiv = CGFloat(Int(self / nearest))
        return intDiv * nearest
    }

}
