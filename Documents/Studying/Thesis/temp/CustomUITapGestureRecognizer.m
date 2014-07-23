//
//  CustomUITapGestureRecognizer.m
//  VNG_Week3
//
//  Created by Tho Do on 6/17/14.
//  Copyright (c) 2014 Tho Do. All rights reserved.
//

#import "CustomUITapGestureRecognizer.h"

@implementation CustomUITapGestureRecognizer

@synthesize _text = text;

- (void)addText:(NSString *)inputText
{
    text = inputText;
}

- (NSString *)getText
{
    return text;
}

- (id)initWithTarget:(id)target action:(SEL)action
{
    super.numberOfTapsRequired = 1;
    
    return [super initWithTarget:target action:action];
}

@end
