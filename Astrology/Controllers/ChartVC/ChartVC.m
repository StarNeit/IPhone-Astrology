
#import "ChartVC.h"

@interface ChartVC ()<UIWebViewDelegate>
{
   
    IBOutlet UILabel *mTitle;
    IBOutlet UIWebView *mWebView;
}

@property double spendTime;
@property NSTimer *timer;
@end

@implementation ChartVC
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationController.navigationBarHidden = YES;
    mTitle.text = self.place_name;
    
    [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Loading..." animated:YES];

    //timer
    self.spendTime = 0;
    SEL mySelector = @selector(myTimerCallback:);
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:mySelector userInfo:nil repeats:YES];

    
    NSLog(self.url);
    
//    NSURL *url2 = [NSURL URLWithString:self.url];
    NSURL *url2 = [NSURL URLWithString:[self.url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
   
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url2];
    mWebView.delegate = self;
    [mWebView loadRequest:urlRequest];
    
}

-(void)myTimerCallback:(NSTimer*)timer
{
    self.spendTime ++;
    if (self.spendTime > 120){
        [self.timer invalidate];
        self.timer = nil;
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [Common showAlert:@"Please check network status."];
        
        [self.navigationController popViewControllerAnimated:YES];
        
    }
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"Error : %@",error);
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self.timer invalidate];
    self.timer = nil;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = NO;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (MFSideMenuContainerViewController *)menuContainerViewController {
    return (MFSideMenuContainerViewController *)self.navigationController.parentViewController;
}
- (IBAction)clickMenu:(id)sender {
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
        
    }];
}
@end
