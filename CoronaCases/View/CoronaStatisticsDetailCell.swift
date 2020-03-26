
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        preservesSuperviewLayoutMargins = false
        separatorInset = UIEdgeInsets.zero
        layoutMargins = UIEdgeInsets.zero
    }
    
    func configure(country: Country) {
        self.countryLbl.text = country.country
        self.confirmedCasesStatisticLbl.text = country.cases?.thousandSeparator() ?? "No Data"
        self.totalDeathsStatisticLbl.text = country.deaths?.thousandSeparator() ?? "No Data"
        self.totalRecoveredStatisticLbl.text = country.recovered?.thousandSeparator() ?? "No Data"
        self.todayCasesStatisticLbl.text = country.todayCases?.thousandSeparator() ?? "No Data"
        self.todayDeathsStatisticLbl.text = country.todayDeaths?.thousandSeparator() ?? "No Data"
        self.criticalCasesStatisticLbl.text = country.critical?.thousandSeparator() ?? "No Data"
    }
}
