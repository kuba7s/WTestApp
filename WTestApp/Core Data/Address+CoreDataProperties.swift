//
//  Address+CoreDataProperties.swift
//  
//
//  Created by Alexandre Carvalho on 16/06/2021.
//
//

import Foundation
import CoreData


extension Address {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Address> {
        return NSFetchRequest<Address>(entityName: "Address")
    }

    @NSManaged public var searchTitle: String?
    @NSManaged public var location: String?
    @NSManaged public var postCode: String?

}
