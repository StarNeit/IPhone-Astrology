
#import "SavedChartVC.h"
#import "Chart.h"
#import "ChartVC.h"
#import "MGSwipeTableCell.h"

@interface SavedChartVC ()
{
   
    IBOutlet UITableView *tbSavedChart;
    NSArray *saved_charts;
    int active_record;
}
@end

@implementation SavedChartVC
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
    
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    
    tbSavedChart.allowsMultipleSelectionDuringEditing = NO;
    
    // all Chart entities from the database
    saved_charts = [Chart all];
    
    tbSavedChart.tableFooterView = [[UIView alloc] init];
    
    if ([saved_charts count] == 0)
    {
        [Common showAlert:@"No saved charts"];
    }
}


//--------
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

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //---add code here for when you hit delete---//
        UIAlertView *errorAlert = [[UIAlertView alloc]
                                   initWithTitle:NSLocalizedString(@"Astroy",nil) message:NSLocalizedString(@"Are you sure to delete this chart?",nil)
                                   delegate:self cancelButtonTitle:NSLocalizedString(@"No",nil) otherButtonTitles:nil];
        errorAlert.tag = 2000;
        [errorAlert addButtonWithTitle:NSLocalizedString(@"Yes",nil)];
        [errorAlert show];
        
        active_record = indexPath.row;
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 2000)
    {
        if (buttonIndex == 0) //no
        {
            
        }else if (buttonIndex == 1) //yes
        {
            int k = 0;
            for(Chart *chart in [Chart all]) {
                if (k == active_record)
                {
                    [chart delete];
                    break;
                }
                k++;
            }
            saved_charts = [Chart all];
            [tbSavedChart reloadData];
        }
    }
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
    //defaultCellIdentifier
    NSString *cellIdentifier = @"defaultCellIdentifier";
    UITableViewCell *cell = [tbSavedChart dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    Chart *chart = [saved_charts objectAtIndex:indexPath.row];
    cell.textLabel.text = chart.chart_name;
    return cell;*/
    
    static NSString * reuseIdentifier = @"programmaticCell";
    MGSwipeTableCell * cell = [tbSavedChart dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell) {
        cell = [[MGSwipeTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    }
    
    
    Chart *chart = [saved_charts objectAtIndex:indexPath.row];
    
    cell.textLabel.text = chart.chart_name;
    cell.delegate = self; //optional
    
    //configure right buttons
    cell.rightButtons = @[[MGSwipeButton buttonWithTitle:@"Delete" backgroundColor:[UIColor redColor]]];
    cell.rightSwipeSettings.transition = MGSwipeTransition3D;
    
    
    cell.rightButtons = [self createRightButtons:indexPath.row];
    return cell;
}


-(NSArray *) createRightButtons: (int) number
{
    NSMutableArray * result = [NSMutableArray array];

        MGSwipeButton * button = [MGSwipeButton buttonWithTitle:@"Delete" backgroundColor:[UIColor redColor] callback:^BOOL(MGSwipeTableCell * sender){
            
            //---add code here for when you hit delete---//
            UIAlertView *errorAlert = [[UIAlertView alloc]
                                       initWithTitle:NSLocalizedString(@"Confirmation",nil) message:NSLocalizedString(@"Are you sure to delete this chart?",nil)
                                       delegate:self cancelButtonTitle:NSLocalizedString(@"No",nil) otherButtonTitles:nil];
            errorAlert.tag = 2000;
            [errorAlert addButtonWithTitle:NSLocalizedString(@"Yes",nil)];
            [errorAlert show];
            
            active_record = number;
            return true;
        }];
        [result addObject:button];
    return result;
}


- (UITableViewCellEditingStyle) tableView:(UITableView *)tableView  editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
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
@end
