//
//  VideoClientAPImethods.swift
//  VideoClient
//
//  Created by Krishna Picart on 7/6/17.
//  Copyright © 2017 StepwiseDesigns. All rights reserved.
//

import Foundation

class VideoClientAPImethods: NSObject {
    
    let session = URLSession.shared
    var authToken: String = ""
    let deviceSettings = VideoClientDeviceSettings.sharedInstance()
    let params = ["part":"snippet","categoryID":"12","description":"the new video"]

    //MARK-: Filter For Server Response
    func filterCodeResponse(_ code: String, completionHandlerForToken: @escaping (_ success: Bool, _ error:NSError?)->Void) -> String {
        
        //use for loop and arrays to perform chacter matching for parsing the authToken response
        var codeResponse = code
        var indexCount = 0
        var matchArray = [Int]()
        let charToMatch = Character("=")
        
        for i in codeResponse.characters {
            
            if charToMatch == i {
                matchArray.append(indexCount)
            }
            indexCount += 1
        }
        
        let charToMatchIndex = matchArray.max()
        let start = codeResponse.characters.startIndex
        
        let filterRange = codeResponse.characters.index(start, offsetBy: charToMatchIndex!)
        
        let range = (codeResponse.startIndex...filterRange)
        codeResponse.characters.removeSubrange(range)
        
        if codeResponse.characters.contains("%"){
            codeResponse.characters.removeSubrange(codeResponse.characters.index(of: "%")!...codeResponse.characters.index(before: codeResponse.characters.endIndex))
            
        } else {
            
            completionHandlerForToken(false, NSError(domain: "no key for login access filterd", code: 0, userInfo: [NSLocalizedDescriptionKey: "filter could not parse data"]))
        }
        completionHandlerForToken(true, nil)
        return codeResponse
    }
    
    
    func methodRequest(_ urlAsStringWithHTTPtype: VideoClientDataModel.urlRequestMethodWithType, completionHandlerForMethodRequest: @escaping (_ success: Bool,_ error: NSError?) -> Void) {
        
        let formatedURLrequest = formatRequest(urlAsStringWithHTTPtype)
        
        let _ = taskForMethodRequest(formatedURLrequest) { (response, error) in
            
            if error != nil {
                completionHandlerForMethodRequest(false,NSError(domain: "URLRequest", code: 1, userInfo: [NSLocalizedDescriptionKey: error?.localizedDescription ?? "unknown error:  completionHandlerForMethodRequest"]))
            }
            else {
                
                if let results = response as? [String:AnyObject]{
                    
                    guard let filteredAuthToken = results["access_token"] else {
                        completionHandlerForMethodRequest(true,nil)
                        return
                    }
                    self.authToken = filteredAuthToken as! String
                    completionHandlerForMethodRequest(true,nil)
                    
                }
            }
        }
    }
    
    
    //MARK: - Helper Method For formatting URLRequest
    
    func formatRequest(_ constructedRequest:VideoClientDataModel.urlRequestMethodWithType) -> URLRequest{
        var request = URLRequest(url: URL(string:constructedRequest.urlMethodAsString)!)
        
        if constructedRequest.httpMethodType == .GET {
            request.httpMethod = "GET"
            return request
        }
        else {
            
            request.httpMethod = "POST"
            
            //parse POST requests: 0 = oAuth 1 = upload
            if constructedRequest.typeSwitch == 1 {
                request.addValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
                
                let boundary = "Boundary-\(UUID().uuidString)"
                request.setValue("multipart/form-data;boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
                
                var uploadThisVideo = Data()
                
                do {
                    uploadThisVideo = try NSData(contentsOf: deviceSettings.outputURL, options: NSData.ReadingOptions()) as Data
                } catch {
                    print(error)
                }
                request.httpBody = createBody(parameters:params,
                                              boundary:boundary,
                                              data:uploadThisVideo,
                                              mimeType:"video/mp4",
                                              filename: deviceSettings.outputURL.lastPathComponent)
            }
            return request
        }
    }

    
    
    //Ref Docs for POST: https://newfivefour.com/swift-form-data-multipart-upload-URLRequest.html
    
    func createBody(parameters:[String:String],boundary:String,  data:Data,mimeType:String,filename:String)-> Data {
        
        var body = Data()
        let boundaryPrefix = "--\(boundary)\r\n"
        
        for (key,value) in parameters {
            body.appendString(boundaryPrefix)
            body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            body.appendString("\(value)\r\n")
        }
        
        body.appendString(boundaryPrefix)
        body.appendString("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"r\n")
        body.appendString("Content-Type: \(mimeType)\r\n\r\n")
        body.append(data)
        body.appendString("\r\n")
        body.appendString("--".appending(boundary.appending("--")))
        
        return body as Data
    }
    

    func taskForMethodRequest(_ processedURL: URLRequest,
                              completionHandlerForYoutubeTask: @escaping ( _ results: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        let task = session.dataTask(with: processedURL as URLRequest) { (data, response, error) in
            
            func sendError(_ error: String) {
                
                let userInfo = [NSLocalizedDescriptionKey: error]
                completionHandlerForYoutubeTask(response ?? "taskResponse" as AnyObject, NSError(domain: "TaskForPost", code: 1, userInfo: userInfo))
            }
            
            guard (error == nil) else {
                sendError((error?.localizedDescription) ?? "unknown error performing taskForMethodRequest")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError((error?.localizedDescription) ?? "code not found" )
                return
            }
            
            guard let data = data else {
                sendError((error?.localizedDescription)!)
                return
            }
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData:completionHandlerForYoutubeTask)
        }
        
        task.resume()
        return task
    }
    
    //MARK: - Convert from json
    private func convertDataWithCompletionHandler(_ data: Data, completionHandlerForConvertData: (_ result:AnyObject?, _ error: NSError?) -> Void) {
        
        var parsedResult: AnyObject! = nil
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : error.localizedDescription]
            completionHandlerForConvertData(true as AnyObject?,NSError(domain: "convertDataWithCompletionHandler", code: 2, userInfo: userInfo))
        }
        completionHandlerForConvertData(parsedResult as AnyObject?,nil)
    }
    
    func performUpdatesOnMainQueue(_ updates: @escaping () -> Void) {
        DispatchQueue.main.async {
            updates()
        }
    }
}

extension Data {
    mutating func appendString(_ string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: false)
        append(data!)
    }
}

