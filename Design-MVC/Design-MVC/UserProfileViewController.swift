//
//  UserProfileViewController.swift
//  Design-MVC
//
//  Created by Mesrop Kareyan on 4/14/17.
//  Copyright © 2017 Mesrop Kareyan. All rights reserved.
//

import UIKit

class UserProfileViewController: UITableViewController{

    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var nameFiled: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    var mediator: TextFieldsMediator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mediator = TextFieldsMediator(fields: [ nameFiled, emailField, passwordField], observer: self)
        mediator.startListnening()
    }
    
    @IBAction func saveBUttonTapped(_ sender: UIButton) {
        saveUserToCoreData()
    }
    
    func saveUserToCoreData() {
        let userData = UserData(name: nameFiled.text!, email: emailField.text!, password: passwordField.text!)
        do {
            let user = try CoreDataManager.saveUser(userData)
            let alert = UIAlertController(title: "Success", message: "Saved with id \(String(describing: user.id))", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        } catch {
            let alert = UIAlertController(title: "Error", message: "Can't save user data", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                present(alert, animated: true, completion: nil)
        }
    }
    
}

extension UserProfileViewController : TextFiledsSubscriber {
    func allTextIs(filled: Bool) {
        self.saveButton.isEnabled = filled;
    }
}
