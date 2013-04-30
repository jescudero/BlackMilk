//
//  MainScreenViewController.m
//  BlackMilkClothing
//
//  Created by Juan Escudero on 4/25/13.
//  Copyright (c) 2013 Juan Escudero. All rights reserved.
//

#import "MainScreenViewController.h"
#import "Section.h"

@interface MainScreenViewController ()

@end

@implementation MainScreenViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"BlackMilk";
    [[UINavigationBar appearance] setTintColor:[UIColor blackColor]];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
