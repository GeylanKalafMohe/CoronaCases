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
            if let error = self.checkErrors(error, andResponse: response) {
                completion(.failure(error))
                return
            }

            guard let data = data, !data.isEmpty else { print("Could'nt get Data"); completion(.failure(.apiNotAvailable)); return }
            
            guard let countries = JSONDecoder().safeDecode([Country].self, from: data) else {
                completion(.failure(APIError.unkown))
                return
            }
            completion(.success(countries))
        }
        .resume()
    }
    
    func getCountry(forName name: String, completion: @escaping (_ country: Result<Country, APIError>) -> ()) {
        guard let countryName = name.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) else {
            print("No url percentage", #file, #function, #line)
            completion(.failure(.unkown))
            return
        }
        
        guard let requestURL = URL(string: URLs.GET_COUNTRY(forName: countryName)) else {
            print("Wrong URL", #file, #function, #line)
            completion(.failure(.unkown))
            return
        }
        
        URLSession.shared.dataTask(with: requestURL) { (data, response, error) in
            if let error = self.checkErrors(error, andResponse: response) {
                completion(.failure(error))
                return
            }
            
            guard let data = data, !data.isEmpty else { print("Could'nt get Data"); completion(.failure(.apiNotAvailable)); return }

            guard let country = JSONDecoder().safeDecode(Country.self, from: data) else {
                completion(.failure(APIError.unkown))
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
            return .unkown
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
    
    func checkForUpdate(completion: @escaping (_ result: Result<Bool, APIError>) -> ()) {
        guard let myURL = URL(string: URLs.GITHUB_RELEASES) else {
            print("URL doesn't seem to be a valid URL")
            completion(.failure(.unkown))
            return
        }

        URLSession.shared.dataTask(with: myURL) { (data, response, error) in
            if let error = self.checkErrors(error, andResponse: response) {
                completion(.failure(error))
                return
            }
            
            guard let data = data else { completion(.failure(.unkown)); return }
            guard let htmlString = String(data: data, encoding: .ascii) else { completion(.failure(.unkown)); return }
            
            do {
                // parses the version out of html
                let doc: Document = try SwiftSoup.parse(htmlString)
                guard var version = try doc.select("body").first()?
                                            .select("div").array()
                                            .first(where: { try $0.attr("class") == "application-main "})?
                                            .select("div").select("main").select("div").array()
                                            .first(where: { try $0.attr("class") == "container-lg clearfix new-discussion-timeline  p-responsive"})?
                                            .attr("class", "repository-content ")
                                            .attr("class", "position-relative border-top clearfix")
                                            .attr("class", "position-relative border-top clearfix")
                                            .children().array().first?.child(2).children().first()?
                                            .children().array().first?.children().array().first?.child(1)
                                            .children().array().first?.children().first()?.child(1)
                                            .ownText() else { return }
                
                // Removes the "v" from version num
                version.remove(at: version.startIndex)
                
                let hasNewVersion = version > DeviceInfo.appVersion
                completion(.success(hasNewVersion))
            } catch let error {
                print("Error: \(error)")
                completion(.failure(.unkown))
            }
        }
        .resume()
    }
}
