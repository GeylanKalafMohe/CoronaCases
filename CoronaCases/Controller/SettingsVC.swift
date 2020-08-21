//
//  SettingsVC.swift
//  CoronaCases
//
//  Created by SwiftiSwift on 21.03.20.
//  Copyright © 2020 SwiftiSwift. All rights reserved.
//

import UIKit
import MessageUI

class SettingsVC: UITableViewController, UITabBarControllerDelegate {

    // MARK: - Outlets
    @IBOutlet weak var appNameLbl: UILabel!
    @IBOutlet weak var versionNumberLbl: UILabel!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var newUpdateIndicator: UIImageView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var darkModeSwitch: UISwitch!
    @IBOutlet weak var useDeviceUIStyleInstructions: VerticalAlignLabel!
    @IBOutlet weak var useDeviceUIStyleSwitch: UISwitch!
    
    lazy var vcStyleIsDark = self.traitCollection.userInterfaceStyle == .dark ? true : false

    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        loadingIndicator.hidesWhenStopped = true
        newUpdateIndicator.isHidden = true

        if updateIsAvailable {
            addBadge()
        }
        appNameLbl.text = DeviceInfo.appName
        versionNumberLbl.text = DeviceInfo.appVersion
        changeSwitchesToUDSettings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(addBadge), name: NSNotification.Name.NEW_UPDATE, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(stopLoading), name: NSNotification.Name.ERROR_SEARCHING_UPDATE, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(errorSearchingUpdate_reloadTapped), name: NSNotification.Name.ERROR_SEARCHING_UPDATE_RELOAD_TAPPED, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(stopLoading), name: NSNotification.Name.SUCCESS_SEARCHING_FOR_UPDATE, object: nil)
        
        setSegmentedControlAppIconIndex()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Cell Actions
    
    func viaTwitterTapped() {
        guard let twitterURL = URL(string: developerTwitterURL) else { return }
        UIApplication.shared.open(twitterURL) { (success) in
            guard !success else { return }
            Alert.showReload(forError: .unknown, onVC: self, reloadTapped: self.viaTwitterTapped)
        }
    }
    
    func shareBtnTapped() {
        let text = loc(.share_text) + URLs.GITHUB_README
        let shareSheet = UIActivityViewController(activityItems: [text, UIImage(named: "Light-HomeScreen")], applicationActivities: nil)
        self.present(shareSheet, animated: true, completion: nil)
    }
    
    func checkForUpdateBtnTapped() {
        guard let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate else { return }
        URLSession.shared.invalidateAndCancel()
        loadingIndicator.startAnimating()
        sceneDelegate.checkForUpdate(showPopupWhenUpToDate: true)
    }
    
    @objc
    func addBadge() {
        newUpdateIndicator.isHidden = false
        loadingIndicator.stopAnimating()
    }
    
    @objc
    func stopLoading() {
        loadingIndicator.stopAnimating()
    }
    
    @objc
    func errorSearchingUpdate_reloadTapped() {
        loadingIndicator.startAnimating()
    }
    
    @IBAction func appIconChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            setAlternateIconName(AppIcon.primary)
        case 1:
            setAlternateIconName(AppIcon.second)
        case 2:
            setAlternateIconName(AppIcon.third)
        default:
            print("Segment case not catched")
            break
        }
    }
    
    func setSegmentedControlAppIconIndex() {
        switch UIApplication.shared.alternateIconName {
        case nil:
            segmentedControl.selectedSegmentIndex = 0
        case AppIcon.second.rawValue:
            segmentedControl.selectedSegmentIndex = 1
        case AppIcon.third.rawValue:
            segmentedControl.selectedSegmentIndex = 2
        default:
            print("Error finding error")
            segmentedControl.selectedSegmentIndex = 0
        }
    }
    
    func setAlternateIconName(_ alternateIconName: AppIcon) {
        #if targetEnvironment(macCatalyst)
        Alert.basicAlert(title: loc(.macOS_not_supported_title), message: loc(.macOS_not_supported_message), onVC: self)
            setSegmentedControlAppIconIndex()
            return
        #endif
        
        guard UIApplication.shared.supportsAlternateIcons else {
            Alert.basicAlert(
                title: loc(.platform_not_supported_title),
                message: loc(.platform_not_supported_message),
                onVC: self)
            setSegmentedControlAppIconIndex()
            print("not supporting alternative app icons")
            return
        }
        
        if alternateIconName == AppIcon.primary {
            print("Icon back to Primary")
            UIApplication.shared.setAlternateIconName(nil)
        } else {
            print("Changing Icon to: ", alternateIconName.rawValue)

            DispatchQueue.main.async {
                UIApplication.shared.setAlternateIconName(alternateIconName.rawValue) { error in
                    DispatchQueue.main.async {
                        if let error = error {
                            Alert.cantUpdateAppIcon(onVC: self)
                            print(error.localizedDescription)
                            self.setSegmentedControlAppIconIndex()
                            return
                        }
                    }
                }
            }
        }
    }
}

