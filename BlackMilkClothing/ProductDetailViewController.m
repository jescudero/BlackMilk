//
//  ProductDetailViewController.m
//  BlackMilkClothing
//
//  Created by Juan Escudero on 4/26/13.
//  Copyright (c) 2013 Juan Escudero. All rights reserved.
//

#import "ProductDetailViewController.h"
#import "TFHpple.h"
#import <QuartzCore/QuartzCore.h>

@interface ProductDetailViewController (){

    BOOL pageControlBeingUsed;
    UIActivityIndicatorView *activityIndicator;
    UIView *overlayView;
    BOOL isImageExpanded;
    
}

@property (weak, nonatomic) IBOutlet UILabel *productTitle;
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

    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicator.alpha = 1.0;
    activityIndicator.center = CGPointMake(160, 240);
    activityIndicator.hidesWhenStopped = YES;
    [self.view addSubview:activityIndicator];
    [activityIndicator startAnimating];

}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self loadProduct];
    
    for (int i = 0; i < self.selectedProduct.images.count; i++) {
        CGRect frame;
        frame.origin.x = self.scrollView.frame.size.width * i;
        frame.origin.y = self.scrollView.frame.origin.y;
        frame.size = self.scrollView.frame.size;
        
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:frame];
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.selectedProduct.images[i]]]];
        imageView.image = image;
        
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
    
    self.addToCartButton.frame = CGRectMake(self.addToCartButton.frame.origin.x, self.productDescription.frame.origin.y + self.productDescription.frame.size.height + 25, self.addToCartButton.frame.size.width, self.addToCartButton.frame.size.height);
   
    [self.scrollViewContent setContentSize:CGSizeMake(320, self.addToCartButton.frame.origin.y + self
                                                      .addToCartButton.frame.size.height + 25)];
    

    self.productDescription.layer.shadowColor = [[UIColor whiteColor] CGColor];
    self.productDescription.layer.shadowOffset = CGSizeMake(2.0f, 2.0f);
    self.productDescription.layer.shadowOpacity = 1.0f;
    self.productDescription.layer.shadowRadius = 1.0f;
    self.productDescription.textColor  = [UIColor blackColor];

    //here is important!!!!
    self.productDescription.backgroundColor = [UIColor clearColor];
    
    [activityIndicator stopAnimating];

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
    
    for (int i= 2; i < product_description.count ; i++)
    {
        self.selectedProduct.description = [NSString stringWithFormat:@"%@ %@", self.selectedProduct.description,  [[product_description objectAtIndex:i]  content]] ;
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
    
        [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionShowHideTransitionViews animations:^{
            overlayView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
            overlayView.backgroundColor = [UIColor colorWithWhite:0 alpha:.5];
            [overlayView addSubview:newImageView];
        
            [self.view.window addSubview:overlayView];

        }completion:^(BOOL finished){
            isImageExpanded = TRUE;
        }];
    }
    else
    {
        [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionShowHideTransitionViews animations:^{
            [overlayView removeFromSuperview];
    
        }completion:^(BOOL finished){
            isImageExpanded = FALSE;
        }];
    }
}

@end
