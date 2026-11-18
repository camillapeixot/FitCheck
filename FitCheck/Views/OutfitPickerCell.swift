//
//  OutfitPickerCell.swift
//  FitCheck
//
//  Created by Camilla Carvalho Peixoto on 18/11/26.
//

import UIKit

final class OutfitPickerCell: UICollectionViewCell {
    static let reuseIdentifier = "OutfitPickerCell"

    private let photoView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let selectionIndicator: UIImageView = {
        let view = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
        view.tintColor = UIColor(named: "BrandPrimary") ?? .systemPurple
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 11
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.layer.cornerRadius = 14
        contentView.layer.cornerCurve = .continuous
        contentView.clipsToBounds = true
        contentView.backgroundColor = .secondarySystemGroupedBackground
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.separator.withAlphaComponent(0.25).cgColor

        contentView.addSubview(photoView)
        contentView.addSubview(selectionIndicator)
        NSLayoutConstraint.activate([
            photoView.topAnchor.constraint(equalTo: contentView.topAnchor),
            photoView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            photoView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            photoView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            selectionIndicator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -6),
            selectionIndicator.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            selectionIndicator.widthAnchor.constraint(equalToConstant: 22),
            selectionIndicator.heightAnchor.constraint(equalToConstant: 22)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with item: ClothingItem, selected: Bool) {
        if let data = item.photoData, let image = UIImage(data: data) {
            photoView.image = image
            photoView.contentMode = .scaleAspectFill
        } else {
            photoView.image = UIImage(systemName: item.symbolName)
            photoView.contentMode = .scaleAspectFit
            photoView.tintColor = .secondaryLabel
        }

        contentView.layer.borderWidth = selected ? 2 : 1
        contentView.layer.borderColor = selected
            ? (UIColor(named: "BrandPrimary") ?? .systemPurple).cgColor
            : UIColor.separator.withAlphaComponent(0.25).cgColor
        selectionIndicator.isHidden = !selected

        isAccessibilityElement = true
        accessibilityLabel = "\(item.name), \(item.category.rawValue)"
        accessibilityTraits = selected ? [.button, .selected] : [.button]
        accessibilityHint = "Double tap to \(selected ? "remove" : "select") this item"
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        photoView.image = nil
        selectionIndicator.isHidden = true
        contentView.layer.borderWidth = 1
        accessibilityLabel = nil
    }
}
