//
//  SoundChatViewController.m
//  temp
//
//  Created by MAC on 7/3/14.
//  Copyright (c) 2014 Tho Do. All rights reserved.
//

#import "SoundChatViewController.h"

@implementation SoundChatViewController
{
    UIView *emoticonsView;
    
    float iCountMessage;
    int yIndex;
    BOOL isEmoticonsPressed;
    BOOL isBoy;
    BOOL isEmoticonsShowing;
    BOOL isSendingText;
    
    // Class Objects
    AudioComponentInstance toneUnit;
    RIOInterface* recorder;
    double frequency;
	double sampleRate;
	double theta;
    NSTimer *_timer;
    float freqGetItem;
    float freqGetText;      // 18080 for boy, 18240 for girl
    float freqStopGetText;  // 18160 for boy, 18320 for girl
    float freqPadding;      // 18000 for boy, 18120 for girl
    int numberOfFired;
    float freqToPlay;
    NSString *sendingText;
    int cursorOfSendingText;
    NSString *receivedText;
    NSURL *iChat1_url;
    NSURL *iChat2_url;
    
    // AVAudioPlayer - use to play background music
    AVAudioPlayer* backgroundPlayer;
}

@synthesize state;      // Waiting, GetItem     // Waiting, GetText, Ready
@synthesize isPlaying;
@synthesize isRecording;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)initObjects{
    iCountMessage = 0;
    yIndex = 110;
    isEmoticonsPressed = NO;
    isEmoticonsShowing = NO;
    sampleRate = 44100;
    state = @"Waiting";
    freqGetItem = 18420;
    numberOfFired = 0;
    freqToPlay = 0;
    sendingText = @"";
    cursorOfSendingText = 0;
    receivedText = @"";
    
    iChat1_url = [[NSBundle mainBundle] URLForResource:@"iChat1" withExtension:@"png"];
    iChat2_url = [[NSBundle mainBundle] URLForResource:@"iChat2" withExtension:@"png"];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == -1) {
        if (buttonIndex == 0) {
            isBoy = YES;
            freqGetText = 18080;
            freqStopGetText = 18160;
            freqPadding = 18000;
        }
        else if (buttonIndex == 1) {
            isBoy = NO;
            freqGetText = 18240;
            freqStopGetText = 18320;
            freqPadding = 18120;
        }
        [self updateGenderLabel];
        [self startAudio];
    }
}

- (void)stateChange:(NSString*)newState {
    @synchronized(self) {
        state = newState;
    }
}

// Tho Do
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self initObjects];
    recorder = [RIOInterface sharedInstance];
    recorder.listener = self;
    
    // Custom initialization
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Welcome!"
                                                     message:@"You are boy or girl?"
                                                    delegate:self
                                           cancelButtonTitle:@"Boy"
                                           otherButtonTitles:@"Girl", nil];
    alert.tag = -1;
    [alert show];
    
    UIView *myInitView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
    
    UISwitch *genderSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(([[UIScreen mainScreen] bounds].size.width - 50) / 2, ([[UIScreen mainScreen] bounds].size.height - 25) / 2, 50, 25)];
    [genderSwitch addTarget:self action:@selector(genderChanged:) forControlEvents:UIControlEventValueChanged];
    
    UILabel *maleLabel = [[UILabel alloc] initWithFrame:CGRectMake(45, ([[UIScreen mainScreen] bounds].size.height - 45) / 2, 50, 50)];
    maleLabel.text = @"Nam";
    
    UILabel *femaleLabel = [[UILabel alloc] initWithFrame:CGRectMake(([[UIScreen mainScreen] bounds].size.width + 200) / 2, ([[UIScreen mainScreen] bounds].size.height - 45) / 2, 50, 50)];
    femaleLabel.text = @"Nữ";
    
    [myInitView addSubview:maleLabel];
    [myInitView addSubview:femaleLabel];
    [myInitView addSubview:genderSwitch];
    
    //[self.view addSubview:myInitView];
    
    
    // Tho Do
    // My codelines here
    // Scroll view
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewTouched:)];
    [[self scrollView] setContentSize:CGSizeMake(320, 480)];
    [[self scrollView] addGestureRecognizer:tapGesture];
    [[self scrollView] setBackgroundColor:[UIColor lightTextColor]];
    
    // Gender label
    [[self genderLabel] setBackgroundColor:[UIColor blueColor]];
    [[self genderLabel] setTextColor:[UIColor redColor]];
    
    // Message field
    [[self messageField] setPlaceholder:@"Tin nhắn..."];
    [[self messageField] setAutocorrectionType:UITextAutocorrectionTypeNo];
    
    // Emoticons
    [[self emoticons] setImage:[UIImage imageNamed:@"emo.png"]];
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(emoticonsPressed)];
    [singleTap setNumberOfTapsRequired:1];
    [singleTap setNumberOfTouchesRequired:1];
    [[self emoticons] addGestureRecognizer:singleTap];
    [[self emoticons] setUserInteractionEnabled:YES];
    
    // Text field keyboard
    [[self messageField] setReturnKeyType:UIReturnKeyDone];
    [[self messageField] setDelegate:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveHomeNotification:) name:@"HomeNotification"
        object:nil];
}

