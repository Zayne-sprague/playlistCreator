//
//  NewSaveViewController.swift
//  PlaylistCreator
//
//  Created by zayne sprague on 3/31/18.
//  Copyright © 2018 ZRS. All rights reserved.
//

import UIKit

protocol updateSaveTable {
    func updateSaveTable()
}

class NewSaveViewController: UIViewController {
    
    var tags : [String]?
    var index: Int?
    var videos: [String]?
    
    var saveDelegate : updateSaveTable?

    @IBOutlet weak var searchNameTextBox: UITextField!
    @IBOutlet weak var searchDescriptionBox: UITextView!
    @IBOutlet weak var createButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //UI Design for text box
        self.searchNameTextBox.borderStyle = .none;
        self.searchNameTextBox.layer.cornerRadius = 10;
        self.searchNameTextBox.backgroundColor = UIColor.groupTableViewBackground;
        
        self.searchNameTextBox.setLeftPaddingPoints(10.0);
        self.searchNameTextBox.setRightPaddingPoints(10.0);
        
        self.searchNameTextBox.layer.shadowColor = UIColor.black.cgColor
        self.searchNameTextBox.layer.shadowOffset = CGSize(width: 0, height: 6);
        self.searchNameTextBox.layer.shadowRadius = 5.0;
        self.searchNameTextBox.layer.shadowOpacity = 0.3;
        self.searchNameTextBox.layer.shouldRasterize = true;

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func createButtonPress(_ sender: Any) {
        let defaults = UserDefaults.standard
        var description = self.searchDescriptionBox.text
        if (description == "How about a short description for your search?"){
            description = ""
        }
        
        var saveData = ["name": self.searchNameTextBox.text, "tags": self.tags, "description": description] as [String : Any]
        
        var saves = defaults.object(forKey: "savedSearches") as? [[String : Any]]
        if (saves == nil){
            saves = [] as! [[String: Any]]
        }
        
        saves?.append(saveData)
        
        defaults.set(saves, forKey: "savedSearches")
        
        self._dismiss()


    }
    
    @IBAction func searchNameEntered(_ sender: Any) {
        if(self.searchNameTextBox.text != "" && !self.createButton.isEnabled){
            self.createButton.isEnabled = true
            self.createButton.backgroundColor = UIColor(hex: 0x6D72C3)
        }
    }
    
    func _dismiss(){
        self.saveDelegate?.updateSaveTable()
        self.dismiss(animated: true, completion: {print("dismissed new save controller")})

    }
    @IBAction func backButtonPress(_ sender: Any) {
        self._dismiss()

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "goToVideos") {
            let secondVC = segue.destination as! VideoController
            
            secondVC.tags = self.tags
            secondVC.index = self.index
            secondVC.videos = self.videos
            
        }
    }
}
