//
//  DatePicker.h
//  Jom
//
//  Copyright (c) 2014 QTS. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol DatePickerDelegate;
@interface DatePicker : UIView
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UIView *subDatePicker;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
@property (weak, nonatomic) IBOutlet UIButton *btnDone;

@property int idx;

@property(nonatomic,assign) BOOL isTime;
@property(nonatomic,retain) id<DatePickerDelegate> delegate;
-(void) initDatePicker;
-(void) initDatePickerFull;
- (IBAction)doCancel:(id)sender;
- (IBAction)doDone:(id)sender;

@end


@protocol DatePickerDelegate <NSObject>

-(void) showDateTimePicker:(NSDate *) date;
-(void) removeDateTimePicker;

@end