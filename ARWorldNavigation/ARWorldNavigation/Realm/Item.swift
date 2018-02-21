//
//  Item.swift
//  ARWorldNavigation
//
//  Created by GEORGE QUENTIN on 21/02/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//
import RealmSwift

class Item: Object {
    @objc dynamic var itemId: String = UUID().uuidString
    @objc dynamic var body: String = ""
    @objc dynamic var isDone: Bool = false
    @objc dynamic var timestamp: Date = Date()

    override static func primaryKey() -> String? {
        return "itemId"
    }
}
