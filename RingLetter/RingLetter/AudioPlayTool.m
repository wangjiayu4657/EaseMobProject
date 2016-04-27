//
//  AudioPlayTool.m
//  RingLetter
//
//  Created by fangjs on 16/4/15.
//  Copyright © 2016年 fangjs. All rights reserved.
//

#import "AudioPlayTool.h"

static UIImageView *animatingImageView;//正在执行动画的ImageView

@implementation AudioPlayTool

+ (void) playWithMessage:(EMMessage *) message withMessageLabel:(UILabel *)messageLabel withReceive:(BOOL)receive {
    //播放语音
    
    //把以前的动画先移除
    [animatingImageView stopAnimating];
    [animatingImageView removeFromSuperview];
    
    //获取语音路径
    EMVoiceMessageBody *voiceBody = message.messageBodies[0];
    NSString *voicePath = voiceBody.localPath;
    NSFileManager *filePath = [NSFileManager defaultManager];
    if (![filePath fileExistsAtPath:voicePath]) {
        voicePath = voiceBody.remotePath;
    }
    [[EMCDDeviceManager sharedInstance] asyncPlayingWithPath:voicePath completion:^(NSError *error) {
        NSLog(@"播放完毕%@",error);
        [animatingImageView stopAnimating];
        [animatingImageView removeFromSuperview];
    }];
    animatingImageView = [[UIImageView alloc] init];
    [messageLabel addSubview:animatingImageView];
    
    if (receive) {
        //接收方
        animatingImageView.frame = CGRectMake(0, 0, 30, 30);
        animatingImageView.animationImages = @[[UIImage imageNamed:@"chat_receiver_audio_playing000"],
                                               [UIImage imageNamed:@"chat_receiver_audio_playing001"],
                                               [UIImage imageNamed:@"chat_receiver_audio_playing002"],
                                               [UIImage imageNamed:@"chat_receiver_audio_playing003"]];
    }
    else {
        //发送方
        animatingImageView.frame = CGRectMake(messageLabel.bounds.size.width - 30,0, 30, 30);
        animatingImageView.animationImages = @[[UIImage imageNamed:@"chat_sender_audio_playing_000"],
                                               [UIImage imageNamed:@"chat_sender_audio_playing_001"],
                                               [UIImage imageNamed:@"chat_sender_audio_playing_002"],
                                               [UIImage imageNamed:@"chat_sender_audio_playing_003"]];
    }
      animatingImageView.animationDuration = 1.2f;
     [animatingImageView startAnimating];
}

+(void)stopPlay {
    //停止播放
    [[EMCDDeviceManager sharedInstance] stopPlaying];
    
    //移除动画
    [animatingImageView stopAnimating];
    [animatingImageView removeFromSuperview];
}

@end
