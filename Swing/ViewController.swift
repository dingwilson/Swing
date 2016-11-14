//
//  ViewController.swift
//  Swing
//
//  Created by Wilson Ding on 11/13/16.
//  Copyright © 2016 Wilson Ding. All rights reserved.
//

import UIKit
import Firebase
import CoreMotion
import AVFoundation
import Alamofire

class ViewController: UIViewController {
    
    var ref: FIRDatabaseReference!
    
    @IBOutlet weak var gyroButton: UIButton!
    
    @IBOutlet weak var xValue: UILabel!
    @IBOutlet weak var yValue: UILabel!
    @IBOutlet weak var zValue: UILabel!
    @IBOutlet weak var topSpeed: UILabel!
    
    let defaultDuration = 3.0
    let defaultDamping = 0.25
    let defaultVelocity = 2.5
    
    var xCalib : Double!
    var yCalib : Double!
    var zCalib : Double!
    
    var xVal : Double!
    var yVal : Double!
    var zVal : Double!
    
    var prevSpeed : Double!
    var speed : Double!
    var speedMultiplier = 100.0
    
    var manager: CMMotionManager = CMMotionManager()
    var attitude: CMAttitude = CMAttitude()
    var motion: CMDeviceMotion = CMDeviceMotion()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        animateButton()
        
        self.ref = FIRDatabase.database().reference()
        
        NotificationCenter.default.addObserver(self, selector: #selector(volumeChanged), name: NSNotification.Name(rawValue: "AVSystemController_SystemVolumeDidChangeNotification"), object: nil)
        
        self.xCalib = 0.0
        self.yCalib = 0.0
        self.zCalib = 0.0
        
        self.prevSpeed = 0
        self.speed = 0
        
        manager.deviceMotionUpdateInterval = 0.05
        manager.startDeviceMotionUpdates(to: OperationQueue.main, withHandler:{
            deviceManager, error in
            
            self.motion = self.manager.deviceMotion!
            self.attitude = self.motion.attitude
            
            self.xVal = self.attitude.yaw * self.speedMultiplier
            self.yVal = self.attitude.roll * self.speedMultiplier
            self.zVal = self.attitude.pitch * self.speedMultiplier
            
            if Int(self.yVal-self.prevSpeed) > Int(self.speed) {
                if Int(self.yVal-self.prevSpeed) > 0 {
                    self.speed = self.yVal-self.prevSpeed
                    self.ref.child("values").setValue(["topSpeed" : String(format: "%.6f", self.speed)])
                }
            }
            
            self.prevSpeed = self.yVal
            
            self.topSpeed.text = String(Int(self.speed))
            
            self.ref.child("values").child("gyro").setValue(["yaw" : String(format: "%.6f", self.xVal - self.xCalib),
                                                             "roll" : String(format: "%.6f", self.yVal - self.yCalib),
                                                             "pitch" : String(format: "%.6f", self.zVal - self.zCalib)])
            
            self.self.xValue.text = "Yaw: " + String(format: "%.3f", self.xVal - self.xCalib)
            self.yValue.text = "Roll: " + String(format: "%.3f", self.yVal - self.yCalib)
            self.zValue.text = "Pitch: " + String(format: "%.3f", self.zVal - self.zCalib)
        })
    }

    @IBAction func gyroCalibration(_ sender: AnyObject) {
        resetValues()
    }
    
    func animateButton() {
        self.gyroButton.imageView?.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        
        UIView.animate(withDuration: defaultDuration,
                       delay: 0,
                       usingSpringWithDamping: CGFloat(defaultDamping),
                       initialSpringVelocity: CGFloat(defaultVelocity),
                       options: UIViewAnimationOptions.allowUserInteraction,
                       animations: { self.gyroButton.imageView?.transform = CGAffineTransform.identity
        },
                       completion: { finished in
                        self.animateButton()
        }
        )
    }
    
    func resetValues() {
        self.xCalib = self.xVal
        self.yCalib = self.yVal
        self.zCalib = self.zVal
        
        let url = URL(string: "http://flask-env.czkykzdpwg.us-west-2.elasticbeanstalk.com/\(Int(self.speed))")
        print(url)
        
        Alamofire.request(url!, method: .get)
        
        self.prevSpeed = 0
        self.speed = 0
        self.speed = 0
        
        self.ref.child("values").setValue(["topSpeed" : String(format: "%.6f", 0.0)])
    }
    
    func volumeChanged(notification: Notification) {
        resetValues()
    }
}

