//
//  CountriesArray+Ext.swift
//  CoronaCases
//
//  Created by SwiftiSwift on 27.03.20.
//  Copyright © 2020 SwiftiSwift. All rights reserved.
//

import Foundation

extension Array where Iterator.Element == Country {
    func sort(by sortType: SortType) -> [Country] {
        switch sortType {
        case .confirmedCases:
            let sorted = self.sorted(by: { $0.cases ?? 0 > $1.cases ?? 0 })
            return sorted
        case .totalDeaths:
            let sorted = self.sorted(by: { $0.deaths ?? 0 > $1.deaths ?? 0 })
            return sorted
        case .totalRecovered:
            let sorted = self.sorted(by: { $0.recovered ?? 0 > $1.recovered ?? 0 })
            return sorted
        }
    }
}
