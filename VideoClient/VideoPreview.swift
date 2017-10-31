//
//  VideoPreview.swift
//  VideoClient
//
//  Created by Krishna Picart on 6/9/17.
//  Copyright © 2017 StepwiseDesigns. All rights reserved.
//

import UIKit
import AVFoundation


class VideoPreview: UIView {
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        
        guard let layer =  layer as? AVCaptureVideoPreviewLayer else {
            fatalError("AVCapturePreviewLayer was not able to load.")
        }
        return layer
    }
    
    var session: AVCaptureSession? {
        get {
            return videoPreviewLayer.session
        }
        set {
            videoPreviewLayer.session = newValue
        }
    }
    
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
}
