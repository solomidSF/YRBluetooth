//
//  SearchChatsViewController.m
//  YRBluetoothDemo
//
//  Created by Yuriy Romanchenko on 1/23/16.
//  Copyright © 2016 solomidSF. All rights reserved.
//

// Controllers
#import "SearchChatsViewController.h"
#import "ClientChatViewController.h"

// Model
#import "ClientChatSession.h"

// Cell
#import "ChatTableCell.h"

static NSString *const kClientChatControllerSegueIdentifier = @"ChatSegue";

@interface SearchChatsViewController ()
<
UITableViewDelegate,
UITableViewDataSource
>
@end

@implementation SearchChatsViewController {
    ClientChatSession *_clientSession;
    
    NSArray <ClientChat *> *_discoveredChats;
    __weak IBOutlet UITableView *_chatsTableView;
}

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _discoveredChats = [NSMutableArray new];
    _clientSession = [ClientChatSession sessionWithNickname:self.nickname];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // TODO: Temp solution.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_clientSession startScanningForChatsWithSuccess:^(NSArray <ClientChat *> *chats) {
            BOOL shouldUpdateSearchResults = _discoveredChats.count != chats.count;

            if (!shouldUpdateSearchResults) {
                // Additional check for ABA
                for (ClientChat *chat in chats) {
                    if (![_discoveredChats containsObject:chat]) {
                        shouldUpdateSearchResults = YES;
                    }
                }
            }
            
            if (shouldUpdateSearchResults) {
                _discoveredChats = chats;
                
                [_chatsTableView reloadData];   
            }
        } failure:^(NSError *error) {
            [[[UIAlertView alloc] initWithTitle:@"Error"
                                        message:error.localizedDescription
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
        }];
    });
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [_clientSession stopScanningForChats];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kClientChatControllerSegueIdentifier]) {
        ClientChatViewController *controller = segue.destinationViewController;
        
        controller.session = _clientSession;
        controller.pickedChat = sender;
    }
}

#pragma mark - <UITableViewDelegate&Datasource>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _discoveredChats.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ChatTableCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ChatTableCell class])];
    
    cell.session = _clientSession;
    cell.chat = _discoveredChats[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self performSegueWithIdentifier:kClientChatControllerSegueIdentifier sender:_discoveredChats[indexPath.row]];
}

@end
