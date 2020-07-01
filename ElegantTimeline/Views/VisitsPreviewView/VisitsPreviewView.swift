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

struct VisitsPreviewView: View {

    @Environment(\.appTheme) private var appTheme: AppTheme

    @State private var selectedDayComponent: DateComponents = DateComponents()

    private let visitsProvider: VisitsProvider
    private let sideBarTracker: VisitsSideBarTracker

    init(visits: [Visit]) {
        visitsProvider = VisitsProvider(visits: visits)
        sideBarTracker = VisitsSideBarTracker(descendingDayComponents: visitsProvider.descendingDayComponents)
    }

    var body: some View {
        ZStack {
            timelineView
                .edgesIgnoringSafeArea(.all)
            fromTodayPopupView
            VStack {
                Spacer()
                scrollToTodayButton
                    .padding()
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

struct VisitsPreviewList_Previews: PreviewProvider {

    static var previews: some View {
        DarkThemePreview {
            VisitsPreviewView(visits: Visit.mocks(start: Date(), end: .daysFromToday(365)))
        }
    }

}
