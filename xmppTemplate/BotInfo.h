//
//  BotInfo.h
//  hg-ios-patch-display
//
//  Created by Anthony Perritano on 10/20/13.
//  Copyright (c) 2013 Learning Technologies Group. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface BotInfo : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * xmpp;

@end
