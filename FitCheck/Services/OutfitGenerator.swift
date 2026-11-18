//
//  OutfitGenerator.swift
//  FitCheck
//
//  Created by Camilla Carvalho Peixoto on 17/11/26.
//

import Foundation

enum OutfitGeneratorError: LocalizedError {
    case missingCategory(ClothingCategory)

    var errorDescription: String? {
        switch self {
        case .missingCategory(let category):
            return "Add at least one item in \(category.rawValue) to create a look."
        }
    }
}

struct OutfitGenerator {
    func generate(from wardrobe: [ClothingItem]) throws -> Outfit {
        let required: [ClothingCategory] = [.tops, .bottoms, .shoes]
        var chosen: [ClothingItem] = []

        for category in required {
            let candidates = wardrobe.filter { $0.category == category }

            guard let item = candidates.randomElement() else {
                throw OutfitGeneratorError.missingCategory(category)
            }
            chosen.append(item)
        }

        let accessoryPool = wardrobe
            .filter { $0.category == .accessories }
            .shuffled()
        let accessoryCount = Int.random(in: 0...min(2, accessoryPool.count))
        chosen.append(contentsOf: accessoryPool.prefix(accessoryCount))

        return Outfit(name: "Surprise Look", items: chosen)
    }
}
