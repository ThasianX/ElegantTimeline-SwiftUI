// Kevin Li - 9:06 AM - 6/1/20

import Introspect
import SwiftUI

let screen = UIScreen.main.bounds

struct VisitsPreviewList: View {

    @Environment(\.appTheme) private var appTheme: AppTheme

    @State private var currentMonthComponent: DateComponents // may have to be inside observableobject as @published
    @State private var selectedDayComponent: DateComponents = DateComponents()

    private let visitsForDayComponents: [DateComponents: [Visit]]
    private let descendingDayComponents: [DateComponents]
    private let indexForDayComponents: [DateComponents: Int]

    private let dateComponentsPredicate: (Visit) -> DateComponents = {
        $0.arrivalDate.dateComponents
    }

    init(visits: [Visit]) {
        visitsForDayComponents = Dictionary(grouping: visits, by: dateComponentsPredicate).visitsSortedAscByArrivalDate
        descendingDayComponents = visitsForDayComponents.descendingKeys
        indexForDayComponents = zip(descendingDayComponents.indices, descendingDayComponents).reduce(into: [DateComponents: Int]()) {
            // dict[dayComponent] = indexOfDayComponent
            $0[$1.1] = $1.0
        }
        _currentMonthComponent = State(initialValue: descendingDayComponents.first!.monthAndYear)
        // OK u know what. basically with the offset, I know exactly what daycomponent is currently being showed.
        // I am able to get the index by -> (int)(offset/30). I can use this index to key the current day component
        // and use that to set the current month component state
    }

    var body: some View {
        VStack(spacing: 0) {
            leftAlignedHeader
            visitsPreviewList
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

    var visitsPreviewList: some View {
        GeometryReader { geometry in
            List {
                ForEach(self.descendingDayComponents.indices) { i in
                    self.daySideBarWithPreviewBlockView(
                        dayComponent: self.descendingDayComponents[i],
                        isFilled: i%2 == 0)
                }
                .listRowInsets(EdgeInsets())
            }
            .onAppear {
                self.configureListAppearance(withMinY: geometry.frame(in: .global).minY)
            }
        }
    }

    func configureListAppearance(withMinY minY: CGFloat) {
        UITableView.appearance().backgroundColor = .clear
        UITableViewCell.appearance().backgroundColor = .clear
        let footerHeightWhereOnlyLastCellIsVisible = screen.height - minY - VisitPreviewConstants.blockHeight
        UITableView.appearance().tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: screen.width, height: footerHeightWhereOnlyLastCellIsVisible))
        UITableView.appearance().separatorStyle = .none
    }

    func daySideBarWithPreviewBlockView(dayComponent: DateComponents, isFilled: Bool) -> some View {
        HStack(spacing: 4) {
            DaySideBar(date: dayComponent.date)
            DayPreviewBlock(visits: visitsForDayComponents[dayComponent]!,
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

struct VisitsPreviewList_Previews: PreviewProvider {

    static var previews: some View {
        VisitsPreviewList(visits: Visit.mocks)
            .colorScheme(.dark)
            .background(Color.black.edgesIgnoringSafeArea(.all))
    }

}
