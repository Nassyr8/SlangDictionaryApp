//
//  HistoryView.swift
//  DictionaryApp
//
//  Created by Nassyrkhan Seitzhapparuly on 7/15/19.
//  Copyright © 2019 Nassyrkhan Seitzhapparuly. All rights reserved.
//

import UIKit
import SnapKit

class HistoryView: UIView {
    
    var tableView = UITableView()    
    var historyList: [String] = []
    private var reuseIdentifier = "customHistoryCell"
    var searchDelegate: SearchSlangDelegate?
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: UIControl.Event.valueChanged)
        refreshControl.tintColor = .lightGray
        
        return refreshControl
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        fetchHistory()
        setupViews()
        
        NotificationCenter.default.addObserver(self, selector: #selector(onDidReceiveDeleteTask), name: .didCompleteDeleteTask, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        backgroundColor = .white
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()        
        tableView.keyboardDismissMode = .onDrag        
        
        addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    func fetchHistory() {
        if let array = UserDefaults.standard.value(forKey: "historyOfSearch") as? [String] {
            historyList = array
            tableView.reloadData()
        }
    }
    
    @objc private func onDidReceiveDeleteTask(notification: Notification) {
        historyList = []
        tableView.reloadData()
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.historyList.removeAll()
        self.fetchHistory()
        DispatchQueue.main.async {
            self.refreshControl.endRefreshing()
        }
    }

}

extension HistoryView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historyList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        cell.textLabel?.text = historyList[indexPath.row]
        
        return cell
    }
}

extension HistoryView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchDelegate?.searchSlangFromHistory(word: historyList[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
