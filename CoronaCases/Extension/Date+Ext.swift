//
//  Date+Ext.swift
//  CoronaCases
//
//  Created by SwiftiSwift on 22.03.20.
//  Copyright © 2020 SwiftiSwift. All rights reserved.
//

import Foundation

extension Date {
    func getFormattedToString(monthInText: Bool = false) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = monthInText ? "dd.MMMM.yyyy" : "dd.MM.yyyy"
        formatter.locale = .current
        
        let dateString = formatter.string(from: self)
        formatter.dateFormat = "HH:mm:ss"
        let timeString = formatter.string(from: self)
        
        return dateString + " at " + timeString
    }
}
