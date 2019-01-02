//
//  AreaDB.swift
//  SingaporeWeather
//
//  Created by Leslie Zhang on 2019/1/3.
//  Copyright © 2019 Leslie Zhang. All rights reserved.
//

import UIKit
import RealmSwift

class AreaDB: RealmSwift.Object {
    @objc public dynamic var name: String = ""
    
    @objc public dynamic var forecast: String = ""
    
    @objc public dynamic var location:LocationDB?
    
    override static func primaryKey() -> String? {
        return "name"
    }
    
}

class LocationDB: Object {
    
    @objc dynamic var latitude:Double = 0.0
    @objc dynamic var longitude:Double = 0.0
    
    let owners = LinkingObjects(fromType: AreaDB.self, property: "location")
}
