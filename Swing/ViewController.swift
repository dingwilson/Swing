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

class ViewController: UIViewController {
    
    var ref: FIRDatabaseReference!
    
    @IBOutlet weak var gyroButton: UIButton!
    
    @IBOutlet weak var xValue: UILabel!
    @IBOutlet weak var yValue: UILabel!
    @IBOutlet weak var zValue: UILabel!
    
    let defaultDuration = 3.0
    let defaultDamping = 0.25
    let defaultVelocity = 2.5
    
    var xCalib : Double!
    var yCalib : Double!
    var zCalib : Double!
    
    var manager: CMMotionManager = CMMotionManager()
    var attitude: CMAttitude = CMAttitude()
    var motion: CMDeviceMotion = CMDeviceMotion()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.ref = FIRDatabase.database().reference()
        
        self.xCalib = 0.0
        self.yCalib = 0.0
        self.zCalib = 0.0
        
        manager.deviceMotionUpdateInterval = 0.01
        manager.startDeviceMotionUpdates(to: OperationQueue.main, withHandler:{
            deviceManager, error in
            self.motion = self.manager.deviceMotion!
            self.attitude = self.motion.attitude
            
            self.ref.child("values").child("gyro").setValue(["x" : String(format: "%.6f", self.attitude.yaw - self.xCalib),
                                                             "y" : String(format: "%.6f", self.attitude.roll - self.yCalib),
                                                             "z" : String(format: "%.6f", self.attitude.pitch - self.zCalib)])
            
            self.xValue.text = "x: " + String(format: "%.3f", self.attitude.yaw - self.xCalib)
            self.yValue.text = "y: " + String(format: "%.3f", self.attitude.roll - self.yCalib)
            self.zValue.text = "z: " + String(format: "%.3f", self.attitude.pitch - self.zCalib)
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func gyroCalibration(_ sender: AnyObject) {
        self.xCalib = self.attitude.yaw
        self.yCalib = self.attitude.roll
        self.zCalib = self.attitude.pitch
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
}

