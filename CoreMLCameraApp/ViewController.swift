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

class ViewController: UIViewController, AVCapturePhotoCaptureDelegate {

    @IBOutlet weak var videoFeed: UIView!
    @IBOutlet weak var resultLabel: UILabel!
    
    var cameraOutput: AVCapturePhotoOutput!
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
        
        recognizeImage()
    }
    
    @objc func recognizeImage() {
        let settings = AVCapturePhotoSettings()
        settings.previewPhotoFormat = settings.embeddedThumbnailPhotoFormat
        cameraOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Error code: \(error.localizedDescription)")
        }
        
        if let imageData = photo.fileDataRepresentation(), let image = UIImage(data: imageData) {
            predictItem(image: image)
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func predictItem(image: UIImage) {
        if let data = image.pngData() {
            let fileName = getDocumentsDirectory().appendingPathComponent("image.png")
            try? data.write(to: fileName)
            
            // let modelFile = SqueezeNet()
            
            guard let modelFile = try? SqueezeNet(configuration: MLModelConfiguration()) else {
                fatalError("Could not load model")
            }
            
            let model = try! VNCoreMLModel(for: modelFile.model)
            
            let request = VNCoreMLRequest(model: model, completionHandler: finalGuess)
            let handler = VNImageRequestHandler(url: fileName)
            try! handler.perform([request])
        }
    }
    
    func finalGuess(request: VNRequest, error: Error?) {
        guard let results = request.results as? [VNClassificationObservation] else {
            fatalError("Unable to get a prediction")
        }
        
        var bestGuess = ""
        var confidence: VNConfidence = 0
        for classification in results {
            if classification.confidence > confidence {
                confidence = classification.confidence
                bestGuess = classification.identifier
            }
        }
        
        resultLabel.text = bestGuess + "\n"
        
        // Takes a picture every 5 seconds and then carry's out a recognition
        Timer.scheduledTimer(timeInterval: 5.0, target: self, selector:  #selector(self.recognizeImage), userInfo: nil, repeats: false)
    }
}


