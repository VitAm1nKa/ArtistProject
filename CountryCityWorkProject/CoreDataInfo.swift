//
//  CoreDataInfo.swift
//  CountryCityWorkProject
//
//  Created by Михаил Силантьев on 21.04.16.
//  Copyright © 2016 Михаил Силантьев. All rights reserved.
//

import Foundation

class CoreCountryData {
    
    var id: Int?
    var Id: Int! {
        if id == nil {
            id = 0
        }
        
        return id!
    }
    
    var title: String?
    var Title: String! {
        if title == nil {
            title = ""
        }
        
        return title!
    }
    
    var imageLinkString: String?
    var ImageLinkString: String! {
        if imageLinkString == nil {
            imageLinkString = ""
        }
        
        return imageLinkString!
    }
    
    var ImageLinkURL: NSURL? {
//        if let url = NSURL(string: ImageLinkString) {
//            return nil
//        }
        
        return nil
    }
    
    // List of cities in country
    var cityListInCountry: [CoreCityData?]?
    var CityListInCountry: [CoreCityData?] {
        if cityListInCountry == nil {
            cityListInCountry = []
        }
        
        return cityListInCountry!
    }
    
    var CityListCount: Int! {
        return CityListInCountry.count
    }
    
    var ArtistListCount: Int! {
        var artistCount: Int = 0
        for cityData in CityListInCountry {
            if cityData != nil {
                artistCount += cityData!.ArtistListCount
            }
        }
        
        return artistCount
    }
    
    var actionThemeName: String?
    var defaultThemeName: String?
}

class CoreCityData {
    
    var id: Int?
    var Id: Int! {
        if id == nil {
            id = 0
        }
        
        return id!
    }
    
    var countryId: Int?
    var CountryId: Int! {
        if countryId == nil {
            countryId = 0
        }
        
        return countryId!
    }
    
    var title: String?
    var Title: String! {
        if title == nil {
            title = ""
        }
        
        return title!
    }
    
    var imageLinkString: String?
    var ImageLinkString: String! {
        if imageLinkString == nil {
            imageLinkString = ""
        }
        
        return imageLinkString!
    }
    
    var ImageLinkURL: NSURL? {
        if let url = NSURL(string: ImageLinkString) {
            return url
        }
        
        return nil
    }
    
    // List of artists in city
    var artistListInCity: [CoreArtistData?]?
    var ArtistListInCity: [CoreArtistData?] {
        if artistListInCity == nil {
            artistListInCity = []
        }
        
        return artistListInCity!
    }
    
    var ArtistListCount: Int! {
        return ArtistListInCity.count
    }
    
}

class CoreArtistData {
    var id: Int?
    var Id: Int! {
        if id == nil {
            id = 0
        }
        
        return id!
    }
    
    var cityId: Int?
    var CityId: Int! {
        if cityId == nil {
            cityId = 0
        }
        
        return cityId!
    }
    
    var age: Int?
    var Age: Int! {
        if age == nil {
            age = 0
        }
        
        return age!
    }
    
    var firstName: String?
    var FirstName: String! {
        if firstName == nil {
            firstName = ""
        }
        
        return firstName!
    }
    
    var description: String?
    var Description: String! {
        if description == nil {
            description = ""
        }
        
        return description!
    }
}

struct ProcessErros {
    static let NoErrors = "NoErrors"
}

class ProcessData {
    static func ParseCountryData(jsonData: NSDictionary?) -> NSDictionary? {
        
        var processError = ProcessErros.NoErrors
        
        if let data = jsonData {
            let timestamp = data["Timestamp"] as? String
            let error = data["Error"] as? Int
            let result = data["Result"] as? [NSDictionary]
            
            print("Timestamp = \(error)")
            
            // stuff for themes
            let themeNames = [ThemeName.Armin, ThemeName.Avicii, ThemeName.Avenir]
            var index = 0
            
            // if no errors
            // i'm not sure that is Int value, but
            if error == nil {
                if result != nil {
                    var countryList = [CoreCountryData]()
                    // start parse country data
                    for countryInfo in result! {
                        let countryData = CoreCountryData()
                        countryData.id = countryInfo["Id"] as? Int
                        countryData.title = countryInfo["Name"] as? String
                        countryData.imageLinkString = countryInfo["ImageLink"] as? String
                        // work with themes
                        // let's imagine that these data come in JSON
                        countryData.actionThemeName = themeNames[index++]
                        if let citiesData = countryInfo["Cities"] as? [NSDictionary] {
                            var cityList = [CoreCityData?]()
                            // start parse cityData
                            for cityInfo in citiesData {
                                let cityData = CoreCityData()
                                cityData.id = cityInfo["Id"] as? Int
                                cityData.countryId = cityInfo["CountryId"] as? Int
                                cityData.title = cityInfo["Name"] as? String
                                cityData.imageLinkString = cityInfo["ImageLink"] as? String
                                if let artistsData = cityInfo["Artists"] as? [NSDictionary] {
                                    var artistList = [CoreArtistData?]()
                                    //start parse artistData
                                    for artistInfo in artistsData {
                                        let artistData = CoreArtistData()
                                        artistData.id = artistInfo["Id"] as? Int
                                        artistData.cityId = artistInfo["CityId"] as? Int
                                        artistData.age = artistInfo["Age"] as? Int
                                        artistData.firstName = artistInfo["FirstName"] as? String
                                        artistData.description = artistInfo["Description"] as? String
                                        artistList.append(artistData)
                                    }
                                    cityData.artistListInCity = artistList
                                }
                                cityList.append(cityData)
                            }
                            countryData.cityListInCountry = cityList
                        }
                        countryList.append(countryData)
                    }
                    
                    return [
                        "error": processError,
                        "collection": countryList
                    ]
                }
            }
        }
        
        return nil
    }
}
