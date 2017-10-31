//
//  VideoClientDeviceSettings.swift
//  VideoClient
//
//  Created by Krishna Picart on 6/22/17.
//  Copyright © 2017 StepwiseDesigns. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

class VideoClientDeviceSettings: NSObject, AVCaptureFileOutputRecordingDelegate {
    
    private let context = CIContext()
    
    let avCaptureSession = AVCaptureSession()
    
    var activeDeviceInput: AVCaptureDeviceInput!
    var systemDeviceInput: AVCaptureDeviceInput!
    
    
    var previewLayer: AVCaptureVideoPreviewLayer!
    let avCapturePhotoOutput = AVCapturePhotoOutput()
    
    
    var outputURL: URL!
    var movieOutput = AVCaptureMovieFileOutput()
    
    var systemDeviceFileOutput: AVCaptureFileOutput? = nil
    var path = ""
    
    
    var recordingText = "Record"
    let systemDeviceDiscoverySession = AVCaptureDeviceDiscoverySession(deviceTypes: [.builtInWideAngleCamera, .builtInDualCamera], mediaType: AVMediaTypeVideo, position: .unspecified)!
    
    
    
    private var setupResult: SessionSetupResult = .success
    
    private enum SessionSetupResult {
        case success
        case notAuthorized
        case configurationFailed
    }
    
    var initialVideoOrientation: AVCaptureVideoOrientation = .portrait
    
    func setupSession() -> Bool {
        print("🔵 setup session")
        avCaptureSession.sessionPreset = AVCaptureSessionPresetHigh
        
        // Setup Camera based on mediaType
        let camera = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        do {
            let defaultDeviceInput = try AVCaptureDeviceInput(device: camera)
            
            if avCaptureSession.canAddInput(defaultDeviceInput) {
                
                avCaptureSession.addInput(defaultDeviceInput)
                activeDeviceInput = defaultDeviceInput
                
                DispatchQueue.main.async {
                    print("🌕setup video Orientation")


                    let statusBarOrientation = UIApplication.shared.statusBarOrientation
                    if statusBarOrientation != .unknown {
                        if let videoOrientation = statusBarOrientation.videoOrientation {
                            self.initialVideoOrientation = videoOrientation
                        }
                    }
                }
            }
            else {
                setupResult = .configurationFailed
                avCaptureSession.commitConfiguration()
                return false
            }
            
        } catch {
            setupResult = .configurationFailed
            avCaptureSession.commitConfiguration()
            return false
        }
        
        // Setup Microphone based on mediaType
        let microphone = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeAudio)
        
