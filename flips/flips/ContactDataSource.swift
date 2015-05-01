//
// Copyright 2015 ArcTouch, Inc.
// All rights reserved.
//
// This file, its contents, concepts, methods, behavior, and operation
// (collectively the "Software") are protected by trade secret, patent,
// and copyright laws. The use of the Software is governed by a license
// agreement. Disclosure of the Software to third parties, in any form,
// in whole or in part, is expressly prohibited except as authorized by
// the license agreement.
//

struct ContactAttributes {
    static let CONTACT_ID = "contactID"
    static let FIRST_NAME = "firstName"
    static let LAST_NAME = "lastName"
    static let PHONE_NUMBER = "phoneNumber"
    static let PHONE_TYPE = "phoneType"
    static let CONTACT_USER = "contactUser"
}

@objc class ContactDataSource : BaseDataSource {
    
    // MARK: - CoreData Creator Methods
    
    private func createEntityWith(firstName: String, lastName: String?, phoneNumber: String, phoneType: String) -> Contact {
        var entity: Contact! = Contact.createInContext(currentContext) as Contact

        entity.createdAt = NSDate()
        self.fillContact(entity, firstName: firstName, lastName: lastName, phoneNumber: phoneNumber, phoneType: phoneType)
        
        return entity
    }
    
    private func fillContact(contact: Contact, firstName: String, lastName: String?, phoneNumber: String, phoneType: String) {
        contact.firstName = firstName
        contact.lastName = lastName
        contact.phoneNumber = PhoneNumberHelper.formatUsingUSInternational(phoneNumber)
        contact.phoneType = phoneType
        contact.updatedAt = NSDate()
    }
    
    
    // MARK: - Public Methods
    
    func createContactWith(contactID: String, firstName: String, lastName: String?, phoneNumber: String, phoneType: String, andContactUser contactUser: User? = nil) -> Contact {
        let contact = self.createEntityWith(firstName, lastName: lastName, phoneNumber: phoneNumber, phoneType: phoneType)
        contact.contactID = contactID
        
        if (contactUser != nil) {
            let contactUserInContext = contactUser?.inContext(currentContext) as User
            contact.contactUser = contactUserInContext
            contactUserInContext.addContactsObject(contact)
        }
        
        return contact
    }
    
    func updateContact(contact: Contact, withFirstName firstName: String, lastName: String?, phoneNumber: String, phoneType: String) -> Contact {
        let contactInContext = contact.inContext(currentContext) as Contact
        self.fillContact(contactInContext, firstName: firstName, lastName: lastName, phoneNumber: phoneNumber, phoneType: phoneType)
        return contactInContext
    }
    
    func sortedByUserFirstNameLastName() -> [NSSortDescriptor] {
        let sortedBy = [
            NSSortDescriptor(key: ContactAttributes.FIRST_NAME, ascending: true, selector: "caseInsensitiveCompare:"),
            NSSortDescriptor(key: ContactAttributes.LAST_NAME, ascending: true, selector: "caseInsensitiveCompare:")
        ]

        return sortedBy
    }
	
	func fetchedResultsController(contains: String, delegate: NSFetchedResultsControllerDelegate?) -> NSFetchedResultsController {
        if let loggedUser = User.loggedUser() {
            let predicate = NSPredicate(format: "(%K BEGINSWITH[cd] %@ OR %K BEGINSWITH[cd] %@) and (\(ContactAttributes.PHONE_NUMBER) != %@)",
                ContactAttributes.FIRST_NAME,
                contains,
                ContactAttributes.LAST_NAME,
                contains,
                PhoneNumberHelper.formatUsingUSInternational(loggedUser.phoneNumber))
            return Contact.fetchAllSortedBy(sortedByUserFirstNameLastName(), withPredicate: predicate, delegate: delegate)
        } else {
            return NSFetchedResultsController()
        }
	}
    
    func getMyContactsIdsWithoutFlipsAccount() -> [String] {
        if let loggedUser = User.loggedUser() {
            let sortedBy = [
                NSSortDescriptor(key: ContactAttributes.FIRST_NAME, ascending: true, selector: "caseInsensitiveCompare:"),
                NSSortDescriptor(key: ContactAttributes.LAST_NAME, ascending: true, selector: "caseInsensitiveCompare:")
            ]
            
            let formatedPhoneNumber = PhoneNumberHelper.formatUsingUSInternational(loggedUser.phoneNumber)
            let predicate = NSPredicate(format: "(\(ContactAttributes.PHONE_NUMBER) != %@) and ((\(ContactAttributes.CONTACT_USER) == nil) or (\(ContactAttributes.CONTACT_USER).isTemporary == true))", formatedPhoneNumber)
            var contacts = Contact.findAllSortedBy("firstName", ascending: true, withPredicate: predicate, inContext: currentContext) as NSArray
            var sortedContacts = contacts.sortedArrayUsingDescriptors(sortedBy)
            var contactIds = Array<String>()
            
            for contact in sortedContacts {
                contactIds.append(contact.contactID)
            }
            
            return contactIds
        } else {
            return Array<String>()
        }
    }
    
