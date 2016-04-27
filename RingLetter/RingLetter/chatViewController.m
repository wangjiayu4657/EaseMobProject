//
//  chatViewController.m
//  RingLetter
//
//  Created by fangjs on 16/4/13.
//  Copyright © 2016年 fangjs. All rights reserved.
//

#import "chatViewController.h"
#import "chatViewCell.h"
#import "CustomView.h"
#import "AudioPlayTool.h"
#import "timeViewCell.h"
#import "timeTool.h"


@interface chatViewController () <UITableViewDataSource,UITableViewDelegate,UITextViewDelegate,EMChatManagerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,CustomViewDelegate>

/**输入工具条底部的约束*/
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inputToolBarConstraint;
/**输入工具条高度的约束*/
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chatInputToolbarHeightConstraint;

@property (weak, nonatomic) IBOutlet UIButton *moreButton;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

/** 数据源 */
@property (strong , nonatomic) NSMutableArray *dataSource;

/** 计算高度的cell工具对象 */
@property (nonatomic, strong) chatViewCell *chatCellTool;

//按下录音按钮
@property (weak, nonatomic) IBOutlet UIButton *recordBtn;
//键盘/录音按钮
@property (weak, nonatomic) IBOutlet UIButton *voiceBtn;
@property (weak, nonatomic) IBOutlet UITextView *MyTextView;

@property (strong , nonatomic) CustomView *customView;
@property (strong , nonatomic) NSString *currentTimeStr;
@property (nonatomic , strong) EMConversation *conversation;

@end

@implementation chatViewController

-(NSMutableArray *)dataSource {
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = self.buddy.username;
    
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
     // 加载本地数据库聊天记录
    [self loadLocalChatRecords];
    
    self.chatCellTool = [self.tableView dequeueReusableCellWithIdentifier:receiveCell];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

   
    [self.tableView reloadData];
    [self scrollToBottom];
    
    //监听键盘弹出
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kbWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    //监听键盘退出
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kbWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

//键盘弹出
- (void) kbWillShow:(NSNotification *) noti {
    
    self.MyTextView.inputView = nil;
    //键盘弹出结束后的位置
    CGRect rect = [noti.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat animationDuration = [noti.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGFloat keHeight = rect.size.height;
    self.inputToolBarConstraint.constant = keHeight;
    
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
        [self.tableView reloadData];
        [self scrollToBottom];
    }];
}

//键盘退出
- (void) kbWillHide:(NSNotification *) noti {
    //inputToolBar回到原位
    self.inputToolBarConstraint.constant = 0;
    CGFloat animationDuration = [noti.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
}

//获取本地聊天记录
- (void) loadLocalChatRecords {
    //获取本地聊天记录使用会话对象
    EMConversation *conversation = [[EaseMob sharedInstance].chatManager conversationForChatter:self.buddy.username conversationType:eConversationTypeChat];
    self.conversation = conversation;
    //加载与当前聊天用户对象的所有聊天记录
    NSArray *messages = [conversation loadAllMessages];
    
    [messages enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[EMMessage class]]) {
            [self addDataSourceWithmMessage:obj];
        }
    }];
}

#pragma mark - UITable view datasource
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self.dataSource[indexPath.row] isKindOfClass:[NSString class]]) {
        timeViewCell *cell = [tableView dequeueReusableCellWithIdentifier:showTimeCell];
        cell.timeLabel.text = self.dataSource[indexPath.row];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    
    EMMessage *message = self.dataSource[indexPath.row];
    chatViewCell *cell = nil;
    
    if ([message.from isEqualToString:self.buddy.username]) {
        //接收方
        cell = [tableView dequeueReusableCellWithIdentifier:receiveCell];
    }
    else {
        //发送方
        cell = [tableView dequeueReusableCellWithIdentifier:sendCell];
    }
    
    cell.message = message;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark - UITable view delegate
- (CGFloat) tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 200;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self.dataSource[indexPath.row] isKindOfClass:[NSString class]]) {
        return 32;
    }
    EMMessage *message = self.dataSource[indexPath.row];
    self.chatCellTool.message = message;
    return [self.chatCellTool cellHeight];;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.view endEditing:YES];
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    //滑动时停止播放
    [AudioPlayTool stopPlay];
}


