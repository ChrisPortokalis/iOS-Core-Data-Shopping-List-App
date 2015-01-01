//
//  ChoicesEntity.h
//  Shopping_Portokalis_Christopher
//
//  Created by Chris Portokalis on 11/8/14.
//  Copyright (c) 2014 PORTOKALIS CHRISTOPHER G. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ShoppingItemEntity;

@interface ChoicesEntity : NSManagedObject

@property (nonatomic, retain) NSString * choiceCategory;
@property (nonatomic, retain) NSString * choiceName;
@property (nonatomic, retain) NSString * choiceSection;
@property (nonatomic, retain) ShoppingItemEntity *choiceToItem;

@end
