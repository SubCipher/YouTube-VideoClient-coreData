//
//  VideoClientDataModel.swift
//  VideoClient
//
//  Created by Krishna Picart on 6/3/17.
//  Copyright © 2017 StepwiseDesigns. All rights reserved.
//


import Foundation
import UIKit



class VideoClientDataModel: NSObject {
    
    struct videos {
        
        var videoURL: URL
        var videoThumbnail: UIImage
        
        init(videoURL: URL, videoThumbnail: UIImage ) {
            self.videoURL = videoURL
            self.videoThumbnail = videoThumbnail
        }
    }
    
    enum httpMethod {
        case POST
        case GET
    }
    
    struct urlRequestMethodWithType {
        var httpMethodType: httpMethod
        var urlMethodAsString: String
        var typeSwitch = 0
        
        init(_ urlMethodAsString: String,_ httpMethodType: httpMethod ){
            
            self.httpMethodType = httpMethodType
            self.urlMethodAsString = urlMethodAsString
        }
    }
}
