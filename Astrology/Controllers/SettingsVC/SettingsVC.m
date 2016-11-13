#import "SettingsVC.h"
#import <GooglePlaces/GooglePlaces.h>

@interface SettingsVC ()<UIActionSheetDelegate, GMSAutocompleteViewControllerDelegate>
{
   
    IBOutlet UILabel *tv_chart_style;
    IBOutlet UILabel *tv_ayanamsa;
    IBOutlet UILabel *tv_node;
    IBOutlet UILabel *tv_transit_location;
    
    NSString *value_chart_style;
    int value_ayanamsa;
    NSString *value_node;
    
    NSString *value_transit_location_name;
    double value_transit_location_lat;
    double value_transit_location_lon;
}
@end

@implementation SettingsVC
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
    
    
    
    //in case, no data in database
    value_chart_style = @"NORTH_INDIAN";
    value_ayanamsa = 1;
    value_node = @"MEAN_NODE";
    value_transit_location_name = @"";
    
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
    if ([USER_DEFAULT objectForKey:@"setting_place_name"] != [NSNull null]
        && [[USER_DEFAULT objectForKey:@"setting_place_name"] length] > 0)
    {
        value_transit_location_name = [USER_DEFAULT objectForKey:@"setting_place_name"];
    }
    if ([USER_DEFAULT objectForKey:@"setting_place_lat"] != [NSNull null]
        && [[USER_DEFAULT objectForKey:@"setting_place_lat"] length] > 0)
    {
        value_transit_location_lat = [[USER_DEFAULT objectForKey:@"setting_place_lat"] floatValue];
    }
    if ([USER_DEFAULT objectForKey:@"setting_place_lon"] != [NSNull null]
        && [[USER_DEFAULT objectForKey:@"setting_place_lon"] length] > 0)
    {
        value_transit_location_lon = [[USER_DEFAULT objectForKey:@"setting_place_lon"] floatValue];
    }
    
    
    //---UIValue Setting---//
    if ([value_chart_style isEqualToString:@"NORTH_INDIAN"])
    {
        tv_chart_style.text = @"North Indian";
    }else{
        tv_chart_style.text = @"South Indian";
    }
    
    switch (value_ayanamsa) {
        case 1:
            tv_ayanamsa.text = @"Lahiri";
            break;
        case 3:
            tv_ayanamsa.text = @"Raman";
            break;
        case 5:
            tv_ayanamsa.text = @"Krishnamurti";
            break;
        case 7:
            tv_ayanamsa.text = @"Yukteshwar";
            break;
        case 8:
            tv_ayanamsa.text = @"J.N Bhasin";
            break;
        case 21:
            tv_ayanamsa.text = @"Suryasiddhanta";
            break;
        case 23:
            tv_ayanamsa.text = @"Aryabhata";
            break;
    }
    
    if ([value_node isEqualToString:@"MEAN_NODE"])
    {
        tv_node.text = @"Mean Node";
    }else{
        tv_node.text = @"True Node";
    }
    
    tv_transit_location.text = value_transit_location_name;
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


- (IBAction)clickChartStyle:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select ChartStyle"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"North Indian", @"South Indian", nil];
    actionSheet.tag = 101;
    [actionSheet showInView:self.view];
}

- (IBAction)clickAyanamsa:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select Ayanamsa"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Lahiri", @"Raman", @"Krishnamurti", @"Yukteshwar"
                                                , @"J.N Bhasin", @"Suryasiddhanta", @"Aryabhata", nil];
    actionSheet.tag = 102;
    [actionSheet showInView:self.view];
}
- (IBAction)clickNode:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select Node"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Mean Node", @"True Node", nil];
    actionSheet.tag = 103;
    [actionSheet showInView:self.view];
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 101)//Chart Style
    {
        if (buttonIndex == 0) {
            tv_chart_style.text = @"North Indian";
            value_chart_style = @"NORTH_INDIAN";
        }else if (buttonIndex == 1) {
            tv_chart_style.text = @"South Indian";
            value_chart_style = @"SOUTH_INDIAN";
        }
    }
    else if (actionSheet.tag == 102)//Ayanamsa
    {
        if (buttonIndex == 0) {
            tv_ayanamsa.text = @"Lahiri";
            value_ayanamsa = 1;
        }else if (buttonIndex == 1) {
            tv_ayanamsa.text = @"Raman";
            value_ayanamsa = 3;
        }else if (buttonIndex == 2) {
            tv_ayanamsa.text = @"Krishnamurti";
            value_ayanamsa = 5;
        }else if (buttonIndex == 3) {
            tv_ayanamsa.text = @"Yukteshwar";
            value_ayanamsa = 7;
        }else if (buttonIndex == 4) {
            tv_ayanamsa.text = @"J.N Bhasin";
            value_ayanamsa = 8;
        }else if (buttonIndex == 5) {
            tv_ayanamsa.text = @"Suryasiddhanta";
            value_ayanamsa = 21;
        }else if (buttonIndex == 6) {
            tv_ayanamsa.text = @"Aryabhata";
            value_ayanamsa = 23;
        }
    }else if (actionSheet.tag == 103)//Node
    {
        if (buttonIndex == 0){
            tv_node.text = @"Mean Node";
            value_node = @"MEAN_NODE";
        }else if (buttonIndex == 1){
            tv_node.text = @"True Node";
            value_node = @"TRUE_NODE";
        }
    }
}







- (IBAction)clickTransitLocation:(id)sender {
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
    
    
    tv_transit_location.text = place.name;
    value_transit_location_name = place.name;
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





- (IBAction)clickUpdateButton:(id)sender {
    
    if (tv_transit_location.text.length > 0)
    {
        [USER_DEFAULT setValue:value_transit_location_name forKey:@"setting_place_name"];
        [USER_DEFAULT setValue:[NSString stringWithFormat:@"%f",value_transit_location_lat] forKey:@"setting_place_lat"];
        [USER_DEFAULT setValue:[NSString stringWithFormat:@"%f",value_transit_location_lon] forKey:@"setting_place_lon"];
    }else{
        [USER_DEFAULT setValue:@"" forKey:@"setting_place_name"];
        [USER_DEFAULT setValue:@"" forKey:@"setting_place_lat"];
        [USER_DEFAULT setValue:@"" forKey:@"setting_place_lon"];
    }
    
    [USER_DEFAULT setValue:value_chart_style forKey:@"setting_chart_style"];
    [USER_DEFAULT setValue:[NSString stringWithFormat:@"%d", value_ayanamsa] forKey:@"setting_ayanamsa"];
    [USER_DEFAULT setValue:value_node forKey:@"setting_node"];
    
    
    [Common showAlert:@"Successfully saved settings"];
}

@end
