//
//  CountryTableViewCell.swift
//  CountryCityWorkProject
//
//  Created by Михаил Силантьев on 20.04.16.
//  Copyright © 2016 Михаил Силантьев. All rights reserved.
//

import UIKit

// Table cell core data info
class CountryCoreTableViewCell: CoreCountryData {
    
    private var loadedImage: UIImage?
    var CountryLogoImage: UIImage! {
        // don't checking for image url change or smth.
        // just load new, if loaded eq nil
        // made it for speed develop
        if loadedImage == nil {
            if let url: NSURL = self.ImageLinkURL {
                let qos = Int(QOS_CLASS_USER_INITIATED.rawValue)
                dispatch_async(dispatch_get_global_queue(qos, 0)) {
                    let imageData = NSData(contentsOfURL: url)
                    dispatch_async(dispatch_get_main_queue()) {
                        if imageData != nil {
                            // image link are broken
                            // we'll never see masterpiece ;( 
                            self.loadedImage = UIImage(data: imageData!)
                        } else {
                            // get image from assets
                            self.loadedImage = UIImage(named: "Globe Asia Filled-100-3")
                        }
                    }
                }
            }
            else {
                loadedImage = UIImage(named: "Globe Asia Filled-100-3")
            }
        }
        
        return loadedImage!
    }
    
    // Flag for favorite state change
    var IsInFavorite: Bool! = false
    
    // Expand state for header-row
    var IsExpand: Bool! = false
    
    // Theme for using
    var ThemeName: String?
    
    // Prepared string for city description
    private var countryDescription: String?
    var CountryDescription: String! {
        if countryDescription == nil {
            countryDescription = "Cities: \(self.CityListCount) • Artists: \(self.ArtistListCount)"
        }
        
        return countryDescription!
    }
    
    var OutputInfoDictionary: NSDictionary? {
        // needs output data
        return [
            "countryId": self.Id,
            "countryTitle": self.Title,
            "countryDescription": self.CountryDescription,
            "logoImage": self.CountryLogoImage,
            "favoriteState": self.IsInFavorite
        ]
    }
}



class AccordionHeaderCellData {
    var themeActionName: String? = ThemeName.None
    var themeDefaultName: String? = ThemeName.None
    private var _themeApplied: Bool = false
    private func _applyTheme() {
        if !_themeApplied {
            if let themeData = ThemesCollection.getTheme(themeActionName) {
                applyTheme(themeData)
                _themeApplied = true
            }
        }
    }
    
    private func _removeTheme() {
        if _themeApplied {
            if let themeData = ThemesCollection.getTheme(themeDefaultName) {
                removeTheme(themeData)
                _themeApplied = false
            }
        }
    }
    
    func applyTheme(themeData: Theme) {}
    func removeTheme(themeData: Theme) {}
    
    var expanded: Bool = false {
        didSet {
            if expanded {
                _applyTheme()
                sectionExpand()
            } else {
                _removeTheme()
                sectionCollapse()
            }
        }
    }
    
    func sectionCollapse() {
        
    }
    
    func sectionExpand() {
        
    }
}

class CountryTableCellData: AccordionHeaderCellData {
    
    var title: String?
    var Title: String {
        if title == nil {
            title = "..."
        }
        
        return title!
    }
    
    var countryId: Int?
    
    var imageLinkURL: NSURL?
    private var loadedImage: UIImage?
    var CountryLogoImage: UIImage! {
        // don't checking for image url change or smth.
        // just load new, if loaded eq nil
        // made it for speed develop
        if loadedImage == nil {
            if let url: NSURL = imageLinkURL {
                let qos = Int(QOS_CLASS_USER_INITIATED.rawValue)
                dispatch_async(dispatch_get_global_queue(qos, 0)) {
                    let imageData = NSData(contentsOfURL: url)
                    dispatch_async(dispatch_get_main_queue()) {
                        if imageData != nil {
                            // image link are broken
                            // we'll never see masterpiece ;(
                            self.loadedImage = UIImage(data: imageData!)
                        } else {
                            // get image from assets
                            self.loadedImage = UIImage(named: "Globe Asia Filled-100-3")
                        }
                    }
                }
            }
            else {
                loadedImage = UIImage(named: "Globe Asia Filled-100-3")
            }
        }
        
        return loadedImage!
    }
    
    // Flag for favorite state change
    var IsInFavorite: Bool! = false
    
    var cityCount: Int? = 0
    var artistCount: Int? = 0
    
    // Prepared string for city description
    private var countryDescription: String?
    var CountryDescription: String! {
        if countryDescription == nil {
            if cityCount != nil && artistCount != nil {
                countryDescription = "Cities: \(cityCount!) • Artists: \(artistCount!)"
            }
        }
        
        return countryDescription!
    }
    
