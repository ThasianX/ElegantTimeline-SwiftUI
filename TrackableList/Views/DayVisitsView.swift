// Kevin Li - 11:23 PM - 6/25/20

import SwiftUI

struct DayVisitsView: View {

    let date: Date
    let visits: [Visit]
    let isFilled: Bool

    private var isDateInToday: Bool {
        Calendar.current.isDateInToday(date)
    }

    var body: some View {
        HStack(spacing: 0) {
            DaySideBar(date: date,
                       color: isDateInToday ? .blackPearl : nil)
                .padding(.trailing, 4)

            if isDateInToday {
                todayIndicator
            }

            DayPreviewBlock(visits: visits,
                            isFilled: isFilled)
        }
        .frame(height: VisitPreviewConstants.blockHeight)
    }

    private var todayIndicator: some View {
        RoundedRectangle(cornerRadius: 8)
            .frame(width: 2, height: nil)
    }

}

struct DayVisitsView_Previews: PreviewProvider {
    static var previews: some View {
        DarkThemePreview {
            DayVisitsView(date: Date(), visits: Visit.mocks(start: Date(), end: .daysFromToday(1)), isFilled: true)
        }
    }
}
