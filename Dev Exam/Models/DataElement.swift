//
//  DataElement.swift
//  Dev Exam
//
//  Created by George Sabanov on 31.07.2018.
//  Copyright © 2018 George Sabanov. All rights reserved.
//

import UIKit
import RealmSwift
import Realm
class DataElement: Object {
    @objc dynamic var id: Int
    @objc dynamic var title: String? = nil
    @objc dynamic var text: String? = nil
    @objc dynamic var image: String? = nil
    @objc dynamic var sort = 0
    @objc dynamic var date: Date? = nil
    override static func primaryKey() -> String? {
        return "id"
    }

    required init(id: Int, title: String, text: String, image: String, sort: Int, date: Date)
    {
        self.id = id
        self.title = title
        self.text = text
        self.image = image
        self.sort = sort
        self.date = date
        super.init()
    }
    
    func updateValues(title: String, text: String, image: String, sort: Int, date: Date)
    {
        self.title = title
        self.text = text
        self.image = image
        self.sort = sort
        self.date = date
    }
    
    required init() {
        self.id = 0
        super.init()
    }
    
    required init(value: Any, schema: RLMSchema) {
        self.id = 0
        super.init(value: value, schema: schema)
    }
    
    
    required init(realm: RLMRealm, schema: RLMObjectSchema) {
        self.id = 0
        super.init(realm: realm, schema: schema)
    }
}
