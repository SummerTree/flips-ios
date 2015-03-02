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

#import <CoreData/CoreData.h>

@interface NSManagedObject (helpers)

+ (NSFetchedResultsController *)fetchAllSortedBy:(NSArray *)sortDescriptors
                                   withPredicate:(NSPredicate *)searchTerm
                                        delegate:(id<NSFetchedResultsControllerDelegate>)delegate;

+ (NSArray *)findAllSortedBy:(NSArray *)sortDescriptors withPredicate:(NSPredicate *)searchTerm;

@end
