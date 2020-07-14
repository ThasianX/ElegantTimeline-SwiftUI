// Kevin Li - 10:37 AM - 7/11/20

import SwiftUI

struct MenuBarIndicator: View {

    var body: some View {
        VStack {
            ForEach(0...2, id: \.self) { _ in
                Circle()
                    .foregroundColor(.white)
                    .frame(width: 5, height: 5)
            }
        }
    }

}

struct MenuBarIndicator_Previews: PreviewProvider {
    static var previews: some View {
        MenuBarIndicator()
    }
}
