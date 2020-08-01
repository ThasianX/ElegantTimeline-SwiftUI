// Kevin Li - 10:15 PM - 7/13/20

import SwiftUI

extension Image {

    static let arrowLeft: Image = {
        let image = UIImage(named: "arrow-left")!
        return Image(uiImage: image)
    }()

    static let chevronUp: Image = {
        let image = UIImage(named: "chevron-up")!
        return Image(uiImage: image)
    }()

}
