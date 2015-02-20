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

struct ContactAttributes {
    static let CONTACT_ID = "contactID"
    static let FIRST_NAME = "firstName"
    static let LAST_NAME = "lastName"
    static let PHONE_NUMBER = "phoneNumber"
    static let PHONE_TYPE = "phoneType"
    static let CONTACT_USER = "contactUser"
}


class ContactDataSource : BaseDataSource {
    
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
        contact.phoneNumber = phoneNumber
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
		let predicate = NSPredicate(format: "(%K BEGINSWITH[cd] %@ OR %K BEGINSWITH[cd] %@) and (\(ContactAttributes.CONTACT_USER).me == false)", ContactAttributes.FIRST_NAME, contains, ContactAttributes.LAST_NAME, contains)
		return Contact.fetchAllSortedBy(sortedByUserFirstNameLastName(), withPredicate: predicate, delegate: delegate)
	}
    
    func getMyContactsIdsWithoutFlipsAccount() -> [String] {
        let sortedBy = [
            NSSortDescriptor(key: ContactAttributes.FIRST_NAME, ascending: true, selector: "caseInsensitiveCompare:"),
            NSSortDescriptor(key: ContactAttributes.LAST_NAME, ascending: true, selector: "caseInsensitiveCompare:")
        ]
        
        var contacts = Contact.findAllSortedBy("firstName", ascending: true, withPredicate: NSPredicate(format: "(\(ContactAttributes.CONTACT_USER) == nil)")) as NSArray
        var sortedContacts = contacts.sortedArrayUsingDescriptors(sortedBy)
        var contactIds = [String]()
        
        for contact in sortedContacts {
            contactIds.append(contact.contactID)
        }
        
        return contactIds
    }
    
    func getMyContactsIdsWithFlipsAccount() -> [String] {
        let sortedBy = [
            NSSortDescriptor(key: ContactAttributes.FIRST_NAME, ascending: true, selector: "caseInsensitiveCompare:"),
            NSSortDescriptor(key: ContactAttributes.LAST_NAME, ascending: true, selector: "caseInsensitiveCompare:")
        ]

        var contacts = Contact.findAllSortedBy("firstName", ascending: true, withPredicate: NSPredicate(format: "(\(ContactAttributes.CONTACT_USER) != nil and \(ContactAttributes.CONTACT_USER).me == false)")) as NSArray
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
    
    func setContactUserAndUpdateContact(user: User!, contact: Contact!) {
        contact.contactUser = user
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
    
    private func getContactById(id: String) -> Contact? {
        return Contact.findFirstByAttribute(ContactAttributes.CONTACT_ID, withValue: id) as? Contact
    }
    
    func getContactBy(firstName: String?, lastName: String?, phoneNumber: String?, phoneType: String?) -> Contact? {
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
            phonenumberPredicate = NSPredicate(format: "%K like %@", ContactAttributes.PHONE_NUMBER, phoneNumber!)
            predicates.append(phonenumberPredicate)
        }
        
        if ((phoneType != nil) && !phoneType!.isEmpty ) {
            phonetypePredicate = NSPredicate(format: "%K like %@", ContactAttributes.PHONE_TYPE, phoneType!)
            predicates.append(phonetypePredicate)
        }
        
        let compound = NSCompoundPredicate.andPredicateWithSubpredicates(predicates)
        return Contact.findFirstWithPredicate(compound) as? Contact
    }
}
