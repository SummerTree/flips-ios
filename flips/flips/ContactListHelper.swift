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

public typealias ContactListSuccessResponse = (Array<ContactListHelperContact>?) -> Void
public typealias ContactListFailureResponse = (String?) -> Void

import Foundation
import AddressBook

public class ContactListHelperContact {

    var firstName: String = ""
    var lastName: String = ""
    var phoneNumber: String = ""
    var phoneType: String = ""

    init(firstName: String?, lastName: String?, phoneNumber: String, phoneType: String) {
        if (firstName != nil) {
            self.firstName = firstName!
        }

        if (lastName != nil) {
            self.lastName = lastName!
        }
        
        self.phoneNumber = phoneNumber
        self.phoneType = phoneType
    }

}

@objc public class ContactListHelper {

    public class var sharedInstance : ContactListHelper {
        struct Static {
            static let instance : ContactListHelper = ContactListHelper()
        }
        return Static.instance
    }

    func findAllContactsWithPhoneNumber(success: ContactListSuccessResponse, failure: ContactListFailureResponse) {
        let authorizationStatus = ABAddressBookGetAuthorizationStatus()

        if (authorizationStatus == ABAuthorizationStatus.Authorized) {
            success(self.retrieveContacts())

        } else if (authorizationStatus == ABAuthorizationStatus.NotDetermined) {
            let addressBook: ABAddressBook? = ABAddressBookCreateWithOptions(nil, nil)?.takeRetainedValue()
            ABAddressBookRequestAccessWithCompletion(addressBook) { (granted, error) -> Void in
                if (!granted) {
                    failure(NSLocalizedString("Denied", comment: "Denied"))
                }

                success(self.retrieveContacts())
            }
        } else if (authorizationStatus == ABAuthorizationStatus.Denied || authorizationStatus == ABAuthorizationStatus.Restricted) {
            failure(NSLocalizedString("Denied", comment: "Denied"))
        }
    }

    private func retrieveContacts() -> Array<ContactListHelperContact>? {
        let addressBook: ABAddressBook? = ABAddressBookCreateWithOptions(nil, nil)?.takeRetainedValue()
        let people: NSArray? = ABAddressBookCopyArrayOfAllPeople(addressBook)?.takeRetainedValue()

        if (people != nil) {
            var contacts = Array<ContactListHelperContact>()

            let loggedUser = User.loggedUser()
            let cleanedLoggedUserPhoneNumber = PhoneNumberHelper.formatUsingUSInternational(loggedUser!.phoneNumber)

            for person : ABRecord in people! {
                let firstName: String? = ABRecordCopyValue(person, kABPersonFirstNameProperty)?.takeRetainedValue() as? String
                let lastName: String? = ABRecordCopyValue(person, kABPersonLastNameProperty)?.takeRetainedValue() as? String
                let phoneNumbers: ABMultiValue? = ABRecordCopyValue(person, kABPersonPhoneProperty)?.takeRetainedValue()

                for i: Int in 0..<(ABMultiValueGetCount(phoneNumbers)) {
                    let phone: String? = ABMultiValueCopyValueAtIndex(phoneNumbers, i).takeRetainedValue() as? String

                    if (phone != nil) {
                        let cleanedPhoneNumber = PhoneNumberHelper.formatUsingUSInternational(phone!)

                        if (cleanedPhoneNumber != cleanedLoggedUserPhoneNumber) {
                            let phoneLabel = ABMultiValueCopyLabelAtIndex(phoneNumbers, i).takeRetainedValue()
                            let phoneType = ABAddressBookCopyLocalizedLabel(phoneLabel).takeRetainedValue() as NSString

                            var contact = ContactListHelperContact(firstName: firstName,
                                lastName: lastName, phoneNumber: cleanedPhoneNumber, phoneType: phoneType)

                            contacts.append(contact)
                        }
                    }
                }
            }

            NSLog("IMPORT CONTACTS - BEGIN CORE DATA UPDATES")

            PersistentManager.sharedInstance.createOrUpdateContacts(contacts)
            
            NSLog("IMPORT CONTACTS - END CORE DATA UPDATES")
            
            return contacts
        }
        
        return nil
    }

}
