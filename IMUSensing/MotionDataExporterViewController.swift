//
//  MotionDataExporterViewController.swift
//  IMUSensing
//
//  Created by Garvit on 28/01/25.
//

import Foundation
import UIKit
import CoreMotion

class MotionDataExporterViewController: UIViewController, CMHeadphoneMotionManagerDelegate {
    
    private lazy var actionButton: UIButton = {
        let actionButton = UIButton(type: .system)
        actionButton.frame = CGRect(x: view.bounds.width * 0.25, y: view.bounds.maxY - 100,
                                     width: view.bounds.width * 0.5, height: 50)
        actionButton.setTitle("Start Recording", for: .normal)
        actionButton.setTitleColor(.white, for: .normal)
        actionButton.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        actionButton.layer.cornerRadius = 8
        actionButton.backgroundColor = .systemTeal
        actionButton.addTarget(self, action: #selector(handleActionButton), for: .touchUpInside)
        
        return actionButton
    }()
    
    private lazy var logTextView: UITextView = {
        let textView = UITextView()
        textView.frame = CGRect(x: view.bounds.width * 0.1, y: view.bounds.height * 0.15,
                                 width: view.bounds.width * 0.8, height: view.bounds.height * 0.7)
        textView.text = "Tap the button below to begin data recording."
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.isEditable = false
        textView.layer.borderWidth = 0.5
        textView.layer.borderColor = UIColor.gray.cgColor
        textView.layer.cornerRadius = 6
        return textView
    }()
    
    private let motionManager = CMHeadphoneMotionManager()
    private let csvWriter = CSVWriter()
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        return formatter
    }()

    private var isRecording = false

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Motion Data Exporter"
        view.backgroundColor = .systemBackground
        view.addSubview(actionButton)
        view.addSubview(logTextView)
        motionManager.delegate = self
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopRecording()
    }

    private func startRecording() {
        guard motionManager.isDeviceMotionAvailable else {
            showAlert(title: "Unsupported", message: "Motion data is not available on this device.")
            return
        }
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileName = dateFormatter.string(from: Date()) + "_motion_data.csv"
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        csvWriter.open(fileURL)

        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motionData, error in
            guard let self = self, let motionData = motionData, error == nil else { return }
            self.csvWriter.write(motionData)
            self.updateLog(with: motionData)
        }
    }

    private func stopRecording() {
        isRecording = false
        motionManager.stopDeviceMotionUpdates()
        csvWriter.close()
        actionButton.setTitle("Start Recording", for: .normal)
    }

    @objc private func handleActionButton() {
        if isRecording {
            stopRecording()
            showFileDirectory()
        } else {
            isRecording = true
            actionButton.setTitle("Stop Recording", for: .normal)
            startRecording()
        }
    }

    private func updateLog(with motionData: CMDeviceMotion) {
        logTextView.text = """
        Orientation Quaternion:
            x: \(motionData.attitude.quaternion.x)
            y: \(motionData.attitude.quaternion.y)
            z: \(motionData.attitude.quaternion.z)
            w: \(motionData.attitude.quaternion.w)
        Attitude (Angles):
            Pitch: \(motionData.attitude.pitch)
            Roll: \(motionData.attitude.roll)
            Yaw: \(motionData.attitude.yaw)
        Gravity Vector:
            x: \(motionData.gravity.x)
            y: \(motionData.gravity.y)
            z: \(motionData.gravity.z)
        Rotation Rates:
            x: \(motionData.rotationRate.x)
            y: \(motionData.rotationRate.y)
            z: \(motionData.rotationRate.z)
        User Acceleration:
            x: \(motionData.userAcceleration.x)
            y: \(motionData.userAcceleration.y)
            z: \(motionData.userAcceleration.z)
        """
    }

    private func showFileDirectory() {
        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            UIApplication.shared.open(documentsDirectory)
        } else {
            showAlert(title: "Error", message: "Unable to access saved files.")
        }
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
