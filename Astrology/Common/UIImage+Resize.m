//
//  UIImage+Resize.m
//  Touch
//
//  Created by Cungtk on 2/22/14.
//  Copyright (c) 2014 com. All rights reserved.
//

#import "UIImage+Resize.h"

@implementation UIImage (Resize)

- (UIImage *)resizeImage:(UIImage*)image newSize:(CGSize)newSize
{
//    CGRect newRect = CGRectIntegral(CGRectMake(0, 0, newSize.width, newSize.height));
//    CGImageRef imageRef = image.CGImage;
//    
//    UIGraphicsBeginImageContextWithOptions(newSize, NO, 1);
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    
//    // Set the quality level to use when rescaling
//    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
//    CGAffineTransform flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, newSize.height);
//    
//    CGContextConcatCTM(context, flipVertical);
//    // Draw into the context; this scales the image
//    CGContextDrawImage(context, newRect, imageRef);
//    
//    // Get the resized image from the context and a UIImage
//    CGImageRef newImageRef = CGBitmapContextCreateImage(context);
//    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
//    
//    CGImageRelease(newImageRef);
//    UIGraphicsEndImageContext();
//    
//    return newImage;
    
    CGRect newRect = CGRectMake(0, 0, newSize.width, newSize.height);
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:newRect blendMode:kCGBlendModePlusDarker alpha:1];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end
