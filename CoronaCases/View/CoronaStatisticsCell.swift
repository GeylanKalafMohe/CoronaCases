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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        preservesSuperviewLayoutMargins = false
        separatorInset = UIEdgeInsets.zero
        layoutMargins = UIEdgeInsets.zero
    }
    
    func configure(country: Country) {
        let localizedCountryName = country.getLocalizedCountryName
        self.countryLbl.text = localizedCountryName.lowercased() == "world" ? loc(.world_name) : localizedCountryName
        self.confirmedCasesStatisticLbl.text = country.cases?.thousandSeparator() ?? loc(.noData)
        self.totalDeathsStatisticLbl.text = country.deaths?.thousandSeparator() ?? loc(.noData)
        self.totalRecoveredStatisticLbl.text = country.recovered?.thousandSeparator() ?? loc(.noData)
    }
}
