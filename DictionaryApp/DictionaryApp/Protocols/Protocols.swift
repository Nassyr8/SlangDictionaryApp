//
//  Protocols.swift
//  DictionaryApp
//
//  Created by Nassyrkhan Seitzhapparuly on 7/11/19.
//  Copyright © 2019 Nassyrkhan Seitzhapparuly. All rights reserved.
//

import Foundation

protocol LoaderPresentable {
    func showLoader()
    func hideLoader()
}

protocol AlertPresentable {
    func showAlert(message: String)
}

protocol DateConvertable {
    func convertToDate(date: String) -> String
}

protocol SearchViewModelDelegate: class {
    func updateData()
}

protocol DataReloadDelegate: class {
    func updateData()
}

protocol SearchSlangDelegate: class {
    func searchSlangFromHistory(word: String)
}

