//
//  ExportCSVViewController.swift
//  AirPodsProMotion
//

import Foundation
import UIKit
import CoreMotion
import AVFoundation

class ExportCSVViewController: UIViewController,
                                CMHeadphoneMotionManagerDelegate,
                                AVAudioRecorderDelegate {
    
    // MARK: – UI
    lazy var statusLabel: UILabel = {
        let lbl = UILabel()
        lbl.frame = CGRect(
            x: 20,
            y: view.safeAreaInsets.top + 10,
            width: view.bounds.width - 40,
            height: 30
        )
        lbl.textAlignment = .center
        lbl.font = .boldSystemFont(ofSize: 16)
        lbl.text = "Idle"
        return lbl
    }()

    lazy var button: UIButton = {
        let btn = UIButton(type: .system)
        btn.frame = CGRect(
            x: view.bounds.width / 4,
            y: view.bounds.maxY - 100,
            width: view.bounds.width / 2,
            height: 50
        )
        btn.setTitle("Start Recording", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 20, weight: .semibold)
        btn.layer.cornerRadius = 10
        btn.backgroundColor = .systemBlue
        btn.addTarget(self, action: #selector(toggleRecording), for: .touchUpInside)
        return btn
    }()

    lazy var textView: UITextView = {
        let tv = UITextView()
        tv.frame = CGRect(
            x: view.bounds.minX + (view.bounds.width / 10),
            y: view.bounds.minY + (view.bounds.height / 6),
            width: view.bounds.width * 0.8,
            height: view.bounds.height - 300
        )
        tv.text = "Press the button below to start."
        tv.font = tv.font?.withSize(14)
        tv.isEditable = false
        return tv
    }()

    // MARK: – Motion
    let APP = CMHeadphoneMotionManager()
    let writer = CSVWriter()
    let f = DateFormatter()
    var isRecordingData = false

    // MARK: – Audio
    var audioRecorder: AVAudioRecorder?
    var audioFileURL: URL?

    // MARK: – Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Information View"
        view.backgroundColor = .systemBackground

        f.dateFormat = "yyyyMMdd_HHmmss"
        APP.delegate = self

        view.addSubview(statusLabel)
        view.addSubview(textView)
        view.addSubview(button)

        // Ensure Info.plist includes NSMicrophoneUsageDescription
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        teardownSession()
    }

    // MARK: – Toggle Recording
    @objc func toggleRecording() {
        if isRecordingData {
            // STOP
            stopAll()
            updateUI(isRecording: false)
            AlertView.action(self) { [weak self] _ in
                self?.viewCreatedFiles()
            }
        } else {
            // START
            guard APP.isDeviceMotionAvailable else {
                AlertView.alert(self, "Sorry", "Your device is not supported.")
                return
            }
            startAll()
            updateUI(isRecording: true)
        }
    }

    // MARK: – Start / Stop Helpers
    private func startAll() {
        isRecordingData = true
        // CSV
        let dir = FileManager.default.urls(
            for: .documentDirectory,
               in: .userDomainMask
        ).first!
        let ts = f.string(from: Date())
        writer.open(dir.appendingPathComponent("\(ts)_motion.csv"))
        APP.startDeviceMotionUpdates(to: .current!) { [weak self] motion, error in
            guard let m = motion, error == nil else { return }
            self?.writer.write(m)
            self?.printData(m)
        }
        // Audio
        startAudioRecording()
    }

    private func stopAll() {
        isRecordingData = false
        writer.close()
        APP.stopDeviceMotionUpdates()
        stopAudioRecording()
        // After stopping, boost volume by 50%
        if let original = audioFileURL {
            let boosted = original.deletingLastPathComponent()
                .appendingPathComponent("boosted_\(original.lastPathComponent)")
            boostVolume(inputURL: original, outputURL: boosted, gain: 1.5) { result in
                switch result {
                case .success(let url):
                    print("Boosted audio saved at: \(url)")
                case .failure(let err):
                    print("Boost failed: \(err)")
                }
            }
        }
    }

    // MARK: – UI
    private func updateUI(isRecording: Bool) {
        if isRecording {
            statusLabel.text = "🔴 Recording audio & motion"
            button.setTitle("Stop Recording", for: .normal)
            button.backgroundColor = .systemRed
        } else {
            statusLabel.text = "Idle"
            button.setTitle("Start Recording", for: .normal)
            button.backgroundColor = .systemBlue
        }
    }

    // MARK: – Audio Recording
    private func startAudioRecording() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord,
                                    mode: .default,
                                    options: [.allowBluetooth, .allowBluetoothA2DP])
            try session.setActive(true)
        } catch {
            print("Audio session error: \(error)")
            return
        }

        let dir = FileManager.default.urls(
            for: .documentDirectory,
               in: .userDomainMask
        ).first!
        let ts = f.string(from: Date())
        let audioURL = dir.appendingPathComponent("\(ts)_audio.caf")
        audioFileURL = audioURL

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatAppleIMA4),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderBitRateKey: 12800,
            AVLinearPCMBitDepthKey: 16
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: audioURL, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.prepareToRecord()
            audioRecorder?.record()
        } catch {
            print("AVAudioRecorder error: \(error)")
        }
    }

    private func stopAudioRecording() {
        audioRecorder?.stop()
        audioRecorder = nil
        try? AVAudioSession.sharedInstance().setActive(false)
    }

    // MARK: – Volume Boost
    /// Boosts volume by `gain` (e.g. 1.5 = +50%) and writes to outputURL
    private func boostVolume(inputURL: URL,
                             outputURL: URL,
                             gain: Float = 1.5,
                             completion: @escaping (Result<URL, Error>) -> Void) {
        let asset = AVURLAsset(url: inputURL)
        guard let track = asset.tracks(withMediaType: .audio).first,
              let export = AVAssetExportSession(
                asset: asset,
                presetName: AVAssetExportPresetPassthrough
              )
        else {
            completion(.failure(NSError(domain: "Boost", code: -1, userInfo: nil)))
            return
        }
        let params = AVMutableAudioMixInputParameters(track: track)
        params.setVolume(gain, at: .zero)
        let mix = AVMutableAudioMix()
        mix.inputParameters = [params]

        export.audioMix = mix
        export.outputFileType = .caf
        export.outputURL = outputURL
        export.exportAsynchronously {
            switch export.status {
            case .completed:
                completion(.success(outputURL))
            case .failed, .cancelled:
                completion(.failure(export.error ?? NSError(domain: "Boost", code: -2, userInfo: nil)))
            default:
                break
            }
        }
    }

    // MARK: – Motion Display
    func printData(_ data: CMDeviceMotion) {
        textView.text = """
        Quaternion:
            x: \(data.attitude.quaternion.x)
            y: \(data.attitude.quaternion.y)
            z: \(data.attitude.quaternion.z)
            w: \(data.attitude.quaternion.w)
        Attitude:
            pitch: \(data.attitude.pitch)
            roll: \(data.attitude.roll)
            yaw: \(data.attitude.yaw)
        Gravity:
            x: \(data.gravity.x)
            y: \(data.gravity.y)
            z: \(data.gravity.z)
        Rotation Rate:
            x: \(data.rotationRate.x)
            y: \(data.rotationRate.y)
            z: \(data.rotationRate.z)
        Acceleration:
            x: \(data.userAcceleration.x)
            y: \(data.userAcceleration.y)
            z: \(data.userAcceleration.z)
        """
    }

    // MARK: – File Browser
    private func viewCreatedFiles() {
        guard let dir = FileManager.default.urls(
            for: .documentDirectory,
               in: .userDomainMask
        ).first,
        var comps = URLComponents(url: dir, resolvingAgainstBaseURL: false)
        else { return }
        comps.scheme = "shareddocuments"
        if let url = comps.url {
            UIApplication.shared.open(url)
        } else {
            AlertView.warning(self)
        }
    }

    // MARK: – Teardown
    private func teardownSession() {
        stopAll()
    }
}
