//
//  ViewController.swift
//  FitCheck
//
//  Created by Camilla Carvalho Peixoto on 10/11/26.
//

import UIKit

final class ViewController: UIViewController {
    private let emptyStateImage: UIImageView = {
        let imageView = UIImageView()

        imageView.image = UIImage(systemName: "hanger")

        imageView.tintColor = UIColor(named: "BrandPrimary") ?? .systemPurple
        imageView.contentMode = .scaleAspectFit

        imageView.translatesAutoresizingMaskIntoConstraints = false

        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "My Wardrobe"
        label.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        label.textColor = .label
        label.adjustsFontForContentSizeCategory = true
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "All your favorite pieces, in one place"
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.text = """
        Your wardrobe starts here!

        Add your first item to start creating your favorite looks.
        """
        label.numberOfLines = 0
        label.font = .preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var emptyStateStack: UIStackView = {
        let stack = UIStackView(
            arrangedSubviews: [
                emptyStateImage,
                messageLabel,
                addButton
            ]
        )

        stack.axis = .vertical
        stack.spacing = 20
        stack.alignment = .center

        stack.translatesAutoresizingMaskIntoConstraints = false

        return stack
    }()
    
    private lazy var titleStack: UIStackView = {
        let stack = UIStackView(
            arrangedSubviews: [
                titleLabel,
                subtitleLabel
            ]
        )

        stack.axis = .vertical
        stack.spacing = 15
        stack.alignment = .fill

        stack.translatesAutoresizingMaskIntoConstraints = false

        return stack
    }()

    private var items: [ClothingItem] = []
    
    private var clothingStore: ClothingStore?

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 16
        
        layout.sectionInset = UIEdgeInsets(
            top: 12,
            left: 20,
            bottom: 24,
            right: 20
        )
        
        layout.estimatedItemSize = .zero
        
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        collection.backgroundColor = .clear
        collection.translatesAutoresizingMaskIntoConstraints = false
        
        collection.dataSource = self
        collection.delegate = self
        
        collection.register(ClothingCell.self, forCellWithReuseIdentifier: ClothingCell.reuseIdentifier)
        
        return collection
    }()
    
    //MARK: - BUTTONS
    private lazy var addButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Add item"
        config.image = UIImage(systemName: "plus")
        config.imagePlacement = .leading
        config.imagePadding = 8
        config.baseBackgroundColor =
            UIColor(named: "BrandPrimary") ?? .systemPurple
        
        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.addTarget(
            self,
            action: #selector(didTapAddItem),
            for: .touchUpInside
        )
        
