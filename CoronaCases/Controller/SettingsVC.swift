//
//  SettingsVC.swift
//  CoronaCases
//
//  Created by SwiftiSwift on 21.03.20.
//  Copyright © 2020 SwiftiSwift. All rights reserved.
//

import UIKit

class SettingsVC: UIViewController {

    @IBOutlet weak var appNameLbl: UILabel!
    @IBOutlet weak var versionNumberLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        appNameLbl.text = DeviceInfo.appName
        versionNumberLbl.text = DeviceInfo.appVersion
    }
}
