//
//  SavedVC.swift
//  DictionaryApp
//
//  Created by Nassyrkhan Seitzhapparuly on 7/11/19.
//  Copyright © 2019 Nassyrkhan Seitzhapparuly. All rights reserved.
//

import UIKit
import SnapKit

class SavedVC: UIViewController {

    var tableView = UITableView()
    private let customReuseIdentifier = "customTableCell"
    let searchController = UISearchController(searchResultsController: nil)
    var arrayOfSlangs: [Slang] = []
    var filteredArrayOfSlangs: [Slang] = []
    var isSearching = false
    var searchedText = String()
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: UIControl.Event.valueChanged)
        refreshControl.tintColor = .lightGray
        
        return refreshControl
    }()    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        navigationItem.title = "Saved"
        
        fetchSlangs()
        setupSearchBar()
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onDidReceiveData), name: .didCompleteTask, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onDidReceiveDeleteTask), name: .didCompleteDeleteTask, object: nil)
    }
    
    private func setupSearchBar() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchBar.delegate = self
        searchController.searchBar.showsCancelButton = false        
    }
    
    private func setupViews() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.addSubview(refreshControl)
        tableView.register(CustomTableCell.self, forCellReuseIdentifier: customReuseIdentifier)
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    @objc private func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.arrayOfSlangs.removeAll()
        self.fetchSlangs()
        DispatchQueue.main.async {
            self.refreshControl.endRefreshing()
        }
    }
    
    @objc private func onDidReceiveData(notification: Notification) {
        fetchSlangs()
    }
    
    @objc private func onDidReceiveDeleteTask(notification: Notification) {
        fetchSlangs()
    }
    
    private func fetchSlangs() {
        arrayOfSlangs.removeAll()
        guard let managedContext = self.managedContext else { return }
        
        let fetchRequest = Slang.fetchSlangRequest()
        
        do {
            self.arrayOfSlangs = try managedContext.fetch(fetchRequest)
            tableView.reloadData()
        } catch {
            print("Fetching slangs error:", error.localizedDescription)
        }
    }
    
}

extension SavedVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil || searchBar.text == "" {
            searchedText = ""
            isSearching = false
            view.endEditing(true)
            self.tableView.reloadData()
        }else{
            searchedText = searchText
            isSearching = true
            filteredArrayOfSlangs = arrayOfSlangs.filter({( slang : Slang) -> Bool in
                return (slang.word)!.lowercased().contains(searchText.lowercased())
            })
            self.tableView.reloadData()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {        
        searchController.searchBar.text = searchedText
        isSearching = false        
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        searchController.searchBar.text = searchedText
        self.searchController.dismiss(animated: true)
        
        return true
    }
    
}

extension SavedVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching ? filteredArrayOfSlangs.count : arrayOfSlangs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: customReuseIdentifier, for: indexPath) as! CustomTableCell
        let slangg = isSearching ? filteredArrayOfSlangs[indexPath.row] : arrayOfSlangs[indexPath.row]
        cell.wordLabel.text = slangg.word
        cell.definitionLabel.text = slangg.definition
        
        return cell
    }
}

extension SavedVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = DetailedVC()
        vc.title = arrayOfSlangs[indexPath.row].word
        vc.slangFromSaved = arrayOfSlangs[indexPath.row]
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension SavedVC: DataReloadDelegate {
    
    func updateData() {
        fetchSlangs()        
    }
    
}
