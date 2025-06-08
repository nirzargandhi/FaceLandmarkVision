//
//  HomeVC.swift
//  FaceLandmarkVision
//
//  Created by Nirzar Gandhi on 02/06/25.
//

import UIKit
import AVFoundation
import Vision
import VisionKit

class HomeVC: BaseVC {
    
    // MARK: - IBOutlets
    
    
    // MARK: - Properties
    fileprivate var previewLayer: AVCaptureVideoPreviewLayer!
    fileprivate lazy var shapeLayer = CAShapeLayer()
    
    
    // MARK: -
    // MARK: - View init Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Home"
        
        self.setControlsProperty()
        self.requestCameraPermission()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.tintColor = .white
        
        self.navigationController?.navigationBar.isHidden = false
        self.navigationItem.hidesBackButton = true
    }
    
    fileprivate func setControlsProperty() {
        
        self.view.backgroundColor = .white
        self.view.isOpaque = false
    }
}


// MARK: - Call back
extension HomeVC {
    
    fileprivate func requestCameraPermission() {
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            
        case .authorized:
            self.setupCamera()
            
        case .notDetermined:
            
            AVCaptureDevice.requestAccess(for: .video) { granted in
                
                DispatchQueue.main.async {
                    
                    if granted {
                        self.setupCamera()
                    } else {
                        self.cameraPermissionDeniedAlert()
                    }
                }
            }
            
        case .denied, .restricted:
            self.cameraPermissionDeniedAlert()
            
        @unknown default:
            print("Unknown camera authorization status.")
        }
    }
    
    fileprivate func setupCamera() {
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video),
              let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice)
        else { return }
        
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        }
        
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }
        
        self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.previewLayer.videoGravity = .resizeAspectFill
        self.previewLayer.frame = CGRect(x: self.view.frame.origin.x, y: self.view.frame.origin.y + STATUSBARHEIGHT + NAVBARHEIGHT, width: self.view.frame.width, height: self.view.frame.height - STATUSBARHEIGHT - NAVBARHEIGHT)
        self.view.layer.addSublayer(self.previewLayer)
        
        self.shapeLayer.frame = view.bounds
        self.shapeLayer.strokeColor = UIColor.green.cgColor
        self.shapeLayer.lineWidth = 2
        self.shapeLayer.fillColor = UIColor.clear.cgColor
        self.view.layer.addSublayer(self.shapeLayer)
        
        captureSession.startRunning()
    }
    
    fileprivate func drawFaceFeatures(face: VNFaceObservation) {
        
        let boundingBox = face.boundingBox
        
        // Convert Vision's normalized bounding box to UIKit coordinates
        let x = boundingBox.origin.x * view.bounds.width
        let height = boundingBox.height * view.bounds.height
        let y = (1 - boundingBox.origin.y - boundingBox.height) * view.bounds.height
        let width = boundingBox.width * view.bounds.width
        
        let rect = CGRect(x: x, y: y, width: width, height: height)
        
        let path = UIBezierPath(rect: rect)
        
        let shape = CAShapeLayer()
        shape.path = path.cgPath
        shape.strokeColor = UIColor.red.cgColor
        shape.lineWidth = 3
        shape.fillColor = UIColor.clear.cgColor
        
        self.shapeLayer.addSublayer(shape)
    }
}


// MARK: - AVCaptureVideoDataOutputSampleBuffer Delegate
extension HomeVC: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let request = VNDetectFaceLandmarksRequest { [weak self] request, error in
            
            guard let results = request.results as? [VNFaceObservation] else { return }
            
            DispatchQueue.main.async {
                
                self?.shapeLayer.sublayers?.removeAll()
                
                for face in results {
                    self?.drawFaceFeatures(face: face)
                }
            }
        }
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .right, options: [:])
        try? handler.perform([request])
    }
}