- (void)scrollViewTouched:(id)sender
{
    [self chatInputViewReturnToNormal];
    [self textFieldShouldReturn:self.messageField];
    isEmoticonsPressed = YES;
}

- (void)genderChanged:(id)sender
{
    BOOL genderState = [sender isOn];
    
    if (genderState == NO)
    {
        isBoy = YES;
        freqGetText = 18080;
        freqStopGetText = 18160;
        freqPadding = 18000;
    }
    else
    {
        isBoy = NO;
        freqGetText = 18240;
        freqStopGetText = 18320;
        freqPadding = 18120;
    }
    [self updateGenderLabel];
    [self startAudio];
}

- (void) receiveHomeNotification:(NSNotification *) notification
{
    // Remove Timers
    [self stopTimer];
    // Stop background music
    if (backgroundPlayer != nil) {
        [backgroundPlayer stop];
        backgroundPlayer = nil;
    }
    // Stop Playback
    while (isPlaying)
        [self stop];
}

// Tho Do
// Gender switched
- (void)updateGenderLabel {
    if(isBoy){
        [[self genderLabel] setBackgroundColor:[UIColor orangeColor]];
        [[self genderLabel] setText:@"Nam"];
        [[self genderLabel] setTextColor:[UIColor blueColor]];
    }
    else{
        [[self genderLabel] setBackgroundColor:[UIColor blueColor]];
        [[self genderLabel] setText:@"Nữ"];
        [[self genderLabel] setTextColor:[UIColor redColor]];
    }
    [self chatInputViewReturnToNormal];
    isEmoticonsPressed = !isEmoticonsPressed;
    if(!(isEmoticonsShowing) && (isEmoticonsPressed)){
        isEmoticonsPressed = !isEmoticonsPressed;
    }
}


#pragma mark - emoticons
- (void)emoticonsPressed{
    [self cleanThumbnails:1 to:50];
    
    if(!isEmoticonsPressed){
        [self chatInputViewPushup];
        emoticonsView = [[UIView alloc] initWithFrame:CGRectMake(0, 51, 320, 350)];
        [emoticonsView setBackgroundColor:[UIColor lightTextColor]];
        
        // Inside Emoticons Scroll View images
        // Inside Emoticons Scroll View
        [[self insideEmoticonsScrollView] setContentSize:CGSizeMake(320, 350)];
        [[self insideEmoticonsScrollView] setBackgroundColor:[UIColor lightTextColor]];
        // Set offset to top left
        [[self insideEmoticonsScrollView] setContentOffset:CGPointMake(0, 0) animated:YES];
        
        // Add images to Inside Emoticons Scroll View
        int iD = 1;
        if(isBoy){
            [self drawThumbnails:iD to:25];
        }
        else{
            iD = 26;
            [self drawThumbnails:iD to:50];
        }
    }
    else{
        [self chatInputViewReturnToNormal];
        [self textFieldShouldReturn:self.messageField];
    }
    isEmoticonsPressed = !isEmoticonsPressed;
}

#pragma mark - Thumbnails

// Tho Do
// cleanThumbnails
- (void)cleanThumbnails:(int)from to:(int)to{
    int tag = from;
    // Remove images draw above
    for(int i = 0; i < 13; i++){
        for(int j = 0; j < 4; j++){
            if(tag <= to){
                UIImageView *thumb = (UIImageView *)[[self view] viewWithTag:tag];
                [thumb removeFromSuperview];
                tag++;
            }
        }
    }
}

