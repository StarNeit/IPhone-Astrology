
#import "HomeVC.h"
#import "Chart.h"
#import "ChartVC.h"

@interface HomeVC ()
{
   
    IBOutlet UITableView *tbSavedChart;
    NSMutableArray *saved_charts;
}
@end

@implementation HomeVC
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
    
    
    tbSavedChart.allowsMultipleSelectionDuringEditing = NO;
    
    // all Chart entities from the database
    
    saved_charts = [[NSMutableArray alloc] init];
    NSArray *temp_saved_charts = [Chart all];
    for (int i = 0; i < [temp_saved_charts count]; i ++)
    {
        if (i < 5){
            saved_charts[i] = temp_saved_charts[[temp_saved_charts count] - i - 1];
        }else{
            break;
        }
    }
    
    tbSavedChart.tableFooterView = [[UIView alloc] init];
    
    if ([saved_charts count] > 2)
    {
        tbSavedChart.hidden = NO;
    }else{
        tbSavedChart.hidden = YES;
    }
    
    [self setNeedsStatusBarAppearanceUpdate];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
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

//---Table View---
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (saved_charts == nil)
        return 0;
    return [saved_charts count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (IS_IPAD) return 150;
    return 60;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //defaultCellIdentifier
    NSString *cellIdentifier = @"defaultCellIdentifier";
    UITableViewCell *cell = [tbSavedChart dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    Chart *chart = [saved_charts objectAtIndex:indexPath.row];
    cell.textLabel.text = chart.chart_name;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Chart *chart = [saved_charts objectAtIndex:indexPath.row];
    
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
    
    
    //---Showing Chart---//
    ChartVC *vc = [[ChartVC alloc] init];
    vc.url = [NSString stringWithFormat:@"http://www.astrologersheaven.com/mobile/android/horoscope?name=%@&date=%@&time=%@&place=%@&latitude=%@&longitude=%@&rawOffset=%@&dstOffset=%@&chartStyle=%@&ayanamsa=%d&node=%@", chart.chart_name, chart.date, chart.time, chart.place_name, chart.place_latitude, chart.place_longitude, chart.rawOffset, chart.dstOffset, value_chart_style, value_ayanamsa, value_node];
    vc.place_name = chart.chart_name;
    [self.navigationController pushViewController:vc animated:NO];
    
}

//---User Interface---//
- (IBAction)clickSettings:(id)sender {
    AppDelegate *delegate = [Common appDelegate];
    [delegate openSettings];
}
- (IBAction)clickCreateNew:(id)sender {
    AppDelegate *delegate = [Common appDelegate];
    [delegate openCreateChart];
}
- (IBAction)clickHelp:(id)sender {
    AppDelegate *delegate = [Common appDelegate];
    [delegate openHelp];
}

@end
