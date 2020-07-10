// Kevin Li - 9:06 AM - 6/1/20

import Introspect
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

// TODO: Add fade animation
struct VisitsPreviewView: View {

    @Environment(\.appTheme) private var appTheme: AppTheme

    let visitsProvider: VisitsProvider
    let sideBarTracker: VisitsSideBarTracker

    var body: some View {
        ZStack {
            timelineView
                .edgesIgnoringSafeArea(.all)

            fromTodayPopupView

            VStack {
                Spacer()
                scrollToTodayButton
                    .padding(.bottom, 75)
            }
        }
    }
    
}

private extension VisitsPreviewView {

    var timelineView: some View {
        VisitsTimelineView(sideBarTracker: sideBarTracker,
                           visitsProvider: visitsProvider)
    }

    var fromTodayPopupView: some View {
        FromTodayPopupView(provider: sideBarTracker)
    }

    var scrollToTodayButton: some View {
        ScrollBackToTodayButton(provider: sideBarTracker)
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
