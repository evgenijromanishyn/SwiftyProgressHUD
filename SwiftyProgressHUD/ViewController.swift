//
//  ViewController.swift
//  SwiftyProgressHUD
//
//  Created by Evgeniy Romanishin on 01.09.2018.
//  Copyright © 2018 Evgeniy Romanishin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func showHUD() {
        startTimer()
        
        view.showHUD = true
        
        guard let hud = view.progressHUD else {return}
        hud.textLabel.text = "Done"
        hud.detailTextLabel.text = "This is a demo version of the SwiftyProgressHUD."
    }
    
    @objc func loop() {
        guard let hud = view.progressHUD else {return}
        
        hud.progress = hud.progress + 0.1
        if hud.progress == 1.0 {
            self.stopTimer()
        }
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.loop), userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
        if let timer = timer {
            timer.invalidate()
        }
        
        timer = nil
        view.showHUD = false
    }
    
}

