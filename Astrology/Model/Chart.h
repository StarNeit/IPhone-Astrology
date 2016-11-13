//
//  OBRPerson.h
//  SampleProject
//
//  Created by Elliot Neal on 22/05/2013.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Chart : NSManagedObject

@property (nonatomic, retain) NSString * chart_name;
@property (nonatomic, retain) NSString * date;
@property (nonatomic, retain) NSString * time;
@property (nonatomic, retain) NSString * place_name;
@property (nonatomic, retain) NSString * place_latitude;
@property (nonatomic, retain) NSString * place_longitude;
@property (nonatomic, retain) NSString * rawOffset;
@property (nonatomic, retain) NSString * dstOffset;

@end
