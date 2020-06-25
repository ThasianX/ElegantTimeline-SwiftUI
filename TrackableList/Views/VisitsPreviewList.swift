// Kevin Li - 9:06 AM - 6/1/20

import Introspect
import SwiftUI

let screen = UIScreen.main.bounds

struct VisitsPreviewList: View {

    @Environment(\.appTheme) private var appTheme: AppTheme

    @State private var selectedDayComponent: DateComponents = DateComponents()
    @ObservedObject private var sideBarTracker: VisitsSideBarTracker

    private let visitsForDayComponents: [DateComponents: [Visit]]
    private let descendingDayComponents: [DateComponents]
    private let indexForDayComponents: [DateComponents: Int]

    init(visits: [Visit]) {
        visitsForDayComponents = Dictionary(grouping: visits,
                                            by: { $0.arrivalDate.dateComponents }).visitsSortedAscByArrivalDate
        descendingDayComponents = visitsForDayComponents.descendingDatesWithGapsFilledIn
        indexForDayComponents = descendingDayComponents.pairKeysWithIndex
        sideBarTracker = VisitsSideBarTracker(descendingDayComponents: descendingDayComponents)
    }

    var body: some View {
        VStack(spacing: 0) {
            leftAlignedHeader
            timelineView
        }
    }
    
}

private extension VisitsPreviewList {

    var leftAlignedHeader: some View {
        HStack {
            headerText
                .padding(.leading)
            Spacer()
        }
        .padding()
    }

    var headerText: some View {
        Text("Visits")
            .font(.largeTitle)
            .foregroundColor(appTheme.primary)
    }

}

private extension VisitsPreviewList {

    var timelineView: some View {
        GeometryReader { geometry in
            HStack(alignment: .top) {
                self.monthYearSideBarView
                self.visitsPreviewList
            }
            .onAppear {
                self.configureSideBarTracker(withListHeight: geometry.size.height)
            }
        }
    }

    func configureSideBarTracker(withListHeight listHeight: CGFloat) {
        sideBarTracker.listHeight = listHeight
        sideBarTracker.setInitialScrollOffset()
    }

    var monthYearSideBarView: MonthYearSideBar {
        MonthYearSideBar(sideBarTracker: sideBarTracker,
                         color: appTheme.primary)
    }

    var visitsPreviewList: some View {
        List {
            // Has to be in foreach for list row insets to work
            ForEach(descendingDayComponents.indices, id: \.self) { i in
                self.daySideBarWithPreviewBlockView(
                    dayComponent: self.descendingDayComponents[i],
                    isFilled: (i % 2) == 0)
            }
            .listRowInsets(EdgeInsets())
        }
        .introspectTableView(customize: sideBarTracker.attach)
    }

    func daySideBarWithPreviewBlockView(dayComponent: DateComponents, isFilled: Bool) -> some View {
        HStack(spacing: 4) {
            DaySideBar(date: dayComponent.date)
            DayPreviewBlock(visits: visitsForDayComponents[dayComponent] ?? [],
                            isFilled: isFilled)
        }
        .frame(height: VisitPreviewConstants.blockHeight)
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
                     through: keys.min()!, by: -1)) // most recent to oldest
    }

}

private extension Array where Element == DateComponents {

    var pairKeysWithIndex: [Element: Int] {
        zip(indices, self).reduce(into: [DateComponents: Int]()) {
            // dict[dayComponent] = indexOfDayComponent
            $0[$1.1] = $1.0
        }
    }

}

struct VisitsPreviewList_Previews: PreviewProvider {

    static var previews: some View {
        VisitsPreviewList(visits: Visit.mocks)
            .colorScheme(.dark)
            .background(Color.black.edgesIgnoringSafeArea(.all))
    }

}
