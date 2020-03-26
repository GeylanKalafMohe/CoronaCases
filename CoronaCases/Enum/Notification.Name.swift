//
//  Notification.Name.swift
//  CoronaCases
//
//  Created by SwiftiSwift on 25.03.20.
//  Copyright © 2020 SwiftiSwift. All rights reserved.
//

import Foundation

extension NSNotification.Name {
    static var NEW_UPDATE = Notification.Name("com.SwiftiSwift.CoronaCases.NEW_UPDATE")
    static var ERROR_SEARCHING_UPDATE_RELOAD_TAPPED = Notification.Name("com.SwiftiSwift.CoronaCases.ERROR_SEARCHING_UPDATE_RELOAD_TAPPED")
    static var ERROR_SEARCHING_UPDATE = Notification.Name("com.SwiftiSwift.CoronaCases.ERROR_SEARCHING_UPDATE")
    static var SUCCESS_SEARCHING_FOR_UPDATE = Notification.Name("com.SwiftiSwift.CoronaCases.SUCCESS_SEARCHING_FOR_UPDATE")
}
