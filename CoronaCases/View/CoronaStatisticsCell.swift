//
//  CoronaStatisticsCell.swift
//  CoronaCases
//
//  Created by SwiftiSwift on 22.03.20.
//  Copyright © 2020 SwiftiSwift. All rights reserved.
//

import UIKit

class CoronaStatisticsCell: UITableViewCell {

    @IBOutlet weak var countryLbl: UILabel!
    @IBOutlet weak var confirmedCasesStatisticLbl: UILabel!
    @IBOutlet weak var totalDeathsStatisticLbl: UILabel!
    @IBOutlet weak var totalRecoveredStatisticLbl: UILabel!

    func configure(country: Country) {
        let localizedCountryName = country.getLocalizedCountryName
        countryLbl.text = localizedCountryName == nil ? loc(.world_name) : localizedCountryName
        confirmedCasesStatisticLbl.text = country.cases?.thousandSeparator() ?? loc(.noData)
        totalDeathsStatisticLbl.text = country.deaths?.thousandSeparator() ?? loc(.noData)
        totalRecoveredStatisticLbl.text = country.recovered?.thousandSeparator() ?? loc(.noData)
    }
}
