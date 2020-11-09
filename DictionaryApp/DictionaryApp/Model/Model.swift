//
//  Model.swift
//  DictionaryApp
//
//  Created by Nassyrkhan Seitzhapparuly on 7/11/19.
//  Copyright © 2019 Nassyrkhan Seitzhapparuly. All rights reserved.
//

import UIKit
import SwiftyJSON

struct SlangDictionary {
    var id: Int32
    var definition: String
    var author: String
    var word: String
    var date: String
    
    init(json: JSON) {
        self.id = Int32(json["defid"].intValue)
        self.definition = json["definition"].stringValue
        self.author = json["author"].stringValue
        self.word = json["word"].stringValue
        self.date = json["written_on"].stringValue
    }
    
    init(id: Int32, definition: String, author: String, word: String, date: String) {
        self.id = id
        self.definition = definition
        self.author = author
        self.date = date
        self.word = word
    }
    
}
