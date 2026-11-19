//
//  BuildOutfitViewController.swift
//  FitCheck
//
//  Created by Camilla Carvalho Peixoto on 17/11/26.
//

import UIKit

@MainActor
final class BuildOutfitViewController: UIViewController {
    // MARK: - Entrada de dados e estado
    private var wardrobeItems: [ClothingItem]
    var onLoadWardrobe: (@MainActor () throws -> [ClothingItem])?
    var onAddClothing: (() -> Void)?
    var onSaveOutfit: ((Outfit) throws -> Void)?
    var onLoadSavedOutfits: (() throws -> [SavedOutfit])?
    var onDeleteSavedOutfit: ((UUID) throws -> Void)?

    private var selectedCategory: ClothingCategory = .tops
    private var selectedItems: [ClothingCategory: ClothingItem] = [:]
    private var selectedAccessories: [ClothingItem] = []
    private var currentOutfit: Outfit?

    init(items: [ClothingItem]) {
        wardrobeItems = items
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var filteredItems: [ClothingItem] {
        wardrobeItems.filter { $0.category == selectedCategory }
    }

    private var canCreateLook: Bool {
        selectedItems[.tops] != nil &&
        selectedItems[.bottoms] != nil &&
        selectedItems[.shoes] != nil
    }

    // MARK: - Cabeçalho (igual à My Wardrobe)
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Build Outfit"
        label.font = .preferredFont(forTextStyle: .largeTitle)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Mix and match your favorite pieces."
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()

    private let previewTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Create your outfit"
        label.font = .preferredFont(forTextStyle: .title3)
        label.textColor = .label
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    private let previewSubtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Start with a top, bottom and shoes. Accessories are optional."
        label.numberOfLines = 0
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.textColor = .secondaryLabel
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    private let outfitPreview = OutfitPreviewView()

    private lazy var savedLooksButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.title = "Saved Looks"
        config.image = UIImage(systemName: "bookmark")
        config.imagePadding = 5
        config.baseForegroundColor = UIColor(named: "BrandPrimary") ?? .systemPurple
        let button = UIButton(configuration: config)
        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        button.addTarget(self, action: #selector(didTapSavedLooks), for: .touchUpInside)
        return button
    }()

    private let previewCard: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemGroupedBackground
        view.layer.cornerRadius = 24
        view.layer.cornerCurve = .continuous
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let instructionLabel: UILabel = {
        let label = UILabel()
        label.text = "Choose a category and tap a piece to add it to your outfit."
        label.font = .preferredFont(forTextStyle: .footnote)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()

    private let progressLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.font = .preferredFont(forTextStyle: .caption1)
        label.numberOfLines = 0
        return label
    }()

    // MARK: - Filtros
    private let categoryScrollView = UIScrollView()
    private let categoryStackView = UIStackView()
    private var categoryButtons: [UIButton] = []

    // MARK: - Miniaturas selecionáveis
    private lazy var pickerCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 96, height: 112)
        layout.minimumLineSpacing = 10
        layout.sectionInset = .zero

        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.backgroundColor = .clear
        collection.showsHorizontalScrollIndicator = false
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.dataSource = self
        collection.delegate = self
        collection.register(
            OutfitPickerCell.self,
            forCellWithReuseIdentifier: OutfitPickerCell.reuseIdentifier
        )
        return collection
    }()

    // MARK: - Categoria vazia
    private let emptyTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.textColor = .label
        label.textAlignment = .center
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        return label
    }()

    private let emptyDescriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Add clothing to your wardrobe to start building outfits."
        label.font = .preferredFont(forTextStyle: .footnote)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private lazy var goToWardrobeButton: UIButton = {
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

    private lazy var emptyCategoryCard: UIView = {
        let card = UIView()
        card.backgroundColor = .secondarySystemGroupedBackground
        card.layer.cornerRadius = 22
        card.translatesAutoresizingMaskIntoConstraints = false

        let icon = UIImageView(image: UIImage(systemName: "hanger"))
        icon.tintColor = UIColor(named: "BrandPrimary") ?? .systemPurple
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.heightAnchor.constraint(equalToConstant: 30).isActive = true

        let stack = UIStackView(arrangedSubviews: [
            icon, emptyTitleLabel, emptyDescriptionLabel, goToWardrobeButton
        ])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 9
        stack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14)
        ])
        return card
    }()

    // MARK: - Rodapé
    private lazy var createLookButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Create Look"
        config.cornerStyle = .capsule
        config.baseBackgroundColor = UIColor(named: "BrandPrimary") ?? .systemPurple
        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTapCreateLook), for: .touchUpInside)
        return button
    }()

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    // MARK: - Ciclo de vida
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupCategoryFilters()
        setupLayout()
        refreshInterface()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refreshWardrobe()
    }

    // MARK: - Layout (sem views duplicadas)
    private func setupLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.spacing = 18
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        let titles = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        titles.axis = .vertical
        titles.spacing = 15
        titles.alignment = .leading

        let header = UIStackView(arrangedSubviews: [titles, savedLooksButton])
        header.axis = .horizontal
        header.alignment = .top
        header.spacing = 8
        header.distribution = .fill

        let previewContent = UIStackView(arrangedSubviews: [
            previewTitleLabel, previewSubtitleLabel, outfitPreview
        ])
        previewContent.axis = .vertical
        previewContent.spacing = 10
        previewContent.translatesAutoresizingMaskIntoConstraints = false
        previewCard.addSubview(previewContent)

        view.addSubview(scrollView)
        view.addSubview(createLookButton)
        scrollView.addSubview(contentStack)

        contentStack.addArrangedSubview(header)
        contentStack.addArrangedSubview(previewCard)
        contentStack.addArrangedSubview(instructionLabel)
        contentStack.addArrangedSubview(categoryScrollView)
        contentStack.addArrangedSubview(pickerCollectionView)
        contentStack.addArrangedSubview(emptyCategoryCard)
        contentStack.addArrangedSubview(progressLabel)

        NSLayoutConstraint.activate([
            previewContent.topAnchor.constraint(equalTo: previewCard.topAnchor, constant: 16),
            previewContent.leadingAnchor.constraint(equalTo: previewCard.leadingAnchor, constant: 16),
            previewContent.trailingAnchor.constraint(equalTo: previewCard.trailingAnchor, constant: -16),
            previewContent.bottomAnchor.constraint(equalTo: previewCard.bottomAnchor, constant: -16),
            outfitPreview.heightAnchor.constraint(equalToConstant: 300),

            createLookButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            createLookButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createLookButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            createLookButton.heightAnchor.constraint(equalToConstant: 52),

            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: createLookButton.topAnchor, constant: -12),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 24),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -20),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -16),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -40),

            categoryScrollView.heightAnchor.constraint(equalToConstant: 44),
            pickerCollectionView.heightAnchor.constraint(equalToConstant: 116),
            emptyCategoryCard.heightAnchor.constraint(greaterThanOrEqualToConstant: 170)
        ])
    }

    private func setupCategoryFilters() {
        categoryScrollView.showsHorizontalScrollIndicator = false
        categoryScrollView.translatesAutoresizingMaskIntoConstraints = false
        categoryStackView.axis = .horizontal
        categoryStackView.alignment = .center
        categoryStackView.spacing = 8
        categoryStackView.translatesAutoresizingMaskIntoConstraints = false
        categoryScrollView.addSubview(categoryStackView)

        for (index, category) in ClothingCategory.allCases.enumerated() {
            var config = UIButton.Configuration.filled()
            config.title = category.rawValue
            config.cornerStyle = .capsule
            config.contentInsets = NSDirectionalEdgeInsets(
                top: 8, leading: 16, bottom: 8, trailing: 16
            )
            let button = UIButton(configuration: config)
            button.tag = index
            button.addTarget(self, action: #selector(didTapCategory(_:)), for: .touchUpInside)
            categoryButtons.append(button)
            categoryStackView.addArrangedSubview(button)
        }

        NSLayoutConstraint.activate([
            categoryStackView.topAnchor.constraint(equalTo: categoryScrollView.contentLayoutGuide.topAnchor),
            categoryStackView.bottomAnchor.constraint(equalTo: categoryScrollView.contentLayoutGuide.bottomAnchor),
            categoryStackView.leadingAnchor.constraint(equalTo: categoryScrollView.contentLayoutGuide.leadingAnchor),
            categoryStackView.trailingAnchor.constraint(equalTo: categoryScrollView.contentLayoutGuide.trailingAnchor),
            categoryStackView.heightAnchor.constraint(equalTo: categoryScrollView.frameLayoutGuide.heightAnchor)
        ])
        updateCategoryAppearance()
    }

    private func updateCategoryAppearance() {
        let purple = UIColor(named: "BrandPrimary") ?? .systemPurple
        for (index, button) in categoryButtons.enumerated() {
            let selected = ClothingCategory.allCases[index] == selectedCategory
            var config = button.configuration
            config?.baseBackgroundColor = selected ? purple : .systemBackground
            config?.baseForegroundColor = selected ? .white : .secondaryLabel
            config?.background.strokeColor = selected ? .clear : .separator
            config?.background.strokeWidth = selected ? 0 : 1
            button.configuration = config
            button.accessibilityTraits = selected ? [.button, .selected] : [.button]
        }
    }

    // MARK: - Atualizações de UI
    private func refreshWardrobe() {
        guard let onLoadWardrobe else {
            refreshInterface()
            return
        }
        do {
            wardrobeItems = try onLoadWardrobe()
            let byID = Dictionary(uniqueKeysWithValues: wardrobeItems.map { ($0.id, $0) })
            selectedItems = selectedItems.compactMapValues { byID[$0.id] }
            selectedAccessories = selectedAccessories.compactMap { byID[$0.id] }
            refreshInterface()
        } catch {
            showMessage("Could not load your wardrobe: \(error.localizedDescription)")
        }
    }

    private func refreshInterface() {
        let ordered: [ClothingItem] = [
            selectedItems[.tops], selectedItems[.bottoms], selectedItems[.shoes]
        ].compactMap { $0 } + selectedAccessories
        outfitPreview.configure(items: ordered)
        pickerCollectionView.reloadData()
        updatePickerState()
        updateCreateLookButton()
    }

    private func updatePickerState() {
        let isEmpty = filteredItems.isEmpty
        pickerCollectionView.isHidden = isEmpty
        emptyCategoryCard.isHidden = !isEmpty
        emptyTitleLabel.text = "No \(selectedCategory.rawValue.lowercased()) yet"
    }

    private func updateCreateLookButton() {
        let count = [ClothingCategory.tops, .bottoms, .shoes]
            .filter { selectedItems[$0] != nil }.count
        progressLabel.text = "\(count) of 3 essential pieces selected"
        createLookButton.isEnabled = canCreateLook
        var config = createLookButton.configuration
        config?.baseBackgroundColor = canCreateLook
            ? (UIColor(named: "BrandPrimary") ?? .systemPurple)
            : .systemGray3
        config?.title = "Create Look"
        createLookButton.configuration = config
        createLookButton.accessibilityHint = canCreateLook
            ? "Preview your complete outfit"
            : "Select a top, bottom and shoes first"
    }

    // MARK: - Ações
    @objc private func didTapCategory(_ sender: UIButton) {
        selectedCategory = ClothingCategory.allCases[sender.tag]
        updateCategoryAppearance()
        pickerCollectionView.reloadData()
        updatePickerState()
    }

    @objc private func didTapAddClothing() {
        onAddClothing?()
    }

    @objc private func didTapCreateLook() {
        guard canCreateLook else { return }
        guard let onSaveOutfit else {
            showMessage("Saving isn't configured yet. Please check the tab bar setup.")
            return
        }
        let ordered = [selectedItems[.tops], selectedItems[.bottoms], selectedItems[.shoes]]
            .compactMap { $0 } + selectedAccessories

        // Alertas curtos fazem sentido aqui: estamos pedindo apenas o nome do look.
        let alert = UIAlertController(title: "Save your look", message: "Choose a name for this outfit.", preferredStyle: .alert)
        alert.addTextField { field in
            field.text = "My Outfit"
            field.placeholder = "Outfit name"
            field.autocapitalizationType = .words
            field.clearButtonMode = .whileEditing
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Save", style: .default) { [weak self, weak alert] _ in
            guard let self, let alert else { return }
            let name = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let outfit = Outfit(name: name, items: ordered)
            do {
                try onSaveOutfit(outfit)
                self.currentOutfit = outfit
                self.showMessage("Look saved! Open Saved Looks to see it again.")
            } catch {
                self.showMessage("Couldn't save look: \(error.localizedDescription)")
            }
        })
        present(alert, animated: true)
    }

    @objc private func didTapSavedLooks() {
        let savedVC = SavedOutfitsViewController()
        savedVC.onLoadOutfits = onLoadSavedOutfits
        savedVC.onDeleteOutfit = onDeleteSavedOutfit
        savedVC.onLoadWardrobe = onLoadWardrobe
        navigationController?.pushViewController(savedVC, animated: true)
    }

    private func showMessage(_ message: String) {
        let alert = UIAlertController(title: "Fit Check", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UICollectionView
extension BuildOutfitViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        filteredItems.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: OutfitPickerCell.reuseIdentifier,
            for: indexPath
        ) as! OutfitPickerCell
        let item = filteredItems[indexPath.item]
        let isSelected = item.category == .accessories
            ? selectedAccessories.contains(where: { $0.id == item.id })
            : selectedItems[item.category]?.id == item.id
        cell.configure(with: item, selected: isSelected)
        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        let item = filteredItems[indexPath.item]
        if item.category == .accessories {
            if let index = selectedAccessories.firstIndex(where: { $0.id == item.id }) {
                selectedAccessories.remove(at: index)
            } else {
                // Duas posições de acessórios: ao escolher uma terceira, substitui a mais antiga.
                if selectedAccessories.count == 2 { selectedAccessories.removeFirst() }
                selectedAccessories.append(item)
            }
        } else if selectedItems[item.category]?.id == item.id {
            selectedItems.removeValue(forKey: item.category)
        } else {
            selectedItems[item.category] = item
        }
        refreshInterface()
    }
}
