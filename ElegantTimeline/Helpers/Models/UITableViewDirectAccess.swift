// Kevin Li - 4:24 PM - 7/5/20

import UIKit

protocol UITableViewDirectAccess {

    var tableView: UITableView! { get }

}

extension UITableViewDirectAccess {

    var adjustedVerticalContentInset: CGFloat {
        adjustedTopContentInset - adjustedBottomContentInset
    }

    var adjustedTopContentInset: CGFloat {
        tableView.adjustedContentInset.top
    }

    var adjustedBottomContentInset: CGFloat {
        tableView.adjustedContentInset.bottom
    }

    var listHeight: CGFloat {
        Constants.List.listHeight
    }

    var listCenter: CGFloat {
        listHeight / 2
    }

    var listContentHeight: CGFloat {
        tableView.contentSize.height
    }

}
