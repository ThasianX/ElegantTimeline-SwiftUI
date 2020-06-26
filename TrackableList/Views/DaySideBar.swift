// Kevin Li - 1:38 PM - 6/1/20

import SwiftUI

struct DaySideBar: View {

    let date: Date

    var body: some View {
        // TODO: Add extra white indicator on the side if is today
        VStack {
            abbreviatedDayOfWeek
            dayOfMonth
        }
        .frame(width: VisitPreviewConstants.sideBarWidth)
    }

}

private extension DaySideBar {

    var abbreviatedDayOfWeek: some View {
        Text(date.abbreviatedDayOfWeek.uppercased())
            .font(.caption)
            .foregroundColor(.gray)
    }

    var dayOfMonth: some View {
        Text(date.dayOfMonth)
            .fontWeight(.bold)
            .foregroundColor(.white)
    }
}

struct DaySideBar_Previews: PreviewProvider {

    static var previews: some View {
        DarkThemePreview {
            DaySideBar(date: Date())
        }
    }

}
