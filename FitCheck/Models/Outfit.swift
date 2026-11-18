//
//  Outfit.swift
//  FitCheck
//
//  Created by Camilla Carvalho Peixoto on 14/11/26.
//

import Foundation

struct Outfit {
    let id: UUID
    var name: String
    var items: [ClothingItem]

    init(
        id: UUID = UUID(),
        name: String = "New Outfit",
        items: [ClothingItem] = []
    ) {
        self.id = id
        self.name = name
        self.items = items
    }
}
