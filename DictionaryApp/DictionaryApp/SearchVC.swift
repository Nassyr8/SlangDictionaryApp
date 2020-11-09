//
//  SearchVC.swift
//  DictionaryApp
//
//  Created by Nassyrkhan Seitzhapparuly on 7/11/19.
//  Copyright © 2019 Nassyrkhan Seitzhapparuly. All rights reserved.
//

import UIKit
import SnapKit

class SearchVC: UIViewController, AlertPresentable, LoaderPresentable {
    
    var tableView = UITableView()
    private let customReuseIdentifier = "customTableCell"
    var searchViewModel = SearchViewModel()
    let searchController = UISearchController(searchResultsController: nil)
    let historyView = HistoryView()
    var searchedText = String()
    var arrayOfSlangs: [Slang] = []
    var savedSlangIndices: [Int32] = []
    var isAdded = false

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        navigationItem.title = "Search"
        
        fetchSlangs()
        setupSearchBar()
        connectHistoryViewDelegate()
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onDidReceiveData), name: .didCompleteTask, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onDidReceiveDeleteTask), name: .didCompleteDeleteTask, object: nil)
    }
    
    private func connectHistoryViewDelegate() {
        historyView.searchDelegate = self
    }
    
    private func setupSearchBar() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.showsCancelButton = false
    }
    
    private func setupViews() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.register(CustomTableCell.self, forCellReuseIdentifier: customReuseIdentifier)
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    @objc private func onDidReceiveData(notification: Notification) {
        fetchSlangs()
    }
    
    @objc private func onDidReceiveDeleteTask(notification: Notification) {
        fetchSlangs()
    }
    
    @objc private func bookmarkButtonPressed(sender: UIButton) {
        let index = sender.tag
        
        guard let managedContext = self.managedContext else { return }
        let fetchRequest = Slang.fetchSlangRequest()
        
        let currSlang = searchViewModel.getSlang(index: index)
        
        let newSlang = Slang(context: managedContext)
        newSlang.word = currSlang.word
        newSlang.author = currSlang.author
        newSlang.definition = currSlang.definition
        newSlang.date = currSlang.date
        newSlang.id = currSlang.id
        
        if isAdded {
            do {
                let result = try managedContext.fetch(fetchRequest)                
                for (index, _) in result.enumerated() {
                    if result[index].id == currSlang.id {
                        managedContext.delete(result[index])
                    }
                }
            } catch {
                print(error.localizedDescription)
            }
            
            do {
                try managedContext.save()
                fetchSlangs()
                NotificationCenter.default.post(name: .didCompleteTask, object: nil)
                sender.setImage(UIImage(named: "addToBookmark"), for: .normal)
                isAdded = false
            } catch let error {
                print("Saving Error:", error.localizedDescription)
            }
        } else {
            do {
                try managedContext.save()
                sender.setImage(UIImage(named: "addToBookmark-filled"), for: .normal)
                isAdded = true
                fetchSlangs()
                NotificationCenter.default.post(name: .didCompleteTask, object: nil)
            } catch let error {
                print("Saving Error:", error.localizedDescription)
            }
        }
        
    }
    
    func searchSlang(word: String) {
        searchedText = word
        searchController.searchBar.text = searchedText        
        if view.subviews.last?.tag != 97 {
            showLoader()
        }
        self.searchViewModel.searchWord(word: word) { [weak self] (response , error) in
            if let unwrappedError = error {
                self?.hideLoader()
                if unwrappedError.localizedDescription != "cancelled" {
                    self?.showAlert(message: unwrappedError.localizedDescription)
                }
            }
            if let _ = response {
                self?.historyView.removeFromSuperview()
                self?.searchController.dismiss(animated: true)
                self?.tableView.reloadData()
                self?.hideLoader()
            }
        }
    }
    
    private func fetchSlangs() {
        guard let managedContext = self.managedContext else { return }
        
        let fetchRequest = Slang.fetchSlangRequest()
        
        do {
            self.arrayOfSlangs = try managedContext.fetch(fetchRequest)
            self.savedSlangIndices = self.arrayOfSlangs.map { $0.id }
            tableView.reloadData()
        } catch {
            print("Fetching slangs error:", error.localizedDescription)
        }
    }
    
}

extension SearchVC: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text != nil && searchBar.text != "" {
            searchSlang(word: searchText)
        }
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        view.addSubview(historyView)
        
        historyView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        return true
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        searchController.searchBar.text = searchedText
        self.historyView.removeFromSuperview()
        self.searchController.dismiss(animated: true)
        
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchController.searchBar.text = searchedText
    }
    
}

extension SearchVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchViewModel.getCountOfData()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: customReuseIdentifier, for: indexPath) as! CustomTableCell
        
        cell.wordLabel.text = searchViewModel.getData(index: indexPath.row).0
        cell.definitionLabel.text = searchViewModel.getData(index: indexPath.row).1
        
        let slangId: Int32 = searchViewModel.getData(index: indexPath.row).2
        let imageName: String = savedSlangIndices.contains(slangId) ? "addToBookmark-filled" : "addToBookmark"
        
        cell.addToBookmarkButton.setImage(UIImage(named: imageName), for: .normal)
        cell.addToBookmarkButton.tag = indexPath.row
        cell.addToBookmarkButton.addTarget(self, action: #selector(bookmarkButtonPressed), for: .touchUpInside)
        
        return cell
    }
    
}

extension SearchVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = DetailedVC()
        vc.title = searchViewModel.getData(index: indexPath.row).0
        vc.slang = searchViewModel.getSlang(index: indexPath.row)
        vc.dataReloadDelegate = self
        
        var historyList: [String] = []
        if let array = UserDefaults.standard.value(forKey: "historyOfSearch") as? [String] {
            historyList = array
        }
        if !historyList.contains(searchedText) {
            historyList.append(searchedText)
        }
        
        UserDefaults.standard.set(historyList, forKey: "historyOfSearch")
        historyView.fetchHistory()
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
}

extension SearchVC: SearchSlangDelegate {
    
    func searchSlangFromHistory(word: String) {
        searchSlang(word: word)
    }
    
}

extension SearchVC: DataReloadDelegate {
    
    func updateData() {
        fetchSlangs()
    }
    
}
