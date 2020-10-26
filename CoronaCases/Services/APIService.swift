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
    case cancelled
}

class APIService {
    static let instance = APIService()
    
    var task: URLSessionDataTask? = nil
    
    func clearCache() {
        let cacheURL =  FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let fileManager = FileManager.default
        do {
            // Get the directory contents urls (including subfolders urls)
            let directoryContents = try FileManager.default.contentsOfDirectory( at: cacheURL, includingPropertiesForKeys: nil, options: [])
            for file in directoryContents {
                do {
                    try fileManager.removeItem(at: file)
                }
                catch let error as NSError {
                    debugPrint("Ooops! Something went wrong while clearing cache: \(error)")
                }

            }
            
            print("Cache Cleared!")
        } catch let error as NSError {
            print("Error clearing cache: ", error.localizedDescription)
        }
    }
    
    func getAllCountries(yesterday: Bool, completion: @escaping (_ countries: Result<[Country], APIError>) -> ()) {
        guard let requestURL = URL(string: URLs.GET_ALL_COUNTRIES(forYesterday: yesterday)) else {
            print("Wrong URL", #file, #function, #line)
            return
        }
        clearCache()
        
        task = URLSession.shared.dataTask(with: requestURL) { (data, response, error) in
            if let error = ErrorChecker.instance.checkErrors(error, andResponse: response) {
                completion(.failure(error))
                return
            }

            guard let data = data, !data.isEmpty else { print("Could'nt get Data"); completion(.failure(.apiNotAvailable)); return }
            
            guard var countries = JSONDecoder().safeDecode([Country].self, from: data) else {
                completion(.failure(APIError.unknown))
                return
            }
            
            self.getWorld(yesterday: yesterday) { (result) in
                switch result {
                case .success(let country):
                    countries.insert(country, at: 0)
                    completion(.success(countries))

                case .failure(let error):
                    completion(.failure(error))
                }
            }
            
        }
        
        task?.resume()
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
        
        clearCache()
        
        task = URLSession.shared.dataTask(with: requestURL) { (data, response, error) in
            if let error = ErrorChecker.instance.checkErrors(error, andResponse: response) {
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
        
        task?.resume()
    }
    
    func getWorld(yesterday: Bool, completion: @escaping (_ countries: Result<Country, APIError>) -> ()) {
        guard let requestURL = URL(string: URLs.GET_WORLD(forYesterday: yesterday)) else {
            print("Wrong URL", #file, #function, #line)
            return
        }
        
        clearCache()

        task = URLSession.shared.dataTask(with: requestURL) { (data, response, error) in
            if let error = ErrorChecker.instance.checkErrors(error, andResponse: response) {
                completion(.failure(error))
                return
            }

            guard let data = data, !data.isEmpty else { print("Could'nt get Data"); completion(.failure(.apiNotAvailable)); return }
            
            guard let world = JSONDecoder().safeDecode(Country.self, from: data) else {
                completion(.failure(APIError.unknown))
                return
            }
            
            completion(.success(world))
        }
        
        task?.resume()
    }
    
    func checkForUpdate(completion: @escaping (_ result: Result<UpdateInfo, APIError>) -> ()) {
        guard let myURL = URL(string: URLs.GITHUB_API_LATEST_RELEASE) else {
            print("URL doesn't seem to be a valid URL")
            completion(.failure(.unknown))
            return
        }

        URLSession.shared.dataTask(with: myURL) { (data, response, error) in
            if let error = ErrorChecker.instance.checkErrors(error, andResponse: response) {
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
    
    func stopCurrentRequest() {
        self.task?.cancel()
    }
}
