//
//  ContactListHelper.swift
//  mugchat
//
//  Created by Diego Santiviago on 11/12/14.
//
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
                self.retrieveContacts()
            })
        } else if (RHAddressBook.authorizationStatus().value == RHAuthorizationStatusDenied.value
            || RHAddressBook.authorizationStatus().value == RHAuthorizationStatusRestricted.value) {

                failure(NSLocalizedString("Denied", comment: "Denied"))
        }
    }
    
    private func retrieveContacts() -> Array<ContactListHelper.Contact> {
        let people = self.addressBook.people() as Array<RHPerson>
        var contacts = Array<ContactListHelper.Contact>()
        for person in people {
            let phones = person.phoneNumbers
            for (var i:UInt = 0; i < phones.count(); i++) {
                var contact = ContactListHelper.Contact(firstName: person.firstName, lastName: person.lastName, phoneNumber: phones.valueAtIndex(i) as String)
                contacts.append(contact)
            }
        }
        
        return contacts
    }
}