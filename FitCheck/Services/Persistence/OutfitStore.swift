//
//  OutfitStore.swift
//  FitCheck
//
//  Created by Camilla Carvalho Peixoto on 18/11/26.
//


import Foundation
import SwiftData

enum OutfitStoreError: LocalizedError {
    case invalidName
    case incompleteOutfit
    case tooManyAccessories
    case duplicatedPiece
    case removedClothing
    case wardrobeChanged
    case savedLookNotFound

    var errorDescription: String? {
        switch self {
        case .invalidName: return "Please give this look a name."
        case .incompleteOutfit: return "Choose exactly one top, bottom, and pair of shoes."
        case .tooManyAccessories: return "A look can have at most two accessories."
        case .duplicatedPiece: return "The same clothing item cannot appear twice in a look."
        case .removedClothing: return "One of these items was deleted. Refresh the outfit and try again."
        case .wardrobeChanged: return "A selected item changed category. Refresh the outfit and try again."
        case .savedLookNotFound: return "This saved look was not found."
        }
    }
}

@MainActor
final class OutfitStore {
    private let container: ModelContainer

    init() throws {
        container = try FitCheckModelContainer.shared()
    }

    func save(_ outfit: Outfit) throws {
        let name = outfit.name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { throw OutfitStoreError.invalidName }

        let required: [ClothingCategory] = [.tops, .bottoms, .shoes]
        guard required.allSatisfy({ category in
            outfit.items.filter { $0.category == category }.count == 1
        }) else { throw OutfitStoreError.incompleteOutfit }

        guard outfit.items.filter({ $0.category == .accessories }).count <= 2 else {
            throw OutfitStoreError.tooManyAccessories
        }

        let ids = outfit.items.map(\.id)
        guard Set(ids).count == ids.count else {
            throw OutfitStoreError.duplicatedPiece
        }

        // Confirma no banco que nenhuma roupa escolhida foi excluida antes de salvar.
        let context = container.mainContext
        let wardrobe = try context.fetch(FetchDescriptor<ClothingRecord>())
        let existingIDs = Set(wardrobe.map(\.id))
        guard ids.allSatisfy({ existingIDs.contains($0) }) else {
            throw OutfitStoreError.removedClothing
        }
        let categoriesByID = Dictionary(uniqueKeysWithValues: wardrobe.map { ($0.id, $0.category) })
        guard outfit.items.allSatisfy({ categoriesByID[$0.id] == $0.category.rawValue }) else {
            throw OutfitStoreError.wardrobeChanged
        }

        let record = OutfitRecord(
            id: outfit.id,
            name: name,
            itemIDsData: try JSONEncoder().encode(ids)
        )
        context.insert(record)

        do {
            try context.save()
        } catch {
            context.rollback()
            throw error
        }
    }

    func loadSavedOutfits() throws -> [SavedOutfit] {
        let descriptor = FetchDescriptor<OutfitRecord>(
            sortBy: [SortDescriptor(\OutfitRecord.createdAt, order: .reverse)]
        )
        return try container.mainContext.fetch(descriptor).map { record in
            let ids = try JSONDecoder().decode([UUID].self, from: record.itemIDsData)
            return SavedOutfit(
                id: record.id,
                name: record.name,
                createdAt: record.createdAt,
                clothingIDs: ids
            )
        }
    }

    func delete(id: UUID) throws {
        let context = container.mainContext
        let descriptor = FetchDescriptor<OutfitRecord>(
            predicate: #Predicate<OutfitRecord> { $0.id == id }
        )
        guard let record = try context.fetch(descriptor).first else {
            throw OutfitStoreError.savedLookNotFound
        }
        context.delete(record)
        do {
            try context.save()
        } catch {
            context.rollback()
            throw error
        }
    }
}
