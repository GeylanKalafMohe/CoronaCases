//
//  CoronaCountryDetailVC.swift
//  CoronaCases
//
//  Created by SwiftiSwift on 20.03.20.
//  Copyright © 2020 SwiftiSwift. All rights reserved.
//

import UIKit

class CoronaCountryDetailVC: UIViewController {
    @IBOutlet weak var countryLbl: UILabel!
    @IBOutlet weak var confirmedCasesStatisticsLbl: UILabel!
    @IBOutlet weak var totalDeathStatisticslbl: UILabel!
    @IBOutlet weak var totalRecoveredStatisticsLbl: UILabel!
    @IBOutlet weak var todayCasesStatisticsLbl: UILabel!
    @IBOutlet weak var todayDeathsStatisticsLbl: UILabel!
    @IBOutlet weak var criticalCasesStatisticsLbl: UILabel!

    var country: Country!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "COVID-19 statistics for"
        navigationItem.largeTitleDisplayMode = .never
        
        configureLbls()
        NotificationCenter.default.addObserver(self, selector: #selector(self.getCountryData), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getCountryData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    func configureLbls() {
        self.countryLbl.text = country.country
        self.confirmedCasesStatisticsLbl.text = country.cases.thousandSeparator()
        self.totalDeathStatisticslbl.text = country.deaths.thousandSeparator()
        self.totalRecoveredStatisticsLbl.text = country.recovered.thousandSeparator()
        self.todayCasesStatisticsLbl.text = country.todayCases.thousandSeparator()
        self.todayDeathsStatisticsLbl.text = country.todayDeaths.thousandSeparator()
        self.criticalCasesStatisticsLbl.text = country.critical.thousandSeparator()
    }
}

extension CoronaCountryDetailVC {
    
    @objc
    func getCountryData() {
        APIService.instance.getCountry(forName: country.country) { [weak self] (result) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let country):
                    self.country = country
                    self.configureLbls()
                case .failure(let error):
                    Alert.showReload(forError: error, onVC: self, function: self.getCountryData)
                }
            }
        }
    }
}
