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
    var name: String
    var details: String
    var createdAt: Date
    @Relationship(deleteRule: .cascade) var expenses: [Expense] = []
    
    init(name: String, details: String = "", createdAt: Date = Date()) {
        self.name = name
        self.details = details
        self.createdAt = createdAt
    }
}

@Model
final class Expense {
    var amount: Double
    var date: Date
    var desc: String
    var receiptImageData: Data?
    @Relationship var project: Project?
    
    init(amount: Double, date: Date = Date(), description: String = "", receiptImageData: Data? = nil, project: Project? = nil) {
        self.amount = amount
        self.date = date
        self.desc = description
        self.receiptImageData = receiptImageData
        self.project = project
    }
}