    func getMyContactsIdsWithFlipsAccount() -> [String] {
        let sortedBy = [
            NSSortDescriptor(key: ContactAttributes.FIRST_NAME, ascending: true, selector: "caseInsensitiveCompare:"),
            NSSortDescriptor(key: ContactAttributes.LAST_NAME, ascending: true, selector: "caseInsensitiveCompare:")
        ]

        var contacts = Contact.findAllSortedBy("firstName", ascending: true, withPredicate: NSPredicate(format: "(\(ContactAttributes.CONTACT_USER) != nil and \(ContactAttributes.CONTACT_USER).me == false) and (\(ContactAttributes.CONTACT_USER).isTemporary != true)"), inContext: currentContext) as NSArray
        var sortedContacts = contacts.sortedArrayUsingDescriptors(sortedBy)
        var contactIds = [String]()
        
        for contact in sortedContacts {
            contactIds.append(contact.contactID)
        }
        
        return contactIds
    }
    
    func retrieveContactWithId(id: String) -> Contact {
        var contact = self.getContactById(id)
        
        if (contact == nil) {
            println("Contact (\(id)) not found in the database, and it mustn't happen. Check why he wasn't imported to database yet.")
        }
        
        return contact!
    }

    func retrieveContactsWithPhoneNumber(phoneNumber: String) -> [Contact] {
        if (countElements(phoneNumber) == 0) {
            return [Contact]()
        }
        
        let contacts = Contact.findAll() as [Contact]
        let cleannedPhoneNumber = PhoneNumberHelper.formatUsingUSInternational(phoneNumber)
        
        var contactsWithSamePhoneNumber = Array<Contact>()
        for contact in contacts {
            var contactPhoneNumber = contact.phoneNumber as String!
            if (PhoneNumberHelper.formatUsingUSInternational(contactPhoneNumber) == cleannedPhoneNumber) {
               contactsWithSamePhoneNumber.append(contact)
            }
        }
        return contactsWithSamePhoneNumber
    }
    
    func getMyContactsSortedByUsersFirst() -> [Contact] {
        if let loggedUser = User.loggedUser() {
            let predicate = NSPredicate(format: "(\(ContactAttributes.PHONE_NUMBER) != %@)", PhoneNumberHelper.formatUsingUSInternational(loggedUser.phoneNumber))
            let contacts: NSArray = Contact.findAllSortedBy(self.sortedByUserFirstNameLastName(), withPredicate: predicate) as NSArray
            
            let usersFirst = contacts.sortedArrayUsingComparator { (contact1, contact2) -> NSComparisonResult in
                
                let contact1: Contact = contact1 as Contact
                let contact2: Contact = contact2 as Contact
                
                if (contact1.contactUser == nil && contact2.contactUser == nil) {
                    return NSComparisonResult.OrderedSame
                }
                
                if (contact1.contactUser != nil && contact2.contactUser != nil) {
                    return NSComparisonResult.OrderedSame
                }
                
                if (contact1.contactUser != nil && contact2.contactUser == nil) {
                    return NSComparisonResult.OrderedAscending
                }
                
                return NSComparisonResult.OrderedDescending
            }
            
            return usersFirst as [Contact]
        } else {
            return Array<Contact>()
        }
    }
    
    func setContactUserAndUpdateContact(user: User!, contact: Contact!) {
        contact.contactUser = user
    }
    
    func getContactById(id: String) -> Contact? {
        return Contact.findFirstByAttribute(ContactAttributes.CONTACT_ID, withValue: id, inContext: currentContext) as? Contact
    }
    
    
    // MARK: - Private Methods
    
    func nextContactID() -> Int {
        let contacts = Contact.findAll()
        
        var currentID: Int = 0
        for contact in contacts {
            var contactID: String = contact.contactID
            if (contactID.toInt() > currentID) {
                currentID = contactID.toInt()!
            }
        }
        return ++currentID
    }
    
    func fetchContactByPhoneNumber(phoneNumber: String) -> Contact? {
        let predicate = NSPredicate(format: "%K = %@", ContactAttributes.PHONE_NUMBER, phoneNumber)
        return Contact.findFirstWithPredicate(predicate, inContext: currentContext) as? Contact
    }
    
    func findContactBy(firstName: String?, lastName: String?, phoneNumber: String?, phoneType: String?) -> Contact? {
        var firstnamePredicate: NSPredicate!
        var lastnamePredicate: NSPredicate!
        var phonenumberPredicate: NSPredicate!
        var phonetypePredicate: NSPredicate!
        var predicates = [NSPredicate]()
        
        if (firstName != nil && !firstName!.isEmpty) {
            firstnamePredicate = NSPredicate(format: "%K like %@", ContactAttributes.FIRST_NAME, firstName!)
            predicates.append(firstnamePredicate)
        }
        
        if (lastName != nil && !lastName!.isEmpty) {
            lastnamePredicate = NSPredicate(format: "%K like %@", ContactAttributes.LAST_NAME, lastName!)
            predicates.append(lastnamePredicate)
        }
        
        if (phoneNumber != nil && !phoneNumber!.isEmpty) {
            let formatedPhoneNumber = PhoneNumberHelper.formatUsingUSInternational(phoneNumber!)
            phonenumberPredicate = NSPredicate(format: "%K like %@", ContactAttributes.PHONE_NUMBER, formatedPhoneNumber)
            predicates.append(phonenumberPredicate)
        }
        
        if ((phoneType != nil) && !phoneType!.isEmpty ) {
            phonetypePredicate = NSPredicate(format: "%K like %@", ContactAttributes.PHONE_TYPE, phoneType!)
            predicates.append(phonetypePredicate)
        }
        
        let compound = NSCompoundPredicate.andPredicateWithSubpredicates(predicates)
        return Contact.findFirstWithPredicate(compound, inContext: currentContext) as? Contact
    }
}
