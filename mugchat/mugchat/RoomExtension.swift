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

extension Room {
    
    func numberOfUnreadMessages() -> Int {
        var notReadMessagesCount = 0
        
        for (var i = 0; i < self.mugMessagesNotRemoved().count; i++) {
            let mugMessage = self.mugMessages[i] as MugMessage
            
            if (mugMessage.notRead.boolValue) {
                notReadMessagesCount++
            }
        }
        
        return notReadMessagesCount
    }
    
    func lastMessageReceivedWithContent() -> MugMessage? {
        var currentLastMessageWithContent = self.mugMessagesNotRemoved().lastObject as MugMessage!
        
        while (!currentLastMessageWithContent.hasAllContentDownloaded()) {
            var currentIndex = self.mugMessages.indexOfObject(currentLastMessageWithContent)
            if (currentIndex == 0) {
                return nil
            }
            currentLastMessageWithContent = self.mugMessages[--currentIndex] as MugMessage
        }

        return currentLastMessageWithContent
    }
    
    func oldestNotReadMessage() -> MugMessage? {
        let mugMessageDataSource = MugMessageDataSource()
        
        var oldestMessageNotRead = mugMessageDataSource.oldestNotReadMugMessageForRoom(self)
        
        if (oldestMessageNotRead == nil) {
            return self.mugMessagesNotRemoved().lastObject as? MugMessage
        }
        
        return oldestMessageNotRead
    }
    
    func mugMessagesNotRemoved() -> NSOrderedSet {
        var notRemovedMessages = NSMutableOrderedSet()
        
        for (var i = 0; i < self.mugMessages.count; i++) {
            let mugMessage = self.mugMessages[i] as MugMessage
            
            if (!mugMessage.removed.boolValue) {
                notRemovedMessages.addObject(mugMessage)
            }
        }
        
        return notRemovedMessages
    }
    
    func markAllMessagesAsRemoved(completion: CompletionBlock) {
        let mugMessageDataSource = MugMessageDataSource()
        mugMessageDataSource.removeAllMugMessagesFromRoomID(self.roomID, completion)
    }
    
}
