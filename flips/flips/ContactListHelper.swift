//
// Copyright 2014 ArcTouch, Inc.
// All rights reserved.
//
// This file, its contents, concepts, methods, behavior, and operation
// (collectively the "Software") are protected by trade secret, patent,
// and copyright laws. The use of the Software is governed by a license
// agreement. Disclosure of the Software to third parties, in any form,
// in whole or in part, is expressly prohibited except as authorized by
// the license agreement.
//

public typealias ContactListSuccessResponse = (Array<ContactListHelper.Contact>?) -> Void
public typealias ContactListFailureResponse = (String?) -> Void

import Foundation

public class ContactListHelper {
    
    public struct Contact {
        let firstName: String!
        let lastName: String!
        let phoneNumber: String!
    }
    
    let addressBook: RHAddressBook! = RHAddressBook()
    
    public class var sharedInstance : ContactListHelper {
        struct Static {
            static let instance : ContactListHelper = ContactListHelper()
        }
        return Static.instance
    }
    
    func findAllContactsWithPhoneNumber(success: ContactListSuccessResponse, failure: ContactListFailureResponse) {
        println("Trying to access Address Book")
        println("Authorization Status = \(RHAddressBook.authorizationStatus().value)")
        
        if (RHAddressBook.authorizationStatus().value == RHAuthorizationStatusAuthorized.value) {
            let contacts = retrieveContacts()
            success(contacts)
            
        } else if (RHAddressBook.authorizationStatus().value == RHAuthorizationStatusNotDetermined.value) {
            addressBook.requestAuthorizationWithCompletion({ (granted, error) -> Void in
                let contacts = self.retrieveContacts()
                success(contacts)
            })
        } else if (RHAddressBook.authorizationStatus().value == RHAuthorizationStatusDenied.value
            || RHAddressBook.authorizationStatus().value == RHAuthorizationStatusRestricted.value) {

                failure(NSLocalizedString("Denied", comment: "Denied"))
        }
    }
    
    private func retrieveContacts() -> Array<ContactListHelper.Contact> {
//        let contactDataSource = ContactDataSource()
        let dataSourceManager = DataFacade.sharedInstance
        let people = self.addressBook.people() as Array<RHPerson>
        var contacts = Array<ContactListHelper.Contact>()
        for person in people {
            let phones: RHMultiStringValue = person.phoneNumbers

            for (var i:UInt = 0; i < phones.count(); i++) {
                if (person.firstName != nil && countElements(person.firstName) > 0) {
                    var contact = ContactListHelper.Contact(firstName: person.firstName, lastName: person.lastName, phoneNumber: phones.valueAtIndex(i) as String)
                    let phoneNumber: String! = phones.valueAtIndex(i) as String
                    let phoneType = ABAddressBookCopyLocalizedLabel(phones.labelAtIndex(i)).takeRetainedValue() as NSString
                    dataSourceManager.createOrUpdateContactWith(person.firstName, lastName: person.lastName, phoneNumber: phoneNumber, phoneType: phoneType)
//                    contactDataSource.createOrUpdateContactWith(person.firstName, lastName: person.lastName, phoneNumber: phoneNumber, phoneType: phoneType)
                    contacts.append(contact)
                }
            }
        }
        
        return contacts
    }
}
