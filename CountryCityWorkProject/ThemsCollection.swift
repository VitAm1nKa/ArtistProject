//
//  ThemsCollection.swift
//  CountryCityWorkProject
//
//  Created by Михаил Силантьев on 22.04.16.
//  Copyright © 2016 Михаил Силантьев. All rights reserved.
////

import Foundation
import UIKit

enum ThemeCollectionTypes {
    case Armin
    case Avenir
    case Avicii
    case None
}

struct ThemeName {
    static let Armin = "Armin"
    static let Avenir = "Avenir"
    static let Avicii = "Avicii"
    static let None = "None"
}

class ThemesCollection {
    static var ThemesCollection: [String: Theme?] = [:]
    static func prepareThemes() {
        ThemesCollection[ThemeName.Armin] = getTheme(ThemeName.Armin)
        ThemesCollection[ThemeName.Avenir] = getTheme(ThemeName.Avenir)
        ThemesCollection[ThemeName.Avicii] = getTheme(ThemeName.Avicii)
        ThemesCollection[ThemeName.None] = getTheme(ThemeName.None)
        print("Thems prepared!")
    }
    static func getTheme(themeName: String?) -> Theme? {
        if themeName != nil {
            switch themeName! {
            case ThemeName.Armin:
                let theme = Theme()
                theme.backgroundColor = 0x241815
                theme.countryTitleColor = 0xf0d9ce
                theme.countryDescriptionColor = 0x76655f
                theme.countryIconBorderColor = 0x82716a
                theme.cityTitleColor = 0xdcbcad
                theme.dotsColor = 0xdcbcad
                theme.authorTitleColor = 0xf0d9ce
                theme.authorDescriptionColor = 0x76655f
                return theme
            case ThemeName.Avenir:
                let theme = Theme()
                theme.backgroundColor = 0x072042
                theme.countryTitleColor = 0x01aef9
                theme.countryDescriptionColor = 0x05598c
                theme.countryIconBorderColor = 0x056296
                theme.cityTitleColor = 0x00adf7
                theme.dotsColor = 0x00adf7
                theme.authorTitleColor = 0x01aef9
                theme.authorDescriptionColor = 0x05598c
                return theme
            case ThemeName.Avicii:
                let theme = Theme()
                theme.backgroundColor = 0x636269
                theme.countryTitleColor = 0xefeff0
                theme.countryDescriptionColor = 0x9b9b9f
                theme.countryIconBorderColor = 0xa4a3a7
                theme.cityTitleColor = 0xe3e9fb
                theme.dotsColor = 0xe3e9fb
                theme.authorTitleColor = 0xefeff0
                theme.authorDescriptionColor = 0x9b9b9f
                return theme
            case ThemeName.None:
                let theme = Theme()
                theme.backgroundColor = 0x636269
                theme.countryTitleColor = 0x000000
                theme.countryDescriptionColor = 0x666666
                theme.countryIconBorderColor = 0xdddddd
                theme.cityTitleColor = 0xe3e9fb
                theme.dotsColor = 0xe3e9fb
                theme.authorTitleColor = 0xefeff0
                theme.authorDescriptionColor = 0x9b9b9f
                return theme
            default: return nil
            }
        }
        
        return nil
    }
}

class Theme {
    var themeTitle: String?
    var backgroundColor: UInt = 0x241815
    var countryTitleColor: UInt = 0x0000000
    var countryDescriptionColor: UInt = 0x000000
    var countryIconBorderColor: UInt = 0x000000
    var countryBackgroundColor: UInt = 0xffffff
    var cityTitleColor: UInt = 0xdcbcad
    var dotsColor: UInt = 0x000000
    var authorTitleColor: UInt = 0xf0d9ce
    var authorDescriptionColor: UInt = 0x000000
}

class CoverImages {
    static var c = 0
    static var imageIndex: Int = 0 {
        didSet {
            if imageIndex >= images.count {
                imageIndex = 0
            }
        }
    }
    static var images = ["cover1", "cover2", "cover3", "cover4", "cover5", "cover6", "cover7", "cover8", "cover9", "cover10"]
    static func GetImage() -> String {
        return images[imageIndex++]
    }
    
    static func getImage() -> UIImage? {
        if let image: UIImage =  UIImage(contentsOfFile: images[c++]) {
            if c >= images.count {
                c = 0
            }
            return image
        }
       
        return nil
    }
}




