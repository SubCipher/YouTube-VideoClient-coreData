//
//  VideoClientPlaybackViewController.swift
//  VideoClient
//
//  Created by Krishna Picart on 6/10/17.
//  Copyright © 2017 StepwiseDesigns. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import CoreData


class VideoClientPlaybackViewController: UIViewController, NSFetchedResultsControllerDelegate {
    
    let stack = VideoClientCoreDataStack(modelName: "VideoClient")
    lazy var videoFetchRequest = NSFetchRequest<NSFetchRequestResult>()

    var videoFetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>? {
        didSet{
        videoFetchedResultsController?.delegate = self
            performCollectionSearch()
        }
    }
    
    let avPlayer = AVPlayer()
    var avPlayerLayer: AVPlayerLayer!
    
    var outputURL: URL!
    var enableSaveButton: Bool!
    
    @IBOutlet weak var saveVideoOutlet: UIButton!
    @IBOutlet weak var playbackMode: UILabel!
    @IBOutlet weak var videoPlaybackView: UIView!
    @IBOutlet weak var playBackPostButtonOutlet: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if enableSaveButton == false {
            saveVideoOutlet.isEnabled = enableSaveButton
        }
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        playVideoItem()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        videoFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserVideo")
        videoFetchRequest.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        
        videoFetchedResultsController = NSFetchedResultsController(fetchRequest: videoFetchRequest, managedObjectContext: (stack?.context)!, sectionNameKeyPath: nil, cacheName: nil)
    }
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        avPlayerLayer.frame =  view.bounds
        videoPlaybackView.layer.insertSublayer(avPlayerLayer, at: 0)
    }
    
    @IBAction func playBackVideo(_ sender: UIButton) {  playVideoItem() }
    
    func playVideoItem(){
        
        playbackMode.isHidden = false
        
        avPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        let playerItem = AVPlayerItem(url: outputURL)
        avPlayer.replaceCurrentItem(with: playerItem)
        
        avPlayer.play()
    }
    
    @IBAction func saveVideo(_ sender: UIButton) {
        saveNewVideo()
    }
    
    func generateThumbnailForVideoAtURL(filePathLocal: URL) -> UIImage? {
        
        let asset = AVURLAsset(url: filePathLocal)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        
        let timestamp = CMTime(seconds: 1, preferredTimescale: 60)
        
        do {
            let thumbnailGen = try generator.copyCGImage(at: timestamp, actualTime: nil)
            return UIImage(cgImage: thumbnailGen)
        }
        catch let error as NSError
        {
            print("Image generation failed with error \(error)")
            return nil
        }
    }
    
    
       func saveNewVideo(){
            let newThumbNailFromFile = self.generateThumbnailForVideoAtURL(filePathLocal: self.outputURL)!
        //save to coreData
        let userVideoItem = UserVideo(userVideoThumbnail: NSData(data: UIImageJPEGRepresentation(newThumbNailFromFile, 0.5)!), userVideoURL: outputURL.absoluteString, context: (stack?.context)!)
            
        userVideoItem.videoThumbnail = NSData(data: UIImageJPEGRepresentation(newThumbNailFromFile, 0.5)!)
        
        userVideoItem.userName = "GUEST"
       userVideoItem.video = NSData(contentsOf: self.outputURL!)
      
        userVideoItem.userVideoURL =  outputURL.absoluteString
        userVideoItem.creationDate = Date()
        
        do {
            try self.stack?.saveContext()
             print("😶save thumbnail")
            let alertController = UIAlertController(title: "Success", message: "Your File Was Saved To Local Device", preferredStyle: .actionSheet)
            let sendButton = UIAlertAction(title: "Ok", style: .default, handler: { (action) -> Void in
                
                
            })
            
            alertController.addAction(sendButton)
            
            self.present(alertController,animated: true, completion: nil)
            
            DispatchQueue.main.async{   self.saveVideoOutlet.isEnabled = false }
            
        } catch {
            let actionSheet = UIAlertController(title: "ERROR", message: error.localizedDescription , preferredStyle: .alert)
            actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        }
    }
    

    
    
    @IBAction func playbackPostButtonAction(_ sender: UIButton) {
        guard outputURL != nil else {
            return
        }
        performSegue(withIdentifier: "outputURLForPost", sender: outputURL)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let videoClientAPIViewContoller = segue.destination as!  VideoClientAPIViewController
        
        videoClientAPIViewContoller.postVideoURL = outputURL
    }
}


extension VideoClientPlaybackViewController {
    
    func performCollectionSearch() {
        
        if let fc = videoFetchedResultsController {
            do {
                try fc.performFetch()
            }
            catch let fetchError as NSError {
                print("Error while trying to perform a search: \n\(fetchError)\n\(String(describing: videoFetchedResultsController))")
            }
        }
    }
}


