//
//  ViewController.swift
//  Smart Camera
//
//  Created by Zain Ahmed on 8/19/20.
//  Copyright © 2020 Zain Ahmed. All rights reserved.
//

import UIKit
import AVKit   // Audio Video Framework
import Vision // Image/object detection Library

                                        // Helps get access to each frame layers (line 45)
class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
        
    @IBOutlet weak var identifier_label: UILabel!
    @IBOutlet weak var confidence_label: UILabel!
    var objectList: [String:Float] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ----- Camera setup here -----
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo  // Sets the camera view in a small square

        // Video from the front camera of an iPhone
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {return}

        // Receives the video from the from camera above
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else {return}
        captureSession.addInput(input) // add the input to overall capture session

        // Keeps the camera running
        captureSession.startRunning()

        // Will allow us to preview camera on screen, the eyes of the camera
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)

        // Displays the camera preview on screen
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame

        // ---- Get access to cameras frame layer ----
        // Monitor whats happening in the frame
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "VIDEO_QUEUE"))
        captureSession.addOutput(dataOutput) // add the output to overall capture session

    }
    
    // Will be called everytime the camera is able to capture a frame
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        // Gets the pixels out from the image above
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {return}
        
        // Machine Learning Model Data
        guard let model = try? VNCoreMLModel(for: Resnet50().model) else {return}
        
        // CoreML request: Will figure out what the image is
        let request = VNCoreMLRequest(model: model) { (finishedReq, err) in
            
            // check error here
            guard let results = finishedReq.results as? [VNClassificationObservation] else {return}
            guard let firstObservation = results.first else {return}
            
            //print(firstObservation.identifier, firstObservation.confidence)
            
            // This method keeps the label in sync
            DispatchQueue.main.async {
                
                // Will only allow identification if confidence level is > 30%
                if firstObservation.confidence > 0.30 {
    
                    // Setup label here
                    self.identifier_label.text = firstObservation.identifier
                    self.confidence_label.text = String(format: "%.0f%%", firstObservation.confidence * 100)
                    
                    // Changes text color based on confidentiality rate
                    if firstObservation.confidence < 0.50 {
                        self.identifier_label.textColor = .yellow
                    }
                    else if firstObservation.confidence >= 0.50 {
                        self.identifier_label.textColor = .green
                    }
                    
                    // Will append all identified objects with > 50% confidence in a list
                    if firstObservation.confidence > 0.50 {
                        self.objectCollector(object: firstObservation.identifier, confidence: firstObservation.confidence)
                    }
                }
            }
        }
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
        
     }
    
    // Creates a list of all the objects classified
    func objectCollector(object:String, confidence: Float) {
        objectList[object] = confidence
    }
    
    // Button will take user to the list of all identified items
    @IBAction func identifiedListVC() {
        let vc = storyboard?.instantiateViewController(identifier: "listVC") as! ListViewController
        vc.objectListReceiver = objectList
        navigationController?.pushViewController(vc, animated: true)
        print("Done")
    }
    
    


}

