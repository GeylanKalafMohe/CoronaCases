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
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self

        segmentedControl.selectedSegmentIndex = UserDefaults.standard.integer(forKey: UDKeys.appIcon)
        loadingIndicator.hidesWhenStopped = true
        newUpdateIndicator.isHidden = true
        if tabBarItem.badgeValue == "1" { addBadge() }
        appNameLbl.text = DeviceInfo.appName
        versionNumberLbl.text = DeviceInfo.appVersion
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(addBadge), name: NSNotification.Name.NEW_UPDATE, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(stopLoading), name: NSNotification.Name.ERROR_SEARCHING_UPDATE, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(errorSearchingUpdate_reloadTapped), name: NSNotification.Name.ERROR_SEARCHING_UPDATE_RELOAD_TAPPED, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(stopLoading), name: NSNotification.Name.SUCCESS_SEARCHING_FOR_UPDATE, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Cell Actions
    func viaTwitterTapped() {
        showTwitter()
    }
    
    func showTwitter() {
        guard let twitterURL = URL(string: developerTwitterURL) else { return }
        UIApplication.shared.open(twitterURL) { (success) in
            guard !success else { return }
            Alert.showReload(forError: .unkown, onVC: self, function: self.showTwitter)
        }
    }
    
    func viaEmailTapped() {
        showEmailVC()
    }
    
    func shareBtnTapped() {
        let text = "Hey! Check out CoronaCases on GitHub.\nIt is a Coronavirus Tracker for iOS, iPadOS & macOS:\n\n" + URLs.GITHUB_README
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
    
    func setAlternateIconName(_ alternateIconName: AppIcon) {        
        guard UIApplication.shared.supportsAlternateIcons else {
            Alert.basicAlert(title: "macOS not supported", message: "Changing the App Icon is currently not supported on macOS", onVC: self)

            print("not supporting alternative app icons")
            return
        }
        if alternateIconName == AppIcon.primary {
            print("Icon back to Primary")
            UIApplication.shared.setAlternateIconName(nil)
            UserDefaults.standard.set(0, forKey: UDKeys.appIcon)
        } else {
            print("Changing Icon to: ", alternateIconName.rawValue)

            UIApplication.shared.setAlternateIconName(alternateIconName.rawValue) { error in
                if let error = error {
                    Alert.cantUpdateAppIcon(onVC: self)
                    print(error.localizedDescription)
                    return
                }
                
                switch alternateIconName {
                case AppIcon.second:
                    UserDefaults.standard.set(1, forKey: UDKeys.appIcon)
                case AppIcon.third:
                    UserDefaults.standard.set(2, forKey: UDKeys.appIcon)
                default:
                    break
                }
            }
        }
    }
    
}

// MARK: - MailComposer
extension SettingsVC: MFMailComposeViewControllerDelegate {
    func showEmailVC() {
        let mailComposer = MFMailComposeViewController()
        mailComposer.mailComposeDelegate = self
        
        //Set to recipients
        mailComposer.setToRecipients([developerEmail])
        
        //Set the subject
        mailComposer.setSubject("Feedback/Support about \(DeviceInfo.appName)")

        //Set mail body
        mailComposer.setMessageBody(
        """
            Hey Developer,</br></br>

            My Feedback/Support: </br></br>

            App: \(DeviceInfo.appName)</br>
            Version: \(DeviceInfo.appVersion)</br>
            \(DeviceInfo.osName) Version: \(DeviceInfo.osVersion)</br>
            Device: \(DeviceInfo.deviceModel)
        """, isHTML: true)
        
        self.present(mailComposer, animated: true, completion: nil)
    }
        
    func mailComposeController(_ didFinishWithcontroller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        didFinishWithcontroller.dismiss(animated: true, completion: nil)
    }
}

extension SettingsVC {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath {
        case .init(row: 1, section: 1):
            viaTwitterTapped()
        case .init(row: 2, section: 1):
            viaEmailTapped()
        case .init(row: 0, section: 2):
            shareBtnTapped()
        case .init(row: 0, section: 4):
            checkForUpdateBtnTapped()
        default:
            break
        }
    }
}
