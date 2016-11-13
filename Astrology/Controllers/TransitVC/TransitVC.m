
#import "TransitVC.h"
#import "ChartVC.h"

@interface TransitVC ()
{
    NSString *latitude;
    NSString *longitude;
    NSString *name;
    NSString *transitDate;
    NSString *time;
    NSString *place;
    
    NSString *chart_style;
    NSString *node;
    int ayanamsa;
    
    NSMutableData *_responseData;
}
@end

@implementation TransitVC
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
    self.title = @"";
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = NO;
    
    if ([USER_DEFAULT objectForKey:@"setting_place_name"] != [NSNull null]
        && [[USER_DEFAULT objectForKey:@"setting_place_name"] length] > 0)
    {
        latitude = [USER_DEFAULT objectForKey:@"setting_place_lat"];
        
        longitude = [USER_DEFAULT objectForKey:@"setting_place_lon"];
        
        name = @"Transit";
        
        
        
        NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"dd/MM/yyyy"];
        transitDate = [dateFormatter stringFromDate:[NSDate date]];
        
        [dateFormatter setDateFormat:@"HH:mm"];
        time = [dateFormatter stringFromDate:[NSDate date]];
        
        place = [USER_DEFAULT objectForKey:@"setting_place_name"];
     
        
        
        chart_style = @"NORTH_INDIAN";
        
        node = @"MEAN_NODE";
        
        ayanamsa = 1;
        
        //---Value Setting---//
        if ([USER_DEFAULT objectForKey:@"setting_chart_style"] != [NSNull null]
            && [[USER_DEFAULT objectForKey:@"setting_chart_style"] length] > 0)
        {
            chart_style = [USER_DEFAULT objectForKey:@"setting_chart_style"];
        }
        if ([USER_DEFAULT objectForKey:@"setting_ayanamsa"] != [NSNull null]
            && [[USER_DEFAULT objectForKey:@"setting_ayanamsa"] length] > 0)
        {
            ayanamsa = [[USER_DEFAULT objectForKey:@"setting_ayanamsa"] intValue];
        }
        if ([USER_DEFAULT objectForKey:@"setting_node"] != [NSNull null]
            && [[USER_DEFAULT objectForKey:@"setting_node"] length] > 0)
        {
            node = [USER_DEFAULT objectForKey:@"setting_node"];
        }
        
        
        //---Calculate timestamp---//
        long timestamp = (long)[[NSDate date] timeIntervalSince1970];
        
        
        //---Calcualte RawOffset, DstOffset---//
        [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Loading..." animated:YES];
        NSString *link_url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/timezone/json?location=%@,%@&timestamp=%ld&key=%@",
                              latitude, longitude, timestamp, @"AIzaSyBhapEFIM1EVtzokYZMV_9AtOs_2sy6614"];
        NSURL *url = [NSURL URLWithString:[link_url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                               cachePolicy:NSURLCacheStorageNotAllowed
                                                           timeoutInterval:30.0];
        [[NSURLConnection alloc] initWithRequest:request delegate:self];
        
    }else{
        UIAlertView *errorAlert = [[UIAlertView alloc]
                                   initWithTitle:NSLocalizedString(@"",nil) message:NSLocalizedString(@"Enter Transit Location",nil)
                                   delegate:self cancelButtonTitle:NSLocalizedString(@"Proceed",nil) otherButtonTitles:nil];
        errorAlert.tag = 3000;
        [errorAlert show];
    }
}
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 3000)
    {
        if (buttonIndex == 0)
        {
            AppDelegate *app = [Common appDelegate];
            [app openSettings];
        }
    }
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


//---NSURLConnection Delegate Methods---//
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    _responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse
{
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    NSString *tmp = [[NSString alloc] initWithData:_responseData encoding:NSASCIIStringEncoding];
    NSArray *result = [NSJSONSerialization JSONObjectWithData:[tmp dataUsingEncoding:NSUTF8StringEncoding]
                                                      options:0 error:NULL];
    
    NSString *dstOffset = [result valueForKey:@"dstOffset"];
    NSString *rawOffset = [result valueForKey:@"rawOffset"];
    
    
    //---Showing Chart---//
    ChartVC *vc = [[ChartVC alloc] init];
    vc.url = [NSString stringWithFormat:@"http://www.astrologersheaven.com/mobile/android/horoscope?name=%@&date=%@&time=%@&place=%@&latitude=%@&longitude=%@&rawOffset=%@&dstOffset=%@&chartStyle=%@&ayanamsa=%d&node=%@", name, transitDate, time, place, latitude, longitude, rawOffset, dstOffset, chart_style, ayanamsa, node];
    vc.place_name = [Common trimString:name];
    [self.navigationController pushViewController:vc animated:NO];
}

@end
