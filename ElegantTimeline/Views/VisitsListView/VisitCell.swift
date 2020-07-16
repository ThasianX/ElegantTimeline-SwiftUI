// Kevin Li - 8:10 PM - 7/9/20

import SwiftUI

struct VisitCell: View {

    let visit: Visit

    var body: some View {
        HStack {
            tagView

            VStack(alignment: .leading) {
                locationName
                visitDuration
            }

            Spacer()
        }
        .frame(height: Constants.Calendar.cellHeight)
        .padding(.vertical, Constants.Calendar.cellVerticalPadding)
    }

}

private extension VisitCell {

    var tagView: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(visit.tagColor)
            .frame(width: 5, height: Constants.Calendar.cellHeight-4)
    }

    var locationName: some View {
        Text(visit.locationName)
            .font(.system(size: 16))
            .lineLimit(1)
    }

    var visitDuration: some View {
        Text(visit.duration)
            .font(.system(size: 10))
            .lineLimit(1)
    }

}

struct VisitCell_Previews: PreviewProvider {
    static var previews: some View {
        DarkThemePreview {
            VisitCell(visit: .mock(withDate: Date()))
        }
    }
}
