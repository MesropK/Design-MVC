//
//  PhotoOperations.swift
//  Design-MVC
//
//  Created by Mesrop Kareyan on 4/6/17.
//  Copyright © 2017 Mesrop Kareyan. All rights reserved.
//

import UIKit

class ImageDownloader: Operation {
    //1
    let photoRecord: PhotoRecord
    
    //2
    init(photoRecord: PhotoRecord) {
        self.photoRecord = photoRecord
    }
    
    //3
    override func main() {
        //4
        if self.isCancelled {
            return
        }
        //5
        let imageData = try? Data(contentsOf: self.photoRecord.url)
        
        //6
        if self.isCancelled {
            return
        }
        
        //7
        if let imageData = imageData, imageData.count > 0 {
            self.photoRecord.image =  UIImage(data:imageData)
            self.photoRecord.state = .downloaded
        }
        else
        {
            self.photoRecord.state = .failed
            self.photoRecord.image = UIImage(named: "Failed")
        }
    }
}
