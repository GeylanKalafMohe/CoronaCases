//
//  Int+Ext.swift
//  CoronaCases
//
//  Created by SwiftiSwift on 19.03.20.
//  Copyright © 2020 SwiftiSwift. All rights reserved.
//

import Foundation

extension Int {
    func asString() -> String {
        "\(self)"
    }
    
    func thousandSeparator() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.decimal
        formatter.locale = Locale.current
        
        return formatter.string(for: self) ?? asString()
    }
}
