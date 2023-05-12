//
//  CameraVM.swift
//  MemoriesSwiftUI
//
//  Created by Alina Potapova on 19.03.2023.
//

import SwiftUI
import AVFoundation
import AVKit

class CameraVM: NSObject, ObservableObject, AVCaptureFileOutputRecordingDelegate {
    @Published var session = AVCaptureSession()
    @Published var alert = false
    @Published var output = AVCaptureMovieFileOutput()
    @Published var preview: AVCaptureVideoPreviewLayer!
    
    // MARK: Video Recorder Properties
    @Published var isRecording: Bool = false
    @Published var recordedURLs: [URL] = []
    @Published var previewURL: URL?
    @Published var showPreview: Bool = false
    
    // Top Progress Bar (Do we need this?)
    @Published var recordedDuration: Double = 0.0
    
    @Published var seconds: CGFloat = 0
    @Published var m_seconds: Int = 0
    
    // YOUR OWN TIMING
    @Published var maxDuration: CGFloat = 11.0
    
    func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setUp()
            return
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { (status) in
                if status {
                    self.setUp()
                }
            }
        case .denied:
            self.alert.toggle()
            return
        default:
            return
        }
    }
    
    func setUp() {
        do {
            self.session.beginConfiguration()
            let cameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
            let videoInput = try AVCaptureDeviceInput(device: cameraDevice!)
            let audioDevice = AVCaptureDevice.default(for: .audio)
            let audioInput = try AVCaptureDeviceInput(device: audioDevice!)
            
            // MARK: Audio Input
            
            if self.session.canAddInput(videoInput) && self.session.canAddInput(audioInput)  {
                self.session.addInput(videoInput)
                self.session.addInput(audioInput)
            }
            
            if self.session.canAddOutput(self.output) {
                self.session.addOutput(self.output)
            }
            
            self.session.commitConfiguration()
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func startRecording() {
        // MARK: Temporary URL for recording Video
//        let tempURL = NSTemporaryDirectory() + "\(Date()).mov"
//        output.startRecording(to: URL(fileURLWithPath: tempURL), recordingDelegate: self)
        isRecording = true
    }
    
    func stopRecording() {
        output.stopRecording()
        isRecording = false
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        
        // CREATED SUCCESSFULLY
        print(outputFileURL)
        self.recordedURLs.append(outputFileURL)
        if self.recordedURLs.count == 1 {
            self.previewURL = outputFileURL
            return
        }
        
        
        self.previewURL = nil
    }
}
