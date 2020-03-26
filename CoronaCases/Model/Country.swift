//
//  Country.swift
//  CoronaCases
//
//  Created by SwiftiSwift on 19.03.20.
//  Copyright © 2020 SwiftiSwift. All rights reserved.
//

import Foundation

struct Country: Codable {
    private(set) public var country: String
    private(set) public var cases: Int?
    private(set) public var todayCases: Int?
    private(set) public var deaths: Int?
    private(set) public var todayDeaths: Int?
    private(set) public var recovered: Int?
    private(set) public var active: Int?
    private(set) public var critical: Int?
    
    static func testAllCountries() -> [Country] {
        guard let url = Bundle.main.url(forResource: "country-codes.json", withExtension: nil) else {
            fatalError("No countrie file found")
        }
        
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode([Country].self, from: data)
        } catch {
            fatalError("Can't decode Countries: \(error)")
        }
    }
}
