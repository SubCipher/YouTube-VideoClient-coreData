//
//  VideoClientCustomRect.swift
//  VideoClient
//
//  Created by kpicart on 6/18/17.
//  Copyright © 2017 StepwiseDesigns. All rights reserved.
//

import UIKit

//create main textFields
var isDeviceVertical = true

class VideoClientCustomRect: UIViewController  {
    
    //var for holding frame sizes
    internal var activeFrameSize = CGSize()
    private var positionID = String()

    //MARK: - Return Divisors
    
    //set and return divisors based on string ID: switch is used for future ext.
    private func framePositionCal() ->(positionValue:CGPoint,sizeValue:CGSize) {
        
        var cgPointDivisor = CGPoint()
        var cgSizeDivisor = CGSize()
        
        switch positionID {

        case "videoPlaybackView":
            cgPointDivisor = isDeviceVertical == true ? CGPoint(x: -375.0, y: 7.3) : CGPoint(x: -667.0, y: 7.2)
            cgSizeDivisor = isDeviceVertical == true ? CGSize(width: 1.0, height: 1.45) : CGSize(width: 1.0, height: 1.4)
            
        case "waterMarkTitle":
            cgPointDivisor = isDeviceVertical == true ? CGPoint(x: -375.0, y: 7.3) : CGPoint(x: -667.0, y: 7.2)
            cgSizeDivisor = isDeviceVertical == true ? CGSize(width: 1.0, height: 1.45) : CGSize(width: 1.0, height: 1.4)
            
        case "waterMarkParent":
            cgPointDivisor = isDeviceVertical == true ? CGPoint(x: -375.0, y: 7.3) : CGPoint(x: -667.0, y: 7.2)
            cgSizeDivisor = isDeviceVertical == true ? CGSize(width: 1.0, height: 1.45) : CGSize(width: 1.0, height: 1.4)


        default:
            print("out of options")
        }
        return  (cgPointDivisor,cgSizeDivisor)
    }
    
    //get current display frame with string ID from global var, set by calling func
    internal func getCGRectPosition(_ ID:String) ->(CGRect){
    positionID = ID
        let videoCGRect = CGRect(x: (activeFrameSize.width / framePositionCal().positionValue.x),
                                 y: (activeFrameSize.height / framePositionCal().positionValue.y),
                                 width: activeFrameSize.width / framePositionCal().sizeValue.width,
                                 height: activeFrameSize.height / framePositionCal().sizeValue.height)
        return (videoCGRect)
    }
    
    
}
