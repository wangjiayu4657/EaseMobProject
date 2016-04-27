//
//  AudioPlayTool.h
//  RingLetter
//
//  Created by fangjs on 16/4/15.
//  Copyright © 2016年 fangjs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AudioPlayTool : NSObject

+ (void) playWithMessage:(EMMessage *) message withMessageLabel:(UILabel *) messageLabel withReceive:(BOOL) receive;

+ (void) stopPlay;

@end
