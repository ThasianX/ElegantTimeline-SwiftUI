// Kevin Li - 12:56 AM - 7/16/20

import SwiftUI

fileprivate let minDragDistanceToShowHeaderOrFooter: CGFloat = 80

class QuoteState: ObservableObject, UITableViewDirectAccess {

    @Published var shouldShowHeader: Bool = false
    @Published var shouldShowFooter: Bool = false
    @Published var headerFooterOffset: CGFloat = .zero

    var tableView: UITableView!

    func determineHeaderAndFooterVisibilityAndOffset(scrollOffset: CGFloat) {
        determineHeaderVisibilityAndOffset(for: scrollOffset)
        determineFooterVisibilityAndOffset(for: scrollOffset)
    }

    private func determineHeaderVisibilityAndOffset(for offset: CGFloat) {
        withAnimation(.easeInOut(duration: 0.05)) {
            shouldShowHeader = offset < -minDragDistanceToShowHeaderOrFooter
            if shouldShowHeader {
                headerFooterOffset = -offset / 1.3
            } else {
                if !shouldShowFooter {
                    headerFooterOffset = 0
                }
            }
        }
    }

    private func determineFooterVisibilityAndOffset(for offset: CGFloat) {
        let maxVisibleHeight = (listContentHeight < listHeight) ? listContentHeight : listHeight
        let gapBetweenOffsetAndListEnd = listContentHeight - offset
        let differenceBetweenVisibleHeightAndGapToEnd = maxVisibleHeight - gapBetweenOffsetAndListEnd

        withAnimation(.easeInOut(duration: 0.05)) {
            shouldShowFooter = differenceBetweenVisibleHeightAndGapToEnd > minDragDistanceToShowHeaderOrFooter
            if shouldShowFooter {
                headerFooterOffset = -(differenceBetweenVisibleHeightAndGapToEnd - minDragDistanceToShowHeaderOrFooter) / 1.3
            } else {
                if !shouldShowHeader {
                    headerFooterOffset = 0
                }
            }
        }
    }

}
