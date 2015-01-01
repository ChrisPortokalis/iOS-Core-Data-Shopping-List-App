//
//  ShoppingItemEntity.h
//  Shopping_Portokalis_Christopher
//
//  Created by Chris Portokalis on 11/8/14.
//  Copyright (c) 2014 PORTOKALIS CHRISTOPHER G. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ChoicesEntity;

@interface ShoppingItemEntity : NSManagedObject

@property (nonatomic, retain) NSNumber * checked;
@property (nonatomic, retain) NSNumber * itemCount;
@property (nonatomic, retain) NSString * itemName;
@property (nonatomic, retain) ChoicesEntity *itemsToChoice;

@end
