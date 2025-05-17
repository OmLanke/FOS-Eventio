//
//  ProfileViewController.swift
//  Eventio
//
//  Created by Om Lanke on 18/05/25.
//

import UIKit

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var emailLabel: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        if let userName = UserDefaults.standard.string(forKey: "userName") {
            nameLabel.text = userName
        }
        
        if let userEmail = UserDefaults.standard.string(forKey: "userEmail") {
            emailLabel.text = userEmail
        }
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
