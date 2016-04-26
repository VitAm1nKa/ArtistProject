//
//  CountryTableViewController.swift
//  CountryCityWorkProject
//
//  Created by Михаил Силантьев on 20.04.16.
//  Copyright © 2016 Михаил Силантьев. All rights reserved.
//

import UIKit

class TableSection {
    var headerIndex: Int = 0
    var cells: [Int] = []
}

class CountryTableViewController: UITableViewController, CountryTableViewCellProtocol {
    
    var countryDefaultImage: UIImage?
    var cu1 = CountryCoreTableViewCell()
    var cu2 = CountryCoreTableViewCell()
    
    var fav = [true, true, true, true]
    var tmp = [1, 2, 1, 4]
    var headers = [2, 3, 2, 5]
    // var cells = [1, 3, 4, 6, 8, 9, 10, 11]
    var array = [[1], [3, 4], [6], [8, 9, 10, 11]]
    
    
    var Defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
    func setFavoriteId(id: Int?) {
        if id != nil {
            var favoriteArray: [Int] = []
            if let array = Defaults.objectForKey("favoriteArray") as? [Int] {
                favoriteArray = array
            }
            
//            if add {
//                if !favoriteArray.contains(id!) {
//                    favoriteArray.append(id!)
//                }
//            } else {
//                if favoriteArray.contains(id!) {
//                    if let index = favoriteArray.indexOf(id!) {
//                        favoriteArray.removeAtIndex(index)
//                    }
//                }
//            }
            
            // save data to defaults
            Defaults.setObject(favoriteArray, forKey: "favoriteArray")
            
            // test saving
            let tmp = Defaults.objectForKey("favoriteArray") as? [Int]
            print(tmp)
        }
    }
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var CountryDataCollection: [CountryCoreTableViewCell] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let data = JSON.getData(GetServerPathUrl(ServerPath.GetCountriesInfo))
        let dataProcessed = ProcessData.ParseCountryData(data)
        print(dataProcessed)
        //JSON.getData(GetServerPathUrl(ServerPath.GetRestaurantInfoByRestaurantId, params: ["restaurantId": RestaurantId!]))

        
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        activityIndicator.center = self.view.center
        self.view.addSubview(activityIndicator)
        activityIndicator.bringSubviewToFront(self.view)
        activityIndicator.startAnimating()
        
        let artist1 = CoreArtistData()
        artist1.age = 31
        artist1.firstName = "Demolition project"
        artist1.description = "Artist 1 little description"
        
        let city1 = CoreCityData()
        city1.title = "Novosibirsk"
        city1.artistListInCity = [artist1]
        
        let country1 = CountryCoreTableViewCell()
        country1.title = "Russia"
        country1.cityListInCountry = [city1]
        
        CountryDataCollection.append(country1)
        
        if dataProcessed != nil {
            if let collection = dataProcessed!["collection"] as? [CountryCoreTableViewCell] {
                CountryDataCollection = collection
            }
        }

        prepareTableHeaders()
        prepareTableCells()
        
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        
//        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
//        self.navigationController?.navigationBar.shadowImage = UIImage()
//        self.navigationController?.navigationBar.translucent = true

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        activityIndicator.stopAnimating()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        if indexPath.row == 0 {
//            tableView.deselectRowAtIndexPath(indexPath, animated: true)
//            
//            let section = indexPath.section
//            let rows: Int = tableView.numberOfRowsInSection(section)
//            var cellIndexPathArray: [NSIndexPath] = []
//            
//            if CountryDataCollection[section].CityListCount > 0 {
//                if CountryDataCollection[section].IsExpand == false {
//                    // if collapsed
//                    for i in 1...CountryDataCollection[section].CityListCount {
//                        cellIndexPathArray.append(NSIndexPath(forRow: i, inSection: section))
//                    }
//                    CountryDataCollection[section].IsExpand = true
//                    PreparedTableHeaders[section].collapsed = false
//                    tableView.insertRowsAtIndexPaths(cellIndexPathArray, withRowAnimation: .Right)
//                    tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Top, animated: true)
//                    makeTableViewBackgound(section)
//                } else {
//                    for i in 1...rows-1 {
//                        cellIndexPathArray.append(NSIndexPath(forRow: i, inSection: section))
//                    }
//                    CountryDataCollection[section].IsExpand = false
//                    PreparedTableHeaders[section].collapsed = true
//                    tableView.deleteRowsAtIndexPaths(cellIndexPathArray, withRowAnimation: .Left)
//                    clearTableViewBackgroud()
//                }
//            }
//        }
        
        print(sections)
    }
    
