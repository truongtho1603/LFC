//
//  CustomUITapGestureRecognizer.h
//  VNG_Week3
//
//  Created by Tho Do on 6/17/14.
//  Copyright (c) 2014 Tho Do. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomUITapGestureRecognizer : UITapGestureRecognizer

@property(retain) NSString * _text;

- (void)addText:(NSString *)inputText;

- (NSString *)getText;

- (id)initWithTarget:(id)target action:(SEL)action;

@end
