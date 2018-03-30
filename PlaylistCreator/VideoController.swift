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
    var index: Int = 0
    
    @IBOutlet weak var nextVideoButton: UIButton!
    @IBOutlet weak var lastVideoButton: UIButton!
    
    @IBOutlet weak var playerView: YTPlayerView!

    override func viewDidLoad() {
        super.viewDidLoad()
        playerView.delegate = self
        
        let playerVars = ["playsinline": 1, "autoplay": 1] // 0: will play video in fullscreen
        self.playerView.load(withVideoId: (self.videos?[index])!, playerVars: playerVars)

        self.playerView.playVideo()
        
        if(self.videos!.count > 1){
            self.nextVideoButton.backgroundColor = UIColor(hex: 0x6D72C3)
            self.nextVideoButton.isEnabled = true;
        }
        
        // Do any additional setup after loading the view.
    }
    
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        self.playerView.playVideo()
    }
    func playerView(_ playerView: YTPlayerView, didChangeTo state: YTPlayerState) {
        if(state == YTPlayerState.ended){
            self.index += 1
            if self.index < (self.videos!.count) {
                playerView.load(withVideoId: (self.videos?[index])!, playerVars: ["playsinline": 1, "autoplay": 1]);
            }

        }else if(state == YTPlayerState.unstarted){
        }
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func nextVideo(_ sender: Any) {
        self.index += 1
        playerView.load(withVideoId: (self.videos?[index])!, playerVars: ["playsinline": 1, "autoplay": 1]);
        
        if self.index >= (self.videos!.count - 1){
            self.nextVideoButton.isEnabled = false;
            self.nextVideoButton.backgroundColor = UIColor.lightGray;
        }
        
        if self.index > 0 && !self.lastVideoButton.isEnabled{
            self.lastVideoButton.isEnabled = true;
            self.lastVideoButton.backgroundColor = UIColor(hex: 0x6D72C3)
        }
    }
    
    @IBAction func lastVideo(_ sender: Any) {
        
        self.index -= 1
        playerView.load(withVideoId: (self.videos?[index])!, playerVars: ["playsinline": 1, "autoplay": 1]);
        
        if self.index <= 0{
            self.lastVideoButton.isEnabled = false;
            self.lastVideoButton.backgroundColor = UIColor.lightGray;
        }
        
        if self.index < self.videos!.count{
            self.nextVideoButton.isEnabled = true;
            self.nextVideoButton.backgroundColor = UIColor(hex: 0x6D72C3)
        }
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
