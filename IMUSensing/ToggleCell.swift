//
//  ToggleCell.swift
//  AirPodsProMotion
//
//  Created by Garvit on 28/01/25.
//



import UIKit
import Foundation

import UIKit

class ToggleCell: UITableViewCell {
    static let identifier = "ToggleCell"

    private let actionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let actionSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.translatesAutoresizingMaskIntoConstraints = false
        return toggle
    }()

    private var switchHandler: ((Bool) -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(actionLabel)
        contentView.addSubview(actionSwitch)

        NSLayoutConstraint.activate([
            actionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            actionLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            actionSwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            actionSwitch.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])

        actionSwitch.addTarget(self, action: #selector(toggleChanged), for: .valueChanged)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with action: String, isEnabled: Bool, switchHandler: @escaping (Bool) -> Void) {
        actionLabel.text = action
        actionSwitch.isOn = isEnabled
        self.switchHandler = switchHandler
    }

    @objc private func toggleChanged() {
        switchHandler?(actionSwitch.isOn)
    }
}
