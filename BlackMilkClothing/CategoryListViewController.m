//
//  CategoryListViewController.m
//  BlackMilkClothing
//
//  Created by Juan Escudero on 4/25/13.
//  Copyright (c) 2013 Juan Escudero. All rights reserved.
//
#import "JASidePanelController.h"
#import "UIViewController+JASidePanel.h"

#import "CategoryListViewController.h"
#import "TFHpple.h"
#import "Section.h"
#import "SectionListCell.h"
#import "ProductListViewController.h"
#import "LoadingView.h"

@interface CategoryListViewController ()
{
        NSMutableArray *_objects;
        LoadingView *loader;
}
@end

@implementation CategoryListViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    loader = [LoadingView loadingViewWithParent:self.view];
    [loader startAnimating];
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self loadCategories];
    [loader stopAnimating];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)loadCategories {
    NSURL *categoriesUrl = [NSURL URLWithString:@"http://blackmilkclothing.com/"];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:categoriesUrl
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:10];
    
    [request setHTTPMethod: @"GET"];

    //[request addValue:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_3) AppleWebKit/537.31 (KHTML, like Gecko) Chrome/26.0.1410.65 Safari/537.31" forHTTPHeaderField:@"User-Agent"];
    
    NSError *requestError;
    NSURLResponse *urlResponse = nil;
    
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&requestError];

    TFHpple *categoriesParser = [TFHpple hppleWithHTMLData:response];
    
    NSString *categoriesXpathQueryString = @"//div[@id='products']/a";
    NSArray *categories_urls = [categoriesParser searchWithXPathQuery:categoriesXpathQueryString];

    NSString *categoriesTitlesXpathQueryString = @"//div[@id='products']/a/div/div/div/h2";
    NSArray *categories_titles = [categoriesParser searchWithXPathQuery:categoriesTitlesXpathQueryString];
    
    NSMutableArray *newCategories = [[NSMutableArray alloc] initWithCapacity:0];
    
    int i=0;
    
    for (TFHppleElement *element in categories_urls) {
        Section *section = [[Section alloc] init];
        [newCategories addObject:section];
        
        section.title = [[[categories_titles objectAtIndex:i] firstChild] content];
        section.url = [[element attributes] objectForKey:@"href"];
        i++;
    }
    
    _objects = newCategories;
    [self.tableView reloadData];
    [loader stopAnimating];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_objects count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    SectionListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SectionListCell" owner:self options:nil];
        cell = (SectionListCell*)[nib objectAtIndex:0];
    }
    
    Section *section = [_objects objectAtIndex:indexPath.row];
    cell.sectionTitle.text = section.title;
  
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ProductListViewController *productViewController = [[ProductListViewController alloc]initWithNibName:@"ProductListViewController" bundle:nil];
    productViewController.selectedSection = [_objects objectAtIndex:indexPath.row];
    [self.sidePanelController showCenterPanelAnimated:YES];
    self.sidePanelController.centerPanel =[[UINavigationController alloc] initWithRootViewController:productViewController];
}

@end
