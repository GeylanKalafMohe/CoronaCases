//
//  Locale+Ext.swift
//  CoronaCases
//
//  Created by SwiftiSwift on 19.03.20.
//  Copyright © 2020 SwiftiSwift. All rights reserved.
//

import Foundation

extension Locale {
    var localizedCountryName: String? {
        guard
            let countryCode = regionCode,
            let currentCountryName = getLocalizedCountryName(forCountryCode: countryCode)
        else { return nil }

        return currentCountryName
    }
    
    func getLocalizedCountryName(forCountryCode countryCode: String) -> String? {
        return self.localizedString(forRegionCode: countryCode)
    }
}
