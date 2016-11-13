//
//  Common.m
//  HeroPager
//
//  Created by Nick LEE on 2/21/12.
//  Copyright (c) 2012 HireVietnamese. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>
#import <AudioToolbox/AudioServices.h>

#import "Common.h"
#import "Define.h"
#import "Reachability.h"
#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>


@implementation Common

+(NSString *) stringByTrimString:(NSString *)string{
    return [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}
+ (AppDelegate *)appDelegate
{
    UIApplication *app = [UIApplication sharedApplication];
    return (AppDelegate *)app.delegate;
}
+(uint64_t)getFreeDiskspace {
    uint64_t totalSpace = 0;
    uint64_t totalFreeSpace = 0;
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
    
    if (dictionary) {
        NSNumber *fileSystemSizeInBytes = [dictionary objectForKey: NSFileSystemSize];
        NSNumber *freeFileSystemSizeInBytes = [dictionary objectForKey:NSFileSystemFreeSize];
        totalSpace = [fileSystemSizeInBytes unsignedLongLongValue];
        totalFreeSpace = [freeFileSystemSizeInBytes unsignedLongLongValue];
        NSLog(@"Memory Capacity of %llu MiB with %llu MiB Free memory available.", ((totalSpace/1024ll)/1024ll), ((totalFreeSpace/1024ll)/1024ll));
    } else {
        NSLog(@"Error Obtaining System Memory Info: Domain = %@, Code = %@", [error domain], [error code]);
    }
    
    return totalFreeSpace;
}
+ (UIImage *)decodeBase64ToImage:(NSString *)strEncodeData {
    NSData *data = [[NSData alloc]initWithBase64EncodedString:strEncodeData options:NSDataBase64DecodingIgnoreUnknownCharacters];
    return [UIImage imageWithData:data];
}
+ (NSString *)getMacAddress
{
    int mgmtInfoBase[6];
    char *msgBuffer = NULL;
    NSString *errorFlag = NULL;
    size_t length;
    // Setup the management Information Base (mib)
    mgmtInfoBase[0] = CTL_NET; // Request network subsystem
    mgmtInfoBase[1] = AF_ROUTE; // Routing table info
    mgmtInfoBase[2] = 0;
    mgmtInfoBase[3] = AF_LINK; // Request link layer information
    mgmtInfoBase[4] = NET_RT_IFLIST; // Request all configured interfaces
    // With all configured interfaces requested, get handle index
    if ((mgmtInfoBase[5] = if_nametoindex("en0")) == 0)
        errorFlag = @"if_nametoindex failure";
    // Get the size of the data available (store in len)
    else if (sysctl(mgmtInfoBase, 6, NULL, &length, NULL, 0) < 0)
        errorFlag = @"sysctl mgmtInfoBase failure";
    // Alloc memory based on above call
    else if ((msgBuffer = malloc(length)) == NULL)
        errorFlag = @"buffer allocation failure";
    // Get system information, store in buffer
    else if (sysctl(mgmtInfoBase, 6, msgBuffer, &length, NULL, 0) < 0)
    {
        free(msgBuffer);
        errorFlag = @"sysctl msgBuffer failure";
    }
    else
    {
        // Map msgbuffer to interface message structure
        struct if_msghdr *interfaceMsgStruct = (struct if_msghdr *) msgBuffer;
        // Map to link-level socket structure
        struct sockaddr_dl *socketStruct = (struct sockaddr_dl *) (interfaceMsgStruct + 1);
        // Copy link layer address data in socket structure to an array
        unsigned char macAddress[6];
        memcpy(&macAddress, socketStruct->sdl_data + socketStruct->sdl_nlen, 6);
        // Read from char array into a string object, into traditional Mac address format
        NSString *macAddressString = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                                      macAddress[0], macAddress[1], macAddress[2], macAddress[3], macAddress[4], macAddress[5]];
        NSLog(@"Mac Address: %@", macAddressString);
        // Release the buffer memory
        free(msgBuffer);
        return macAddressString;
    }
    // Error...
    NSLog(@"Error: %@", errorFlag);
    return nil;
}
+ (BOOL) connectedInternet{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return !(networkStatus == NotReachable);
}

+ (void)showAlert2:(NSString *)message title:(NSString*)title
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillResignActiveNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification* notification){
        [alert dismissWithClickedButtonIndex:0 animated:NO];
    }];
}


