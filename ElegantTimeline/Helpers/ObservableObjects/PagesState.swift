// Kevin Li - 8:23 PM - 7/9/20

import SwiftUI

class PagesState: ObservableObject {

    @Published var activePage: Int
    @Published var translation: CGFloat = .zero

    let pageCount: Int
    let pageWidth: CGFloat = screen.width
    let deltaCutoff: CGFloat

    var wasPreviousPageYearView: Bool = false

    init(startingPage: Int, pageCount: Int, deltaCutoff: CGFloat) {
        activePage = startingPage
        self.pageCount = pageCount
        self.deltaCutoff = deltaCutoff
    }

}

protocol PagesStateDirectAccess {

    var pagesState: PagesState { get }

}

extension PagesStateDirectAccess {

    var activePage: Int {
        pagesState.activePage
    }

    var translation: CGFloat {
        pagesState.translation
    }

    var pageCount: Int {
        pagesState.pageCount
    }

    var pageWidth: CGFloat {
        pagesState.pageWidth
    }

    var deltaCutoff: CGFloat {
        pagesState.deltaCutoff
    }

    var wasPreviousPageYearView: Bool {
        pagesState.wasPreviousPageYearView
    }

    var delta: CGFloat {
        translation / screen.width
    }

    var isSwipingLeft: Bool {
        translation < 0
    }

    var isSwipingRight: Bool {
        translation > 0
    }

}
