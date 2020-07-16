// Kevin Li - 9:02 AM - 6/1/20

import Foundation
import SwiftUI

struct Visit {

    let locationName: String
    let locationAddress: String
    let locationCity: String
    let locationZip: String
    let tagColor: Color
    let arrivalDate: Date
    let departureDate: Date

    var duration: String {
        arrivalDate.timeOnlyWithPadding + " ➝ " + departureDate.timeOnlyWithPadding
    }

}

extension Visit: Identifiable {

    var id: Int {
        UUID().hashValue
    }

}

extension Visit {

    static func mock(withDate date: Date) -> Visit {
        Visit(locationName: "Apple Inc",
              locationAddress: "54 W Colorado Blvd",
              locationCity: "Pasadena, CA",
              locationZip: "91105",
              tagColor: .randomColor,
              arrivalDate: date,
              departureDate: date.addingTimeInterval(60*60))
    }

    static func mocks(start: Date) -> [Visit] {
        appCalendar.generateVisits(
            start: start,
            end: Date())
    }

}

let minVisitCount = 0
let maxVisitCount = 7
fileprivate let visitCountRange = minVisitCount...maxVisitCount

private extension Calendar {

    func generateVisits(start: Date, end: Date) -> [Visit] {
        var visits = [Visit]()

        enumerateDates(
            startingAfter: start,
            matching: .everyDay,
            matchingPolicy: .nextTime) { date, _, stop in
            if let date = date {
                if isDateInToday(date) {
                    // This is just to guarantee that the today visit block does have visits
                    visits.append(.mock(withDate: date))
                    visits.append(.mock(withDate: date))
                } else if date < end {
                    for _ in 0..<Int.random(in: visitCountRange) {
                        visits.append(.mock(withDate: date))
                    }
                } else {
                    stop = true
                }
            }
        }

        return visits
    }

}

fileprivate let colorAssortment: [Color] = [.turquoise, .forestGreen, .darkPink, .darkRed, .lightBlue, .salmon, .military]

private extension Color {

    static var randomColor: Color {
        let randomNumber = arc4random_uniform(UInt32(colorAssortment.count))
        return colorAssortment[Int(randomNumber)]
    }

}

private extension DateComponents {

    static var everyDay: DateComponents {
        DateComponents(hour: 0, minute: 0, second: 0)
    }

}
