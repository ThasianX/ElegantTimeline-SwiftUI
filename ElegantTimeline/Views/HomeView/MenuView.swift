// Kevin Li - 5:22 PM - 7/2/20

import SwiftUI

fileprivate let menuOptions = ["What's New", "Search", "RSVP", "Smart Alerts", "Siri Shortcuts", "Preferences", "Themes", "User Guides", "Help & Support", "About", "My Account"]

struct MenuView: View, PageScrollStateDirectAccess {

    @EnvironmentObject var scrollState: PageScrollState

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            header
            menuOptionsStack
        }
        .padding(.leading, 30)
        .rotation3DEffect(menuRotationAngle,
                          axis: (x: 0, y: 10.0, z: 0),
                          anchor: .leading)
        .opacity(menuOpacity)
        .frame(width: pageWidth * deltaCutoff, alignment: .leading)
    }

}

private extension MenuView {

    var header: some View {
        HStack(spacing: 4) {
            Text("ELEGANT")
                .font(.system(size: 28, weight: .semibold))
            Text("TIMELINE")
                .font(.system(size: 28, weight: .light))
        }
    }

    var menuOptionsStack: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(menuOptions, id: \.self) { option in
                self.makeText(for: option)
            }
        }
    }

    private func makeText(for option: String) -> some View {
        Text(option)
            .font(.system(size: 18, weight: .light))
            .onTapGesture {
                self.menuOptionTapped(option)
            }
    }

    private func menuOptionTapped(_ option: String) {
        if option == "Themes" {
            self.scrollState.scroll(to: .themePicker)
        }
    }

}

fileprivate let menuClosedDegrees: Double = 90
fileprivate let menuOpenDegrees: Double = 0

private extension MenuView {

    var menuRotationAngle: Angle {
        // Menu's rotation angle should only be modified for the list and menu page
        guard !activePage.isCalendar else { return .init(degrees: menuClosedDegrees) }
        guard activePage != .themePicker else { return .init(degrees: menuOpenDegrees) }

        if isSwipingLeft {
            // If we're at the last page and we're swiping left into the empty
            // space to the right, we don't want the menu's rotation angle to change
            guard activePage == .list else { return .init(degrees: menuOpenDegrees) }
            // Now we know we're on the center page and we're swiping towards the last page,
            // we don't want to over rotate the menu page
            guard abs(delta) <= deltaCutoff else { return .init(degrees: menuOpenDegrees) }

            // negation for clearer syntax
            let degreesToBeSubtracted = Double(-delta) * (menuClosedDegrees / Double(deltaCutoff))
            return .init(degrees: menuClosedDegrees - degreesToBeSubtracted)
        } else if isSwipingRight {
            // If we're swiping from the center page towards the first page, we don't
            // want any rotation changes to the menu page
            guard activePage == .menu else { return .init(degrees: menuClosedDegrees) }
            // Once the menu page is folded again, we don't want to keep folding even more
            guard delta <= deltaCutoff else { return .init(degrees: menuClosedDegrees) }

            let degreesToBeAdded = Double(delta) * (menuClosedDegrees / Double(deltaCutoff))
            return .init(degrees: menuOpenDegrees + degreesToBeAdded)
        } else {
            // When the user isn't dragging anything and the center page is active, we want
            // the menu page to be closed. But when the menu page is active and there is no
            // drag, we want it to be open
            return activePage == .list ? .init(degrees: menuClosedDegrees) : .init(degrees: menuOpenDegrees)
        }
    }

}

fileprivate let menuClosedOpacity: Double = 0
fileprivate let menuOpenOpacity: Double = 1

private extension MenuView {

    var menuOpacity: Double {
        // Menu page's opacity should only be modified when either the center or menu is active
        guard !activePage.isCalendar else { return menuClosedOpacity }
        guard activePage != .themePicker else { return menuOpenOpacity }

        if isSwipingLeft {
            // If we're at the last page and we're swiping left into the empty
            // space to the right, the menu opacity should remain as it is open
            guard activePage == .list else { return menuOpenOpacity }
            // Now we know we're on the center page and we're swiping towards the last page,
            // we don't want to add too much to the menu's opacity
            guard abs(delta) <= deltaCutoff else { return menuOpenOpacity }

            // negation for clearer syntax
            let opacityToBeAdded = Double(-delta) * (menuOpenOpacity / Double(deltaCutoff))
            return menuClosedOpacity + opacityToBeAdded
        } else if isSwipingRight {
            // If we're swiping from the center page towards the first page, we don't
            // want any opaicty changes to the menu page
            guard activePage == .menu else { return menuClosedOpacity }
            // Once the menu page is faded entirely, we don't want to keep fading
            guard delta <= deltaCutoff else { return menuClosedOpacity }

            let opacityToBeRemoved = Double(delta) * (menuOpenOpacity / Double(deltaCutoff))
            return menuOpenOpacity - opacityToBeRemoved
        } else {
            // When the user isn't dragging anything and the center page is active, we want
            // the menu page to be fully faded. But when the menu page is active and there is no
            // drag, we want it to be fully visible
            return activePage == .list ? menuClosedOpacity : menuOpenOpacity
        }
    }

}


struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        DarkThemePreview {
            MenuView()
                .environmentObject(PageScrollState())
        }
    }
}
