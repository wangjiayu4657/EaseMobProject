//
//  ConversationViewController.m
//  RingLetter
//
//  Created by fangjs on 16/4/11.
//  Copyright © 2016年 fangjs. All rights reserved.
//

#import "ConversationViewController.h"
#import "EaseMob.h"
#import "chatViewController.h"
#import "BadgeTableViewCell.h"

@interface ConversationViewController ()<EMChatManagerDelegate>

@property (strong , nonatomic) NSMutableArray *datasource;
@property (strong , nonatomic) NSArray *buddyList;

@end

@implementation ConversationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"会话";
    
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
    
    [self loadConversationSource];
    
    UIView *footerView = [[UIView alloc] init];
    self.tableView.tableFooterView = footerView;
}

- (void) loadConversationSource {
    //获取历史会化记录
    //从内存中获取历史会话
    NSArray *array = [[EaseMob sharedInstance].chatManager conversations];
    self.datasource = [NSMutableArray arrayWithArray:array];
    
    //如果你内存中没有会话记录,那么就从数据库中获取
    if (self.datasource.count == 0) {
        self.datasource = [NSMutableArray arrayWithArray:[[EaseMob sharedInstance].chatManager loadAllConversationsFromDatabaseWithAppend2Chat:YES]];
    }

    [self shaowTabBarBadge];
}

#pragma mark - chatManager 代理方法
//监听网络状态
//eEMConnectionConnected,   //连接成功
//eEMConnectionDisconnected,//未连接
-(void)didConnectionStateChanged:(EMConnectionState)connectionState {
    if (connectionState == eEMConnectionDisconnected) {
        self.title = @"未连接";
    }
    else {
        self.title = @"会话";
    }
}

//将自动连接
-(void)willAutoReconnect {
    self.title = @"连接中...";
}

//自动重连接
- (void)didAutoReconnectFinishedWithError:(NSError *)error {
    if (!error) {
        self.title = @"会话";
    }
    else {
        self.title = @"网络已断开";
    }
}

#pragma mark - 好友添加的代理方法
#pragma mark - 好友请求被同意
- (void)didAcceptedByBuddy:(NSString *)username {
    [self showMessageUsername:username WithStatus:@"通过了你的请求" withTitle:@"好友添加结果"];
}

#pragma mark 好友请求被拒绝
- (void)didRejectedByBuddy:(NSString *)username {
    [self showMessageUsername:username WithStatus:@"拒绝了你的请求" withTitle:@"好友添加结果"];
}

//向用户展示信息
- (void) showMessageUsername:(NSString *) username WithStatus:(NSString *) status withTitle:(NSString *) title {
    NSString *message = [NSString stringWithFormat:@"@%@%@",username,status];
    UIAlertController *alter = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"我知道了" style:UIAlertActionStyleDefault handler:nil];
    [alter addAction:ok];
    [self presentViewController:alter animated:YES completion:nil];
}

#pragma mark - 接收到好友请求时的通知
-(void)didReceiveBuddyRequest:(NSString *)username message:(NSString *)message {
    UIAlertController *alter = [UIAlertController alertControllerWithTitle:@"好友添加结果" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"接受" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[EaseMob sharedInstance].chatManager acceptBuddyRequest:username error:nil];
    }];
    UIAlertAction *cancle = [UIAlertAction actionWithTitle:@"拒绝" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [[EaseMob sharedInstance].chatManager rejectBuddyRequest:username reason:message error:nil];
    }];
    
    [alter addAction:ok];
    [alter addAction:cancle];
    [self presentViewController:alter animated:YES completion:nil];
}


#pragma mark - 监听被好友删除
-(void)didRemovedByBuddy:(NSString *)username {
    [self showMessageUsername:username WithStatus:@"把你删除了" withTitle:@"好友删除提示"];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datasource.count;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 64;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BadgeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:badgeCell];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"BadgeTableViewCell" owner:self options:nil] lastObject];
    }
    EMConversation *conversation = self.datasource[indexPath.row];
    EMMessage *lastMessage = [conversation latestMessage];
    [cell showBageCount:conversation.unreadMessagesCount WithMessage:lastMessage];

    cell.usernameLabel.text = [NSString stringWithFormat:@"%@",conversation.chatter];
    
    id body = conversation.latestMessage.messageBodies[0];
    if ([body isKindOfClass:[EMTextMessageBody class]]) {
        EMTextMessageBody *textBody = body;
        cell.contentLabel.text = textBody.text;
    }
    else if ([body isKindOfClass:[EMVoiceMessageBody class]]) {
        EMVoiceMessageBody *voiceBody = body;
        cell.contentLabel.text = voiceBody.displayName;
    }
    else if ([body isKindOfClass:[EMImageMessageBody class]]) {
        EMImageMessageBody *imageBody = body;
        cell.contentLabel.text = imageBody.displayName;
    }
    else if ([body isKindOfClass:[EMVideoMessageBody class]]) {
        EMVideoMessageBody *videoBody = body;
        cell.contentLabel.text = videoBody.displayName;
    }
    else {
         cell.contentLabel.text = @"未知类型";
    }
    
    return cell;
}

#pragma mark - UITableView delegate
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    EMConversation *conversation = self.datasource[indexPath.row];
    EMBuddy *buddy = [EMBuddy buddyWithUsername:conversation.chatter];
    chatViewController *chatController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"showDetailController"];
    chatController.buddy = buddy;
    [self.navigationController pushViewController:chatController animated:YES];
}

//将参数buddy传到chatViewController控制器
//- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    id controller = segue.destinationViewController;
//    if ([controller isKindOfClass:[chatViewController class]]) {
//        chatViewController *chatController = controller;
//        for (EMBuddy *buddy in self.buddyList) {
//            if ([buddy.username isEqualToString:self.conversation.chatter]) {
//                 [chatController setValue:buddy forKey:@"buddy"];
//                 [chatController setValue:self.conversation forKey:@"conversation"];
//            }
//        }
//    }
//}


- (void) viewWillDisappear:(BOOL)animated {
    [self.tableView reloadData];
}

#pragma mark - 自动登录回调
-(void) didAutoLoginWithInfo:(NSDictionary *)loginInfo error:(EMError *)error {
    if (!error) {
        NSLog(@"%s 自动登录成功: %@",__FUNCTION__,loginInfo);
    }
    else {
        NSLog(@"自动登录失败: %@",error);
    }
}


- (void) didUpdateConversationList:(NSArray *)conversationList {
    //给数据源重新赋值
    self.datasource = [NSMutableArray arrayWithArray:conversationList];
//    self.datasource = conversationList;
    [self.tableView reloadData];
    
    [self shaowTabBarBadge];
}

- (void) didUnreadMessagesCountChanged {
    [self.tableView reloadData];
    [self shaowTabBarBadge];
}

- (void) shaowTabBarBadge {
    NSInteger totalUnreadCount = 0;
    for (EMConversation *conversation in self.datasource) {
        totalUnreadCount += conversation.unreadMessagesCount;
    }
    if (totalUnreadCount > 0) {
        self.navigationController.tabBarItem.badgeValue = [NSString stringWithFormat:@"%ld",totalUnreadCount];
    }else {
        self.navigationController.tabBarItem.badgeValue = nil;
    }
}

-(void)dealloc {
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
}

@end
