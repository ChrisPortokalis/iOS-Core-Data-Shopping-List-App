//
//  ShoppingItem.m
//  Shopping_Portokalis_Christopher
//
//  Created by PORTOKALIS CHRISTOPHER G on 9/23/14.
//  Copyright (c) 2014 PORTOKALIS CHRISTOPHER G. All rights reserved.
//

#import "ShoppingItem.h"

@interface ShoppingItem () 



@end

@implementation ShoppingItem

    +(ShoppingItem*)itemWithName:(NSString*)name
    {
        ShoppingItem* st = [ShoppingItem alloc];
        
        st.itemName = name;
        st.checked = NO;
        st.itemCount = 1;
        
        return st;
    }

- (NSString *) description
{
    return [NSString stringWithFormat: @"%@",
            self.itemName];
}

@end
