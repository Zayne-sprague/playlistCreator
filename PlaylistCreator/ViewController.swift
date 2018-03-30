//
//  ViewController.swift
//  PlaylistCreator
//
//  Created by zayne sprague on 3/11/18.
//  Copyright © 2018 ZRS. All rights reserved.
//

import UIKit
import Tags
import Alamofire

class ViewController: UIViewController, UITextFieldDelegate{

    @IBOutlet weak var tagTextBox: UITextField!
    
    @IBOutlet weak var tagSearchButton: UIButton!
    @IBOutlet private weak var tagsView: TagsView!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    
    var videoIds : [String]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //UI Design for text box
        self.tagTextBox.borderStyle = .none;
        self.tagTextBox.layer.cornerRadius = 10;
        self.tagTextBox.backgroundColor = UIColor.groupTableViewBackground;
        
        self.tagTextBox.setLeftPaddingPoints(10.0);
        self.tagTextBox.setRightPaddingPoints(10.0);
        
        self.tagTextBox.layer.shadowColor = UIColor.black.cgColor
        self.tagTextBox.layer.shadowOffset = CGSize(width: 0, height: 6);
        self.tagTextBox.layer.shadowRadius = 5.0;
        self.tagTextBox.layer.shadowOpacity = 0.3;
        self.tagTextBox.layer.shouldRasterize = true;
        

        //----------------------
        self.loader.transform = CGAffineTransform(scaleX: 2, y: 2)

        
        self.title = "Tags"
        
        self.tagsView.delegate = self
        
        self.tagTextBox.delegate = self
        self.tagsView.lastTag = ""
        self.tagsView.lastTagLayerColor = .white


        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier=="goToVideos"{
            let secondVC = segue.destination as! VideoController
           
            secondVC.videos = self.videoIds!
        }
    }
    
    /*func drawTags(){
        for tag in self.customTags{
        }
    }*/

    @IBAction func tagsTextBoxEntered(_ sender: Any) {
        tagTextBox.resignFirstResponder()  //if desired
        
        self.tagsView.append(self.tagTextBox.text!)
        print(self.tagsView?.tagTextArray)
        self.tagsView.lastTag = ""
        self.tagsView.lastTagLayerColor = .white
        
        self.tagSearchButton.isEnabled = true;
        self.tagSearchButton.backgroundColor = UIColor(hex: 0x6D72C3)
        
        self.tagTextBox.text = "";
        
        
    }
    
    @IBAction func searchButtonPress(_ sender: Any) {
        self.tagSearchButton.isEnabled = false;
        self.tagSearchButton.backgroundColor = UIColor.lightGray;
        
        self.loader.startAnimating();
        
        Alamofire.request("http://localhost:8090/youtube_data", method: .post, parameters: ["topics": self.tagsView.tagTextArray, "filters":["likes": "most"]], encoding: JSONEncoding.default)
            .responseJSON { response in
                
                self.tagSearchButton.isEnabled = true;
                self.tagSearchButton.backgroundColor = UIColor(hex: 0x6D72C3)
                self.loader.stopAnimating();


                guard let json = response.result.value as? [String: Any] else {
                        print("didn't get todo object as JSON from API")
                        print("Error: \(response.result.error)")
                        return
                    }
                
                if let vidIds = json["result"] as? [String] {
                    self.videoIds = vidIds
                    self.performSegue(withIdentifier: "goToVideos", sender: nil)
                }else{
                    self.tagsView.removeAll()
                }
                
        }
    }
}

extension ViewController: TagsDelegate{
    
    // Tag Touch Action
    func tagsTouchAction(_ tagsView: TagsView, tagButton: TagButton) {
        tagsView.remove(tagButton)
        self.tagsView.lastTag = ""
        self.tagsView.lastTagLayerColor = .white
        
        if tagsView.tagArray.count <= 0{
            self.tagSearchButton.isEnabled = false;
            self.tagSearchButton.backgroundColor = UIColor.lightGray;
        }


    }
    
    // Last Tag Touch Action
    func tagsLastTagAction(_ tagsView: TagsView, tagButton: TagButton) {
        
    }
    
    // TagsView Change Height
    func tagsChangeHeight(_ tagsView: TagsView, height: CGFloat) {
        
    }
}

extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}

extension UIColor {
    
    convenience init(hex: Int) {
        let components = (
            R: CGFloat((hex >> 16) & 0xff) / 255,
            G: CGFloat((hex >> 08) & 0xff) / 255,
            B: CGFloat((hex >> 00) & 0xff) / 255
        )
        self.init(red: components.R, green: components.G, blue: components.B, alpha: 1)
    }
    
}