    init(countryData: CoreCountryData?, isInFavorite: Bool = false) {
        super.init()
        if countryData != nil {
            self.title = countryData!.Title
            self.countryId = countryData!.Id
            self.imageLinkURL = countryData!.ImageLinkURL
            self.IsInFavorite = isInFavorite
            self.cityCount = countryData!.CityListCount
            self.artistCount = countryData!.ArtistListCount
            self.themeActionName = countryData!.actionThemeName
            self.themeDefaultName = ThemeName.None
        }
    }
}

class AccordionHeaderTableViewCell: UITableViewCell {
    
    var themeActionName: String? = ThemeName.None
    var themeDefaultName: String? = ThemeName.None
    private var _themeApplied: Bool = false
    private func _applyTheme() {
        if let themeData = ThemesCollection.getTheme(themeActionName) {
            applyTheme(themeData)
            _themeApplied = true
            print("aplied")
        }
    }
    
    private func _removeTheme() {
        if let themeData = ThemesCollection.getTheme(themeDefaultName) {
            removeTheme(themeData)
            _themeApplied = false
            print("removed")
        }
    }
    
    func applyTheme(themeData: Theme) {}
    func removeTheme(themeData: Theme) {}
    
    var expanded: Bool = false
    
    func setNeedApplyTheme() {
        if expanded {
            _applyTheme()
            sectionExpand()
            print("1")
        } else {
            _removeTheme()
            sectionCollapse()
            print("2")
        }
    }
    
    func sectionCollapse() {
        
    }
    
    func sectionExpand() {
        
    }
}

class AccordionCellCellData {
    var themeActionName: String? = ThemeName.None
    var isSelected: Bool = false
}

class CityTableCellData: AccordionCellCellData {
    
    var title: String?
    var Title: String {
        if title == nil {
            title = "..."
        }
        
        return title!
    }
    
    var artistList: [ArtistData?]?
    var ArtistList: [ArtistData?] {
        if artistList == nil {
            artistList = []
        }
        
        return artistList!
    }
    
    var cityId: Int?
    
    init(cityData: CoreCityData?) {
        if cityData != nil {
            self.cityId = cityData!.Id
            self.title = cityData!.Title
            artistList = []
            for artistInfo in cityData!.ArtistListInCity {
                if artistInfo != nil {
                    let artistData = ArtistData(artistData: artistInfo!)
                    artistList?.append(artistData)
                }
            }
        }
    }
}

class ArtistData {
    
    var imageLinkURL: NSURL?
    private var loadedImage: UIImage?
    var ArtistCoverImage: UIImage! {
        // don't checking for image url change or smth.
        // just load new, if loaded eq nil
        // made it for speed develop
        if loadedImage == nil {
            if let url: NSURL = imageLinkURL {
                let qos = Int(QOS_CLASS_USER_INITIATED.rawValue)
                dispatch_async(dispatch_get_global_queue(qos, 0)) {
                    let imageData = NSData(contentsOfURL: url)
                    dispatch_async(dispatch_get_main_queue()) {
                        if imageData != nil {
                            // image link are broken
                            // we'll never see masterpiece ;(
                            self.loadedImage = UIImage(data: imageData!)
                        } else {
                            // get image from assets
                            self.loadedImage = UIImage(named: CoverImages.GetImage())
                        }
                    }
                }
            }
            else {
                loadedImage = UIImage(named: CoverImages.GetImage())
            }
        }
        
        return loadedImage!
    }
    
    var firstName: String?
    var FirstName: String {
        if firstName == nil {
            firstName = ""
        }
        
        return firstName!
    }
    
    var description: String?
    var Description: String {
        if description == nil {
            description = ""
        }
        
        return description!
    }
    
    init(artistData: CoreArtistData?) {
        if artistData != nil {
            self.imageLinkURL = nil
            self.firstName = artistData!.FirstName
            self.description = artistData!.Description
        }
    }
}

protocol CountryTableViewCellProtocol {
    func setFavoriteId(id: Int?)
}

class CountryTableViewCell: AccordionHeaderTableViewCell {

    var delegate: CountryTableViewCellProtocol?
    
    var cellData: CountryTableCellData? {
        didSet {
            updateUI()
        }
    }
    
    var cellDataDisctionary: NSDictionary? {
        didSet {
            updateUI()
        }
    }
    
    override func applyTheme(themeData: Theme) {
        countryIconViewContainer?.layer.borderColor = UIColorFromRGB(themeData.countryIconBorderColor).CGColor
        countryTitleLabel?.textColor = UIColorFromRGB(themeData.countryTitleColor)
        countryDescriptionLabel?.textColor = UIColorFromRGB(themeData.countryDescriptionColor)
        self.backgroundColor = UIColorFromRGB(themeData.countryBackgroundColor, alpha: 0)
    }
    
    override func removeTheme(themeData: Theme) {
        countryIconViewContainer?.layer.borderColor = UIColorFromRGB(themeData.countryIconBorderColor).CGColor
        countryTitleLabel?.textColor = UIColorFromRGB(themeData.countryTitleColor)
        countryDescriptionLabel?.textColor = UIColorFromRGB(themeData.countryDescriptionColor)
        self.backgroundColor = UIColorFromRGB(themeData.countryBackgroundColor, alpha: 1)
    }
    
