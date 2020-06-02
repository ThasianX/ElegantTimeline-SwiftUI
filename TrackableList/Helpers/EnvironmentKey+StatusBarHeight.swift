// Kevin Li - 9:05 PM - 6/1/20

import SwiftUI

struct StatusBarHeightEnvironmentKey: EnvironmentKey {

    public static let defaultValue: CGFloat = .zero

}

extension EnvironmentValues {

    public var statusBarHeight: CGFloat {
        get { self[StatusBarHeightEnvironmentKey.self] }
        set { self[StatusBarHeightEnvironmentKey.self] = newValue }
    }
    
}