#pragma mark - UIText view delegate
- (void) textViewDidChange:(UITextView *)textView {
    NSLog(@"%@",textView.text);
    
    CGFloat textViewH = 0;
    CGFloat textViewMinH = 33;
    CGFloat textViewMaxH = 68;
    
    CGFloat contentHeight = textView.contentSize.height;
    if (contentHeight < textViewMinH) {
        textViewH = textViewMinH;
    }
    else if (contentHeight > textViewMaxH) {
        textViewH = textViewMaxH;
    }
    else {
        textViewH = contentHeight;
    }
    
    if ([textView.text hasSuffix:@"\n"]) {
        //发送消息
        [self sendText:textView.text];
        //发送完后要清空
        textView.text = nil;
        textViewH = textViewMinH;
    }
    
    self.chatInputToolbarHeightConstraint.constant = 6 + textViewH + 7;
    [UIView animateWithDuration:0.25 animations:^{
        [self.view layoutIfNeeded];
    }];
    
    /**让光标回到原位 */
//  [textView setContentOffset:CGPointZero animated:YES];
//  [textView scrollRangeToVisible:textView.selectedRange];
}


#pragma mark - 发送消息

- (void) sendMessage:(id<IEMMessageBody>) body {
    //创建一个消息对象
    EMMessage *message = [[EMMessage alloc]initWithReceiver:self.buddy.username bodies:@[body]];
    message.messageType = eMessageTypeChat;
    
    //发送消息
    [[EaseMob sharedInstance].chatManager asyncSendMessage:message progress:nil prepare:^(EMMessage *message, EMError *error) {
        NSLog(@"准备发送消息");
    } onQueue:nil completion:^(EMMessage *message, EMError *error) {
        NSLog(@"消息发送成功 %@",error);
    } onQueue:nil];
    
    [self addDataSourceWithmMessage:message];
    [self.tableView reloadData];
    [self scrollToBottom];
}

//发送文本消息
- (void) sendText:(NSString *) text {
    //去掉text 中的"\n"占位符
    text = [text substringToIndex:text.length - 1];
    // 创建一个聊天文本对象
    EMChatText *chatText = [[EMChatText alloc] initWithText:text];
    //创建一个文本消息体
    EMTextMessageBody *textBody = [[EMTextMessageBody alloc] initWithChatObject:chatText];
    
    [self sendMessage:textBody];
}

//发送语音消息
- (void) sendVoiceMessage:(NSString *) fileName duration:(NSInteger) duration {
    //创建一个聊天语音对象
    EMChatVoice *chatVoice = [[EMChatVoice alloc] initWithFile:fileName displayName:@"[语音消息]"];
    chatVoice.duration = duration;
    EMVoiceMessageBody *voiceBody = [[EMVoiceMessageBody alloc] initWithChatObject:chatVoice];

    [self sendMessage:voiceBody];
}

//发送图片
-(void) sendImage:(UIImage *) selectedImage {
    EMChatImage *chatImage = [[EMChatImage alloc] initWithUIImage:selectedImage displayName:@"[图片]"];
    EMImageMessageBody *imageBody = [[EMImageMessageBody alloc] initWithImage:chatImage thumbnailImage:nil];

    [self sendMessage:imageBody];
}

//接收消息
-(void)didReceiveMessage:(EMMessage *)message {
    if ([message.from isEqualToString:self.buddy.username]) {
        [self addDataSourceWithmMessage:message];
        [self.tableView reloadData];
        [self scrollToBottom];
    }
}

