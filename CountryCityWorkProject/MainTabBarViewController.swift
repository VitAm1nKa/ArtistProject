//
//  MainTabBarViewController.swift
//  CountryCityWorkProject
//
//  Created by Михаил Силантьев on 23.04.16.
//  Copyright © 2016 Михаил Силантьев. All rights reserved.
//

import UIKit

struct NotificationMessages {
    static let DataLoaded = "dataLoaded"
    static let FavotireChanged = "favoriteChanged"
    static let AddToFavorite = "addToFavorite"
    static let RemoveFromFavorite = "removeFromFavorite"
    static let ClearFavorite = "clearFavorite"
    static let FavoritWasCleared = "favoriteWasCleared"
    static let SelectedCityIdChanged = "selectedCityIdChanged"
    static let SelectedCityIdCompleteCahnging = "selectCityCompleteChanging"
    static let DataDownloaded = "dataDownloded"
    static let ReloadData = "reloadData"
    static let ReloadDataStart = "reloadDataStart"
    static let ReloadDataComplete = "reloadDataComplete"
}

struct LoadDataMesages {
    static let LoadData = "Loading data..."
    static let PrepareData = "Prepare data..."
}

enum DataStaus {
    case NotDownloaded
    case Downloading
    case Downloaded
    case Refreshing
}

class MainTabBarViewController: UITabBarController {
    
    var notificationCenter: NSNotificationCenter {
        get {
            return NSNotificationCenter.defaultCenter()
        }
    }
    var defaults: NSUserDefaults  {
        get {
            return NSUserDefaults.standardUserDefaults()
        }
    }
    
    // made here localData base
    // not perfect, bt for test
    var dataStausValue: DataStaus = .NotDownloaded
    var dataStorage: [CoreCountryData]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBar.tintColor = UIColorFromRGB(0xff2d55)
        
        
        // load Data - Not here
        loadData()
        
        // Listen for favotite state change
        notificationCenter.addObserver(self, selector: Selector("loadData"), name: NotificationMessages.ReloadData, object: nil)
        notificationCenter.addObserver(self, selector: Selector("changeFavorite:"), name: NotificationMessages.FavotireChanged, object: nil)
        notificationCenter.addObserver(self, selector: Selector("clearFavorite:"), name: NotificationMessages.ClearFavorite, object: nil)
        notificationCenter.addObserver(self, selector: Selector("selectedCityIdChanged:"), name: NotificationMessages.SelectedCityIdChanged, object: nil)
    }

    func loadData() {
        // notificate all for starting updating / loading data
        let notification = NSNotification(name: NotificationMessages.ReloadDataStart, object: nil)
        notificationCenter.postNotification(notification)
        
        // start loading data
        dataStausValue = .Downloading
        let qos = Int(QOS_CLASS_USER_INITIATED.rawValue)
        dispatch_async(dispatch_get_global_queue(qos, 0)) {
            let data = JSON.getData(GetServerPathUrl(ServerPath.GetCountriesInfo))
            // and parse data async too
            let dataProcessed = ProcessData.ParseCountryData(data)
            dispatch_async(dispatch_get_main_queue()) {
                if dataProcessed != nil {
                    if let collection = dataProcessed!["collection"] as? [CoreCountryData] {
                        // create notification about ending of downloading data
                        self.dataStorage = collection
                        self.dataStausValue = .Downloaded
                        let notification = NSNotification(name: NotificationMessages.DataDownloaded, object: collection)
                        self.notificationCenter.postNotification(notification)
                    }
                }
            }
        }
    }
    
    func changeFavorite(notification: NSNotification) {
        if let id = notification.object as? Int {
            var favoriteArray: [Int] = []
            if let array = defaults.objectForKey("favoriteArray") as? [Int] {
                favoriteArray = array
            }
            
            // i made it like this, cz rly don't know how many observers ll have
            // in this case i have two observers - main tableView and favorite tableView
            // bt mb next time i'll have more stuff for work with favorite list (send to server or more views)
            // after cell favorite btn click, force message from tableView to notification center
            // in this method, work with defaults for update favorite array, and force new notification
            if !favoriteArray.contains(id) {
                favoriteArray.insert(id, atIndex: 0)
                // force message about add to favorite list
                sendNotification(NotificationMessages.AddToFavorite, object: id)
            } else {
                if let index = favoriteArray.indexOf(id) {
                    favoriteArray.removeAtIndex(index)
                    // force message about remove from favorit list
                    sendNotification(NotificationMessages.RemoveFromFavorite, object: id)
                }
            }
            
            // save data to defaults
            defaults.setObject(favoriteArray, forKey: "favoriteArray")
            
            // test saving
            let tmp = defaults.objectForKey("favoriteArray") as? [Int]
            print(tmp)
        }
    }
    
    func clearFavorite(notification: NSNotification) {
        dispatch_async(dispatch_get_main_queue()) {
            if var favoriteArray = self.defaults.objectForKey("favoriteArray") as? [Int] {
                favoriteArray.removeAll()
                self.defaults.setObject(favoriteArray, forKey: "favoriteArray")
                self.sendNotification(NotificationMessages.FavoritWasCleared)
            }
        }
    }
    
    func selectedCityIdChanged(notification: NSNotification) {
        if let cityId = notification.object as? Int {
            print("City Id = \(cityId)")
            defaults.setInteger(cityId, forKey: "selectedCityId")
            // create notification for call back adding
            let notification = NSNotification(name: NotificationMessages.SelectedCityIdCompleteCahnging, object: cityId)
            notificationCenter.postNotification(notification)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Data for tableviews, in fact - the only :c
    var countryCollectionData: [CountryCoreTableViewCell]?
    
    // Need to load data
    // Make it here, coze i want have one data for all views
    // Async loadin ofc
    // After load, create a notification and send it to all my tables
    func loadCountryData() {
        // async stuff
        let qos = Int(QOS_CLASS_USER_INITIATED.rawValue)
        dispatch_async(dispatch_get_global_queue(qos, 0)) {
            // load data
            let data = JSON.getData(GetServerPathUrl(ServerPath.GetCountriesInfo))
            // and parse data async too
            let dataProcessed = ProcessData.ParseCountryData(data) // hard coded 3 themes
            dispatch_async(dispatch_get_main_queue()) {
                if dataProcessed != nil {
                    if let collection = dataProcessed!["collection"] as? [CountryCoreTableViewCell] {
                        self.countryCollectionData = collection
                        self.sendNotification(NotificationMessages.DataLoaded)
                    }
                }
            }
        }
    }
    
    func sendNotification(notificationMessage: String, object: AnyObject? = nil) {
        // I rly don't know, which way is better
        // Here i'll crete notification and send it
        // Data stil here, doesn't send, another controllers call super to get data
        let notification = NSNotification(name: notificationMessage, object: object)
        notificationCenter.postNotification(notification)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
