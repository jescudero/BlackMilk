//
//  ProductDetailViewController.m
//  BlackMilkClothing
//
//  Created by Juan Escudero on 4/26/13.
//  Copyright (c) 2013 Juan Escudero. All rights reserved.
//

#import "ProductDetailViewController.h"
#import "TFHpple.h"
#import "LoadingView.h"
#import <QuartzCore/QuartzCore.h>

@interface ProductDetailViewController (){

    BOOL pageControlBeingUsed;
    UIActivityIndicatorView *activityIndicator;
    UIView *overlayView;
    BOOL isImageExpanded;
    LoadingView *loader;
}

@property (weak, nonatomic) IBOutlet UILabel *productTitle;
@property (weak, nonatomic) IBOutlet UILabel *productPrice;
@property (weak, nonatomic) IBOutlet UITextView *productDescription;
@property (weak, nonatomic) IBOutlet UIButton *addToCartButton;
@property (weak, nonatomic) IBOutlet UIScrollView* scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl* pageControl;
@property (nonatomic, weak) IBOutlet UIScrollView * scrollViewContent;

- (IBAction)changePage:(id)sender;

@end

@implementation ProductDetailViewController


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
    self.navigationItem.title = @"BlackMilk";

    loader = [LoadingView loadingViewWithParent:self.view];
    [loader startAnimating];
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self loadProduct];
    
    //self.scrollView.frame = CGRectMake(0, 0, 150, 250);
    
    NSLog(NSStringFromCGRect(self.scrollView.frame));
    
    for (int i = 0; i < self.selectedProduct.images.count; i++) {
        CGRect frame;
        frame.origin.x = self.scrollView.frame.size.width * i;
        frame.origin.y = 0; //self.scrollView.frame.origin.y;
        frame.size = self.scrollView.frame.size;
        
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:frame];
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.selectedProduct.images[i]]]];
        imageView.image = image;
        
        NSLog(NSStringFromCGRect(imageView.frame));

        
        NSLog(@"%@", NSStringFromCGSize(imageView.image.size));
        
        
        imageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *pgr = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)];
        pgr.delegate = self;
        [imageView addGestureRecognizer:pgr];
        
        [self.scrollView addSubview:imageView];
    }
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * self.selectedProduct.images.count, self.scrollView.frame.size.height);
    
    self.pageControl.numberOfPages = self.selectedProduct.images.count;
    
    CGSize expectedLabelSize =[self.selectedProduct.description sizeWithFont:self.productDescription.font constrainedToSize:CGSizeMake(self.productDescription.frame.size.width,9999)];
    
    CGRect newFrame = self.productDescription.frame;
    newFrame.size.height = expectedLabelSize.height;
    self.productDescription.frame = newFrame;
                               
    self.productDescription.text = self.selectedProduct.description;

    self.productDescription.layer.shadowColor = [[UIColor grayColor] CGColor];
    self.productDescription.layer.shadowOffset = CGSizeMake(2.0f, 2.0f);
    self.productDescription.layer.shadowOpacity = 1.0f;
    self.productDescription.layer.shadowRadius = 1.0f;
    self.productDescription.textColor  = [UIColor blackColor];

    //here is important!!!!

    self.productDescription.backgroundColor = [UIColor clearColor];
    
    self.productPrice.frame = CGRectMake(self.productPrice.frame.origin.x, self.productDescription.frame.origin.y + self.productDescription.frame.size.height + 25, self.productPrice.frame.size.width, self.productPrice.frame.size.height);
    
    self.productPrice.text = [NSString stringWithFormat:@"$ %@", self.selectedProduct.price];
   
    self.addToCartButton.frame = CGRectMake(self.addToCartButton.frame.origin.x, self.productPrice.frame.origin.y + self.productPrice.frame.size.height + 25, self.addToCartButton.frame.size.width, self.addToCartButton.frame.size.height);
  
    
    [self.scrollViewContent setContentSize:CGSizeMake(320, self.addToCartButton.frame.origin.y + self
                                                      .addToCartButton.frame.size.height + 25)];
    
    [loader stopAnimating];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadProduct {
    NSURL *productURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://blackmilkclothing.com/%@", self.selectedProduct.url]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:productURL
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:10];
    
    [request setHTTPMethod: @"GET"];
    
    [request addValue:@"Mozilla/5.0 (iPhone; U; CPU like Mac OS X; en) AppleWebKit/420+ (KHTML, like Gecko) Version/3.0 Mobile/1A543a Safari/419.3" forHTTPHeaderField:@"User-Agent"];
    
    NSError *requestError;
    NSURLResponse *urlResponse = nil;
    
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&requestError];
    
    TFHpple *productsParser = [TFHpple hppleWithHTMLData:response];
    
    NSString *productIMGXpathQueryString = @"//div[@class='swipe images clearfix']/div";
    NSArray *product_imgs = [productsParser searchWithXPathQuery:productIMGXpathQueryString];
    
    self.productTitle.text = self.selectedProduct.title;
    
    NSMutableArray *images = [[NSMutableArray alloc]init];
    for (int i = 0; i < [product_imgs count] ; i++)
    {
        [images addObject:[[[[[product_imgs objectAtIndex:i] children] objectAtIndex:1] attributes] valueForKey:@"src"]];
        
    }

    self.selectedProduct.images = images;
    NSString *productDescription = @"//div[@class='description p']//text()";
    NSArray *product_description = [productsParser searchWithXPathQuery:productDescription];
    
    self.selectedProduct.description = @"";
    
    for (int i= 3; i < product_description.count ; i++)
    {
        self.selectedProduct.description = [NSString stringWithFormat:@"%@ %@", self.selectedProduct.description,  (NSString *)[[product_description objectAtIndex:i]  content] ] ;
    }
    
    
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    // Update the page when more than 50% of the previous/next page is visible
    CGFloat pageWidth = self.scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
}

- (IBAction)changePage {
    // update the scroll view to the appropriate page
    CGRect frame;
    frame.origin.x = self.scrollView.frame.size.width * self.pageControl.currentPage;
    frame.origin.y = self.scrollView.frame.origin.y;
    frame.size = self.scrollView.frame.size;
    [self.scrollView scrollRectToVisible:frame animated:YES];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    pageControlBeingUsed = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    pageControlBeingUsed = NO;
}

-(void)handleTap:(UITapGestureRecognizer *)tapGestureRecognizer
{
    if (!isImageExpanded)
    {
        UIImageView *imageView = [self.scrollView.subviews objectAtIndex:self.pageControl.currentPage];
        
        UIImageView *newImageView = [[UIImageView alloc]initWithImage:imageView.image];
        newImageView.frame = CGRectMake(0, 0, 320, 480);
        newImageView.gestureRecognizers = imageView.gestureRecognizers;
    
        
        // first reduce the view to 1/100th of its original dimension
        CGAffineTransform trans = CGAffineTransformScale(self.view.transform, 0.01, 0.01);
        self.view.transform = trans;	// do it instantly, no animation
        [self.view addSubview:newImageView];
        // now return the view to normal dimension, animating this tranformation
        [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.view.transform = CGAffineTransformScale(self.view.transform, 100.0, 100.0);
                         }
                         completion:nil];
    }
}


@end
