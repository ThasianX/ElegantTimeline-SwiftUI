// Kevin Li - 2:46 PM - 6/1/20

import SwiftUI

struct AppTheme: Hashable {

    let name: String
    let primaryuiColor: UIColor
    let complementaryuiColor: UIColor
    let primary: Color
    let complementary: Color

    init(name: String, primaryuiColor: UIColor, complementaryuiColor: UIColor) {
        self.name = name
        self.primaryuiColor = primaryuiColor
        self.complementaryuiColor = complementaryuiColor
        self.primary = Color(primaryuiColor)
        self.complementary = Color(complementaryuiColor)
    }

}

extension AppTheme {

    static let allThemes: [AppTheme] = [
        .antwerpBlue,
        .arcticBlue,
        .bonoboGreen,
        .brilliantViolet,
        .fluorescentPink,
        .cadiumOrange,
        .kiwiGreen,
        .kraftBrown,
        .mauvePurple,
        .orangeYellow,
        .oxideGreen,
        .peachBlossomPink,
        .red,
        .royalBlue,
        .scarletRed,
        .seaweedGreen,
        .skyBlue,
        .sunflowerYellow,
        .underwaterBlue
    ]

    static let antwerpBlue = AppTheme(name: "Antwerp Blue",
                                      primaryuiColor: .antwerpBlue,
                                      complementaryuiColor: .antwerpBlueComplement)
    static let arcticBlue = AppTheme(name: "Arctic Blue",
                                     primaryuiColor: .arcticBlue,
                                     complementaryuiColor: .arcticBlueComplement)
    static let bonoboGreen = AppTheme(name: "Bonobo Green",
                                      primaryuiColor: .bonoboGreen,
                                      complementaryuiColor: .bonoboGreenComplement)
    static let brilliantViolet = AppTheme(name: "Brilliant Violet",
                                          primaryuiColor: .brilliantViolet,
                                          complementaryuiColor: .brilliantVioletComplement)
    static let cadiumOrange = AppTheme(name: "Cadium Orange",
                                       primaryuiColor: .cadiumOrange,
                                       complementaryuiColor: .cadiumOrangeComplement)
    static let fluorescentPink = AppTheme(name: "Fluorescent Pink",
                                          primaryuiColor: .fluorescentPink,
                                          complementaryuiColor: .fluorescentPinkComplement)
    static let kiwiGreen = AppTheme(name: "Kiwi Green",
                                    primaryuiColor: .kiwiGreen,
                                    complementaryuiColor: .kiwiGreenComplement)
    static let kraftBrown = AppTheme(name: "Kraft Brown",
                                     primaryuiColor: .kraftBrown,
                                     complementaryuiColor: .kraftBrownComplement)
    static let mauvePurple = AppTheme(name: "Mauve Purple",
                                      primaryuiColor: .mauvePurple,
                                      complementaryuiColor: .mauvePurpleComplement)
    static let orangeYellow = AppTheme(name: "Orange Yellow",
                                       primaryuiColor: .orangeYellow,
                                       complementaryuiColor: .orangeYellowComplement)
    static let oxideGreen = AppTheme(name: "Oxide Green",
                                     primaryuiColor: .oxideGreen,
                                     complementaryuiColor: .oxideGreenComplement)
    static let peachBlossomPink = AppTheme(name: "Peach Blossom Pink",
                                           primaryuiColor: .peachBlossomPink,
                                           complementaryuiColor: .peachBlossomPinkComplement)
    static let red = AppTheme(name: "Red",
                              primaryuiColor: .red,
                              complementaryuiColor: .redComplement)
    static let royalBlue = AppTheme(name: "Royal Blue",
                                    primaryuiColor: .royalBlue,
                                    complementaryuiColor: .royalBlueComplement)
    static let scarletRed = AppTheme(name: "Scarlet Red",
                                     primaryuiColor: .scarletRed,
                                     complementaryuiColor: .scarletRedComplement)
    static let seaweedGreen = AppTheme(name: "Seaweed Green",
                                       primaryuiColor: .seaweedGreen,
                                       complementaryuiColor: .seaweedGreenComplement)
    static let skyBlue = AppTheme(name: "Sky Blue",
                                  primaryuiColor: .skyBlue,
                                  complementaryuiColor: .skyBlueComplement)
    static let sunflowerYellow = AppTheme(name: "Sunflower Yellow",
                                          primaryuiColor: .sunflowerYellow,
                                          complementaryuiColor: .sunflowerYellowComplement)
    static let underwaterBlue = AppTheme(name: "Underwater Blue",
                                         primaryuiColor: .underwaterBlue,
                                         complementaryuiColor: .underwaterBlueComplement)
    static let wednesdayPink = AppTheme(name: "Wednesday Pink",
                                        primaryuiColor: .wednesdayPink,
                                        complementaryuiColor: .wednesdayPinkComplement)

