// Kevin Li - 2:13 PM - 6/26/20

import SwiftUI

struct VisitsTimelineView: View {

    let sideBarTracker: VisitsSideBarTracker
    let visitsProvider: VisitsProvider

    var body: some View {
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

}

private extension VisitsTimelineView {

    var monthYearSideBarView: some View {
        MonthYearSideBar(provider: sideBarTracker)
    }

    var visitsPreviewList: some View {
        List {
            // Has to be in foreach for list row insets to work
            ForEach(visitsProvider.descendingDayComponents.indices, id: \.self) { i in
                self.dayVisitsView(
                    dayComponent: self.visitsProvider.descendingDayComponents[i],
                    isFilled: (i % 2) == 0)
            }
            .listRowInsets(EdgeInsets())
        }
        .introspectTableView(customize: sideBarTracker.attach)
    }

    func dayVisitsView(dayComponent: DateComponents, isFilled: Bool) -> some View {
        DayVisitsView(date: dayComponent.date,
                      visits: visitsProvider.visitsForDayComponents[dayComponent] ?? [],
                      isFilled: isFilled)
    }

    func configureSideBarTracker(withListHeight listHeight: CGFloat) {
        sideBarTracker.listHeight = listHeight
        sideBarTracker.setInitialScrollOffset()
    }

}
