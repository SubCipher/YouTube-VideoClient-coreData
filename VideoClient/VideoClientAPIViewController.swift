//
//  VideoClientAPIViewController.swift
//  VideoClient
//00
//  Created by Krishna Picart on 6/22/17.
//  Copyright © 2017 StepwiseDesigns. All rights reserved.
//

import UIKit
import SafariServices
import AVFoundation

import SystemConfiguration


class VideoClientAPIViewController: UIViewController, SFSafariViewControllerDelegate {
    
    weak var delegate: SFSafariViewControllerDelegate?
    let videoClientAPImethods = VideoClientAPImethods()
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    
    //var runCount = 0
    var internetIsAccessible: Bool!
    let deviceSettings = VideoClientDeviceSettings.sharedInstance()
    var constructedURLwithTypes: VideoClientDataModel.urlRequestMethodWithType!
    var postVideoURL: URL!
    
    @IBOutlet weak var instructionsOutlet: UITextView!
    @IBOutlet weak var postVideoOutlet: UIButton!
    @IBOutlet weak var authenticationOutlet: UIButton!
    var authCode:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        postVideoOutlet.isEnabled = false
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        internetIsAccessible = isInternetAvailable()
        
        //Check for internet/network access
        checkReachability()
    }
    
    //MARK:- Authentication token Reqest
    //references docs
    //https://developer.apple.com/documentation/safariservices/sfsafariviewcontroller
    //https://stackoverflow.com/questions/38818786/safariviewcontroller-how-to-grab-oauth-token-from-url
    

    //use two step post to prevent abuse/"incidental" public post
    //Step one authenticate
    @IBAction func authentication(_ sender: Any) {
        
        let youTubeAuthenticationMethod = URL(string: "\(apiURLs.googleAuthURL)&\(apiParams.responseType)&\(apiClientCreds.clientID)&\(apiScopeURL.upload)&\(apiURLs.redirect+":\(apiClientCreds.scheme)")")
        
        //MARK:- authentication method using Safari view controller w/ helper function to parse accesscode
        NotificationCenter.default.addObserver(self, selector: #selector(accessCodeRequest(_:)), name: Notification.Name("codeRequest"), object: nil)
        
        let safariVC = SFSafariViewController(url: youTubeAuthenticationMethod!)
        safariVC.delegate = self
        self.present(safariVC, animated: true, completion: nil)
    }
    
    
    @objc func accessCodeRequest(_ notification : Notification) {
        
        guard let codeDataAsURL = notification.object as? URL! else {
            return
        }
        dismiss(animated: false, completion: nil)
        
        authCode =  videoClientAPImethods.filterCodeResponse(codeDataAsURL.absoluteString) { (success, error) in
            
            guard error == nil else {
                
                self.postVideoOutlet.isEnabled = false
                let actionSheet = UIAlertController(title: "Code Request", message: error?.localizedDescription, preferredStyle: .alert)
                
                actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.present(actionSheet,animated: true, completion: nil)
                return
            }
            self.postVideoOutlet.isEnabled = true
        }
    }
    
    
    //MARK:- Authorization Request For Token
    //Step two post video
    @IBAction func postVideoActionButton(_ sender: Any) {
        
        guard (postVideoURL) != nil else {
            postVideoOutlet.isEnabled = false
            
            let actionSheet = UIAlertController(title: "Video", message: "no video selection made", preferredStyle: .alert)
            
            actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(actionSheet,animated: true, completion: nil)
            return
        }
        activityIndicatorView.startAnimating()
        
        postVideoOutlet.isEnabled = false
        
        let tokenExchangeCode = "code=\(authCode)"
        
        let methodForTokenExchange = "\(apiURLs.baseURL)\(apiMethods.tokenExchangeMethod)\(tokenExchangeCode)&\(apiClientCreds.clientID)&\(apiURLs.redirect):\(apiClientCreds.scheme)&\(apiParams.tokenExchangeGrantType)"
        
        constructedURLwithTypes = VideoClientDataModel.urlRequestMethodWithType(methodForTokenExchange,VideoClientDataModel.httpMethod.POST)
        videoClientAPImethods.methodRequest(constructedURLwithTypes!) {(success,error) in
            
            if success == false{
                
                self.activityIndicatorView.stopAnimating()
                
                let actionSheet = UIAlertController(title: "MethodRequest", message: error?.localizedDescription, preferredStyle: .alert)
                
                actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.present(actionSheet,animated: true, completion: nil)
                
            } else {
                
                let uploadURLasString = "\(apiURLs.baseURL)\(apiMethods.uploadVideoMethod)\(apiParams.uploadPart)"
                
                self.constructedURLwithTypes = VideoClientDataModel.urlRequestMethodWithType(uploadURLasString,VideoClientDataModel.httpMethod.POST)
                
                //add typeSwitch to parse upload request other POST request
                self.constructedURLwithTypes.typeSwitch = 1
                
                self.videoClientAPImethods.methodRequest(self.constructedURLwithTypes!){ (success,error) in
                    
                    guard (error == nil) else {
                        DispatchQueue.main.async{
                            self.activityIndicatorView.stopAnimating()
                            self.activityIndicatorView.isHidden = true
                            
                            let actionSheet = UIAlertController(title: "upload MethodRequest", message: error?.localizedDescription, preferredStyle: .alert)
                            actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                            self.present(actionSheet,animated: true, completion: nil)
                        }
                        return
                    }
                    DispatchQueue.main.async{
                        self.activityIndicatorView.stopAnimating()
                        
                        let alertController = UIAlertController(title: "upload MethodRequest", message: "video upload complete", preferredStyle: .actionSheet)
                        let sendButton = UIAlertAction(title: "Ok", style: .default, handler: { (action) -> Void in
                            
                            self.navigationController!.popToRootViewController(animated: true)

                        })
                        alertController.addAction(sendButton)
                        
                        self.present(alertController,animated: true, completion: nil)
                    }
                }
            }
        }
    }
}

extension VideoClientAPIViewController {
    /*
     reference resources for networking
     https://www.invasivecode.com/weblog/network-reachability-in-swift/
     https://developer.apple.com/documentation/systemconfiguration/scnetworkreachability-g7d#//apple_ref/doc/uid/TP40007260
     https://stackoverflow.com/questions/38726100/best-approach-for-checking-internet-connection-in-ios

 */
    
    func isInternetAvailable() -> Bool
    {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        return (isReachable && !needsConnection)
    }
    
    //green = found connection / red = no connection
    func checkReachability()  {
        
        if internetIsAccessible  == true {
            
            authenticationOutlet.backgroundColor = UIColor.init(red: 0.0, green: 1.0, blue: 0.0, alpha: 0.5)
            
        } else {
            authenticationOutlet.backgroundColor = UIColor.init(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.5)
            
            //MARK: failed connection alert
            let actionSheet = UIAlertController(title: "NETWORK ERROR", message: "Your Internet Connection Cannot Be Detected", preferredStyle: .actionSheet)
            
            let actOnButton = UIAlertAction(title: "Cancel", style: .default, handler: { (action) -> Void in
            })
            actionSheet.addAction(actOnButton)
            //actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(actionSheet,animated: true, completion: nil)
        }
    }
}



