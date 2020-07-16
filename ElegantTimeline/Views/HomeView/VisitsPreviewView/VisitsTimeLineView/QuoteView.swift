// Kevin Li - 3:47 PM - 6/29/20

import SwiftUI

struct QuoteView: View {

    @Environment(\.appTheme) private var appTheme: AppTheme

    @ObservedObject var quoteState: QuoteState

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
                    .opacity(quoteState.shouldShowHeader ? 1 : 0)

                Spacer()

                footerQuoteText
                    .opacity(quoteState.shouldShowFooter ? 1 : 0)
            }
            .padding(.horizontal, 24)
            .offset(y: quoteState.headerFooterOffset)
        }
    }

    var headerQuoteText: some View {
        VStack(alignment: .leading) {
            Text("If you're not failing, you're probably not really moving forward.")
                .font(.footnote)
            Text("-John Maxwell")
                .font(.caption)
                .italic()
        }
    }

    var footerQuoteText: some View {
        VStack(alignment: .leading) {
            Text("Why worry about things you can't control when you can keep yourself busy controlling the things that depend on you?")
                .font(.footnote)
            Text("-John Maxwell")
                .font(.caption)
                .italic()
        }
    }

}
