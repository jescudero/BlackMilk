//
//  ProductListViewController.m
//  BlackMilkClothing
//
//  Created by Juan Escudero on 4/25/13.
//  Copyright (c) 2013 Juan Escudero. All rights reserved.
//

#import "ProductListViewController.h"
#import "Section.h"
#import "TFHpple.h"
#import "Product.h"
#import "ProductListCell.h"
#import "ProductDetailViewController.h"

@interface ProductListViewController ()
{
           NSMutableArray *_objects;
}

@property (nonatomic, strong) IBOutlet UITableView *tableView;

@end

@implementation ProductListViewController

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
    self.navigationItem.title = self.selectedSection.title;

    [self loadProducts];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadProducts {
    NSURL *categoriesUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://blackmilkclothing.com/%@", self.selectedSection.url]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:categoriesUrl
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:10];
    
    [request setHTTPMethod: @"GET"];
    
    //[request addValue:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_3) AppleWebKit/537.31 (KHTML, like Gecko) Chrome/26.0.1410.65 Safari/537.31" forHTTPHeaderField:@"User-Agent"];
    
    NSError *requestError;
    NSURLResponse *urlResponse = nil;
    
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&requestError];
    
    TFHpple *productsParser = [TFHpple hppleWithHTMLData:response];
    
    NSString *productIMGXpathQueryString = @"//div[@id='products']/div/a/div/div/img";
    NSArray *product_imgs = [productsParser searchWithXPathQuery:productIMGXpathQueryString];
    
    
    NSString *productURLXpathQueryString = @"//div[@id='products']/div/a";
    NSArray *product_urls = [productsParser searchWithXPathQuery:productURLXpathQueryString];
    
    NSString *productXpathQueryString = @"//div[@id='products']/div/a/div[@class='details dtable']/div";
    NSArray *product_details = [productsParser searchWithXPathQuery:productXpathQueryString];

    NSString *sizeXpathQueryString = @"//div[@id='products']/div/a/div[@class='details dtable']/div/div";
    NSArray *size_details = [productsParser searchWithXPathQuery:sizeXpathQueryString];

    NSMutableArray *products = [[NSMutableArray alloc] initWithCapacity:0];
    
    int i=0;
    
    for (TFHppleElement *element in product_details) {
        Product *product = [[Product alloc] init];
        [products addObject:product];
        
        product.title = [[[[element children]objectAtIndex:1] firstChild] content];
        NSString *available = @"";
        
        for (int i=0;  i < [[[size_details objectAtIndex:0] children] count]; i++) {
            
            if (![[[[size_details objectAtIndex:0] children] objectAtIndex:i] content])
            {
                available = [NSString stringWithFormat:@"%@ %@",available,[[[[[[size_details objectAtIndex:0] children] objectAtIndex:i] children] objectAtIndex:0] content] ];
            }
        }
        
        product.availableSize = [NSString stringWithFormat:@"Available: %@", available];
        product.price = [[[[[element children]objectAtIndex:5] firstChild] firstChild]content];
        product.thumbUrl = [[[product_imgs objectAtIndex:i] attributes] valueForKey:@"src"];
        product.url = [[[product_urls objectAtIndex:i] attributes] valueForKey:@"href"];
        i++;
    }
    
    _objects = products;
    [self.tableView reloadData];
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
    static NSString *CellIdentifier = @"ProdCell";
    
    ProductListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ProductListCell" owner:self options:nil];
        cell = (ProductListCell*)[nib objectAtIndex:0];
    }
    
    Product *product = [_objects objectAtIndex:indexPath.row];
    cell.title.text = product.title;
    cell.imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:product.thumbUrl]]];
    cell.price.text = product.price;
    cell.availlableSize.text = product.availableSize;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ProductDetailViewController *productDetail = [[ProductDetailViewController alloc]init];
    productDetail.selectedProduct = [_objects objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:productDetail animated:YES];
}

@end
