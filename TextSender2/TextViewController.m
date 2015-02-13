//
//  ViewController.m
//  TextingView
//
//  Created by Sandeep  Raghunandhan on 2/8/15.
//  Copyright (c) 2015 Sandeep. All rights reserved.
//

#import "TextViewController.h"
#import <MessageUI/MessageUI.h>

@interface TextViewController () <MFMessageComposeViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *message;
@property (weak, nonatomic) IBOutlet UIButton *send;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumber;
@property (weak, nonatomic) IBOutlet UITextView *Conversation;

@property(strong, nonatomic)NSMutableString *conversationText;
@property(strong,nonatomic)NSString *textMessage;
@property (strong, nonatomic)NSString *objectId;

@end

@implementation TextViewController:UIViewController
-(void)viewDidLoad
{
    [super viewDidLoad];
    if (_objectId)
    {
        // Retriving code
        PFQuery *query = [PFQuery queryWithClassName:@"Conversation"];
        [query getObjectInBackgroundWithId:_objectId block:^(PFObject *conversation, NSError *error) {
            // Do something with the returned PFObject
            _conversationText = [conversation objectForKey:@"savedConversation"];
        }];
    }
    else
    {
        _conversationText = [[NSMutableString alloc]init];
    }
}
-(void)saveConversation
{
    // Clear the field in which you enter your message
    
    _message.text = @"";
    
    // Save data code
    
    PFObject *testObject = [PFObject objectWithClassName:@"Conversation"];
    testObject[@"savedConversation"] = _conversationText;
    [testObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            // The object has been saved.
            _objectId = [testObject objectId];
            NSLog(@"%@", _objectId);
        } else {
            // There was a problem, check error.description
        }
    }];
}
- (IBAction)sendMessage:(id)sender {
    
    // The ViewController of the default iOS messaging app
    
    MFMessageComposeViewController *messageVC = [[MFMessageComposeViewController alloc]init];
    
    // Vital information involved in a text message
    
    NSString *number = _phoneNumber.text;
    NSString *message = _message.text;
    _textMessage = [NSString stringWithFormat:@"%@: %@ \n", number, message];
    
    // Pushes content to MessagingViewController
    messageVC.body = message;
    messageVC.recipients = @[number];
    messageVC.messageComposeDelegate = self;
    
    // Launches the Messaging App
    
    [self presentViewController:messageVC animated:NO completion:NULL];
    
    // Saves content using Parse
    
    [self saveConversation];
    
}
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    switch (result) {
        case MessageComposeResultCancelled:
            NSLog(@"Message was cancelled");
            [self dismissViewControllerAnimated:YES completion:NULL];
            break;
        case MessageComposeResultFailed:
            NSLog(@"Message failed");
            [self dismissViewControllerAnimated:YES completion:NULL];
            break;
        case MessageComposeResultSent:
            NSLog(@"Message was sent");
            [self dismissViewControllerAnimated:YES completion:NULL];
            
            // Update conversation TextField when message has successfully been sent
            
            [_conversationText appendString: _textMessage];
            _Conversation.text = _conversationText;
            [_Conversation setNeedsDisplay];
            
            break;
        default:
            break;
    } 
}



@end
