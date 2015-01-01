//
//  ShoppingItem.h
//  Shopping_Portokalis_Christopher
//
//  Created by PORTOKALIS CHRISTOPHER G on 9/23/14.
//  Copyright (c) 2014 PORTOKALIS CHRISTOPHER G. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShoppingItem : NSObject

    @property (nonatomic) int itemCount;
    @property (strong, nonatomic) NSString* itemName;
    @property (nonatomic) BOOL checked;

+(ShoppingItem*) itemWithName: (NSString*) name;

@end
