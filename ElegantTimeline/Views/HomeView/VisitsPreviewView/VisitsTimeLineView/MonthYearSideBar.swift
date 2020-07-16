// Kevin Li - 1:39 PM - 6/1/20

import SwiftUI

fileprivate let angle: Angle = .degrees(-90)
fileprivate let offsetLowerBound: CGFloat = Constants.List.listTopPadding

struct MonthYearSideBar: View {

    @Environment(\.appTheme) private var appTheme: AppTheme

    @State private var size1: CGSize = .zero
    @State private var size2: CGSize = .zero

    @ObservedObject var state: MonthYearSideBarState

    private var offset1: CGFloat {
        state.monthYear1Offset - (size1.height / 2) + Constants.List.listTopPadding
    }

    private var offset2: CGFloat {
        state.monthYear2Offset - (size2.height / 2) + Constants.List.listTopPadding
    }

    var body: some View {
        ZStack(alignment: .top) {
            monthYear1Text
                .rotated(angle)
                .captureSize(in: $size1)
                .offset(y: offset1)

            monthYear2Text
                .rotated(angle)
                .captureSize(in: $size2)
                .offset(y: offset2)
        }
        .frame(width: Constants.List.monthYearWidth)
    }

}

private extension MonthYearSideBar {

    var monthYear1Text: some View {
        Text(monthYear1FullMonthWithYear.uppercased())
            .tracking(10)
            .foregroundColor(isMonthYear1SameMonthAndYearAsToday ? appTheme.primary : nil)
            .font(.caption)
            .fontWeight(.semibold)
            .lineLimit(1)
            .padding(.vertical, 8)
            .transition(.opacity)
    }

    var isMonthYear1SameMonthAndYearAsToday: Bool {
        appCalendar.isDate(state.monthYear1Component.date, equalTo: Date(), toGranularity: .month) &&
            appCalendar.isDate(state.monthYear1Component.date, equalTo: Date(), toGranularity: .year)
    }

    var monthYear1FullMonthWithYear: String {
        state.monthYear1Component.date.fullMonthWithYear
    }

}

private extension MonthYearSideBar {

    var monthYear2Text: some View {
        Text(monthYear2FullMonthWithYear.uppercased())
            .tracking(10)
            .foregroundColor(isMonthYear2SameMonthAndYearAsToday ? appTheme.primary : nil)
            .font(.caption)
            .fontWeight(.semibold)
            .lineLimit(1)
            .padding(.vertical, 8)
            .transition(.opacity)
    }

    var isMonthYear2SameMonthAndYearAsToday: Bool {
        appCalendar.isDate(state.monthYear2Component.date, equalTo: Date(), toGranularity: .month) &&
            appCalendar.isDate(state.monthYear2Component.date, equalTo: Date(), toGranularity: .year)
    }

    var monthYear2FullMonthWithYear: String {
        state.monthYear2Component.date.fullMonthWithYear
    }

}
