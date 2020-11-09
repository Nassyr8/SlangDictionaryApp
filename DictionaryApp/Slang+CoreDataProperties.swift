//
//  Slang+CoreDataProperties.swift
//  
//
//  Created by Nassyrkhan Seitzhapparuly on 7/14/19.
//
//

import Foundation
import CoreData


extension Slang {

    @nonobjc public class func fetchSlangRequest() -> NSFetchRequest<Slang> {
        return NSFetchRequest<Slang>(entityName: "Slang")
    }    

    @NSManaged public var author: String?
    @NSManaged public var date: String?
    @NSManaged public var definition: String?
    @NSManaged public var id: Int32
    @NSManaged public var word: String?

}