// Tho Do
// Draw thumbnails from iD to iD
- (void)drawThumbnails:(int)iD to:(int)maxId{
    for(int i = 0; i < 13; i++){
        for(int j = 0; j < 4; j++){
            if(iD <= maxId){
                UIImageView *thumb = [[UIImageView alloc] initWithFrame:CGRectMake(15*j+70*j, 20*(i+1)+70*i, 70, 70)];
                NSString *imgId = [NSString stringWithFormat:@"%02d.png", iD];
                [thumb setImage:[UIImage imageNamed:imgId]];
                
                // set Tag for each image view for latter manipulation
                [thumb setTag:iD];
                [[self insideEmoticonsScrollView] addSubview:thumb];
                
                // Add tap gesture and selector delegate
                UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(thumbnailsPressed:)];
                [singleTap setNumberOfTapsRequired:1];
                [singleTap setNumberOfTouchesRequired:1];
                [thumb addGestureRecognizer:singleTap];
                [thumb setUserInteractionEnabled:YES];
                
                // inCrease iD for next thumbnails
                iD++;
                [[self insideEmoticonsScrollView] setContentSize:CGSizeMake(320, i*120)];
            }
        }
    }
}

// Tho Do
// Thumbnails pressed
- (void)thumbnailsPressed:(UITapGestureRecognizer *)gr{
    if (isPlaying)
        return;
    // Change sending state, stop playback and stop timer
    isSendingText = NO;
    if (!isPlaying)
        [self play];
    [self stopTimer];
    
    // Send directly to main scroll view
    UIImageView *theTappedImageView = (UIImageView *)[gr view];
    long tagId = [theTappedImageView tag];
    
    // Emoticons thumbnails
    if (tagId > 0) {
        freqToPlay = [self indexToFreq:tagId];
        //[self playASong:@"Part2" withExtension:@"wav" andLoops:0];
        [self startTimer];
    }
    
    // Switch on
    NSURL *url = [[NSBundle mainBundle] URLForResource:[NSString stringWithFormat:@"%02ld",tagId] withExtension:@"gif"];
    UIImageView* imageView;
    // Add GIF to main scroll view
    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(220, iCountMessage * yIndex, 100, 100)];
    // Add GIF to main scroll view
    [imageView setImage:[UIImage animatedImageWithAnimatedGIFURL:url]];
    [[self scrollView] addSubview:imageView];
    iCountMessage++;
    
    // Increase content size for more items in scroll view
    [[self scrollView] setContentSize:CGSizeMake(320, 1100 + (iCountMessage-10) * yIndex)];
    
    // Bounce to bottom item as we adding it to scroll view
    CGPoint bottomOffset;
    if (isEmoticonsShowing){
        if([[UIScreen mainScreen] bounds].size.height == 568)
            bottomOffset = CGPointMake(0, [self scrollView].contentSize.height - 260);
        else
            bottomOffset = CGPointMake(0, [self scrollView].contentSize.height - 180);
    }
    else{
        if([[UIScreen mainScreen] bounds].size.height == 568)
            bottomOffset = CGPointMake(0, [self scrollView].contentSize.height - 480);
        else
            bottomOffset = CGPointMake(0, [self scrollView].contentSize.height - 400);
    }
    [[self scrollView] setContentOffset:bottomOffset animated:YES];
    // End switch on
}


