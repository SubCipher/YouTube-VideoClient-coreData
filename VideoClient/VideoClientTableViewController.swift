//
//  VideoClientViewTableViewController.swift
//
//  Created by Krishna Picart on 6/6/17.
//  Copyright © 2017 StepwiseDesigns. All rights reserved.
//

import UIKit
import CoreData

class VideoClientTableViewController: UITableViewController , NSFetchedResultsControllerDelegate{
    
    
    let stack = VideoClientCoreDataStack(modelName: "VideoClient")
    lazy var videofetchRequest = NSFetchRequest<NSFetchRequestResult>()
    var videoFetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>? {
        didSet {
        
        // Whenever the frc changes execute search
        videoFetchedResultsController?.delegate = self
        performCollectionSearch()
        }
    }
    
    var userVideosArray = [UserVideo]()
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        videofetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserVideo")
        videofetchRequest.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        
        videoFetchedResultsController = NSFetchedResultsController(fetchRequest: videofetchRequest, managedObjectContext: (stack?.context)!, sectionNameKeyPath: nil, cacheName: nil)
        
        loadData()
    }
    
    
        func loadData(){
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserVideo")
            
        do {
            let videoFetchRequest = try self.stack?.context.fetch(fetchRequest)
           userVideosArray = videoFetchRequest as! [UserVideo]
            tableView.reloadData()
        } catch {
            
        }
    }
    
    
    func removeVideo(_ outputURL: URL) {
        let path = outputURL.path
        if FileManager.default.fileExists(atPath: path) {
            do {
                try FileManager.default.removeItem(atPath: path)
            }
            catch {
                print("Could not remove file at url: \(outputURL)")
            }
        }
    }
    
    
    // MARK: - Table view data source
    
    internal override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return (videoFetchedResultsController?.fetchedObjects?.count)!
        
        return userVideosArray.count
        
    }
    
    
    internal override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath)
       // let singleCell = userVideosArray[indexPath.row]
        
        let videoObj = videoFetchedResultsController?.object(at: indexPath) as! UserVideo
        
        cell.textLabel?.text = "\(videoObj.userName!) created:\(videoObj.creationDate!)"
        return cell
    }
    
    //delete on swipe
    internal override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            // Delete the row from the data source
            //allow uesr to remove video from path in tmp dir while retaining copy in photoLib
            
            let videoURLFromString = URL(string: userVideosArray[indexPath.row].userVideoURL!)
            userVideosArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            removeVideo(videoURLFromString!)
            
            
            if let context = self.videoFetchedResultsController?.managedObjectContext,  let delObj = self.videoFetchedResultsController?.object(at: indexPath) as? UserVideo {
                context.delete(delObj)
                
                do {
                    try self.stack?.context.save()
                }
                catch {
                    print("error Saving Obj")
                    
                }
            }

        }
        do {
            try self.stack?.context.save()
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
    
    internal override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailController = self.storyboard!.instantiateViewController(withIdentifier: "VideoClientPlaybackViewController") as! VideoClientPlaybackViewController
        
        detailController.enableSaveButton = false
        let videoURLFromString = URL(string: userVideosArray[indexPath.row].userVideoURL!)
        
        detailController.outputURL = videoURLFromString
        navigationController!.pushViewController(detailController, animated: true)
    }
    
}

extension VideoClientTableViewController{
    
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
