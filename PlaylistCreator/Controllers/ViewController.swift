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

protocol clearCurrentSearch {
    func clearCurrentSearch()
}

protocol createCurrentSearch{
    func createCurrentSearch(tags: [String])
}

protocol checkSaves{
    func checkSaves()
}

class ViewController: UIViewController, UITextFieldDelegate, UIScrollViewDelegate, clearCurrentSearch, createCurrentSearch, checkSaves{

    @IBOutlet weak var tagTextBox: UITextField!
    
    @IBOutlet weak var tagSearchButton: UIButton!
    @IBOutlet private weak var tagsView: TagsView!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var loadSearchButton: UIButton!
    
    var videoIds : [String]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.checkSaves()
        
        //Scroll view styles
        scrollView.contentSize = CGSize(width: 1, height: tagsView.frame.height + 300)
        scrollView.delegate = self
        
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
        self.tagsView.lastTag = "last tag afjkhawejghawekljhf"
        self.tagsView.lastTagLayerColor = .white
        self.tagsView.lastTagTitleColor = .white


        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func clearCurrentSearch() {
        self.tagsView.removeAll()
        self.tagTextBox.placeholder = "Enter What You Want To Find!"
        self.tagSearchButton.isEnabled = false
        self.tagSearchButton.backgroundColor = UIColor.lightGray;
    }
    
    func createCurrentSearch(tags: [String]) {
        if (tags.count > 0){

            self.tagsView.removeAll()

            for tag in tags{
                self.tagsView.append(tag)
            }
            if (tags.count < 20){
                self.tagTextBox.placeholder = "Load extra tags!"
            }else{
                self.tagTextBox.placeholder = "Whoa, too many. Delete Some Tags"
            }
            
            self.tagSearchButton.isEnabled = true
            self.tagSearchButton.backgroundColor = UIColor(hex: 0x6D72C3)
        }
    }
    
    func checkSaves(){
        //Checks & Load button styles
        var saves = UserDefaults.standard.object(forKey: "savedSearches") as? [[String: Any]]
        if saves != nil && saves!.count > 0{
            self.loadSearchButton.isEnabled = true
            self.loadSearchButton.isHidden = false
        }else{
            self.loadSearchButton.isEnabled = false
            self.loadSearchButton.isHidden = true
        }
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier=="goToVideos"{
            let secondVC = segue.destination as! VideoController
           
            secondVC.videos = self.videoIds!
            secondVC.index = 0
            secondVC.tags = self.tagsView.tagTextArray
            
            secondVC.clearDelegate = self
            secondVC.checkSavesDelegate = self
        }else if segue.identifier=="goToLoading"{
            let secondVC = segue.destination as! LoadPreviousViewController
            
            secondVC.delegate = self
            secondVC.checkSavesDelegate = self
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
        self.tagsView.lastTag = "last tag afjkhawejghawekljhf"
        self.tagsView.lastTagLayerColor = .white
        self.tagsView.lastTagTitleColor = .white

        
        self.tagSearchButton.isEnabled = true;
        self.tagSearchButton.backgroundColor = UIColor(hex: 0x6D72C3)
        
        if(self.tagsView.tagArray.count < 20){
            self.tagTextBox.placeholder = "Add another?"
        }else{
            self.tagTextBox.placeholder = "Whoa, too many. Delete Some Tags"
            self.tagTextBox.isEnabled = false
        }
        
        self.tagTextBox.text = "";
        
        
    }
    
    @IBAction func searchButtonPress(_ sender: Any) {
        self.tagSearchButton.isEnabled = false;
        self.tagSearchButton.backgroundColor = UIColor.lightGray;
        
        self.loader.startAnimating();
        /*var local_url = "http://localhost:8090/youtube_data"
        var temp_url = "https://tempory_url.ngrok.io/youtube_data"
        Alamofire.request(temp_url, method: .post, parameters: ["topics": self.tagsView.tagTextArray, "filters":["likes": "most"]], encoding: JSONEncoding.default)
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
                
        }*/
        var ids = find_videos_for_tags(tags: self.tagsView.tagTextArray, filters: ["likes": "most"], handler: {
            ids in
            self.videoIds = ids
            self.performSegue(withIdentifier: "goToVideos", sender: nil)
            //self.tagsView.removeAll()
            self.loader.stopAnimating();
        })
        



    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x > 0 {
            scrollView.contentOffset.x = 0
        }
    }
    @IBAction func loadSaveButtonPress(_ sender: Any) {
        performSegue(withIdentifier: "goToLoading", sender: nil)
    }
}

extension ViewController: TagsDelegate{
    
    // Tag Touch Action
    func tagsTouchAction(_ tagsView: TagsView, tagButton: TagButton) {
        tagsView.remove(tagButton)
        self.tagsView.lastTag = "last tag afjkhawejghawekljhf"
        self.tagsView.lastTagLayerColor = .white
        self.tagsView.lastTagTitleColor = .white

        
        if tagsView.tagArray.count <= 0{
            self.tagSearchButton.isEnabled = false;
            self.tagSearchButton.backgroundColor = UIColor.lightGray;
            self.tagTextBox.placeholder = "Enter What You Want To Find!"
        }
        
        if tagsView.tagArray.count < 20 && !self.tagTextBox.isEnabled{
            self.tagTextBox.isEnabled = true
            self.tagTextBox.placeholder = "Add another?"
            
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

private var __maxLengths = [UITextField: Int]()
extension UITextField {
    @IBInspectable var maxLength: Int {
        get {
            guard let l = __maxLengths[self] else {
                return 150 // (global default-limit. or just, Int.max)
            }
            return l
        }
        set {
            __maxLengths[self] = newValue
            addTarget(self, action: #selector(fix), for: .editingChanged)
            
        }
    }
    @objc func fix(textField: UITextField) {
        let t = textField.text
        textField.text = t?.safelyLimitedTo(length: maxLength)
    }
}

extension String
{
    func safelyLimitedTo(length n: Int)->String {
        if (self.count <= n) {
            return self
        }
        return String( Array(self).prefix(upTo: n) )
    }
}

@IBDesignable extension UIButton {
    
    @IBInspectable var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        set {
            guard let uiColor = newValue else { return }
            layer.borderColor = uiColor.cgColor
        }
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
    }
}

