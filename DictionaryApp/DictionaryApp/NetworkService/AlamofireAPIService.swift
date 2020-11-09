//
//  AlamofireAPIService.swift
//  DictionaryApp
//
//  Created by Nassyrkhan Seitzhapparuly on 7/11/19.
//  Copyright © 2019 Nassyrkhan Seitzhapparuly. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class AlamofireAPIService {
    
    var request: DataRequest?
    
    func getData(word: String, completionHandler: @escaping (_ response: [SlangDictionary]?, _ error: Error?) -> Void) {
        
        let params = ["term": word]
        guard let url = URL(string: "http://api.urbandictionary.com/v0/define") else { return }
        
        request = Alamofire.request(url, method: .get, parameters: params, encoding: URLEncoding(destination: .queryString))
        
        var slangArray: [SlangDictionary] = []
        request?.validate(statusCode: 200..<300)
        request?.responseJSON { (response) in
            switch response.result {
            case .success(let value):                
                let data = JSON(value)
                if let array = data["list"].array {
                    array.forEach({ (json) in
                        slangArray.append(SlangDictionary(json: json))
                    })
                }
                completionHandler(slangArray, nil)
            case .failure(let error):
                completionHandler(nil, error)
            }
            slangArray.removeAll()
        }
        
    }
    
    func cancelRequest() {
        if let request = self.request {            
            request.cancel()
        }
    }
    
}
