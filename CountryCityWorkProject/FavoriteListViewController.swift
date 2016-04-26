//
//  FavoriteListViewController.swift
//  CountryCityWorkProject
//
//  Created by Михаил Силантьев on 23.04.16.
//  Copyright © 2016 Михаил Силантьев. All rights reserved.
//

import UIKit

class FavoriteListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CountryTableViewCellProtocol {

    
    @IBOutlet weak var tableView: UITableView!
    
    var backgroundView: UIView?
    func prepareBackgroundView() {
        let backgroundView = UIView(frame: self.tableView.frame)
        if let backgroundPatternImage = UIImage(named: "bgIOS") {
            UIGraphicsBeginImageContext(backgroundView.frame.size)
            backgroundPatternImage.drawInRect(backgroundView.bounds)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            // set background color
            backgroundView.backgroundColor = UIColorFromRGB(0xffffff, alpha: 1)
            
            let upperView = UIView(frame: backgroundView.frame)
            upperView.backgroundColor = UIColor(patternImage: image)
            backgroundView.insertSubview(upperView, atIndex: 0)
            
            // blur effect
            let blurEffect = UIBlurEffect(style: .Dark)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = upperView.bounds
            blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
            upperView.insertSubview(blurEffectView, atIndex: 0)
            self.backgroundView = backgroundView
        }
    }
    
    @IBOutlet weak var processActivityBackgroundView: UIView!
    @IBOutlet weak var processActivityView: UIStackView!
    @IBOutlet weak var processActivity_activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var processActivity_label: UILabel!
    @IBOutlet weak var clearFavoriteButton: UIBarButtonItem! {
        didSet {
            clearFavoriteButton.enabled = false
        }
    }
    @IBOutlet weak var searchButton: UIBarButtonItem! {
        didSet {
            searchButton.enabled = false
        }
    }
    
    func startActivityProcess() {
        // little animation
        self.searchButton?.enabled = false
        self.clearFavoriteButton?.enabled = false
        processActivityView.hidden = false
        self.processActivityBackgroundView.hidden = false
        UIView.animateWithDuration(
            0.3,
            animations: {
                self.processActivityView.alpha = 1
                self.processActivityBackgroundView.alpha = 1
            },
            completion: {
                complition in
                // to do
                self.processActivityView.alpha = 1
                self.processActivityBackgroundView.alpha = 1
                self.processActivity_activityIndicator.startAnimating()
        })
    }
    
