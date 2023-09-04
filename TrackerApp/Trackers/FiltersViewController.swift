//
//  FiltersViewController.swift
//  TrackerApp
//
//  Created by Юрий Демиденко on 05.07.2023.
//

import UIKit

final class FiltersViewController: UIViewController {

    private let dismissCompletion: (Filter) -> Void
    private var selectedFilter: Filter

    private lazy var screenTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = L10n.Trackers.filtersTitle
        label.font = UIFont(name: Fonts.medium, size: 16)
        label.textAlignment = .center
        return label
    }()

    private lazy var filtersTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true
        tableView.separatorColor = .tableSeparatorColor
        tableView.register(ButtonTableCell.self, forCellReuseIdentifier: ButtonTableCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()

    init(selectedFilter: Filter, dismissCompletion: @escaping (Filter) -> Void) {
        self.selectedFilter = selectedFilter
        self.dismissCompletion = dismissCompletion
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraints()
        view.backgroundColor = .viewBackgroundColor
    }

    private func setupConstraints() {
        [screenTitleLabel, filtersTableView].forEach { view.addSubview($0) }
        NSLayoutConstraint.activate([
            screenTitleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 27),
            screenTitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            filtersTableView.topAnchor.constraint(equalTo: screenTitleLabel.bottomAnchor, constant: 38),
            filtersTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            filtersTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            filtersTableView.heightAnchor.constraint(equalToConstant: 300)
        ])
    }
}

// MARK: - UITableViewDelegate

extension FiltersViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let selectedFilter = Filter(rawValue: indexPath.row) else { return }
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .checkmark
        dismiss(animated: true) { [weak self] in
            self?.dismissCompletion(selectedFilter)
        }
    }
}

// MARK: - UITableViewDataSource

extension FiltersViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Filter.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ButtonTableCell.identifier) as? ButtonTableCell else {
            return UITableViewCell()
        }
        cell.set(label: Filter.allCases[indexPath.row].localizedString)
        cell.accessoryType = selectedFilter == Filter(rawValue: indexPath.row) ? .checkmark : .none
        if indexPath.row == 3 {
            cell.separatorInset = .init(top: 0, left: UIScreen.main.bounds.width, bottom: 0, right: 0)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}

