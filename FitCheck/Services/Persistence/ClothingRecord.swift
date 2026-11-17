//
//  ClothingRecord.swift
//  FitCheck
//
//  Created by Camilla Carvalho Peixoto on 16/11/26.
//

import Foundation
import SwiftData

@Model
final class ClothingRecord {

    @Attribute(.unique)
    var id: UUID

    var name: String
    var category: String
    var symbolName: String

    @Attribute(.externalStorage)
    var photoData: Data?

    init(from item: ClothingItem) {
        self.id = item.id
        self.name = item.name
        self.category = item.category.rawValue
        self.symbolName = item.symbolName
        self.photoData = item.photoData
    }

    func toClothingItem() -> ClothingItem? {
        guard let category = ClothingCategory(rawValue: category) else {
            return nil
        }

        return ClothingItem(
            id: id,
            name: name,
            category: category,
            symbolName: symbolName,
            photoData: photoData
        )
    }
}
