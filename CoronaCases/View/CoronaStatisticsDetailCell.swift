
//
//  CoronaStatisticsDetailCell.swift
//  CoronaCases
//
//  Created by SwiftiSwift on 22.03.20.
//  Copyright © 2020 SwiftiSwift. All rights reserved.
//

import UIKit

class CoronaStatisticsDetailCell: UITableViewCell {

    @IBOutlet weak var countryLbl: UILabel!
    @IBOutlet weak var confirmedCasesStatisticLbl: UILabel!
    @IBOutlet weak var totalDeathsStatisticLbl: UILabel!
    @IBOutlet weak var totalRecoveredStatisticLbl: UILabel!
    @IBOutlet weak var todayCasesStatisticLbl: UILabel!
    @IBOutlet weak var todayDeathsStatisticLbl: UILabel!
    @IBOutlet weak var criticalCasesStatisticLbl: UILabel!
    @IBOutlet weak var topSV: UIStackView!
    @IBOutlet weak var bottomSV: UIStackView!
    @IBOutlet weak var todayCasesLbl: UILabel!
    @IBOutlet weak var todayDeathsLbl: UILabel!
    
    func configure(country: Country, yesterday: Bool) {
        self.todayCasesLbl.text = yesterday ? loc(.casesYesterday) : loc(.casesToday)
        self.todayDeathsLbl.text = yesterday ? loc(.deathsYesterday) : loc(.deathsToday)
        
        let localizedCountryName = country.getLocalizedCountryName
        self.countryLbl.text = localizedCountryName == nil ? loc(.world_name) : localizedCountryName
        self.confirmedCasesStatisticLbl.text = country.cases?.thousandSeparator() ?? loc(.noData)
        self.totalDeathsStatisticLbl.text = country.deaths?.thousandSeparator() ?? loc(.noData)
        self.totalRecoveredStatisticLbl.text = country.recovered?.thousandSeparator() ?? loc(.noData)
        self.todayCasesStatisticLbl.text = country.todayCases?.thousandSeparator() ?? loc(.noData)
        self.todayDeathsStatisticLbl.text = country.todayDeaths?.thousandSeparator() ?? loc(.noData)
        self.criticalCasesStatisticLbl.text = country.critical?.thousandSeparator() ?? loc(.noData)
    }
}
