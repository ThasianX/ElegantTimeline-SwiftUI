// Kevin Li - 1:39 PM - 6/1/20

import SwiftUI

protocol MonthYearSideBarProvider: ObservableObject {

    var offset: CGFloat { get }
    var currentMonthYearComponent: DateComponents { get }

}

fileprivate let angle: Angle = .degrees(-90)

struct MonthYearSideBar<Provider>: View where Provider: MonthYearSideBarProvider {

    @Environment(\.appTheme) private var appTheme: AppTheme

    @State private var size: CGSize = .zero

    @ObservedObject var provider: Provider

    var body: some View {
        monthYearText
            .rotated(angle)
            .captureSize(in: $size)
            .offset(y: offset)
    }

    private var offset: CGFloat {
        let offset = provider.offset - (size.height / 2)
        return offset >= 15 ? offset : 15
    }

}

private extension MonthYearSideBar {

    var monthYearText: some View {
        Text(currentFullMonthWithYear.uppercased())
            .tracking(10)
            .foregroundColor(isSameMonthAndYearAsToday ? appTheme.primary : nil)
            .font(.caption)
            .fontWeight(.semibold)
            .lineLimit(1)
            .padding(.vertical, 8)
            .transition(.opacity)
            .id("MonthYearSideBar" + currentFullMonthWithYear)
    }

    var isSameMonthAndYearAsToday: Bool {
        Calendar.current.isDate(provider.currentMonthYearComponent.date, equalTo: Date(), toGranularity: .month) &&
            Calendar.current.isDate(provider.currentMonthYearComponent.date, equalTo: Date(), toGranularity: .year)
    }

    var currentFullMonthWithYear: String {
        provider.currentMonthYearComponent.date.fullMonthWithYear
    }

}
