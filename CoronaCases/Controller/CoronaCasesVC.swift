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
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var changeFetchTimeSegmentControl: UISegmentedControl!
    
    // MARK: - Variables
    let coronaDetailCellID = String(describing: CoronaStatisticsDetailCell.self)
    let coronaCellID = String(describing: CoronaStatisticsCell.self)
    var refreshControl: UIRefreshControl!
    
    var countriesSortedBy: SortType = .confirmedCases
    lazy var searchedCountries: SectionData? = nil
    var expandedCountry: Country? = nil
    
    var countries: [Country] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }
        
    var countrySections: [SectionData] {
        let sec2 = SectionData(title: loc(.current_infections_by_countries),
                               data: self.countries.sort(by: countriesSortedBy))

        guard let countryCode = Locale.current.countryCode else { return [sec2] }

        let localCountryData = self.countries.first(where: { $0.countryInfo?.iso2 == countryCode })
        
        let sec1 = SectionData(title: loc(.yourCountry), data: localCountryData == nil ? [] : [localCountryData!])
        
        return [sec1, sec2]
    }
    
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = loc(.covid_19_cases)
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.searchController?.searchBar.placeholder = loc(.search)

        addRefresh()
        setupTableView()
        
        tabBarController?.delegate = self
        addSearchBar()
        KeyboardAvoiding.avoidingView = self.tableView
        tableView.estimatedRowHeight = 150
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(makeBecomeActiveNotif), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshCountries), name: Notification.Name.ERROR_SEARCHING_UPDATE_RELOAD_TAPPED, object: nil)
        
        getAllCountries(forYesterday: changeFetchTimeSegmentControl.selectedSegmentIndex == 1 ? true : false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
        self.refreshControl.endRefreshing()
    }

    @objc
    func makeBecomeActiveNotif() {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshCountries), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    // MARK: - Setup
    func addSearchBar() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.obscuresBackgroundDuringPresentation = false;
        navigationItem.searchController = searchController
    }
}

// MARK: - TableView
extension CoronaCasesVC: UITableViewDelegate, UITableViewDataSource {
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.refreshControl = refreshControl
    }
    
    func addRefresh() {
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshCountries), for: .valueChanged)
    }
    
    @objc
    func refreshCountries() {
        self.changeFetchTimeSegmentControl.selectedSegmentIndex = 0
        self.getAllCountries(forYesterday: false)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        searchedCountries == nil ? countrySections[section].numberOfItems : searchedCountries!.numberOfItems
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        searchedCountries == nil ? countrySections.count : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if !((indexPath.section == 0 && countrySections.count == 1) || (indexPath.section == 1 && countrySections.count > 1) || searchedCountries != nil) {
            
            if let detailCell = tableView.dequeueReusableCell(withIdentifier: coronaDetailCellID, for: indexPath) as? CoronaStatisticsDetailCell {
                
                let currentCountry = searchedCountries == nil ? countrySections[indexPath.section][indexPath.row] : searchedCountries![indexPath.row]
                detailCell.configure(country: currentCountry)
                detailCell.isUserInteractionEnabled = false
                return detailCell
            }
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: coronaCellID, for: indexPath) as? CoronaStatisticsCell else { return UITableViewCell() }

        let currentCountry = searchedCountries == nil ? countrySections[indexPath.section][indexPath.row] : searchedCountries![indexPath.row]
        cell.configure(country: currentCountry)

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard (indexPath.section == 0 && countrySections.count == 1) || (indexPath.section == 1 && countrySections.count > 1) || searchedCountries != nil else { return }
        
        let selectedCountry = searchedCountries == nil ? countrySections[indexPath.section][indexPath.row] : searchedCountries![indexPath.row]
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vcID = String(describing: CoronaCountryDetailVC.self)
        guard let vc = storyboard.instantiateViewController(withIdentifier: vcID) as? CoronaCountryDetailVC else { return }
        
        vc.country = selectedCountry
        vc.selectedSegment = changeFetchTimeSegmentControl.selectedSegmentIndex
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard (indexPath.section == 0 && countrySections.count == 1) || (indexPath.section == 1 && countrySections.count > 1) || searchedCountries != nil else { return 270 }
        return 150
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return searchedCountries == nil ? countrySections[section].title : searchedCountries!.title
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        countries.first?.getUpdatedDate?.getString()
    }
    
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textAlignment = NSTextAlignment.right
        
        let yesterdaySelected = changeFetchTimeSegmentControl.selectedSegmentIndex == 1 ? true : false

        let latestUpdate = self.countries.first?.getUpdatedDate?.getString() ?? Date().getString()
        header.textLabel?.text = loc(.lastUpdate) + (yesterdaySelected ? loc(.yesterday) : latestUpdate)
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

