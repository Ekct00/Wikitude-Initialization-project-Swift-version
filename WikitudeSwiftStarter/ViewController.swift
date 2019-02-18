//
//  ViewController.swift
//  WikitudeSwiftStarter
//
//  Created by Ekct on 2/18/19.
//  Copyright © 2019 WalkPhoneGo. All rights reserved.
//

import UIKit

class ViewController: UIViewController, WTArchitectViewDelegate{
    fileprivate var architectView:WTArchitectView?
    fileprivate var architectWorldNavigation:WTNavigation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            try WTArchitectView.isDeviceSupported(forRequiredFeatures: WTFeatures._ImageTracking)
            architectView = WTArchitectView(frame: self.view.frame)
            architectView?.requiredFeatures = ._ImageTracking
            architectView?.delegate = self
            //broken on purpose so it will not compile until  you add your Wikitude license
            architectView?.setLicenseKey("xxx")
            self.architectView?.loadArchitectWorld(from: Bundle.main.url(forResource: "index", withExtension: "html", subdirectory: "Web")!)
            self.view.addSubview(architectView!)
            
            NotificationCenter.default.addObserver(self, selector: #selector(self.didReceiveApplicationWillResignActiveNotification), name: .UIApplicationWillResignActive, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.didReceiveApplicationDidBecomeActiveNotification), name: .UIApplicationDidBecomeActive, object: nil)
            
        } catch {
            print(error)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.startWikitudeSDKRendering()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.stopWikitudeSDKRendering()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func startWikitudeSDKRendering(){
        if self.architectView?.isRunning == false{
            self.architectView?.start({ configuration in
                configuration.captureDevicePosition = AVCaptureDevice.Position.back
            }, completion: {isRunning, error in
                if !isRunning{
                    print("WTArchitectView could not be started. Reason: \(error.localizedDescription)")
                }
            })
        }
    }
    
    func stopWikitudeSDKRendering(){
        if self.architectView?.isRunning == true {
            self.architectView?.stop()
        }
    }
    
    @objc func didReceiveApplicationWillResignActiveNotification(_ notification: Notification) {
        DispatchQueue.main.async(execute: {() -> Void in
            self.stopWikitudeSDKRendering()
        })
    }
    
    @objc func didReceiveApplicationDidBecomeActiveNotification(_ notification: Notification) {
        DispatchQueue.main.async(execute: {() -> Void in
            self.startWikitudeSDKRendering()
        })
    }
    
    
    
    //Revieve JS message and handle
    func architectView(_ architectView: WTArchitectView, receivedJSONObject jsonObject: [AnyHashable : Any]) {
        
        let actionObject = jsonObject["action"]
        if (actionObject != nil) && (actionObject is String) {
            let action = actionObject as? String
            print(action!)
        }
    }
    
}
