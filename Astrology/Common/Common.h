//
//  Common.h
//  HeroPager
//
//  Created by Nick LEE on 2/21/12.
//  Copyright (c) 2012 HireVietnamese. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>

#define kBitmapInfo       kCGImageAlphaPremultipliedLast

@interface Common : NSObject

+(NSString *) stringByTrimString:(NSString *)string;
+(uint64_t)getFreeDiskspace;
+ (BOOL) connectedInternet;
+ (NSString *)getMacAddress;
+ (AppDelegate *)appDelegate;
+ (void)showAlert:(NSString *)message;
+ (void)showAlert2:(NSString *)message title:(NSString*)title;
+ (UIImage *) resizeImage:(UIImage *)orginalImage withSize:(CGSize)size;
+ (BOOL) checkEmailFormat:(NSString *)email;
+ (NSString*) md5: (NSString *)str;
+ (void) setDeviceToken:(NSString*) token;
+ (NSString*) getDeviceToken;
+ (NSString *) getXMLSpecialChars:(NSString *)str;
+ (NSString *) processXMLSpecialChars:(NSString *)str;
+ (NSDate *) convertDateTime:(NSString *)fromUTCDateTime serverTime:(NSString *)strServerTime;
+ (NSDate *) convertStringToDate: (NSString *)dateString;
+ (BOOL) CompareDateWithDate:(NSDate *)date : (NSDate *)date2;

+ (void) playPushSound;
+ (BOOL) validateUrl: (NSString *) url;
+ (UIColor*) getTintColor;
+ (NSString *)stringFromDate:(NSDate *)date withFormat:(NSString *)formatString;
+ (NSString*)trimString:(NSString*)string;
+ (BOOL) isNumeric:(NSString *)s;

+ (NSString*)formatJSONValue:(NSString*)str;
+ (float)formatJSONValueFloat:(NSString*)str;
+ (int)formatJSONValueInt:(NSString*)str;
+ (UIImage*) getSubImageFrom: (UIImage*) img WithRect: (CGRect) rect;

+(BOOL) checkScreenIPhone5;
+(NSString *)extractYoutubeID:(NSString *)youtubeURL;
+ (CGSize)sizeOfString:(NSString *)string inFont:(UIFont *)font maxWidth:(CGFloat)maxWidth;
+ (UIColor *) colorWithHexString: (NSString *) stringToConvert;

+ (NSString*) stringFromColorSelect:(int)_index;
+ (NSString*) stringFromFrame;
+ (UIImage *)fillApplyColorFrame:(int)_index toImage:(UIImage*)toImage;

+ (CGFloat)widthOfString:(NSString *)string withFont:(UIFont *)font;
+ (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize;
+(NSString*)secondToTime:(int)second;
+(UIImage*)generateThumbNailDataWithVideo:(NSURL*) url flip:(BOOL)_isFlip;
+(UIImage*)generateThumbNailDataWithVideo:(NSURL*) url time:(int)_time flip:(BOOL)_isFlip;
+(NSString*)convertTimeQues:(int)timeQues;
+ (NSURL *) tempFileURL;
+ (NSURL *) creatFileURL;
+ (NSURL *) creatFileURL_two;
+(UIImage *)imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize)newSize;

+(UIImage*)generateThumbNailDataWithVideo:(NSURL*) url time:(int)_time;
+(UIImage*)generateThumbNailDataWithVideo:(NSURL*) url;

void debug(NSString *format, ...);

+ (UIImage*) getPhoto480:(UIImage*)_image;
+ (UIColor*) getPixelColorAtLocation:(CGPoint)point andImage:(UIImage*)_image;
+ (UIImage*) resizedImage:(UIImage *)_image adnThum:(CGRect) thumbRect;
+ (int) getNumCellFromFrame:(int)_frame;

+ (BOOL) saveImageDocument:(UIImage*)_image;
+ (UIImage*) getImageDocument:(NSString*)_nameImage;
+(NSString *) randomStringWithLength: (int) len;
+ (NSString *)encodeToBase64String:(UIImage *)image;
+ (UIImage *)decodeBase64ToImage:(NSString *)strEncodeData;

+(void)logoutUser;

+(UIImage *)resizeImage:(UIImage *)image;

+(void)downloadImageWithURL:(NSURL *)url completionBlock:(void (^)(BOOL succeeded, UIImage *image))completionBlock;
@end
