
#import "CreateChartVC.h"
#import "DatePicker.h"
#import <GooglePlaces/GooglePlaces.h>
#import "ChartVC.h"
#import "Chart.h"

@interface CreateChartVC ()<GMSAutocompleteViewControllerDelegate, UITextFieldDelegate>
{
   
    IBOutlet UITextField *txf_name;
    IBOutlet UILabel *tv_date;
    IBOutlet UILabel *tv_time;
    IBOutlet UILabel *tv_place;
    
    float value_transit_location_lon;
    float value_transit_location_lat;
    
    NSDate *selected_date;
    
    NSInteger hour;
    NSInteger minutes;
    NSInteger day;
    NSInteger mounth;
    NSInteger year;
    
    NSMutableData *_responseData;
    
    IBOutlet UILabel *label_remain_count;
    IBOutlet UILabel *label_no_count;
    IBOutlet UIButton *btn_shop;
    IBOutlet UIButton *btn_create;
    
    int remain_count;
}
@property DatePicker *datePicker;
#define loadNib(nibName) [[[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil] objectAtIndex:0]
@end

@implementation CreateChartVC
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
    
    remain_count = [[USER_DEFAULT objectForKey:@"remain_count"] intValue];
    if (remain_count > 0)
    {
        label_remain_count.text = [NSString stringWithFormat:@"Number of charts remaining: %d", remain_count];
        
        label_no_count.hidden = YES;
        label_remain_count.hidden = NO;
        btn_create.hidden = NO;
        btn_shop.hidden = YES;
    }else{
        
        label_no_count.hidden = NO;
        label_remain_count.hidden = YES;
        btn_create.hidden = YES;
        btn_shop.hidden = NO;
    }
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


- (IBAction)clickCalendar:(id)sender {
    if (self.datePicker == nil){
        self.datePicker = loadNib(@"DatePicker");
    }
    self.datePicker.idx = 2;
    [self.datePicker setFrame:self.view.frame];
    self.datePicker.datePicker.datePickerMode = UIDatePickerModeDate;
    self.datePicker.delegate = self;
    [self.datePicker.datePicker setDate:[NSDate date]];
    [self.datePicker.subDatePicker setFrame:CGRectMake(0,[[UIScreen mainScreen] bounds].size.height/2/*-self.datePicker.subDatePicker.frame.size.height*/, [[UIScreen mainScreen] bounds].size.width,
                                                       [[UIScreen mainScreen] bounds].size.height / 2)];
    
    [[Common appDelegate].window addSubview:self.datePicker];
}
- (IBAction)clickClock:(id)sender {
    if (self.datePicker == nil){
        self.datePicker = loadNib(@"DatePicker");
    }
    self.datePicker.idx = 1;
    [self.datePicker setFrame:self.view.frame];
    self.datePicker.datePicker.datePickerMode = UIDatePickerModeTime;
    self.datePicker.delegate = self;
    [self.datePicker.datePicker setDate:[NSDate date]];
    [self.datePicker.subDatePicker setFrame:CGRectMake(0,[[UIScreen mainScreen] bounds].size.height-self.datePicker.subDatePicker.frame.size.height, [[UIScreen mainScreen] bounds].size.width,
                                                       [[UIScreen mainScreen] bounds].size.height / 2)];
    
    [[Common appDelegate].window addSubview:self.datePicker];
    
}
- (IBAction)clickMaker:(id)sender {
    GMSAutocompleteViewController *acController = [[GMSAutocompleteViewController alloc] init];
    acController.delegate = self;
    [self presentViewController:acController animated:YES completion:nil];
}




// Handle the user's selection.
- (void)viewController:(GMSAutocompleteViewController *)viewController
didAutocompleteWithPlace:(GMSPlace *)place {
    [self dismissViewControllerAnimated:YES completion:nil];
    // Do something with the selected place.
    NSLog(@"Place name %@", place.name);
    NSLog(@"Place address %@", place.formattedAddress);
    NSLog(@"Place attributions %@", place.attributions.string);
    
    
    tv_place.text = place.name;
    value_transit_location_lon = place.coordinate.longitude;
    value_transit_location_lat = place.coordinate.latitude;
}

- (void)viewController:(GMSAutocompleteViewController *)viewController
didFailAutocompleteWithError:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
    // TODO: handle the error.
    NSLog(@"Error: %@", [error description]);
}

