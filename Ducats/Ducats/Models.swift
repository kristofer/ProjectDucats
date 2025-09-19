//
//  Models.swift
//  Ducats
//
//  Created by Kristofer Younger on 9/17/25.
//

import Foundation
import SwiftData

// Only model definitions below
@Model
final class Project {
    var name: String = ""
    var details: String = ""
    var createdAt: Date = Date()
    var completed: Bool = false
    @Relationship(deleteRule: .cascade) var expenses: [Expense]? = nil
    
    init(name: String, details: String = "", createdAt: Date = Date(), completed: Bool = false) {
        self.name = name
        self.details = details
        self.createdAt = createdAt
        self.completed = completed
    }
}

@Model
final class Expense {
    var amount: Double = 0.0
    var date: Date = Date()
    var desc: String = ""
    var receiptImageData: Data?
    var whereMade: String = ""
    var whatPurchased: String = ""
    @Relationship var project: Project? = nil
    
    init(amount: Double, date: Date = Date(), description: String = "", receiptImageData: Data? = nil, project: Project? = nil, whereMade: String = "", whatPurchased: String = "") {
        self.amount = amount
        self.date = date
        self.desc = description
        self.receiptImageData = receiptImageData
        self.project = project
        self.whereMade = whereMade
        self.whatPurchased = whatPurchased
    }
}
