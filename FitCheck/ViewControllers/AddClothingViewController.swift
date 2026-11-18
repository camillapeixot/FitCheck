//
//  AddClothingViewController.swift
//  FitCheck
//
//  Created by Camilla Carvalho Peixoto on 13/11/26.
//


import UIKit
import PhotosUI

final class AddClothingViewController: UIViewController {
    var onSave: ((ClothingItem) -> Bool)?
    var onDelete: ((ClothingItem) -> Bool)?
    
    var editingItem: ClothingItem?
    
    private func configureForEditing() {
        guard let item = editingItem else { return }

        nameTextField.text = item.name
        selectedCategory = item.category

        var configuration = categoryButton.configuration
        configuration?.title = item.category.rawValue
        categoryButton.configuration = configuration

        if let data = item.photoData,
           let image = UIImage(data: data) {
            selectedImage = image
            clothingImageView.image = image
            clothingImageView.contentMode = .scaleAspectFill
        }

        var saveConfiguration = saveButton.configuration
        saveConfiguration?.title = "Save Changes"
        saveButton.configuration = saveConfiguration
    }
    
    private let nameTextField: UITextField = {
        let field = UITextField()

        field.placeholder = "e.g. White T-Shirt"
        field.borderStyle = .roundedRect
        field.autocapitalizationType = .words
        field.returnKeyType = .done

        field.translatesAutoresizingMaskIntoConstraints = false

        return field
    }()
    
    private func validateName() -> Bool {
        let name = nameTextField.text?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        return !name.isEmpty
    }
    
    private var selectedCategory: ClothingCategory = .tops

    private lazy var categoryButton: UIButton = {
        var configuration = UIButton.Configuration.plain()

        configuration.title = selectedCategory.rawValue
//        configuration.image = UIImage(systemName: "tshirt")
        configuration.imagePlacement = .leading
        configuration.imagePadding = 12

        configuration.baseForegroundColor =
            UIColor(named: "InkPrimary") ?? .label

        configuration.background.backgroundColor =
            UIColor(named: "BackgroundWarm") ?? .secondarySystemGroupedBackground

        configuration.background.strokeColor = .separator
        configuration.background.strokeWidth = 1
        configuration.background.cornerRadius = 14

        configuration.contentInsets = NSDirectionalEdgeInsets(
            top: 12,
            leading: 16,
            bottom: 12,
            trailing: 44
        )

        let button = UIButton(configuration: configuration)

        button.contentHorizontalAlignment = .leading
        button.translatesAutoresizingMaskIntoConstraints = false

        let actions = ClothingCategory.allCases.map { category in
            UIAction(title: category.rawValue) { [weak self] _ in
                guard let self else { return }

                self.selectedCategory = category

                var updatedConfiguration = self.categoryButton.configuration
                updatedConfiguration?.title = category.rawValue
                self.categoryButton.configuration = updatedConfiguration
            }
        }

        button.menu = UIMenu(children: actions)
        button.showsMenuAsPrimaryAction = true

        let chevronImageView = UIImageView(
            image: UIImage(systemName: "chevron.right")
        )

        chevronImageView.tintColor = .secondaryLabel
        chevronImageView.translatesAutoresizingMaskIntoConstraints = false
        chevronImageView.isUserInteractionEnabled = false

        button.addSubview(chevronImageView)

        NSLayoutConstraint.activate([
            chevronImageView.trailingAnchor.constraint(
                equalTo: button.trailingAnchor,
                constant: -16
            ),

            chevronImageView.centerYAnchor.constraint(
                equalTo: button.centerYAnchor
            )
        ])

        return button
    }()

    private let clothingImageView: UIImageView = {
        let imageView = UIImageView()

        imageView.image = UIImage(systemName: "photo")
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .secondaryLabel
        imageView.clipsToBounds = true
        imageView.backgroundColor = .secondarySystemGroupedBackground
        imageView.layer.cornerRadius = 18

        imageView.translatesAutoresizingMaskIntoConstraints = false

        return imageView
    }()
    
