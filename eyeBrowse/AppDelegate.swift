//
//  AppDelegate.swift
//  eyeBrowse
//
//  Created by Adam Saladino on 2/19/15.
//  Copyright (c) 2015 Adam Saladino. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MSDynamicsDrawerViewControllerDelegate {

    var window: UIWindow?
    var windowBackground: UIImageView?
    
    var dynamicsDrawerViewController: MSDynamicsDrawerViewController!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        loadCookies()
        
        self.dynamicsDrawerViewController = self.window!.rootViewController as! MSDynamicsDrawerViewController
        self.dynamicsDrawerViewController.delegate = self
        self.dynamicsDrawerViewController.addStylers(from: [MSDynamicsDrawerScaleStyler.styler(), MSDynamicsDrawerFadeStyler.styler()], for:MSDynamicsDrawerDirection.left)
        
        let menuViewController = dynamicsDrawerViewController.storyboard!.instantiateViewController(withIdentifier: "Menu") as! MenuViewController
        menuViewController.dynamicsDrawerViewController = self.dynamicsDrawerViewController
        menuViewController.transitionToViewController(MenuViewController.MSPaneViewControllerType.browser)
        
        self.dynamicsDrawerViewController.setDrawerViewController(menuViewController, for: MSDynamicsDrawerDirection.left)
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window!.rootViewController = self.dynamicsDrawerViewController
        self.window!.makeKeyAndVisible()
        
        return true
    }
    
    func descriptionForPaneState(_ paneState: MSDynamicsDrawerPaneState) -> String {
        switch (paneState) {
        case MSDynamicsDrawerPaneState.open:
            return "MSDynamicsDrawerPaneStateOpen"
        case MSDynamicsDrawerPaneState.closed:
            return "MSDynamicsDrawerPaneStateClosed"
        case MSDynamicsDrawerPaneState.openWide:
            return "MSDynamicsDrawerPaneStateOpenWide"
        }
    }
    
    func descriptionForDirection(_ direction: MSDynamicsDrawerDirection) -> String {
        switch (direction) {
        case MSDynamicsDrawerDirection.top:
            return "MSDynamicsDrawerDirectionTop";
        case MSDynamicsDrawerDirection.left:
            return "MSDynamicsDrawerDirectionLeft";
        case MSDynamicsDrawerDirection.bottom:
            return "MSDynamicsDrawerDirectionBottom";
        case MSDynamicsDrawerDirection.right:
            return "MSDynamicsDrawerDirectionRight";
        default:
            return ""
        }
    }
    
    func dynamicsDrawerViewController(_ drawerViewController: MSDynamicsDrawerViewController!, didUpdateTo paneState: MSDynamicsDrawerPaneState, for direction: MSDynamicsDrawerDirection) {
        NSLog("Drawer view controller did update to state `%@` for direction `%@`", descriptionForPaneState(paneState), self.descriptionForDirection(direction))
    }
    
    func dynamicsDrawerViewController(_ drawerViewController: MSDynamicsDrawerViewController!, mayUpdateTo paneState: MSDynamicsDrawerPaneState, for direction: MSDynamicsDrawerDirection) {
        NSLog("Drawer view controller may update to state `%@` for direction `%@`", descriptionForPaneState(paneState), self.descriptionForDirection(direction))
    
    }
    
    func dynamicsDrawerViewController(_ drawerViewController: MSDynamicsDrawerViewController!, shouldBeginPanePan panGestureRecognizer: UIPanGestureRecognizer!) -> Bool {
        return true
    }
    

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveCookies()
        self.saveContext()
    }
    
    func loadCookies() {
        let cookieData: Data? = UserDefaults.standard.object(forKey: "cookies") as! Data?
        if cookieData != nil {
            let cookies: [HTTPCookie]! = NSKeyedUnarchiver.unarchiveObject(with: cookieData!) as! [HTTPCookie]!
            let cookieStorage = HTTPCookieStorage.shared
            for cookie in cookies {
                cookieStorage.setCookie(cookie)
            }
        }
    }
    
    func saveCookies() {
        let cookiesData = NSKeyedArchiver.archivedData(withRootObject: HTTPCookieStorage.shared.cookies!)
        let defaults = UserDefaults.standard
        defaults.set(cookiesData, forKey: "cookies")
        defaults.synchronize()
    }
    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.codingsimply.apps.eyeBrowse" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1] as URL
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "eyeBrowse", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("eyeBrowse.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        
        do {
            try coordinator!.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
            return coordinator
        } catch var error {
            coordinator = nil
            // Report any error we got.
            let dict = NSMutableDictionary()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict as? [AnyHashable : Any])
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error)")
            abort()
        }
        
    }()

    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if let moc = self.managedObjectContext {
            if moc.hasChanges {
                do {
                    try moc.save()
                } catch let error {
                    NSLog("Unresolved error \(error)")
                    abort()
                }
            }
        }
    }

}
