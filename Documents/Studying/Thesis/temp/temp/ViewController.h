//
//  ViewController.h
//  temp
//
//  Created by Tho Do on 6/26/14.
//  Copyright (c) 2014 Tho Do. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RIOInterface;

@interface ViewController : UIViewController
{
	BOOL isListening;
	RIOInterface *rioRef;
	float currentFrequency;
}

@property(nonatomic, assign) RIOInterface *rioRef;
@property(nonatomic, assign) float currentFrequency;
@property(assign) BOOL isListening;
@property (strong, nonatomic) IBOutlet UIButton *locateButton;

- (IBAction)toggleButton:(id)sender;
- (void)startListener;
- (void)stopListener;

- (void)frequencyChangedWithValue:(float)newFrequency;
- (void)updateFrequencyLabel;
- (void)useSecretResource:(NSDictionary*)items;

@end
