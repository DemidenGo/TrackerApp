//
//  StatisticsTableCell.swift
//  TrackerApp
//
//  Created by Юрий Демиденко on 06.07.2023.
//

import UIKit

final class StatisticsTableCell: UITableViewCell {

    private lazy var gradientBackgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.layer.addSublayer(gradientLayer)
        return view
    }()

    private lazy var gradientLayer: CAGradientLayer = {
        let gradient = CAGradientLayer()
        let gradientSize = CGSize(width: UIScreen.main.bounds.width - 32, height: 90)
        gradient.frame = CGRect(origin: .zero, size: gradientSize)
        gradient.colors = [
            UIColor.firstGradientColor.cgColor,
            UIColor.secondGradientColor.cgColor,
            UIColor.thirdGradientColor.cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.cornerRadius = 16
        gradient.masksToBounds = true
        return gradient
    }()

    private lazy var cellView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.backgroundColor = .viewBackgroundColor
        return view
    }()

    private lazy var valueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: Fonts.bold, size: 34)
        return label
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: Fonts.medium, size: 12)
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupConstraints() {
        contentView.addSubview(gradientBackgroundView)
        gradientBackgroundView.addSubview(cellView)
        [valueLabel, titleLabel].forEach { cellView.addSubview($0) }
        NSLayoutConstraint.activate([
            gradientBackgroundView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            gradientBackgroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            gradientBackgroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            gradientBackgroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            cellView.topAnchor.constraint(equalTo: gradientBackgroundView.topAnchor, constant: 1),
            cellView.leadingAnchor.constraint(equalTo: gradientBackgroundView.leadingAnchor, constant: 1),
            cellView.bottomAnchor.constraint(equalTo: gradientBackgroundView.bottomAnchor, constant: -1),
            cellView.trailingAnchor.constraint(equalTo: gradientBackgroundView.trailingAnchor, constant: -1),

            valueLabel.topAnchor.constraint(equalTo: gradientBackgroundView.topAnchor, constant: 12),
            valueLabel.leadingAnchor.constraint(equalTo: gradientBackgroundView.leadingAnchor, constant: 12),

            titleLabel.leadingAnchor.constraint(equalTo: gradientBackgroundView.leadingAnchor, constant: 12),
            titleLabel.bottomAnchor.constraint(equalTo: gradientBackgroundView.bottomAnchor, constant: -12)
        ])
    }

    func set(title: String) {
        titleLabel.text = title
    }

    func set(value: Int) {
        valueLabel.text = String(value)
    }
}
