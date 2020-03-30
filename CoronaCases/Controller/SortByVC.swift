//
//  SortByVC.swift
//  CoronaCases
//
//  Created by SwiftiSwift on 27.03.20.
//  Copyright © 2020 SwiftiSwift. All rights reserved.
//

import UIKit

class SortByVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var countriesSortBy: SortType!
    
    private let cellID = String(describing: UITableViewCell.self)
    weak var countriesSortByDelegate: CountriesSortByDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTap()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        tableView.layer.cornerRadius = 20
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        SortType.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let currentType = SortType.allCases[indexPath.row]
        cell.textLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 16)
        cell.textLabel?.text = currentType.rawValue
        cell.layer.cornerRadius = 20
        cell.layer.masksToBounds = true
        
        if currentType == self.countriesSortBy {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.countriesSortBy = SortType.allCases[indexPath.row]

        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadData()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.countriesSortByDelegate?.selectedNewSorting(self.countriesSortBy)

            self.dismissScreen()
        }
    }
}

extension SortByVC: UIGestureRecognizerDelegate {
    // MARK: UIGestureRecognizerDelegate methods
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view?.isDescendant(of: tableView!.superview!) == true {
            return false
        }
        return true
    }
    
    func setupTap() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissScreen))
        tap.delegate = self
        tap.numberOfTouchesRequired = 1
        self.view.addGestureRecognizer(tap)
    }
    
    @objc
    func dismissScreen() {
        dismiss(animated: true, completion: nil)
    }
}
