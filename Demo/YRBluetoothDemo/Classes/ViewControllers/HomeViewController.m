//
//  ViewController.m
//  YRBluetoothDemo
//
//  Created by Yuriy Romanchenko on 12/30/15.
//  Copyright © 2015 solomidSF. All rights reserved.
//

// Controllers
#import "HomeViewController.h"
#import "SearchChatsViewController.h"
#import "ServerChatViewController.h"

static NSString *const kSavedUsernameKey = @"Username";

static NSString *const kClientViewControllerSegueIdentifier = @"ClientSegue";
static NSString *const kServerViewControllerSegueIdentifier = @"ServerSegue";

@implementation HomeViewController {
    __weak IBOutlet UITextField *_nicknameTextField;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _nicknameTextField.text = [[NSUserDefaults standardUserDefaults] objectForKey:kSavedUsernameKey];
}

- (IBAction)searchChatsClicked:(id)sender {
    if (_nicknameTextField.text.length == 0) {
        [[[UIAlertView alloc] initWithTitle:@"Error"
                                    message:@"Please enter your nickname"
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
        return;
    }

    [[NSUserDefaults standardUserDefaults] setObject:_nicknameTextField.text forKey:kSavedUsernameKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self performSegueWithIdentifier:kClientViewControllerSegueIdentifier sender:self];
}

- (IBAction)createChatClicked:(id)sender {
    if (_nicknameTextField.text.length == 0) {
        [[[UIAlertView alloc] initWithTitle:@"Error"
                                    message:@"Please enter your nickname"
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
        return;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:_nicknameTextField.text forKey:kSavedUsernameKey];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [self performSegueWithIdentifier:kServerViewControllerSegueIdentifier sender:self];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kServerViewControllerSegueIdentifier]) {
        ServerChatViewController *controller = segue.destinationViewController;
        
        controller.nickname = _nicknameTextField.text;
    } else if ([segue.identifier isEqualToString:kClientViewControllerSegueIdentifier]) {
        SearchChatsViewController *controller = segue.destinationViewController;
        
        controller.nickname = _nicknameTextField.text;
    }
}

@end
