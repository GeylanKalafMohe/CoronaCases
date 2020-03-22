//
//  APIService.swift
//  CoronaCases
//
//  Created by SwiftiSwift on 19.03.20.
//  Copyright © 2020 SwiftiSwift. All rights reserved.
//

import Foundation

enum APIError: Error {
    case unkown
    case apiNotAvailable
    case noInternet
}

class APIService {
    static let instance = APIService()
    
    func getAllCountries(completion: @escaping (_ countries: Result<[Country], APIError>) -> ()) {
        guard let requestURL = URL(string: URLs.GET_ALL_COUNTRIES) else {
            print("Wrong URL", #file, #function, #line)
            return
        }
        
        URLSession.shared.dataTask(with: requestURL) { (data, response, error) in
            if let error = self.checkForInternet(forError: error) {
                completion(.failure(error))
                return
            }
            
            if let error = error {
                print(error.localizedDescription)
                completion(.failure(APIError.unkown))
                return
            }
            
            if let error = self.checkForBadStatusCode(forResponse: response) {
                completion(.failure(error))
                return
            }

            guard let data = data else { print("Could'nt get Data"); completion(.failure(.unkown)); return }
            
            do {
                let countries = try JSONDecoder().decode([Country].self, from: data)
                completion(.success(countries))
            } catch {
                print(error.localizedDescription)
                completion(.failure(APIError.unkown))
            }
        }
        .resume()
    }
    
    func getCountry(forName name: String, completion: @escaping (_ country: Result<Country, APIError>) -> ()) {
        guard let requestURL = URL(string: URLs.GET_COUNTRY(forName: name)) else { print("Wrong URL", #file, #function, #line); return }
        
        URLSession.shared.dataTask(with: requestURL) { (data, response, error) in
            if let error = self.checkForInternet(forError: error) {
                completion(.failure(error))
                return
            }

            if let error = error {
                print(error.localizedDescription)
                completion(.failure(APIError.unkown))
                return
            }
            
            if let error = self.checkForBadStatusCode(forResponse: response) {
                completion(.failure(error))
                return
            }
            
            guard let data = data else { return }
            
            do {
                let country = try JSONDecoder().decode(Country.self, from: data)
                completion(.success(country))
            } catch {
                print(error.localizedDescription)
                completion(.failure(APIError.unkown))
            }
        }
        .resume()
    }
    
    private func checkForInternet(forError error: Error?) -> APIError? {
        if let urlError = error as? URLError, urlError.errorCode == -1009 {
            print("no internet")
            return APIError.noInternet
        }
        
        return nil
    }
    
    private func checkForBadStatusCode(forResponse response: URLResponse?) -> APIError? {
        if let httpResponse = response as? HTTPURLResponse {
            let statusCode = httpResponse.statusCode
            if statusCode != 200 {
                print("API is not available! StatusCode:", statusCode)
                return APIError.apiNotAvailable
            }
        }
        
        return nil
    }
}
