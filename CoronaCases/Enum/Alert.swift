//
//  Alert.swift
//  CoronaCases
//
//  Created by SwiftiSwift on 21.03.20.
//  Copyright © 2020 SwiftiSwift. All rights reserved.
//

import UIKit

enum Alert {
    static func showReload(forError error: APIError, onVC vc: UIViewController, function: @escaping () -> ()) {
        var message: String!
        
        switch error {
        case .apiNotAvailable:
            message = "The servers are currently not available!\nPlease try again later."
        case .unkown:
            message = "An unkown error occured.\nPlease try again later."
        case .noInternet:
            message = "You're Offline.\nTurn off Airplane Mode or connect to Wi-Fi or Cellular Data."
        }
        
        let controller = UIAlertController(title: "Whoops", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Reload", style: .default) { (_) in
            function()
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        controller.addAction(action)
        controller.addAction(cancel)
        
        vc.present(controller, animated: true, completion: nil)
    }
}
