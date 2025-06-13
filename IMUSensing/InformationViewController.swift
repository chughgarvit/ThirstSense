//
//  InformationViewController.swift
//

import UIKit
import CoreMotion

enum ConfigurationType {
    case periocular
    case head
    case facial
}

class InformationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: - Properties

    var configurationType: ConfigurationType?

    var doubleTapActions: [String] = []
    var quadrupleTapActions: [String] = []
    var enabledDoubleTaps: [Bool] = []
    var enabledQuadrupleTaps: [Bool] = []

    lazy var configurationTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ToggleCell.self, forCellReuseIdentifier: ToggleCell.identifier)
        return tableView
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupTableView()
        loadConfiguration()
    }

    private func setupTableView() {
        view.addSubview(configurationTableView)
        configurationTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            configurationTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            configurationTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            configurationTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            configurationTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func loadConfiguration() {
        switch configurationType {
        case .periocular:
            doubleTapActions = ["Pause / Play", "Next Song"]
            quadrupleTapActions = ["Brightness Up", "Brightness Down"]
            enabledDoubleTaps = [true, false]
            enabledQuadrupleTaps = [false, true]
        case .head:
            doubleTapActions = ["Activate Siri", "Volume Up"]
            quadrupleTapActions = ["Volume Down", "Toggle Flashlight"]
            enabledDoubleTaps = [false, true]
            enabledQuadrupleTaps = [true, false]
        case .facial:
            doubleTapActions = ["Mute Mic", "Answer Call"]
            quadrupleTapActions = ["Reject Call", "End Call"]
            enabledDoubleTaps = [true, false]
            enabledQuadrupleTaps = [false, true]
        default:
            doubleTapActions = []
            quadrupleTapActions = []
        }
    }

    // MARK: - TableView DataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? doubleTapActions.count : quadrupleTapActions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ToggleCell.identifier, for: indexPath) as? ToggleCell else {
            fatalError("Failed to dequeue ToggleCell")
        }
        let actionName = indexPath.section == 0 ? doubleTapActions[indexPath.row] : quadrupleTapActions[indexPath.row]
        let isEnabled = indexPath.section == 0 ? enabledDoubleTaps[indexPath.row] : enabledQuadrupleTaps[indexPath.row]

        cell.configure(with: actionName, isEnabled: isEnabled) { isOn in
            if indexPath.section == 0 {
                self.enabledDoubleTaps[indexPath.row] = isOn
            } else {
                self.enabledQuadrupleTaps[indexPath.row] = isOn
            }
        }
        return cell
    }


    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Double Tap Actions" : "Quadruple Tap Actions"
    }
}
