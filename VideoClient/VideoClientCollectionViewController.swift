//
//  VideoClientCollectionViewController.swift
//
//  Created by Krishna Picart on 6/6/17.
//  Copyright © 2017 StepwiseDesigns. All rights reserved.
//

import UIKit
import AVFoundation
import CoreData


class VideoClientCollectionViewController: UICollectionViewController, NSFetchedResultsControllerDelegate {
    
    //MARK:- CoreData Implementation
    var stack = VideoClientCoreDataStack(modelName: "VideoClient")
    lazy var videoFetchRequest = NSFetchRequest<NSFetchRequestResult>()
    var videoFetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>? {
        didSet {
            videoFetchedResultsController?.delegate = self
            performCollectionSearch()
        }
    }
    
    
    
   // var userVideosArray = [UserVideo]()
    @IBOutlet weak var flowViewLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var collectionViewOutlet: UICollectionView!
    @IBOutlet weak var noVideoMsgOutlet: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        videoFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserVideo")
        videoFetchRequest.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        
        videoFetchedResultsController = NSFetchedResultsController(fetchRequest: videoFetchRequest, managedObjectContext: (stack?.context)!, sectionNameKeyPath: nil, cacheName: nil)
        
        collectionViewOutlet.backgroundColor = UIColor.blue
        
        let space: CGFloat = 2
        flowViewLayout.minimumInteritemSpacing = 0
        flowViewLayout.minimumLineSpacing = 5
        
        let dimensionW = (view.frame.size.width - (3 * space)) / 3.0
        let dimensionH = (view.frame.size.height - (2 * space)) / 4.0
        
        flowViewLayout.itemSize = CGSize(width: dimensionW,height: dimensionH)
        collectionViewOutlet.reloadData()
        noVideoMsgOutlet.isHidden = (videoFetchedResultsController?.fetchedObjects?.count)! > 0
    }
    
    
    internal override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (self.videoFetchedResultsController?.fetchedObjects?.count)!
    }
    
    
    internal override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoClientCollectionViewCell", for: indexPath) as! VideoClientCollectionViewCell
        let videoObject =  videoFetchedResultsController?.object(at: indexPath) as! UserVideo
        
        //convert from NSData to Data
        let dataObj = videoObject.videoThumbnail! as Data
        
        guard let videoThumbnail = UIImage(data: dataObj) else {
            return cell
        }
        
        cell.videoClientImageView.image = videoThumbnail
        return cell
    }
    
    
    internal override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailController = self.storyboard!.instantiateViewController(withIdentifier: "VideoClientPlaybackViewController") as! VideoClientPlaybackViewController
        
        let videoOBj = videoFetchedResultsController?.object(at:indexPath) as! UserVideo
        
        
        //push the video URL to new VC and disable save option since its already saved
        detailController.enableSaveButton = false
        let videoURLFromString = URL(string: videoOBj.userVideoURL!)
    
        
        detailController.outputURL = videoURLFromString
        navigationController!.pushViewController(detailController, animated: true)
    }
}

extension VideoClientCollectionViewController{
    
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


