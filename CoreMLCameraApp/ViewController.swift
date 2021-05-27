//
//  ViewController.swift
//  CoreMLCameraApp
//
//  Created by Shailesh Patel on 26/05/2021.
//

import UIKit
import AVFoundation
import CoreML
import Vision

class ViewController: UIViewController {

    @IBOutlet weak var videoFeed: UIView!
    @IBOutlet weak var resultLabel: UILabel!
    
    var cameraOutput: AVCaptureOutput!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var captureSession: AVCaptureSession!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        useCamera()
    }
    
    func useCamera() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
        
        cameraOutput = AVCapturePhotoOutput()
        
        let device = AVCaptureDevice.default(for: AVMediaType.video)
        if let input = try? AVCaptureDeviceInput(device: device!) {
            if (captureSession.canAddInput(input)) {
                captureSession.addInput(input)
                
                if (captureSession.canAddOutput(cameraOutput)) {
                    captureSession.addOutput(cameraOutput)
                }
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
                previewLayer.frame = videoFeed.bounds
                videoFeed.layer.addSublayer(previewLayer)
                captureSession.startRunning()
            } else {
                print("Could not get any input")
            }
        } else {
            print("No video feed available")
        }
    }
    
    


}

