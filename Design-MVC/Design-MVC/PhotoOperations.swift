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
            self.photoRecord.image = #imageLiteral(resourceName: "false .png")
        }
    }
}

class ImageFiltration: Operation {
    let photoRecord: PhotoRecord
    
    init(photoRecord: PhotoRecord) {
        self.photoRecord = photoRecord
    }
    
    override func main () {
        if self.isCancelled {
            return
        }
        
        if self.photoRecord.state != .downloaded {
            return
        }
        
        if let filteredImage = applySepiaFilter(image:self.photoRecord.image!) {
            self.photoRecord.image = filteredImage
            self.photoRecord.state = .filtered
        }
    }
    
    func applySepiaFilter(image:UIImage) -> UIImage? {
        let inputImage = CIImage(data:UIImagePNGRepresentation(image)!)
        
        if self.isCancelled {
            return nil
        }
        let context = CIContext(options:nil)
        let filter = CIFilter(name:"CISepiaTone")
        filter!.setValue(inputImage, forKey: kCIInputImageKey)
        filter!.setValue(0.8, forKey: "inputIntensity")
        let outputImage = filter!.outputImage
        
        if self.isCancelled {
            return nil
        }
        
        let outImage = context.createCGImage(outputImage!, from: outputImage!.extent)
        let returnImage = UIImage(cgImage: outImage!)
        return returnImage
    }
}
