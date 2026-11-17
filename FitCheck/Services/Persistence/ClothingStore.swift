//
//  ClothingStore.swift
//  FitCheck
//
//  Created by Camilla Carvalho Peixoto on 16/11/26.
//

import Foundation
import SwiftData

enum ClothingStoreError: LocalizedError {
    case itemNotFound

    var errorDescription: String? {
        switch self {
        case .itemNotFound:
            return "This clothing item could not be found."
        }
    }
}

@MainActor
final class ClothingStore {

    private let container: ModelContainer

    init() throws {
        container = try ModelContainer(
            for: ClothingRecord.self
        )
    }

    func save(_ item: ClothingItem) throws {
        let record = ClothingRecord(from: item)

        let context = container.mainContext
        context.insert(record)

        do {
            try context.save()
        } catch {
            context.rollback()
            throw error
        }
    }

    func loadItems() throws -> [ClothingItem] {
        let descriptor = FetchDescriptor<ClothingRecord>(
            sortBy: [
                SortDescriptor(\ClothingRecord.name)
            ]
        )

        let records = try container.mainContext.fetch(
            descriptor
        )

        return records.compactMap { record in
            record.toClothingItem()
        }
    }
    
    private func findRecord(id: UUID) throws -> ClothingRecord? {
        let descriptor = FetchDescriptor<ClothingRecord>(
            predicate: #Predicate<ClothingRecord> {
                $0.id == id
            }
        )

        return try container.mainContext.fetch(descriptor).first
    }
    
    func update(_ item: ClothingItem) throws {
        guard let record = try findRecord(id: item.id) else {
            throw ClothingStoreError.itemNotFound
        }

        let context = container.mainContext

        record.name = item.name
        record.category = item.category.rawValue
        record.symbolName = item.symbolName
        record.photoData = item.photoData

        do {
            try context.save()
        } catch {
            context.rollback()
            throw error
        }
    }
    
    func delete(id: UUID) throws {
        guard let record = try findRecord(id: id) else {
            throw ClothingStoreError.itemNotFound
        }

        let context = container.mainContext

        context.delete(record)

        do {
            try context.save()
        } catch {
            context.rollback()
            throw error
        }
    }

}