+ (void)showAlert:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:APP_NAME message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillResignActiveNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification* notification){
        [alert dismissWithClickedButtonIndex:0 animated:NO];
    }];
}
+(NSString*)secondToTime:(int)second
{
    int hour=second/3600;
    int min=(second-hour*3600)/60;
    int sec=second-hour*3600-min*60;
    NSString *returnStr=@"";
    
    if(hour<10)returnStr=[returnStr stringByAppendingString:[NSString stringWithFormat:@"0%i:",hour]];
    else
        returnStr=[returnStr stringByAppendingString:[NSString stringWithFormat:@"%i:",hour]];
    if(min<10)
        returnStr=[returnStr stringByAppendingString:[NSString stringWithFormat:@"0%i:",min]];
    else
        returnStr=[returnStr stringByAppendingString:[NSString stringWithFormat:@"%i:",min]];
    if(sec<10)
        returnStr=[returnStr stringByAppendingString:[NSString stringWithFormat:@"0%i",sec]];
    else
        returnStr=[returnStr stringByAppendingString:[NSString stringWithFormat:@"%i",sec]];
    
    return returnStr;
}
+(UIImage*)generateThumbNailDataWithVideo:(NSURL*) url flip:(BOOL)_isFlip{
    NSLog(@"%@", url);
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:url options:nil];
    AVAssetImageGenerator *generate = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    CMTime time = CMTimeMake(1, 60);
    CGImageRef imgRef = [generate copyCGImageAtTime:time actualTime:NULL error:nil];
    
    int frontCameraImageOrientation = !_isFlip?UIImageOrientationRight:UIImageOrientationLeftMirrored;
    UIImage *image = [UIImage imageWithCGImage:imgRef scale:1.0 orientation:frontCameraImageOrientation];
    CFRelease(imgRef); //cgImage is retained by the UIImage above
    return image;
}
+(UIImage*)generateThumbNailDataWithVideo:(NSURL*) url time:(int)_time flip:(BOOL)_isFlip{
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:url options:nil];
    AVAssetImageGenerator *generate = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    CMTime time = CMTimeMakeWithSeconds(_time, 600);
    CGImageRef imgRef = [generate copyCGImageAtTime:time actualTime:NULL error:nil];
    
    int frontCameraImageOrientation = !_isFlip?UIImageOrientationRight:UIImageOrientationLeftMirrored;
    UIImage *image = [UIImage imageWithCGImage:imgRef scale:1.0 orientation:frontCameraImageOrientation];
    CFRelease(imgRef); //cgImage is retained by the UIImage above
    return image;
}

+(UIImage*)generateThumbNailDataWithVideo:(NSURL*) url{
    NSLog(@"%@", url);
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:url options:nil];
    AVAssetImageGenerator *generate = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    CMTime time = CMTimeMake(1, 60);
    CGImageRef imgRef = [generate copyCGImageAtTime:time actualTime:NULL error:nil];
    
    UIImage *image = [UIImage imageWithCGImage:imgRef];
    CFRelease(imgRef); //cgImage is retained by the UIImage above
    return image;
}
+(UIImage*)generateThumbNailDataWithVideo:(NSURL*) url time:(int)_time{
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:url options:nil];
    AVAssetImageGenerator *generate = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    CMTime time = CMTimeMakeWithSeconds(_time, 600);
    CGImageRef imgRef = [generate copyCGImageAtTime:time actualTime:NULL error:nil];
    
    UIImage *image = [UIImage imageWithCGImage:imgRef];
    CFRelease(imgRef); //cgImage is retained by the UIImage above
    return image;
}

+ (UIImage *) resizeImage:(UIImage *)orginalImage withSize:(CGSize)size
{  CGFloat actualHeight = orginalImage.size.height;
    CGFloat actualWidth = orginalImage.size.width;
    NSLog(@"Origin size %f %f",actualWidth,actualHeight);
    
    if(actualWidth <= size.width || actualHeight <= size.height)
    {
        return orginalImage;
    }
    else
    {
        if((actualWidth/actualHeight)<(size.width/size.height))
        {
            actualHeight=actualHeight*(size.width/actualWidth);
            actualWidth=size.width;
            
        }else
        {
            actualWidth=actualWidth*(size.height/actualHeight);
            actualHeight=size.height;
        }
    }
    
    NSLog(@"Upkload size %f %f",actualWidth,actualHeight);
    CGRect rect = CGRectMake(0.0,0.0,actualWidth,actualHeight);
    UIGraphicsBeginImageContext(rect.size);
    [orginalImage drawInRect:rect];
    orginalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return orginalImage;
}
+ (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize
{
    CGFloat actualHeight = image.size.height;
    CGFloat actualWidth = image.size.width;
    
    if(actualWidth <= newSize.width || actualHeight <= newSize.height)
    {
        return image;
    }
    else
    {
        if((actualWidth/actualHeight)<(newSize.width/newSize.height))
        {
            actualHeight=actualHeight*(newSize.width/actualWidth);
            actualWidth=newSize.width;
            
        }else
        {
            actualWidth=actualWidth*(newSize.height/actualHeight);
            actualHeight=newSize.height;
        }
    }
    // Create a graphics image context
    UIGraphicsBeginImageContext(CGSizeMake(actualWidth,actualHeight));
    
    // Tell the old image to draw in this new context, with the desired
    // new size
    [image drawInRect:CGRectMake(0,0,actualWidth,actualHeight)];
    
    // Get the new image from the context
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // End the context
    UIGraphicsEndImageContext();
    // Return the new image.
    return newImage;
}

+ (BOOL) checkEmailFormat:(NSString *)email
{
    NSString *emailRegEx =
    @"(?:[A-Za-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[A-Za-z0-9!#$%\\&'*+/=?\\^_`{|}"
    @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
    @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[A-Za-z0-9](?:[a-"
    @"z0-9-]*[A-Za-z0-9])?\\.)+[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?|\\[(?:(?:25[0-5"
    @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
    @"9][0-9]?|[A-Za-z0-9-]*[A-Za-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
    @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
    NSPredicate *regExPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
    BOOL myStringMatchesRegEx = [regExPredicate evaluateWithObject:email];
//    NSLog(@"check email result %i",myStringMatchesRegEx);
    return myStringMatchesRegEx;
}

+ (NSString*) md5: (NSString *)str
{
    const char *cStr = [str UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, strlen(cStr), result );
    return [NSString  stringWithFormat:
            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3], result[4],
            result[5], result[6], result[7],
            result[8], result[9], result[10], result[11], result[12],
            result[13], result[14], result[15]
            ];
}


+ (void) setDeviceToken:(NSString*) token
{        
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:token forKey:@"DEVICE_TOKEN"];
    [prefs synchronize];
}

+ (NSString*) getDeviceToken
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *deviceToken = [prefs stringForKey:@"DEVICE_TOKEN"];
    if (deviceToken == NULL) {
        NSDate *today = [NSDate date];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
        deviceToken  = [Common md5:[dateFormat stringFromDate:today]];
        deviceToken = [NSString stringWithFormat:@"%@%@",deviceToken,deviceToken];
    }else{
        NSLog(@"device token : %@",deviceToken);
    }
    return deviceToken;            
}

