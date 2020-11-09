//
//  DetailedVC.swift
//  DictionaryApp
//
//  Created by Nassyrkhan Seitzhapparuly on 7/13/19.
//  Copyright © 2019 Nassyrkhan Seitzhapparuly. All rights reserved.
//

import UIKit
import CoreData

class DetailedVC: UIViewController, DateConvertable {
    
    let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.showsHorizontalScrollIndicator = false
        view.showsVerticalScrollIndicator = false
        view.backgroundColor = .white
        
        return view
    }()
    
    let definitionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        
        return label
    }()
    
    let authorLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        
        return label
    }()
    
    let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20)
        label.numberOfLines = 0
        label.textColor = .lightGray
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .right
        
        return label
    }()
    
    let bookmarkButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named:"addToBookmark"), for: .normal)
        
        return button
    }()
    
    var arrayOfSlangs: [Slang] = []
    var isAdded = false
    var dataReloadDelegate: DataReloadDelegate?
    
    var newSlangDictionary: SlangDictionary?
    
    var slang: SlangDictionary? {
        didSet {
            if let word = slang {
                definitionLabel.text = word.definition
                authorLabel.text = word.author
                dateLabel.text = convertToDate(date: word.date)                                
            }
        }
    }
    
    var slangFromSaved: Slang? {
        didSet {
            if let word = slangFromSaved {
                definitionLabel.text = word.definition
                authorLabel.text = word.author
                dateLabel.text = convertToDate(date: word.date ?? "")
                
                newSlangDictionary = SlangDictionary(id: word.id, definition: word.definition ?? "", author: word.author ?? "", word: word.word ?? "", date: word.date ?? "")
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        fetchSlangs()
        setupNavigationBar()
        setupViews()
        
    }
    
    private func setupNavigationBar() {
        let backButton = UIBarButtonItem()
        backButton.title = ""
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        
        if isAdded {
            bookmarkButton.setImage(UIImage(named:"addToBookmark-filled"), for: .normal)
            bookmarkButton.addTarget(self, action: #selector(addBookmarkPressed), for: .touchUpInside)
        } else {
            bookmarkButton.setImage(UIImage(named:"addToBookmark"), for: .normal)
            bookmarkButton.addTarget(self, action: #selector(addBookmarkPressed), for: .touchUpInside)
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: bookmarkButton)
    }
    
    private func setupViews() {
        view.backgroundColor = .white
        
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        scrollView.addSubview(definitionLabel)
        scrollView.addSubview(authorLabel)
        scrollView.addSubview(dateLabel)
        
        definitionLabel.snp.makeConstraints { (make) in
            make.top.equalTo(scrollView).offset(20)
            make.leading.equalTo(view.snp.leading).offset(20)
            make.trailing.equalTo(view.snp.trailing).offset(-20)
        }
        
        authorLabel.snp.makeConstraints { (make) in
            make.top.equalTo(definitionLabel.snp.bottom).offset(20)
            make.leading.equalTo(scrollView).offset(20)
            make.bottom.equalTo(scrollView).offset(-20)
        }
        
        dateLabel.snp.makeConstraints { (make) in
            make.top.equalTo(definitionLabel.snp.bottom).offset(20)
            make.leading.equalTo(authorLabel.snp.trailing).offset(10)
            make.trailing.equalTo(view.snp.trailing).offset(-20)
            make.bottom.equalTo(scrollView.snp.bottom).offset(-20)
        }
        
    }
    
    private func fetchSlangs() {
        guard let managedContext = self.managedContext else { return }
        
        let fetchRequest = Slang.fetchSlangRequest()

        
        do {
            self.arrayOfSlangs = try managedContext.fetch(fetchRequest)
        } catch {
            print("Fetching slangs error:", error.localizedDescription)
        }

        if !arrayOfSlangs.isEmpty {
            if let slDiction = slang {
                arrayOfSlangs.forEach { (word) in
                    if word.id == slDiction.id {
                        isAdded = true
                    }
                }
            }
            if let slSaved = slangFromSaved {
                arrayOfSlangs.forEach { (word) in
                    if word.id == slSaved.id {
                        isAdded = true
                    }
                }
            }
        }
    }
    
    private func getNewSlang() {
        if let slFromSaved = slangFromSaved {
            newSlangDictionary = SlangDictionary(id: slFromSaved.id, definition: slFromSaved.definition ?? "", author: slFromSaved.author ?? "", word: slFromSaved.word ?? "", date: slFromSaved.date ?? "")
        }
    }
    
    @objc private func addBookmarkPressed(sender: UIButton) {
        let alert = UIAlertController(title: "", message: nil, preferredStyle: .alert)
        
        guard let managedContext = self.managedContext else { return }
        let fetchRequest = Slang.fetchSlangRequest()
        
        let newSlang = Slang(context: managedContext)
        
        if let currentSlangDictionaryElement = slang {
            newSlang.word = currentSlangDictionaryElement.word
            newSlang.author = currentSlangDictionaryElement.author
            newSlang.definition = currentSlangDictionaryElement.definition
            newSlang.date = currentSlangDictionaryElement.date
            newSlang.id = currentSlangDictionaryElement.id
        } else if let _ = slangFromSaved {
            if let slangDiction = newSlangDictionary {
                newSlang.word = slangDiction.word
                newSlang.author = slangDiction.author
                newSlang.definition = slangDiction.definition
                newSlang.date = slangDiction.date
                newSlang.id = slangDiction.id
            }
        }
                
        if isAdded {
            alert.title = "Remove Item?"
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { [weak self] (_) in
                if let currSlang = self?.slang {
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
                }
                if let currSlang = self?.slangFromSaved {
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
                }
                
                do {
                    try managedContext.save()
                    self?.dataReloadDelegate?.updateData()
                    NotificationCenter.default.post(name: .didCompleteTask, object: nil)
                } catch let error {
                    print("Saving Error:", error.localizedDescription)
                }
                self?.bookmarkButton.setImage(UIImage(named:"addToBookmark"), for: .normal)
                self?.isAdded = false
            }))
        } else {
            alert.title = "Add Item?"
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { [weak self] (_) in
                do {
                    try managedContext.save()
                    self?.dataReloadDelegate?.updateData()
                    NotificationCenter.default.post(name: .didCompleteTask, object: nil)
                } catch let error {
                    print("Saving Error:", error.localizedDescription)
                }
                self?.bookmarkButton.setImage(UIImage(named:"addToBookmark-filled"), for: .normal)
                self?.isAdded = true
            }))
        }
        
        present(alert, animated: true)
    }
    
}
