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
    static func showReload(forError error: APIError, title: String? = loc(.whoops_title), onVC vc: UIViewController, cancelTapped: (() -> ())? = nil, reloadTapped: @escaping () -> ()) {
        var message: String!
        
        switch error {
        case .apiNotAvailable:
            message = loc(.serversNotAvailable_message)
        case .unknown:
            message = loc(.unkownError_message)
        case .noInternet:
            message = loc(.noInternet_message)
        case .cancelled:
            return
        }
        
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: loc(.reload_btn), style: .default) { _ in
            reloadTapped()
        }
        let cancel = UIAlertAction(title: loc(.cancel_btn), style: .cancel) { _ in
            cancelTapped?()
        }
        
        controller.addAction(cancel)
        controller.addAction(action)

        vc.present(controller, animated: true, completion: nil)
    }
    
    static func showUpdate(changelog: String, hasUpdate: Bool, onVC vc: UIViewController) {
        let title = hasUpdate ? loc(.newUpdateAvailable_title) : loc(.upToDate_title)
        let message = hasUpdate ? (loc(.newUpdateAvailable_message) + "\n\n" + changelog) : nil
        
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let updateAct = UIAlertAction(title: loc(.update), style: .default) { (_) in
            func show() {
                Alert.showReload(forError: .unknown, title: loc(.errorSearchingForUpdate), onVC: vc, reloadTapped: {
                    showUpdate(changelog: changelog, hasUpdate: hasUpdate, onVC: vc)
                })
            }
            
            guard let url = URL(string: URLs.GITHUB_RELEASES) else {
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
        let laterAct = UIAlertAction(title: loc(.later_btn), style: .cancel, handler: nil)
        
        if hasUpdate {
            controller.addAction(laterAct)
            controller.addAction(updateAct)
        } else {
            controller.addAction(okAct)
        }
        
        controller.dismissTopAlert()
        controller.presentOnMostTop()
    }
    
    static func basicAlert(title: String?, message: String?, onVC vc: UIViewController) {        
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAct = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        controller.addAction(okAct)
        
        vc.present(controller, animated: true, completion: nil)
    }
    
    static func cantUpdateAppIcon(onVC vc: UIViewController) {
        let title = loc(.unableToChangeIcon_title)
        let message = loc(.unableToChangeIcon_message)
        
        Self.basicAlert(title: title, message: message, onVC: vc)
    }
}
