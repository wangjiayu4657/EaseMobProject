//
//  chatViewCell.m
//  RingLetter
//
//  Created by fangjs on 16/4/13.
//  Copyright © 2016年 fangjs. All rights reserved.
//

#import "chatViewCell.h"
#import "AudioPlayTool.h"
#import "UIImageView+WebCache.h"
#import "showImageView.h"


@interface chatViewCell ()

#define  ScreenWidth [UIScreen mainScreen].bounds.size.width
#define  ScreenHeight [UIScreen mainScreen].bounds.size.height

@property (strong , nonatomic) NSString *imagePath;
@property (strong , nonatomic) UIImageView *chatImageView;


@end

@implementation chatViewCell


-(UIImageView *)chatImageView {
    if (!_chatImageView) {
        _chatImageView = [[UIImageView alloc] init];
    }
    return _chatImageView;
}

- (void)awakeFromNib {
    //给 label 添加点击手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(messageLabelTap:)];
    [self.messageLabel addGestureRecognizer:tap];
}

- (void) messageLabelTap:(UITapGestureRecognizer *) recognizer {
   
    //只有当前的类型为语音的时候才开始播放
    //获取消息体
    id body = self.message.messageBodies[0];
    if ([body isKindOfClass:[EMVoiceMessageBody class]]) {
         NSLog(@"正在播放");
         BOOL receive = [self.reuseIdentifier isEqualToString:receiveCell];
         [AudioPlayTool playWithMessage:self.message withMessageLabel:self.messageLabel withReceive:receive];
    }
//    else if ([body isKindOfClass:[EMImageMessageBody class]]) {
//        showImageView *showImage = [[showImageView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
//        showImage.imagePath = self.imagePath;
//        showImage.backgroundColor = [UIColor grayColor];
//        UIWindow *window = [UIApplication sharedApplication].keyWindow;
//        [window addSubview:showImage];
//    }
}

-(CGFloat)cellHeight {
    [self layoutIfNeeded];
    return 10 + 10 + self.messageLabel.bounds.size.height + 10 + 5;
}


-(void)setMessage:(EMMessage *)message {    
    [self.chatImageView removeFromSuperview];

    _message = message;
    id body = message.messageBodies[0];
    
    if ([body isKindOfClass:[EMTextMessageBody class]]) {
        EMTextMessageBody *textBody = body;
        self.messageLabel.text = textBody.text;
    }
    else if ([body isKindOfClass:[EMVoiceMessageBody class]]) {
        self.messageLabel.attributedText = [self voiceAttributedString];
    }
    else if ([body isKindOfClass:[EMImageMessageBody class]]) {
        [self showImage];
    }
    else {
        NSLog(@"视屏消息");
    }
}

- (void) showImage {
    
    EMImageMessageBody *imageBody = self.message.messageBodies[0];
    CGRect thumbnailFrame = (CGRect){0,0,imageBody.thumbnailSize};
    
    NSTextAttachment *imageAttach = [[NSTextAttachment alloc] init];
    imageAttach.bounds = thumbnailFrame;
    NSAttributedString *imageAtt = [NSAttributedString attributedStringWithAttachment: imageAttach];
    self.messageLabel.attributedText = imageAtt;
    
    self.chatImageView.frame = thumbnailFrame;
    [self.messageLabel addSubview: self.chatImageView];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:imageBody.thumbnailLocalPath]) {
        [self.chatImageView sd_setImageWithURL:[NSURL fileURLWithPath:imageBody.thumbnailLocalPath] placeholderImage:[UIImage imageNamed:@"downloading"]];
        self.imagePath = imageBody.thumbnailLocalPath;
    }
    else {
        [self.chatImageView sd_setImageWithURL:[NSURL fileURLWithPath:imageBody.thumbnailRemotePath] placeholderImage:[UIImage imageNamed:@"downloading"]];
        self.imagePath = imageBody.thumbnailRemotePath;
    }
    
}

#pragma mark - 返回语音富文本

- (NSAttributedString *) voiceAttributedString {
    NSMutableAttributedString *voiceMutableAttributedString = [[NSMutableAttributedString alloc] init];
   
    if ([self.reuseIdentifier isEqualToString:receiveCell]) {
        // 1.接收方: 富文本 = 图片 + 时间
        //接收方的语音图片
        UIImage *receiverImage = [UIImage imageNamed:@"chat_receiver_audio_playing_full"];
        //创建图片的附件
        NSTextAttachment *imageAttachment = [[NSTextAttachment alloc] init];
        imageAttachment.image = receiverImage;
        imageAttachment.bounds = CGRectMake(0, -10, 30, 30);
        //创建富文本
        NSAttributedString *imageAttr = [NSAttributedString attributedStringWithAttachment:imageAttachment];
        [voiceMutableAttributedString appendAttributedString:imageAttr];
       
        //创建时间富文本
        //获取时间
        EMVoiceMessageBody *body = self.message.messageBodies[0];
        NSInteger duration = body.duration;
        NSString *timerStr = [NSString stringWithFormat:@"   %ld'",duration];
        NSAttributedString *timerAtt = [[NSAttributedString alloc] initWithString:timerStr];
        [voiceMutableAttributedString appendAttributedString:timerAtt];
    }
    else {
        // 1.接收方: 富文本 = 图片 + 时间
        //创建时间富文本
        EMVoiceMessageBody *body = self.message.messageBodies[0];
        NSInteger duration = body.duration;
        NSString *timerStr = [NSString stringWithFormat:@"%ld'   ",duration];
        NSAttributedString *timerAtt = [[NSAttributedString alloc] initWithString:timerStr];
        [voiceMutableAttributedString appendAttributedString:timerAtt];
        
        //接收方的语音图片
        UIImage *receiverImage = [UIImage imageNamed:@"chat_sender_audio_playing_full"];
        //创建图片的附件
        NSTextAttachment *imageAttachment = [[NSTextAttachment alloc] init];
        imageAttachment.image = receiverImage;
        imageAttachment.bounds = CGRectMake(0, -10, 30, 30);
        //创建富文本
        NSAttributedString *imageAttr = [NSAttributedString attributedStringWithAttachment:imageAttachment];
        [voiceMutableAttributedString appendAttributedString:imageAttr];
    }
    
    return [voiceMutableAttributedString copy];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}












































@end
