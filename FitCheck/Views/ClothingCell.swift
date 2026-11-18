//
//  ClothingCell.swift
//  FitCheck
//
//  Created by Camilla Carvalho Peixoto on 12/11/26.
//


import UIKit

final class ClothingCell: UICollectionViewCell {

    static let reuseIdentifier = "ClothingCell"

    // MARK: - Views

    private let photoView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .tertiarySystemGroupedBackground
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let placeholderView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .tertiaryLabel
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFontMetrics(
            forTextStyle: .subheadline
        ).scaledFont(
            for: .systemFont(ofSize: 15, weight: .semibold)
        )
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .label
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .caption1)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupViews() {
        backgroundColor = .clear

        contentView.backgroundColor = .secondarySystemGroupedBackground
        contentView.layer.cornerRadius = 18
        contentView.layer.cornerCurve = .continuous
        contentView.clipsToBounds = true

        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.08
        layer.shadowRadius = 8
        layer.shadowOffset = CGSize(width: 0, height: 3)

        contentView.addSubview(photoView)
        photoView.addSubview(placeholderView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(categoryLabel)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            photoView.topAnchor.constraint(
                equalTo: contentView.topAnchor
            ),
            photoView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor
            ),
            photoView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor
            ),
            photoView.heightAnchor.constraint(
                equalTo: photoView.widthAnchor,
                multiplier: 1.18
            ),

            placeholderView.centerXAnchor.constraint(
                equalTo: photoView.centerXAnchor
            ),
            placeholderView.centerYAnchor.constraint(
                equalTo: photoView.centerYAnchor
            ),
            placeholderView.widthAnchor.constraint(
                equalToConstant: 52
            ),
            placeholderView.heightAnchor.constraint(
                equalToConstant: 52
            ),

            nameLabel.topAnchor.constraint(
                equalTo: photoView.bottomAnchor,
                constant: 10
            ),
            nameLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 12
            ),
            nameLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -12
            ),

            categoryLabel.topAnchor.constraint(
                equalTo: nameLabel.bottomAnchor,
                constant: 4
            ),
            categoryLabel.leadingAnchor.constraint(
                equalTo: nameLabel.leadingAnchor
            ),
            categoryLabel.trailingAnchor.constraint(
                equalTo: nameLabel.trailingAnchor
            ),
            categoryLabel.bottomAnchor.constraint(
                lessThanOrEqualTo: contentView.bottomAnchor,
                constant: -10
            )
        ])
    }

    // MARK: - Configuration

    func configure(with item: ClothingItem) {
        nameLabel.text = item.name
        categoryLabel.text = item.category.rawValue.capitalized

        if let data = item.photoData,
           let image = UIImage(data: data) {
            photoView.image = image
            placeholderView.isHidden = true
        } else {
            photoView.image = nil
            placeholderView.image = UIImage(
                systemName: item.symbolName
            ) ?? UIImage(systemName: "hanger")
            placeholderView.isHidden = false
        }

        isAccessibilityElement = true
        accessibilityLabel = "\(item.name), \(item.category.rawValue)"
        accessibilityTraits = .button
    }

    // MARK: - Reuse

    override func prepareForReuse() {
        super.prepareForReuse()

        photoView.image = nil
        placeholderView.image = nil
        placeholderView.isHidden = false
        nameLabel.text = nil
        categoryLabel.text = nil
        accessibilityLabel = nil
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        layer.shadowPath = UIBezierPath(
            roundedRect: bounds,
            cornerRadius: 18
        ).cgPath
    }
}
