//
//  RExpense.swift
//  Extr
//
//  Created by Zhaolong Zhong on 11/12/16.
//  Copyright © 2016 Expense Manager. All rights reserved.
//

import Foundation
import RealmSwift

class RExpense: Object {
    static let TAG = NSStringFromClass(RExpense.self)
    
    struct JsonKey {
        static let objectId = "objectId"
        static let amount = "amount"
        static let note = "note"
        static let spentAt = "spentAt"
        static let createdAt = "createdAt"
        static let categoryId = "categoryId"
        static let userId = "userId"
        static let groupId = "groupId"
        static let iso = "iso"
    }
    
    struct PropertyKey {
        static let id = "id"
        static let amount = "amount"
        static let spentAt = "spentAt"
        static let userId = "userId"
        static let groupId = "groupId"
    }
    
    dynamic var id: String = ""
    dynamic var amount: Double = 0.0
    dynamic var note: String = ""
    dynamic var spentAt: Date = Date()
    dynamic var createdAt: Date = Date()
    dynamic var categoryId: String = ""
    dynamic var userId: String = ""
    dynamic var groupId: String = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    func map(dictionary: NSDictionary) throws {
        guard let id = dictionary[JsonKey.objectId] as? String else {
            throw JsonError.noKey(key: JsonKey.objectId)
        }
        
        guard let userIdDict = dictionary[JsonKey.userId] as? NSDictionary else {
            throw JsonError.noKey(key: JsonKey.userId)
        }
        
        guard let groupIdDict = dictionary[JsonKey.groupId] as? NSDictionary else {
            throw JsonError.noKey(key: JsonKey.groupId)
        }
        
        self.id = id
        self.userId = userIdDict[JsonKey.objectId] as! String
        self.groupId = groupIdDict[JsonKey.objectId] as! String
        
        if let amountString = dictionary[JsonKey.amount] as? String {
            if let amount = Double(amountString) {
                self.amount = amount
            } else {
                print("\(type(of: self).TAG): Cannot convert amount to double. amount: \(amountString)")
            }
        } else {
            throw JsonError.noKey(key: JsonKey.amount)
        }
        
        if let note = dictionary[JsonKey.note] as? String {
            self.note = note
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        
        if let createdAtString = dictionary[JsonKey.createdAt] as? String {
            if let createdAt = dateFormatter.date(from: createdAtString) {
                self.createdAt = createdAt
            } else {
                print("\(type(of: self).TAG): Error in parsing createdAt. createdAt: \(createdAtString)")
            }
        } else {
            throw JsonError.noKey(key: JsonKey.createdAt)
        }
        
        if let spentAtDict = dictionary[JsonKey.spentAt] as? NSDictionary {
            if let spentAtString = spentAtDict[JsonKey.iso] as? String {
                if let spentAt = dateFormatter.date(from: spentAtString) {
                    self.spentAt = spentAt
                } else {
                    print("\(type(of: self).TAG): Error in parsing spentAt. spentAt: \(spentAtString)")
                }
            } else {
                throw JsonError.noKey(key: JsonKey.iso)
            }
        } else {
            throw JsonError.noKey(key: JsonKey.spentAt)
        }
        
        if let categoryIdDict = dictionary[JsonKey.categoryId] as? NSDictionary {
            self.categoryId = categoryIdDict[JsonKey.objectId] as! String
        } else {
            throw JsonError.noKey(key: JsonKey.categoryId)
        }
    }
    
    static func map(array: [NSDictionary]) -> [RExpense] {
        let realm = AppDelegate.getInstance().realm!
        var expenses: [RExpense] = []
        
        for dictionary in array {
            let expense = RExpense()
            
            do {
                try expense.map(dictionary: dictionary)
                
                realm.beginWrite()
                realm.add(expense, update: true)
                try realm.commitWrite()
                
                expenses.append(expense)
                
            } catch JsonError.noKey(let key) {
                let error = JsonError.noKey(key: key).error
                print("\(TAG): \(error.localizedDescription)")
                realm.cancelWrite()
            } catch let error {
                realm.cancelWrite()
                print("\(TAG): \(error)")
            }
        }
        
        return expenses
    }
    
    // MARK: - Realm queries
    static func getAllExpense() -> Results<RExpense> {
        let realm = AppDelegate.getInstance().realm!
        return realm.objects(RExpense.self).sorted(byProperty: PropertyKey.spentAt, ascending: false)
    }
    
    static func getExpenseById(id: String) -> RExpense? {
        let realm = AppDelegate.getInstance().realm!
        let predicate = NSPredicate(format:"\(PropertyKey.id) == %@", id)
        return realm.objects(RExpense.self).filter(predicate).first
    }
    
    static func getExpensesByGroupId(groupId: String) -> Results<RExpense> {
        let realm = AppDelegate.getInstance().realm!
        let predicate = NSPredicate(format:"\(PropertyKey.groupId) == %@", groupId)
        return realm.objects(RExpense.self).filter(predicate).sorted(byProperty: PropertyKey.spentAt, ascending: false)
    }
}