#pragma mark - UITableView 滑动到最后一行
- (void) scrollToBottom {
    if (self.dataSource.count == 0) {
        return;
    }
    NSIndexPath *lastIndex = [NSIndexPath indexPathForRow:self.dataSource.count - 1 inSection:0];
    [self.tableView scrollToRowAtIndexPath:lastIndex atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

#pragma mark - UIButtonAction

- (IBAction)voiceAction:(id)sender {
    
    if ([self.MyTextView isFirstResponder]) {
        [self.MyTextView endEditing:YES];
    }
    
    //录音和键盘切换按钮
    self.voiceBtn.selected = !self.voiceBtn.selected;
    //录音按钮
    self.recordBtn.hidden = !self.recordBtn.hidden;
    self.MyTextView.hidden = !self.MyTextView.hidden;
    
    if (self.recordBtn.hidden == NO) {//录音按钮要显示
        //inputToolBarConstraint的高度回复默认值(46)
        self.chatInputToolbarHeightConstraint.constant = 46;
        //隐藏藏键盘
        [self.view endEditing:YES];
    }
    else {
        //当不录音的时候,键盘显示
        [self.MyTextView becomeFirstResponder];
        
        //恢复原来的高度
        [self textViewDidChange:self.MyTextView];
    }
}

//按下开始录音
- (IBAction)didStartRecordAction:(id)sender {
    
    int count = arc4random() % 100000;
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    NSString *fileName = [NSString stringWithFormat:@"%d%d",(int)time,count];
    [[EMCDDeviceManager sharedInstance] asyncStartRecordingWithFileName:fileName completion:^(NSError *error) {
        if (!error) {
            NSLog(@"开始录音");
        }
    }];
}

//在按钮范围内松手结束录音并发送
- (IBAction)didFinishRecordAction:(id)sender {
    [[EMCDDeviceManager sharedInstance] asyncStopRecordingWithCompletion:^(NSString *recordPath, NSInteger aDuration, NSError *error) {
        if (!error) {
            NSLog(@"录音成功");
            [self sendVoiceMessage:recordPath duration:aDuration];
        }
    }];
}

//在按钮范围之外松手取消录音
- (IBAction)didCancleRecordAction:(id)sender {
    [[EMCDDeviceManager sharedInstance] cancelCurrentRecording];
}

- (IBAction)moreBtn:(id)sender {
    self.moreButton.selected = !self.moreButton.selected;
    if (!self.moreButton.selected) {
        
        if ([self.MyTextView isFirstResponder]) {
            [self.MyTextView resignFirstResponder];
        }

        self.MyTextView.inputView = nil;
        [self.MyTextView becomeFirstResponder];
    }
    else {
        if ([self.MyTextView isFirstResponder]) {
            [self.MyTextView resignFirstResponder];
        }
        CustomView *customView = [[CustomView alloc] init];
        customView.delegate = self;
        self.MyTextView.inputView = customView;
        [self.MyTextView becomeFirstResponder];
    }
}


#pragma mark - UIImagePickerControllerDelegate
- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [self sendImage:info[UIImagePickerControllerOriginalImage]];
    [self dismissViewControllerAnimated:YES completion:nil];
}



#pragma mark - CustomViewDelegate
-(void) customeView:(CustomView *)customView WithTag:(NSInteger)tag {
    
    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    pickerController.delegate = self;
    [self presentViewController:pickerController animated:YES completion:nil];
}

//添加数据源
- (void) addDataSourceWithmMessage:(EMMessage *) message {
     NSString *timeStr = [timeTool timeString:message.timestamp];
    if (![self.currentTimeStr isEqualToString:timeStr]) {
        [self.dataSource addObject:timeStr];
        self.currentTimeStr = timeStr;
    }
    
    [self.dataSource addObject:message];
    
    //设置消息为已读
    [self.conversation markMessageWithId:message.messageId asRead:YES];
    
}

- (void) viewWillAppear:(BOOL)animated {
    NSLog(@"3333:%@",self.buddy.username);
    NSLog(@"4444:%@",self.conversation.chatter);
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
}


//- (void) viewWillDisappear:(BOOL)animated {
//     讲所有消息标记为已读
//    [_conversation markAllMessagesAsRead:YES];
//}


@end
