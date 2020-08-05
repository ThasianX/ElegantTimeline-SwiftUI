// Kevin Li - 1:41 PM - 6/1/20

import SwiftUI

struct VisitPreviewCell: View {

    let visit: Visit
    let isBackgroundWhite: Bool

    var body: some View {
        HStack(spacing: 10) {
            tagView

            VStack(alignment: .leading, spacing: 3) {
                locationName
                visitDurationAndAddress
            }

            Spacer()
        }
    }

}

private extension VisitPreviewCell {

    var tagView: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(visit.tagColor)
            .frame(width: 5, height: 28)
    }

    var locationName: some View {
        Text(visit.locationName)
            .font(.system(size: 16))
            .fontWeight(.light)
            .lineLimit(1)
            .foregroundColor(isBackgroundWhite ? .black : .white)
    }

    var visitDurationAndAddress: some View {
        Text("\(visit.duration)    \(visit.locationCity)")
            .font(.system(size: 8))
            .lineLimit(1)
            .foregroundColor(isBackgroundWhite ? .black : .white)
    }

}

struct LocationPreviewCell_Previews: PreviewProvider {

    static var previews: some View {
        DarkThemePreview {
            VisitPreviewCell(visit: .mock(withDate: Date()),
                             isBackgroundWhite: false)
        }
    }
    
}
