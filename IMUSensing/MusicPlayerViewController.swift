import UIKit
import AVFoundation

class MusicPlayerViewController: UIViewController {

    // Playlist of songs
    let songs = [
        ("Blinding Lights", "The Weeknd", "Blinding Lights.mp3"),
        ("Can't Feel My Face", "The Weeknd", "Can't Feel My Face.mp3"),
        ("Earned It", "The Weeknd", "Earned It.mp3"),
        ("Feel It Coming", "The Weeknd ft. Daft Punk", "Feel It Coming ft. Daft Punk.mp3"),
        ("Snowchild", "The Weeknd", "Snowchild.mp3"),
        ("Starboy", "The Weeknd ft. Daft Punk", "Starboy ft. Daft Punk.mp3"),
        ("The Hills", "The Weeknd", "The Hills.mp3")
    ]

    var currentSongIndex = 0
    var audioPlayer: AVAudioPlayer?
    var captureSession: AVCaptureSession?
    var previewLayer: AVCaptureVideoPreviewLayer?

    lazy var cameraView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        return view
    }()
    
    

    lazy var songTitleLabel: UILabel = {
        let label = UILabel()
        label.text = songs[currentSongIndex].0
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        return label
    }()

    lazy var artistLabel: UILabel = {
        let label = UILabel()
        label.text = songs[currentSongIndex].1
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .gray
        label.textAlignment = .center
        return label
    }()

    lazy var playPauseButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
        button.tintColor = .systemBlue
        button.addTarget(self, action: #selector(playPauseTapped), for: .touchUpInside)
        return button
    }()

    lazy var nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "forward.fill"), for: .normal)
        button.tintColor = .systemBlue
        button.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        return button
    }()

    lazy var previousButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "backward.fill"), for: .normal)
        button.tintColor = .systemBlue
        button.addTarget(self, action: #selector(previousTapped), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        setupLayout()
        setupCameraFeed() // Set up the live camera feed
        loadCurrentSong() // Load the first song
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = cameraView.bounds
    }


    private func setupLayout() {
        view.addSubview(cameraView)
        view.addSubview(songTitleLabel)
        view.addSubview(artistLabel)
        view.addSubview(previousButton)
        view.addSubview(playPauseButton)
        view.addSubview(nextButton)

        cameraView.translatesAutoresizingMaskIntoConstraints = false
        songTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        artistLabel.translatesAutoresizingMaskIntoConstraints = false
        previousButton.translatesAutoresizingMaskIntoConstraints = false
        playPauseButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            // Camera View
            cameraView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cameraView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            cameraView.widthAnchor.constraint(equalToConstant: 300),
            cameraView.heightAnchor.constraint(equalToConstant: 200),

            // Song Title
            songTitleLabel.topAnchor.constraint(equalTo: cameraView.bottomAnchor, constant: 20),
            songTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            songTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            // Artist
            artistLabel.topAnchor.constraint(equalTo: songTitleLabel.bottomAnchor, constant: 10),
            artistLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            artistLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            // Previous Button
            previousButton.centerYAnchor.constraint(equalTo: playPauseButton.centerYAnchor),
            previousButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 60),

            // Play/Pause Button
            playPauseButton.topAnchor.constraint(equalTo: artistLabel.bottomAnchor, constant: 30),
            playPauseButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playPauseButton.widthAnchor.constraint(equalToConstant: 60),
            playPauseButton.heightAnchor.constraint(equalToConstant: 60),

            // Next Button
            nextButton.centerYAnchor.constraint(equalTo: playPauseButton.centerYAnchor),
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -60)
        ])
    }

    private func setupCameraFeed() {
        captureSession = AVCaptureSession()
        captureSession?.sessionPreset = .high

        guard let frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let input = try? AVCaptureDeviceInput(device: frontCamera) else {
            print("Error: Unable to access front camera.")
            return
        }

        captureSession?.addInput(input)

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
        previewLayer?.videoGravity = .resizeAspectFill
        previewLayer?.frame = cameraView.bounds
        if let previewLayer = previewLayer {
            cameraView.layer.addSublayer(previewLayer)
        }

        // Start running the session
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession?.startRunning()
        }
    }

    // MARK: - Audio Player Controls

    private func loadCurrentSong() {
        let song = songs[currentSongIndex]
        songTitleLabel.text = song.0
        artistLabel.text = song.1

        if let url = Bundle.main.url(forResource: song.2, withExtension: nil) {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.prepareToPlay()
            } catch {
                print("Error loading audio file: \(error)")
            }
        }
    }

    @objc private func playPauseTapped() {
        guard let player = audioPlayer else { return }

        if player.isPlaying {
            player.pause()
            playPauseButton.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
        } else {
            player.play()
            playPauseButton.setImage(UIImage(systemName: "pause.circle.fill"), for: .normal)
        }
    }

    @objc private func nextTapped() {
        currentSongIndex = (currentSongIndex + 1) % songs.count
        loadCurrentSong()
        audioPlayer?.play()
        playPauseButton.setImage(UIImage(systemName: "pause.circle.fill"), for: .normal)
    }

    @objc private func previousTapped() {
        currentSongIndex = (currentSongIndex - 1 + songs.count) % songs.count
        loadCurrentSong()
        audioPlayer?.play()
        playPauseButton.setImage(UIImage(systemName: "pause.circle.fill"), for: .normal)
    }
}