    func endActivityProcess() {
        UIView.animateWithDuration(
            0.3,
            animations: {
                self.processActivityView.alpha = 0
                self.processActivityBackgroundView.alpha = 0
            },
            completion: {
                complition in
                self.processActivityView.hidden = true
                self.processActivityBackgroundView.hidden = true
                self.processActivity_activityIndicator.stopAnimating()
                
                // whis is not good
                // data may be prepared for a long time, bt for test
                self.searchButton?.enabled = true
                self.clearFavoriteButton?.enabled = true
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // observe notification server for updating data
        notificationCenter.addObserver(self, selector: Selector("dataDownloaded:"), name: NotificationMessages.DataDownloaded, object: nil)
        notificationCenter.addObserver(self, selector: Selector("favoriteIdAdded:"), name: NotificationMessages.AddToFavorite, object: nil)
        notificationCenter.addObserver(self, selector: Selector("favoriteIdRemove:"), name: NotificationMessages.RemoveFromFavorite, object: nil)
        notificationCenter.addObserver(self, selector: Selector("favoriteClear:"), name: NotificationMessages.FavoritWasCleared, object: nil)
        notificationCenter.addObserver(self, selector: Selector("selectedCityIdChanged:"), name: NotificationMessages.SelectedCityIdCompleteCahnging, object: nil)
        notificationCenter.addObserver(self, selector: Selector("dataReloaded:"), name: NotificationMessages.ReloadDataComplete, object: nil)
        notificationCenter.addObserver(self, selector: Selector("reloadData"), name: NotificationMessages.ReloadDataStart, object: nil)
        
        // check data
        if let tabBar = tabBarController as? MainTabBarViewController {
            switch tabBar.dataStausValue {
            case .Downloading, .Refreshing:
                startActivityProcess()
            case .Downloaded:
                proceddDownlodadedData(tabBar.dataStorage)
            case .NotDownloaded:
                // some error data loading stuff
                break
            }
        }
        
        // set table view delegation and data source for self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        prepareBackgroundView()
    }
    
    func reloadData() {
        startActivityProcess()
    }
    
    func dataReloaded(notification: NSNotification) {
        if let data = notification.object as? [CoreCountryData] {
            proceddDownlodadedData(data)
        }
    }
    
    func dataDownloaded(notification: NSNotification) {
        if let data = notification.object as? [CoreCountryData] {
            proceddDownlodadedData(data)
        }
    }
    
    func proceddDownlodadedData(data: [CoreCountryData]?) {
        if data != nil {
            CountryDataCollection = data!
            prepareTableViewAndData()
        }
    }
    
    func prepareTableViewAndData() {
        self.processActivity_label? .text = LoadDataMesages.PrepareData
        let qos = Int(QOS_CLASS_USER_INITIATED.rawValue)
        dispatch_async(dispatch_get_global_queue(qos, 0)) {
            self.prepareTableData()
            dispatch_async(dispatch_get_main_queue()) {
                self.endActivityProcess()
                self.tableView.reloadData()
                self.isFavoriteIsEmpty()
                
                // remove this
                // i have some problem with it
                // then u fast switch from favorite, until expanded section which contains selected cityId
                // and remove any favorite country in main tableview, it's throw an exeption
                // table view trying to display section with non existing id
                // it'll not hard to fix it, bt in this case i just comment this option out
                // in addition, expand section in favorite list, rly not necessary
                //
                // self.selectCityIndexPath()
            }
        }
    }
    
    func selectCityIndexPath(animated: Bool = true) {
        if let section = (PreparedTableCells.indexOf { $0.contains { $0.isSelected } }) {
            let row = PreparedTableCells[section].indexOf { $0.isSelected }
            let indexPath = NSIndexPath(forRow: row! + 1, inSection: section)
            if animated {
                if !PreparedTableHeaders[section].expanded {
                    expandSection(section)
                    lastExpandedSectionId = section
                }
                tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: .Middle)
            } else {
                tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: .None)
            }
        } else {
            if let indexPath = tableView.indexPathForSelectedRow {
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        // 
    }
    
    
    @IBOutlet weak var infoStatusView: UIStackView!
    
    // MARK: - Table View stuff
    
    var notificationCenter: NSNotificationCenter {
        get {
            return NSNotificationCenter.defaultCenter()
        }
    }
    
    // Work with defauls
    // Saving and updating favorit list
    func setFavoriteId(id: Int?) {
        // Show alert first
        let alert = UIAlertController(
            title: "Remvoe fom favorite",
            message: "Are you sure you wan to remove the country from the elected?",
            preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Remove", style: UIAlertActionStyle.Default, handler: {
            action in
            // removing data from favorit
            // update table
            dispatch_async(dispatch_get_main_queue()) {
                let notification = NSNotification(name: NotificationMessages.FavotireChanged, object: id)
                self.notificationCenter.postNotification(notification)
            }
        }))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func removeSectionFromTable(countryId: Int?) {
        if countryId != nil {
            if let index = (PreparedTableHeaders.indexOf { $0.countryId == countryId }) {
                if PreparedTableHeaders[index].expanded {
                    lastExpandedSectionId = -1
                    clearTableViewBackgroud()
                }
                PreparedTableHeaders.removeAtIndex(index)
                PreparedTableCells.removeAtIndex(index)
                tableView.deleteSections(NSIndexSet(index: index), withRowAnimation: .Right)
                if lastExpandedSectionId != -1 && index < lastExpandedSectionId {
                    lastExpandedSectionId--
                }
            }
            isFavoriteIsEmpty()
        }
    }
    
    func isFavoriteIsEmpty() {
        if PreparedTableHeaders.count == 0 {
            if infoStatusView.hidden {
                infoStatusView.hidden = false
                UIView.animateWithDuration(
                    0.6,
                    animations: {
                        self.infoStatusView.alpha = 1
                    },
                    completion: {
                        complition in
                        self.infoStatusView.alpha = 1
                        
                })
            }
        } else
        {
            if !infoStatusView.hidden {
                UIView.animateWithDuration(
                    0.2,
                    animations: {
                        self.infoStatusView.alpha = 0
                    },
                    completion: {
                        complition in
                        self.infoStatusView.alpha = 0
                        self.infoStatusView.hidden = true
                })
            }
        }
    }
    
    func favoriteIdAdded(notification: NSNotification) {
        if let id = notification.object as? Int {
            addToFavorite(id)
        }
    }
    
    func favoriteIdRemove(notification: NSNotification) {
        if let id = notification.object as? Int {
            removeSectionFromTable(id)
        }
    }
    
    func favoriteClear(notification: NSNotification) {
        if PreparedTableHeaders.count > 0 {
            PreparedTableHeaders.removeAll()
            PreparedTableCells.removeAll()
            tableView.reloadData()
            lastExpandedSectionId = -1
            clearTableViewBackgroud()
            isFavoriteIsEmpty()
        }
    }
    
    
    @IBAction func clearFavoriteButton(sender: AnyObject) {
        // clear all kind of favorite
        // firts, ask user for confirm this operation
        let clearFavoriteAlert = UIAlertController(
            title: "Clear favortie",
            message: "You are sure want to clear all favorites?",
            preferredStyle: .Alert)
        
        clearFavoriteAlert.addAction(UIAlertAction(
            title: "Cancel",
            style: .Cancel,
            handler: nil))
        
        clearFavoriteAlert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: {
            alert in
            // create notification for clear
            let notification = NSNotification(name: NotificationMessages.ClearFavorite, object: nil)
            self.notificationCenter.postNotification(notification)
        }))
        
