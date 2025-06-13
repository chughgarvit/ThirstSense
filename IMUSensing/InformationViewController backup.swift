//
//  ViewController.swift
//  AirPodsProMotion
//
//

import UIKit
import CoreMotion

class InformationViewController: UIViewController, CMHeadphoneMotionManagerDelegate {

    lazy var textView: UITextView = {
        let view = UITextView()
        view.frame = CGRect(x: self.view.bounds.minX + (self.view.bounds.width / 10),
                            y: self.view.bounds.minY + (self.view.bounds.height / 6),
                            width: self.view.bounds.width, height: self.view.bounds.height)
        view.text = "Looking for AirPods Pro"
        view.font = view.font?.withSize(14)
        view.isEditable = false
        return view
    }()
    

    
    lazy var button1: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Visualise", for: .normal)
        // Add additional styling here
        button.addTarget(self, action: #selector(button1Action), for: .touchUpInside)
        return button
    }()

    lazy var button2: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Record", for: .normal)
        // Add additional styling here
        button.addTarget(self, action: #selector(button2Action), for: .touchUpInside)
        return button
    }()

    
    
    
    //AirPods Pro => APP :)
    let APP = CMHeadphoneMotionManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "IMU Data"
        view.backgroundColor = .systemBackground
        view.addSubview(textView)

        view.addSubview(button1)
        view.addSubview(button2)

        button1.translatesAutoresizingMaskIntoConstraints = false
        button2.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            button1.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            button1.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),

            button2.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            button2.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])

        
        
        APP.delegate = self
        
        guard APP.isDeviceMotionAvailable else {
            AlertView.alert(self, "Sorry", "Your device is not supported.")
            textView.text = "Sorry, Your device is not supported."
            return
        }
        
        APP.startDeviceMotionUpdates(to: OperationQueue.current!, withHandler: {[weak self] motion, error  in
            guard let motion = motion, error == nil else { return }
            self?.printData(motion)
        })
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        APP.stopDeviceMotionUpdates()
    }
    
    @objc func button1Action() {
        // Navigate to Option B
        let optionBViewController = SK3DViewController()
        self.navigationController?.pushViewController(optionBViewController, animated: true)
    }

    @objc func button2Action() {
        // Navigate to Option D
        let optionDViewController = ExportCSVViewController()
        self.navigationController?.pushViewController(optionDViewController, animated: true)
    }

    
    
    func printData(_ data: CMDeviceMotion) {
        print(data)
        self.textView.text = """
            Quaternion:
                x: \(data.attitude.quaternion.x)
                y: \(data.attitude.quaternion.y)
                z: \(data.attitude.quaternion.z)
                w: \(data.attitude.quaternion.w)
            Attitude:
                pitch: \(data.attitude.pitch)
                roll: \(data.attitude.roll)
                yaw: \(data.attitude.yaw)
            Gravitational Acceleration:
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
            Magnetic Field:
                field: \(data.magneticField.field)
                accuracy: \(data.magneticField.accuracy)
            Heading:
                \(data.heading)
            """
    }

}
