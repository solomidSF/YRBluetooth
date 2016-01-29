//
//  ChatClientViewController.m
//  YRBluetoothDemo
//
//  Created by Yuriy Romanchenko on 1/1/16.
//  Copyright © 2016 solomidSF. All rights reserved.
//

// Controllers
#import "ClientChatViewController.h"
#import "ChatMembersController.h"

// Events
#import "EventObject.h"
#import "ConnectionEvent.h"
#import "NewMessageEvent.h"

// Cells
#import "BaseEventTableCell.h"

static NSString *const kChatMembersSegueIdentifier = @"ChatMembersSegue";

@interface ClientChatViewController ()
<
ClientChatSessionObserver,
UITableViewDelegate,
UITableViewDataSource
>
@end

@implementation ClientChatViewController {
    NSMutableArray <EventObject *> *_datasource;
    
    id _keyboardObserver;

    IBOutlet UIBarButtonItem *_retryConnectionButton;
    __weak IBOutlet UITableView *_messagesTableView;
    __weak IBOutlet UITextField *_messageTextField;
    __weak IBOutlet NSLayoutConstraint *_messageBottomConstraint;
    __weak IBOutlet UILabel *_connectionStateLabel;
    __weak IBOutlet UIImageView *_connectionStateImageView;
    __weak IBOutlet UIButton *_participantsCountButton;
    __weak IBOutlet UIView *_noMessagesView;
}

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = self.pickedChat.name;
    
    _datasource = [NSMutableArray new];
    _noMessagesView.hidden = _datasource.count > 0;

    _messagesTableView.rowHeight = UITableViewAutomaticDimension;
    _messagesTableView.estimatedRowHeight = 50.0f;
    
    [_session addObserver:self];
    
    [self tryToConnect];
    [self updateChatHeaderUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    __typeof(self) __weak weakSelf = self;
    _keyboardObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillChangeFrameNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        
        if (strongSelf) {
            CGRect keyboardRect = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
            NSTimeInterval duration = [note.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];

            CGFloat localY = [[UIApplication sharedApplication].keyWindow convertPoint:keyboardRect.origin toView:strongSelf.view].y;
            
            [UIView animateWithDuration:duration animations:^() {
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
    [_session removeObserver:self];
}

#pragma mark - Callbacks

- (IBAction)tryToConnectCallback:(id)sender {
    [self tryToConnect];
}

- (IBAction)participantsClicked:(id)sender {
    [self performSegueWithIdentifier:kChatMembersSegueIdentifier sender:self];
}

- (IBAction)sendClicked:(id)sender {
    [_session sendText:_messageTextField.text
                inChat:self.pickedChat
           withSuccess:^(Message *message) {
               _noMessagesView.hidden = YES;
               
               NewMessageEvent *event = [[NewMessageEvent alloc] initWithChat:self.pickedChat
                                                                      message:message
                                                                    timestamp:message.timestamp];
               
               [_datasource addObject:event];
               
               [_datasource sortUsingComparator:^NSComparisonResult(EventObject *obj1, EventObject *obj2) {
                   return [@(obj1.timestamp) compare:@(obj2.timestamp)];
               }];
               
               [_messagesTableView reloadData];
               
               [_messagesTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:_datasource.count - 1 inSection:0]
                                         atScrollPosition:UITableViewScrollPositionBottom
                                                 animated:NO];
    } failure:^(YRBTMessageOperation *operation, NSError *error) {
        [[[UIAlertView alloc] initWithTitle:@"Error"
                                    message:error.localizedDescription
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }];
    
    _messageTextField.text = nil;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kChatMembersSegueIdentifier]) {
        ChatMembersController *membersController = segue.destinationViewController;
        
        membersController.session = self.session;
        membersController.chat = self.pickedChat;
    }
}

#pragma mark - Private

- (void)tryToConnect {
    self.navigationItem.rightBarButtonItem = nil;
    
    if (self.pickedChat.state == kChatStateDisconnected) {
        [_session connectToChat:self.pickedChat withSuccess:^(ClientChat *chat, ClientUser *userInfo) {
            
        } failure:^(NSError *error) {
            self.navigationItem.rightBarButtonItem = _retryConnectionButton;
            
            [[[UIAlertView alloc] initWithTitle:@"Error"
                                        message:error.localizedDescription
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
        }];
    }
}

- (void)updateChatHeaderUI {
    NSString *readableState = @[@"Disconnected",
                                @"Connecting",
                                @"Connected"][self.pickedChat.state];
    
    NSString *connectionImage = @[@"offline",
                                  @"offline",
                                  @"online"][self.pickedChat.state];
    
    _connectionStateLabel.text = readableState;
    _connectionStateImageView.image = [UIImage imageNamed:connectionImage];
    
    _participantsCountButton.enabled = (self.pickedChat.state == kChatStateConnected);
    [_participantsCountButton setTitle:[NSString stringWithFormat:@"%d Participants", (int32_t)self.pickedChat.members.count + 2]
                              forState:UIControlStateNormal];
}

#pragma mark - <ClientChatSessionObserver>

- (void)chatSession:(ClientChatSession *)session chatStateDidUpdate:(Chat *)chat {
    if ([self.pickedChat isEqual:chat]) {
        [self updateChatHeaderUI];
    }
}

- (void)chatSession:(ClientChatSession *)session userDidConnect:(ClientUser *)user
             toChat:(ClientChat *)chat timestamp:(NSTimeInterval)timestamp {
    _noMessagesView.hidden = YES;

    ConnectionEvent *event = [[ConnectionEvent alloc] initWithChat:self.pickedChat
                                                              user:user
                                                         eventType:kEventTypeConnected
                                                         timestamp:timestamp];
    
    [_datasource addObject:event];
    
    [_datasource sortUsingComparator:^NSComparisonResult(EventObject *obj1, EventObject *obj2) {
        return [@(obj1.timestamp) compare:@(obj2.timestamp)];
    }];
    
    [self updateChatHeaderUI];
    
    [_messagesTableView reloadData];
    
    [_messagesTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:_datasource.count - 1 inSection:0]
                              atScrollPosition:UITableViewScrollPositionBottom
                                      animated:NO];
    
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        UILocalNotification *notification = [UILocalNotification new];
        
        notification.alertBody = [NSString stringWithFormat:@"User %@ connected to %@'s chat.", user.name, chat.name];
        notification.soundName = @"ding.mp3";
        
        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
    }
}

- (void)chatSession:(ClientChatSession *)session userDidDisconnect:(ClientUser *)user
           fromChat:(ClientChat *)chat timestamp:(NSTimeInterval)timestamp {
    _noMessagesView.hidden = YES;
    
    ConnectionEvent *event = [[ConnectionEvent alloc] initWithChat:self.pickedChat
                                                              user:user
                                                         eventType:kEventTypeDisconnected
                                                         timestamp:timestamp];
    
    [_datasource addObject:event];
    
    [_datasource sortUsingComparator:^NSComparisonResult(EventObject *obj1, EventObject *obj2) {
        return [@(obj1.timestamp) compare:@(obj2.timestamp)];
    }];
    
    [self updateChatHeaderUI];
    
    [_messagesTableView reloadData];
    
    [_messagesTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:_datasource.count - 1 inSection:0]
                              atScrollPosition:UITableViewScrollPositionBottom
                                      animated:NO];
}

- (void)chatSession:(ClientChatSession *)session didReceiveMessage:(Message *)message inChat:(ClientChat *)chat {
    _noMessagesView.hidden = YES;

    NewMessageEvent *event = [[NewMessageEvent alloc] initWithChat:self.pickedChat
                                                           message:message
                                                         timestamp:message.timestamp];
    
    [_datasource addObject:event];
    
    [_datasource sortUsingComparator:^NSComparisonResult(EventObject *obj1, EventObject *obj2) {
        return [@(obj1.timestamp) compare:@(obj2.timestamp)];
    }];
    
    [_messagesTableView reloadData];
    
    [_messagesTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:_datasource.count - 1 inSection:0]
                              atScrollPosition:UITableViewScrollPositionBottom
                                      animated:NO];
    
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        UILocalNotification *notification = [UILocalNotification new];
        
        notification.alertBody = [NSString stringWithFormat:@"New message from %@ in %@'s chat:\n%@", message.sender.name, chat.name, message.messageText];
        notification.soundName = UILocalNotificationDefaultSoundName;
        
        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
    }
}

#pragma mark - <UITableViewDelegate&Datasource>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _datasource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EventObject *event = _datasource[indexPath.row];
    
    __kindof BaseEventTableCell *cell = [tableView dequeueReusableCellWithIdentifier:event.reuseIdentifier];
    
    cell.clientSession = _session;
    cell.event = event;
    
    return cell;
}

@end