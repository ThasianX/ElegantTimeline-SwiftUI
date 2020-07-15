// Kevin Li - 5:22 PM - 7/2/20

import SwiftUI

struct MenuView: View, PageScrollStateDirectAccess {

    @EnvironmentObject var scrollState: PageScrollState
    let changeTheme: (AppTheme) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            header
            themePickerList
        }
        .padding(.leading, 24)
        .rotation3DEffect(menuRotationAngle,
                          axis: (x: 0, y: 10.0, z: 0),
                          anchor: .leading)
        .opacity(menuOpacity)
        .frame(width: pageWidth * deltaCutoff)
    }

}

private extension MenuView {

    var header: some View {
        HStack(spacing: 4) {
            Text("ELEGANT")
                .font(.system(size: 30, weight: .semibold))
            Text("TIMELINE")
                .font(.system(size: 30, weight: .light))
        }
        .padding(.bottom, 5)
    }

    var themePickerList: some View {
        VStack(alignment: .leading, spacing: 25) {
            ForEach(AppTheme.allThemes, id: \.self) {
                AppThemePickerCell(theme: $0, onTap: self.changeTheme)
            }
        }
    }

}

struct AppThemePickerCell: View {

    let theme: AppTheme
    let onTap: (AppTheme) -> Void

    var body: some View {
        HStack {
            pickerContent
            Spacer()
        }
    }

    private var pickerContent: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(theme.primary)
                .frame(width: 25, height: 25)

            Text(theme.name)
                .font(.system(size: 18))
        }
        .padding(12)
        .contentShape(Rectangle())
        .background(roundedComplementaryBackground)
        .onTapGesture(perform: setTheme)
    }

    private var roundedComplementaryBackground: some View {
        RoundedRectangle(cornerRadius: 16, style: .circular)
            .fill(theme.complementary)
            .opacity(0.7)
    }

    private func setTheme() {
        withAnimation(.easeInOut) {
            onTap(theme)
        }
    }

}

fileprivate let menuClosedDegrees: Double = 90
fileprivate let menuOpenDegrees: Double = 0

private extension MenuView {

    var menuRotationAngle: Angle {
        // Center page's height should only be modified for the center and last page
        guard !activePage.isCalendar else { return .init(degrees: menuClosedDegrees) }

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
            MenuView(changeTheme: { _ in })
        }
    }
}
