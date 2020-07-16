// Kevin Li - 6:18 PM - 6/25/20

import SwiftUI

class FromTodayPopupState: ObservableObject {

    @Published var showFromTodayPopup: Bool = false
    @Published var weeksFromCurrentMonthToToday: Int = 0

    func dayChanged(_ dayComponent: DateComponents) {
        let startOfToday = appCalendar.startOfDay(for: Date())
        let startOfSelectedDate = appCalendar.startOfDay(for: dayComponent.date)
        let weeks = appCalendar.dateComponents([.weekOfYear], from: startOfToday, to: startOfSelectedDate).weekOfYear!
        weeksFromCurrentMonthToToday = weeks > 0 ? 0 : abs(weeks)
    }

    func didBeginDragging() {
        if weeksFromCurrentMonthToToday > 3 {
            DispatchQueue.main.async {
                withAnimation(.easeInOut) {
                    self.showFromTodayPopup = true
                }
            }
        }
    }

    func didEndDragging() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            withAnimation(.easeInOut) {
                self.showFromTodayPopup = false
            }
        }
    }

}

struct FromTodayPopupView: View {

    @ObservedObject var state: FromTodayPopupState

    var body: some View {
        fromTodayPopupView
            .scaleEffect(state.showFromTodayPopup ? 1 : 0)
            .opacity(state.showFromTodayPopup ? 1 : 0)
    }

    private var fromTodayPopupView: some View {
        let weeksToToday = state.weeksFromCurrentMonthToToday

        let unitsFromToday: String
        if weeksToToday < 8 {
            unitsFromToday = "\(weeksToToday) \(weeksToToday != 1 ? "WEEKS" : "WEEK")"
        } else {
            unitsFromToday = "\(weeksToToday/4) MONTHS"
        }

        return VStack {
            unitsFromTodayText(unitsFromToday)
            unitsDescriptionText
        }
        .transition(.identity)
        .id("FromTodayPopup\(weeksToToday)")
    }

    private func unitsFromTodayText(_ text: String) -> some View {
        Text(text)
            .font(.headline)
            .fontWeight(.semibold)
            .tracking(2.5)
    }

    private var unitsDescriptionText: some View {
        Text("AGO")
            .font(.system(size: 10))
    }

}