        do {
            let micInput = try AVCaptureDeviceInput(device: microphone)
            if avCaptureSession.canAddInput(micInput) {
                avCaptureSession.addInput(micInput)
            }
        } catch {
            return false
        }
        
        
        // Movie output
        if avCaptureSession.canAddOutput(movieOutput) {
            avCaptureSession.addOutput(movieOutput)
        }
        avCaptureSession.commitConfiguration()
        return true
    }
    
    
    func switchCamera(){
        DispatchQueue.main.async {
            
            let currentVideoDevice = self.activeDeviceInput.device
            let currentPosition = currentVideoDevice!.position
            
            let preferredPosition: AVCaptureDevicePosition
            let preferredDeviceType: AVCaptureDeviceType
            
            switch currentPosition {
            case .unspecified, .front:
                preferredPosition = .back
                preferredDeviceType = .builtInDualCamera
                
            case .back:
                preferredPosition = .front
                preferredDeviceType = .builtInWideAngleCamera
            }
            
            let devices = self.systemDeviceDiscoverySession.devices!
            var newInputDevice: AVCaptureDevice? = nil
            
            if let device = devices.filter({$0.position == preferredPosition && $0.deviceType == preferredDeviceType }).first {
                newInputDevice = device
            }
                
            else if let device = devices.filter({ $0.position == preferredPosition }).first {
                newInputDevice = device
            }
            if let activeDevice = newInputDevice {
                do {
                    let activeDeviceInput = try AVCaptureDeviceInput(device: activeDevice)
                    
                    self.avCaptureSession.beginConfiguration()
                    self.avCaptureSession.removeInput(self.activeDeviceInput)
                    
                    if self.avCaptureSession.canAddInput(activeDeviceInput){
                        
                        NotificationCenter.default.removeObserver(self, name: Notification.Name("AVCaptureDeviceSubjectAreaDidChangeNotification"),object: currentVideoDevice!)
                        
                        NotificationCenter.default.addObserver(self, selector: #selector(self.subjectAreaDidChange), name: Notification.Name("AVCaptureDeviceSubjectAreaDidChangeNotification"),object: activeDeviceInput.device)
                        
                        self.avCaptureSession.addInput(activeDeviceInput)
                        self.activeDeviceInput  = activeDeviceInput
                    }
                    else {
                        self.avCaptureSession.addInput(self.activeDeviceInput)
                        
                    }
                    if let connection = self.systemDeviceFileOutput?.connection(withMediaType: AVMediaTypeVideo) {
                        if connection.isVideoStabilizationSupported {
                            connection.preferredVideoStabilizationMode = .auto
                        }
                    }
                    self.avCapturePhotoOutput.isLivePhotoCaptureEnabled = self.avCapturePhotoOutput.isLivePhotoCaptureSupported;
                    self.avCaptureSession.commitConfiguration()
                }
                catch {
                    
                    print("Error occured while creating video device input \(error)")
                    
                }
            }
        }
    }
    
    
    func subjectAreaDidChange(notification: NSNotification) {
        let devicePoint = CGPoint(x: 0.5, y: 0.5)
        focus(with: .autoFocus, exposureMode: .continuousAutoExposure, at: devicePoint, monitorSubjectAreaChange: false)
    }
    
    
    //MARK:- Camera Session Controls
    func startSession() {
        
        if !avCaptureSession.isRunning {
            sessionQueue().async {
                self.avCaptureSession.startRunning()
            }
        }
    }
    
    
    func stopSession() {
        if avCaptureSession.isRunning {
            sessionQueue().async {
                self.avCaptureSession.stopRunning()
            }
        }
    }
    
    
    func sessionQueue() -> DispatchQueue {
        return DispatchQueue.main
    }
    
    
    func currentVideoOrientation() -> AVCaptureVideoOrientation {
        var orientation: AVCaptureVideoOrientation
        
        switch UIDevice.current.orientation {
        case .portrait:
            orientation = AVCaptureVideoOrientation.portrait
        case .landscapeRight:
            orientation = AVCaptureVideoOrientation.landscapeLeft
        case .portraitUpsideDown:
            orientation = AVCaptureVideoOrientation.portraitUpsideDown
        default:
            orientation = AVCaptureVideoOrientation.landscapeRight
        }
        
        return orientation
    }
    
    
    //MARK:- capture images and save to filePath
    func startCapture()  {
        
        if movieOutput.isRecording == false {
            //configure device input
            let connection = movieOutput.connection(withMediaType: AVMediaTypeVideo)
            if (connection?.isVideoOrientationSupported)! {
                connection?.videoOrientation = currentVideoOrientation()
            }
            
            if (connection?.isVideoStabilizationSupported)! {
                connection?.preferredVideoStabilizationMode = AVCaptureVideoStabilizationMode.auto
            }
            
            let device = activeDeviceInput.device
            if (device?.isSmoothAutoFocusSupported)! {
                
                do {
                    try device?.lockForConfiguration()
                    device?.isSmoothAutoFocusEnabled = false
                    device?.unlockForConfiguration()
                } catch {
                    print("Error setting configuration: \(error)")
                }
            }
            outputURL = tempURL()
            //start record to file path
            movieOutput.startRecording(toOutputFileURL: outputURL, recordingDelegate: self)
        }
        else {
            stopRecording()
        }
    }
    
    
    func stopRecording() {
        
        if movieOutput.isRecording == true {
            movieOutput.stopRecording()
        }
    }
    
    
    //MARK:- Setup FilePath
    func tempURL() -> URL? {
        let directory = NSTemporaryDirectory() as NSString
        if directory != "" {
            path = directory.appendingPathComponent(NSUUID().uuidString + ".mp4")
            return URL(fileURLWithPath: path)
        }
        return nil
    }
    
    var recordedVideo: URL!

    func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
        
        guard (error == nil) else {
            return
        }
        recordedVideo = outputURL! as URL
           }
    
    
    
    
    func focus(with focusMode: AVCaptureFocusMode, exposureMode: AVCaptureExposureMode, at devicePoint: CGPoint, monitorSubjectAreaChange: Bool) {
        
        sessionQueue().async { [unowned self] in
            if let device = self.activeDeviceInput.device {
                do {
                    try device.lockForConfiguration()
                    
                    if device.isFocusPointOfInterestSupported && device.isFocusModeSupported(focusMode) {
                        device.focusPointOfInterest = devicePoint
                        device.focusMode = focusMode
                    }
                    if device.isExposurePointOfInterestSupported && device.isExposureModeSupported(exposureMode) {
                        device.exposurePointOfInterest = devicePoint
                        device.exposureMode = exposureMode
                    }
                    device.isSubjectAreaChangeMonitoringEnabled = monitorSubjectAreaChange
                    device.unlockForConfiguration()
                }
                catch {
                    print("Could not lock device for configuration: \(error)")
                    
                }
            }
        }
    }
    
    
    
    class func sharedInstance() -> VideoClientDeviceSettings {
        struct Singleton {
            static var sharedInstance =  VideoClientDeviceSettings()
        }
        return Singleton.sharedInstance
    }
}

extension UIDeviceOrientation {
    var videoOrientation: AVCaptureVideoOrientation? {
        switch self {
        case .portrait: return .portrait
        case .portraitUpsideDown: return .portraitUpsideDown
        case .landscapeLeft: return .landscapeRight
        case .landscapeRight: return .landscapeLeft
        default: return nil
        }
    }
}

extension UIInterfaceOrientation {
    var videoOrientation: AVCaptureVideoOrientation? {
        switch self {
        case .portrait: return .portrait
        case .portraitUpsideDown: return .portraitUpsideDown
        case .landscapeLeft: return .landscapeLeft
        case .landscapeRight: return .landscapeRight
        default: return nil
        }
    }
}

extension AVCaptureDeviceDiscoverySession {
    func uniqueDevicePositionsCount() -> Int {
        var uniqueDevicePositions = [AVCaptureDevicePosition]()
        
        for device in devices {
            if !uniqueDevicePositions.contains(device.position) {
                uniqueDevicePositions.append(device.position)
            }
        }
        return uniqueDevicePositions.count
    }
}

