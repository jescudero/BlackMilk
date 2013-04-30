//
//  LoadingView.m
//  BlackMilkClothing
//
//  Created by Juan Escudero on 4/30/13.
//  Copyright (c) 2013 Juan Escudero. All rights reserved.
//

#import "LoadingView.h"

@interface LoadingView ()

@property (nonatomic, strong) IBOutlet UIView *view;

@end


@implementation LoadingView

+(LoadingView*)loadingViewWithParent:(UIView*)parent
{
    LoadingView *view = [[self alloc] initWithFrame:parent.bounds];
    [parent addSubview:view];
    
    return view;
}

- (void)initialize
{
    
    [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([LoadingView class]) owner:self options:nil];
    self.view.frame = self.bounds;
    [self addSubview:self.view];
    
    [self stopAnimating];
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        [self initialize];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self initialize];
}

-(void) startAnimating
{
    [[self superview] bringSubviewToFront:self];
    
    [self setHidden:NO];
    [self setAlpha:0.5f];
    [self.activityIndicator startAnimating];
}

-(void) stopAnimating
{
    [self setHidden:YES];
    [self setAlpha:1.0];
    [self.activityIndicator stopAnimating];
}


@end
