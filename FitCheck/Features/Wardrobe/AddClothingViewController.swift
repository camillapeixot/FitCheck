//
//  AddClothingViewController.swift
//  FitCheck
//
//  Created by Camilla Carvalho Peixoto on 13/11/26.
//


import UIKit
import PhotosUI

final class AddClothingViewController: UIViewController {
    var onSave: ((ClothingItem) -> Void)?
    
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
        let button = UIButton(type: .system)

        let actions = ClothingCategory.allCases.map { category in
            UIAction(title: category.rawValue) { [weak self] _ in
                self?.selectedCategory = category
                self?.categoryButton.setTitle(
                    category.rawValue,
                    for: .normal
                )
            }
        }

        button.setTitle(selectedCategory.rawValue, for: .normal)
        button.menu = UIMenu(children: actions)
        button.showsMenuAsPrimaryAction = true
        button.translatesAutoresizingMaskIntoConstraints = false

        return button
    }()
    
    private let clothingImageView: UIImageView = {
        let imageView = UIImageView()

        imageView.image = UIImage(systemName: "photo")
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .secondaryLabel
        imageView.clipsToBounds = true

        imageView.translatesAutoresizingMaskIntoConstraints = false

        return imageView
    }()
    
    private lazy var addClothingStackView: UIStackView = {
        let stack = UIStackView(
            arrangedSubviews: [
                clothingImageView,
                choosePhotoButton,
                nameTextField,
                categoryButton,
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
        configuration.title = "Choose Photo"
        configuration.image = UIImage(systemName: "photo.on.rectangle")
        configuration.imagePadding = 8

        let button = UIButton(configuration: configuration)

        button.addTarget(
            self,
            action: #selector(didTapChoosePhoto),
            for: .touchUpInside
        )

        return button
    }()

    private lazy var saveButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.title = "Save Item"
        configuration.baseBackgroundColor = .systemPurple

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
            id: UUID(),
            name: name,
            category: selectedCategory,
            symbolName: "tshirt",
            photoData: photoData
        )

        onSave?(newItem)
        dismiss(animated: true)
    }
    
    @objc private func didTapCancel() {
        dismiss(animated: true)
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

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        setupConstraints()
    }
    
    private func setupViews() {
        title = "Add Clothing"
        view.backgroundColor = .systemBackground

        // navigation bar
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(didTapCancel)
        )

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
                equalTo: view.safeAreaLayoutGuide.bottomAnchor
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
                equalToConstant: 180
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

//#Preview {
//    return AddClothingViewController()
//}

