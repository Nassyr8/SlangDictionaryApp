//
//  SettingsVC.swift
//  DictionaryApp
//
//  Created by Nassyrkhan Seitzhapparuly on 7/11/19.
//  Copyright © 2019 Nassyrkhan Seitzhapparuly. All rights reserved.
//

import UIKit
import SnapKit
import CoreData

class SettingsVC: UIViewController, LoaderPresentable {
    
    var tableView = UITableView()
    var reuseIdentifier = "customCell"

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        navigationItem.title = "Settings"
        
        setupViews()
    }
    
    private func setupViews() {
        tableView = UITableView(frame: CGRect.zero, style: .grouped)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
}

extension SettingsVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        cell.textLabel?.text = "Clear all caches"
        
        return cell
    }
    
    
}

extension SettingsVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let managedContext = self.managedContext else { return }
        let fetchRequest = Slang.fetchSlangRequest()
        
        let alert = UIAlertController(title: "Clear cache?", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Clear", style: .default, handler: { [weak self] (_) in
            self?.showLoader()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                UserDefaults.standard.removeObject(forKey: "historyOfSearch")
                do {
                    let results = try managedContext.fetch(fetchRequest as! NSFetchRequest<NSFetchRequestResult>)
                    for managedObject in results
                    {
                        let managedObjectData:NSManagedObject = managedObject as! NSManagedObject
                        managedContext.delete(managedObjectData)
                    }
                } catch {
                    self?.hideLoader()
                    print("Clearing all cashes:", error.localizedDescription)
                }
                do {
                    try managedContext.save()
                    NotificationCenter.default.post(name: .didCompleteDeleteTask, object: nil)
                    self?.hideLoader()
                } catch let error {
                    self?.hideLoader()
                    print("Saving Error:", error.localizedDescription)
                }
            })
        }))
        present(alert, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
