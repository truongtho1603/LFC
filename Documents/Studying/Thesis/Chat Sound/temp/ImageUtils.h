//
//  ImageUtils.h
//  LittleFunnyChicken
//
//  Created by MAC on 6/16/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageUtils : NSObject

+ (UIImage*) imageFromText:(NSString*)text inImage:(UIImage*)image atPoint:(CGPoint)point;
+ (UIImage*) scaleImage:(UIImage*)originalImage scaledToSize:(CGSize)size;

@end
