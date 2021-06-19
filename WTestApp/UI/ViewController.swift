//
//  ViewController.swift
//  WTestApp
//
//  Created by Alexandre Carvalho on 16/06/2021.
//

import UIKit
import CSVImporter
import CoreData

class ViewController: UIViewController {

    // MARK: - Outlets

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loadingLabel: UILabel!
    
    // MARK: - Properties

    private let searchController: UISearchController = UISearchController(searchResultsController: SearchTableViewController())
    private let manager: Manager = Manager()
    private var addressList: [AddressModel] = []

    // MARK: - Life cycle method

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Códigos Postais"
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController

        getDataFromPersistence()

        if addressList.count > 0 {

            whenIsEndedFetchingData()
        } else {

            downloadCSVData()
        }
    }

    // MARK: - Methods

    private func downloadCSVData() {

        loadingLabel.text = "Loading"
        loadingLabel.isHidden = false
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()

        manager.downloadCSVData { _ in

            let fileManager = FileManager.default
            let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            do {

                let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
                if let path = fileURLs.first?.path {

                    self.parseCSVData(path: path)
                }
            } catch {

                print("Error while enumerating files \(documentsURL.path): \(error.localizedDescription)")
            }
        }
    }

    private func deleteAllData() {

        addressList.removeAll()
        tableView.reloadData()

        let fetchRequest: NSFetchRequest<Address> = Address.fetchRequest()
        do {

            let addresses = try PersistenceRepository.context.fetch(fetchRequest)
            addresses.forEach {

                PersistenceRepository.context.delete($0)
            }
            PersistenceRepository.saveContext()
        } catch let error {
            print("Error deleting core data:", error)
        }
    }

    private func whenIsEndedFetchingData() {

        tableView.reloadData()

        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true

        loadingLabel.isHidden = true
    }

    private func getDataFromPersistence() {

        activityIndicator.startAnimating()
        let fetchRequest: NSFetchRequest<Address> = Address.fetchRequest()
        do {

            let addresses = try PersistenceRepository.context.fetch(fetchRequest)
            addresses.forEach {

                guard let postCode = $0.postCode, let location = $0.location else { return }
                
                addressList.append(AddressModel(postCode: postCode, location: location))
            }
        } catch {
            print("Error fetching data from persistence!")
        }
    }

    private func saveDataToPersistence(list: [AddressModel]) {

        list.forEach {

            let address = Address(context: PersistenceRepository.context)
            address.location = $0.location
            address.postCode = $0.postCode
            address.searchTitle = "\($0.postCode) \($0.location)"
        }
        PersistenceRepository.saveContext()
        print("Data saved to persistence")
    }

    private func parseCSVData(path: String) {

        let teamsDefaultImporter = CSVImporter<AddressModel>(path: path)
        teamsDefaultImporter.startImportingRecords { recordValues -> AddressModel in

            return AddressModel(postCode: "\(recordValues[14])-\(recordValues[15])", location: recordValues[16])

        }.onProgress {

            self.loadingLabel.text = "\($0) lines loaded"
        }.onFinish {

            print($0.count)
            print("----- All the data is loaded! -----")

            self.addressList = $0
            self.addressList.removeFirst()

            self.saveDataToPersistence(list: self.addressList)
            self.whenIsEndedFetchingData()
        }
    }

    private func showErrorAlert() {

        let alertController = UIAlertController(title: "Error", message: "Unable to complete the action", preferredStyle: .alert)

        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            self.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }

    // MARK: - Actions

    @IBAction func didTapDownloadButton(_ sender: Any) {

        if addressList.isEmpty, activityIndicator.isHidden {

            downloadCSVData()
        } else {

            showErrorAlert()
        }
    }
    
    @IBAction func didTapDeleteButton(_ sender: Any) {

        if activityIndicator.isHidden, !addressList.isEmpty {

            let alertController = UIAlertController(title: "Delete Data", message: "Do you want to delete all the data?", preferredStyle: .actionSheet)

            let okAction = UIAlertAction(title: "OK", style: .default) { _ in self.deleteAllData() }
            let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)

            alertController.addAction(okAction)
            alertController.addAction(cancelAction)

            self.present(alertController, animated: true, completion: nil)
        } else {

            showErrorAlert()
        }

    }
}

// MARK: - UITableViewDataSource

extension ViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { addressList.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell.textLabel?.text = addressList[indexPath.row].postCode
        cell.detailTextLabel?.text = addressList[indexPath.row].location
        return cell
    }
}

// MARK: - UISearchBarDelegate

extension ViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if let lastElement = searchText.last, lastElement != " " {
            do {
                let fetchRequest: NSFetchRequest<Address> = Address.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "searchTitle CONTAINS[cd] %@", searchText)
                let fetchedResults = try PersistenceRepository.context.fetch(fetchRequest)

                let searchController = searchController.searchResultsController as? SearchTableViewController
                searchController?.dataSource = []
                fetchedResults.forEach {
                    
                    guard let postCode = $0.postCode, let location = $0.location else { return }

                    searchController?.dataSource.append(AddressModel(postCode: postCode, location: location))
                }
                searchController?.tableView.reloadData()
            }
            catch {
                print ("Fetch has failed", error)
            }
        }
    }
}

// MARK: - FileManager

extension FileManager {
    
    func urls(for directory: FileManager.SearchPathDirectory, skipsHiddenFiles: Bool = true) -> [URL]? {
        let documentsURL = urls(for: directory, in: .userDomainMask)[0]
        let fileURLs = try? contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil, options: skipsHiddenFiles ? .skipsHiddenFiles : [])
        return fileURLs
    }
}
