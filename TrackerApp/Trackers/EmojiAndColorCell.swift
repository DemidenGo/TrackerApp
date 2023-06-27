//
//  EmojiCell.swift
//  TrackerApp
//
//  Created by Юрий Демиденко on 17.03.2023.
//

import UIKit

final class EmojiAndColorCell: UICollectionViewCell {

    private lazy var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupConstraints() {
        contentView.addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 6),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -6)
        ])
    }

    func setLabel(text: String) {
        label.text = text
        label.font = UIFont(name: Fonts.bold, size: 32)
    }

    func setLabel(color: UIColor) {
        label.backgroundColor = color
        label.layer.cornerRadius = 8
        label.layer.masksToBounds = true
    }
}
