//
//  SearchTableViewController.swift
//  WTestApp
//
//  Created by Alexandre Carvalho on 19/06/2021.
//

import UIKit

class SearchTableViewController: UITableViewController {
    
    var dataSource: [AddressModel] = []

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { dataSource.count }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell.textLabel?.text = dataSource[indexPath.row].postCode
        cell.detailTextLabel?.text = dataSource[indexPath.row].location
        return cell
    }
}
