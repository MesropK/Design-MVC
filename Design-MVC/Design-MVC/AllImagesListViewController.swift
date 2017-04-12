//
//  FirstViewController.swift
//  Design-MVC
//
//  Created by Mesrop Kareyan on 4/4/17.
//  Copyright © 2017 Mesrop Kareyan. All rights reserved.
//

import UIKit

let dataSourceURL = URL(string:"http://www.raywenderlich.com/downloads/ClassicPhotosDictionary.plist")!

class AllImagesListViewController: UIViewController {
    
    var photos = [PhotoRecord]()
    let pendingOperations = PendingOperations()
    weak var selectedImage: UIImage?

    @IBOutlet weak var tableVIew: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableVIew.delegate = self
        tableVIew.dataSource = self
        fetchPhotoDetails()
        (self.tableVIew as UIScrollView).delegate = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier,
                identifier == "showFromAllList",
            let photoViewController = segue.destination as? PhotoViewController {
            photoViewController.image = selectedImage
        }
    }
    
    func fetchPhotoDetails() {
        let request = URLRequest(url:dataSourceURL)
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        NSURLConnection.sendAsynchronousRequest(request, queue: OperationQueue.main) {response,data,error in
            if data != nil {
                
                let datasourceDictionary = (try! PropertyListSerialization.propertyList(from: data!, options:PropertyListSerialization.MutabilityOptions.mutableContainersAndLeaves, format: nil)) as! NSDictionary
                
                for(key, value) in datasourceDictionary {
                    let name = key as? String
                    let url = NSURL(string:value as? String ?? "")
                    
                    if name != nil && url != nil {
                        let photoRecord = PhotoRecord(name:name!, url:url! as URL)
                        self.photos.append(photoRecord)
                    }
                }
                
                self.tableVIew.reloadData()
            }
            if error != nil {
                let alert = UIAlertView(title:"Oops!",message:error!.localizedDescription, delegate:nil, cancelButtonTitle:"OK")
                alert.show()
            }
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }
    
}


extension AllImagesListViewController :  UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "downloadedCellID", for: indexPath)
        //1
        if cell.accessoryView == nil {
            let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
            cell.accessoryView = indicator
        }
        let indicator = cell.accessoryView as! UIActivityIndicatorView
        
        //2
        let photoDetails = photos[indexPath.row]
        
        //3
        cell.textLabel?.text = photoDetails.name
        cell.imageView?.image = photoDetails.image
        
        //4
        switch (photoDetails.state){
        case .filtered:
            indicator.stopAnimating()
        case .failed:
            indicator.stopAnimating()
            cell.textLabel?.text = "Failed to load"
        case .new, .downloaded:
            indicator.startAnimating()
            
            if (!tableView.isDragging && !tableView.isDecelerating) {
                self.startOperationsForPhotoRecord(photoDetails: photoDetails, indexPath: indexPath)
            }
        }
        return cell
    }
    
    //Optimizations
     func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        //1
        suspendAllOperations()
    }
    
     func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        // 2
        if !decelerate {
            loadImagesForOnscreenCells()
            resumeAllOperations()
        }
    }
    
     func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // 3
        loadImagesForOnscreenCells()
        resumeAllOperations()
    }
    
    func suspendAllOperations () {
        pendingOperations.downloadQueue.isSuspended = true
        pendingOperations.filtrationQueue.isSuspended = true
    }
    
    func resumeAllOperations () {
        pendingOperations.downloadQueue.isSuspended = false
        pendingOperations.filtrationQueue.isSuspended = false
    }
    
    func loadImagesForOnscreenCells () {
        //1
        if let pathsArray = tableVIew.indexPathsForVisibleRows {
            //2
            var allPendingOperations = Set(pendingOperations.downloadsInProgress.keys)
            allPendingOperations = allPendingOperations.union(pendingOperations.filtrationsInProgress.keys)
            
            //3
            var toBeCancelled = allPendingOperations
            let visiblePaths = Set(pathsArray)
            toBeCancelled.subtract(visiblePaths)
            
            //4
            var toBeStarted = visiblePaths
            toBeStarted.subtract(allPendingOperations)
            
            // 5
            for indexPath in toBeCancelled {
                if let pendingDownload = pendingOperations.downloadsInProgress[indexPath] {
                    pendingDownload.cancel()
                }
                pendingOperations.downloadsInProgress.removeValue(forKey: indexPath)
                if let pendingFiltration = pendingOperations.filtrationsInProgress[indexPath] {
                    pendingFiltration.cancel()
                }
                pendingOperations.filtrationsInProgress.removeValue(forKey: indexPath)
            }
            
            // 6
            for indexPath in toBeStarted {
                let indexPath = indexPath as IndexPath
                let recordToProcess = self.photos[indexPath.row]
                startOperationsForPhotoRecord(photoDetails: recordToProcess, indexPath: indexPath as IndexPath)
            }
        }
    }

}

extension AllImagesListViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if let cell = tableView.cellForRow(at: indexPath) {
            selectedImage = cell.imageView?.image
        }
        return indexPath
    }
    
}

//MARK: Operations
extension AllImagesListViewController {
    
    func startOperationsForPhotoRecord(photoDetails: PhotoRecord, indexPath: IndexPath){
        switch (photoDetails.state) {
        case .new:
            startDownloadForRecord(photoDetails: photoDetails, indexPath: indexPath)
        case .downloaded:
            startFiltrationForRecord(photoDetails: photoDetails, indexPath: indexPath)
        default:
            NSLog("do nothing")
        }
    }

    func startDownloadForRecord(photoDetails: PhotoRecord, indexPath: IndexPath){
        //1
        if let _ = pendingOperations.downloadsInProgress[indexPath as IndexPath] {
            return
        }
        
        //2
        let downloader = ImageDownloader(photoRecord: photoDetails)
        //3
        downloader.completionBlock = {
            if downloader.isCancelled {
                return
            }
            DispatchQueue.main.async(execute: {
                self.pendingOperations.downloadsInProgress.removeValue(forKey: indexPath)
                self.tableVIew.reloadRows(at: [indexPath], with: .fade)
            })
        }
        //4
        pendingOperations.downloadsInProgress[indexPath] = downloader
        //5
        pendingOperations.downloadQueue.addOperation(downloader)
    }
    
    func startFiltrationForRecord(photoDetails: PhotoRecord, indexPath: IndexPath){
        if let _ = pendingOperations.filtrationsInProgress[indexPath]{
            return
        }
        
        let filterer = ImageFiltration(photoRecord: photoDetails)
        filterer.completionBlock = {
            if filterer.isCancelled {
                return
            }
            DispatchQueue.main.async(execute: {
                self.pendingOperations.filtrationsInProgress.removeValue(forKey: indexPath)
                self.tableVIew.reloadRows(at: [indexPath], with: .fade)
            })
        }
        pendingOperations.filtrationsInProgress[indexPath] = filterer
        pendingOperations.filtrationQueue.addOperation(filterer)
    }
}

