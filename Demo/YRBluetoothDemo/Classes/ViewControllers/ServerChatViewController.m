//
//  ChatServerViewController.m
//  YRBluetoothDemo
//
//  Created by Yuriy Romanchenko on 1/1/16.
//  Copyright © 2016 solomidSF. All rights reserved.
//

// Controllers
#import "ServerChatViewController.h"
#import "ChatMembersController.h"

// Sessions
#import "ServerChatSession.h"

// Events
#import "EventObject.h"
#import "ConnectionEvent.h"
#import "NewMessageEvent.h"

// Entities
#import "ServerUser.h"

// Cells
#import "BaseEventTableCell.h"
#import "InformativeTableCell.h"
#import "MessageTableCell.h"
#import "MyMessageTableCell.h"

static NSString *const kChatMembersSegueIdentifier = @"ChatMembersSegue";

@interface ServerChatViewController ()
<
ServerChatSessionObserver,
UITableViewDelegate,
UITableViewDataSource
>
@end

@implementation ServerChatViewController {
    ServerChatSession *_serverSession;
    NSMutableArray <EventObject *> *_datasource;
    
    id _keyboardObserver;

    __weak IBOutlet UIButton *_broadcastButton;
    __weak IBOutlet UIButton *_participantsCountButton;
    __weak IBOutlet UILabel *_bluetoothStateLabel;
    __weak IBOutlet UIImageView *_bluetoothStateImageView;
    
    __weak IBOutlet UIView *_noMessagesView;
    
    __weak IBOutlet UITableView *_messagesTableView;
    __weak IBOutlet UITextField *_messageTextField;
    __weak IBOutlet NSLayoutConstraint *_messageBottomConstraint;
}

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _datasource = [NSMutableArray new];
    _noMessagesView.hidden = _datasource.count > 0;
    
    _messagesTableView.rowHeight = UITableViewAutomaticDimension;
    _messagesTableView.estimatedRowHeight = 50.0f;

    _serverSession = [ServerChatSession sessionWithNickname:self.nickname];
    
    [_serverSession addObserver:self];
    
    self.title = [NSString stringWithFormat:@"%@'s Chat", self.nickname];
    
    [self updateChatHeaderUI];    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    __typeof(self) __weak weakSelf = self;
    _keyboardObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillChangeFrameNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        
        if (strongSelf)
        {
            CGRect keyboardRect = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
            NSTimeInterval duration = [note.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
            
            CGFloat localY = [[UIApplication sharedApplication].keyWindow convertPoint:keyboardRect.origin toView:strongSelf.view].y;
            
            [UIView animateWithDuration:duration animations:^()
             {
                 strongSelf->_messageBottomConstraint.constant = MIN(0, localY - CGRectGetHeight(strongSelf.view.bounds));
                 
                 [strongSelf.view layoutIfNeeded];
             }];
        }
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:_keyboardObserver];
}

- (void)dealloc {
    [_serverSession stopAdvertising];
    
    [_serverSession endSession];
}

#pragma mark - Callbacks

- (IBAction)broadcastClicked:(id)sender {
    if (_serverSession.isAdvertising) {
        [_serverSession stopAdvertising];
    } else {
        [_serverSession startAdvertising];
    }
}

- (IBAction)participantsClicked:(id)sender {
    [self performSegueWithIdentifier:kChatMembersSegueIdentifier sender:self];
}

