//
//  PhotoViewController.swift
//  Design-MVC
//
//  Created by Mesrop Kareyan on 4/12/17.
//  Copyright © 2017 Mesrop Kareyan. All rights reserved.
//

import UIKit

enum Filter : Int {
    case filter_1 = 1
    case filter_2
    case filter_3
    case filter_4
    case filter_5
    var name: String {
        switch self {
        case .filter_1:
            return "CIPhotoEffectMono"
        case .filter_2:
            return "CIColorPosterize"
        case .filter_3:
            return "CIPhotoEffectChrome"
        case .filter_4:
            return "CIVignette"
        case .filter_5:
            return "CIPhotoEffectFade"
        }
    }
}

enum PhotoViewerType {
    case allImages
    case forUser
}

class PhotoViewController: UIViewController {
    
    var image: UIImage?
    @IBOutlet weak var scrollView: UIScrollView?

    @IBOutlet weak var imageView: UIImageView! {
        didSet {
            imageView.image = image
        }
    }
    
    var type: PhotoViewerType?
    
    @IBOutlet var filterButtons: [UIButton]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    func configure() {
        guard let type = self.type  else {
            fatalError()
        }
        switch type {
        case .allImages:
            break
        case .forUser:
            break
        }
    }
    
    @IBAction func deonButtonAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonAction(_ sender: Any) {
        saveImageToDataBase()
    }
    
    @IBAction func filterButtonTapped(_ button: UIButton) {
        if let filter = Filter(rawValue: button.tag) {
            makePhoto(with: filter)
        }
    }
    
    @IBAction func tapAction(_ tap: UITapGestureRecognizer) {
        self.scrollView?.setZoomScale(1, animated: true)
    }
    
    func saveImageToDataBase() {
        if let image = self.image {
            CoreDataManager.prepareImageForSaving(image: image)
        }
    }
    
    func makePhoto(with filter: Filter) {
        guard let image = self.image else {
            return
        }
        let inputImage = CIImage(data:UIImagePNGRepresentation(image)!)
        let context = CIContext(options:nil)
        let filter = CIFilter(name: filter.name)
        filter!.setValue(inputImage, forKey: kCIInputImageKey)
//        /filter!.setValue(0.8, forKey: "inputIntensity")
        let outputImage = filter!.outputImage
        let outImage = context.createCGImage(outputImage!, from: outputImage!.extent)
        let returnImage = UIImage(cgImage: outImage!)
        self.imageView.image = returnImage
    }
    

}


extension PhotoViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
}