#pragma mark - send button
// Tho Do
// Send button
- (IBAction)sendButtonPressed:(id)sender {
    if (isPlaying)
        return;
    if ([[[self messageField] text] isEqualToString:@""])
        return;
    
    // Change sending state, stop playback and stop timer
    isSendingText = YES;
    if (!isPlaying)
        [self play];
    [self stopTimer];
    
    sendingText = [[self messageField] text];
    NSString* _sendingText = sendingText;
    // Add head and tail signal
    NSString* temp = @"";
    for (int i=0; i<[sendingText length]; i++)
        temp = [NSString stringWithFormat:@"%@%c%c", temp, [self freqToChar:freqPadding], [sendingText characterAtIndex:i]];
    sendingText = temp;
    
    sendingText = [NSString stringWithFormat:@"%c%@%c", [self freqToChar:freqGetText], sendingText, [self freqToChar:freqStopGetText]];
    [[self messageField] setText:@""];
    cursorOfSendingText = 0;
    
    //[self playASong:@"Part2" withExtension:@"wav" andLoops:3];
    [self startTimer];
    
    UIImage* image = [UIImage imageWithData:[NSData dataWithContentsOfURL:iChat1_url]];
    if (image == nil) {
        sendingText = @"";
        return;
    }
    float textWidth = [self widthOfString:_sendingText] * 1.6f;
    textWidth = textWidth > 80 ? textWidth : 80;
    image = [ImageUtils scaleImage:image scaledToSize:CGSizeMake(textWidth, image.size.height * 2)];
    
    float indent = textWidth / 13.0f > 8 ? textWidth / 13.0f : 8;
    //image = [ImageUtils imageFromText:_sendingText inImage:image atPoint:CGPointMake(indent, 10)];
    
    // Tho Do
    UILabel *sms = [[UILabel alloc] initWithFrame:CGRectMake(indent, -10, textWidth, 50)];
    sms.text = _sendingText;
    
    UIImageView* imageView;
    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(310.0f - image.size.width, iCountMessage * yIndex, image.size.width, 20 * 1.5)];
    [imageView setImage:image];
    [imageView addSubview:sms];
    [[self scrollView] addSubview:imageView];
    iCountMessage += 0.35;
    
    // Increase content size for more items in scroll view
    [[self scrollView] setContentSize:CGSizeMake(320, 1100 + (iCountMessage-10) * yIndex)];
    
    // Bounce to bottom item as we adding it to scroll view
    CGPoint bottomOffset;
    if (isEmoticonsShowing){
        if([[UIScreen mainScreen] bounds].size.height == 568)
            bottomOffset = CGPointMake(0, [self scrollView].contentSize.height - 260);
        else
            bottomOffset = CGPointMake(0, [self scrollView].contentSize.height - 180);
    }
    else{
        if([[UIScreen mainScreen] bounds].size.height == 568)
            bottomOffset = CGPointMake(0, [self scrollView].contentSize.height - 480);
        else
            bottomOffset = CGPointMake(0, [self scrollView].contentSize.height - 400);
    }
    [[self scrollView] setContentOffset:bottomOffset animated:YES];
    // End switch on
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return interfaceOrientation == UIInterfaceOrientationPortrait;
}

#pragma mark - keyboard

// Tho Do
// Dismiss keyboard
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    
    [self chatInputViewReturnToNormal];
    
    return YES;
}

#pragma mark - text field message

#define MAX_LENGTH 15
#define CHARACTER_ONLY @"abcdefghijklmnopqrstuvwxyz 0123456789"

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString*)string
{
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    if(newLength > MAX_LENGTH){
        return NO;
    }
    
    NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:CHARACTER_ONLY] invertedSet];
    NSString *filteredstring  = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    return ([string isEqualToString:filteredstring]);
}

// Tho Do
// Message field text changed
- (IBAction)messageFieldTextChanged:(id)sender {
    // Check input setting here
    isEmoticonsPressed = YES;
}

// Tho Do
// Message field touched
- (IBAction)messageFieldTouchedDowm:(id)sender {
    [self chatInputViewPushup];
    isEmoticonsPressed = YES;
}

- (IBAction)messageFieldEditingDidBegin:(id)sender {
    [self chatInputViewPushup];
    isEmoticonsPressed = YES;
}

#pragma mark - chat view

// Tho Do
// Push up components
- (void)chatInputViewPushup{
    isEmoticonsShowing = YES;
    if([[UIScreen mainScreen] bounds].size.height == 568){
        // Inside Emoticons Scroll View push up
        [[self insideEmoticonsScrollView] setFrame:CGRectMake(0, 350, 320, 250)];
        
        // Emoticons push up
        [[self emoticons] setFrame:CGRectMake(5, 321, 31, 31)];
        
        // Message field push up
        [[self messageField] setFrame:CGRectMake(46, 320, 220, 30)];
        
        // Send buttons push up
        [[self sendButton] setFrame:CGRectMake(274, 320, 46, 30)];
    }
    else{
        // Inside Emoticons Scroll View push up
        [[self insideEmoticonsScrollView] setFrame:CGRectMake(0, 260, 320, 250)];
        
        // Emoticons push up
        [[self emoticons] setFrame:CGRectMake(5, 231, 31, 31)];
        
        // Message field push up
        [[self messageField] setFrame:CGRectMake(46, 231, 220, 30)];
        
        // Send buttons push up
        [[self sendButton] setFrame:CGRectMake(274, 231, 46, 30)];
    }
    // Bounce to bottom item as we adding it to scroll view
    CGPoint bottomOffset;
    if([[UIScreen mainScreen] bounds].size.height == 568)
        bottomOffset = CGPointMake(0, [self scrollView].contentSize.height - 260);
    else
        bottomOffset = CGPointMake(0, [self scrollView].contentSize.height - 180);
    [[self scrollView] setContentOffset:bottomOffset animated:YES];
}

