//
//  FlipMessageSubmissionManager.swift
//  flips
//
//  Created by Taylor Bell on 9/13/15.
//
//

import Foundation

class FlipMessageSubmissionManager : NSObject {
    
    enum SubmissionState {
        case Sending
        case Waiting
        case Error
    }
    
    struct Notifications {
        static let SEND_ERROR = "FlipsNotificationSendingFailed"
        static let SEND_COMPLETE = "FlipsNotificationFinishedSending"
        static let RETRY_SUBMISSION = "FlipsNotificationRetrySending"
        static let CANCEL_SUBMISSION = "FlipsNotificationCancelSending"
    }
    
    class var sharedInstance : FlipMessageSubmissionManager {
        struct Singleton {
            static let instance = FlipMessageSubmissionManager()
        }
        return Singleton.instance;
    }
    
    private var state : SubmissionState = .Waiting
    private var requestQueue : [SubmissionRequest] = []
    
    
    
    ////
    // MARK: - Init & Deinit
    ////
    
    override init() {
        super.init()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FlipMessageSubmissionManager.handleRetrySubmissionNotification(_:)), name: Notifications.RETRY_SUBMISSION, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FlipMessageSubmissionManager.handleCancelSubmissionNotification(_:)), name: Notifications.CANCEL_SUBMISSION, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    ////
    // MARK: - Status Methods
    ////
    
    func getState() -> (SubmissionState) {
        return state
    }
    
    func hasPendingMessages() -> (Bool) {
        return requestQueue.count > 1
    }
    
    func hasPendingMessageForRoom(roomID: String) -> (Bool) {
        
        for request in requestQueue {
            if roomID == request.roomID {
                return true
            }
        }
        
        return false
        
    }
    
    func hasAdditionalPendingMessagesForRoom(roomID: String) -> (Bool) {
        
        for i in (1 ..< requestQueue.count) {
            if roomID == requestQueue[i].roomID {
                return true
            }
        }
        
        return false
        
    }
    
    
    
    ////
    // MARK: - Request Submission
    ////
    
    func submitRequest(request: SubmissionRequest) {
        
        // Add the request to the queue
        requestQueue.append(request)
        
        // Begin processing requests
        startExecutingRequests()
        
    }
    
    
    
    ////
    // MARK: - Request Queue Management
    ////
    
    private func startExecutingRequests() {
        
        if requestQueue.count > 0 && state == .Waiting
        {
            state = .Sending
            executeRequest(requestQueue[0])
        }
        
    }
    
    private func executeNextRequest() {
        
        if requestQueue.count > 0
        {
            state = .Sending
            executeRequest(requestQueue[0])
        }
        else
        {
            state = .Waiting
        }
        
    }
    
    private func executeRequest(request: SubmissionRequest) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
        
            if self.createAndUploadFlips(request)
            {
                self.sendMessage(request)
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.state = .Error
                    self.sendMessageSendFailedNotification(request.roomID, error: "Flips Message Error", errorDetails: "Flips was unable to create your message at this time.")
                })
            }
        
        })
        
    }
    
    
    
    ////
    // MARK: - Message Submission
    ////
    
    private func createAndUploadFlips(request: SubmissionRequest) -> (Bool) {
        
        var error : FlipError?
        let group = dispatch_group_create()
        
        for flipPage in request.flipPages {
                
            let flipWord = request.flipWords[flipPage.order]
            
            if flipPage.pageID == nil
            {
                dispatch_group_enter(group)
                
                PersistentManager.sharedInstance.createAndUploadFlip(flipPage.word, videoURL: flipPage.videoURL, thumbnailURL: flipPage.thumbnailURL, createFlipSuccessCompletion: { (flip) -> Void in
                    
                    flipPage.pageID = flip.flipID
                    flipWord.associatedFlipId = flip.flipID
                    
                    dispatch_group_leave(group)
                    
                }, createFlipFailCompletion: { (flipError) -> Void in
                    
                    error = flipError
                    flipPage.pageID = "-1"
                    
                    dispatch_group_leave(group)
                    
                })
            }
            
            dispatch_group_wait(group, DISPATCH_TIME_FOREVER)
            
        }
        
        return error == nil
        
    }
    
    private func sendMessage(request: SubmissionRequest) {
        
        let completionBlock : SendMessageCompletion = { (success, roomID, flipError) -> Void in
                        
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
            
                if (success)
                {
                    self.logRequestAnalytics(request)
                    
                    self.requestQueue.removeAtIndex(0)
                    self.sendMessageSentNotification(roomID!)
                    
                    self.executeNextRequest()
                }
                else
                {
                    self.state = .Error
                    
                    if let flipError = flipError, let error = flipError.error, let details = flipError.details
                    {
                        self.sendMessageSendFailedNotification(roomID, error: error, errorDetails: details)
                    }
                    else
                    {
                        self.sendMessageSendFailedNotification(roomID, error: "Flips Message Error", errorDetails: "Flips was unable to send your message at this time.")
                    }
                }
                
            })
        }
        
        let messageService = MessageService.sharedInstance
        
        if (request.roomID != nil)
        {
            messageService.sendMessage(request.flipWords, roomID: request.roomID!, completion: completionBlock)
        }
        else
        {
            messageService.sendMessage(request.flipWords, toContacts: request.contactIDs!, completion: completionBlock)
        }
        
    }
    
    private func logRequestAnalytics(request: SubmissionRequest) {
        
        let numOfWords = request.flipWords.count
        var numOfWordsAssigned = 0
        
        let flipDataSource = FlipDataSource()
        
        for word in request.flipWords
        {
            if let associatedFlipId = word.associatedFlipId
            {
                let flip = flipDataSource.retrieveFlipWithId(associatedFlipId)
                
                if (!flip.backgroundURL.isEmpty)
                {
                    numOfWordsAssigned += 1
                }
            }
        }
        
        var isGroupRoom = false
        
        if request.contactIDs != nil
        {
            isGroupRoom = request.contactIDs?.count > 1
        }
        else if let roomID = request.roomID
        {
            let roomDataSource = RoomDataSource()
            isGroupRoom = roomDataSource.retrieveRoomWithId(roomID).participants.count > 2
        }
        
        AnalyticsService.logMessageSent(numOfWords, percentWordsAssigned: (numOfWordsAssigned / numOfWords) * 100, group: isGroupRoom)
        
    }
    
    
    
    ////
    // MARK: - Notification Sending
    ////
    
    private func sendMessageSentNotification(roomID: String) {
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
        
            var userInfo : [NSObject : AnyObject] = [NSObject : AnyObject]()
            
            userInfo["roomID"] = roomID
            
            NSNotificationCenter.defaultCenter().postNotificationName(Notifications.SEND_COMPLETE, object: nil, userInfo: userInfo)
            
        })
        
    }
    
    private func sendMessageSendFailedNotification(roomID: String?, error: String?, errorDetails: String?) {
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            
            var userInfo : [NSObject : AnyObject] = [NSObject : AnyObject]()
        
            if let roomID = roomID {
                userInfo["roomID"] = roomID
            }
            
            if let error = error {
                userInfo["error"] = error
            }
            
            if let errorDetails = errorDetails {
                userInfo["errorDetails"] = errorDetails
            }
            
            NSNotificationCenter.defaultCenter().postNotificationName(Notifications.SEND_ERROR, object: nil, userInfo: userInfo)
            
        })
        
    }
    
    
    
    ////
    // MARK: - Notification Handlers
    ////
    
    func handleRetrySubmissionNotification(notification: NSNotification) {
        
        if requestQueue.count > 0 {
            state = .Sending
            executeRequest(requestQueue[0])
        }
        
    }
    
    func handleCancelSubmissionNotification(notification: NSNotification) {
        
        requestQueue.removeAtIndex(0)
        
        executeNextRequest()
        
    }
    
    
    
    ////
    // MARK: - Submission Request Class
    ////
    
    class SubmissionRequest {
        
        private var roomID : String!
        private var contacts : [Contact]?
        
        private var flipWords : [FlipText] = []
        private var flipPages : [FlipPage] = []
        private var flipPlayerItems : [FlipPlayerItem] = []
        
        private var contactIDs : [String]? {
            get {
                return contacts?.map({ (contact) -> String in
                    return contact.contactID
                })
            }
        }
        
        init(flipWords: [FlipText!], flipPages: [FlipPage!], roomID: String!, contacts: [Contact]?) {
            
            self.roomID = roomID
            self.contacts = contacts
            
            for flipWord in flipWords {
                self.flipWords.append(flipWord)
            }
            
            for flipPage in flipPages {
                self.flipPages.append(flipPage)
            }
            
        }
        
    }
    
}