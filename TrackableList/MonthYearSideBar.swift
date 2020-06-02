// Kevin Li - 1:39 PM - 6/1/20

import SwiftUI

struct MonthYearSideBar: View {

    let date: Date
    let color: Color

    var body: some View {
        monthYearText
    }

}

private extension MonthYearSideBar {

    var monthYearText: some View {
        Text(date.fullMonthWithYear.uppercased())
            .tracking(10)
            .foregroundColor(color)
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.vertical, 8)
            .rotated(.degrees(-90))
    }

}

struct MonthSideBar_Previews: PreviewProvider {

    static var previews: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            MonthYearSideBar(date: Date(), color: .red)
        }
    }

}
