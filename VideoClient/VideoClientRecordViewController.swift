//
//  VideoClientRecordViewController.swift
//  VideoClient
//
//  Created by Krishna Picart on 5/31/17.
//  Copyright © 2017 StepwiseDesigns. All rights reserved.
//

import UIKit
import AVFoundation
import Foundation


/* Documentation and implementation references:
 
 https://developer.apple.com/library/content/samplecode/AVCam/Introduction/Intro.html#//apple_ref/doc/uid/DTS40010112-Intro-DontLinkElementID_2
 
 https://developer.apple.com/library/content/documentation/AudioVideo/Conceptual/AVFoundationPG/Articles/00_Introduction.html#//apple_ref/doc/uid/TP40010188-CH1-SW3
 */

class VideoClientRecordViewController: UIViewController {
    
    let deviceSettings = VideoClientDeviceSettings.sharedInstance()
    
    @IBOutlet weak var liveRecordingOutlet: UILabel!
    @IBOutlet weak var switchCameraOutlet: UIButton!
    @IBOutlet weak var recordButtonOutlet: UIButton!
    @IBOutlet weak var videoPreview: VideoPreview!
    @IBOutlet weak var playbackOutlet: UIButton!
    
    @IBOutlet weak var systemDevicesUnavailableOutlet: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        liveRecordingOutlet.isHidden = true
        recordButtonOutlet.isEnabled = false
        switchCameraOutlet.isEnabled = false
        playbackOutlet.isEnabled = false
        systemDevicesUnavailableOutlet.isHidden = false
        videoPreview.session = deviceSettings.avCaptureSession
        
        
        //initiate system device configuration for camera/audio devices
       
        if deviceSettings.setupSession(){
            
            deviceSettings.startSession()
            
            liveRecordingOutlet.isEnabled = true
            recordButtonOutlet.isEnabled = true
            switchCameraOutlet.isEnabled = true
            systemDevicesUnavailableOutlet.isHidden = true
            
            videoPreview.videoPreviewLayer.connection.videoOrientation = deviceSettings.initialVideoOrientation
        } else {

            
            guard (videoPreview.session?.isRunning)! else {
                
            let actionSheet = UIAlertController(title: "Camera/Video", message: "system devices are unavailable, check your settings", preferredStyle: .alert)
            
            actionSheet.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            self.present(actionSheet,animated: true, completion: nil)
            return
            }
        }
         //view.reloadInputViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
            liveRecordingOutlet.isEnabled = true
            recordButtonOutlet.isEnabled = true
            switchCameraOutlet.isEnabled = true
            systemDevicesUnavailableOutlet.isHidden = true
            playbackOutlet.isEnabled = false
        
    }
    
    override var shouldAutorotate: Bool {
        // Disable autorotation of the interface when recording is in progress.
        if deviceSettings.movieOutput.isRecording == true {
            return self.deviceSettings.movieOutput.isRecording
        } else {
            return !self.deviceSettings.movieOutput.isRecording
        }
    }
    
    //determine which interface to support
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }
    
    //coordinate UI object animations when device changes size/position
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        if let videoPreviewLayerConnection = videoPreview.videoPreviewLayer.connection {
            let deviceOrientation = UIDevice.current.orientation
            
            guard let newVideoOrientation = deviceOrientation.videoOrientation, deviceOrientation.isPortrait || deviceOrientation.isLandscape else {
                return
            }
            videoPreviewLayerConnection.videoOrientation = newVideoOrientation
        }
    }
    
    
    //MARK:- Change Camera Button Action
    @IBAction func changeCamera(_ sender: UIButton) {
        deviceSettings.switchCamera()
    }
    
    //MARK:- RecordButton Action
    @IBAction func recordButtonAction(_ sender: UIButton) {
        deviceSettings.startCapture()
        
        deviceSettings.sessionQueue().async {
            
            if self.deviceSettings.movieOutput.isRecording {

                self.liveRecordingOutlet.isHidden = true
                self.playbackOutlet.isEnabled = true
                self.recordButtonOutlet.setTitle("Record", for: .normal)
                self.switchCameraOutlet.isEnabled = true
                
            } else {

                self.switchCameraOutlet.isEnabled = false
                self.recordButtonOutlet.setTitle("Stop", for: .normal)

                self.liveRecordingOutlet.isHidden = false
                self.playbackOutlet.isEnabled = false
            }
        }
    }
    
    @IBAction func playbackButtonAction(_ sender: UIButton) {
        
        guard deviceSettings.recordedVideo != nil else {
            return
        }
        performSegue(withIdentifier: "VideoClientPlayback", sender: deviceSettings.recordedVideo)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let playbackViewController = segue.destination as! VideoClientPlaybackViewController
        playbackViewController.enableSaveButton = true
        playbackViewController.outputURL = sender as! URL
    }
}
