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

#import "NSManagedObject+helpers.h"
#import "CoreData+MagicalRecord.h"


@implementation NSManagedObject (helpers)

+ (NSFetchRequest *)requestAllSortedBy:(NSArray *)sortDescriptors withPredicate:(NSPredicate *)searchTerm inContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [self MR_requestAllInContext:context];
    if (searchTerm) {
        [request setPredicate:searchTerm];
    }
    
    [request setFetchBatchSize:kMagicalRecordDefaultBatchSize];
    [request setSortDescriptors:sortDescriptors];
    
    return request;
}

+ (NSFetchedResultsController *)fetchAllSortedBy:(NSArray *)sortDescriptors withPredicate:(NSPredicate *)searchTerm delegate:(id<NSFetchedResultsControllerDelegate>)delegate {
	NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];
	NSFetchRequest *request = [self requestAllSortedBy:sortDescriptors
										 withPredicate:searchTerm
											 inContext:context];
	
	NSFetchedResultsController *controller =
	[[NSFetchedResultsController alloc] initWithFetchRequest:request
										managedObjectContext:context
										  sectionNameKeyPath:nil
												   cacheName:nil];
	controller.delegate = delegate;
	
	[self MR_performFetch:controller];
	return controller;
}

+ (NSArray *)findAllSortedBy:(NSArray *)sortDescriptors {
    NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];
    NSFetchRequest *request = [self requestAllSortedBy:sortDescriptors
                                         withPredicate:nil
                                             inContext:context];
    
    return [self MR_executeFetchRequest:request inContext:context];
}

@end