        return button
    }()
    
    private lazy var addAnotherButton: UIButton = {
        var configuration = UIButton.Configuration.filled()

        configuration.image = UIImage(systemName: "plus")
        configuration.baseBackgroundColor =
            UIColor(named: "BrandPrimary") ?? .systemPurple
        configuration.cornerStyle = .capsule

        let button = UIButton(configuration: configuration)

        button.accessibilityLabel = "Add another item"
        button.translatesAutoresizingMaskIntoConstraints = false

        button.addTarget(
            self,
            action: #selector(didTapAddItem),
            for: .touchUpInside
        )

        return button
    }()
    
    //MARK: - BUTTONS FUNCTIONS
    
    @objc private func didTapAddItem() {
        let addVC = AddClothingViewController()

        addVC.onSave = { [weak self] newItem -> Bool in
            guard let self,
                  let clothingStore = self.clothingStore else {
                return false
            }

            do {
                try clothingStore.save(newItem)

                self.items.append(newItem)

                self.items.sort {
                    $0.name.localizedCaseInsensitiveCompare($1.name)
                        == .orderedAscending
                }

                self.collectionView.reloadData()
                self.updateEmptyState()

                return true

            } catch {
                print("Error saving clothing: \(error)")
                return false
            }
        }

        navigationController?.pushViewController(
            addVC,
            animated: true
        )
    }
    
    // MARK: - CRUD
    private func editItem(_ item: ClothingItem) {
        let editVC = AddClothingViewController()
        editVC.editingItem = item

        // MARK: - Update

        editVC.onSave = { [weak self] updatedItem -> Bool in
            guard let self,
                  let clothingStore = self.clothingStore else {
                return false
            }

            do {
                try clothingStore.update(updatedItem)
                self.loadSavedItems()
                return true

            } catch {
                print("Update failed: \(error)")
                return false
            }
        }

        // MARK: - Delete

        editVC.onDelete = { [weak self] item -> Bool in
            guard let self,
                  let clothingStore = self.clothingStore else {
                return false
            }

            do {
                try clothingStore.delete(id: item.id)
                self.loadSavedItems()
                return true

            } catch {
                print("Delete failed: \(error)")
                return false
            }
        }

        // MARK: - Navigation

        navigationController?.pushViewController(
            editVC,
            animated: true
        )
    }

    //MARK: - FILTER
    
    private var selectedFilter: ClothingCategory?

    private var filteredItems: [ClothingItem] {
        guard let selectedFilter else {
            return items
        }

        return items.filter {
            $0.category == selectedFilter
        }
    }
    
    private let filterScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    private let filterStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private var filterButtons: [UIButton] = []
    
    private func addFilterButton(
        title: String,
        index: Int
    ) {
        var config = UIButton.Configuration.filled()

        config.title = title
        config.cornerStyle = .capsule
        config.contentInsets = NSDirectionalEdgeInsets(
            top: 8,
            leading: 16,
            bottom: 8,
            trailing: 16
        )

        let button = UIButton(configuration: config)
        button.tag = index

        button.addTarget(
            self,
            action: #selector(didTapFilter(_:)),
            for: .touchUpInside
        )

        filterButtons.append(button)
        filterStackView.addArrangedSubview(button)
    }
    
    private func setupFilters() {
        view.addSubview(filterScrollView)
        filterScrollView.addSubview(filterStackView)

        addFilterButton(title: "All", index: 0)

        for (index, category) in
            ClothingCategory.allCases.enumerated() {

            addFilterButton(
                title: category.rawValue.capitalized,
                index: index + 1
            )
        }

        NSLayoutConstraint.activate([
            filterStackView.leadingAnchor.constraint(
                equalTo: filterScrollView.contentLayoutGuide.leadingAnchor,
                constant: 20
            ),
            filterStackView.trailingAnchor.constraint(
                equalTo: filterScrollView.contentLayoutGuide.trailingAnchor,
                constant: -20
            ),
            filterStackView.topAnchor.constraint(
                equalTo: filterScrollView.contentLayoutGuide.topAnchor
            ),
            filterStackView.bottomAnchor.constraint(
                equalTo: filterScrollView.contentLayoutGuide.bottomAnchor
            ),
            filterStackView.heightAnchor.constraint(
                equalTo: filterScrollView.frameLayoutGuide.heightAnchor
            )
        ])

        updateFilterAppearance()
    }

    @objc private func didTapFilter(_ sender: UIButton) {
        if sender.tag == 0 {
            selectedFilter = nil
        } else {
            selectedFilter = ClothingCategory.allCases[
                sender.tag - 1
            ]
        }

        updateFilterAppearance()
        collectionView.reloadData()
        updateEmptyState()
    }
    
    private func updateFilterAppearance() {
        let brandColor = UIColor(named: "BrandPrimary") ?? .systemPurple
        for (index, button) in filterButtons.enumerated() {
            let isSelected: Bool

            if index == 0 {
                isSelected = selectedFilter == nil
            } else {
                isSelected = selectedFilter ==
                    ClothingCategory.allCases[index - 1]
            }

            var config = button.configuration

            config?.baseBackgroundColor = isSelected
                ? brandColor
                : .secondarySystemGroupedBackground

            config?.baseForegroundColor = isSelected
                ? .white
                : .secondaryLabel
            
            //filtros não selecionados
            config?.background.strokeColor = isSelected
            ? .clear
            : .separator
            
            config?.background.strokeWidth = isSelected ? 0 : 1

            button.configuration = config

            button.accessibilityTraits = isSelected
                ? [.button, .selected]
                : [.button]
        }
    }
    
    //MARK: - VIEW
    private func updateEmptyState() {
        let isEmpty = filteredItems.isEmpty

        collectionView.isHidden = isEmpty
        addAnotherButton.isHidden = isEmpty
        emptyStateStack.isHidden = !isEmpty
        
        if items.isEmpty {
            messageLabel.text = "Your wardrobe is empty."
        } else if let selectedFilter, filteredItems.isEmpty {
            messageLabel.text =
                "No \(selectedFilter.rawValue.lowercased()) yet."
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(
            true,
            animated: animated
        )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        setupFilters()
        setupConstraints()
        updateEmptyState()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        loadSavedItems()
    }
    
    private func loadSavedItems() {
        do {
            if clothingStore == nil {
                clothingStore = try ClothingStore()
            }

            guard let clothingStore else {
                return
            }

            items = try clothingStore.loadItems()

            collectionView.reloadData()
            updateEmptyState()

        } catch {
            let alert = UIAlertController(
                title: "Storage Error",
                message: "Could not load your wardrobe. \(error.localizedDescription)",
                preferredStyle: .alert
            )

            alert.addAction(
                UIAlertAction(title: "OK", style: .default)
            )

            present(alert, animated: true)
        }
    }
    
    func wardrobeItemsSnapshot() throws -> [ClothingItem] {
        if clothingStore == nil {
            clothingStore = try ClothingStore()
        }

        guard let clothingStore else {
            return []
        }

        return try clothingStore.loadItems()
    }
    
    func openAddClothing() {
        didTapAddItem()
    }

    private func setupViews() {
        view.backgroundColor = .systemBackground

        view.addSubview(titleStack)
        view.addSubview(collectionView)
        view.addSubview(emptyStateStack)
        view.addSubview(addAnotherButton)
        collectionView.contentInset.bottom = 88
    }
    
    private func setupConstraints() {

        let preferredCenterY = emptyStateStack.centerYAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.centerYAnchor
        )

        preferredCenterY.priority = .defaultHigh

        NSLayoutConstraint.activate([

            // MARK: - Title Stack

            titleStack.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 24
            ),

            titleStack.leadingAnchor.constraint(
                equalTo: view.layoutMarginsGuide.leadingAnchor
            ),

            titleStack.trailingAnchor.constraint(
                equalTo: view.layoutMarginsGuide.trailingAnchor
            ),

            // MARK: - Empty State

            preferredCenterY,

            emptyStateStack.topAnchor.constraint(
                greaterThanOrEqualTo: titleStack.bottomAnchor,
                constant: 24
            ),

            emptyStateStack.leadingAnchor.constraint(
                equalTo: view.layoutMarginsGuide.leadingAnchor
            ),

            emptyStateStack.trailingAnchor.constraint(
                equalTo: view.layoutMarginsGuide.trailingAnchor
            ),

            messageLabel.widthAnchor.constraint(
                equalTo: emptyStateStack.widthAnchor
            ),

            emptyStateImage.widthAnchor.constraint(
                equalToConstant: 80
            ),

            emptyStateImage.heightAnchor.constraint(
                equalToConstant: 80
            ),

            // MARK: - Collection View

            collectionView.topAnchor.constraint(
                equalTo: filterScrollView.bottomAnchor,
                constant: 14
            ),

            collectionView.leadingAnchor.constraint(
                equalTo: view.layoutMarginsGuide.leadingAnchor
            ),

            collectionView.trailingAnchor.constraint(
                equalTo: view.layoutMarginsGuide.trailingAnchor
            ),

            collectionView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor
            ),
            
            // MARK: - Add another clothing
            
            addAnotherButton.trailingAnchor.constraint(
                equalTo: view.layoutMarginsGuide.trailingAnchor
            ),

            addAnotherButton.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -16
            ),

            addAnotherButton.widthAnchor.constraint(
                equalToConstant: 56
            ),

            addAnotherButton.heightAnchor.constraint(
                equalToConstant: 56
            ),
            
            //MARK: - Filters
            
            filterScrollView.topAnchor.constraint(
                equalTo: subtitleLabel.bottomAnchor,
                constant: 18
            ),

            filterScrollView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),

            filterScrollView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),

            filterScrollView.heightAnchor.constraint(
                equalToConstant: 44
            )
        ])
    }
}

extension ViewController: UICollectionViewDataSource {

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return filteredItems.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ClothingCell.reuseIdentifier,
            for: indexPath
        ) as! ClothingCell

        let item = filteredItems[indexPath.item]
        cell.configure(with: item)

        return cell
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {

        let horizontalPadding: CGFloat = 40
        let spacing: CGFloat = 12

        let availableWidth = collectionView.bounds.width
            - horizontalPadding - spacing

        let width = floor(availableWidth / 2)

        let imageHeight = width * 1.18
        let textHeight: CGFloat = 84

        return CGSize(
            width: width,
            height: ceil(imageHeight + textHeight)
        )
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        let item = filteredItems[indexPath.item]
        editItem(item)
    }
}

