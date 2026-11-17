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

        let navigationController = UINavigationController(
            rootViewController: addVC
        )

        present(navigationController, animated: true)
    }
    
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
        
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        collection.backgroundColor = .systemBackground
        collection.translatesAutoresizingMaskIntoConstraints = false
        
        collection.dataSource = self
        collection.delegate = self
        
        collection.register(ClothingCell.self, forCellWithReuseIdentifier: ClothingCell.reuseIdentifier)
        
        return collection
    }()
    
    private func updateEmptyState() {
        let hasItems = !items.isEmpty

        collectionView.isHidden = !hasItems
        addAnotherButton.isHidden = !hasItems
        emptyStateStack.isHidden = hasItems
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
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

    private func setupViews() {
        view.backgroundColor = .systemBackground

        view.addSubview(titleStack)
        view.addSubview(collectionView)
        view.addSubview(emptyStateStack)
        view.addSubview(addAnotherButton)
        collectionView.contentInset.bottom = 88
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(didTapAddItem)
        )
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
                equalTo: titleStack.bottomAnchor,
                constant: 24
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
            )
        ])
    }
}

extension ViewController: UICollectionViewDataSource {

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return items.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ClothingCell.reuseIdentifier,
            for: indexPath
        ) as! ClothingCell

        let item = items[indexPath.item]
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

        let spacing: CGFloat = 12
        let availableWidth = collectionView.bounds.width - spacing
        let itemWidth = availableWidth / 2

        return CGSize(
            width: itemWidth,
            height: 150
        )
    }
}

