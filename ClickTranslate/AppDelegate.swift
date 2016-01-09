//
//  AppDelegate.swift
//  ClickTranslate
//
//  Created by Tamas Bara on 24.12.15.
//  Copyright © 2015 Tamas Bara. All rights reserved.
//

import UIKit
import SystemConfiguration

let GOOGLE_API_KEY = "?"
let KEY_LAST_WARNING_NO_NETWORK = "kNoNet"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{
    var window: UIWindow?

    class func executeOnMainThread(meth: ()->())
    {
        if NSThread.isMainThread()
        {
            meth()
        }
        else
        {
            dispatch_sync(dispatch_get_main_queue())
            {
                meth()
            }
        }
    }
    
    class func checkNetwork() -> Bool
    {
        if AppDelegate.isConnectedToNetwork()
        {
            return true
        }
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        print("No network error")
        
        var showWarning = false
        let defaults = NSUserDefaults.standardUserDefaults()
        if let strDateLastWarning = defaults.objectForKey(KEY_LAST_WARNING_NO_NETWORK) as? String
        {
            let dateLastWarning = dateFormatter.dateFromString(strDateLastWarning)
            let components = NSCalendar.currentCalendar().components(NSCalendarUnit.Minute, fromDate: dateLastWarning!, toDate: NSDate(), options: NSCalendarOptions(rawValue: 0))
            showWarning = components.minute > 0
        }
        else
        {
            showWarning = true
        }
        
        if showWarning
        {
            let alert = UIAlertView()
            alert.title = NSLocalizedString("Warning", comment: "")
            alert.message = NSLocalizedString("NoNetwork", comment: "")
            alert.addButtonWithTitle("OK")
            alert.show()
            
            defaults.setObject(dateFormatter.stringFromDate(NSDate()), forKey: KEY_LAST_WARNING_NO_NETWORK)
        }
        
        return false
    }
    
    class func isConnectedToNetwork() -> Bool
    {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
        }
        
        var flags = SCNetworkReachabilityFlags.ConnectionAutomatic
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        
        return (isReachable && !needsConnection)
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool
    {
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window?.rootViewController = MainViewController(nibName: "MainViewController", bundle: nil)
        window?.backgroundColor = UIColor.whiteColor()
        window?.makeKeyAndVisible()
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

