//
//  LoadPreviousViewController.swift
//  PlaylistCreator
//
//  Created by zayne sprague on 3/31/18.
//  Copyright © 2018 ZRS. All rights reserved.
//

import UIKit

class LoadPreviousViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var saves: [[String: Any]]?
    
    var delegate : createCurrentSearch?
    var checkSavesDelegate : checkSaves?
    
    var psTags: [String] = []
    var psIndex: Int?

    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var savesTable: UITableView!
    @IBOutlet weak var loadSaveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.saves = UserDefaults.standard.object(forKey: "savedSearches") as? [[String : Any]]
        
        self.savesTable.delegate = self
        self.savesTable.dataSource = self
        
        savesTable.register(UINib(nibName:"PreviousSaveCell", bundle: nil), forCellReuseIdentifier: "PreviousSaveCell")

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButtonPress(_ sender: Any) {
        self.dismiss(animated: true, completion: {
            print("Dissmissed load screen")
            self.checkSavesDelegate?.checkSaves()
        })
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
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var data = self.saves![indexPath.row]
        
        self.psTags = data["tags"] as! [String]
        self.psIndex = indexPath.row
        
        if (!self.loadSaveButton.isEnabled){
            self.loadSaveButton.isEnabled = true
            self.loadSaveButton.backgroundColor = UIColor(hex: 0x6D72C3)
        }
        if (!self.deleteButton.isEnabled){
            self.deleteButton.isEnabled = true
            self.deleteButton.setTitleColor(UIColor(hex: 0xFF0000), for: .normal)
        }
    }
    
    @IBAction func deleteButtonPress(_ sender: Any) {
        
        self.saves?.remove(at: self.psIndex!)
        UserDefaults.standard.set(self.saves, forKey: "savedSearches")
        
        self.savesTable.reloadData()
        
        self.deleteButton.isEnabled = false
        self.deleteButton.setTitleColor(UIColor(hex: 0xFFFFFF), for: .normal)
        
        self.loadSaveButton.isEnabled = false
        self.loadSaveButton.backgroundColor = UIColor.lightGray
        
    }
    
    @IBAction func loadSaveButtonPress(_ sender: Any) {
        self.delegate?.createCurrentSearch(tags: self.psTags)
        self.dismiss(animated: true, completion: {
            print("Dissmissed load screen")
            self.checkSavesDelegate?.checkSaves()
        })
        
    }
}
