// Kevin Li - 6:39 PM - 8/4/20

import SwiftUI

struct IsSetupKey: EnvironmentKey {

    static var defaultValue: Bool = true
    
}

extension EnvironmentValues {

    var isSetup: Bool {
        get { self[IsSetupKey.self] }
        set { self[IsSetupKey.self] = newValue }
    }

}
