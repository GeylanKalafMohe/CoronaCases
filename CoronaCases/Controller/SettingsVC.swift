//
//  SettingsVC.swift
//  CoronaCases
//
//  Created by SwiftiSwift on 21.03.20.
//  Copyright © 2020 SwiftiSwift. All rights reserved.
//

import UIKit

class SettingsVC: UITableViewController {

    // MARK: - Outlets
    @IBOutlet weak var appNameLbl: UILabel!
    @IBOutlet weak var versionNumberLbl: UILabel!
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        appNameLbl.text = DeviceInfo.appName
        versionNumberLbl.text = DeviceInfo.appVersion
    }

    // MARK: - IBAction
    @IBAction func checkForUpdateBtn(_ sender: UIButton) {
        checkForUpdate()
    }
    
    func checkForUpdate() {
        APIService.instance.checkForUpdate { (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let hasUpdate):
                    Alert.showUpdate(hasUpdate: hasUpdate, onVC: self)
                case .failure(let error):
                    Alert.showReload(forError: error, onVC: self, function: self.checkForUpdate)
                }
            }
        }
    }
}