// Tho Do
// Return to normal position components
- (void)chatInputViewReturnToNormal{
    isEmoticonsShowing = NO;
    if([[UIScreen mainScreen] bounds].size.height == 568){
        // Inside Emoticons Scroll View return to normal
        [[self insideEmoticonsScrollView] setFrame:CGRectMake(0, 600, 320, 250)];
        
        // Emoticons return to normal position
        [[self emoticons] setFrame:CGRectMake(5, 528, 31, 31)];
        
        // Message field return to normal position
        [[self messageField] setFrame:CGRectMake(46, 527, 220, 30)];
        
        // Send buttons return to normal position
        [[self sendButton] setFrame:CGRectMake(274, 527, 46, 30)];
    }
    else{
        // Inside Emoticons Scroll View return to normal
        [[self insideEmoticonsScrollView] setFrame:CGRectMake(0, 520, 320, 250)];
        
        // Emoticons return to normal position
        [[self emoticons] setFrame:CGRectMake(5, 446, 31, 31)];
        
        // Message field return to normal position
        [[self messageField] setFrame:CGRectMake(46, 447, 220, 30)];
        
        // Send buttons return to normal position
        [[self sendButton] setFrame:CGRectMake(274, 447, 46, 30)];
    }
    // Bounce to bottom item as we adding it to scroll view
    CGPoint bottomOffset;
    if([[UIScreen mainScreen] bounds].size.height == 568)
        bottomOffset = CGPointMake(0, [self scrollView].contentSize.height - 480);
    else
        bottomOffset = CGPointMake(0, [self scrollView].contentSize.height - 400);
    [[self scrollView] setContentOffset:bottomOffset animated:YES];
}

- (void)loadImageByReceivedFrequency:(int)tagId {
    // Switch on
    NSURL *url = [[NSBundle mainBundle] URLForResource:[NSString stringWithFormat:@"%02d",tagId] withExtension:@"gif"];
    if (url == nil)
        return;
    UIImage* image = [UIImage animatedImageWithAnimatedGIFURL:url];
    if (image == nil)
        return;
    UIImageView* imageView;
    
    // Add GIF to main scroll view
    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, iCountMessage * yIndex, 100, 100)];
    // Add GIF to main scroll view
    [imageView setImage:image];
    [[self scrollView] addSubview:imageView];
    iCountMessage++;
    
    // Increase content size for more items in scroll view
    [[self scrollView] setContentSize:CGSizeMake(320, 1100 + (iCountMessage-10) * yIndex)];
    
    // Bounce to bottom item as we adding it to scroll view
    CGPoint bottomOffset;
    if (isEmoticonsShowing){
        if([[UIScreen mainScreen] bounds].size.height == 568)
            bottomOffset = CGPointMake(0, [self scrollView].contentSize.height - 260);
        else
            bottomOffset = CGPointMake(0, [self scrollView].contentSize.height - 180);
    }
    else{
        if([[UIScreen mainScreen] bounds].size.height == 568)
            bottomOffset = CGPointMake(0, [self scrollView].contentSize.height - 480);
        else
            bottomOffset = CGPointMake(0, [self scrollView].contentSize.height - 400);
    }
    [[self scrollView] setContentOffset:bottomOffset animated:YES];
    // End switch on
}