    @IBAction func trtr(sender: AnyObject) {
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    var cells = [["One", "Two"], ["One", "Two", "Three", "Four"], ["One", "Two", "Three", "Four"], ["One", "Two"]]
    var sections = [true, true, true, true]
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return CountryDataCollection.count
        //return cells.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        if CountryDataCollection[section].IsExpand == true {
            // adding 1 - it's because first row of sequnce will be header-cell
            return CountryDataCollection[section].CityListCount + 1
        }
        
        return 1
        
//        if !sections[section] {
//            // adding 1 - it's because first row of sequnce will be header-cell
//            return cells[section].count + 1
//        }
//        
//        return 1
    }
    
//    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let cell = tableView.dequeueReusableCellWithIdentifier("header") as? CountryTableViewCell
//        return nil
//        // return cell
//    }
    
//    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        let footerCell = tableView.dequeueReusableCellWithIdentifier("footer")
//        
//        return footerCell
//    }
    
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.min
    }
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.min
    }
    
    func makeTableViewBackgound(section: Int) {
        // 
    }
    
    func clearTableViewBackgroud() {
        tableView.backgroundView = nil
    }
    
    // Here will prepare cells for header
    // User dequeue cells - make me some trouble, with stylizing
    // I hope next time, i'll fix this problem
    // But now i using my old tehcnique, cz spend a lot of time looking for problem
    // Just prepare cell and store they in array
    var PreparedTableHeaders: [CountryTableViewCell] = []
    func prepareTableHeaders() {
        // first - get favorite state array from defaults
        let favoriteArray = Defaults.objectForKey("favoriteArray") as? [Int]
        for i in 0..<CountryDataCollection.count {
            if let headerCell = tableView.dequeueReusableCellWithIdentifier("header") as? CountryTableViewCell {
                // headerCell.collapsed = CountryDataCollection[i].IsExpand
                headerCell.cellDataDisctionary = CountryDataCollection[i].OutputInfoDictionary
                // headerCell.theme = getTheme(i)
                // headerCell.defaultTheme = getTheme()
                headerCell.delegate = self
                if favoriteArray != nil {
                    if favoriteArray!.contains(CountryDataCollection[i].Id) {
                        headerCell.favoriteState = true
                    }
                }
                PreparedTableHeaders.append(headerCell)
            }
        }
    }
    
    // Here will prepare cells for sectors data (city)
    // I'll make 2 different options for use
    // First - using pure dequeu cells prepare
    // Second - preload cells
    var PreparedTableCells: [[CityTableViewCell]] = []
    func prepareTableCells() {
        for i in 0..<CountryDataCollection.count {
            var sectionContainer: [CityTableViewCell] = []
            for j in 0..<CountryDataCollection[i].CityListCount {
                if let cityCell = tableView.dequeueReusableCellWithIdentifier("city") as? CityTableViewCell {
                    cityCell.cityInfoData = CountryDataCollection[i].CityListInCountry[j]
                    sectionContainer.append(cityCell)
                }
            }
            PreparedTableCells.append(sectionContainer)
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // first row of sequence must be header-cell
        // header-cell contains country info
        if indexPath.row == 0 {
            return PreparedTableHeaders[indexPath.section]
        }

        return PreparedTableCells[indexPath.section][indexPath.row-1]
        
        // First method in use
        // another rows about city
        /*
        if !sections[indexPath.section] {
            if let cell = tableView.dequeueReusableCellWithIdentifier("city", forIndexPath: indexPath) as? CityTableViewCell {
                cell.actionTheme = getTheme(indexPath.section)
                return cell
            }
        }*/
        
        // default row
//        let cell = tableView.dequeueReusableCellWithIdentifier("tmp", forIndexPath: indexPath)
//        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
