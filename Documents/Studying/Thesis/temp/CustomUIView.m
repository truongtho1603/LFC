//
//  CustomUIView.m
//  VNG_Week3
//
//  Created by Tho Do on 6/25/14.
//  Copyright (c) 2014 Tho Do. All rights reserved.
//

#import "CustomUIView.h"
#import <CoreText/CoreText.h>

@implementation CustomUIView
{
    NSAttributedString *content;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        content = [[NSAttributedString alloc] init];
        
        [self setBackgroundColor:[UIColor lightTextColor]];
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{    
    // draw link
    
    [content drawAtPoint:CGPointMake(0.f, 0.f)];
}

- (void)setTagContent:(NSAttributedString *)attributedString
{
    content = attributedString;
}

@end