- (void)frequencyChangedWithValue:(float)newFrequency{
	if (newFrequency >= recorder.MIN_FREQ && newFrequency <= recorder.MAX_FREQ)  // to avoid environmental noise
    {
        NSLog(@"%f", newFrequency);
        
        float newTextFrequency = newFrequency;
        
        newFrequency = roundf(newFrequency / 30) * 30;
        int index = [self freqToIndex:newFrequency];
        if ([state isEqualToString:@"Waiting"]) {
            if (newFrequency == freqGetItem) {
                [self stateChange:@"GetItem"];
                return;
            }
        }
        if ([state isEqualToString:@"GetItem"]) {
            if (newFrequency != freqGetItem) {
                [self stateChange:@"Waiting"];
                if ((isBoy && index > 25) || (!isBoy && index <= 25))
                    [self loadImageByReceivedFrequency:index];
                return;
            }
        }
        
        newTextFrequency = roundf(newTextFrequency / 40) * 40;
        if (isBoy) {
            if ([state isEqualToString:@"Waiting"] && newTextFrequency == freqGetText + 160) {
                [self stateChange:@"GetText"];
                return;
            }
            if ([state isEqualToString:@"GetText"]) {
                if (newTextFrequency == freqPadding + 120) {
                    [self stateChange:@"Ready"];
                    return;
                }
                if (newTextFrequency == freqStopGetText + 160) {
                    [self stateChange:@"Waiting"];
                    [self performSelectorInBackground:@selector(receivedText:) withObject:nil];
                    return;
                }
            }
            if ([state isEqualToString:@"Ready"]) {
                if (newTextFrequency > freqStopGetText + 160) {
                    [self stateChange:@"GetText"];
                    char c = [self freqToChar:newTextFrequency];
                    receivedText = [NSString stringWithFormat:@"%@%c", receivedText, c];
                    return;
                }
                if (newTextFrequency == freqStopGetText + 160) {
                    [self stateChange:@"Waiting"];
                    [self performSelectorInBackground:@selector(receivedText:) withObject:nil];
                    return;
                }
            }
        }
        else {
            if ([state isEqualToString:@"Waiting"] && newTextFrequency == freqGetText - 160) {
                [self stateChange:@"GetText"];
                return;
            }
            if ([state isEqualToString:@"GetText"]) {
                if (newTextFrequency == freqPadding - 120) {
                    [self stateChange:@"Ready"];
                    return;
                }
                if (newTextFrequency == freqStopGetText - 160) {
                    [self stateChange:@"Waiting"];
                    [self performSelectorInBackground:@selector(receivedText:) withObject:nil];
                    return;
                }
            }
            if ([state isEqualToString:@"Ready"]) {
                if (newTextFrequency > freqStopGetText) {
                    [self stateChange:@"GetText"];
                    char c = [self freqToChar:newTextFrequency];
                    receivedText = [NSString stringWithFormat:@"%@%c", receivedText, c];
                    return;
                }
                if (newTextFrequency == freqStopGetText - 160) {
                    [self stateChange:@"Waiting"];
                    [self performSelectorInBackground:@selector(receivedText:) withObject:nil];
                    return;
                }
            }
        }
    }
}

- (void)receivedText:(id)object {
    UIImage* image = [UIImage imageWithData:[NSData dataWithContentsOfURL:iChat2_url]];
    if (image == nil) {
        receivedText = @"";
        return;
    }
    float textWidth = [self widthOfString:receivedText] * 1.6f;
    textWidth = textWidth > 80 ? textWidth : 80;
    image = [ImageUtils scaleImage:image scaledToSize:CGSizeMake(textWidth, image.size.height)];
    float indent = textWidth / 13.0f > 8 ? textWidth / 13.0f : 8;
    //image = [ImageUtils imageFromText:receivedText inImage:image atPoint:CGPointMake(indent, 10)];
    
    // Tho Do
    UILabel *sms = [[UILabel alloc] initWithFrame:CGRectMake(indent, -10, textWidth, 50)];
    sms.text = receivedText;
    
    UIImageView* imageView;
    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, iCountMessage * yIndex, image.size.width, 20 * 1.5)];
    [imageView setImage:image];
    [imageView addSubview:sms];
    [[self scrollView] addSubview:imageView];
    iCountMessage += 0.35;
    
    // Increase content size for more items in scroll view
    [[self scrollView] setContentSize:CGSizeMake(320, 1100 + (iCountMessage-10) * yIndex)];
    
    // Bounce to bottom item as we adding it to scroll view
    CGPoint bottomOffset;
    if (isEmoticonsShowing){
        if([[UIScreen mainScreen] bounds].size.height == 568)
            bottomOffset = CGPointMake(0, [self scrollView].contentSize.height - 260);
        else
            bottomOffset = CGPointMake(0, [self scrollView].contentSize.height - 180);
    }
    else{
        if([[UIScreen mainScreen] bounds].size.height == 568)
            bottomOffset = CGPointMake(0, [self scrollView].contentSize.height - 480);
        else
            bottomOffset = CGPointMake(0, [self scrollView].contentSize.height - 400);
    }
    [[self scrollView] setContentOffset:bottomOffset animated:YES];
    // End switch on
    
    receivedText = @"";
}

