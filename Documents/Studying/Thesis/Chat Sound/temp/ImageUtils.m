//
//  ImageUtils.m
//  LittleFunnyChicken
//
//  Created by MAC on 6/16/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "ImageUtils.h"

@implementation ImageUtils

+ (UIImage*) imageFromText:(NSString*)text inImage:(UIImage*)image atPoint:(CGPoint)point
{
    
    UIFont *font = [UIFont boldSystemFontOfSize:12];
    // check if UIGraphicsBeginImageContextWithOptions is available (iOS is 4.0+)
    if (UIGraphicsBeginImageContextWithOptions != NULL)
        UIGraphicsBeginImageContextWithOptions(image.size, NO, 0.0f);
    else
        // iOS is < 4.0
        UIGraphicsBeginImageContext(image.size);
    [image drawInRect:CGRectMake(0.0f, 0.0f, image.size.width, image.size.height)];
    CGRect rect = CGRectMake(point.x, point.y, image.size.width, image.size.height);
    NSDictionary *dictionary = @{ NSFontAttributeName: font,
                                  NSForegroundColorAttributeName: [UIColor blackColor]};
    [text drawInRect:CGRectIntegral(rect) withAttributes:dictionary];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (UIImage *)scaleImage:(UIImage*)originalImage scaledToSize:(CGSize)size
{
    //avoid redundant drawing
    if (CGSizeEqualToSize(originalImage.size, size))
    {
        return originalImage;
    }
    
    // check if UIGraphicsBeginImageContextWithOptions is available (iOS is 4.0+)
    if (UIGraphicsBeginImageContextWithOptions != NULL)
        UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
    else
        // iOS is < 4.0
        UIGraphicsBeginImageContext(size);
    
    //draw
    [originalImage drawInRect:CGRectMake(0.0f, 0.0f, size.width, size.height)];
    
    //capture resultant image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //return image
    return image;
}

@end
