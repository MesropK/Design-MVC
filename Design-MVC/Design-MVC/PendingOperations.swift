//
//  PendingOperations.swift
//  Design-MVC
//
//  Created by Mesrop Kareyan on 4/6/17.
//  Copyright © 2017 Mesrop Kareyan. All rights reserved.
//

import Foundation

class PendingOperations {
    
    lazy var downloadsInProgress = [IndexPath: Operation]()
    lazy var downloadQueue: OperationQueue = {
        var queue  = OperationQueue()
        queue.name = "Download queue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    lazy var filtrationsInProgress = [ IndexPath: Operation]()
    lazy var filtrationQueue: OperationQueue = {
        var queue  = OperationQueue()
        queue.name = "Image Filtration queue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
}