    // Dummy color used for the initial color theme selection. Not actually part of the themes.
    static let _white = AppTheme(name: "Off White",
                                primaryuiColor: ._white,
                                complementaryuiColor: ._whiteComplement)
}

extension UIColor {

    static let antwerpBlue = UIColor(red: 17, green: 110, blue: 177)
    static let arcticBlue = UIColor(red: 149, green: 174, blue: 200)
    static let bonoboGreen = UIColor(red: 24, green: 147, blue: 120)
    static let brilliantViolet = UIColor(red: 69, green: 58, blue: 146)
    static let cadiumOrange = UIColor(red: 208, green: 64, blue: 24)
    static let fluorescentPink = UIColor(red: 185, green: 22, blue: 77)
    static let kiwiGreen = UIColor(red: 117, green: 142, blue: 41)
    static let kraftBrown = UIColor(red: 168, green: 136, blue: 99)
    static let mauvePurple = UIColor(red: 148, green: 42, blue: 115)
    static let orangeYellow = UIColor(red: 219, green: 135, blue: 41)
    static let oxideGreen = UIColor(red: 22, green: 128, blue: 83)
    static let peachBlossomPink = UIColor(red: 177, green: 131, blue: 121)
    static let red = UIColor(red: 177, green: 32, blue: 28)
    static let royalBlue = UIColor(red: 24, green: 83, blue: 149)
    static let scarletRed = UIColor(red: 149, green: 5, blue: 41)
    static let seaweedGreen = UIColor(red: 80, green: 127, blue: 129)
    static let skyBlue = UIColor(red: 72, green: 147, blue: 175)
    static let sunflowerYellow = UIColor(red: 196, green: 151, blue: 49)
    static let underwaterBlue = UIColor(red: 25, green: 142, blue: 151)
    static let wednesdayPink = UIColor(red: 179, green: 103, blue: 159)

    static let antwerpBlueComplement = UIColor(red: 19, green: 104, blue: 168)
    static let arcticBlueComplement = UIColor(red: 142, green: 167, blue: 192)
    static let bonoboGreenComplement = UIColor(red: 21, green: 142, blue: 115)
    static let brilliantVioletComplement = UIColor(red: 66, green: 55, blue: 141)
    static let cadiumOrangeComplement = UIColor(red: 200, green: 61, blue: 23)
    static let fluorescentPinkComplement = UIColor(red: 179, green: 20, blue: 74)
    static let kiwiGreenComplement = UIColor(red: 112, green: 135, blue: 38)
    static let kraftBrownComplement = UIColor(red: 161, green: 130, blue: 95)
    static let mauvePurpleComplement = UIColor(red: 142, green: 40, blue: 109)
    static let orangeYellowComplement = UIColor(red: 210, green: 129, blue: 39)
    static let oxideGreenComplement = UIColor(red: 19, green: 123, blue: 80)
    static let peachBlossomPinkComplement = UIColor(red: 171, green: 126, blue: 116)
    static let redComplement = UIColor(red: 170, green: 30, blue: 26)
    static let royalBlueComplement = UIColor(red: 22, green: 80, blue: 143)
    static let scarletRedComplement = UIColor(red: 142, green: 6, blue: 41)
    static let seaweedGreenComplement = UIColor(red: 77, green: 122, blue: 124)
    static let skyBlueComplement = UIColor(red: 69, green: 139, blue: 168)
    static let sunflowerYellowComplement = UIColor(red: 188, green: 143, blue: 49)
    static let underwaterBlueComplement = UIColor(red: 24, green: 136, blue: 146)
    static let wednesdayPinkComplement = UIColor(red: 171, green: 98, blue: 153)

    // Dummy color used for the initial color theme selection. Not actually part of the themes.
    static let _white = UIColor(red: 245, green: 250, blue: 250)
    static let _whiteComplement = UIColor(red: 240, green: 245, blue: 246)

}

fileprivate extension UIColor {

    convenience init(red: CGFloat, green: CGFloat, blue: CGFloat) {
        self.init(red: red / 255, green: green / 255, blue: blue / 255, alpha: 1)
    }

}

struct AppThemeKey: EnvironmentKey {
    
    static let defaultValue: AppTheme = .royalBlue
    
}

extension EnvironmentValues {
    
    var appTheme: AppTheme {
        get { self[AppThemeKey.self] }
        set { self[AppThemeKey.self] = newValue }
    }
    
}
