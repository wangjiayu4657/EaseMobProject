//
//  chatViewCell.h
//  RingLetter
//
//  Created by fangjs on 16/4/13.
//  Copyright © 2016年 fangjs. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString *receiveCell = @"receiveMessageCell";
static NSString *sendCell = @"sendMessageCell";

@interface chatViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
/** 消息模型，内部set方法 显示文字 */
@property (strong , nonatomic) EMMessage *message;

- (CGFloat) cellHeight;

@end
