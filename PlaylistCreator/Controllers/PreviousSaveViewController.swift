//
//  PreviousSaveViewController.swift
//  PlaylistCreator
//
//  Created by zayne sprague on 3/31/18.
//  Copyright © 2018 ZRS. All rights reserved.
//

import UIKit

class PreviousSaveViewController: UIViewController {
    
    var tags: [String]?
    var index: Int?
    var videos: [String]?
    
    var previousSaveTitle: String?
    var previousSaveTags: [String]?
    var previousSaveDescription: String?

    var saveDelegate : updateSaveTable?
    
    @IBOutlet weak var previousSaveTitleLabel: UILabel!
    @IBOutlet weak var previousSaveDescriptionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.previousSaveTitleLabel.text = self.previousSaveTitle
        self.previousSaveDescriptionLabel.text = self.previousSaveDescription
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButtonPress(_ sender: Any) {
        self.dismiss(animated: true, completion: {print("dismissed previous save controller")})
    }
    
    @IBAction func overwriteButtonPress(_ sender: Any) {
        let defaults = UserDefaults.standard

        var saveData = ["name": self.previousSaveTitle, "tags": self.tags, "description": self.previousSaveDescription] as [String : Any]
        defaults.set(saveData, forKey: self.previousSaveTitle!)
        
        self.dismiss(animated: true, completion: {
            self.saveDelegate?.updateSaveTable()
            print("dismissed previous save controller")
            
        })
    }
    
    

}
