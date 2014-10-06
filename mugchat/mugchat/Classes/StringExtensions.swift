//
//  StringExtensions.swift
//  mugchat
//
//  Created by Bruno Bruggemann on 10/3/14.
//
//

extension String {
    
    func stringByRemovingStringsIn(array: NSArray) -> String {
        var newString = self
        for stringToDelete in array {
            newString = newString.stringByReplacingOccurrencesOfString(stringToDelete as String, withString: "", options: NSStringCompareOptions.CaseInsensitiveSearch)
        }
        return newString
    }
}
