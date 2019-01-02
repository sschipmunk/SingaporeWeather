//
//  AreaRealmTool.swift
//  SingaporeWeather
//
//  Created by Leslie Zhang on 2019/1/3.
//  Copyright © 2019 Leslie Zhang. All rights reserved.
//

import UIKit
import RealmSwift

class AreaRealmTool: Object {
    public class func getDB() -> Realm {
        let docPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0] as String
        let dbPath = docPath.appending("/defaultDB.realm")
        let defaultRealm = try! Realm(fileURL: URL.init(string: dbPath)!)
        return defaultRealm
    }
    

    public class func insertAreas(by areas: [AreaDB]) -> Void {
        let defalutReaml = self.getDB()
        try! defalutReaml.write {
            defalutReaml.add(areas)
        }
    }
    
    public class func getAreas() -> Results<AreaDB> {
        let defaultReaml = self.getDB()
        return defaultReaml.objects(AreaDB.self)
    }
    
    public class func updateAreas(areas: [AreaDB]) {
        let defaultReaml = self.getDB()
        try! defaultReaml.write {
            defaultReaml.add(areas, update: true)
        }
    }
}
