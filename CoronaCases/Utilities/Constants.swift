//
//  Constants.swift
//  CoronaCases
//
//  Created by SwiftiSwift on 19.03.20.
//  Copyright © 2020 SwiftiSwift. All rights reserved.
//

import UIKit

var updateIsAvailable = false

struct URLs {
    private static let BASE_URL = "https://api.caw.sh/"

    static func GET_ALL_COUNTRIES(forYesterday yesterday: Bool) -> String {
        return Self.BASE_URL + "v2/countries?yesterday=" + "\(yesterday)"
    }

    static func GET_COUNTRY(forName name: String, forYesterday yesterday: Bool) -> String {
        Self.BASE_URL + "v2/countries/" + name + "/?yesterday=" + "\(yesterday)"
    }
    
    static let GITHUB_RELEASES = "https://github.com/SwiftiSwift/CoronaCases/releases/"
    static let GITHUB_MAIN = "https://github.com/SwiftiSwift/CoronaCases/"
    static let GITHUB_README = "https://github.com/SwiftiSwift/CoronaCases/blob/master/README.md"
    static let GITHUB_API_LATEST_RELEASE = "https://api.github.com/repos/swiftiswift/coronacases/releases/latest"
}

let developerEmail = "unnotige.sachen@web.de"
let developerTwitterURL = "https://twitter.com/brownleeMarq"

struct DeviceInfo {
    static var appVersion: String {
        let appVersion: Any? = Bundle.main.infoDictionary!["CFBundleShortVersionString"]
        guard let appVersionString = appVersion as? String else { return "" }
        return appVersionString
    }
    
    static var appName: String {
        let appName = Bundle.main.infoDictionary![kCFBundleNameKey as String]
        guard let appNameString = appName as? String else { return "CoronaCases" }
        return appNameString
    }
    
    static var osVersion = UIDevice.current.systemVersion
    static var osName = UIDevice.current.systemName
    static var deviceModel = UIDevice.modelName

    static var deviceModelIdentifier: String {
        var sysinfo = utsname()
        uname(&sysinfo) // ignore return value
        return String(bytes: Data(bytes: &sysinfo.machine, count: Int(_SYS_NAMELEN)), encoding: .ascii)!.trimmingCharacters(in: .controlCharacters)
    }
}

func loc(_ stringKey: LocalizedStringKey) -> String {
    NSLocalizedString(stringKey.rawValue, comment: "")
}
