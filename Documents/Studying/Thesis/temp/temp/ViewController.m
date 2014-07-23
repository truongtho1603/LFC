//
//  ViewController.m
//  temp
//
//  Created by Tho Do on 6/26/14.
//  Copyright (c) 2014 Tho Do. All rights reserved.
//

#import "ViewController.h"
#import "RIOInterface.h"
#import "TableViewController1.h"

@interface ViewController()

@end

@implementation ViewController

@synthesize isListening;
@synthesize	rioRef;
@synthesize currentFrequency;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    rioRef = [RIOInterface sharedInstance];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)toggleButton:(id)sender {
    NSURL *url = nil;
    if (isListening)
    {
		[self stopListener];
        url = [[NSBundle mainBundle] URLForResource:@"locate_me_on" withExtension:@"png"];
	}
    else
    {
		[self startListener];
		url = [[NSBundle mainBundle] URLForResource:@"locate_me_off" withExtension:@"png"];
	}
	
    UIImage* image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
    [_locateButton setImage:image forState:UIControlStateNormal];
    
	isListening = !isListening;
}

- (void)startListener
{
	[rioRef startListening:self];
}

- (void)stopListener
{
	[rioRef stopListening];
}

- (void)frequencyChangedWithValue:(float)newFrequency
{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    if (rioRef.MIN_FREQ <= newFrequency && newFrequency <= rioRef.MAX_FREQ) {
        newFrequency = roundf(newFrequency / 50) * 50;
        self.currentFrequency = newFrequency;
        [self performSelectorInBackground:@selector(updateFrequencyLabel) withObject:nil];
	}
	[pool drain];
	pool = nil;
	
}

- (void)updateFrequencyLabel
{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Items" ofType:@"plist"];
    NSDictionary* contentDictionary = [NSDictionary dictionaryWithContentsOfFile:filePath];
    if (contentDictionary != nil) {
        NSDictionary* items = [contentDictionary valueForKey:[NSString stringWithFormat:@"%d", (int)(self.currentFrequency)]];
        if (items != nil) {
            [self toggleButton:nil];
            [self useSecretResource:items];
        }
    }
    
	[pool drain];
	pool = nil;
}

- (void)useSecretResource:(NSDictionary*)items
{
    // TODO here
    //NSLog(@"%@", items);
    
    /*
     store 1
     {
     0 =     {
     Description = "Shop Gi\U00e0y Nike";
     };
     1 =     {
     Link = "vi-vn.facebook.com/nikevietnam";
     };
     2 =     {
     Contact = 0906851115;
     };
     3 =     {
     Thumbnail = "media.komonews.com/images/070207_nike_shoe.jpg";
     };
     }
     */
    
    TableViewController1 *tableViewController = [[TableViewController1 alloc] initWithNibName:@"TableViewController1" bundle:nil];
    
    [tableViewController setItemsDictionary:items];
    
    [self.navigationController pushViewController:tableViewController animated:YES];
    
}

@end
