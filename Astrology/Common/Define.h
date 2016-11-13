//
//  Define.h
//  Saverpassport
//
//  Created by Phan Minh Tam on 6/9/14.
//  Copyright (c) 2015 Phan Minh Tam. All rights reserved.
//

#ifndef Define_h

#define APP_NAME                @"Astrologers Heaven"

#define NETWORK_DISCONNECT      @"No Internet Connection Available. Please try again."
//ERROR
#define EROOR_MISS_USERNAME     @"Username is required."
#define ERROR_MISS_EMAIL       @"Your email is required."
#define ERROR_EMAIL_FORMAT      @"Your email is invalid."
#define ERROR_MISS_PASSWORD     @"Password is required."
#define ERROR_MISS_CURRENT_PASSWORD     @"Current password is required."
#define ERROR_MISS_CURRENT_PASSWORD_MATCH     @"Current Password does not match."
#define ERROR_MISS_NEW_PASSWORD @"New password is required."
#define EROOR_MISS_FIRSTNAME     @"First name is required."
#define EROOR_MISS_LASTNAME     @"Last name is required."
#define EROOR_MISS_AGE     @"Age is required."
#define EROOR_MISS_PHONE     @"Phone is required."
#define EROOR_MISS_ZIPCODE     @"Zipcode is required."
#define EROOR_MISS_CITY     @"City is required."
#define EROOR_MISS_TERM     @"Term and Conditions is required."

#define Cat_GeneralPhotos 1
#define Cat_Videos 2
#define Cat_Vehicles 3
#define Cat_Garages 4
#define Cat_Events 5

#define UD_FB_USER_DETAIL @"FacebookUserDetail"
#define UD_FB_LOGIN_REQUEST @"FacebookLoginRequest"
#define UD_FB_TOKEN @"FacebookToken"
#define FBID @"1417858111854756"

#define USER_DEFAULT [NSUserDefaults standardUserDefaults]
#define trimString(str) [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
#define IS_IPAD [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad

#define APP_TOKEN   @"capitol-es-are-dev"
//---#define WS_LINK     @"http://capitolstreet.vndsupport.com/api/"
#define WS_LINK     @"http://test-api.darumble.com/api/"

//#define WS_LINK @"capitolstreet.vndsupport.com"
#define k_add_user_success @"k_add_user_success"
#define k_add_user_fail @"k_add_user_fail"


#endif
