// Kevin Li - 12:54 PM - 7/11/20

import SwiftUI

struct ResizingOverlayView: View, PageScrollStateDirectAccess {

    @EnvironmentObject var scrollState: PageScrollState

    private var strokeWidth: CGFloat {
        40 - (40 * ((centerPageHeight - centerMinHeight) / centerCutoffHeight))
    }

    var body: some View {
        VStack(spacing: 0) {
            // Used to capture top areas that the black stroke border can't reach
            Color.black
                .edgesIgnoringSafeArea(.top)

            // This is used to round the corners of the list content as the menu appears.
            // The magic number belows were obtained after testing on various sized phones
            // and determining the best overall trim that fits all of them
            ZStack {
                RoundedRectangle(cornerRadius: centerCornerRadius, style: .continuous)
                    .trim(from: -0.9, to: 0.2)
                    .stroke(Color.black, lineWidth: strokeWidth)
                    .frame(width: pageWidth + strokeWidth, height: centerPageHeight + 60)

                RoundedRectangle(cornerRadius: centerCornerRadius, style: .continuous)
                    .trim(from: 0.44, to: 0.7)
                    .stroke(Color.black, lineWidth: strokeWidth)
                    .frame(width: pageWidth + strokeWidth, height: centerPageHeight + 60)
            }

            // Used to capture bottom areas that the black stroke border can't reach
            Color.black
                .edgesIgnoringSafeArea(.bottom)
        }
    }

}

fileprivate let centerMaxHeight = screen.height
fileprivate let centerCutoffHeight: CGFloat = 160
fileprivate let centerMinHeight: CGFloat = centerMaxHeight - centerCutoffHeight

private extension ResizingOverlayView {

    var centerPageHeight: CGFloat {
        // Center page's height should only be modified for the center and last page
        guard !activePage.isCalendar else { return centerMaxHeight }
        guard activePage != .themePicker else { return centerMinHeight }

        if isSwipingLeft {
            // If we're at the last page and we're swiping left into the empty
            // space to the right, we don't want the center page's height to change.
            guard activePage == .list else { return centerMinHeight }
            // Now we know we're on the center page and we're swiping towards the last page,
            // we don't want to cut off too much of the height
            guard abs(delta) <= deltaCutoff else { return centerMinHeight }

            // negation for clearer syntax
            let heightToBeCutoff = -delta * (centerCutoffHeight / deltaCutoff)
            return centerMaxHeight - heightToBeCutoff
        } else if isSwipingRight {
            // If we're swiping from the center page towards the first page, we don't
            // want any height changes to the center page
            guard activePage == .menu else { return centerMaxHeight }
            // Once the center page's height gets restored to its initial height, we don't
            // want to keep adding to its height and make it greater than the screen's height
            guard delta <= deltaCutoff else { return centerMaxHeight }

            let heightToBeAdded = delta * (centerCutoffHeight / deltaCutoff)
            return centerMinHeight + heightToBeAdded
        } else {
            // When the user isn't dragging anything, we want the center page to be fullscreen
            // when its active but at its min height when the last page is active
            return activePage == .list ? centerMaxHeight : centerMinHeight
        }
    }

}

fileprivate let centerMinRadius: CGFloat = 0
fileprivate let centerCutoffRadius: CGFloat = 50
fileprivate let centerMaxRadius: CGFloat = centerMinRadius + centerCutoffRadius

private extension ResizingOverlayView {

    var centerCornerRadius: CGFloat {
        // Corner radius should only start being modified for the center and last page
        guard !activePage.isCalendar else { return centerMinRadius }
        guard activePage != .themePicker else { return centerMaxRadius }

        if isSwipingLeft {
            // If we're at the last page and we're swiping left into the empty
            // space to the right, we don't want the center page's radius to change.
            guard activePage == .list else { return centerMaxRadius }
            // Now we know we're on the center page and we're swiping towards the last page,
            // we don't want to add too much to the center radius
            guard abs(delta) <= deltaCutoff else { return centerMaxRadius }

            // negation for clearer syntax
            let radiusToBeAdded = -delta * (centerCutoffRadius / deltaCutoff)
            return centerMinRadius + radiusToBeAdded
        } else if isSwipingRight {
            // If we're swiping from the center page towards the first page, we don't
            // want any radius changes to the center page
            guard activePage == .menu else { return centerMinRadius }
            // Once the center page's radius gets restored to its initial radius, we don't
            // want to keep subtracting from its radius
            guard delta <= deltaCutoff else { return centerMinRadius }

            let radiusToBeSubtracted = delta * (centerCutoffRadius / deltaCutoff)
            return centerMaxRadius - radiusToBeSubtracted
        } else {
            // When the user isn't dragging anything and the center page is active,
            // we don't want there to be any radius. But when the last page is active,
            // and there is no drag translation, we want the center page's radius to be at its max
            return activePage == .list ? centerMinRadius : centerMaxRadius
        }
    }

}
