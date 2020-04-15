//
//  APIService.swift
//  CoronaCases
//
//  Created by SwiftiSwift on 19.03.20.
//  Copyright © 2020 SwiftiSwift. All rights reserved.
//

import Foundation
import SwiftSoup

enum APIError: Error {
    case unknown
    case apiNotAvailable
    case noInternet
}

class APIService {
    static let instance = APIService()
    
    func getAllCountries(yesterday: Bool, completion: @escaping (_ countries: Result<[Country], APIError>) -> ()) {
        guard let requestURL = URL(string: URLs.GET_ALL_COUNTRIES(forYesterday: yesterday)) else {
            print("Wrong URL", #file, #function, #line)
            return
        }
        
        URLSession.shared.dataTask(with: requestURL) { (data, response, error) in
            if let error = self.checkErrors(error, andResponse: response) {
                completion(.failure(error))
                return
            }

            guard let data = data, !data.isEmpty else { print("Could'nt get Data"); completion(.failure(.apiNotAvailable)); return }
            
            guard var countries = JSONDecoder().safeDecode([Country].self, from: data) else {
                completion(.failure(APIError.unknown))
                return
            }
            
            var totalCases = 0
            var todayCases = 0
            var totalDeaths = 0
            var todayDeaths = 0
            var totalRecovered = 0
            var criticalCases = 0

            for country in countries {
                totalCases += country.cases ?? 0
                todayCases += country.todayCases ?? 0
                totalDeaths += country.deaths ?? 0
                todayDeaths += country.todayDeaths ?? 0
                totalRecovered += country.recovered ?? 0
                criticalCases += country.critical ?? 0
            }
            
            let world = Country(country: "World",
                                cases: totalCases,
                                todayCases: todayCases,
                                deaths: totalDeaths,
                                todayDeaths: todayDeaths,
                                recovered: totalRecovered,
                                critical: criticalCases,
                                countryInfo: nil,
                                updated: countries.first?.updated ?? Date().timeIntervalSinceNow)
            countries.insert(world, at: 0)
            completion(.success(countries))
        }
        .resume()
    }
    
    func getCountry(forName name: String, forYesterday yesterday: Bool, completion: @escaping (_ country: Result<Country, APIError>) -> ()) {
        guard let countryName = name.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) else {
            print("No url percentage", #file, #function, #line)
            completion(.failure(.unknown))
            return
        }
        
        guard let requestURL = URL(string: URLs.GET_COUNTRY(forName: countryName, forYesterday: yesterday)) else {
            print("Wrong URL", #file, #function, #line)
            completion(.failure(.unknown))
            return
        }
        
        URLSession.shared.dataTask(with: requestURL) { (data, response, error) in
            if let error = self.checkErrors(error, andResponse: response) {
                completion(.failure(error))
                return
            }
            
            guard let data = data, !data.isEmpty else { print("Could'nt get Data"); completion(.failure(.apiNotAvailable)); return }

            guard let country = JSONDecoder().safeDecode(Country.self, from: data) else {
                completion(.failure(APIError.unknown))
                return
            }
            completion(.success(country))
        }
        .resume()
    }
    
    private func checkErrors(_ error: Error?, andResponse response: URLResponse?) -> APIError? {
        if let error = self.checkForInternet(forError: error) {
            return error
        }

        if let error = error {
            print(error.localizedDescription)
            return .unknown
        }
        
        if let error = self.checkForBadStatusCode(forResponse: response) {
            return error
        }
        
        return nil
    }
    
    private func checkForInternet(forError error: Error?) -> APIError? {
        // No internet errorCode: -1009
        if let urlError = error as? URLError, urlError.code == .notConnectedToInternet {
            print("no internet")
            return APIError.noInternet
        }
        
        return nil
    }
    
    private func checkForBadStatusCode(forResponse response: URLResponse?) -> APIError? {
        if let httpResponse = response as? HTTPURLResponse {
            let statusCode = httpResponse.statusCode
            switch statusCode {
            case 200...201: break
            default:
                print("API is not available! StatusCode:", statusCode)
                return APIError.apiNotAvailable
            }
        }
        
        return nil
    }
    
    func checkForUpdate(completion: @escaping (_ result: Result<UpdateInfo, APIError>) -> ()) {
        guard let myURL = URL(string: URLs.GITHUB_API_LATEST_RELEASE) else {
            print("URL doesn't seem to be a valid URL")
            completion(.failure(.unknown))
            return
        }

        URLSession.shared.dataTask(with: myURL) { (data, response, error) in
            if let error = self.checkErrors(error, andResponse: response) {
                completion(.failure(error))
                return
            }
            
            guard let data = data else { completion(.failure(.unknown)); return }
            
            do {
                let jsonResponse = try JSONSerialization.jsonObject(with: data)
                
                guard let jsonDict = jsonResponse as? [String: Any],
                      var version = jsonDict["tag_name"] as? String,
                      let changelog = jsonDict["body"] as? String
                else { print("error getting update"); completion(.failure(.unknown)); return }

                // Removes the "v" from version num
                version.remove(at: version.startIndex)
                
                let hasNewVersion = version > DeviceInfo.appVersion

                let updateInfo = UpdateInfo(updateAvailable: hasNewVersion, changelog: changelog)
                completion(.success(updateInfo))
            } catch let parsingError {
                print("Error", parsingError)
                completion(.failure(.unknown))
            }
        }
        .resume()
    }
}

struct UpdateInfo {
    let updateAvailable: Bool
    let changelog: String
}
