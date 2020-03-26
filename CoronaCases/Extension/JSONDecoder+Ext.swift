//
//  JSONDecoder+Ext.swift
//  CoronaCases
//
//  Created by SwiftiSwift on 26.03.20.
//  Copyright © 2020 SwiftiSwift. All rights reserved.
//

import Foundation

extension JSONDecoder {
    func safeDecode<T: Decodable>(_ type: T.Type, from data: Data) -> T? {
        do {
            let decoded = try JSONDecoder().decode(type, from: data)
            return decoded
        } catch let DecodingError.dataCorrupted(context) {
            print(context)
        } catch let DecodingError.keyNotFound(key, context) {
            print("Key '\(key)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch let DecodingError.valueNotFound(value, context) {
            print("Value '\(value)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch let DecodingError.typeMismatch(type, context)  {
            print("Type '\(type)' mismatch:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch {
            print("DECODING ERROR: ", error.localizedDescription)
        }
        
        return nil
    }
}
