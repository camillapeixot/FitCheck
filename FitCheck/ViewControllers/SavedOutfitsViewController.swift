//
//  SavedOutfitsViewController.swift
//  FitCheck
//
//  Created by Camilla Carvalho Peixoto on 18/11/26.
//

import UIKit

@MainActor
final class SavedOutfitsViewController: UIViewController {
    var onLoadOutfits: (() throws -> [SavedOutfit])?
    var onDeleteOutfit: ((UUID) throws -> Void)?
    var onLoadWardrobe: (() throws -> [ClothingItem])?

    private var savedOutfits: [SavedOutfit] = []
    private var wardrobeItems: [ClothingItem] = []

    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.backgroundColor = .clear
        table.rowHeight = 88
        table.dataSource = self
        table.delegate = self
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()

    private let emptyView: UIStackView = {
        let image = UIImageView(image: UIImage(systemName: "bookmark"))
        image.tintColor = UIColor(named: "BrandPrimary") ?? .systemPurple
        image.contentMode = .scaleAspectFit
        image.heightAnchor.constraint(equalToConstant: 55).isActive = true

        let title = UILabel()
        title.text = "No saved looks yet"
        title.textAlignment = .center
        title.textColor = .label
        title.font = .preferredFont(forTextStyle: .headline)

        let subtitle = UILabel()
        subtitle.text = "Create a look or save a Surprise Me combination to see it here."
        subtitle.textAlignment = .center
        subtitle.textColor = .secondaryLabel
        subtitle.font = .preferredFont(forTextStyle: .subheadline)
        subtitle.numberOfLines = 0

        let stack = UIStackView(arrangedSubviews: [image, title, subtitle])
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Saved Looks"
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        view.addSubview(emptyView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            emptyView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            emptyView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 34),
            emptyView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -34)
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reloadSavedLooks()
    }

    private func reloadSavedLooks() {
        guard let onLoadOutfits, let onLoadWardrobe else {
            presentError("Saved looks aren't configured yet.")
            return
        }

        do {
            savedOutfits = try onLoadOutfits()
            wardrobeItems = try onLoadWardrobe()
            tableView.reloadData()
            let empty = savedOutfits.isEmpty
            emptyView.isHidden = !empty
            tableView.isHidden = empty
        } catch {
            presentError("Couldn't load saved looks: \(error.localizedDescription)")
        }
    }

    private func presentError(_ message: String) {
        let alert = UIAlertController(title: "Fit Check", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension SavedOutfitsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        savedOutfits.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "SavedOutfitCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier)
            ?? UITableViewCell(style: .subtitle, reuseIdentifier: identifier)

        let saved = savedOutfits[indexPath.row]
        let available = saved.availableItems(in: wardrobeItems)
        cell.textLabel?.text = saved.name
        cell.textLabel?.font = .preferredFont(forTextStyle: .headline)
        cell.detailTextLabel?.text = "\(available.count)/\(saved.totalPieces) pieces available • \(saved.createdAt.formatted(date: .abbreviated, time: .omitted))"
        cell.detailTextLabel?.textColor = available.count == saved.totalPieces ? .secondaryLabel : .systemOrange
        cell.detailTextLabel?.font = .preferredFont(forTextStyle: .caption1)

        let thumbnail = available.first?.photoData.flatMap { UIImage(data: $0) }
        cell.imageView?.image = thumbnail ?? UIImage(systemName: "hanger")
        cell.imageView?.tintColor = UIColor(named: "BrandPrimary") ?? .systemPurple
        cell.imageView?.contentMode = .scaleAspectFill
        cell.imageView?.clipsToBounds = true
        cell.imageView?.layer.cornerRadius = 9
        cell.accessoryType = .disclosureIndicator
        cell.accessibilityLabel = "\(saved.name), \(available.count) of \(saved.totalPieces) pieces available"
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let details = SavedOutfitDetailViewController(
            outfit: savedOutfits[indexPath.row],
            wardrobe: wardrobeItems
        )
        details.onDelete = onDeleteOutfit
        navigationController?.pushViewController(details, animated: true)
    }
}
