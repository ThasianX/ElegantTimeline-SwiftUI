// Kevin Li - 10:29 PM - 6/25/20

import SwiftUI

protocol ScrollToTodayProvider: ObservableObject {

    func scrollToToday()
    var currentDayComponent: DateComponents { get }

}

struct ScaleButtonStyle: ButtonStyle {

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 1.25 : 1)
            .animation(.easeInOut)
    }

}

struct ScrollBackToTodayButton<Provider>: View where Provider: ScrollToTodayProvider {

    @Environment(\.appTheme) private var appTheme: AppTheme
    @ObservedObject var provider: Provider

    private var isCurrentDayWithinToday: Bool {
        appCalendar.isDateInToday(provider.currentDayComponent.date)
    }

    var body: some View {
        scrollToTodayButton
            .scaleEffect(isCurrentDayWithinToday ? 0 : 1)
            .opacity(isCurrentDayWithinToday ? 0 : 1)
    }

    private var scrollToTodayButton: some View {
        Button(action: provider.scrollToToday) {
            scrollImage
        }
        .buttonStyle(ScaleButtonStyle())
    }

    private var scrollImage: some View {
        ZStack {
            Image(systemName: "circle.fill")
                .resizable()
                .frame(width: 55, height: 55)
                .foregroundColor(.white)
            Image.chevronUp
                .resizable()
                .frame(width: 50, height: 50)
                .foregroundColor(appTheme.primary)
        }
    }

}
