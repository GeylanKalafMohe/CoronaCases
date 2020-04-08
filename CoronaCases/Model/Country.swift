//
//  Country.swift
//  CoronaCases
//
//  Created by SwiftiSwift on 19.03.20.
//  Copyright © 2020 SwiftiSwift. All rights reserved.
//

import Foundation

struct Country: Codable, Equatable {
    private(set) public var country: String
    private(set) public var cases: Int?
    private(set) public var todayCases: Int?
    private(set) public var deaths: Int?
    private(set) public var todayDeaths: Int?
    private(set) public var recovered: Int?
    private(set) public var critical: Int?
    private(set) public var countryInfo: CountryInfo?
    private(set) public var updated: Double?

    struct CountryInfo: Codable {
        private(set) public var iso2: String?
    }

    var getLocalizedCountryName: String {
        guard let isoCode = countryInfo?.iso2 else { return country }
        return Locale.current.getLocalizedCountryName(forCountryCode: isoCode) ?? country
    }
    
    var getUpdatedDate: Date? {
        guard let updated = updated else { return nil }
        let date = Date(timeIntervalSince1970: updated / 1000)

        return date
    }
        
    static func ==(lhs: Country, rhs: Country) -> Bool {
        lhs.country == rhs.country
    }
    
    #if DEBUG
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
    #endif
}
