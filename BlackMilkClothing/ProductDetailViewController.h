//
//  ProductDetailViewController.h
//  BlackMilkClothing
//
//  Created by Juan Escudero on 4/26/13.
//  Copyright (c) 2013 Juan Escudero. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Product.h"

@interface ProductDetailViewController : UIViewController<UIScrollViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) Product *selectedProduct;
@end
