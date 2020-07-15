// Kevin Li - 2:46 PM - 6/1/20

import SwiftUI

struct AppTheme: Hashable {

    let name: String
    let primary: Color
    let complementary: Color
    
}

extension AppTheme {

    static let allThemes: [AppTheme] = [.brilliantViolet, .kiwiGreen, .mauvePurple, .royalBlue]

    static let brilliantViolet = AppTheme(name: "Brilliant Violet",
                                          primary: .brilliantViolet,
                                          complementary: .brilliantVioletComplement)
    static let kiwiGreen = AppTheme(name: "Kiwi Green",
                                    primary: .kiwiGreen,
                                    complementary: .kiwiGreenComplement)
    static let mauvePurple = AppTheme(name: "Mauve Purple",
                                      primary: .mauvePurple,
                                      complementary: .mauvePurpleComplement)
    static let royalBlue = AppTheme(name: "Royal Blue",
                                    primary: .royalBlue,
                                    complementary: .royalBlueComplement)
    
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