    var countryId: Int?
    
    func updateUI() {
        if cellData != nil {
            countryId = cellData!.countryId
            countryTitleLabel?.text = cellData!.Title
            countryDescriptionLabel?.text = cellData!.CountryDescription
            countryLogoImageView?.image = cellData!.CountryLogoImage
            favoriteState = cellData!.IsInFavorite
            super.themeActionName = cellData!.themeActionName
            super.themeDefaultName = cellData!.themeDefaultName
            super.expanded = cellData!.expanded
            super.setNeedApplyTheme()
        }
        
        if isFavoriteTableCell {
            favoriteButton?.setImage(UIImage(named: "Delete-100"), forState: .Normal)
        } else {
            if favoriteState {
                favoriteButton?.setImage(UIImage(named: "Christmas Star Filled-100"), forState: .Normal)
            } else {
                favoriteButton?.setImage(UIImage(named: "Christmas Star-100"), forState: .Normal)
            }
        }
    }
    
    var section: Int?
    
    @IBOutlet weak var countryLogoImageView: UIImageView!
    @IBOutlet weak var countryTitleLabel: UILabel!
    @IBOutlet weak var countryDescriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    override func sectionCollapse() {
        print("Collapsed")
    }
    
    override func sectionExpand() {
        print("Expanded")
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    // Favorite state stuff
    @IBOutlet weak var favoriteButton: UIButton!
    @IBAction func favoriteButtonAction(sender: UIButton) {
        if isFavoriteTableCell {
            print("Delete")
        } else {
            
        }
        delegate?.setFavoriteId(countryId!)
        // favoriteState = !favoriteState
    }
    
    var isFavoriteTableCell: Bool = false
    var favoriteState: Bool = false
    
    
    @IBOutlet weak var countryIconViewContainer: UIView! {
        didSet {
            countryIconViewContainer.layer.borderWidth = 0.8
            countryIconViewContainer.layer.borderColor = UIColorFromRGB(0xdddddd).CGColor
        }
    }

}

class AccordionCellTableViewCell: UITableViewCell {
    var themeActionName: String? = ThemeName.None {
        didSet {
            _applyTheme()
        }
    }
    
    private func _applyTheme() {
        if let themeData = ThemesCollection.getTheme(themeActionName) {
            applyTheme(themeData)
        }
    }
    
    func applyTheme(themeData: Theme) {}
}

class CityTableViewCell: AccordionCellTableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    @IBOutlet weak var cityTitleLabel: UILabel!
    @IBOutlet weak var dotsLabel: UIButton!
    
    @IBOutlet var artistLogoImageView: [UIImageView]!
    @IBOutlet var artistLabel: [UILabel]!
    @IBOutlet var artistDescriptionLabel: [UILabel]!
    
    @IBOutlet weak var nothingView: UIView! {
        didSet {
            nothingView.hidden = true
        }
    }
    
    override func applyTheme(themeData: Theme) {
        cityTitleLabel?.textColor = UIColorFromRGB(themeData.cityTitleColor)
        dotsLabel?.setTitleColor(UIColorFromRGB(themeData.dotsColor), forState: .Normal)
        if artistLabel != nil {
            for artist in artistLabel! {
                artist.textColor = UIColorFromRGB(themeData.authorTitleColor)
            }
        }
        if artistDescriptionLabel != nil {
            for artist in artistDescriptionLabel! {
                artist.textColor = UIColorFromRGB(themeData.authorDescriptionColor)
            }
        }
    }
    
    var cityInfoData: CoreCityData? {
        didSet {
            updateUI()
        }
    }
    
    var cellData: CityTableCellData? {
        didSet {
            updateUI()
        }
    }
    
    func updateUI() {
        if cellData != nil {
            // set city title
            cityTitleLabel?.text = cellData!.Title
            
            // clear artists sections
            artistLabel?.forEach { $0.text = "" }
            artistDescriptionLabel?.forEach { $0.text = ""}
            artistLogoImageView?.forEach { $0.image = nil }
            nothingView.hidden = true
            
            if cellData!.ArtistList.count == 0 {
                nothingView.hidden = false
            } else {
                for (index, artist) in cellData!.ArtistList.prefix(3).enumerate() {
                    if artist != nil {
                        artistLabel?[index].text = artist!.FirstName
                        artistDescriptionLabel?[index].text = artist!.Description
                        artistLogoImageView?[index].image = artist!.ArtistCoverImage
                    }
                }
            }
        }
    }
    
    var isSelectedState: Bool = false
    
    var collapsed: Bool = true {
        didSet {
            
        }
    }
    
    var isSelecter: Bool = true {
        didSet {
            if isSelecter {
                UIView.animateWithDuration(0.6, animations: {
                    self.alpha = 1
                })
            }
            else {
                UIView.animateWithDuration(0.6, animations: {
                    self.alpha = 0
                })
            }
        }
    }
}


