//
//  ClothingItem.swift
//  FitCheck
//
//  Created by Camilla Carvalho Peixoto on 12/11/26.
//

import Foundation

enum ClothingCategory: String, CaseIterable {
    case tops = "Tops"
    case bottoms = "Bottoms"
    case shoes = "Shoes"
    case accessories = "Accessories"
}

struct ClothingItem {
    let id: UUID
    let name: String
    let category: ClothingCategory
    let symbolName: String
    var photoData: Data? = nil
}
