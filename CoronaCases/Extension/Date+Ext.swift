//
//  Date+Ext.swift
//  CoronaCases
//
//  Created by SwiftiSwift on 22.03.20.
//  Copyright © 2020 SwiftiSwift. All rights reserved.
//

import Foundation

extension Date {
    func getString(monthInText: Bool = false, withTime timeOn: Bool = true) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = monthInText ? "dd.MMMM.yyyy" : "dd.MM.yyyy"
        formatter.locale = .current
        
        let dateString = formatter.string(from: self)
        if timeOn {
            formatter.dateFormat = "HH:mm:ss"
            let timeString = formatter.string(from: self)
            return dateString + " \(loc(.at)) " + timeString
        }
        
        return dateString
    }
    
    var yesterday: Date? {
        let lastDay = Calendar.current.date(byAdding: .day, value: -1, to: self)

        return lastDay
    }
}
