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
        sideBarTracker = VisitsSideBarTracker(descendingDayComponents: descendingDayComponents,
                                              visitsForDayComponents: visitsForDayComponents)
    }

    var body: some View {
        VStack(spacing: 0) {
            leftAlignedHeader
            timelineView
                .edgesIgnoringSafeArea(.all)
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
        HStack {
            monthYearSideBarView
            visitsPreviewList
        }
    }

    var monthYearSideBarView: MonthYearSideBar {
        MonthYearSideBar(sideBarTracker: sideBarTracker,
                         color: appTheme.primary)
    }

    var visitsPreviewList: some View {
        GeometryReader { geometry in
            List {
                ForEach(self.descendingDayComponents.indices, id: \.self) { i in
                    self.daySideBarWithPreviewBlockView(
                        dayComponent: self.descendingDayComponents[i],
                        isFilled: i%2 == 0)
                }
                .listRowInsets(EdgeInsets())
            }
            .onAppear {
                self.configureListAppearance(withMinY: geometry.frame(in: .global).minY)
            }
            .introspectTableView { tableView in
                tableView.delegate = self.sideBarTracker
            }
        }
    }

    func configureListAppearance(withMinY minY: CGFloat) {
        UITableView.appearance().backgroundColor = .clear
        UITableViewCell.appearance().backgroundColor = .clear
        let footerHeightWhereOnlyLastCellIsVisible = screen.height - minY - VisitPreviewConstants.blockHeight
        UITableView.appearance().tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: screen.width, height: footerHeightWhereOnlyLastCellIsVisible))
        UITableView.appearance().separatorStyle = .none
        UITableView.appearance().allowsSelection = false
        UITableViewCell.appearance().selectionStyle = .none
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
