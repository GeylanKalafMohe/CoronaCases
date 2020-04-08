//
//  Locale+Ext.swift
//  CoronaCases
//
//  Created by SwiftiSwift on 19.03.20.
//  Copyright © 2020 SwiftiSwift. All rights reserved.
//

import Foundation

extension Locale {
    var countryCode: String? {
        guard let countryCode = (Locale.current as NSLocale).object(forKey: .countryCode) as? String else { return nil }
        return countryCode
    }
    
    var localizedCountryName: String? {
        guard
            let countryCode = countryCode,
            let currentCountryName = getLocalizedCountryName(forCountryCode: countryCode)
        else { return nil }

        return currentCountryName
    }
    
    func getLocalizedCountryName(forCountryCode countryCode: String) -> String? {
        return self.localizedString(forRegionCode: countryCode)
    }
}
