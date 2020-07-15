// Kevin Li - 7:16 PM - 7/2/20

import SwiftUI

extension Color {

    static let brilliantViolet = Color("brilliantViolet")
    static let brilliantVioletComplement = Color("brilliantVioletComplement")

    static let kiwiGreen = Color("kiwiGreen")
    static let kiwiGreenComplement = Color("kiwiGreenComplement")

    static let mauvePurple = Color("mauvePurple")
    static let mauvePurpleComplement = Color("mauvePurpleComplement")

    static let royalBlue = Color("royalBlue")
    static let royalBlueComplement = Color("royalBlueComplement")

    static let craftBrown = Color("craftBrown")
    static let craftBrownComplement = Color("craftBrownComplement")

    static let fluorescentPink = Color("fluorescentPink")
    static let fluorescentPinkComplement = Color("fluorescentPinkComplement")

    static let orangeYellow = Color("orangeYellow")
    static let orangeYellowComplement = Color("orangeYellowComplement")

    static let red = Color("red")
    static let redComplement = Color("redComplement")

    static let systemBackground = Color(UIColor.systemBackground)

    static let turquoise = Color(red: 24, green: 147, blue: 120)
    static let forestGreen = Color(red: 22, green: 128, blue: 83)
    static let darkPink = Color(red: 179, green: 102, blue: 159)
    static let darkRed = Color(red: 185, green: 22, blue: 77)
    static let lightBlue = Color(red: 72, green: 147, blue: 175)
    static let salmon = Color(red: 219, green: 135, blue: 41)
    static let military = Color(red: 117, green: 142, blue: 41)

}

fileprivate extension Color {

    init(red: Int, green: Int, blue: Int) {
        self.init(red: Double(red)/255, green: Double(green)/255, blue: Double(blue)/255)
    }

}
