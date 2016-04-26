//
//  MainListViewController.swift
//  CountryCityWorkProject
//
//  Created by Михаил Силантьев on 22.04.16.
//  Copyright © 2016 Михаил Силантьев. All rights reserved.
//

import UIKit

class MainListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CountryTableViewCellProtocol {

    
    @IBAction func changeBg(sender: AnyObject) {
        let notification = NSNotification(name: NotificationMessages.FavotireChanged, object: 2)
        notificationCenter.postNotification(notification)
    }
    
    var backgroundView: UIView?
    func prepareBackgroundView() {
        let backgroundView = UIView(frame: self.tableView.frame)
        if let backgroundPatternImage = UIImage(named: "bgIOS") {
            UIGraphicsBeginImageContext(backgroundView.frame.size)
            backgroundPatternImage.drawInRect(backgroundView.bounds)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            // set background color
            // get color from bgGallery
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
    
    @IBOutlet weak var tableView: UITableView!
    
    let notificationCenter = NSNotificationCenter.defaultCenter()
    
    
    @IBOutlet weak var processActivityBackgroundView: UIView!
    @IBOutlet weak var processActivityView: UIStackView!
    @IBOutlet weak var processActivity_activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var processActivity_label: UILabel!
    
    
    @IBOutlet weak var refreshDataButton: UIBarButtonItem! {
        didSet {
            refreshDataButton.enabled = false
        }
    }
    
    func startActivityProcess() {
        // little animation
        refreshDataButton?.enabled = false
        clearCityIdButton?.enabled = false
        processActivityView?.hidden = false
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
                // self.clearCityIdButton.enabled = true
                self.processActivity_activityIndicator.stopAnimating()
                
                // whis is not good
                // data may be prepared for a long time, bt for test
                self.refreshDataButton.enabled = true
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // observe notification server for updating data
        notificationCenter.addObserver(self, selector: Selector("dataDownloaded:"), name: NotificationMessages.DataDownloaded, object: nil)
        notificationCenter.addObserver(self, selector: Selector("favoriteIdAdded:"), name: NotificationMessages.AddToFavorite, object: nil)
        notificationCenter.addObserver(self, selector: Selector("favoriteIdRemove:"), name: NotificationMessages.RemoveFromFavorite, object: nil)
        notificationCenter.addObserver(self, selector: Selector("selectedCityIdChanged:"), name: NotificationMessages.SelectedCityIdCompleteCahnging, object: nil)
        notificationCenter.addObserver(self, selector: Selector("favoriteClear:"), name: NotificationMessages.FavoritWasCleared, object: nil)
        notificationCenter.addObserver(self, selector: Selector("dataReloaded:"), name: NotificationMessages.ReloadDataComplete, object: nil)
        notificationCenter.addObserver(self, selector: Selector("reloadData"), name: NotificationMessages.ReloadDataStart, object: nil)
        
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
    
    
    @IBAction func refreshDataAction(sender: AnyObject) {
        let notification = NSNotification(name: NotificationMessages.ReloadData, object: nil)
        notificationCenter.postNotification(notification)
    }
    
    func reloadData() {
        startActivityProcess()
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
            print("44444")
        }
    }
    
    func dataReloaded(notification: NSNotification) {
        if let data = notification.object as? [CoreCountryData] {
            proceddDownlodadedData(data)
        }
    }
    
    func prepareTableViewAndData() {
        self.processActivity_label? .text = LoadDataMesages.PrepareData
        let qos = Int(QOS_CLASS_USER_INITIATED.rawValue)
        dispatch_async(dispatch_get_global_queue(qos, 0)) {
            self.prepareTableData()
            dispatch_async(dispatch_get_main_queue()) {
                self.endActivityProcess()
                self.clearTableViewBackgroud()
                self.tableView.reloadData()
                self.selectCityIndexPath()
            }
        }
    }
    
    func selectCityIndexPath(animated: Bool = true) {
        if let section = (PreparedTableCells.indexOf { $0.contains { $0.isSelected } }) {
            if clearCityIdButton.enabled == false {
                clearCityIdButton.enabled = true
            }
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
                clearCityIdButton.enabled = false
            }
        }
    }
    
    func favoriteClear(notification: NSNotification) {
        PreparedTableHeaders.forEach { $0.IsInFavorite = false }
        if let indexPaths = (tableView.indexPathsForVisibleRows?.filter { $0.row == 0 }) {
            tableView.reloadRowsAtIndexPaths(indexPaths, withRowAnimation: .None)
        }
    }
    
    
    
    @IBOutlet weak var clearCityIdButton: UIBarButtonItem! {
        didSet {
            clearCityIdButton.enabled = false
        }
    }
    @IBAction func clearCityIdAction(sender: AnyObject) {
        // this is last one yammm :C
        cityIdSelected(-1)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table View stuff
    
    // Work with defauls
    // Saving and updating favorit list
    var Defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
    func setFavoriteId(id: Int?) {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        let notification = NSNotification(name: NotificationMessages.FavotireChanged, object: id)
        notificationCenter.postNotification(notification)
    }
    
    func favoriteIdAdded(notification: NSNotification) {
        if let id = notification.object as? Int {
            changeFavoriteState(id, favoriteState: true)
        }
    }
    
    func favoriteIdRemove(notification: NSNotification) {
        if let id = notification.object as? Int {
            changeFavoriteState(id, favoriteState: false)
        }
    }
    
    func changeFavoriteState(id: Int?, favoriteState: Bool) {
        if id != nil {
            if let index = (PreparedTableHeaders.indexOf { $0.countryId == id }) {
                PreparedTableHeaders[index].IsInFavorite = favoriteState
                tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: index)], withRowAnimation: .None)
            }
        }
    }
    
    // Main data container
    var CountryDataCollection: [CoreCountryData] = []
    
    // Stuff for collapsing table view sections
    // Looks prety good
    var lastExpandedSectionId: Int = -1
    
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
    }
    
    func cityIdSelected(id: Int?) {
        if id != nil {
            let notification = NSNotification(name: NotificationMessages.SelectedCityIdChanged, object: id)
            notificationCenter.postNotification(notification)
        }
    }
    
    var PreparedTableHeaders: [CountryTableCellData] = []
    var PreparedTableCells: [[CityTableCellData]] = []
    func prepareTableHeaders() {
        // clear containers
        PreparedTableHeaders = []
        PreparedTableCells = []
        // first - get favorite state array from defaults
        let favoriteArray = NSUserDefaults.standardUserDefaults().objectForKey("favoriteArray") as? [Int]
        for countryInfo in CountryDataCollection {
            var isFavorite = false
            if favoriteArray != nil {
                if favoriteArray!.contains(countryInfo.Id) {
                    isFavorite = true
                }
            }
            let countryCellData = CountryTableCellData(countryData: countryInfo, isInFavorite: isFavorite)
            PreparedTableHeaders.append(countryCellData)
            
            let selectedCityId = NSUserDefaults.standardUserDefaults().objectForKey("selectedCityId") as? Int
            var sectionContainer: [CityTableCellData] = []
            for cityInfo in countryInfo.CityListInCountry {
                let cityCellData = CityTableCellData(cityData: cityInfo)
                cityCellData.themeActionName = countryInfo.actionThemeName
                if selectedCityId == cityInfo?.Id {
                    cityCellData.isSelected = true
                }
                sectionContainer.append(cityCellData)
            }
            PreparedTableCells.append(sectionContainer)
            
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // first row of sequence must be header-cell
        // header-cell contains country info
        if indexPath.row == 0 {
            if let headerCell = tableView.dequeueReusableCellWithIdentifier("header") as? CountryTableViewCell {
                headerCell.isFavoriteTableCell = false
                headerCell.cellData = PreparedTableHeaders[indexPath.section]
                headerCell.delegate = self
                return headerCell
            }
        }
        else {
            if let cell = tableView.dequeueReusableCellWithIdentifier("city", forIndexPath: indexPath) as? CityTableViewCell {
                cell.cellData = PreparedTableCells[indexPath.section][indexPath.row - 1]
                cell.themeActionName = PreparedTableHeaders[indexPath.section].themeActionName
                let bgView = UIView()
                bgView.backgroundColor = UIColorFromRGB(0x999999, alpha: 0.3)
                cell.selectedBackgroundView = bgView
                return cell
            }
        }
        
        return tableView.dequeueReusableCellWithIdentifier("city", forIndexPath: indexPath)
    }

}
