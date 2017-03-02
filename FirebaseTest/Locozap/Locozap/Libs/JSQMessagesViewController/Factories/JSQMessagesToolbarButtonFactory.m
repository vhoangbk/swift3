//
//  Created by Jesse Squires
//  http://www.jessesquires.com
//
//
//  Documentation
//  http://cocoadocs.org/docsets/JSQMessagesViewController
//
//
//  GitHub
//  https://github.com/jessesquires/JSQMessagesViewController
//
//
//  License
//  Copyright (c) 2014 Jesse Squires
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import "JSQMessagesToolbarButtonFactory.h"

#import "UIColor+JSQMessages.h"
#import "UIImage+JSQMessages.h"
#import "NSBundle+JSQMessages.h"
#import "StringUtilities.h"

@interface JSQMessagesToolbarButtonFactory ()

@property (strong, nonatomic, readonly) UIFont *buttonFont;

@end

@implementation JSQMessagesToolbarButtonFactory

- (instancetype)init
{
    return [self initWithFont:[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline]];
}

- (instancetype)initWithFont:(UIFont *)font
{
    NSParameterAssert(font != nil);
    
    self = [super init];
    if (self) {
        _buttonFont = font;
    }
    
    return self;
}

- (UIButton *)defaultAccessoryButtonItem
{
    UIImage *accessoryImage = [UIImage imageNamed:@"chat_plus"];
    UIImage *normalImage = [UIImage imageNamed:@"chat_plus"];
    UIImage *highlightedImage = [UIImage imageNamed:@"chat_plus"];

    UIButton *accessoryButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, accessoryImage.size.width, 32.0f)];
    [accessoryButton setImage:normalImage forState:UIControlStateNormal];
    [accessoryButton setImage:highlightedImage forState:UIControlStateHighlighted];

    accessoryButton.contentMode = UIViewContentModeScaleAspectFit;
    accessoryButton.backgroundColor = [UIColor clearColor];
    accessoryButton.tintColor = [UIColor lightGrayColor];
    accessoryButton.titleLabel.font = self.buttonFont;
    
    accessoryButton.accessibilityLabel = [NSBundle jsq_localizedStringForKey:@"accessory_button_accessibility_label"];

    return accessoryButton;
}

- (UIButton *)defaultSendButtonItem
{
    NSString *sendTitle = [StringUtilities getLocalizedString:@"send" comment:@""];

    UIButton *sendButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [sendButton setTitle:sendTitle forState:UIControlStateNormal];
    [sendButton setTitleColor:[UIColor colorWithRed:254/255.0 green:211/255.0 blue:3/255.0 alpha:1] forState:UIControlStateNormal];
    [sendButton setTitleColor:[UIColor colorWithRed:254/255.0 green:211/255.0 blue:3/255.0 alpha:1] forState:UIControlStateHighlighted];
    [sendButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];

    sendButton.titleLabel.font = self.buttonFont;
    sendButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    sendButton.titleLabel.minimumScaleFactor = 0.85f;
    sendButton.contentMode = UIViewContentModeCenter;
//    sendButton.backgroundColor = [UIColor colorWithRed:254/255.0 green:211/255.0 blue:3/255.0 alpha:1];
//    sendButton.tintColor = [UIColor whiteColor];
//    sendButton.layer.cornerRadius = 5;

    CGFloat maxHeight = 32.0f;

    CGRect sendTitleRect = [sendTitle boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, maxHeight)
                                                   options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                attributes:@{ NSFontAttributeName : sendButton.titleLabel.font }
                                                   context:nil];

    sendButton.frame = CGRectMake(0.0f,
                                  0.0f,
                                  CGRectGetWidth(CGRectIntegral(sendTitleRect)),
                                  maxHeight);

    return sendButton;
}

@end
