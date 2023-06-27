//
//  SupplementaryView.swift
//  TrackerApp
//
//  Created by Юрий Демиденко on 21.03.2023.
//

import UIKit

final class SupplementaryView: UICollectionReusableView {

    private lazy var sectionTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: Fonts.bold, size: 19)
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstreaints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupConstreaints() {
        addSubview(sectionTitle)
        NSLayoutConstraint.activate([
            sectionTitle.topAnchor.constraint(equalTo: topAnchor),
            sectionTitle.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            sectionTitle.heightAnchor.constraint(equalToConstant: 20)
        ])
    }

    func setTitle(text: String) {
        sectionTitle.text = text
    }
}