        self.presentViewController(clearFavoriteAlert, animated: true) {
            // do noting
        }
    }
    
    @IBAction func searchActionButton(sender: AnyObject) {
        let alert = UIAlertController(
            title: "Ok, Google?",
            message: "We don't usualy promise anything for the future, but in this case we are making an exeption. We will make a search! Mayby even better than Google",
            preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Not believe", style: UIAlertActionStyle.Default, handler: {
            action in
            // No Way
            let notification = NSNotification(name: NotificationMessages.ClearFavorite, object: nil)
            self.notificationCenter.postNotification(notification)
        }))
        alert.addAction(UIAlertAction(title: "Believe", style: UIAlertActionStyle.Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }

    func addToFavorite(id: Int) {
        if let countryInfo = (CountryDataCollection.filter { c in c.Id == id }.first) {
            let countryCellData = CountryTableCellData(countryData: countryInfo)
            let cityCellsData = countryInfo.CityListInCountry.map { CityTableCellData(cityData: $0) }
            let selectedCityId = NSUserDefaults.standardUserDefaults().objectForKey("selectedCityId") as? Int
            (cityCellsData.filter { $0.cityId == selectedCityId }).first?.isSelected = true
            PreparedTableHeaders.insert(countryCellData, atIndex: 0)
            PreparedTableCells.insert(cityCellsData, atIndex: 0)
            tableView.insertSections(NSIndexSet(index: 0), withRowAnimation: .Right)
            if lastExpandedSectionId != -1 {
                lastExpandedSectionId++
            }
            isFavoriteIsEmpty()
        }
    }
    
    // Main data container
    var CountryDataCollection: [CoreCountryData] = []
    
    // Stuff for collapsing table view sections
    // Looks prety good
    
    var lastExpandedSectionId: Int = -1
    var lastSelectedCityCellId: Int = -1
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            let section = indexPath.section
            
            if lastExpandedSectionId != -1 {
                collapseSection(lastExpandedSectionId)
                if section != lastExpandedSectionId {
                    expandSection(section)
                    lastExpandedSectionId = section
                } else { lastExpandedSectionId = -1 }
            } else {
                expandSection(section)
                lastExpandedSectionId = section
            }
        } else {
            // it's meens city cell was clicked
            // in this case nothing else may be clicked, well, no check it out
            // just scroll to selected cell, believe it'll looking good
            cityIdSelected(PreparedTableCells[indexPath.section][indexPath.row - 1].cityId)
            tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Middle, animated: true)
        }
    }
    
    func expandSection(section: Int) {
        let indexPath = NSIndexPath(forRow: 0, inSection: section)
        PreparedTableHeaders[section].expanded = true
        let indices = (1...PreparedTableCells[section].count).map { NSIndexPath(forRow: $0, inSection: section) }
        tableView.insertRowsAtIndexPaths(indices, withRowAnimation: .Left)
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
        tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Top, animated: true)
        makeTableViewBackgound(PreparedTableHeaders[section].themeActionName)
        
        // select cell if needed
        if let selectedIndex = (PreparedTableCells[section].indexOf { $0.isSelected }) {
            tableView.selectRowAtIndexPath(NSIndexPath(forRow: selectedIndex + 1, inSection: section), animated: true, scrollPosition: .None)
        }
    }
    
    func collapseSection(section: Int) {
        let rows: Int = tableView.numberOfRowsInSection(section)
        let indexPath = NSIndexPath(forRow: 0, inSection: section)
        PreparedTableHeaders[section].expanded = false
        let indices = (1...rows-1).map { NSIndexPath(forRow: $0, inSection: section) }
        tableView.deleteRowsAtIndexPaths(indices, withRowAnimation: .Right)
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
        clearTableViewBackgroud()
    }
    
    func cityIdSelected(id: Int?) {
        if id != nil {
            let notification = NSNotification(name: NotificationMessages.SelectedCityIdChanged, object: id)
            notificationCenter.postNotification(notification)
        }
    }
    
    func selectedCityIdChanged(notification: NSNotification) {
        if let cityId = notification.object as? Int {
            PreparedTableCells.forEach { $0.forEach { $0.isSelected = ($0.cityId == cityId) ? true : false } }
            selectCityIndexPath(false)
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return PreparedTableHeaders.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if PreparedTableHeaders[section].expanded == true {
            // adding 1 - it's because first row of sequnce will be header-cell
            return PreparedTableCells[section].count + 1
        }
        
        return 1
    }
    
    // Margins, header footer heights remove
    // For better look
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 82
        } else {
            return 270
        }
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.min
    }
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.min
    }
    
    // Visual stuff
    // Making background sweet
    func makeTableViewBackgound(themeName: String?) {
        if let themeData = ThemesCollection.getTheme(themeName) {
            backgroundView?.backgroundColor = UIColorFromRGB(themeData.backgroundColor)
            tableView.backgroundView = backgroundView
        }
    }
    
    func clearTableViewBackgroud() {
        tableView.backgroundView = nil
    }
    
    func prepareTableData() {
        prepareTableHeaders()
        // prepareTableCells()
    }
    
    // Here will prepare cells for header
    // User dequeue cells - make me some trouble, with stylizing
    // I hope next time, i'll fix this problem
    // But now i using my old tehcnique, cz spend a lot of time looking for problem
    // Just prepare cell and store they in array
    // *** Updated ***
    // I'm pleased, first of all to himself
    // Problem i had, was due to the fact that i did no so :c
    // It's rly long story about, how, why etc. bt, i found correct solution
    // And i'm using a normal scheme with dequeue cells, allow iOS do all work perfect (not like me)
    var PreparedTableHeaders: [CountryTableCellData] = []
    var PreparedTableCells: [[CityTableCellData]] = []
    func prepareTableHeaders() {
        // clear containers
        PreparedTableHeaders = []
        PreparedTableCells = []
        // first - get favorite state array from defaults
        if let favoriteArray = NSUserDefaults.standardUserDefaults().objectForKey("favoriteArray") as? [Int] {
            let mapData = CountryDataCollection.map { Int($0.Id) }
            for favorite in favoriteArray {
                if mapData.contains(favorite) {
                    let dataIndex = mapData.indexOf(favorite)
                    let countryCellData = CountryTableCellData(countryData: CountryDataCollection[dataIndex!], isInFavorite: true)
                    
                    let selectedCityId = NSUserDefaults.standardUserDefaults().objectForKey("selectedCityId") as? Int
                    var sectionContainer: [CityTableCellData] = []
                    for cityInfo in CountryDataCollection[dataIndex!].CityListInCountry {
                        let cityCellData = CityTableCellData(cityData: cityInfo)
                        cityCellData.themeActionName = CountryDataCollection[dataIndex!].actionThemeName
                        if selectedCityId == cityInfo?.Id {
                            cityCellData.isSelected = true
                        }
                        sectionContainer.append(cityCellData)
                    }
                    PreparedTableHeaders.append(countryCellData)
                    PreparedTableCells.append(sectionContainer)
                }
            }
        }
    }
    
    var selectedCityIndexPath: NSIndexPath?
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // first row of sequence must be header-cell
        // header-cell contains country info
        if indexPath.row == 0 {
            if let headerCell = tableView.dequeueReusableCellWithIdentifier("header") as? CountryTableViewCell {
                headerCell.isFavoriteTableCell = true
                headerCell.cellData = PreparedTableHeaders[indexPath.section]
                headerCell.delegate = self
                return headerCell
            }
        }
        else {
            if let cell = tableView.dequeueReusableCellWithIdentifier("city", forIndexPath: indexPath) as? CityTableViewCell {
                cell.cellData = PreparedTableCells[indexPath.section][indexPath.row - 1]
                cell.themeActionName = PreparedTableHeaders[indexPath.section].themeActionName
                // little strange code
                let bgView = UIView()
                bgView.backgroundColor = UIColorFromRGB(0x999999, alpha: 0.3)
                cell.selectedBackgroundView = bgView
                return cell
            }
        }
        
        return tableView.dequeueReusableCellWithIdentifier("city", forIndexPath: indexPath)
    }


}
