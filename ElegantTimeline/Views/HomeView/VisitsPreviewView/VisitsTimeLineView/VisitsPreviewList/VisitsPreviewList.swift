// Kevin Li - 1:18 PM - 7/3/20

import SwiftUI

fileprivate class HostingCell: UITableViewCell {

    static let identifier = "HostingCell"

    private var hostingController: UIHostingController<AnyView>?

    func configure(with view: AnyView) {
        if let hostingController = hostingController {
            hostingController.rootView = view
        } else {
            let controller = UIHostingController(rootView: view)
            hostingController = controller

            let rootView = controller.view!
            rootView.translatesAutoresizingMaskIntoConstraints = false

            contentView.addSubview(rootView)

            NSLayoutConstraint.activate([
                rootView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                rootView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                rootView.topAnchor.constraint(equalTo: contentView.topAnchor),
                rootView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            ])
        }

        layoutIfNeeded()
    }

}

struct VisitsPreviewList: UIViewRepresentable {

    @Environment(\.autoTimer) private var autoTimer: AutoTimer

    typealias UIViewType = UITableView

    let visitsProvider: VisitsProvider
    let listScrollState: ListScrollState

    func makeUIView(context: Context) -> UITableView {
        let tableView = UITableView.visitsPreview(source: context.coordinator)
        listScrollState.attach(to: tableView)
        return tableView
    }

    func updateUIView(_ tableView: UITableView, context: Context) { }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITableViewDataSource {

        private let parent: VisitsPreviewList

        private var listScrollState: ListScrollState {
            parent.listScrollState
        }

        private var visitsProvider: VisitsProvider {
            parent.visitsProvider
        }

        init(_ parent: VisitsPreviewList) {
            self.parent = parent
        }

        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            listScrollState.descendingDayComponents.count
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: HostingCell.identifier) as! HostingCell

            let index = indexPath.row

            let rootView = dayVisitsView(
                dayComponent: visitsProvider.descendingDayComponents[index],
                isFilled: (index % 2) == 0)
                .id(index) // id is crucial as it resets state for a reused cell
                .erased

            cell.configure(with: rootView)

            return cell
        }

        private func dayVisitsView(dayComponent: DateComponents, isFilled: Bool) -> DayVisitsView {
            DayVisitsView(date: dayComponent.date,
                          visits: visitsProvider.visitsForDayComponents[dayComponent] ?? [],
                          isFilled: isFilled)
        }

    }

}


private extension UITableView {

    static func visitsPreview(source: UITableViewDataSource) -> UITableView {
        let tableView = UITableView()

        tableView.showsVerticalScrollIndicator = false
        tableView.allowsSelection = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.scrollsToTop = false

        // Both are crucial towards making the scroll smoother and necessary for the tableview
        // to scroll to a specific row properly
        tableView.rowHeight = Constants.List.blockHeight
        tableView.estimatedRowHeight = Constants.List.blockHeight

        tableView.dataSource = source

        tableView.register(HostingCell.self, forCellReuseIdentifier: HostingCell.identifier)

        return tableView
    }

}
