//
//  CoronaCountryDetailVC.swift
//  CoronaCases
//
//  Created by SwiftiSwift on 20.03.20.
//  Copyright © 2020 SwiftiSwift. All rights reserved.
//

import UIKit

class CoronaCountryDetailVC: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var countryLbl: UILabel!
    @IBOutlet weak var confirmedCasesStatisticsLbl: UILabel!
    @IBOutlet weak var totalDeathStatisticsLbl: UILabel!
    @IBOutlet weak var totalRecoveredStatisticsLbl: UILabel!
    @IBOutlet weak var todayCasesStatisticsLbl: UILabel!
    @IBOutlet weak var todayDeathsStatisticsLbl: UILabel!
    @IBOutlet weak var criticalCasesStatisticsLbl: UILabel!
    @IBOutlet weak var lastUpdateLbl: UILabel!
    @IBOutlet weak var todayCasesLbl: UILabel!
    @IBOutlet weak var todayDeathsLbl: UILabel!
    @IBOutlet weak var changeFetchTimeControl: UISegmentedControl!
    @IBOutlet weak var reloadIndicator: UIActivityIndicatorView!
    
    // MARK: - Variables
    var country: Country!
    var selectedSegment: Int!
    var fetchForYesterday: Bool {
        get {
            selectedSegment == 1 ? true : false
        }
    }
    
    var reverseOnFailure = false

    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        title = loc(.covid_19_statistics_for)
        navigationItem.largeTitleDisplayMode = .never
        
        configureLbls()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        changeFetchTimeControl.selectedSegmentIndex = selectedSegment
        getCountryData()
        NotificationCenter.default.addObserver(self, selector: #selector(self.enteredAppAgain), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    @objc
    func enteredAppAgain() {
        self.reverseOnFailure = false
        self.getCountryData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    // MARK: - Configuring
    func configureLbls() {
        let localizedCountryName = country.getLocalizedCountryName
        self.countryLbl.text = localizedCountryName == nil ? loc(.world_name) : localizedCountryName
        self.confirmedCasesStatisticsLbl.text = country.cases?.thousandSeparator() ?? loc(.noData)
        self.totalDeathStatisticsLbl.text = country.deaths?.thousandSeparator() ?? loc(.noData)
        self.totalRecoveredStatisticsLbl.text = country.recovered?.thousandSeparator() ?? loc(.noData)
        self.todayCasesStatisticsLbl.text = country.todayCases?.thousandSeparator() ?? loc(.noData)
        self.todayDeathsStatisticsLbl.text = country.todayDeaths?.thousandSeparator() ?? loc(.noData)
        self.criticalCasesStatisticsLbl.text = country.critical?.thousandSeparator() ?? loc(.noData)
        
        self.todayCasesLbl.text = fetchForYesterday ? loc(.casesYesterday) : loc(.casesToday)
        self.todayDeathsLbl.text = fetchForYesterday ? loc(.deathsYesterday) : loc(.deathsToday)

        let latestDate = country.getUpdatedDate?.getString(monthInText: true) ?? Date().getString(monthInText: true)
        self.lastUpdateLbl.text = loc(.lastUpdate) + (fetchForYesterday ? loc(.yesterday) : latestDate)
    }
    
    @IBAction func changedFetchTime(_ sender: UISegmentedControl) {
        self.selectedSegment = sender.selectedSegmentIndex

        getCountryData()
    }
}

// MARK: - API Requests
extension CoronaCountryDetailVC {
    
    @objc
    func getCountryData() {
        APIService.instance.stopCurrentRequest()
        self.reloadIndicator.startAnimating()
        print("REQUEST GetCountry")
        guard let countryName = country.country else {
            getWorld()
            return
        }
        
        APIService.instance.getCountry(forName: countryName, forYesterday: fetchForYesterday) { [weak self] (result) in
            guard let self = self else { return }

            DispatchQueue.main.async {
                self.reloadIndicator.stopAnimating()

                switch result {
                case .success(let country):
                    self.country = country
                    
                    self.reverseOnFailure = true
                    self.configureLbls()
                    print("GOT GetCountry")
                case .failure(let error):
                    self.handleError(error)
                }
            }
        }
    }
    
    func reverseSegment() {
        guard reverseOnFailure else { return }
        let reversed = self.changeFetchTimeControl.selectedSegmentIndex == 1 ? 0 : 1
        self.selectedSegment = reversed
        self.changeFetchTimeControl.selectedSegmentIndex = reversed
    }
    
    func getWorld() {
        self.reloadIndicator.startAnimating()

        APIService.instance.getWorld(yesterday: fetchForYesterday) { [weak self] (result) in
            guard let self = self else { return }

            DispatchQueue.main.async {
                self.reloadIndicator.stopAnimating()

                switch result {
                case .success(let world):
                    self.country = world
                    
                    self.reverseOnFailure = true
                    self.configureLbls()
                    print("GOT WORLD GetCountry")
                case .failure(let error):
                    self.handleError(error)
                }
            }
        }
    }
    
    func handleError(_ error: APIError) {
        if error == .unknown || error == .apiNotAvailable {
            guard let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate else { return }
            sceneDelegate.checkForUpdate(showPopupWhenUpToDate: false)
        }
        Alert.showReload(forError: error, onVC: self,
                         cancelTapped: self.reverseSegment,
                         reloadTapped: self.getCountryData)
    }
}
