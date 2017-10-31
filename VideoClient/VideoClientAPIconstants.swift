//
//  APIconstants.swift
//  VideoClient
//
//  Created by Krishna Picart on 7/6/17.
//  Copyright © 2017 StepwiseDesigns. All rights reserved.
//


extension VideoClientAPIViewController {
    
    struct apiURLs {
        
        //URL paths
        static let googleAuthURL = "https://accounts.google.com/o/oauth2/v2/auth?"
        static let baseURL = "https://www.googleapis.com/"
        static let redirect = "redirect_uri=com.StepwiseDesigns.VideoClient"
    }
    
    struct apiScopeURL {
        static let upload = "scope=https://www.googleapis.com/auth/youtube.upload"
    }
    
    struct apiMethods {
        
        static let listVideoMethod = "youtube/v3/videos?"
        static let uploadVideoMethod = "upload/youtube/v3/videos?"
        static let tokenExchangeMethod = "oauth2/v4/token?"
    }
    
    struct apiParams {
        
        //URL parameters
        static let tokenExchangeGrantType = "grant_type=authorization_code"
        static let videoTitle = "title=videoTest"
        static let videoCatID = "categoryId=22"
        static let videoDescription = "what it is"
        static let mine = "mine=true"
        static let part = "part=snippet%2CcontentDetails%2Cstatistics"
        static let uploadPart = "part=snippet,status,contentDetails"
        static let uploadType = "uploadType=resumable"
        static let responseType = "response_type=code"
        static let accessType = "access_type=offline"
    }
    
    struct apiClientCreds {
        //app unique IDs
        static let scheme = "com.StepwiseDesigns.VideoMeme"
        static let apiKey = "key=YOUR_API_KEY_HERE"
        static let clientID = "client_id=YOUR_CLIENT_ID_HERE.apps.googleusercontent.com"
    }
}
