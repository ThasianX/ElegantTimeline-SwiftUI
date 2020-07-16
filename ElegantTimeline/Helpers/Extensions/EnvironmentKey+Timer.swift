// Kevin Li - 6:09 PM - 6/30/20

import Combine
import SwiftUI

typealias AutoTimer = Publishers.Autoconnect<Timer.TimerPublisher>

struct TimerKey: EnvironmentKey {

    static let defaultValue: AutoTimer = Timer.publish(every: Constants.List.previewTime,
                                                       on: .main,
                                                       in: .common).autoconnect()

}

extension EnvironmentValues {

    var autoTimer: AutoTimer {
        get { self[TimerKey.self] }
        set { self[TimerKey.self] = newValue }
    }

}
