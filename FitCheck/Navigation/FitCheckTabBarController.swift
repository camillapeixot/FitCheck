//
//  FitCheckTabBarController.swift
//  FitCheck
//
//  Created by Camilla Carvalho Peixoto on 17/11/26.
//


import UIKit

final class FitCheckTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTabs()
        setupAppearance()
    }

    // MARK: - Tabs

    private func setupTabs() {

        // MARK: Wardrobe

        let wardrobeVC = ViewController()

        let wardrobeNavigation = UINavigationController(
            rootViewController: wardrobeVC
        )

        wardrobeNavigation.tabBarItem = UITabBarItem(
            title: "Wardrobe",
            image: UIImage(systemName: "square.grid.2x2.fill"),
            tag: 0
        )

        // MARK: Build Outfit

        let buildOutfitVC = BuildOutfitViewController(
            items: []
        )

        buildOutfitVC.onLoadWardrobe = { [weak wardrobeVC] in
            guard let wardrobeVC else { return [] }

            return try wardrobeVC.wardrobeItemsSnapshot()
        }

        buildOutfitVC.onAddClothing = { [weak self, weak wardrobeVC] in
            self?.selectedIndex = 0
            wardrobeVC?.openAddClothing()
        }

        buildOutfitVC.onSaveOutfit = { outfit in
            try OutfitStore().save(outfit)
        }

        buildOutfitVC.onLoadSavedOutfits = {
            try OutfitStore().loadSavedOutfits()
        }

        buildOutfitVC.onDeleteSavedOutfit = { id in
            try OutfitStore().delete(id: id)
        }

        let looksNavigation = UINavigationController(
            rootViewController: buildOutfitVC
        )

        looksNavigation.tabBarItem = UITabBarItem(
            title: "Looks",
            image: UIImage(systemName: "hanger"),
            tag: 1
        )

        // MARK: Surprise Me

        let surpriseVC = SurpriseMeViewController()

        surpriseVC.onSaveOutfit = { outfit in
            try OutfitStore().save(outfit)
        }

        surpriseVC.onLoadWardrobe = { [weak wardrobeVC] in
            guard let wardrobeVC else { return [] }

            return try wardrobeVC.wardrobeItemsSnapshot()
        }

        surpriseVC.onAddClothing = { [weak self, weak wardrobeVC] in
            self?.selectedIndex = 0
            wardrobeVC?.openAddClothing()
        }

        let surpriseNavigation = UINavigationController(
            rootViewController: surpriseVC
        )

        surpriseNavigation.tabBarItem = UITabBarItem(
            title: "Surprise",
            image: UIImage(systemName: "sparkles"),
            tag: 2
        )

        // MARK: Register Tabs

        setViewControllers(
            [
                wardrobeNavigation,
                looksNavigation,
                surpriseNavigation
            ],
            animated: false
        )

        selectedIndex = 0
    }

    // MARK: - Appearance

    private func setupAppearance() {
        tabBar.tintColor =
            UIColor(named: "BrandPrimary") ?? .systemPurple

        tabBar.unselectedItemTintColor = .secondaryLabel

        if #available(iOS 26.0, *) {
            tabBarMinimizeBehavior = .onScrollDown
        }
    }
}
