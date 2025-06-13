//
//  IntroViewController.swift
//

import UIKit

class IntroViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "PeriSense"
        label.font = UIFont.boldSystemFont(ofSize: 36)
        label.textAlignment = .center
        return label
    }()

    lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Your AirPods can now be used\n to control your phone hands free!"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        label.textColor = .gray
        label.numberOfLines = 0
        return label
    }()

    lazy var enabledSwitchLabel: UILabel = {
        let label = UILabel()
        label.text = "Enabled"
        label.font = UIFont.systemFont(ofSize: 18)
        return label
    }()

    lazy var enabledSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.isOn = true
        toggle.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
        return toggle
    }()

    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    lazy var visualiseButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Visualise", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(openVisualisePage), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    lazy var recordButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Record", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemOrange
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(openRecordPage), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    lazy var testGesturesButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Test the gestures on a music app", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(openMusicPlayer), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    let sectionTitles = ["Airpod Controls"]
    let actions = [
        "Periocular Region Actions",
        "Head Region Actions",
        "Facial Region Actions"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        setupLayout()
    }

    private func setupLayout() {
        // Add subviews
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(enabledSwitchLabel)
        view.addSubview(enabledSwitch)
        view.addSubview(tableView)
        view.addSubview(visualiseButton)
        view.addSubview(recordButton)
        view.addSubview(testGesturesButton)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        enabledSwitchLabel.translatesAutoresizingMaskIntoConstraints = false
        enabledSwitch.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            // Title
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            // Subtitle
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            subtitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            // Enabled Switch
            enabledSwitchLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 30),
            enabledSwitchLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            enabledSwitch.centerYAnchor.constraint(equalTo: enabledSwitchLabel.centerYAnchor),
            enabledSwitch.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            // TableView
            tableView.topAnchor.constraint(equalTo: enabledSwitchLabel.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: visualiseButton.topAnchor, constant: -20),

            // Visualise Button
            visualiseButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            visualiseButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            visualiseButton.bottomAnchor.constraint(equalTo: recordButton.topAnchor, constant: -10),
            visualiseButton.heightAnchor.constraint(equalToConstant: 50),

            // Record Button
            recordButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            recordButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            recordButton.bottomAnchor.constraint(equalTo: testGesturesButton.topAnchor, constant: -10),
            recordButton.heightAnchor.constraint(equalToConstant: 50),

            // Test Gestures Button
            testGesturesButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            testGesturesButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            testGesturesButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            testGesturesButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    @objc private func switchChanged() {
        print("Switch is now \(enabledSwitch.isOn ? "Enabled" : "Disabled")")
    }

    @objc private func openVisualisePage() {
        let visualiseVC = SK3DViewController() // Replace with the actual class name for visualisation
        navigationController?.pushViewController(visualiseVC, animated: true)
    }

    @objc private func openRecordPage() {
        let recordVC = ExportCSVViewController() // Replace with the actual class name for recording
        navigationController?.pushViewController(recordVC, animated: true)
    }

    @objc private func openMusicPlayer() {
        let musicPlayerVC = MusicPlayerViewController()
        navigationController?.pushViewController(musicPlayerVC, animated: true)
    }

    // MARK: - UITableViewDelegate & UITableViewDataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return actions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = actions[indexPath.row]
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let informationVC = InformationViewController()
        switch indexPath.row {
        case 0:
            informationVC.title = "Periocular Region Actions"
            informationVC.configurationType = .periocular
        case 1:
            informationVC.title = "Head Region Actions"
            informationVC.configurationType = .head
        case 2:
            informationVC.title = "Facial Region Actions"
            informationVC.configurationType = .facial
        default:
            break
        }
        navigationController?.pushViewController(informationVC, animated: true)
    }
}
