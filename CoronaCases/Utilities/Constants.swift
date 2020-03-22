//
//  Constants.swift
//  CoronaCases
//
//  Created by SwiftiSwift on 19.03.20.
//  Copyright © 2020 SwiftiSwift. All rights reserved.
//

import UIKit

struct URLs {
    private static let BASE_URL = "https://corona.lmao.ninja/"
    static let GET_ALL_COUNTRIES = Self.BASE_URL + "countries"
    
    static func GET_COUNTRY(forName name: String) -> String {
        Self.BASE_URL + "countries/" + name
    }
}

struct DeviceInfo {
    static var appVersion: String {
        let appVersion: Any? = Bundle.main.infoDictionary!["CFBundleShortVersionString"]
        guard let appVersionString = appVersion as? String else { return "" }
        return appVersionString
    }
    
    static var appName: String {
        let appName = Bundle.main.infoDictionary![kCFBundleNameKey as String]
        guard let appNameString = appName as? String else { return "Unit Converter" }
        return appNameString
    }
    
    static var osVersion = UIDevice.current.systemVersion
    static var osName = UIDevice.current.systemName
    
    static var deviceModelIdentifier: String {
        var sysinfo = utsname()
        uname(&sysinfo) // ignore return value
        return String(bytes: Data(bytes: &sysinfo.machine, count: Int(_SYS_NAMELEN)), encoding: .ascii)!.trimmingCharacters(in: .controlCharacters)
    }
}
