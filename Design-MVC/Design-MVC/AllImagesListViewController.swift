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
    
    lazy var photos = NSDictionary(contentsOf: dataSourceURL)!

    @IBOutlet weak var tableVIew: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableVIew.delegate = self
        tableVIew.dataSource = self
    }

    func applySepiaFilter(image:UIImage) -> UIImage? {
        let inputImage = CIImage(data:UIImagePNGRepresentation(image)!)
        let context = CIContext(options:nil)
        let filter = CIFilter(name:"CISepiaTone")
        filter!.setValue(inputImage, forKey: kCIInputImageKey)
        filter!.setValue(0.8, forKey: "inputIntensity")
        if let outputImage = filter!.outputImage ,
            let outImage = context.createCGImage(outputImage, from: outputImage.extent) {
            return UIImage(cgImage: outImage)
        }
        return nil
    }
    
}


extension AllImagesListViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "downloadedCellID", for: indexPath)
        let rowKey = photos.allKeys[indexPath.row] as! String
        
        var image : UIImage?
        if let imageURL = URL(string:photos[rowKey] as! String),
            let imageData = try? Data(contentsOf: imageURL) {
            //1
            let unfilteredImage = UIImage(data:imageData)
            //2
            image = self.applySepiaFilter(image: unfilteredImage!)
        }
        
        // Configure the cell...
        cell.textLabel?.text = rowKey
        if image != nil {
            cell.imageView?.image = image!
        }
        
        return cell
    }

}


