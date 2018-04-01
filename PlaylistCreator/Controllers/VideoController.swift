//
//  VideoController.swift
//  PlaylistCreator
//
//  Created by zayne sprague on 3/11/18.
//  Copyright © 2018 ZRS. All rights reserved.
//

import UIKit
import youtube_ios_player_helper

class VideoController: UIViewController, YTPlayerViewDelegate {
    
    var videos : [String]?
    var index: Int?
    var tags: [String]?
    
    var clearDelegate : clearCurrentSearch?
    
    @IBOutlet weak var nextVideoButton: UIButton!
    @IBOutlet weak var lastVideoButton: UIButton!
    
    @IBOutlet weak var titleTagLabel: UILabel!
    @IBOutlet weak var playerView: YTPlayerView!

    override func viewDidLoad() {
        super.viewDidLoad()
        playerView.delegate = self
        
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
        self.playerView.pauseVideo()
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
    

    

}
