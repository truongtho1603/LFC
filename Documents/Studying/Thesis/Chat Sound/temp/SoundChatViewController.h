//
//  SoundChatViewController.h
//  temp
//
//  Created by MAC on 7/3/14.
//  Copyright (c) 2014 Tho Do. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RIOInterface.h"
#import "UIImage+animatedGIF.h"
#import "AppDelegate.h"
#import "ImageUtils.h"

@interface SoundChatViewController : UIViewController<UIAlertViewDelegate, RIOListenerDelegate, UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *chatInputView;

@property (strong, nonatomic) IBOutlet UIScrollView *insideEmoticonsScrollView;
@property (strong, nonatomic) IBOutlet UIImageView *emoticons;
@property (strong, nonatomic) IBOutlet UIButton *sendButton;
@property (strong, nonatomic) IBOutlet UILabel *genderLabel;
@property (strong, nonatomic) IBOutlet UITextField *messageField;


- (IBAction)messageFieldTextChanged:(id)sender;
- (IBAction)messageFieldTouchedDowm:(id)sender;
- (IBAction)sendButtonPressed:(id)sender;

@property(atomic, retain) NSString  *state;
@property(atomic) bool              isPlaying;
@property(atomic) bool              isRecording;

- (void)frequencyChangedWithValue:(float)newFrequency;

@end
