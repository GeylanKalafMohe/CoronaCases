//
//  SortType.swift
//  CoronaCases
//
//  Created by SwiftiSwift on 27.03.20.
//  Copyright © 2020 SwiftiSwift. All rights reserved.
//

import Foundation

enum SortType: CaseIterable {
    case confirmedCases
    case totalDeaths
    case totalRecovered
    
    var localizedString: String {
        switch self {
        case .confirmedCases:
            return loc(.confirmedCases)
        case .totalDeaths:
            return loc(.totalDeaths)
        case .totalRecovered:
            return loc(.totalRecovered)
        }
    }
}
