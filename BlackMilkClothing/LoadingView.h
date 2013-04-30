//
//  LoadingView.h
//  BlackMilkClothing
//
//  Created by Juan Escudero on 4/30/13.
//  Copyright (c) 2013 Juan Escudero. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoadingView : UIView

@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicator;

+(LoadingView*)loadingViewWithParent:(UIView*)parent;

-(void) startAnimating;
-(void) stopAnimating;

@end
