//
//  ViewController.swift
//  Hello
//
//  Created by Mahmoud on 6/5/19.
//  Copyright © 2019 Mahmoud. All rights reserved.
//

import UIKit
import CoreMotion
import CoreLocation


class ViewController: UIViewController {
	
	
	var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    let motion = CMMotionManager()
    let location = CLLocationManager()
    var timerA: Timer!
	var time: Double = 0.0
	var angle: Double = 0.0
	let file = AppFile()
	var fullData: String = ""
	var iter: Int = 0
    func aquireAccelerometerData() -> Void {
		if self.motion.isAccelerometerAvailable && self.motion.isDeviceMotionAvailable && self.motion.isGyroAvailable{
			self.motion.accelerometerUpdateInterval = 1.0/60
			self.motion.gyroUpdateInterval = 1.0/60
			self.motion.deviceMotionUpdateInterval = 1.0/60
			self.motion.startDeviceMotionUpdates()
			self.motion.startGyroUpdates()
			self.motion.startAccelerometerUpdates()
			self.timerA = Timer(fire: Date(),
								interval: self.motion.accelerometerUpdateInterval,
								repeats: true, block: { (Timer) in
									self.time = self.time + 1.0/60
									if let data = self.motion.accelerometerData ,
										let gyroData = self.motion.gyroData,
										let gravityData = self.motion.deviceMotion?.gravity {
										
										let x = data.acceleration.x
										let y = data.acceleration.y
										let z = data.acceleration.z
										
										let gX = gyroData.rotationRate.x
										let gY = gyroData.rotationRate.y
										let gZ = gyroData.rotationRate.z
										
										
										let gaX = gravityData.x
										let gaY = gravityData.y
										let gaZ = gravityData.z
										
										
										
										self.xValue.text = String(x)
										self.yValue.text = String(y)
										self.zValue.text = String(z)
										
										
										self.gX.text = String(gX)
										self.gY.text = String(gY)
										self.gZ.text = String(gZ)
										
										
										self.gravX.text = String(gaX)
										self.gravY.text = String(gaY)
										self.gravZ.text = String(gaZ)
										
										self.angle = Double(self.getDirection(manager: self.location, didUpdateHeading: self.location.heading)) as! Double
										self.direction.text = self.getDirection(manager: self.location, didUpdateHeading: self.location.heading)
										self.fullData += self.generateString(t: self.time
											, aX: x
											, aY: y
											, aZ: z
											, gX: gX
											, gY: gY
											, gZ: gZ
											, gaX: gaX
											, gaY: gaY
											, gaZ: gaZ
											, direction: self.angle)
									}
			})
			RunLoop.current.add(self.timerA!, forMode: RunLoop.Mode.default)
		}
    }
	func generateString(t:Double,aX:Double, aY:Double,aZ: Double,gX:Double, gY:Double,gZ: Double,gaX:Double, gaY:Double,gaZ: Double,direction:Double) -> String {
		return String(t) + "," + String(aX) + "," + String(aY) + "," + String(aZ) + "," +
			String(gX) + "," + String(gY) + "," + String(gZ) + "," + String(gaX) + "," + String(gaY) + "," + String(gaZ) + "," + String(direction) + "\n"
	}
    func getDirection(manager: CLLocationManager!, didUpdateHeading newHeading: CLHeading!) -> String {
        return String(newHeading.trueHeading)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    @IBOutlet var direction: UILabel!
	
    @IBOutlet var xValue: UILabel!
    @IBOutlet var yValue: UILabel!
    @IBOutlet var zValue: UILabel!
	
	
	@IBOutlet var gX: UILabel!
	@IBOutlet var gY: UILabel!
	@IBOutlet var gZ: UILabel!
	
	
	@IBOutlet var gravX: UILabel!
	@IBOutlet var gravY: UILabel!
	@IBOutlet var gravZ: UILabel!
	
	
	override func viewDidLoad() {
        super.viewDidLoad()
        location.startUpdatingHeading()
		registerBackgroundTask()
		if backgroundTask != .invalid {
			endBackgroundTask()
		}
		NotificationCenter.default
			.addObserver(self, selector: #selector(reinstateBackgroundTask),
						 name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    @IBAction func beginTakingData(_ sender: UIButton) {
        aquireAccelerometerData()
		registerBackgroundTask()
    }
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	@objc func reinstateBackgroundTask() {
		if timerA != nil && backgroundTask ==  .invalid {
			registerBackgroundTask()
		}
	}
	func registerBackgroundTask() {
		backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
			self?.endBackgroundTask()
		}
		assert(backgroundTask != .invalid)
	}
	func endBackgroundTask() {
		print("Background task ended.")
		UIApplication.shared.endBackgroundTask(backgroundTask)
		backgroundTask = .invalid
	}
    @IBAction func stopTakingData(_ sender: UIButton) {
        self.timerA.invalidate()
		_ = file.writeFile(containing: fullData, to: .Documents, withName: "test" + String(self.iter) + ".csv")
		_ = file.list()
		print("file written...")
		self.iter += 1
		self.fullData = ""
		self.time = 0.0
    }
}

