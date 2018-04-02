//
//  PreviousSaveViewController.swift
//  PlaylistCreator
//
//  Created by zayne sprague on 3/31/18.
//  Copyright © 2018 ZRS. All rights reserved.
//

import UIKit

class PreviousSaveViewController: UIViewController, UITextViewDelegate {
    
    var tags: [String]?
    var index: Int?
    var videos: [String]?
    
    var previousSaveTitle: String?
    var previousSaveTags: [String]?
    var previousSaveDescription: String?
    
    var saves : [[String: Any]]?
    var savesIndex: Int?

    var saveDelegate : updateSaveTable?
    
    @IBOutlet weak var previousSaveTitleBox: UITextField!
    @IBOutlet weak var previousSaveDescriptionBox: UITextView!

    @IBOutlet weak var editTitleButton: UIButton!
    @IBOutlet weak var editDescriptionButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.previousSaveTitleBox.text = self.previousSaveTitle
        
        if self.previousSaveDescription != ""{
            self.previousSaveDescriptionBox.text = self.previousSaveDescription
        }
        
        self.previousSaveDescriptionBox.delegate = self
        
        //UI Design for text box
        self.previousSaveTitleBox.borderStyle = .none;
        self.previousSaveTitleBox.layer.cornerRadius = 10;
        self.previousSaveTitleBox.backgroundColor = UIColor.groupTableViewBackground;
        
        self.previousSaveTitleBox.setLeftPaddingPoints(10.0);
        self.previousSaveTitleBox.setRightPaddingPoints(10.0);
        
        self.previousSaveTitleBox.layer.shadowColor = UIColor.black.cgColor
        self.previousSaveTitleBox.layer.shadowOffset = CGSize(width: 0, height: 6);
        self.previousSaveTitleBox.layer.shadowRadius = 5.0;
        self.previousSaveTitleBox.layer.shadowOpacity = 0.3;
        self.previousSaveTitleBox.layer.shouldRasterize = true;
        
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

        var saveData = ["name": self.previousSaveTitleBox.text, "tags": self.tags, "description": self.previousSaveDescriptionBox.text] as [String : Any]
        
        self.saves![self.savesIndex!] = saveData
        defaults.set(self.saves!, forKey: "savedSearches")
        
        self.dismiss(animated: true, completion: {
            self.saveDelegate?.updateSaveTable()
            print("dismissed previous save controller")
            
        })
    }
    
    @IBAction func deleteButtonPress(_ sender: Any) {
        
        
        self.saves?.remove(at: self.savesIndex!)
        UserDefaults.standard.set(self.saves, forKey: "savedSearches")
        
        self.dismiss(animated: true, completion: {
            self.saveDelegate?.updateSaveTable()
            print("dismissed previous save controller")
            
        })
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        return newText.count <= 200
    }
    
    
    @IBAction func titleBoxEditButtonPress(_ sender: Any) {
        
        if(self.editTitleButton.titleLabel?.text == "edit"){
            self.editTitleButton.setTitle("done", for: .normal)
            self.previousSaveTitleBox.isEnabled = true
        }else{
            self.editTitleButton.setTitle("edit", for: .normal)
            self.previousSaveTitleBox.isEnabled = false
        }
        
    }

    @IBAction func descriptionBoxEditButtonPress(_ sender: Any) {
        if(self.editDescriptionButton.titleLabel?.text == "edit"){
            self.editDescriptionButton.setTitle("done", for: .normal)
            self.previousSaveDescriptionBox.isEditable = true
        }else{
            self.editDescriptionButton.setTitle("edit", for: .normal)
            self.previousSaveDescriptionBox.isEditable = false
        }
        
    }
}
