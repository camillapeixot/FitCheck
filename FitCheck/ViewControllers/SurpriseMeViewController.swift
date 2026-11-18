//
//  SurpriseMeViewController.swift
//  FitCheck
//
//  Created by Camilla Carvalho Peixoto on 18/11/26.
//

import UIKit

@MainActor
final class SurpriseMeViewController: UIViewController {
    var onLoadWardrobe: (@MainActor () throws -> [ClothingItem])?
    var onAddClothing: (() -> Void)?
    
    private let generator = OutfitGenerator()
    private var wardrobeItems: [ClothingItem] = []
    private var currentOutfit: Outfit?
    
    // MARK: - Título principal (alinhado como My Wardrobe)
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Surprise Me"
        label.font = .preferredFont(forTextStyle: .largeTitle)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .label
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Find a new combination from your wardrobe."
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()
    
    private let heroTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Your Surprise Look ✨"
        label.font = .preferredFont(forTextStyle: .title3)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .label
        return label
    }()
    
    private let heroDescriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "An outfit assembled from your saved clothing photos."
        label.font = .preferredFont(forTextStyle: .footnote)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()
    
    private let previewView = OutfitPreviewView()
    
    private let heroCard: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemGroupedBackground
        view.layer.cornerRadius = 24
        view.layer.cornerCurve = .continuous
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.text = "Choose Shuffle to discover a new look."
        label.font = .preferredFont(forTextStyle: .footnote)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()
    
    private let piecesTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Pieces in this look"
        label.font = .preferredFont(forTextStyle: .headline)
        label.textColor = .label
        return label
    }()
    
    private let piecesStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 9
        return stack
    }()
    
    private lazy var addClothingButton: UIButton = {
        var config = UIButton.Configuration.bordered()
        config.title = "Add Clothing"
        config.image = UIImage(systemName: "plus")
        config.imagePadding = 8
        config.cornerStyle = .capsule
        config.baseForegroundColor = UIColor(named: "BrandPrimary") ?? .systemPurple
        let button = UIButton(configuration: config)
        button.addTarget(self, action: #selector(didTapAddClothing), for: .touchUpInside)
        return button
    }()
    
    private lazy var shuffleButton: UIButton = {
        var config = UIButton.Configuration.bordered()
        config.title = "Shuffle Again"
        config.image = UIImage(systemName: "shuffle")
        config.imagePadding = 6
        config.cornerStyle = .capsule
        config.baseForegroundColor = UIColor(named: "BrandPrimary") ?? .systemPurple
        let button = UIButton(configuration: config)
        button.addTarget(self, action: #selector(didTapShuffle), for: .touchUpInside)
        return button
    }()
    
    private let saveButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Save Look"
        config.image = UIImage(systemName: "bookmark")
        config.imagePadding = 6
        config.cornerStyle = .capsule
        config.baseBackgroundColor = UIColor(named: "BrandPrimary") ?? .systemPurple
        let button = UIButton(configuration: config)
        button.isEnabled = false // Persistência de looks será implementada na Aula 10.
        button.accessibilityHint = "Saving outfits will be available after persistence is implemented"
        return button
    }()
    
    private let saveHintLabel: UILabel = {
        let label = UILabel()
        label.text = "Save Look will be enabled when we add SwiftData for outfits."
        label.font = .preferredFont(forTextStyle: .caption2)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()
    
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let actionsStack = UIStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupLayout()
        updateResults()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reloadWardrobe()
    }
    
    // MARK: - Layout
    private func setupLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.spacing = 16
        
        let headerStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        headerStack.axis = .vertical
        headerStack.spacing = 15
        
        let heroContent = UIStackView(arrangedSubviews: [
            heroTitleLabel, heroDescriptionLabel, previewView
        ])
        heroContent.axis = .vertical
        heroContent.spacing = 10
        heroContent.translatesAutoresizingMaskIntoConstraints = false
        heroCard.addSubview(heroContent)
        
        actionsStack.axis = .horizontal
        actionsStack.distribution = .fillEqually
        actionsStack.spacing = 10
        actionsStack.translatesAutoresizingMaskIntoConstraints = false
        actionsStack.addArrangedSubview(shuffleButton)
        actionsStack.addArrangedSubview(saveButton)
        
        view.addSubview(scrollView)
        view.addSubview(actionsStack)
        scrollView.addSubview(contentStack)
        contentStack.addArrangedSubview(headerStack)
        contentStack.addArrangedSubview(heroCard)
        contentStack.addArrangedSubview(statusLabel)
        contentStack.addArrangedSubview(addClothingButton)
        contentStack.addArrangedSubview(piecesTitleLabel)
        contentStack.addArrangedSubview(piecesStack)
        contentStack.addArrangedSubview(saveHintLabel)
        
        NSLayoutConstraint.activate([
            heroContent.topAnchor.constraint(equalTo: heroCard.topAnchor, constant: 16),
            heroContent.leadingAnchor.constraint(equalTo: heroCard.leadingAnchor, constant: 16),
            heroContent.trailingAnchor.constraint(equalTo: heroCard.trailingAnchor, constant: -16),
            heroContent.bottomAnchor.constraint(equalTo: heroCard.bottomAnchor, constant: -16),
            previewView.heightAnchor.constraint(equalToConstant: 310),
            
            actionsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            actionsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            actionsStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            actionsStack.heightAnchor.constraint(equalToConstant: 50),
            
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: actionsStack.topAnchor, constant: -12),
            
            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 24),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -20),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -16),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -40)
        ])
    }
    
    // MARK: - Dados / Gerador
    private func reloadWardrobe() {
        do {
            wardrobeItems = try onLoadWardrobe?() ?? []
            // Se uma peça foi alterada, usamos o objeto atual; se foi apagada, sorteamos novamente.
            if let outfit = currentOutfit {
                let updated = Dictionary(uniqueKeysWithValues: wardrobeItems.map { ($0.id, $0) })
                let refreshedItems = outfit.items.compactMap { updated[$0.id] }
                if refreshedItems.count == outfit.items.count {
                    currentOutfit = Outfit(id: outfit.id, name: outfit.name, items: refreshedItems)
                } else {
                    currentOutfit = nil
                }
            }
            if currentOutfit == nil {
                generateLook()
            } else {
                updateResults()
            }
        } catch {
            currentOutfit = nil
            statusLabel.text = "Couldn't load wardrobe: \(error.localizedDescription)"
            updateResults()
        }
    }
    
    @objc private func didTapShuffle() {
        generateLook()
    }
    
    private func generateLook() {
        do {
            currentOutfit = try generator.generate(from: wardrobeItems)
            statusLabel.text = "A fresh combination made from your own wardrobe."
        } catch {
            currentOutfit = nil
            statusLabel.text = error.localizedDescription
        }
        updateResults()
    }
    
    private func updateResults() {
        let items = currentOutfit?.items ?? []
        previewView.configure(items: items)
        piecesTitleLabel.isHidden = items.isEmpty
        saveHintLabel.isHidden = items.isEmpty
        addClothingButton.isHidden = !items.isEmpty
        let requiredCategories: [ClothingCategory] = [.tops, .bottoms, .shoes]
        let canShuffle = requiredCategories.allSatisfy { category in
            wardrobeItems.contains { $0.category == category }
        }
        shuffleButton.isEnabled = canShuffle
        var shuffleConfiguration = shuffleButton.configuration
        shuffleConfiguration?.title = currentOutfit == nil ? "Generate Look" : "Shuffle Again"
        shuffleButton.configuration = shuffleConfiguration
        
        // Remove linhas antigas antes de redesenhar, para não acumular peças.
        for row in piecesStack.arrangedSubviews {
            piecesStack.removeArrangedSubview(row)
            row.removeFromSuperview()
        }
        
        for item in items {
            piecesStack.addArrangedSubview(makePieceRow(for: item))
        }
    }
    
    private func makePieceRow(for item: ClothingItem) -> UIView {
        let photo = UIImageView()
        photo.contentMode = .scaleAspectFill
        photo.clipsToBounds = true
        photo.layer.cornerRadius = 9
        photo.backgroundColor = .secondarySystemGroupedBackground
        photo.image = item.photoData.flatMap(UIImage.init(data:))
        ?? UIImage(systemName: item.symbolName)
        photo.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            photo.widthAnchor.constraint(equalToConstant: 48),
            photo.heightAnchor.constraint(equalToConstant: 52)
        ])
        
        let name = UILabel()
        name.font = .preferredFont(forTextStyle: .subheadline)
        name.textColor = .label
        name.numberOfLines = 2
        name.text = item.name
        
        let category = UILabel()
        category.font = .preferredFont(forTextStyle: .caption1)
        category.textColor = .secondaryLabel
        category.text = item.category.rawValue
        
        let texts = UIStackView(arrangedSubviews: [name, category])
        texts.axis = .vertical
        texts.spacing = 3
        
        let row = UIStackView(arrangedSubviews: [photo, texts])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 12
        row.isAccessibilityElement = true
        row.accessibilityLabel = "\(item.name), \(item.category.rawValue)"
        return row
    }
    
    @objc private func didTapAddClothing() {
        onAddClothing?()
    }
}
