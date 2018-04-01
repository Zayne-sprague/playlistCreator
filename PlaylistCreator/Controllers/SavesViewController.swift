//
//  SavesViewController.swift
//  PlaylistCreator
//
//  Created by zayne sprague on 3/31/18.
//  Copyright © 2018 ZRS. All rights reserved.
//

import UIKit

class SavesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, updateSaveTable {

    var tags: [String]?
    var index: Int?
    var videos: [String]?
    
    var saves: [[String: Any]]?
    
    var psTags: [String] = []
    var psName: String = ""
    var psDesc: String = ""

    @IBOutlet weak var savesTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.saves = UserDefaults.standard.object(forKey: "savedSearches") as? [[String : Any]]
        
        self.savesTable.delegate = self
        self.savesTable.dataSource = self
        
        savesTable.register(UINib(nibName:"PreviousSaveCell", bundle: nil), forCellReuseIdentifier: "PreviousSaveCell")


        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.saves != nil){
            return self.saves!.count
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PreviousSaveCell", for: indexPath) as! PreviousSaveCell
        
        cell.saveTitle.text = self.saves![indexPath.row]["name"] as! String
        
        //cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        return cell
    }
    
    func updateSaveTable() {
        self.saves = UserDefaults.standard.object(forKey: "savedSearches") as? [[String : Any]]
        
        self.savesTable.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButtonPress(_ sender: Any) {
        self.dismiss(animated: true, completion: {print("dismissed saves controller")})
    }
    
    @IBAction func newSaveButtonPress(_ sender: Any) {
        performSegue(withIdentifier: "goToNewSave", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var data = self.saves![indexPath.row]
        
        self.psName = data["name"] as! String
        self.psTags = data["tags"] as! [String]
        self.psDesc = data["description"] as! String
        
        performSegue(withIdentifier: "goToPreviousSave", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "goToNewSave") {
            let secondVC = segue.destination as! NewSaveViewController
            
            secondVC.tags = self.tags
            secondVC.index = self.index
            secondVC.videos = self.videos
            
            secondVC.saveDelegate = self
            
        } else if (segue.identifier == "goToPreviousSave") {
            let secondVC = segue.destination as! PreviousSaveViewController
            
            secondVC.tags = self.tags
            secondVC.index = self.index
            secondVC.videos = self.videos
            
            secondVC.previousSaveTitle = self.psName
            secondVC.previousSaveTags = self.psTags
            secondVC.previousSaveDescription = self.psDesc
            
            secondVC.saveDelegate = self
            
        }
    }
}
