// Kevin Li - 3:47 PM - 6/29/20

import SwiftUI

struct QuoteView: View {

    @Environment(\.appTheme) private var appTheme: AppTheme

    @ObservedObject var listScrollState: ListScrollState

    var body: some View {
        HStack(spacing: 0) {
            Spacer()
                .frame(width: Constants.List.sideBarWidth + Constants.List.sideBarPadding)

            quotePreviewBlock
        }
    }

}

private extension QuoteView {

    var quotePreviewBlock: some View {
        ZStack(alignment: .leading) {
            appTheme.primary
                .edgesIgnoringSafeArea(.vertical)

            VStack(alignment: .leading) {
                headerQuoteText
                    .opacity(listScrollState.shouldShowHeader ? 1 : 0)

                Spacer()

                footerQuoteText
                    .opacity(listScrollState.shouldShowFooter ? 1 : 0)
            }
            .padding(.horizontal, 24)
            .offset(y: listScrollState.headerFooterOffset)
        }
    }

    var headerQuoteText: some View {
        VStack(alignment: .leading) {
            Text("Life is not a problem to be solved, but a reality to be experienced.")
                .font(.footnote)
            Text("-Soren Kierkegaard")
                .font(.caption)
                .italic()
        }
    }

    var footerQuoteText: some View {
        VStack(alignment: .leading) {
            Text("Life is a series of natural and spontaneous changes. Don't resist them--that only creates sorrow. Let reality be reality. Let things flow naturally forward in whatever way they like.")
                .font(.footnote)
            Text("-Lao Tzu")
                .font(.caption)
                .italic()
        }
    }

}
