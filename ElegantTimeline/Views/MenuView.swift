// Kevin Li - 5:22 PM - 7/2/20

import SwiftUI

fileprivate let menuOptions = ["What's New", "Search", "RSVP", "Smart Alerts", "Siri Shortcuts", "Preferences", "Themes", "User Guides", "Help & Support", "What's New", "About", "My Account"]

struct MenuView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack(spacing: 4) {
                Text("ELEGANT")
                    .font(.system(size: 26, weight: .semibold))
                Text("TIMELINE")
                    .font(.system(size: 26, weight: .light))
            }
            .padding(.bottom, 5)

            ForEach(menuOptions, id: \.self) {
                Text($0)
                    .font(.system(size: 20))
            }
        }
    }
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        DarkThemePreview {
            MenuView()
        }
    }
}
