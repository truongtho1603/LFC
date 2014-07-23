//
//  TableViewController1.m
//  temp
//
//  Created by Tho Do on 6/26/14.
//  Copyright (c) 2014 Tho Do. All rights reserved.
//

#import "TableViewController1.h"
#import "CAPSCustomCell.h"
#import "SVWebViewController.h"

@interface TableViewController1 ()
{
    NSDictionary *items;
    dispatch_queue_t loadingQueue;
}

@end

@implementation TableViewController1

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    loadingQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);//("myQueue", NULL);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [items count] - 1;
}

- (void)setItemsDictionary:(NSDictionary *)dict
{
    items = [[NSDictionary alloc] initWithDictionary:dict];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"CAPSCustomCell";
    
    CAPSCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell)
    {
        NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"CAPSCustomCell" owner:self options:nil];
        
        cell = views[0];
    }
    
    __block UIImage *img = nil;
    __block NSString *url = nil;
    __block NSData *urlData = nil;
    __block NSString *gestureUrl = nil;
    
    // download
    dispatch_async(loadingQueue, ^{
        // loading
        url = [cell getThumbnailURLWithDictionary:items];
        url = [url stringByReplacingOccurrencesOfString:@"http://" withString:@""];
        urlData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", @"http://", url]]];
        
        dispatch_barrier_sync(dispatch_get_main_queue(), ^{
            // draw Name, Description, Contact
            [cell setCellContentWithDictionary:items atRow:indexPath.row];
            
            img = [[UIImage alloc] initWithData:urlData];
            
            // draw Thumbnail
            [cell setThumbnailWith:img];
            
            if (indexPath.row == 3 || indexPath.row == 4)
            {
                // Add Duong's code
                gestureUrl = [cell getThumbnailGestureURLWithDictionary:items];
                CustomUITapGestureRecognizer *singleTap = [[CustomUITapGestureRecognizer alloc] initWithTarget:self action:@selector(navigateToAdLink:)];
                [singleTap addText:gestureUrl];
                singleTap.numberOfTapsRequired = 1;
                [cell addGestureRecognizer:singleTap];
            }
        });
    });
    
    return cell;
}

-(void)navigateToAdLink:(id)sender{
    NSString *url = [NSString stringWithFormat:@"%@%@", @"http://", [sender getText]];
    SVWebViewController *webViewController = [[SVWebViewController alloc] initWithAddress:url];
    [self.navigationController pushViewController:webViewController animated:YES];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row)
    {
        case 0:
            return 50;
        case 1:
            return 250;
        case 2:
            return 50;
        case 3:
            return 150;
        default:
            break;
    }
    return 50;
}

@end
