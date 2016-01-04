//
//  ViewController.m
//  YRBluetoothDemo
//
//  Created by Yuriy Romanchenko on 12/30/15.
//  Copyright © 2015 solomidSF. All rights reserved.
//

// Controllers
#import "HomeViewController.h"

static NSString *const kSavedUsernameKey = @"Username";

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
    
//    self performSegueWithIdentifier:<#(nonnull NSString *)#> sender:<#(nullable id)#>
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

//    self performSegueWithIdentifier:<#(nonnull NSString *)#> sender:<#(nullable id)#>
}

@end
