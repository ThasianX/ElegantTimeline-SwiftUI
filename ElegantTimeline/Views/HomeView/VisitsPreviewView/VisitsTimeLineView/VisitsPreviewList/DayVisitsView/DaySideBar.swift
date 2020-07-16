// Kevin Li - 1:38 PM - 6/1/20

import SwiftUI

struct DaySideBar: View {

    let date: Date
    var color: Color? = nil

    var body: some View {
        VStack {
            abbreviatedDayOfWeek
            dayOfMonth
        }
        .frame(width: Constants.List.sideBarWidth)
        .padding(.trailing, Constants.List.sideBarPadding)
    }

}

private extension DaySideBar {

    var abbreviatedDayOfWeek: some View {
        Text(date.abbreviatedDayOfWeek.uppercased())
            .font(.system(size: 9, weight: .regular))
            .foregroundColor(color ?? .white)
            .opacity(0.8)
    }

    var dayOfMonth: some View {
        Text(date.dayOfMonth)
            .font(.system(size: 17, weight: .semibold))
            .foregroundColor(color ?? .white)
    }
    
}

struct DaySideBar_Previews: PreviewProvider {

    static var previews: some View {
        DarkThemePreview {
            DaySideBar(date: Date())
        }
    }

}