#pragma mark - timer

/*
 * Timer's area
 */
- (void)startTimer{
    if (!_timer) {
        if (!isSendingText) {
            _timer = [NSTimer scheduledTimerWithTimeInterval:0.2f
                                                      target:self
                                                    selector:@selector(_timerFired:)
                                                    userInfo:nil
                                                     repeats:YES];
        }
        else {
            _timer = [NSTimer scheduledTimerWithTimeInterval:0.4f
                                                      target:self
                                                    selector:@selector(_timerFired:)
                                                    userInfo:nil
                                                     repeats:YES];
        }
    }
}

- (void)stopTimer{
    if ([_timer isValid]) {
        [_timer invalidate];
    }
    
    _timer = nil;
}

- (void)_timerFired:(NSTimer *)timer {
    if (!isSendingText) {
        if (numberOfFired == 0) {
            [self freqChanged:freqGetItem];
        }
        if (numberOfFired == 1) {
            [self freqChanged:freqToPlay];
        }
        if (!isPlaying)
            [self play];
        if (numberOfFired == 2) {
            if (isPlaying) {
                [self stopTimer];
                [self stop];
                numberOfFired = 0;
                return;
            }
        }
        numberOfFired++;
    }
    else {
        if (cursorOfSendingText >= [sendingText length]) {
            [self stopTimer];
            [self stop];
            return;
        }
        char c = [sendingText characterAtIndex:cursorOfSendingText];
        [self freqChanged:[self charToFreq:c]];
        if (!isPlaying)
            [self play];
        cursorOfSendingText++;
    }
}


#pragma mark - playback

/*
 *  Playback Area
 */
OSStatus RenderTone(
                     void *inRefCon,
                     AudioUnitRenderActionFlags 	*ioActionFlags,
                     const AudioTimeStamp 		*inTimeStamp,
                     UInt32 						inBusNumber,
                     UInt32 						inNumberFrames,
                     AudioBufferList 			*ioData)

{
    // Fixed amplitude is good enough for our purposes
    const double amplitude = 2;
    
	// Get the tone parameters out of the view controller
	SoundChatViewController *viewController = (__bridge SoundChatViewController *)inRefCon;
	double theta = viewController->theta;
	double theta_increment = 2.0 * M_PI * viewController->frequency / viewController->sampleRate;
    
	// This is a mono tone generator so we only need the first buffer
	const int channel = 0;
	Float32 *buffer = (Float32 *)ioData->mBuffers[channel].mData;
	
	// Generate the samples
	for (UInt32 frame = 0; frame < inNumberFrames; frame++)
	{
		buffer[frame] = sin(theta) * amplitude;
		
		theta += theta_increment;
		if (theta > 2.0 * M_PI)
		{
			theta -= 2.0 * M_PI;
		}
	}
	
	// Store the theta back in the view controller
	viewController->theta = theta;
    
	return noErr;
}

void ToneInterruptionListener(void *inClientData, UInt32 inInterruptionState)
{
	SoundChatViewController *viewController = (__bridge SoundChatViewController *)inClientData;
	[viewController stop];
}

- (void)freqChanged:(double)freq
{
	frequency = freq;
}

