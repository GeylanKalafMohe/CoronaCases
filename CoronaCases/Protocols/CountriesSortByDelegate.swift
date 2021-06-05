//
//  CountriesSortByDelegate.swift
//  CoronaCases
//
//  Created by SwiftiSwift on 28.03.20.
//  Copyright © 2020 SwiftiSwift. All rights reserved.
//

import Foundation

protocol CountriesSortByDelegate: AnyObject {
    func selectedNewSorting(_ sortType: SortType)
}
