//
//  SideMenuVC.m
//  Sufi 2.0
//
//  Created by Vidic Phan on 5/20/13.
//  Copyright (c) 2013 KGP. All rights reserved.
//

#import "SideMenuVC.h"
#import "AppDelegate.h"

@interface SideMenuVC ()
{
    
    __weak IBOutlet UIScrollView *_scrMenu;
    __weak IBOutlet UIButton *_btnAvatar;
    CGPoint velocityF;
    CGPoint velocityL;
}
@end

@implementation SideMenuVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (MFSideMenuContainerViewController *)menuContainerViewController {
    return (MFSideMenuContainerViewController *)self.parentViewController;
}

- (void)viewDidLoad
{
    NSLog(@"Load SideMenu");
    [Common appDelegate].sideMenu = self;
    [super viewDidLoad];
    [_scrMenu setContentSize:CGSizeMake(10, 750)];

    [self addGestureRecognizers];
}

- (void)addGestureRecognizers {
    [[self view] addGestureRecognizer:[self panGestureRecognizer]];
}

- (UIPanGestureRecognizer *)panGestureRecognizer {
    UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handlePan:)];
    return recognizer;
}

- (void) handlePan:(UIPanGestureRecognizer *)recognizer {
    if(recognizer.state == UIGestureRecognizerStateBegan) {
        velocityF = [recognizer velocityInView:self.view];
        velocityL = [recognizer velocityInView:self.view];
    }else if(recognizer.state == UIGestureRecognizerStateEnded) {
        velocityL = [recognizer velocityInView:self.view];
        
        if(velocityL.x > velocityF.x + 200)
        {
//            AppDelegate *app = [Common appDelegate];
//            [app initSideMenu];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1) {
        
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewDidUnload {
    [super viewDidUnload];
    
}
- (IBAction)clickHome:(id)sender {
    AppDelegate *app = [Common appDelegate];
    [self.menuContainerViewController setMenuState:MFSideMenuStateClosed completion:^{
        [app openHome];
    }];
}
- (IBAction)clickCreateChart:(id)sender {
    AppDelegate *app = [Common appDelegate];
    [self.menuContainerViewController setMenuState:MFSideMenuStateClosed completion:^{
        [app openCreateChart];
    }];
}
- (IBAction)clickSaveChart:(id)sender {
    AppDelegate *app = [Common appDelegate];
    [self.menuContainerViewController setMenuState:MFSideMenuStateClosed completion:^{
        [app openSavedChart];
    }];
}
- (IBAction)clickTransit:(id)sender {
    AppDelegate *app = [Common appDelegate];
    [self.menuContainerViewController setMenuState:MFSideMenuStateClosed completion:^{
        [app openTransit];
    }];
}
- (IBAction)clickSettings:(id)sender {
    AppDelegate *app = [Common appDelegate];
    [self.menuContainerViewController setMenuState:MFSideMenuStateClosed completion:^{
        [app openSettings];
    }];
}
- (IBAction)clickHelp:(id)sender {
    AppDelegate *app = [Common appDelegate];
    [self.menuContainerViewController setMenuState:MFSideMenuStateClosed completion:^{
        [app openHelp];
    }];
}
- (IBAction)clickShop:(id)sender {
    AppDelegate *app = [Common appDelegate];
    [self.menuContainerViewController setMenuState:MFSideMenuStateClosed completion:^{
        [app openShop];
    }];
}
- (IBAction)clickContact:(id)sender {
    AppDelegate *app = [Common appDelegate];
    [self.menuContainerViewController setMenuState:MFSideMenuStateClosed completion:^{
        [app openContact];
    }];
}
- (IBAction)clickRate:(id)sender {
    [self.menuContainerViewController setMenuState:MFSideMenuStateClosed completion:^{
        
        UIAlertView *errorAlert = [[UIAlertView alloc]
                                   initWithTitle:NSLocalizedString(@"Astrologers Heaven",nil) message:NSLocalizedString(@"Do you like this app?",nil)
                                   delegate:self cancelButtonTitle:NSLocalizedString(@"No",nil) otherButtonTitles:nil];
        errorAlert.tag = 1000;
        [errorAlert addButtonWithTitle:NSLocalizedString(@"Yes",nil)];
        [errorAlert show];
    }];
}

/*
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1000)
    {
        if (buttonIndex == 0) //no
        {
            
        }else if (buttonIndex == 1) //yes
        {
            
        }
    }
}
*/

@end