- (void)createToneUnit
{
	// Configure the search parameters to find the default playback output unit
	// (called the kAudioUnitSubType_RemoteIO on iOS but
	// kAudioUnitSubType_DefaultOutput on Mac OS X)
	AudioComponentDescription defaultOutputDescription;
	defaultOutputDescription.componentType = kAudioUnitType_Output;
	defaultOutputDescription.componentSubType = kAudioUnitSubType_RemoteIO;
	defaultOutputDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
	defaultOutputDescription.componentFlags = 0;
	defaultOutputDescription.componentFlagsMask = 0;
	
	// Get the default playback output unit
	AudioComponent defaultOutput = AudioComponentFindNext(NULL, &defaultOutputDescription);
	NSAssert(defaultOutput, @"Can't find default output");
	
	// Create a new unit based on this that we'll use for output
	OSErr err = AudioComponentInstanceNew(defaultOutput, &toneUnit);
	
	// Set our tone rendering function on the unit
	AURenderCallbackStruct input;
	input.inputProc = RenderTone;
	input.inputProcRefCon = (__bridge void *)(self);
	err = AudioUnitSetProperty(toneUnit,
                               kAudioUnitProperty_SetRenderCallback,
                               kAudioUnitScope_Input,
                               0,
                               &input,
                               sizeof(input));
	
	// Set the format to 32 bit, single channel, floating point, linear PCM
	const int four_bytes_per_float = 4;
	const int eight_bits_per_byte = 8;
	AudioStreamBasicDescription streamFormat;
	streamFormat.mSampleRate = sampleRate;
	streamFormat.mFormatID = kAudioFormatLinearPCM;
    streamFormat.mFormatFlags =
#ifndef ANDROID
	kAudioFormatFlagsNativeFloatPacked | kAudioFormatFlagIsNonInterleaved;
#endif
#ifdef ANDROID
    kAudioFormatFlagIsFloat | kAudioFormatFlagsNativeEndian | kAudioFormatFlagIsPacked | kAudioFormatFlagIsNonInterleaved;
#endif
	streamFormat.mBytesPerPacket = four_bytes_per_float;
	streamFormat.mFramesPerPacket = 1;
	streamFormat.mBytesPerFrame = four_bytes_per_float;
	streamFormat.mChannelsPerFrame = 1;
	streamFormat.mBitsPerChannel = four_bytes_per_float * eight_bits_per_byte;
	err = AudioUnitSetProperty (toneUnit,
                                kAudioUnitProperty_StreamFormat,
                                kAudioUnitScope_Input,
                                0,
                                &streamFormat,
                                sizeof(AudioStreamBasicDescription));
}

- (void)play
{
	if (toneUnit == nil)
	{
		[self createToneUnit];
		
		// Stop changing parameters on the unit
		OSErr err = AudioUnitInitialize(toneUnit);
		
		// Start playback
		err = AudioOutputUnitStart(toneUnit);
		
        isPlaying = YES;
	}
}

- (void)stop
{
	if (toneUnit != nil)
	{
        isPlaying = NO;
		AudioOutputUnitStop(toneUnit);
		AudioUnitUninitialize(toneUnit);
		AudioComponentInstanceDispose(toneUnit);
		toneUnit = nil;
	}
}

#pragma mark - record

/*
 *  Record Area
 */
void interruptionListenerCallback(void *inUserData, UInt32 interruptionState)
{
	
}

/*
 * Starts recording from the microphone. Also starts the audio player.
 */
- (void)startAudio
{
	[recorder startListening];
    isRecording = YES;
}

/*
 * Stops recording from the microphone. Also stops the audio player.
 */
- (void)stopAudio
{
	[recorder stopListening];
    isRecording = NO;
}

#pragma mark - frequency manipulation

/*
 * General functions
 */
- (float)indexToFreq:(long)index{
    return 18510 + index * 30;
}

- (int)freqToIndex:(float)freq{
    return (freq - 18510) / 30;
}

- (void)playASong:(NSString*)fileName withExtension:(NSString*)extension andLoops:(int)loops {
    if (backgroundPlayer != nil)
    {
        [backgroundPlayer stop];
        backgroundPlayer = nil;
    }
    // Audio player
    NSError* error;
    NSURL *audioFileLocationURL = [[NSBundle mainBundle] URLForResource:fileName withExtension:extension];
    backgroundPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:audioFileLocationURL error:&error];
    [backgroundPlayer setNumberOfLoops:loops];
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
        NSLog(@"Can not read audio file");
    }
    else {
        //Load the audio into memory
        [backgroundPlayer prepareToPlay];
        [backgroundPlayer setVolume:1.0f];
        [backgroundPlayer play];
    }
}

- (float)charToFreq:(char)c{
    int i = (int)c;
    if (i == 32)    // white-space
        i = 86;
    if (48 <= i && i <= 57)     // 0 - 9
        i += 39;
    return 18400 + (i - 86) * 40;
}

- (char)freqToChar:(float)freq{
    int i = (freq - 18400) / 40 + 86;
    if (i == 86)    // white-space
        i = 32;
    if (87 <= i && i <= 96)     // 0 - 9
        i -= 39;
    return (char)i;
}

- (CGFloat)widthOfString:(NSString *)string {
    UIFont *font = [UIFont boldSystemFontOfSize:12];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
    return [[[NSAttributedString alloc] initWithString:string attributes:attributes] size].width;
}

@end