// MARK: - MailComposer
extension SettingsVC: MFMailComposeViewControllerDelegate {
    func viaEmailTapped() {
        let mailComposer = MFMailComposeViewController()
        mailComposer.mailComposeDelegate = self
        
        //Set to recipients
        mailComposer.setToRecipients([developerEmail])
        
        //Set the subject
        mailComposer.setSubject("Feedback/Support \(loc(.about)) \(DeviceInfo.appName)")

        //Set mail body
        mailComposer.setMessageBody(
        """
            Hey \(loc(.developer)),</br></br>

            Feedback/Support: </br></br>

            App: \(DeviceInfo.appName)</br>
            Version: \(DeviceInfo.appVersion)</br>
            \(DeviceInfo.osName) Version: \(DeviceInfo.osVersion)</br>
            \(loc(.device)): \(DeviceInfo.deviceModel)
        """, isHTML: true)
        
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposer, animated: true, completion: nil)
        } else {
            Alert.basicAlert(title: loc(.nicht_eingerichtet), message: loc(.nicht_eingerichtet_message), onVC: self)
        }
    }
        
    func mailComposeController(_ didFinishWithcontroller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        didFinishWithcontroller.dismiss(animated: true, completion: nil)
    }
}

extension SettingsVC {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath {
        case .init(row: 0, section: 1):
            checkForUpdateBtnTapped()
        case .init(row: 1, section: 2):
            viaTwitterTapped()
        case .init(row: 2, section: 2):
            viaEmailTapped()
        case .init(row: 0, section: 4):
            shareBtnTapped()
        default:
            break
        }
    }
    
    func switchUIStyle(to style: UIUserInterfaceStyle) {
        guard let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate else { return }
        
        sceneDelegate.changeUIStyle(to: style)
    }
    
    func changeSwitchesToUDSettings() {
        let useDeviceUIStyleSwitchOn = UDService.instance.useDeviceUIStyleSwitch
        darkModeSwitch.isOn = UDService.instance.darkModeSwitch
        useDeviceUIStyleSwitch.isOn = useDeviceUIStyleSwitchOn

        darkModeSwitch.isEnabled = !useDeviceUIStyleSwitchOn
    }
    
    @IBAction func darkModeSwitchTapped(_ sender: UISwitch) {
        UDService.instance.darkModeSwitch = sender.isOn
        switchUIStyle(to: sender.isOn ? .dark : .light)
    }
    
    @IBAction func useDeviceUIStyleTapped(_ sender: UISwitch) {
        if sender.isOn {
            UDService.instance.useDeviceUIStyleSwitch = true
            self.darkModeSwitch.isEnabled = false
            switchUIStyle(to: .unspecified)

        } else {
            self.darkModeSwitch.isEnabled = true
            UDService.instance.useDeviceUIStyleSwitch = false
            
            darkModeSwitchTapped(self.darkModeSwitch)
        }
    }
}
