//
//  OutfitRecord.swift
//  FitCheck
//
//  Created by Camilla Carvalho Peixoto on 18/11/26.
//

import Foundation
import SwiftData

@Model
final class OutfitRecord {
    @Attribute(.unique) var id: UUID
    var name: String
    var createdAt: Date
    var itemIDsData: Data

    init(id: UUID, name: String, createdAt: Date = .now, itemIDsData: Data) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
        self.itemIDsData = itemIDsData
    }
}
