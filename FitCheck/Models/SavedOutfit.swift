//
//  SavedOutfit.swift
//  FitCheck
//
//  Created by Camilla Carvalho Peixoto on 18/11/26.
//

import Foundation

struct SavedOutfit {
    let id: UUID
    let name: String
    let createdAt: Date
    let clothingIDs: [UUID]

    var totalPieces: Int {
        clothingIDs.count
    }

    func availableItems(in wardrobe: [ClothingItem]) -> [ClothingItem] {
        clothingIDs.compactMap { id in
            wardrobe.first { $0.id == id }
        }
    }
}
