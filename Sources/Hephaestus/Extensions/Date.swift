
import Foundation
import UIKit

extension Date {
    func dateByAddingDays(_ days: Int) -> Date {
        return dateByAdding(component: .day, value: days)
    }
    
    private func dateByAdding(component: NSCalendar.Unit, value: Int) -> Date {
        return (Calendar.current as NSCalendar).date(
            byAdding: component,
            value: value,
            to: self,
            options: []
        ) ?? self
    }
}

extension Date {
    init(year: Int, month: Int, day: Int) {
        let calendar = Calendar.current
        var dateComponent = DateComponents()
        dateComponent.year = year
        dateComponent.month = month
        dateComponent.day = day
        self = calendar.date(from: dateComponent) ?? Date()
    }
    static func == (lhs: Date, rhs: Date) -> Bool {
        return lhs.compare(rhs) == ComparisonResult.orderedSame
    }
    
    static func < (lhs: Date, rhs: Date) -> Bool {
        return lhs.compare(rhs) == ComparisonResult.orderedAscending
    }
    
    static func > (lhs: Date, rhs: Date) -> Bool {
        return rhs.compare(lhs) == ComparisonResult.orderedAscending
    }
}
