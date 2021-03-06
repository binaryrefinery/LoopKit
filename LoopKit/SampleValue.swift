//
//  SampleValue.swift
//  Naterade
//
//  Created by Nathan Racklyeft on 1/24/16.
//  Copyright © 2016 Nathan Racklyeft. All rights reserved.
//

import Foundation
import HealthKit


public protocol TimelineValue {
    var startDate: Date { get }
    var endDate: Date { get }
}


public extension TimelineValue {
    var endDate: Date {
        return startDate
    }
}


public protocol SampleValue: TimelineValue {
    var quantity: HKQuantity { get }
}


public extension Sequence where Iterator.Element: TimelineValue {
    /**
     Returns the closest element in the sorted sequence prior to the specified date

     - parameter date: The date to use in the search

     - returns: The closest element, if any exist before the specified date
     */
    func closestPriorToDate(_ date: Date) -> Iterator.Element? {
        var closestElement: Iterator.Element?

        for value in self {
            if value.startDate <= date {
                closestElement = value
            } else {
                break
            }
        }

        return closestElement
    }

    /**
     Returns an array of elements filtered by the specified date range.
     
     This behavior mimics HKQueryOptionNone, where the value must merely overlap the specified range,
     not strictly exist inside of it.

     - parameter startDate: The earliest date of elements to return
     - parameter endDate:   The latest date of elements to return

     - returns: A new array of elements
     */
    func filterDateRange(_ startDate: Date?, _ endDate: Date?) -> [Iterator.Element] {
        return filter { (value) -> Bool in
            if let startDate = startDate, value.endDate < startDate {
                return false
            }

            if let endDate = endDate, value.startDate > endDate {
                return false
            }

            return true
        }
    }
}


public extension BidirectionalCollection where Iterator.Element: TimelineValue, Index: Comparable {

    /**
     Determines whether the sequence contains boundary elements which span the specified time interval.

     The sequence is assumed to be sorted chronologically.

     TODO: Is this an effective measure to determine if there's enough reservoir entries to be trustworthy?

     - returns: True if the time interval is matched
     */
    func spanTimeInterval(_ timeInterval: TimeInterval, within errorInterval: TimeInterval = TimeInterval(minutes: 5)) -> Bool {
        guard let lastValue = last, let firstValue = first else { return false }

        return abs(lastValue.startDate.timeIntervalSince(firstValue.startDate) - timeInterval) <= errorInterval / 2
    }
}
