//
//  OutfitPreviewView.swift
//  FitCheck
//
//  Created by Camilla Carvalho Peixoto on 18/11/26.
//

import UIKit

final class OutfitPreviewView: UIView {
    private let topSlot = OutfitSlotView(title: "Tops", symbol: "tshirt", compact: false)
    private let bottomSlot = OutfitSlotView(title: "Bottoms", symbol: "square.grid.2x2", compact: false)
    private let shoesSlot = OutfitSlotView(title: "Shoes", symbol: "shoeprints.fill", compact: true)
    private let accessoryOneSlot = OutfitSlotView(title: "Accessory", symbol: "sparkles", compact: true)
    private let accessoryTwoSlot = OutfitSlotView(title: "Accessory", symbol: "bag", compact: true)

    private lazy var mainColumn: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [topSlot, bottomSlot])
        stack.axis = .vertical
        stack.spacing = 8
        stack.distribution = .fillEqually
        return stack
    }()

    private lazy var sideColumn: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            accessoryOneSlot, accessoryTwoSlot, shoesSlot
        ])
        stack.axis = .vertical
        stack.spacing = 8
        stack.distribution = .fillEqually
        return stack
    }()

    private lazy var columns: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [mainColumn, sideColumn])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .secondarySystemGroupedBackground
        layer.cornerRadius = 20
        layer.cornerCurve = .continuous

        addSubview(columns)
        NSLayoutConstraint.activate([
            columns.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            columns.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            columns.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            columns.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            sideColumn.widthAnchor.constraint(equalTo: columns.widthAnchor, multiplier: 0.31)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(items: [ClothingItem]) {
        let accessories = items.filter { $0.category == .accessories }

        topSlot.configure(with: items.first { $0.category == .tops })
        bottomSlot.configure(with: items.first { $0.category == .bottoms })
        shoesSlot.configure(with: items.first { $0.category == .shoes })
        accessoryOneSlot.configure(with: accessories.first)
        accessoryTwoSlot.configure(with: accessories.count > 1 ? accessories[1] : nil)
    }
}

private final class OutfitSlotView: UIView {
    private let title: String
    private let symbol: String
    private let compact: Bool
    
    private let imageView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.clipsToBounds = true
        image.contentMode = .scaleAspectFill
        return image
    }()
    
    private let symbolView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.tintColor = UIColor(named: "BrandPrimary") ?? .systemPurple
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .label
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 2
        return label
    }()
    
    private let hintLabel: UILabel = {
        let label = UILabel()
        label.text = "Select an item"
        label.textAlignment = .center
        label.font = .preferredFont(forTextStyle: .caption2)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private lazy var placeholder: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [symbolView, titleLabel, hintLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = compact ? 4 : 7
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    init(title: String, symbol: String, compact: Bool) {
        self.title = title
        self.symbol = symbol
        self.compact = compact
        super.init(frame: .zero)
        
        backgroundColor = .systemBackground
        layer.cornerRadius = 15
        layer.cornerCurve = .continuous
        clipsToBounds = true
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.separator.withAlphaComponent(0.18).cgColor
        
        titleLabel.text = title
        titleLabel.font = compact
        ? .preferredFont(forTextStyle: .caption1)
        : .preferredFont(forTextStyle: .subheadline)
        hintLabel.isHidden = compact
        symbolView.image = UIImage(systemName: symbol) ?? UIImage(systemName: "hanger")
        
        addSubview(imageView)
        addSubview(placeholder)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            placeholder.centerXAnchor.constraint(equalTo: centerXAnchor),
            placeholder.centerYAnchor.constraint(equalTo: centerYAnchor),
            placeholder.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 4),
            placeholder.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -4),
            symbolView.heightAnchor.constraint(equalToConstant: compact ? 22 : 32),
            symbolView.widthAnchor.constraint(equalToConstant: compact ? 22 : 32)
        ])
        isAccessibilityElement = true
        accessibilityLabel = "\(title), not selected"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with item: ClothingItem?) {
        guard let item else {
            imageView.image = nil
            placeholder.isHidden = false
            accessibilityLabel = "\(title), not selected"
            return
        }
        
        placeholder.isHidden = true
        if let data = item.photoData, let image = UIImage(data: data) {
            imageView.image = image
            imageView.contentMode = .scaleAspectFill
        } else {
            imageView.image = UIImage(systemName: item.symbolName)
            imageView.contentMode = .scaleAspectFit
            imageView.tintColor = UIColor(named: "BrandPrimary") ?? .systemPurple
        }
        accessibilityLabel = "\(title), \(item.name)"
    }
}
