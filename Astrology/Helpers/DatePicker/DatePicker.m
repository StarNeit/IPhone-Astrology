//
//  DatePicker.m
//  Jom
//
//  Copyright (c) 2014 QTS. All rights reserved.
//

#import "DatePicker.h"
@interface NSDate (Rounding)

- (NSDate *)dateByRoundingToMinutes:(NSInteger)minutes;

@end

@implementation NSDate (Rounding)

- (NSDate *)dateByRoundingToMinutes:(NSInteger)minutes {
    NSTimeInterval absoluteTime = floor([self timeIntervalSinceReferenceDate]);
    NSTimeInterval minuteInterval = minutes*60;
    
    NSTimeInterval remainder = (absoluteTime - (floor(absoluteTime/minuteInterval)*minuteInterval));
    if(remainder < 60) {
        return self;
    } else {
        NSTimeInterval remainingSeconds = minuteInterval - remainder;
        return [self dateByAddingTimeInterval:remainingSeconds];
    }
}

@end
@implementation DatePicker

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}



-(void)initDatePicker
{
    self.datePicker.datePickerMode = UIDatePickerModeDateAndTime;
   	self.datePicker.hidden = NO;
	//self.datePicker.date = [NSDate date];
    
    
    NSDate *currentDate = [NSDate date];
    [self.datePicker setDate:currentDate];
}


- (IBAction)doCancel:(id)sender {
    [self.delegate removeDateTimePicker];
}

- (IBAction)doDone:(id)sender {
    [self.delegate showDateTimePicker:self.datePicker.date];
}
@end
