//
//  CountryCodes.swift
//  flips
//
//  Created by Noah Labhart on 9/2/15.
//
//

import UIKit

public class CountryCodes: NSObject {

    private let JSON_FILE : String = "CountryCodes"
    private let JSON_EXT : String = "json"
    
    var countryCodes : [NSDictionary] = []
    
    override init() {
        super.init()
        self.loadCountryCodes()
    }
    
    public class var sharedInstance : CountryCodes {
        struct Static {
            static let instance : CountryCodes = CountryCodes()
        }
        return Static.instance
    }
    
    func loadCountryCodes() {
        if let path = NSBundle.mainBundle().pathForResource(self.JSON_FILE, ofType: self.JSON_EXT)
        {
            if let jsonData = try? NSData(contentsOfFile: path, options: .DataReadingMappedIfSafe)
            {
                if let jsonResult: [NSDictionary] = (try? NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableContainers)) as? [NSDictionary]
                {
                    self.countryCodes = jsonResult //.sort { self.countryCodeSort($0, p2: $1) }
                }
            }
        }
    }
    
    func countryCodeSort(p1 : NSDictionary, p2 : NSDictionary) -> Bool {
        return p2["dial_code"] as? String > p1["dial_code"] as? String
    }
    
    func findCountryIndex(countryAbbr: String) -> Int {
        for i in 0...self.countryCodes.count {
            if self.countryCodes[i]["code"] as? String == countryAbbr {
                return i
            }
        }
        return -1
    }
    
    func findCountryDictionary(countryAbbr: String) -> NSDictionary? {
        for i in 0...self.countryCodes.count {
            if self.countryCodes[i]["code"] as? String == countryAbbr {
                return self.countryCodes[i]
            }
        }
        return nil
    }
    
    func findCountryDialCode(countryIndex: Int) -> String? {
        let currCountry = self.countryCodes[countryIndex]
        return currCountry["dial_code"] as! String?
    }
    
    func setSelectedPicksDialCode(picker: UIPickerView) {
        let currentLocale = NSLocale.currentLocale()
        let countryCode = currentLocale.objectForKey(NSLocaleCountryCode) as! String?
        
        if countryCode != nil {
            let dialCodeIndex = self.findCountryIndex(countryCode!)
            picker.selectRow(dialCodeIndex, inComponent: 0, animated: true)
        }
    }
}
