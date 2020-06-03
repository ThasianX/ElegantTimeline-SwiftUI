// Kevin Li - 1:39 PM - 6/1/20

import SwiftUI

struct MonthYearSideBar: View {

    @ObservedObject var sideBarTracker: VisitsSideBarTracker

    let color: Color

    var body: some View {
        monthYearText
    }

}

private extension MonthYearSideBar {

    var monthYearText: some View {
        Text(currentFullMonthWithYear.uppercased())
            .tracking(10)
            .foregroundColor(color)
            .font(.caption)
            .fontWeight(.semibold)
            .lineLimit(1)
            .padding(.vertical, 8)
            .transition(.opacity)
            .id("MonthYearSideBar" + currentFullMonthWithYear)
            .rotated(.degrees(-90))
    }

    var currentFullMonthWithYear: String {
        sideBarTracker.currentMonthYearComponent.date.fullMonthWithYear
    }

}