- (IBAction)sendClicked:(id)sender {
    NSString *filteredText = [_messageTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    filteredText = [filteredText stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    if (filteredText.length > 0) {
        [_serverSession sendMessage:_messageTextField.text];
        
        _messageTextField.text = nil;
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Error"
                                    message:@"Please enter your message."
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kChatMembersSegueIdentifier]) {
        ChatMembersController *membersController = segue.destinationViewController;
        
        membersController.serverSession = _serverSession;
        membersController.chat = _serverSession.chat;
    }
}

#pragma mark - Private

- (void)updateChatHeaderUI {
    int32_t participants = (int32_t)_serverSession.chat.members.count + 1;
    
    NSString *participantsTitle = [NSString stringWithFormat:@"%d %@", participants, participants == 1 ? @"Participant" : @"Participants"];
    
    [_participantsCountButton setTitle:participantsTitle
                              forState:UIControlStateNormal];

    NSString *broadcastTitle = _serverSession.isAdvertising ? @"Stop" : @"Broadcast";
    
    [_broadcastButton setTitle:broadcastTitle forState:UIControlStateNormal];
    _broadcastButton.enabled = (_serverSession.bluetoothState == kYRBluetoothStatePoweredOn);
    
    BOOL isBluetoothEnabled = _serverSession.bluetoothState == kYRBluetoothStatePoweredOn;
    
    _bluetoothStateLabel.text = [self humanReadableBluetoothState:_serverSession.bluetoothState];
    _bluetoothStateImageView.image = [UIImage imageNamed:isBluetoothEnabled ? @"online" : @"offline"];
}

- (void)appendEventAndReload:(__kindof EventObject *)event {
    _noMessagesView.hidden = YES;
    
    [_datasource addObject:event];
    
    [_datasource sortUsingComparator:^NSComparisonResult(EventObject *obj1, EventObject *obj2) {
        return [@(obj1.timestamp) compare:@(obj2.timestamp)];
    }];
    
    [_messagesTableView reloadData];
    
    [_messagesTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:_datasource.count - 1 inSection:0]
                              atScrollPosition:UITableViewScrollPositionBottom
                                      animated:NO];
}

- (NSString *)humanReadableBluetoothState:(YRBluetoothState)state {
    return @[@"Unknown BT State",
             @"Bluetooth Reset",
             @"Bluetooth Unsupported",
             @"Bluetooth Unauthorized",
             @"Bluetooth OFF",
             @"Bluetooth ON"][state];
}

#pragma mark - <ServerChatSessionObserver>

- (void)chatSession:(ServerChatSession *)session bluetoothStateDidChange:(YRBluetoothState)newState {
    [self updateChatHeaderUI];
}

- (void)chatSession:(ServerChatSession *)session advertisingStateChanged:(BOOL)isAdvertising {
    [self updateChatHeaderUI];
}

- (void)chatSession:(ServerChatSession *)session userDidConnectWithEvent:(ConnectionEvent *)event {
    [self updateChatHeaderUI];
    [self appendEventAndReload:event];
    
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        UILocalNotification *notification = [UILocalNotification new];
        
        notification.alertBody = [NSString stringWithFormat:@"%@ connected!", event.user.name];
        notification.soundName = @"ding.mp3";
        
        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
    }
}

- (void)chatSession:(ServerChatSession *)session userDidDisconnectWithEvent:(ConnectionEvent *)event {
    [self updateChatHeaderUI];
    [self appendEventAndReload:event];
}

- (void)chatSession:(ServerChatSession *)session userDidUpdateName:(ServerUser *)user {
    [_messagesTableView reloadData];
}

- (void)chatSession:(ServerChatSession *)session didReceiveMessage:(NewMessageEvent *)event {
    [self appendEventAndReload:event];
    
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        Message *message = event.message;
        UILocalNotification *notification = [UILocalNotification new];
        
        notification.alertBody = [NSString stringWithFormat:@"New message from %@:\n%@", message.sender.name, message.messageText];
        notification.soundName = UILocalNotificationDefaultSoundName;
        
        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
    }
}

#pragma mark - <UITableViewDelegate/Datasource>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _datasource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EventObject *event = _datasource[indexPath.row];
    
    __kindof BaseEventTableCell *cell = [tableView dequeueReusableCellWithIdentifier:event.reuseIdentifier];
    
    cell.event = event;
    
    return cell;
}

@end