// MARK: - SearchBar
extension CoronaCasesVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard searchText != "" else { endSearch(); return }
        let searchTextLowercased = searchText.lowercased()
        
        let searchedCountryData = self.countries.filter { $0.getLocalizedCountryName.lowercased().hasPrefix(searchTextLowercased) }
        
        self.searchedCountries = SectionData(title: loc(.searchResults), data: searchedCountryData)
        
        tableView.reloadData()
        scrollToTop()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        endSearch()
    }
    
    func scrollToTop() {
        guard (searchedCountries?.data.count ?? 0) > 0, tableView.isDragging else { return }
        let firstIndex = IndexPath(row: 0, section: 0)
        tableView.scrollToRow(at: firstIndex, at: .top, animated: true)
    }
    
    func endSearch() {
        scrollToTop()
        searchedCountries = nil
        tableView.reloadData();
    }
}

// MARK: - TabBar Setup
extension CoronaCasesVC: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        guard tableView.visibleCells.count > 0 else { return }
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.scrollToRow(at: indexPath, at: .top, animated: true)
    }
}

// MARK: - API Requests
extension CoronaCasesVC {
    
    @objc
    func getAllCountries(forYesterday yesterday: Bool) {
        print("REQUEST GetAllCountries")
        self.refreshControl.beginRefreshing()

        APIService.instance.getAllCountries(yesterday: yesterday) { [weak self] (result) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()

                switch result {
                case .success(let countries):
                    self.countries = countries

                    print("GOT Countries")
                case .failure(let error):
                    self.countries.removeAll()
                    guard self.presentedViewController == nil else { return }
                    if error == .unknown {
                        guard let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate else { return }
                        sceneDelegate.checkForUpdate(showPopupWhenUpToDate: false)
                    }
                    Alert.showReload(forError: error, onVC: self, function: { self.getAllCountries(forYesterday: yesterday) })
                }
            }
        }
    }
    
    @IBAction func changedFetchTime(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            getAllCountries(forYesterday: false)
        case 1:
            getAllCountries(forYesterday: true)
        default:
            getAllCountries(forYesterday: false)
        }
    }
}

extension CoronaCasesVC {
    @IBAction func sortByButtonTapped(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "SortByVC") as? SortByVC else { return }
        vc.countriesSortBy = self.countriesSortedBy
        vc.countriesSortByDelegate = self

        // If is macOS
        #if targetEnvironment(macCatalyst)
            vc.preferredContentSize = .init(width: 350, height: 260)
            vc.modalPresentationStyle = .popover
            let presentationController = vc.popoverPresentationController
            presentationController?.barButtonItem = self.navigationItem.leftBarButtonItem
            presentationController?.sourceView = self.view
            presentationController?.sourceRect = self.view.bounds
        #else
            vc.modalPresentationStyle = .overFullScreen
            vc.modalTransitionStyle = .crossDissolve
        #endif
        
        self.present(vc, animated: true, completion: nil)
    }
}

extension CoronaCasesVC: CountriesSortByDelegate {
    func selectedNewSorting(_ sortType: SortType) {
        guard countriesSortedBy != sortType else { return }
        self.countriesSortedBy = sortType
        animateTableViewReload(completion: nil)
    }
    
    func animateTableViewReload(duration: TimeInterval = 0.5, options: UIView.AnimationOptions = .transitionCrossDissolve, completion: ((Bool) -> ())?) {
        UIView.transition(with: tableView, duration: duration, options: options, animations: {self.tableView.reloadData()}, completion: completion)
    }
}
