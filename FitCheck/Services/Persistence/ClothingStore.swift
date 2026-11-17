//
//  ClothingStore.swift
//  FitCheck
//
//  Created by Camilla Carvalho Peixoto on 16/11/26.
//

import Foundation
import SwiftData

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
}
