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
    var psTags: [String] = []

    @IBOutlet weak var savesTable: UITableView!
    
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
        self.dismiss(animated: true, completion: {print("Dissmissed load screen")})
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var data = self.saves![indexPath.row]
        
        self.psTags = data["tags"] as! [String]
        
    }

    @IBAction func loadSaveButtonPress(_ sender: Any) {
        self.delegate?.createCurrentSearch(tags: self.psTags)
        self.dismiss(animated: true, completion: {print("Dissmissed load screen")})
        
    }
}