    private lazy var addClothingStackView: UIStackView = {
        let stack = UIStackView(
            arrangedSubviews: [
                clothingImageView,
                photoButtonsStackView,
                nameTextField,
                categoryFieldStackView,
                saveButton
            ]
        )
        
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        return stack
    }()
    
    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.keyboardDismissMode = .interactive
        return scroll
    }()
    
    private lazy var choosePhotoButton: UIButton = {
        var configuration = UIButton.Configuration.bordered()

        configuration.title = "Choose from\nLibrary"
        configuration.image = UIImage(systemName: "photo.on.rectangle")
        configuration.imagePlacement = .top
        configuration.imagePadding = 8
        configuration.cornerStyle = .large
        configuration.baseForegroundColor =
            UIColor(named: "BrandPrimary") ?? .systemPurple
        configuration.contentInsets = NSDirectionalEdgeInsets(
            top: 16,
            leading: 14,
            bottom: 16,
            trailing: 14
        )

        let button = UIButton(configuration: configuration)

        button.titleLabel?.numberOfLines = 2
        button.titleLabel?.textAlignment = .center

        button.addTarget(
            self,
            action: #selector(didTapChoosePhoto),
            for: .touchUpInside
        )

        return button
    }()
    
    private lazy var takePhotoButton: UIButton = {
        var configuration = UIButton.Configuration.bordered()

        configuration.title = "Take Photo"
        configuration.image = UIImage(systemName: "camera")
        configuration.imagePlacement = .top
        configuration.imagePadding = 8
        configuration.cornerStyle = .large
        configuration.baseForegroundColor =
            UIColor(named: "BrandPrimary") ?? .systemPurple

        let button = UIButton(configuration: configuration)

        button.addTarget(
            self,
            action: #selector(didTapTakePhoto),
            for: .touchUpInside
        )

        return button
    }()

    private lazy var saveButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.title = "Save Item"
        configuration.baseBackgroundColor =
            UIColor(named: "BrandPrimary") ?? .systemPurple

        let button = UIButton(configuration: configuration)

        button.addTarget(
            self,
            action: #selector(didTapSave),
            for: .touchUpInside
        )

        return button
    }()
    
    @objc private func didTapChoosePhoto() {
        openPhotoPicker()
    }
    
    @objc private func didTapTakePhoto() {
        openCamera()
    }

    private func openPhotoPicker() {
        var configuration = PHPickerConfiguration()

        configuration.filter = .images
        configuration.selectionLimit = 1

        let picker = PHPickerViewController(
            configuration: configuration
        )

        picker.delegate = self
        present(picker, animated: true)
    }
    
    private func openCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            let alert = UIAlertController(
                title: "Camera unavailable",
                message: "This device does not have an available camera.",
                preferredStyle: .alert
            )

            alert.addAction(UIAlertAction(
                title: "OK",
                style: .default
            ))

            present(alert, animated: true)
            return
        }

        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        picker.allowsEditing = false

        present(picker, animated: true)
    }
    
    private lazy var photoButtonsStackView: UIStackView = {
        let stack = UIStackView(
            arrangedSubviews: [
                takePhotoButton,
                choosePhotoButton
            ]
        )

        stack.axis = .horizontal
        stack.spacing = 12
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false

        return stack
    }()
    
    private let categoryLabel: UILabel = {
        let label = UILabel()

        label.text = "Category"
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()

    private lazy var categoryFieldStackView: UIStackView = {
        let stack = UIStackView(
            arrangedSubviews: [
                categoryLabel,
                categoryButton
            ]
        )

        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false

        return stack
    }()

    private var selectedImage: UIImage?
    
    @objc private func didTapSave() {
        guard validateName() else {
            showAlert(message: "Please enter an item name.")
            return
        }

        guard selectedImage != nil else {
            showAlert(message: "Please choose a photo.")
            return
        }

        let name = nameTextField.text?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        guard let image = selectedImage,
              let photoData = image.jpegData(compressionQuality: 0.8)
        else {
            showAlert(message: "Please choose a valid photo.")
            return
        }

        let newItem = ClothingItem(
            id: editingItem?.id ?? UUID(),
            name: name,
            category: selectedCategory,
            symbolName: "tshirt",
            photoData: photoData
        )

        guard onSave?(newItem) == true else {
            showAlert(
                message: "Could not save this item. Please try again."
            )
            return
        }

        navigationController?.popViewController(
            animated: true
        )
    }
    
    @objc private func didTapDelete() {
        guard let item = editingItem else { return }

        let alert = UIAlertController(
            title: "Delete Clothing?",
            message: "Are you sure you want to delete \(item.name)? This action cannot be undone.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(
            title: "Cancel",
            style: .cancel
        ))

        alert.addAction(UIAlertAction(
            title: "Delete",
            style: .destructive
        ) { [weak self] _ in
            guard let self else { return }

            if self.onDelete?(item) == true {
                self.navigationController?.popViewController(
                    animated: true
                )
            } else {
                self.showAlert(
                    message: "Could not delete this item. Please try again."
                )
            }
        })

        present(alert, animated: true)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(
            title: "Fit Check",
            message: message,
            preferredStyle: .alert
        )

        alert.addAction(
            UIAlertAction(title: "OK", style: .default)
        )

        present(alert, animated: true)
    }
    
    @objc private func keyboardDidShow() {
        guard nameTextField.isFirstResponder else {
            return
        }

        view.layoutIfNeeded()

        let textFieldRect = nameTextField.convert(
            nameTextField.bounds,
            to: scrollView
        )

        let visibleRect = textFieldRect.insetBy(
            dx: 0,
            dy: -20
        )

        scrollView.scrollRectToVisible(
            visibleRect,
            animated: true
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func setupNavigationBar() {
        navigationItem.title = editingItem == nil
            ? "Add Clothing"
            : "Edit Clothing"

        navigationItem.largeTitleDisplayMode = .never

        navigationController?.navigationBar.tintColor =
            UIColor(named: "BrandPrimary") ?? .systemPurple

        if editingItem != nil {
            let deleteButton = UIBarButtonItem(
                image: UIImage(systemName: "trash"),
                style: .plain,
                target: self,
                action: #selector(didTapDelete)
            )

            deleteButton.tintColor = .systemRed
            deleteButton.accessibilityLabel = "Delete clothing item"

            navigationItem.rightBarButtonItem = deleteButton
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        setupConstraints()
        configureForEditing()
        setupNavigationBar()
        
        NotificationCenter.default.addObserver(
                self,
                selector: #selector(keyboardDidShow),
                name: UIResponder.keyboardDidShowNotification,
                object: nil
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(
            false,
            animated: animated
        )
    }
    
    private func setupViews() {
        view.backgroundColor = .systemBackground
        
        // hierarchy
        view.addSubview(scrollView)
        scrollView.addSubview(addClothingStackView)

        nameTextField.delegate = self
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([

            // MARK: - Scroll View

            scrollView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor
            ),

            scrollView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),

            scrollView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),

            scrollView.bottomAnchor.constraint(
                equalTo: view.keyboardLayoutGuide.topAnchor
            ),

            // MARK: - Stack View

            addClothingStackView.topAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.topAnchor,
                constant: 24
            ),

            addClothingStackView.leadingAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.leadingAnchor,
                constant: 20
            ),

            addClothingStackView.trailingAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.trailingAnchor,
                constant: -20
            ),

            addClothingStackView.bottomAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.bottomAnchor,
                constant: -24
            ),

            addClothingStackView.widthAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.widthAnchor,
                constant: -40
            ),

            // MARK: - Component Sizes

            clothingImageView.heightAnchor.constraint(
                equalToConstant: 240
            ),
            
            photoButtonsStackView.heightAnchor.constraint(
                equalToConstant: 116
            ),
            
            nameTextField.heightAnchor.constraint(
                equalToConstant: 48
            ),

            categoryButton.heightAnchor.constraint(
                equalToConstant: 48
            ),

            saveButton.heightAnchor.constraint(
                equalToConstant: 50
            )
        ])
    }


}

extension AddClothingViewController: PHPickerViewControllerDelegate {

    func picker(
        _ picker: PHPickerViewController,
        didFinishPicking results: [PHPickerResult]
    ) {
        picker.dismiss(animated: true)

        guard let result = results.first else {
            return
        }

        let provider = result.itemProvider

        guard provider.canLoadObject(ofClass: UIImage.self) else {
            return
        }

        provider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
            guard let image = object as? UIImage else {
                return
            }

            DispatchQueue.main.async {
                self?.selectedImage = image
                self?.clothingImageView.image = image
                self?.clothingImageView.contentMode = .scaleAspectFill
            }
        }
    }
}

extension AddClothingViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension AddClothingViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        if let image = info[.originalImage] as? UIImage {
            selectedImage = image
            clothingImageView.image = image
            clothingImageView.contentMode = .scaleAspectFill
        }

        picker.dismiss(animated: true)
    }


    func imagePickerControllerDidCancel(
        _ picker: UIImagePickerController
    ) {
        picker.dismiss(animated: true)
    }
}

//#Preview {
//    return AddClothingViewController()
//}

