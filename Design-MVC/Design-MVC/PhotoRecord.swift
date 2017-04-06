//
//  PhotoRecord.swift
//  Design-MVC
//
//  Created by Mesrop Kareyan on 4/6/17.
//  Copyright © 2017 Mesrop Kareyan. All rights reserved.
//

import UIKit

// This enum contains all the possible states a photo record can be in
enum PhotoRecordState {
    case new, downloaded, filtered, failed
}

class PhotoRecord {
    let name: String
    let url:  URL
    var state = PhotoRecordState.new
    var image = UIImage(named: "Placeholder")
    init(name:String, url: URL) {
        self.name = name
        self.url = url
    }
}
