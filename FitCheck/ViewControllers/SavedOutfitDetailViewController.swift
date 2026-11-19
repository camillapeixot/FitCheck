//
//  SavedOutfitDetailViewController.swift
//  FitCheck
//
//  Created by Camilla Carvalho Peixoto on 18/11/26.
//

import UIKit

@MainActor
final class SavedOutfitDetailViewController: UIViewController {
    var onDelete: ((UUID) throws -> Void)?

    private let outfit: SavedOutfit
    private let wardrobe: [ClothingItem]
    private let preview = OutfitPreviewView()
    private let scrollView = UIScrollView()
    private let stack = UIStackView()
    private let message = UILabel()
    private let pieces = UIStackView()

    init(outfit: SavedOutfit, wardrobe: [ClothingItem]) {
        self.outfit = outfit
        self.wardrobe = wardrobe
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = outfit.name
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "trash"),
            style: .plain,
            target: self,
            action: #selector(confirmDelete)
        )
        navigationItem.rightBarButtonItem?.tintColor = .systemRed
        setupLayout()
        showDetails()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    private func setupLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 18

        message.numberOfLines = 0
        message.font = .preferredFont(forTextStyle: .subheadline)
        message.textColor = .secondaryLabel
        pieces.axis = .vertical
        pieces.spacing = 12

        let heading = UILabel()
        heading.text = "Pieces"
        heading.font = .preferredFont(forTextStyle: .headline)

        view.addSubview(scrollView)
        scrollView.addSubview(stack)
        stack.addArrangedSubview(preview)
        stack.addArrangedSubview(message)
        stack.addArrangedSubview(heading)
        stack.addArrangedSubview(pieces)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -20),
            stack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -24),
            stack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -40),
            preview.heightAnchor.constraint(equalToConstant: 320)
        ])
    }

    private func showDetails() {
        let available = outfit.availableItems(in: wardrobe)
        preview.configure(items: available)
        let missing = outfit.totalPieces - available.count
        message.text = missing == 0
            ? "Saved \(outfit.createdAt.formatted(date: .long, time: .omitted)) • \(outfit.totalPieces) pieces"
            : "\(missing) piece(s) from this saved look were deleted from your wardrobe. The look is kept so you can review or delete it."
        if missing > 0 { message.textColor = .systemOrange }

        for item in available {
            let label = UILabel()
            label.font = .preferredFont(forTextStyle: .body)
            label.numberOfLines = 0
            label.text = "• \(item.name) — \(item.category.rawValue)"
            label.isAccessibilityElement = true
            pieces.addArrangedSubview(label)
        }
        if available.isEmpty {
            let label = UILabel()
            label.text = "No pieces are still available."
            label.textColor = .secondaryLabel
            pieces.addArrangedSubview(label)
        }
    }

    @objc private func confirmDelete() {
        let alert = UIAlertController(
            title: "Delete this look?",
            message: "Your clothing items will not be deleted.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete Look", style: .destructive) { [weak self] _ in
            guard let self else { return }
            do {
                guard let onDelete = self.onDelete else {
                    throw OutfitStoreError.savedLookNotFound
                }
                try onDelete(self.outfit.id)
                self.navigationController?.popViewController(animated: true)
            } catch {
                let failure = UIAlertController(
                    title: "Couldn't delete look",
                    message: error.localizedDescription,
                    preferredStyle: .alert
                )
                failure.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(failure, animated: true)
            }
        })
        present(alert, animated: true)
    }
}
