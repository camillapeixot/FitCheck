//
//  FitCheckModelContainer.swift
//  FitCheck
//
//  Created by Camilla Carvalho Peixoto on 18/11/26.
//

import SwiftData

@MainActor
enum FitCheckModelContainer {
    private static var cached: ModelContainer?

    static func shared() throws -> ModelContainer {
        if let cached { return cached }

        let container = try ModelContainer(
            for: ClothingRecord.self,
            OutfitRecord.self
        )
        cached = container
        return container
    }
}
