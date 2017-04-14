//
//  TextFiledsMediator.swift
//  Design-MVC
//
//  Created by Mesrop Kareyan on 4/14/17.
//  Copyright © 2017 Mesrop Kareyan. All rights reserved.
//

//swift 3.0
import UIKit

protocol TextFiledsSubscriber: class {
    func allTextIs(filled: Bool)
}

class TextFieldsMediator {
    
    init() {}
    init(fields: [UITextField], observer: TextFiledsSubscriber) {
        self.subscriber = observer
        self.textFieldsToObserve = Set(fields)
    }
    
    func startListnening() {
        textFieldsToObserve.forEach{ $0.addTarget(self, action: #selector(self.checkForFill), for: .editingChanged)
        }
    }
    
    private var textFieldsToObserve: Set<UITextField> = []
    private weak var subscriber: TextFiledsSubscriber?
    
    func addFieldFor(observe field: UITextField) {
        field.addTarget(self, action: #selector(self.checkForFill), for: .editingChanged)
        textFieldsToObserve.insert(field)
    }
    
    private(set) var isFilled: Bool = false {
        didSet{
            subscriber?.allTextIs(filled: isFilled)
        }
    }
    
    @objc  func checkForFill()  {
        for textField in textFieldsToObserve {
            if textField.text!.isEmpty {
                isFilled = false
                return
            }
        }
        isFilled = true
    }
    
    func dispose() {
        subscriber = nil
        textFieldsToObserve.removeAll()
    }
    
    deinit {
        dispose()
    }
}
