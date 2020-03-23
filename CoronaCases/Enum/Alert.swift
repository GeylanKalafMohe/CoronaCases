//
//  Alert.swift
//  CoronaCases
//
//  Created by SwiftiSwift on 21.03.20.
//  Copyright © 2020 SwiftiSwift. All rights reserved.
//

import UIKit
import SafariServices

enum Alert {
    static func showReload(forError error: APIError, title: String? = "Whoops", onVC vc: UIViewController, function: @escaping () -> ()) {
        var message: String!
        
        switch error {
        case .apiNotAvailable:
            message = "The servers are currently not available!\nPlease try again later."
        case .unkown:
            message = "An unkown error occured.\nPlease try again later."
        case .noInternet:
            message = "You're Offline.\nTurn off Airplane Mode or connect to Wi-Fi or Cellular Data."
        }
        
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Reload", style: .default) { (_) in
            function()
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        controller.addAction(cancel)
        controller.addAction(action)

        vc.present(controller, animated: true, completion: nil)
    }
    
    static func showUpdate(hasUpdate: Bool, onVC vc: UIViewController) {
        let title = hasUpdate ? "New Update is available!" : "You're up to date"
        let message = hasUpdate ? "A new update for CoronaCases has been released.\nCheck GitHub now." : nil
        
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let updateAct = UIAlertAction(title: "Update", style: .default) { (_) in
            func show() {
                Alert.showReload(forError: .unkown, title: "Error sesarching for an update", onVC: vc, function: {
                    showUpdate(hasUpdate: hasUpdate, onVC: vc)
                })
            }
            
            guard let url = URL(string: URLs.GITHUB_MAIN) else {
                show()
                return
            }
            
            UIApplication.shared.open(url, completionHandler: { success in
                if !success {
                    show()
                }
            })
        }
        let okAct = UIAlertAction(title: "OK", style: .default, handler: nil)
        let laterAct = UIAlertAction(title: "Later", style: .cancel, handler: nil)
        
        if hasUpdate {
            controller.addAction(laterAct)
            controller.addAction(updateAct)
        } else {
            controller.addAction(okAct)
        }
        
        vc.present(controller, animated: true, completion: nil)
    }
}
