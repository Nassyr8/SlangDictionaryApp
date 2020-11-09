//
//  SearchViewModel.swift
//  DictionaryApp
//
//  Created by Nassyrkhan Seitzhapparuly on 7/11/19.
//  Copyright © 2019 Nassyrkhan Seitzhapparuly. All rights reserved.
//

import UIKit
import Alamofire

class SearchViewModel {
    
    private let service = AlamofireAPIService()
    var array: [SlangDictionary] = []
    
    func searchWord(word: String, completionHandler: @escaping (_ response: [SlangDictionary]?, _ error: Error?) -> Void) {
        array.removeAll()
        service.cancelRequest()
        
            self.service.getData(word: word) { [weak self] (response, error) in
                if let unwrappedError = error {
                    completionHandler(nil, unwrappedError)
                }
                if let data = response {
                    self?.array = data
                    completionHandler(self?.array, nil)
                }
            }
    }
    
    func getSlang(index: Int) -> SlangDictionary {
        return array[index]
    }
    
    func getCountOfData() -> Int {
        return array.count
    }
    
    func getData(index: Int) -> (String, String, Int32) {
        return (array[index].word, array[index].definition, array[index].id)
    }
    
}
