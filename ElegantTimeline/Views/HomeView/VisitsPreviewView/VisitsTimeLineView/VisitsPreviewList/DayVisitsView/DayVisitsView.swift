// Kevin Li - 11:23 PM - 6/25/20

import SwiftUI

struct DayVisitsView: View {

    @Environment(\.appTheme) private var appTheme: AppTheme
    @Environment(\.autoTimer) private var autoTimer: AutoTimer

    let date: Date
    let visits: [Visit]
    let isFilled: Bool

    private var isDateInToday: Bool {
        appCalendar.isDateInToday(date)
    }

    var body: some View {
        HStack(spacing: 0) {
            DaySideBar(date: date,
                       color: isDateInToday ? appTheme.primary : nil)

            ZStack(alignment: .leading) {
                DayPreviewBlock(visits: visits,
                                isFilled: isFilled)
                if isDateInToday {
                    todayIndicator
                }
            }
        }
        .frame(height: Constants.List.blockHeight)
    }

    private var todayIndicator: some View {
        RoundedRectangle(cornerRadius: 8)
            .frame(width: 2, height: nil)
    }

}

struct DayVisitsView_Previews: PreviewProvider {
    static var previews: some View {
        DarkThemePreview {
            DayVisitsView(date: Date(), visits: Visit.mocks(start: .daysFromToday(-1)), isFilled: true)
        }
    }
}