// User canceled the operation.
- (void)wasCancelled:(GMSAutocompleteViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// Turn the network activity indicator on and off again.
- (void)didRequestAutocompletePredictions:(GMSAutocompleteViewController *)viewController {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)didUpdateAutocompletePredictions:(GMSAutocompleteViewController *)viewController {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}


- (IBAction)clickShop:(id)sender {
    AppDelegate *delegate = [Common appDelegate];
    [delegate openShop];
}


- (IBAction)clickCreateChart:(id)sender {
    if ([Common trimString:txf_name.text].length == 0)
    {
        [Common showAlert2:@"Name is required" title:@"Error"];
        return;
    }
    if (tv_date.text.length == 0)
    {
        [Common showAlert2:@"Date is required" title:@"Error"];
        return;
    }
    if (tv_time.text.length == 0)
    {
        [Common showAlert2:@"Time is required" title:@"Error"];
        return;
    }
    if (tv_place.text.length == 0)
    {
        [Common showAlert2:@"Place is required" title:@"Error"];
        return;
    }
    
    //---Calculate timestamp---//
    NSDateFormatter *mmddccyy = [[NSDateFormatter alloc] init];
    mmddccyy.timeStyle = NSDateFormatterNoStyle;
    mmddccyy.dateFormat = @"MM/dd/yyyy HH:mm";
    
    NSDate *d = [mmddccyy dateFromString:[NSString stringWithFormat:@"%d/%d/%d %d:%d", mounth, day, year, hour, minutes]];
    long timestamp = (long)[d timeIntervalSince1970];
    
    
    //---Calcualte RawOffset, DstOffset---//
    [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Loading..." animated:YES];
    NSString *link_url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/timezone/json?location=%f,%f&timestamp=%ld&key=%@",
                          value_transit_location_lat, value_transit_location_lon, timestamp, @"AIzaSyBhapEFIM1EVtzokYZMV_9AtOs_2sy6614"];
    NSURL *url = [NSURL URLWithString:[link_url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLCacheStorageNotAllowed
                                                       timeoutInterval:30.0];
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
}




-(void) removeDateTimePicker
{
    [self.datePicker removeFromSuperview];
    if (self.datePicker.idx == 1)
    {
        tv_time.text = @"";
    }else if (self.datePicker.idx == 2)
    {
        tv_date.text = @"";
    }
}

-(void) showDateTimePicker:(NSDate *)date
{
    NSDateFormatter *formatter;
    NSString        *dateString;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:date];
    
    
    if (self.datePicker.idx == 1)
    {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"HH:mm"];
        dateString = [formatter stringFromDate:date];
        tv_time.text = dateString;
        
        hour = [components hour];
        minutes = [components minute];
        
        
    }else if (self.datePicker.idx == 2)
    {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"dd/MM/yyyy"];
        dateString = [formatter stringFromDate:date];
        tv_date.text = dateString;
        
        day = [components day];
        mounth = [components month];
        year = [components year];
    }
    
    [self.datePicker removeFromSuperview];
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
    
    
    //in case, no data in database
    NSString *value_chart_style = @"NORTH_INDIAN";
    int value_ayanamsa = 1;
    NSString *value_node = @"MEAN_NODE";
   
    
    //---Value Setting---//
    if ([USER_DEFAULT objectForKey:@"setting_chart_style"] != [NSNull null]
        && [[USER_DEFAULT objectForKey:@"setting_chart_style"] length] > 0)
    {
        value_chart_style = [USER_DEFAULT objectForKey:@"setting_chart_style"];
    }
    if ([USER_DEFAULT objectForKey:@"setting_ayanamsa"] != [NSNull null]
        && [[USER_DEFAULT objectForKey:@"setting_ayanamsa"] length] > 0)
    {
        value_ayanamsa = [[USER_DEFAULT objectForKey:@"setting_ayanamsa"] intValue];
    }
    if ([USER_DEFAULT objectForKey:@"setting_node"] != [NSNull null]
        && [[USER_DEFAULT objectForKey:@"setting_node"] length] > 0)
    {
        value_node = [USER_DEFAULT objectForKey:@"setting_node"];
    }
    
    
    //---Save Chart---//
    Chart *chart = [Chart create];
    chart.chart_name = [Common trimString:txf_name.text];
    chart.date = tv_date.text;
    chart.time = tv_time.text;
    chart.place_name = tv_place.text;
    chart.place_latitude = [NSString stringWithFormat:@"%f", value_transit_location_lat];
    chart.place_longitude = [NSString stringWithFormat:@"%f", value_transit_location_lon];
    chart.dstOffset = [NSString stringWithFormat:@"%@", dstOffset];
    chart.rawOffset = [NSString stringWithFormat:@"%@", rawOffset];
    [chart save];
    
    //---Decrease remain count---//
    remain_count --;
    
    if (remain_count <= 0)
        remain_count = 0;
    
    
    [USER_DEFAULT setValue:[NSString stringWithFormat:@"%d", remain_count] forKey:@"remain_count"];
    
    //---Showing Chart---//
    ChartVC *vc = [[ChartVC alloc] init];
    vc.url = [NSString stringWithFormat:@"http://www.astrologersheaven.com/mobile/android/horoscope?name=%@&date=%@&time=%@&place=%@&latitude=%f&longitude=%f&rawOffset=%@&dstOffset=%@&chartStyle=%@&ayanamsa=%d&node=%@", [Common trimString:txf_name.text], tv_date.text, tv_time.text, tv_place.text, value_transit_location_lat, value_transit_location_lon, rawOffset, dstOffset, value_chart_style, value_ayanamsa, value_node];
    vc.place_name = [Common trimString:txf_name.text];
    [self.navigationController pushViewController:vc animated:NO];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:true];
   return YES;
}
@end
