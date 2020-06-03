// Kevin Li - 9:58 PM - 6/1/20

import SwiftUI

class VisitsSideBarTracker: NSObject, ObservableObject {

    @Published var currentMonthYearComponent: DateComponents

    private let descendingDayComponents: [DateComponents]
    private let visitsForDayComponents: [DateComponents: [Visit]]

    init(descendingDayComponents: [DateComponents], visitsForDayComponents: [DateComponents: [Visit]]) {
        currentMonthYearComponent = descendingDayComponents.first!.monthAndYear
        self.descendingDayComponents = descendingDayComponents
        self.visitsForDayComponents = visitsForDayComponents
    }

}

extension VisitsSideBarTracker: UITableViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentIndex = Int(scrollView.contentOffset.y / VisitPreviewConstants.blockHeight) // basically want to floor down to nearest 150
        guard currentIndex >= 0 && currentIndex < descendingDayComponents.count else { return }
        let hovered = descendingDayComponents[currentIndex].monthAndYear
        if currentMonthYearComponent != hovered {
            withAnimation {
                currentMonthYearComponent = hovered
            }
        }
    }

}