+ (NSString *) getXMLSpecialChars:(NSString *)str
{ 
    NSString * tempStr = [str stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
    tempStr = [tempStr stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
    tempStr = [tempStr stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
    tempStr = [tempStr stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
    tempStr = [tempStr stringByReplacingOccurrencesOfString:@"&#39;" withString:@"'"];
    tempStr = [tempStr stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
    return tempStr;
}

+ (NSString *) processXMLSpecialChars:(NSString *)str
{ 
    NSString * tempStr = [str stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"];
    tempStr = [tempStr stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"];
    tempStr = [tempStr stringByReplacingOccurrencesOfString:@">" withString:@"&gt;"];
    tempStr = [tempStr stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"];
    tempStr = [tempStr stringByReplacingOccurrencesOfString:@"'" withString:@"&apos;"];
    return tempStr;
}

+ (NSDate *) convertDateTime:(NSString *)fromUTCDateTime serverTime:(NSString *)strServerTime{ 
    NSDateFormatter *srcDateFormatter = [[NSDateFormatter alloc] init];
    [srcDateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [srcDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *serverDate = [srcDateFormatter dateFromString:strServerTime];
    
    
    NSDateFormatter *desDateFormatter = [[NSDateFormatter alloc] init];
    [desDateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    [desDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *srcDate = [srcDateFormatter dateFromString:fromUTCDateTime];
    
    
    NSTimeInterval delta = [[NSDate date] timeIntervalSinceDate:serverDate];
    NSTimeInterval timeZoneOffset = [[NSTimeZone systemTimeZone] secondsFromGMT] + delta;
    NSDate *desDate = [NSDate dateWithTimeInterval:timeZoneOffset sinceDate:srcDate];
    NSLog(@"Correct Time%@", desDate);
    
    return desDate;
}

+ (NSDate *) convertStringToDate: (NSString *)dateString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    
    NSDate *date = [dateFormatter dateFromString:dateString];
    return date;
}

+ (void) playPushSound
{
    SystemSoundID soundID;
    NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"push" ofType:@"wav"];
    CFURLRef soundUrl = (__bridge CFURLRef) [NSURL fileURLWithPath:soundPath];
    //Use audio sevices to create the sound
    AudioServicesCreateSystemSoundID((CFURLRef)soundUrl, &soundID); 
    //Use audio services to play the sound
    AudioServicesPlaySystemSound(soundID);
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    //CFRelease(soundUrl);
    
}

+ (BOOL) validateUrl: (NSString *) url {
    NSString *theURL =@"(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+";
    NSPredicate *urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", theURL]; 
    return [urlTest evaluateWithObject:url];
}

+ (UIColor*) getTintColor{
    return [UIColor colorWithRed:89.0/255.0 green:7.0/255.0 blue:35.0/255.0 alpha:1.0];
}

+ (NSString *)stringFromDate:(NSDate *)date withFormat:(NSString *)formatString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init] ;
    dateFormatter.dateFormat = formatString;
    return [dateFormatter stringFromDate:date];
}

+ (NSString*)trimString:(NSString*)string
{
    NSString *trimmedString = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return trimmedString;
}

+ (BOOL) isNumeric:(NSString *)s
{
    NSScanner *sc = [NSScanner scannerWithString: s];
    if ( [sc scanFloat:NULL] )
        {
            return [sc isAtEnd];
        }
    return NO;
}

+ (NSString*)formatJSONValue:(NSString*)str{
    
    NSString *temp = [NSString stringWithFormat:@"%@",str];
    
    if (str!=NULL) {
        if ([temp isEqualToString:@"null"] || 
            [temp isEqualToString:@"<null>"] ||
            [temp isEqualToString:@""]) {
            return @"";
        }else {
            return str;
        }
    }else {
        return @"";
    }
}

+ (int)formatJSONValueInt:(NSString*)str{
    
    NSString *temp = [NSString stringWithFormat:@"%@",str];
    
    if (str!=NULL) {
        if ([temp isEqualToString:@"null"] || 
            [temp isEqualToString:@"<null>"] ||
            [temp isEqualToString:@""]) {
            return 0 ;
        }else {
            return [str intValue];
        }
    }else {
        return 0;
    }
}

+ (float)formatJSONValueFloat:(NSString*)str{
    
    NSString *temp = [NSString stringWithFormat:@"%@",str];
    
    if (str!=NULL) {
        if ([temp isEqualToString:@"null"] || 
            [temp isEqualToString:@"<null>"] ||
            [temp isEqualToString:@""]) {
            return 0 ;
        }else {
            return [str floatValue];
        }
    }else {
        return 0;
    }
}

+(BOOL) checkScreenIPhone5{
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
        if([UIScreen mainScreen].bounds.size.height == 568.0){
            return YES;
        }
        else{
            return NO;
        }
    }else{
        return NO;
    }
}

+ (NSString *)extractYoutubeID:(NSString *)youtubeURL
{
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"?.*v=(.*)" options:NSRegularExpressionCaseInsensitive error:&error];
    NSRange rangeOfFirstMatch = [regex rangeOfFirstMatchInString:youtubeURL options:0 range:NSMakeRange(0, [youtubeURL length])];
    if(!NSEqualRanges(rangeOfFirstMatch, NSMakeRange(NSNotFound, 0)))
    {
        NSString *substringForFirstMatch = [youtubeURL substringWithRange:rangeOfFirstMatch];
        
        return substringForFirstMatch;
    }
    return nil;
}
+ (CGSize)sizeOfString:(NSString *)string inFont:(UIFont *)font maxWidth:(CGFloat)maxWidth
{
    CGSize size = [string sizeWithFont:font
                     constrainedToSize:CGSizeMake(maxWidth, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    return size;
}

+ (NSString*) stringFromFrame
{
    int rand = (random()%25);
    
    NSLog(@"%d", rand);
    switch (rand) {
        case 1:
            return @"800000";
            break;
        case 2:
            return @"804000";
            break;
        case 3:
            return @"ff0000";
            break;
        case 4:
            return @"ff8000";
            break;
        case 5:
            return @"ff6666";
            break;
        case 6:
            return @"ffcc66";
            break;
        case 7:
            return @"ccff66";
            break;
        case 8:
            return @"ffff00";
            break;
        case 9:
            return @"408000";
            break;
        case 10:
            return @"008000";
            break;
        case 11:
            return @"008080";
            break;
        case 12:
            return @"004080";
            break;
        case 13:
            return @"00ffff";
            break;
        case 14:
            return @"66ccff";
            break;
        case 15:
            return @"cc66ff";
            break;
        case 16:
            return @"8000ff";
            break;
        case 17:
            return @"400080";
            break;
        case 18:
            return @"400080";
            break;
        case 19:
            return @"800040";
            break;
        case 20:
            return @"7f7f7f";
            break;
        case 21:
            return @"999999";
            break;
        case 22:
            return @"333333";
            break;
        case 23:
            return @"191919";
            break;
        case 24:
            return @"ffffff";
            break;
        case 25:
            return @"000000";
            break;
        default:
            break;
    }
    return @"000000";
}

+ (NSString*) stringFromColorSelect:(int)_index
{
    switch (_index) {
        case 1:
            return @"800000";
            break;
        case 2:
            return @"804000";
            break;
        case 3:
            return @"ff0000";
            break;
        case 4:
            return @"ff8000";
            break;
        case 5:
            return @"ff6666";
            break;
        case 6:
            return @"ffcc66";
            break;
        case 7:
            return @"ccff66";
            break;
        case 8:
            return @"ffff00";
            break;
        case 9:
            return @"408000";
            break;
        case 10:
            return @"008000";
            break;
        case 11:
            return @"008080";
            break;
        case 12:
            return @"004080";
            break;
        case 13:
            return @"00ffff";
            break;
        case 14:
            return @"66ccff";
            break;
        case 15:
            return @"cc66ff";
            break;
        case 16:
            return @"8000ff";
            break;
        case 17:
            return @"400080";
            break;
        case 18:
            return @"400080";
            break;
        case 19:
            return @"800040";
            break;
        case 20:
            return @"7f7f7f";
            break;
        case 21:
            return @"999999";
            break;
        case 22:
            return @"333333";
            break;
        case 23:
            return @"191919";
            break;
        case 24:
            return @"ffffff";
            break;
        case 25:
            return @"000000";
            break;
        default:
            break;
    }
    return @"000000";
}


+ (UIImage *)fillApplyColorFrame:(int)_index toImage:(UIImage*)toImage
{
    UIGraphicsBeginImageContext(CGSizeMake(toImage.size.width, toImage.size.width));
    [[UIColor blackColor] set];
    CGRect rect = CGRectMake(0, 0, 480, 480);
    CGContextAddRect(UIGraphicsGetCurrentContext(),rect);
    CGContextFillPath(UIGraphicsGetCurrentContext());
    switch (_index) {
        case 1:
            
            for (int i = 0; i< 2; i++) {
                for (int j = 0; j<2; j++) {
                    [[Common colorWithHexString: [Common stringFromFrame]] set];
                    CGRect rect = CGRectMake(242*j, 242*i, 238, 238);
                    CGContextAddRect(UIGraphicsGetCurrentContext(),rect);
                    CGContextFillPath(UIGraphicsGetCurrentContext());
                }
                
            }
            break;
            
        case 2:
            
            for (int i = 0; i< 3; i++) {
                for (int j = 0; j<3; j++) {
                    [[Common colorWithHexString: [Common stringFromFrame]] set];
                    CGRect rect = CGRectMake(162*j, 162*i, 158, 158);
                    CGContextAddRect(UIGraphicsGetCurrentContext(),rect);
                    CGContextFillPath(UIGraphicsGetCurrentContext());
                }
                
            }
            
            break;
        case 3:
            
            for (int i = 0; i< 4; i++) {
                for (int j = 0; j<4; j++) {
                    [[Common colorWithHexString: [Common stringFromFrame]] set];
                    CGRect rect = CGRectMake(122*j, 122*i, 118, 118);
                    CGContextAddRect(UIGraphicsGetCurrentContext(),rect);
                    CGContextFillPath(UIGraphicsGetCurrentContext());
                }
                
            }
            
            break;
        case 4:
            
            [[Common colorWithHexString: [Common stringFromFrame]] set];
            CGRect rect = CGRectMake(80, 0, 318, 238);
            CGContextAddRect(UIGraphicsGetCurrentContext(),rect);
            CGContextFillPath(UIGraphicsGetCurrentContext());
            [[Common colorWithHexString: [Common stringFromFrame]] set];
            rect= CGRectMake(80, 242, 318, 238);
            CGContextAddRect(UIGraphicsGetCurrentContext(),rect);
            CGContextFillPath(UIGraphicsGetCurrentContext());
            
            break;
        case 5:
            
            [[Common colorWithHexString: [Common stringFromFrame]] set];
            rect = CGRectMake(0, 80, 238, 318);
            CGContextAddRect(UIGraphicsGetCurrentContext(),rect);
            CGContextFillPath(UIGraphicsGetCurrentContext());
            [[Common colorWithHexString: [Common stringFromFrame]] set];
            rect = CGRectMake(242, 80, 238, 318);
            CGContextAddRect(UIGraphicsGetCurrentContext(),rect);
            CGContextFillPath(UIGraphicsGetCurrentContext());
            
            break;
        case 6:
            
            [[Common colorWithHexString: [Common stringFromFrame]] set];
            CGPoint pt1 = CGPointMake(0.0f, 0.0f);
            CGPoint pt2 = CGPointMake(0.0f, 478.0f);
            CGPoint pt3 = CGPointMake(478.0f, 0.0f);
            
            CGPoint vertices[] = {pt1, pt2, pt3, pt1};
            
            CGContextBeginPath(UIGraphicsGetCurrentContext());
            CGContextAddLines(UIGraphicsGetCurrentContext(), vertices, 3);
            CGContextFillPath(UIGraphicsGetCurrentContext());
            
            [[Common colorWithHexString: [Common stringFromFrame]] set];
            pt1 = CGPointMake(480.0f, 480.0f);
            pt2 = CGPointMake(2.0f, 480.0f);
            pt3 = CGPointMake(480.0f, 2.0f);
            
            CGPoint vertices0[] = {pt1, pt2, pt3, pt1};
            
            CGContextBeginPath(UIGraphicsGetCurrentContext());
            CGContextAddLines(UIGraphicsGetCurrentContext(), vertices0, 3);
            CGContextFillPath(UIGraphicsGetCurrentContext());
            
            break;
        case 7:
            
            [[Common colorWithHexString: [Common stringFromFrame]] set];
            pt1 = CGPointMake(2.0f, 0.0f);
            pt2 = CGPointMake(480.0f, 0.0f);
            pt3 = CGPointMake(480.0f, 478.0f);
            
            CGPoint vertices1[] = {pt1, pt2, pt3, pt1};
            
            CGContextBeginPath(UIGraphicsGetCurrentContext());
            CGContextAddLines(UIGraphicsGetCurrentContext(), vertices1, 3);
            CGContextFillPath(UIGraphicsGetCurrentContext());
            
            [[Common colorWithHexString: [Common stringFromFrame]] set];
            pt1 = CGPointMake(0.0f, 2.0f);
            pt2 = CGPointMake(0.0f, 480.0f);
            pt3 = CGPointMake(478.0f, 480.0f);
            
            CGPoint vertices2[] = {pt1, pt2, pt3, pt1};
            
            CGContextBeginPath(UIGraphicsGetCurrentContext());
            CGContextAddLines(UIGraphicsGetCurrentContext(), vertices2, 3);
            CGContextFillPath(UIGraphicsGetCurrentContext());
            
            break;
        case 8:
            
            [[Common colorWithHexString: [Common stringFromFrame]] set];
            
            pt1 = CGPointMake(0.0f, 0.0f);
            pt2 = CGPointMake(0.0f, 478.0f);
            pt3 = CGPointMake(238.0f, 0.0f);
            
            CGPoint vertices8[] = {pt1, pt2, pt3, pt1};
            
            CGContextBeginPath(UIGraphicsGetCurrentContext());
            CGContextAddLines(UIGraphicsGetCurrentContext(), vertices8, 3);
            CGContextFillPath(UIGraphicsGetCurrentContext());
            
            [[Common colorWithHexString: [Common stringFromFrame]] set];
            pt1 = CGPointMake(240.0f, 0.0f);
            pt2 = CGPointMake(2.0f, 480.0f);
            pt3 = CGPointMake(478.0f, 480.0f);
            
            CGPoint vertices9[] = {pt1, pt2, pt3, pt1};
            
            CGContextBeginPath(UIGraphicsGetCurrentContext());
            CGContextAddLines(UIGraphicsGetCurrentContext(), vertices9, 3);
            CGContextFillPath(UIGraphicsGetCurrentContext());
            
            [[Common colorWithHexString: [Common stringFromFrame]] set];
            pt1 = CGPointMake(242.0f, 0.0f);
            pt2 = CGPointMake(480.0f, 478.0f);
            pt3 = CGPointMake(480.0f, 0.0f);
            
            CGPoint vertices10[] = {pt1, pt2, pt3, pt1};
            
            CGContextBeginPath(UIGraphicsGetCurrentContext());
            CGContextAddLines(UIGraphicsGetCurrentContext(), vertices10, 3);
            CGContextFillPath(UIGraphicsGetCurrentContext());
            
            break;
        case 9:
            
            [[Common colorWithHexString: [Common stringFromFrame]] set];
            rect = CGRectMake(0, 0, 238, 238);
            CGContextAddRect(UIGraphicsGetCurrentContext(),rect);
            CGContextFillPath(UIGraphicsGetCurrentContext());
            [[Common colorWithHexString: [Common stringFromFrame]] set];
            rect = CGRectMake(242, 0, 238, 238);
            CGContextAddRect(UIGraphicsGetCurrentContext(),rect);
            CGContextFillPath(UIGraphicsGetCurrentContext());
            [[Common colorWithHexString: [Common stringFromFrame]] set];
            rect = CGRectMake(0, 242, 480, 238);
            CGContextAddRect(UIGraphicsGetCurrentContext(),rect);
            CGContextFillPath(UIGraphicsGetCurrentContext());
            
            break;
        case 10:
            
            [[Common colorWithHexString: [Common stringFromFrame]] set];
            rect = CGRectMake(0, 0, 480, 238);
            CGContextAddRect(UIGraphicsGetCurrentContext(),rect);
            CGContextFillPath(UIGraphicsGetCurrentContext());
            [[Common colorWithHexString: [Common stringFromFrame]] set];
            rect = CGRectMake(0, 242, 238, 238);
            CGContextAddRect(UIGraphicsGetCurrentContext(),rect);
            CGContextFillPath(UIGraphicsGetCurrentContext());
            [[Common colorWithHexString: [Common stringFromFrame]] set];
            rect = CGRectMake(242, 242, 238, 238);
            CGContextAddRect(UIGraphicsGetCurrentContext(),rect);
            CGContextFillPath(UIGraphicsGetCurrentContext());
            
            
            break;
        default:
            break;
    }
    UIImage *myImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return myImage;
}

+ (UIColor *) colorWithHexString: (NSString *) stringToConvert
{
    NSString *cString = [[stringToConvert stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor blackColor];
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    if ([cString length] != 6) return [UIColor blackColor];
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}
+ (CGFloat)widthOfString:(NSString *)string withFont:(UIFont *)font {
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
    return [[[NSAttributedString alloc] initWithString:string attributes:attributes] size].width;
}

void debug(NSString *format, ...)
{
#ifdef DEBUG
    va_list args;
    va_start(args, format);
    NSString *msg = [[NSString alloc] initWithFormat:format arguments:args] ;
    NSLog(@"%@", msg);
    va_end(args);
#endif
}
+(NSString*)convertTimeQues:(int)timeQues{
    
    int sec = timeQues%60;
    
    NSString *temp = @"";    
    
    
    if (sec<10) {
        temp = [NSString stringWithFormat:@"0%d",sec];
    }else{
        temp = [NSString stringWithFormat:@"%d",sec];
    }
    
    return temp;
}
+ (NSURL *) tempFileURL
{
    NSArray *paths= NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
	NSString *destinationPath = [documentsDirectory stringByAppendingFormat:@"/VID_%@.mp4", [dateFormatter stringFromDate:[NSDate date]]];
    return [NSURL fileURLWithPath:destinationPath];
}

+ (NSURL *) creatFileURL
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *outputURL = paths[0];
	NSFileManager *manager = [NSFileManager defaultManager];
	[manager createDirectoryAtPath:outputURL withIntermediateDirectories:YES attributes:nil error:nil];
	outputURL = [outputURL stringByAppendingPathComponent:@"output3.mp4"];
	// Remove Existing File
	[manager removeItemAtPath:outputURL error:nil];
    return [NSURL fileURLWithPath:outputURL];
}

+ (NSURL *) creatFileURL_two
{
    NSArray *paths= NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
	NSString *destinationPath = [documentsDirectory stringByAppendingFormat:@"/VID_Mum_%@.mp4", [dateFormatter stringFromDate:[NSDate date]]];
    return [NSURL fileURLWithPath:destinationPath];
}


+ (UIImage*) getSubImageFrom: (UIImage*) img WithRect: (CGRect) rect {
        
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    // translated rectangle for drawing sub image
    CGRect drawRect = CGRectMake(-rect.origin.x, -rect.origin.y, img.size.width, img.size.height);
    // clip to the bounds of the image context
    // not strictly necessary as it will get clipped anyway?
    CGContextClipToRect(context, CGRectMake(0, 0, rect.size.width, rect.size.height));
    // draw image
    [img drawInRect:drawRect];
    // grab image
    UIImage* subImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return subImage;
}

#pragma Mark - uStamp
+ (UIImage*) getPhoto480:(UIImage*)_image
{
    CGImageRef imageRef = [_image CGImage];
    CGBitmapInfo bitmapInfo = (CGBitmapInfo) kBitmapInfo;
    
    CGRect thumbRect;
    thumbRect.origin.x = 0;
    thumbRect.origin.y = 0;
    thumbRect.size.width = 320;
    thumbRect.size.height = 320;
    // Build a bitmap context that's the size of the thumbRect
    CGContextRef bitmap = CGBitmapContextCreate(
                                                NULL,
                                                thumbRect.size.width,       // width
                                                thumbRect.size.height,      // height
                                                CGImageGetBitsPerComponent(imageRef),   // really needs to always be 8
                                                4 * thumbRect.size.width,   // rowbytes
                                                CGImageGetColorSpace(imageRef),
                                                bitmapInfo
                                                );
    
    // Draw into the context, this scales the image
    CGContextDrawImage(bitmap, thumbRect, imageRef);
    
    // Get an image from the context and a UIImage
    CGImageRef  ref = CGBitmapContextCreateImage(bitmap);
    UIImage*    result = [UIImage imageWithCGImage:ref];
    
    CGContextRelease(bitmap);   // ok if NULL
    CGImageRelease(ref);
    
    return result;
}

+(UIImage*) resizedImage:(UIImage *)_image adnThum:(CGRect) thumbRect
{
    CGImageRef imageRef = [_image CGImage];
    CGBitmapInfo bitmapInfo = (CGBitmapInfo) kBitmapInfo;
    
    
    // Build a bitmap context that's the size of the thumbRect
    CGContextRef bitmap = CGBitmapContextCreate(
                                                NULL,
                                                thumbRect.size.width,       // width
                                                thumbRect.size.height,      // height
                                                CGImageGetBitsPerComponent(imageRef),   // really needs to always be 8
                                                4 * thumbRect.size.width,   // rowbytes
                                                CGImageGetColorSpace(imageRef),
                                                bitmapInfo
                                                );
    
    // Draw into the context, this scales the image
    CGContextDrawImage(bitmap, thumbRect, imageRef);
    
    // Get an image from the context and a UIImage
    CGImageRef  ref = CGBitmapContextCreateImage(bitmap);
    UIImage*    result = [UIImage imageWithCGImage:ref];
    
    CGContextRelease(bitmap);   // ok if NULL
    CGImageRelease(ref);
    
    return result;
}

+ (UIColor*) getPixelColorAtLocation:(CGPoint)point andImage:(UIImage*)_image {
    // Cancel if point is outside image coordinates
    if (!CGRectContainsPoint(CGRectMake(0.0f, 0.0f, _image.size.width, _image.size.height), point)) {
        return nil;
    }
    
    NSInteger pointX = trunc(point.x);
    NSInteger pointY = trunc(_image.size.height - point.y);
    CGImageRef cgImage = _image.CGImage;
    NSUInteger width = CGImageGetWidth(cgImage);
    NSUInteger height = CGImageGetHeight(cgImage);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    int bytesPerPixel = 4;
    int bytesPerRow = bytesPerPixel * 1;
    NSUInteger bitsPerComponent = 8;
    unsigned char pixelData[4] = { 0, 0, 0, 0 };
    CGContextRef context = CGBitmapContextCreate(pixelData,
                                                 1,
                                                 1,
                                                 bitsPerComponent,
                                                 bytesPerRow,
                                                 colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    
    // Draw the pixel we are interested in onto the bitmap context
    CGContextTranslateCTM(context, -pointX, -pointY);
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, (CGFloat)width, (CGFloat)height), cgImage);
    CGContextRelease(context);
    
    // Convert color values [0..255] to floats [0.0..1.0]
    CGFloat red   = (CGFloat)pixelData[0] / 255.0f;
    CGFloat green = (CGFloat)pixelData[1] / 255.0f;
    CGFloat blue  = (CGFloat)pixelData[2] / 255.0f;
    CGFloat alpha = (CGFloat)pixelData[3] / 255.0f;
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

+ (int) getNumCellFromFrame:(int)_frame
{
    int k = 0;
    switch (_frame) {
        case 1:
            k = 4;
            break;
        case 2:
            k = 9;
            break;
        case 3:
            k = 16;
            break;
        case 4:
            k = 2;
            break;
        case 5:
            k = 2;
            break;
        case 6:
            k = 3;
            break;
        case 7:
            k = 3;
            break;
        case 8:
            k = 4;
            break;
        case 9:
            k = 3;
            break;
        case 10:
            k = 3;
            break;
            
        default:
            break;
    }
    return k;
}

//Fill Color
/*
 - (void) intPickerColor
 {
 _scrMainColor.bouncesZoom = YES;
 _scrMainColor.clipsToBounds = YES;
 _scrMainColor.contentSize = CGSizeMake(320, 320);
 int k = 0;
 for(int i=0;i<5;i++)
 {
 for(int j=0;j<5;j++)
 {
 k++;
 UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(64 * i,64 * j, 64, 64)];
 [button setBackgroundImage: [UIImage imageNamed:[NSString stringWithFormat:@"%d.png", k]] forState:UIControlStateNormal];
 button.tag = k;
 [button addTarget:self action:@selector(clickSelectColor:) forControlEvents:UIControlEventTouchUpInside];
 [_scrMainColor addSubview:button];
 }
 }
 }
 
 - (void) clickSelectColor:(id)sender
 {
 UIButton *btn = (UIButton*)sender;
 if (!_isFrame) {
 NSLog(@"%@", [Common stringFromColorSelect:btn.tag]);
 _txfEditText.textColor = [Common colorWithHexString: [Common stringFromColorSelect:btn.tag]];
 }
 
 }
 */
+ (BOOL) saveImageDocument:(UIImage*)_image
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc]init];
    timeFormatter.dateFormat = @"MM_dd_yyyy_HH_mm_ss";
    
    NSString *timeString = [timeFormatter stringFromDate: [NSDate date]];
//    NSLog(@"Save uStamp_%@.png", timeString);
    
    NSString *savedImagePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/uStamp_%@.png", timeString]];
    UIImage *image = _image; // imageView is my image from camera
    NSData *imageData = UIImagePNGRepresentation(image);
    [imageData writeToFile:savedImagePath atomically:NO];
    NSLog(@"%@", savedImagePath);
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"uStampGallery"] count] > 0) {
        
        
        NSMutableArray *arr = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"uStampGallery"]];
        //[[NSUserDefaults standardUserDefaults] objectForKey:@"12345"];
        int n = [arr count];
        [arr insertObject: [NSString stringWithFormat:@"uStamp_%@.png", timeString] atIndex:n];
        [[NSUserDefaults standardUserDefaults] setObject:arr forKey:@"uStampGallery"];
        
    }else
    {
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        [arr insertObject: [NSString stringWithFormat:@"uStamp_%@.png", timeString] atIndex:0];
        [[NSUserDefaults standardUserDefaults] setObject:arr forKey:@"uStampGallery"];
    }
    
    return YES;
}

