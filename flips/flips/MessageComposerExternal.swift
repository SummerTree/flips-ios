//
//  MessageComposer.swift
//  flips
//
//  Created by Noah Labhart on 7/7/15.
//
//

import Foundation
import MessageUI

class MessageComposerExternal: NSObject, MFMessageComposeViewControllerDelegate {
    
    private let STOCK_INVITATION = NSLocalizedString(
                                        " just sent you a Flip Message! " +
                                        "Download Flips now to view your message. " +
                                        "https://appsto.re/us/rnY96.i",
                                                comment:
                                        " just sent you a Flip Message! " +
                                        "Download Flips now to view your message. " +
                                        "https://appsto.re/us/rnY96.i")
    
    private let DEEPLINK_MESSAGE = NSLocalizedString("", comment: "")
    
    var videoUrl : NSURL?
    var contacts : [String]?
    var messageSent : Bool = false
    var messagePresented : Bool = false
    var containsNonFlipsUsers : Bool = false
    
    weak var delegate : MessageComposerExternalDelegate?
    
    
    ////
    // MFMessageComposeViewController Method Wrappers
    ////
    
    static func canSendText() -> Bool {
        return MFMessageComposeViewController.canSendText()
    }
    
    static func canSendAttachments() -> Bool {
        return MFMessageComposeViewController.canSendAttachments()
    }
    
    
    
    ////
    // MARK: -
    ////
    
    func configuredMessageComposeViewController() -> MFMessageComposeViewController {
        
        let userName = NSLocalizedString(User.loggedUser()!.fullName()!, comment: User.loggedUser()!.fullName()!)
        
        let messageComposeVC = MFMessageComposeViewController()
        messageComposeVC.messageComposeDelegate = self
        messageComposeVC.recipients = self.contacts
        
        if self.containsNonFlipsUsers {
            messageComposeVC.body = userName + STOCK_INVITATION
        }
        
        if MessageComposerExternal.canSendAttachments() {
            messageComposeVC.addAttachmentURL(self.videoUrl!, withAlternateFilename: "\(userName).mov")
            messageComposeVC.disableUserAttachments()
        }
        
        self.messageSent = false
        self.messagePresented = false
        
        return messageComposeVC
    }
    
    
    
    ////
    // MFMessageComposerViewController Delegate
    ////
    
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {

        switch result.rawValue
        {
            case MessageComposeResultSent.rawValue:
                print("Flip MMS sent successfully.")
                self.messageSent = true
                AnalyticsService.logMMSSent()
                delegate?.didFinishSendingTextMessage(true)
            case MessageComposeResultFailed.rawValue:
                print("Text message failed to send.")
                let alertView = UIAlertView(
                    title: NSLocalizedString("Text Send Failure"),
                    message: NSLocalizedString("Text message failed to send."),
                    delegate: nil,
                    cancelButtonTitle: LocalizedString.OK)
                alertView.show()
                self.messageSent = false
                AnalyticsService.logMMSFailed()
                delegate?.didFinishSendingTextMessage(false)
            case MessageComposeResultCancelled.rawValue:
                print("Flips MMS was cancelled.")
                self.messageSent = false
                AnalyticsService.logMMSCancelled()
                delegate?.didCancelSendingTextMessage()
            default:
                self.messageSent = false
                delegate?.didFinishSendingTextMessage(false)
        }
        
        controller.dismissViewControllerAnimated(true, completion: {
            MovieExport.sharedInstance.clearVideoFromLocalStorage(self.videoUrl)
        })
    }
    
}

////
// MessageComposerExternal Delegate Protocol
////

protocol MessageComposerExternalDelegate : class {
    
    func didFinishSendingTextMessage(success: Bool)
    func didCancelSendingTextMessage()
    
}
