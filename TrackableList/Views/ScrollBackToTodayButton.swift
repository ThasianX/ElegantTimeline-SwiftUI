// Kevin Li - 10:29 PM - 6/25/20

import SwiftUI

protocol ScrollToTodayProvider: ObservableObject {

    func scrollToToday()
    var currentDayComponent: DateComponents { get }

}

struct ScaleButtonStyle: ButtonStyle {

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 1.5 : 1)
    }

}

struct ScrollBackToTodayButton<Provider>: View where Provider: ScrollToTodayProvider {

    @ObservedObject var provider: Provider

    private var isCurrentDayWithinToday: Bool {
        Calendar.current.isDateInToday(provider.currentDayComponent.date)
    }

    var body: some View {
        scrollToTodayButton
            .animation(.spring())
            .scaleEffect(isCurrentDayWithinToday ? 0 : 1)
    }

    private var scrollToTodayButton: some View {
        Button(action: provider.scrollToToday) {
            Image(systemName: "chevron.up.circle.fill")
                .resizable()
                .frame(width: 50, height: 50)
        }
        .foregroundColor(.white)
        .buttonStyle(ScaleButtonStyle())
    }

}
