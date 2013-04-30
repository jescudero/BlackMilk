//
//  Product.h
//  BlackMilkClothing
//
//  Created by Juan Escudero on 4/25/13.
//  Copyright (c) 2013 Juan Escudero. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Product : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *availableSize;
@property (nonatomic, copy) NSString *price;
@property (nonatomic, copy) NSString *thumbUrl;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *description;
@property (nonatomic, copy) NSMutableArray *images;

@end
