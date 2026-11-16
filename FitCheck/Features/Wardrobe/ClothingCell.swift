//
//  ClothingCell.swift
//  FitCheck
//
//  Created by Camilla Carvalho Peixoto on 12/11/26.
//

import UIKit

final class ClothingCell: UICollectionViewCell {

    static let reuseIdentifier = "ClothingCell"

    private let symbolView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemPurple
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 2
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupViews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.backgroundColor = .secondarySystemBackground
        contentView.layer.cornerRadius = 12

        contentView.addSubview(symbolView)
        contentView.addSubview(nameLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([

            // MARK: - Symbol View

            symbolView.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: 16
            ),

            symbolView.centerXAnchor.constraint(
                equalTo: contentView.centerXAnchor
            ),

            symbolView.widthAnchor.constraint(
                equalToConstant: 60
            ),

            symbolView.heightAnchor.constraint(
                equalToConstant: 60
            ),

            // MARK: - Name Label

            nameLabel.topAnchor.constraint(
                equalTo: symbolView.bottomAnchor,
                constant: 12
            ),

            nameLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 8
            ),

            nameLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -8
            ),

            nameLabel.bottomAnchor.constraint(
                lessThanOrEqualTo: contentView.bottomAnchor,
                constant: -12
            )
        ])
    }

    func configure(with item: ClothingItem) {
        nameLabel.text = item.name

        if let data = item.photoData,
           let image = UIImage(data: data) {
            symbolView.image = image
        } else {
            symbolView.image = UIImage(systemName: item.symbolName)
        }
    }
}
