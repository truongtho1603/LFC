#import "CAPSCustomCell.h"
#import "CustomUIView.h"
#import <CoreText/CoreText.h>

@implementation CAPSCustomCell
{
    NSDictionary *items;
    
    NSUInteger xPos;
    
    NSUInteger yPos;
    
    NSMutableArray *data;
    
    UIImageView *imgView;
    
    CustomUITapGestureRecognizer *imgViewGesture;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        
        // Initialization code
        
        items = [[NSDictionary alloc] init];
        
        xPos = 0;
        
        yPos = 0;
        
        data = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

#pragma mark - Set Cell content
- (void)setCellContentWithDictionary:(NSDictionary *)dict atRow:(NSUInteger)row
{
    switch (row)
    {
            NSMutableAttributedString *content;
            
            UITextView *customView;
            
            CustomUITapGestureRecognizer *customGesture;
            
        case 0:
        {
            // draw Name - Bold
            content = [[NSMutableAttributedString alloc] initWithString:[[dict valueForKey:[NSString stringWithFormat:@"%d", row]] objectForKey:@"Name"]
                                                             attributes:@{NSForegroundColorAttributeName: [UIColor redColor],
                                                                          NSFontAttributeName: [UIFont boldSystemFontOfSize:24]}];
            
            customView = [[UITextView alloc] initWithFrame:CGRectMake([[UIScreen mainScreen] bounds].size.width / 2 - [content size].width / 2, 0, 320, 40)];
            
            [customView setEditable:NO];
            
            [customView setScrollEnabled:NO];
            
            [customView setAttributedText:content];
            
            [self addSubview:customView];
            
            break;
        }
        case 1:
        {
            // draw Description
            content = [[NSMutableAttributedString alloc] initWithString:[[dict valueForKey:[NSString stringWithFormat:@"%d", row]] objectForKey:@"Description"]
                                                             attributes:@{NSForegroundColorAttributeName: [UIColor blueColor]}];
            
            customView = [[UITextView alloc] initWithFrame:CGRectMake(10, 0, 300, 250)];
            
            [customView setEditable:NO];
            
            [customView setScrollEnabled:YES];
            
            [customView setAttributedText:content];
            
            [customView setTextAlignment:NSTextAlignmentJustified];
            
            [self addSubview:customView];
            
            break;
        }
        case 2:
        {
            // draw contact - italic
            content = [[NSMutableAttributedString alloc] initWithString:[[dict valueForKey:[NSString stringWithFormat:@"%d", row]] objectForKey:@"Contact"]
                                                             attributes:@{NSForegroundColorAttributeName: [UIColor blackColor],
                                                                          NSFontAttributeName: [UIFont italicSystemFontOfSize:24]}];
            
            customView = [[UITextView alloc] initWithFrame:CGRectMake([[UIScreen mainScreen] bounds].size.width / 2 - [content size].width / 2, 0, 320, 40)];
            
            [customView setEditable:NO];
            
            [customView setScrollEnabled:NO];
            
            [customView setAttributedText:content];
            
            customGesture = [[CustomUITapGestureRecognizer alloc] initWithTarget:self action:@selector(phoneTapped:)];
            
            [customGesture addText:[content string]];
            
            [customView addGestureRecognizer:customGesture];
            
            [self addSubview:customView];
            
            break;
        }
        case 3:
        {
            // draw thumbnail

            imgView = [[UIImageView alloc] initWithFrame:CGRectMake([[UIScreen mainScreen] bounds].size.width / 2 - 150 / 2, 0, 150, 150)];
            
            [imgView setBackgroundColor:[UIColor lightTextColor]];
            
            [imgView setUserInteractionEnabled:YES];
            
            // add link to thumbnails
            
            imgViewGesture = [[CustomUITapGestureRecognizer alloc] initWithTarget:self action:@selector(linkTapped:)];
            
            [self addSubview:imgView];
        }
        
        default:
            break;
    }
}

- (NSString *)getThumbnailURLWithDictionary:(NSDictionary *)dict
{
    NSString *url = [[dict valueForKey:[NSString stringWithFormat:@"%d", 3]] objectForKey:@"Thumbnail"];
    url = [url stringByReplacingOccurrencesOfString:@"http://" withString:@""];
    NSMutableAttributedString *content1 = [[NSMutableAttributedString alloc] initWithString:url];
    return [content1 string];
}

- (void)setThumbnailWith:(UIImage *)image
{
    [imgView setImage:image];
}

- (NSString *)getThumbnailGestureURLWithDictionary:(NSDictionary *)dict
{
    NSString *url = [[dict valueForKey:[NSString stringWithFormat:@"%d", 4]] objectForKey:@"Link"];
    url = [url stringByReplacingOccurrencesOfString:@"http://" withString:@""];
    NSMutableAttributedString *content1 = [[NSMutableAttributedString alloc] initWithString:url];
    return [content1 string];
}

- (void)setThumbnailGestureWith:(NSString *)url
{
    [imgViewGesture addText:url];
    
    [imgView addGestureRecognizer:imgViewGesture];
}

- (void)dealloc {
    [super dealloc];
}

- (void)linkTapped:(id)sender
{
    CustomUITapGestureRecognizer *gesture = (CustomUITapGestureRecognizer *)sender;
    
    //NSURL *linkURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", @"http://", [gesture getText]]];
    NSURL *linkURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", @"http://", [gesture getText]]];
    
    NSLog(@"%@", linkURL);
    
    [[UIApplication sharedApplication] openURL:linkURL];
}

- (void)phoneTapped:(id)sender
{
    CustomUITapGestureRecognizer *gesture = (CustomUITapGestureRecognizer *)sender;
    
    NSURL *phoneURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", @"tel://", [gesture getText]]];
    
    NSLog(@"%@", phoneURL);
    
    [[UIApplication sharedApplication] openURL:phoneURL];
}
@end
