//
//  StatisticViewController.swift
//  TrackerApp
//
//  Created by Юрий Демиденко on 14.03.2023.
//

import UIKit

final class StatisticsViewController: UIViewController {

    private let statisticsService: StatisticsServiceProtocol

    private lazy var screenLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = L10n.Trackers.statisticsTitle
        label.font = UIFont(name: Fonts.bold, size: 34)
        return label
    }()

    private lazy var statisticsTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .viewBackgroundColor
        tableView.allowsSelection = false
        tableView.register(StatisticsTableCell.self, forCellReuseIdentifier: StatisticsTableCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()

    init(statisticsService: StatisticsServiceProtocol = StatisticsService.shared) {
        self.statisticsService = statisticsService
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .viewBackgroundColor
        setupConstraints()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        statisticsTableView.reloadData()
    }

    private func setupConstraints() {
        [screenLabel, statisticsTableView].forEach { view.addSubview($0) }
        NSLayoutConstraint.activate([
            screenLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 44),
            screenLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),

            statisticsTableView.topAnchor.constraint(equalTo: screenLabel.bottomAnchor, constant: 65),
            statisticsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            statisticsTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            statisticsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
}

// MARK: - UITableViewDelegate

extension StatisticsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        102
    }
}

// MARK: - UITableViewDataSource

extension StatisticsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Statistics.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: StatisticsTableCell.identifier)
                as? StatisticsTableCell else { return UITableViewCell() }
        cell.set(title: Statistics.allCases[indexPath.row].localizedString)
        cell.set(value: statisticsService.statistics[indexPath.row])
        return cell
    }
}
