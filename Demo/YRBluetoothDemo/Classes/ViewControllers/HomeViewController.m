//
//  ViewController.m
//  YRBluetoothDemo
//
//  Created by Yuriy Romanchenko on 12/30/15.
//  Copyright © 2015 solomidSF. All rights reserved.
//

// Controllers
#import "HomeViewController.h"

@implementation HomeViewController {
    __weak IBOutlet UITextField *_nicknameTextField;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // TODO: Load saved nickname.
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
}

@end
