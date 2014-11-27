//
//  BuilderWord.h
//  mugchat
//
//  Created by Bruno Bruggemann on 11/27/14.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface BuilderWord : NSManagedObject

@property (nonatomic, retain) NSNumber * fromServer;
@property (nonatomic, retain) NSString * word;
@property (nonatomic, retain) NSDate * addedAt;

@end
