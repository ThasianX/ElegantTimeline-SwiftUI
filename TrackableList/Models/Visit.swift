// Kevin Li - 9:02 AM - 6/1/20

import Foundation
import SwiftUI

struct Visit {

    let locationName: String
    let locationAddress: String
    let tagColor: Color
    let arrivalDate: Date
    let departureDate: Date

    var duration: String {
        arrivalDate.timeOnlyWithPadding + " ➝ " + departureDate.timeOnlyWithPadding
    }

}

extension Visit: Identifiable {

    var id: Int {
        locationName.hashValue
    }

}

extension Visit {

    static let mock = Visit(locationName: "Apple Inc",
                            locationAddress: "191 W Lane Ave, Columbus, OH 43210 US",
                            tagColor: .blue,
                            arrivalDate: Date(),
                            departureDate: Date().addingTimeInterval(180))

    static let mocks = [
        Visit(locationName: "In-N-Out Burger",
              locationAddress: "191 W Lane Ave, Columbus, OH 43210 US",
              tagColor: .blue,
              arrivalDate: Date.custom("2020-06-01 15:29:51"),
              departureDate: Date.custom("2020-06-01 17:59:23")),
        Visit(locationName: "Apple Inc",
              locationAddress: "191 W Lane Ave, Columbus, OH 43210 US",
              tagColor: .blue,
              arrivalDate: Date.custom("2020-06-01 10:29:51"),
              departureDate: Date.custom("2020-06-01 11:59:23")),
        Visit(locationName: "Buckeye Stadium",
              locationAddress: "191 W Lane Ave, Columbus, OH 43210 US",
              tagColor: .green,
              arrivalDate: Date.custom("2020-06-01 10:08:52"),
              departureDate: Date.custom("2020-06-01 10:21:02")),
        Visit(locationName: "Jenni's Ice Cream",
              locationAddress: "191 W Lane Ave, Columbus, OH 43210 US",
              tagColor: .red,
              arrivalDate: Date.custom("2020-06-01 09:24:05"),
              departureDate: Date.custom("2020-06-01 09:48:55")),
        Visit(locationName: "Eiffel Tower",
              locationAddress: "191 W Lane Ave, Columbus, OH 43210 US",
              tagColor: .red,
              arrivalDate: Date.custom("2020-05-31 14:45:23"),
              departureDate: Date.custom("2020-06-01 09:10:20")),
        Visit(locationName: "Stonehenge",
              locationAddress: "191 W Lane Ave, Columbus, OH 43210 US",
              tagColor: .green,
              arrivalDate: Date.custom("2020-05-31 13:34:15"),
              departureDate: Date.custom("2020-05-31 14:36:11")),
        Visit(locationName: "Porkfolio KBBQ",
              locationAddress: "191 W Lane Ave, Columbus, OH 43210 US",
              tagColor: .blue,
              arrivalDate: Date.custom("2020-05-23 13:05:46"),
              departureDate: Date.custom("2020-05-23 13:38:14")),
        Visit(locationName: "Fork Over Pork",
              locationAddress: "191 W Lane Ave, Columbus, OH 43210 US",
              tagColor: .orange,
              arrivalDate: Date.custom("2020-05-23 12:22:08"),
              departureDate: Date.custom("2020-05-23 12:40:30")),
        Visit(locationName: "Tesla Headquarters",
              locationAddress: "191 W Lane Ave, Columbus, OH 43210 US",
              tagColor: .orange,
              arrivalDate: Date.custom("2020-05-23 10:13:38"),
              departureDate: Date.custom("2020-05-23 10:34:38")),
        Visit(locationName: "Google Headquarters",
              locationAddress: "191 W Lane Ave, Columbus, OH 43210 US",
              tagColor: .green,
              arrivalDate: Date.custom("2020-05-17 16:19:58"),
              departureDate: Date.custom("2020-05-23 10:08:05")),
        Visit(locationName: "Jack In the Box",
              locationAddress: "191 W Lane Ave, Columbus, OH 43210 US",
              tagColor: .green,
              arrivalDate: Date.custom("2020-05-09 16:41:35"),
              departureDate: Date.custom("2020-05-09 16:55:26")),
        Visit(locationName: "McDonalds",
              locationAddress: "191 W Lane Ave, Columbus, OH 43210 US",
              tagColor: .yellow,
              arrivalDate: Date.custom("2020-05-07 16:19:58"),
              departureDate: Date.custom("2020-05-07 10:08:05")),
        Visit(locationName: "Potato Corner",
              locationAddress: "191 W Lane Ave, Columbus, OH 43210 US",
              tagColor: .green,
              arrivalDate: Date.custom("2020-05-02 15:31:34"),
              departureDate: Date.custom("2020-05-03 12:51:34")),
        Visit(locationName: "Chipotle",
              locationAddress: "191 W Lane Ave, Columbus, OH 43210 US",
              tagColor: .blue,
              arrivalDate: Date.custom("2020-04-02 13:30:55"),
              departureDate: Date.custom("2020-05-02 14:07:02")),
        Visit(locationName: "Yoshinoya",
              locationAddress: "191 W Lane Ave, Columbus, OH 43210 US",
              tagColor: .orange,
              arrivalDate: Date.custom("2020-03-14 12:38:49"),
              departureDate: Date.custom("2020-03-14 13:50:48")),
    ]

}

private extension Date {

    static func custom(_ dateString: String) -> Date {
        Formatter.custom.date(from: dateString)!
    }

}

private extension Formatter {

    static let custom: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()

}
