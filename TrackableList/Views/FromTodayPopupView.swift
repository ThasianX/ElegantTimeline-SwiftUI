// Kevin Li - 6:18 PM - 6/25/20

import SwiftUI

protocol FromTodayPopupProvider: ObservableObject {

    var isDragging: Bool { get }
    var weeksFromCurrentMonthToToday: Int { get }

}

struct FromTodayPopupView<Provider>: View where Provider: FromTodayPopupProvider {

    @ObservedObject var provider: Provider

    var body: some View {
        fromTodayPopupView
            .scaleEffect(provider.isDragging ? 1 : 0)
            .opacity(provider.isDragging ? 1 : 0)
    }

    private var fromTodayPopupView: some View {
        let weeksToToday = provider.weeksFromCurrentMonthToToday

        let unitsFromToday: String
        if abs(weeksToToday) < 8 {
            unitsFromToday = "\(abs(weeksToToday)) \(weeksToToday != 1 ? "WEEKS" : "WEEK")"
        } else {
            unitsFromToday = "\(abs(weeksToToday)/4) MONTHS"
        }

        let unitsDescription: String
        if weeksToToday > 0 {
            unitsDescription = "FROM TODAY"
        } else {
            unitsDescription = "AGO"
        }

        return VStack {
            unitsFromTodayText(unitsFromToday)
            unitsDescriptionText(unitsDescription)
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

    private func unitsDescriptionText(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 10))
    }

}
