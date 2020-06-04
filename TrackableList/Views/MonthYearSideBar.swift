// Kevin Li - 1:39 PM - 6/1/20

import SwiftUI

fileprivate let angle: Angle = .degrees(-90)

struct MonthYearSideBar: View {

    @State private var size: CGSize = .zero

    @ObservedObject var sideBarTracker: VisitsSideBarTracker
    let color: Color

    var body: some View {
        monthYearText
            .rotated(angle)
            .captureSize(in: $size)
            .offset(y: offset)
    }

    private var offset: CGFloat {
        let offset = sideBarTracker.offset - (size.height / 2)
        return offset >= 15 ? offset : 15
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
    }

    var currentFullMonthWithYear: String {
        sideBarTracker.currentMonthYearComponent.date.fullMonthWithYear
    }

}
