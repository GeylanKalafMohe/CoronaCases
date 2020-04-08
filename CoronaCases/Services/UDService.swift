//
//  UDService.swift
//  CoronaCases
//
//  Created by SwiftiSwift on 08.04.20.
//  Copyright © 2020 SwiftiSwift. All rights reserved.
//

import Foundation

class UDService {
    static let instance = UDService()
    
    private lazy var userDefaults = UserDefaults.standard
    
    var darkModeSwitch: Bool {
        get {
            userDefaults.bool(forKey: UDKeys.darkModeSwitch)
        }
        
        set {
            userDefaults.set(newValue, forKey: UDKeys.darkModeSwitch)
            userDefaults.synchronize()
        }
    }
    
    var useDeviceUIStyleSwitch: Bool {
        get {
            userDefaults.bool(forKey: UDKeys.useDeviceUIStyleSwitch)
        }
        
        set {
            userDefaults.set(newValue, forKey: UDKeys.useDeviceUIStyleSwitch)
            userDefaults.synchronize()
        }
    }
    
    var setDarkMode: Bool {
        userDefaults.object(forKey: UDKeys.useDeviceUIStyleSwitch) != nil || userDefaults.object(forKey: UDKeys.darkModeSwitch) != nil
    }
}
