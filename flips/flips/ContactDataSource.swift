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
        var entity: Contact! = Contact.MR_createEntity() as Contact

        entity.createdAt = NSDate()
        entity.contactID = String(self.nextContactID())
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
    
    func createOrUpdateContactWith(firstName: String, lastName: String?, phoneNumber: String, phoneType: String) -> Contact {

        var contact = self.getContactBy(firstName, lastName: lastName, phoneNumber: phoneNumber, phoneType: phoneType)
        
        if (contact == nil) {
            contact = self.createEntityWith(firstName, lastName: lastName, phoneNumber: phoneNumber, phoneType: phoneType)
        } else {
            self.fillContact(contact!, firstName: firstName, lastName: lastName, phoneNumber: phoneNumber, phoneType: phoneType)
        }
        self.save()
        
        return contact!
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
        self.save()
    }
    
    
    // MARK: - Private Methods
    
    private func nextContactID() -> Int {
        let contacts = Contact.MR_findAllSortedBy("contactID.intValue", ascending: false)
        let contact: Contact = contacts.first as Contact
        if (contacts == nil || contact.contactID == nil) {
            return 0
        }
        
        var contactID: String = contact.contactID
        var nextID: Int = contactID.toInt()!
        return ++nextID
    }
    
    private func getContactById(id: String) -> Contact? {
        return Contact.findFirstByAttribute(ContactAttributes.CONTACT_ID, withValue: id) as? Contact
    }
    
    private func getContactBy(firstName: String?, lastName: String?, phoneNumber: String?, phoneType: String?) -> Contact? {
        var firstnamePredicate: NSPredicate!
        var lastnamePredicate: NSPredicate!
        var phonenumberPredicate: NSPredicate!
        var phonetypePredicate: NSPredicate!
        var predicates = [NSPredicate]()
        
        if (firstName != nil) {
            firstnamePredicate = NSPredicate(format: "%K like %@", ContactAttributes.FIRST_NAME, firstName!)
            predicates.append(firstnamePredicate)
        }
        
        if (lastName != nil) {
            lastnamePredicate = NSPredicate(format: "%K like %@", ContactAttributes.LAST_NAME, lastName!)
            predicates.append(lastnamePredicate)
        }
        
        if (phoneNumber != nil) {
            phonenumberPredicate = NSPredicate(format: "%K like %@", ContactAttributes.PHONE_NUMBER, phoneNumber!)
            predicates.append(phonenumberPredicate)
        }
        
        if (phoneType != nil) {
            phonetypePredicate = NSPredicate(format: "%K like %@", ContactAttributes.PHONE_TYPE, phoneType!)
            predicates.append(phonetypePredicate)
        }
        
        let compound = NSCompoundPredicate.andPredicateWithSubpredicates(predicates)

        return Contact.findFirstWithPredicate(compound) as? Contact
    }
}