+ (UIImage*) getImageDocument:(NSString*)_nameImage
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *savedImagePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", _nameImage]];
//    NSLog(@"%@", savedImagePath);
    return [UIImage imageWithContentsOfFile:savedImagePath];
}

+ (void) checkRelease
{
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:@"MM/dd/yyyy"];
    NSDate *stringDate = [dateFormat dateFromString:@"03/03/2015"];
    if ([self CompareDateWithDate:date :stringDate ]) {
        NSLog(@"Nho hon");
        
    }else
    {
        NSLog(@"Lon hon");
       
    }
}

+ (BOOL) CompareDateWithDate:(NSDate *)date : (NSDate *)date2
{
    //so sánh theo giây
    NSLog(@"%@-->%@", date, date2);
    NSTimeInterval timeFrom1970OfDate = [date timeIntervalSince1970];
    
    NSTimeInterval timeFrom1970OfDate2 = [date2 timeIntervalSince1970];
    
    NSLog(@"time from date: %f",timeFrom1970OfDate);
    NSLog(@"time from date2: %f",timeFrom1970OfDate2);
    
    if (timeFrom1970OfDate>timeFrom1970OfDate2)
    {
        
        return YES;
    }
    return NO;
}

+(NSString *) randomStringWithLength: (int) len {
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random() % [letters length]]];
    }
    
    return randomString;
}
+ (NSString *)encodeToBase64String:(UIImage *)image {
    return [UIImagePNGRepresentation(image) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}


+(void) logoutUser
{
    [USER_DEFAULT setValue:@"" forKey:@"username"];
    [USER_DEFAULT setValue:@"" forKey:@"fname"];
    [USER_DEFAULT setValue:@"" forKey:@"lname"];
    [USER_DEFAULT setValue:@""  forKey:@"email"];
    [USER_DEFAULT setValue:@"" forKey:@"password"];
    [USER_DEFAULT setValue:@"" forKey:@"age"];
    [USER_DEFAULT setValue:@"" forKey:@"phone"];
    [USER_DEFAULT setValue:@"" forKey:@"zip"];
    [USER_DEFAULT setValue:@"" forKey:@"clubName"];
    [USER_DEFAULT setValue:@"" forKey:@"photo_url"];
    [USER_DEFAULT setValue:@"" forKey:@"userID"];
    [USER_DEFAULT setValue:@"" forKey:@"country"];
    [USER_DEFAULT setValue:@"" forKey:@"city"];

}

+(UIImage *)resizeImage:(UIImage *)image
{
    float actualHeight = image.size.height;
    float actualWidth = image.size.width;
    float maxHeight = 300.0;
    float maxWidth = 400.0;
    float imgRatio = actualWidth/actualHeight;
    float maxRatio = maxWidth/maxHeight;
    float compressionQuality = 0.5;//50 percent compression
    
    if (actualHeight > maxHeight || actualWidth > maxWidth)
    {
        if(imgRatio < maxRatio)
        {
            //adjust width according to maxHeight
            imgRatio = maxHeight / actualHeight;
            actualWidth = imgRatio * actualWidth;
            actualHeight = maxHeight;
        }
        else if(imgRatio > maxRatio)
        {
            //adjust height according to maxWidth
            imgRatio = maxWidth / actualWidth;
            actualHeight = imgRatio * actualHeight;
            actualWidth = maxWidth;
        }
        else
        {
            actualHeight = maxHeight;
            actualWidth = maxWidth;
        }
    }
    
    CGRect rect = CGRectMake(0.0, 0.0, actualWidth, actualHeight);
    UIGraphicsBeginImageContext(rect.size);
    [image drawInRect:rect];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    NSData *imageData = UIImageJPEGRepresentation(img, compressionQuality);
    UIGraphicsEndImageContext();
    
    return [UIImage imageWithData:imageData];
    
}


+ (void)downloadImageWithURL:(NSURL *)url completionBlock:(void (^)(BOOL succeeded, UIImage *image))completionBlock
{
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if ( !error )
                               {
                                   UIImage *image = [[UIImage alloc] initWithData:data];
                                   completionBlock(YES,image);
                               } else{
                                   completionBlock(NO,nil);
                               }
                               
                           }];
}
@end
