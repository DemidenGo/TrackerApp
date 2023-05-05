//
//  ButtonsTableViewCell.swift
//  TrackerApp
//
//  Created by Юрий Демиденко on 18.03.2023.
//

import UIKit

final class ButtonTableCell: UITableViewCell {

    lazy var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "YSDisplay-Regular", size: 17)
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        accessoryType = .none
        layer.cornerRadius = 0
        selectedBackgroundView?.layer.cornerRadius = 0
        separatorInset = .init(top: 0, left: 16, bottom: 0, right: 16)
    }

    private func setupCell() {
        backgroundColor = .backgroundColor
        selectionStyle = .none
        separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }

    private func setupConstraints() {
        contentView.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -6),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    func set(label text: String, additionalText: String? = nil) {
        if let additionalText = additionalText {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 2
            let labelAttributes = [NSAttributedString.Key.foregroundColor : UIColor.black,
                                   NSAttributedString.Key.paragraphStyle : paragraphStyle]
            let additionalTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.interfaceGray]
            let labelText = NSMutableAttributedString(string: text, attributes: labelAttributes)
            let additionalText = NSMutableAttributedString(string: "\n\(additionalText)",
                                                           attributes: additionalTextAttributes)
            labelText.append(additionalText)
            label.numberOfLines = 2
            label.attributedText = labelText
        } else {
            label.text = text
        }
    }
}
