//
//  AdvertisementViewController.swift
//  PlaylistCreator
//
//  Created by zayne sprague on 3/30/18.
//  Copyright © 2018 ZRS. All rights reserved.
//

import GoogleMobileAds
import UIKit

class AdvertisementViewController: UIViewController, GADInterstitialDelegate {
    
    var interstitial: GADInterstitial!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // interstitial = GADInterstitial(adUnitID: "ca-app-pub-6594357715615120/7360334408")
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-3940256099942544/4411468910")
        
        let request = GADRequest()
        interstitial.load(request)
        interstitial.delegate = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        interstitial.present(fromRootViewController: self)
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        self.dismiss(animated: true, completion: {print("dismissed advertisements controller")})
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
