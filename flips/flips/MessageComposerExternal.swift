//
//  MessageComposer.swift
//  flips
//
//  Created by Noah Labhart on 7/7/15.
//
//

import Foundation
import MessageUI

class MessageComposerExternal: NSObject,
                               MFMessageComposeViewControllerDelegate {
    
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
    
    func canSendText() -> Bool {
        return MFMessageComposeViewController.canSendText()
    }
    
    func canSendAttachments() -> Bool {
        return MFMessageComposeViewController.canSendAttachments()
    }
    
    func configuredMessageComposeViewController() -> MFMessageComposeViewController {
        
        var userName = NSLocalizedString(User.loggedUser()!.fullName()!, comment: User.loggedUser()!.fullName()!)
        
        let messageComposeVC = MFMessageComposeViewController()
        messageComposeVC.messageComposeDelegate = self
        messageComposeVC.recipients = self.contacts
        
        if self.containsNonFlipsUsers {
            messageComposeVC.body = userName + STOCK_INVITATION
        }
        
        if self.canSendAttachments() {
            messageComposeVC.addAttachmentURL(self.videoUrl, withAlternateFilename: "\(userName).mov")
            messageComposeVC.disableUserAttachments()
        }
        
        self.messageSent = false
        self.messagePresented = false
        
        return messageComposeVC
    }
    
    func messageComposeViewController(controller: MFMessageComposeViewController!, didFinishWithResult result: MessageComposeResult) {

        switch result.value {
            case MessageComposeResultSent.value:
                println("Flip MMS sent successfully.")
                self.messageSent = true
                
                AnalyticsService.logMMSSent()
                break
            case MessageComposeResultFailed.value:
                println("Text message failed to send.")
                let alertView = UIAlertView(
                    title: NSLocalizedString("Text Send Failure"),
                    message: NSLocalizedString("Text message failed to send."),
                    delegate: nil,
                    cancelButtonTitle: LocalizedString.OK)
                alertView.show()
                self.messageSent = false
                
                AnalyticsService.logMMSFailed()
                break
            case MessageComposeResultCancelled.value:
                println("Flips MMS was cancelled.")
                self.messageSent = false
                
                AnalyticsService.logMMSCancelled()
                break
            default:
                self.messageSent = false
                break
        }
        
        controller.dismissViewControllerAnimated(true, completion: {
            MovieExport.sharedInstance.clearVideoFromLocalStorage(self.videoUrl)
        })
    }
}
