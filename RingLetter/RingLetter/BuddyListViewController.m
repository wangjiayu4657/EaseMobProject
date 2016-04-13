//
//  BuddyListViewController.m
//  RingLetter
//
//  Created by fangjs on 16/4/12.
//  Copyright © 2016年 fangjs. All rights reserved.
//

#import "BuddyListViewController.h"

@interface BuddyListViewController ()<EMChatManagerDelegate>

@property (strong , nonatomic) NSArray *buddyList;

@end

@implementation BuddyListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
    
    // 获取好友列表数据
    /* 注意
     * 1.好友列表buddyList需要在自动登录成功后才有值
     * 2.buddyList的数据是从 本地数据库获取
     * 3.如果要从服务器获取好友列表 调用chatManger下面的方法
     【-(void *)asyncFetchBuddyListWithCompletion:onQueue:】;
     * 4.如果当前有添加好友请求，环信的SDK内部会往数据库的buddy表添加好友记录
     * 5.如果程序删除或者用户第一次登录，buddyList表是没记录，
     解决方案
     1》要从服务器获取好友列表记录
     2》用户第一次登录后，自动从服务器获取好友列表
     */

    self.buddyList = [[EaseMob sharedInstance].chatManager buddyList];
    NSLog(@"%@",self.buddyList);
    
    UIView *footerView = [[UIView alloc] init];
    self.tableView.tableFooterView = footerView;
    self.tableView.backgroundColor= [UIColor clearColor];
    self.tableView.backgroundView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"callBg"]];

}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.buddyList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellID = @"buddyCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    cell.backgroundColor = [UIColor clearColor];
    cell.selectedBackgroundView=[[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor = [UIColor colorWithWhite:0.800 alpha:0.100];
    cell.separatorInset = UIEdgeInsetsMake(0, 15, 0, 15);
    
    EMBuddy *buddy = self.buddyList[indexPath.row];
    cell.imageView.image = [UIImage imageNamed:@"chatListCellHead"];
    cell.textLabel.text = buddy.username;
    
    return cell;
}

#pragma mark - Table view delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

//将好友从列表中删除
- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    EMBuddy *buddy = self.buddyList[indexPath.row];
    NSString *deleteUsername = buddy.username;
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [[EaseMob sharedInstance].chatManager removeBuddy:deleteUsername removeFromRemote:YES error:nil];
    }
}

#pragma mark - chatmanger的代理
#pragma mark - 监听自动登录成功
-(void)didAutoLoginWithInfo:(NSDictionary *)loginInfo error:(EMError *)error {
    if (!error) {
        self.buddyList = [[EaseMob sharedInstance].chatManager buddyList];
        [self.tableView reloadData];
    }
}


#pragma mark - 好友添加请求同意
-(void)didAcceptBuddySucceed:(NSString *)username {

//    NSArray *buddyList = [[EaseMob sharedInstance].chatManager buddyList];
//    NSLog(@"%@",buddyList);

    [self loadBuddyListFromServer];
}

#pragma mark - 从服务器上重新获取好友列表数据
- (void) loadBuddyListFromServer {
    [[EaseMob sharedInstance].chatManager asyncFetchBuddyListWithCompletion:^(NSArray *buddyList, EMError *error) {
        self.buddyList = buddyList;
        [self.tableView reloadData];
    } onQueue:nil];
}

#pragma mark - 好友列表数据被更新
- (void)didUpdateBuddyList:(NSArray *)buddyList changedBuddies:(NSArray *)changedBuddies isAdd:(BOOL)isAdd {
    NSLog(@"好友列表数据被更新 :%@",buddyList);
    self.buddyList = buddyList;
    [self.tableView reloadData];
}

#pragma mark - 监听被好友删除
-(void)didRemovedByBuddy:(NSString *)username {
    [self loadBuddyListFromServer];
}

- (void)dealloc {
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
}


@end
