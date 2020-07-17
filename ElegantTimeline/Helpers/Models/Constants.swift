// Kevin Li - 1:38 PM - 6/1/20

import Foundation
import UIKit

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

        static let listHeight = screen.height

        static let numberOfBlocksOnScreen: Int = {
            hasTopNotch ? 6 : 5
        }()

        static let blockHeight: CGFloat = {
            let visibleListHeight = Self.listHeight - Self.listTopPadding
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

        // 31 is a number I got after some experimentation using various iPhones
        static let listTopPadding: CGFloat = {
            hasTopNotch ? 31 : 0
        }()

    }

}

// Basically, if iPhoneX and above or not. For iPhoneX, the list snaps the nearest cell
// to the iPhone's top notch. Super cool if you ask me
private var hasTopNotch: Bool {
    UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.safeAreaInsets.top ?? 0 > 20
}

private extension CGFloat {

    func floor(nearest: CGFloat) -> CGFloat {
        let intDiv = CGFloat(Int(self / nearest))
        return intDiv * nearest
    }

}
