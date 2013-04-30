//
//  ProductListViewController.h
//  BlackMilkClothing
//
//  Created by Juan Escudero on 4/25/13.
//  Copyright (c) 2013 Juan Escudero. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Section.h"

@interface ProductListViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) Section *selectedSection;

@end
