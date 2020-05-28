//
//  ErrorChecker.swift
//  CoronaCases
//
//  Created by Geylan Kalaf Mohe on 20.04.20.
//  Copyright © 2020 Geylan Kalaf Mohe. All rights reserved.
//

import Foundation

class ErrorChecker {
    static let instance = ErrorChecker()
    
    func checkErrors(_ error: Error?, andResponse response: URLResponse?) -> APIError? {
        if let urlError = error as? URLError, urlError.code == .cancelled {
            return .cancelled
        }

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
}
