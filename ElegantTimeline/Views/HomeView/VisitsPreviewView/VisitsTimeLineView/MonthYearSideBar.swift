// Kevin Li - 1:39 PM - 6/1/20

import SwiftUI

protocol MonthYearSideBarProvider: ObservableObject {

    var monthYear1Component: DateComponents { get }
    var monthYear1Offset: CGFloat { get }
    var monthYear2Component: DateComponents { get }
    var monthYear2Offset: CGFloat { get }

}

fileprivate let angle: Angle = .degrees(-90)
fileprivate let offsetLowerBound: CGFloat = VisitPreviewConstants.listTopPadding

struct MonthYearSideBar<Provider>: View where Provider: MonthYearSideBarProvider {

    @Environment(\.appTheme) private var appTheme: AppTheme

    @State private var size1: CGSize = .zero
    @State private var size2: CGSize = .zero

    @ObservedObject var provider: Provider

    private var offset1: CGFloat {
        provider.monthYear1Offset - (size1.height / 2) + VisitPreviewConstants.listTopPadding
    }

    private var offset2: CGFloat {
        provider.monthYear2Offset - (size2.height / 2) + VisitPreviewConstants.listTopPadding
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
        Calendar.current.isDate(provider.monthYear1Component.date, equalTo: Date(), toGranularity: .month) &&
            Calendar.current.isDate(provider.monthYear1Component.date, equalTo: Date(), toGranularity: .year)
    }

    var monthYear1FullMonthWithYear: String {
        provider.monthYear1Component.date.fullMonthWithYear
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
        Calendar.current.isDate(provider.monthYear2Component.date, equalTo: Date(), toGranularity: .month) &&
            Calendar.current.isDate(provider.monthYear2Component.date, equalTo: Date(), toGranularity: .year)
    }

    var monthYear2FullMonthWithYear: String {
        provider.monthYear2Component.date.fullMonthWithYear
    }

}
