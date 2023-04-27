//
//  CategoriesSelectingViewController.swift
//  TrackerApp
//
//  Created by Юрий Демиденко on 28.03.2023.
//

import UIKit

final class CategoriesViewController: UIViewController {

    lazy var categoryStore: CategoryStoreProtocol = CategoryStore(delegate: self)
    lazy var newCategoryViewController = NewCategoryViewController()

    var callback: ((String?) -> ())?
    private var selectedCategoryName: String?
    private var checkedCellIndexPath: IndexPath?

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Категория"
        label.font = UIFont(name: "YSDisplay-Medium", size: 16)
        label.textAlignment = .center
        return label
    }()

    private lazy var stubImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "StarIcon")
        return imageView
    }()

    private lazy var stubLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Привычки и события можно\nобъединить по смыслу"
        label.font = UIFont(name: "YSDisplay-Medium", size: 12)
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()

    private lazy var addCategoryButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .black
        button.setTitle("Добавить категорию", for: .normal)
        button.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 16)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(addCategoryButtonAction), for: .touchUpInside)
        return button
    }()

    private lazy var categoriesTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true
        tableView.register(ButtonTableCell.self, forCellReuseIdentifier: ButtonTableCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupConstraints()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        categoriesTableView.isHidden = categoryStore.numberOfItems() == 0 ? true : false
    }

    @objc private func addCategoryButtonAction() {
        newCategoryViewController.presentationController?.delegate = newCategoryViewController
        newCategoryViewController.callback = { [weak self] newCategory in
            guard let newCategory = newCategory, let self = self else { return }
            self.selectedCategoryName = newCategory
            self.uncheckCellIfNeeded()
            if let existingIndexPath = self.categoryStore.indexPath(for: newCategory) {
                self.checkCell(at: existingIndexPath)
                return
            }
            if let newIndexPath = try? self.categoryStore.save(newCategory) {
                self.checkCell(at: newIndexPath)
            }
        }
        present(newCategoryViewController, animated: true)
    }

    private func uncheckCellIfNeeded() {
        if let indexPath = checkedCellIndexPath {
            let cell = categoriesTableView.cellForRow(at: indexPath)
            cell?.accessoryType = .none
            checkedCellIndexPath = nil
        }
    }

    private func checkCell(at indexPath: IndexPath) {
        let cell = categoriesTableView.cellForRow(at: indexPath)
        cell?.accessoryType = .checkmark
        checkedCellIndexPath = indexPath
        categoriesTableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
        dismissWithCallback()
    }

    private func dismissWithCallback() {
        dismiss(animated: true) { [weak self] in
            self?.callback?(self?.selectedCategoryName)
        }
    }

    private func setupConstraints() {
        [titleLabel, stubImageView, stubLabel, categoriesTableView, addCategoryButton].forEach { view.addSubview($0) }
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            categoriesTableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            categoriesTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categoriesTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            categoriesTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -80),

            stubImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stubImageView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: -30),

            stubLabel.topAnchor.constraint(equalTo: stubImageView.bottomAnchor, constant: 8),
            stubLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            addCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    private func customizeCornersAndSeparator(for cell: UITableViewCell, at indexPath: IndexPath) {
        if indexPath.row == categoryStore.numberOfItems() - 1 {
            cell.layer.masksToBounds = true
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            cell.selectedBackgroundView?.layer.cornerRadius = 16
            cell.selectedBackgroundView?.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            cell.separatorInset = .init(top: 0, left: UIScreen.main.bounds.width, bottom: 0, right: 0)
            if categoryStore.numberOfItems() > 1 {
                let indexPathForReload = IndexPath(row: indexPath.row - 1, section: indexPath.section)
                let cellForReload = categoriesTableView.cellForRow(at: indexPathForReload)
                cellForReload?.layer.cornerRadius = 0
                cellForReload?.selectedBackgroundView?.layer.cornerRadius = 0
                cellForReload?.separatorInset = .init(top: 0, left: 16, bottom: 0, right: 16)
                categoriesTableView.performBatchUpdates {
                    categoriesTableView.reloadRows(at: [indexPathForReload], with: .automatic)
                }
            }
        }
    }
}

// MARK: - UITableViewDelegate

extension CategoriesViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        uncheckCellIfNeeded()
        selectedCategoryName = categoryStore.object(at: indexPath)
        checkCell(at: indexPath)
    }
}

// MARK: - UITableViewDataSource

extension CategoriesViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryStore.numberOfItems()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ButtonTableCell.identifier) as? ButtonTableCell,
              let categoryName = categoryStore.object(at: indexPath) else { return UITableViewCell() }
        cell.set(label: categoryName)
        if indexPath == checkedCellIndexPath { cell.accessoryType = .checkmark }
        customizeCornersAndSeparator(for: cell, at: indexPath)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}

// MARK: - UIAdaptivePresentationControllerDelegate

extension CategoriesViewController: UIAdaptivePresentationControllerDelegate {

    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        selectedCategoryName = nil
        callback?(nil)
    }
}

// MARK: - CategoryStoreDelegate

extension CategoriesViewController: CategoryStoreDelegate {

    func didUpdateCategory(_ insertedIndexes: IndexSet, _ deletedIndexes: IndexSet) {
        let insertedIndexPaths = insertedIndexes.map { IndexPath(item: $0, section: 0) }
        let deletedIndexPaths = deletedIndexes.map { IndexPath(item: $0, section: 0) }
        categoriesTableView.performBatchUpdates {
            categoriesTableView.insertRows(at: insertedIndexPaths, with: .automatic)
            categoriesTableView.deleteRows(at: deletedIndexPaths, with: .automatic)
        }
    }
}
