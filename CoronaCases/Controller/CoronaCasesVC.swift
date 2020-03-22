//
//  CoronaCasesVC.swift
//  CoronaCases
//
//  Created by SwiftiSwift on 19.03.20.
//  Copyright © 2020 SwiftiSwift. All rights reserved.
//

import UIKit
import IHKeyboardAvoiding

class CoronaCasesVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let coronaDetailCellID = String(describing: CoronaStatisticsDetailCell.self)
    let coronaCellID = String(describing: CoronaStatisticsCell.self)
    var refreshControl: UIRefreshControl!
    
    var countries: [Country] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    var lastRefresh: Date? {
        didSet {
            self.setLastUpdatedDateLbl()
        }
    }
        
    var countrySections: [SectionData] {
        let sec2 = SectionData(title: "Current infections by countries", data: self.countries)

        guard let currentCountryName = Locale.current.countryNameInEnglish else { return [sec2] }
        guard let localCountryData = self.countries.first(where: { $0.country == currentCountryName }) else { return [sec2] }
        
        let sec1 = SectionData(title: "Your country", data: [localCountryData])
        
        return [sec1, sec2]
    }
    
    lazy var searchedCountry: SectionData? = nil
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "COVID-19 Cases"
        navigationController?.navigationBar.prefersLargeTitles = true
        addRefresh()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.refreshControl = refreshControl

        addSearchBar()
        NotificationCenter.default.addObserver(self, selector: #selector(makeBecomeActiveNotif), name: UIApplication.didEnterBackgroundNotification, object: nil)
        KeyboardAvoiding.avoidingView = self.tableView
    }

    
    @objc
    func makeBecomeActiveNotif() {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(self.getAllCountries), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        refreshControl.beginRefreshing()
        getAllCountries()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    func addSearchBar() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.obscuresBackgroundDuringPresentation = false;
        navigationItem.searchController = searchController
    }
    
    func addRefresh() {
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(getAllCountries), for: .valueChanged)
    }
    
    func setLastUpdatedDateLbl() {
        self.navigationItem.searchController?.searchBar.placeholder = "Last Update: " + self.lastRefresh!.getDateAndHour()
    }
}

extension CoronaCasesVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard searchText != "" else { endSearch(); return }
        let searchTextLowercased = searchText.lowercased()
        
        let searchedCountryData = self.countries.filter { $0.country.lowercased().hasPrefix(searchTextLowercased) }
        
        self.searchedCountry = SectionData(title: "Search Results", data: searchedCountryData)
        
        tableView.reloadData()
        scrollToTop()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        endSearch()
    }
    
    func scrollToTop() {
        guard (searchedCountry?.data.count ?? 0) > 0 else { return }
        let firstIndex = IndexPath(row: 0, section: 0)
        tableView.scrollToRow(at: firstIndex, at: .top, animated: true)
    }
    
    func endSearch() {
        scrollToTop()
        self.searchedCountry = nil; tableView.reloadData();
    }
}


extension CoronaCasesVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        searchedCountry == nil ? countrySections[section].numberOfItems : searchedCountry!.numberOfItems
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        searchedCountry == nil ? countrySections.count : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if !((indexPath.section == 0 && countrySections.count == 1) || (indexPath.section == 1 && countrySections.count > 1) || searchedCountry != nil) {
            
            if let detailCell = tableView.dequeueReusableCell(withIdentifier: coronaDetailCellID, for: indexPath) as? CoronaStatisticsDetailCell {
                
                let currentCountry = searchedCountry == nil ? countrySections[indexPath.section][indexPath.row] : searchedCountry![indexPath.row]
                detailCell.configure(country: currentCountry)
                
                return detailCell
            }
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: coronaCellID, for: indexPath) as? CoronaStatisticsCell else { return UITableViewCell() }

        let currentCountry = searchedCountry == nil ? countrySections[indexPath.section][indexPath.row] : searchedCountry![indexPath.row]
        cell.configure(country: currentCountry)

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard (indexPath.section == 0 && countrySections.count == 1) || (indexPath.section == 1 && countrySections.count > 1) || searchedCountry != nil else { return 270 }
        return 150
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return searchedCountry == nil ? countrySections[section].title : searchedCountry!.title
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let lbl = UILabel()
        lbl.text = searchedCountry == nil ? countrySections[section].title : searchedCountry!.title
        lbl.font = UIFont(name: "Menlo-Regular", size: 15)
        lbl.textAlignment = .left
        lbl.textColor = .systemGray
        return lbl
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard (indexPath.section == 0 && countrySections.count == 1) || (indexPath.section == 1 && countrySections.count > 1) || searchedCountry != nil else { return }
        let selectedCountry = searchedCountry == nil ? countrySections[indexPath.section][indexPath.row] : searchedCountry![indexPath.row]
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "CoronaCountryDetailVC") as? CoronaCountryDetailVC else { return }
        
        vc.country = selectedCountry
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension CoronaCasesVC {
    @objc
    func getAllCountries() {
        print("REQUEST")
        APIService.instance.getAllCountries { [weak self] (result) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()

                switch result {
                case .success(let countries):
                    self.countries = countries
                    self.lastRefresh = Date()
                case .failure(let error):
                    Alert.showReload(forError: error, onVC: self, function: self.getAllCountries)
                }
            }
        }
    }
}

struct SectionData {
    let title: String
    let data : [Country]

    var numberOfItems: Int {
        return data.count
    }

    subscript(index: Int) -> Country {
        return data[index]
    }
}

extension SectionData {
    //  Putting a new init method here means we can
    //  keep the original, memberwise initaliser.
    init(title: String, data: Country...) {
        self.title = title
        self.data  = data
    }
}
