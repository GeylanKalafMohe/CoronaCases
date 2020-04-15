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
    
    // MARK: - Variables
    var country: Country!
    var selectedSegment: Int!
    lazy var fetchForYesterday = selectedSegment == 1 ? true : false

    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        title = loc(.covid_19_statistics_for)
        navigationItem.largeTitleDisplayMode = .never
        
        configureLbls()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getCountryData()
        NotificationCenter.default.addObserver(self, selector: #selector(self.getCountryData), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    // MARK: - Configuring
    func configureLbls() {
        let localizedCountryName = country.getLocalizedCountryName
        self.countryLbl.text = localizedCountryName.lowercased() == "world" ? loc(.world_name) + " 🌎" : localizedCountryName
        self.confirmedCasesStatisticsLbl.text = country.cases?.thousandSeparator() ?? loc(.noData)
        self.totalDeathStatisticsLbl.text = country.deaths?.thousandSeparator() ?? loc(.noData)
        self.totalRecoveredStatisticsLbl.text = country.recovered?.thousandSeparator() ?? loc(.noData)
        self.todayCasesStatisticsLbl.text = country.todayCases?.thousandSeparator() ?? loc(.noData)
        self.todayDeathsStatisticsLbl.text = country.todayDeaths?.thousandSeparator() ?? loc(.noData)
        self.criticalCasesStatisticsLbl.text = country.critical?.thousandSeparator() ?? loc(.noData)
        
        let yesterdaySelected = selectedSegment == 1 ? true : false

        let latestDate = country.getUpdatedDate?.getString(monthInText: true) ?? Date().getString(monthInText: true)
        self.lastUpdateLbl.text = loc(.lastUpdate) + (yesterdaySelected ? loc(.yesterday) : latestDate)
    }
}

// MARK: - API Requests
extension CoronaCountryDetailVC {
    
    @objc
    func getCountryData() {
        print("REQUEST GetCountry")
        guard country.getLocalizedCountryName.lowercased() != "world" else { return }
        APIService.instance.getCountry(forName: country.country, forYesterday: fetchForYesterday) { [weak self] (result) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let country):
                    self.country = country

                    self.configureLbls()
                    print("GOT GetCountry")
                case .failure(let error):
                    Alert.showReload(forError: error, onVC: self, function: self.getCountryData)
                }
            }
        }
    }
}
