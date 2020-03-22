//
//  Locale+Ext.swift
//  CoronaCases
//
//  Created by SwiftiSwift on 19.03.20.
//  Copyright © 2020 SwiftiSwift. All rights reserved.
//

import Foundation

extension Locale {
    var countryNameInEnglish: String? {
        guard let countryCode = (Locale.current as NSLocale).object(forKey: .countryCode) as? String else { return nil }

        guard let currentCountryName = Self.countryNameInEnglish(countryCode: countryCode) else { return nil}
        
        return currentCountryName
    }
    
    static func countryNameInEnglish(countryCode: String) -> String? {
        let current = Locale(identifier: "en_US")
        return current.localizedString(forRegionCode: countryCode)
    }
}
