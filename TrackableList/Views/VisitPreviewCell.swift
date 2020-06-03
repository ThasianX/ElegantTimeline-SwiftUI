// Kevin Li - 1:41 PM - 6/1/20

import SwiftUI

struct VisitPreviewCell: View {

    let visit: Visit

    var body: some View {
        HStack {
            tagView

            VStack(alignment: .leading) {
                locationName
                visitDurationAndAddress
            }

            Spacer()
        }
        .frame(height: VisitPreviewConstants.cellHeight)
        .padding(VisitPreviewConstants.cellPadding)
    }

}

private extension VisitPreviewCell {

    var tagView: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(visit.tagColor)
            .frame(width: 30, height: 5)
            .rotated(.degrees(90))
    }

    var locationName: some View {
        Text(visit.locationName)
            .font(.system(size: 16))
            .lineLimit(1)
    }

    var visitDurationAndAddress: some View {
        Text("\(visit.duration)    \(visit.locationAddress)")
            .font(.system(size: 10))
            .lineLimit(1)
    }

}

struct LocationPreviewCell_Previews: PreviewProvider {

    static var previews: some View {
        VisitPreviewCell(visit: .mock)
    }
    
}
