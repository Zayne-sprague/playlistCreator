//
//  VideoController.swift
//  PlaylistCreator
//
//  Created by zayne sprague on 3/11/18.
//  Copyright © 2018 ZRS. All rights reserved.
//

import UIKit
import youtube_ios_player_helper
import Alamofire

class VideoController: UIViewController, YTPlayerViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource{

    
    var videos : [String]?
    var index: Int?
    var tags: [String]?
    var thumbnailUrls: [[String: Any]] = []
    
    var clearDelegate : clearCurrentSearch?
    var checkSavesDelegate: checkSaves?
    
    @IBOutlet weak var nextVideoButton: UIButton!
    @IBOutlet weak var lastVideoButton: UIButton!
    
    @IBOutlet weak var titleTagLabel: UILabel!
    @IBOutlet weak var playerView: YTPlayerView!

    @IBOutlet weak var showSimilarVideosButton: UIButton!
    @IBOutlet weak var similarVideosLoader: UIActivityIndicatorView!
    @IBOutlet weak var similar_video_collection: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        playerView.delegate = self
        self.similar_video_collection.delegate = self
        self.similar_video_collection.dataSource = self
        
        self.similarVideosLoader.transform = CGAffineTransform(scaleX: 1, y: 1)
        self.similarVideosLoader.isHidden = true
        
        let playerVars = ["playsinline": 1, "autoplay": 1] // 0: will play video in fullscreen
        self.playerView.load(withVideoId: (self.videos?[self.index!])!, playerVars: playerVars)

        self.playerView.playVideo()
        
        if(self.videos!.count - 1 > self.index!){
            self.nextVideoButton.backgroundColor = UIColor(hex: 0x6D72C3)
            self.nextVideoButton.isEnabled = true;
        }
        
        if(self.index! > 0){
            self.lastVideoButton.backgroundColor = UIColor(hex: 0x6D72C3)
            self.lastVideoButton.isEnabled = true;
        }
        
        titleTagLabel.text = tags![index!]
        
        // Do any additional setup after loading the view.
    }
    
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        self.playerView.playVideo()
    }
    
    func playerView(_ playerView: YTPlayerView, didChangeTo state: YTPlayerState) {
        if(state == YTPlayerState.ended){
            self.index! += 1
            titleTagLabel.text = tags![index!]
            self.goToAdvertisements()
            if self.index! < (self.videos!.count) {
                playerView.load(withVideoId: (self.videos?[self.index!])!, playerVars: ["playsinline": 1, "autoplay": 1]);
            }

        }else if(state == YTPlayerState.unstarted){
        }
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func backButtonPress(_ sender: Any) {
        self.clearDelegate?.clearCurrentSearch()
        self.checkSavesDelegate?.checkSaves()
        self.dismiss(animated: true, completion: {print("dismissed video controller")})
    }
    
    @IBAction func nextVideo(_ sender: Any) {
        self.index! += 1
        self.goToAdvertisements()
        titleTagLabel.text = tags![index!]

        playerView.load(withVideoId: (self.videos?[self.index!])!, playerVars: ["playsinline": 1, "autoplay": 1]);
        
        if self.index! >= (self.videos!.count - 1){
            self.nextVideoButton.isEnabled = false;
            self.nextVideoButton.backgroundColor = UIColor.lightGray;
        }
        
        if self.index! > 0 && !self.lastVideoButton.isEnabled{
            self.lastVideoButton.isEnabled = true;
            self.lastVideoButton.backgroundColor = UIColor(hex: 0x6D72C3)
        }
    }
    
    @IBAction func lastVideo(_ sender: Any) {
        
        self.index! -= 1
        titleTagLabel.text = tags![index!]
        playerView.load(withVideoId: (self.videos?[self.index!])!, playerVars: ["playsinline": 1, "autoplay": 1]);
        
        if self.index! <= 0{
            self.lastVideoButton.isEnabled = false;
            self.lastVideoButton.backgroundColor = UIColor.lightGray;
        }
        
        if self.index! < self.videos!.count{
            self.nextVideoButton.isEnabled = true;
            self.nextVideoButton.backgroundColor = UIColor(hex: 0x6D72C3)
        }
        
    }
    
    func goToAdvertisements(){
        if(self.index! != 0 && self.index! % 3 == 0){
            performSegue(withIdentifier: "goToAdvertisement", sender: nil)
        }
    }
    
    @IBAction func saveSearchButtonPress(_ sender: Any) {
        performSegue(withIdentifier: "goToSave", sender: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "goToSave"){
            let secondVC = segue.destination as! SavesViewController
            
            secondVC.videos = self.videos
            secondVC.index = self.index
            secondVC.tags = self.tags
            
        }
    }
    
    @IBAction func showSimilarVideosButtonPress(_ sender: Any) {
        self.showSimilarVideosButton.isEnabled = false
        self.showSimilarVideosButton.isHidden = true
        
        self.similarVideosLoader.isHidden = false
        self.similarVideosLoader.startAnimating()
        
        /* var local_url = "http://localhost:8090/youtube_showmore"
        var temp_url = "https://tempory_url.ngrok.io/youtube_showmore"
        Alamofire.request(temp_url, method: .post, parameters: ["topics": self.tags![self.index!], "filters":["likes": "most"]], encoding: JSONEncoding.default)
            .responseJSON { response in
                
                self.similarVideosLoader.stopAnimating()
                self.similarVideosLoader.isHidden = true
                
                
                guard let json = response.result.value as? [String: Any] else {
                    print("didn't get todo object as JSON from API")
                    print("Error: \(response.result.error)")
                    return
                }
                
                if let vidIds = json["result"] as? [String] {
                    print(vidIds)
                }
                
        }*/
        
        find_similar_videos_to_tag(tag: self.tags![self.index!], filters: ["likes": "most"]) { (ids) in
            
            self.similar_video_collection.isHidden = false
        
            self.thumbnailUrls = []
            for id in ids{
                var url : URL = URL(string: "https://img.youtube.com/vi/\(id)/default.jpg")!
                DispatchQueue.global(qos: .userInitiated).async {
                    
                    let imageData:NSData = NSData(contentsOf: url)!
                    
                    DispatchQueue.main.async {
                        let image = UIImage(data: imageData as Data)
                        self.thumbnailUrls.append(["id": id, "image": image!])
                        
                        self.similar_video_collection.reloadData()
                        
                        
                    }
                }
                
            }
            
            self.similarVideosLoader.isHidden = true
            self.similarVideosLoader.stopAnimating()
            
        }
        
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.thumbnailUrls.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SimilarThumbnailCell", for: indexPath) as! ThumbNailImageCell
        
        var cell_data = self.thumbnailUrls[indexPath.row]
        cell.thumbnailImage.image = cell_data["image"] as! UIImage
        cell.tag_id = cell_data["id"] as! String
        
        return cell
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var cell = collectionView.cellForItem(at: indexPath) as! ThumbNailImageCell
        playerView.load(withVideoId: cell.tag_id!, playerVars: ["playsinline": 1, "autoplay": 1]);
    }
    

    

}
