//
//  BadgeTableViewCell.m
//  RingLetter
//
//  Created by fangjs on 16/4/25.
//  Copyright © 2016年 fangjs. All rights reserved.
//

#import "BadgeTableViewCell.h"
#import "timeTool.h"

@implementation BadgeTableViewCell

- (void)awakeFromNib {
    self.badgeLabel.layer.masksToBounds = YES;
    self.badgeLabel.layer.cornerRadius = 10.0f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}


- (void)showBageCount:(NSInteger)count WithMessage:(EMMessage *)message {
    if (count != 0) {
         self.badgeLabel.hidden = NO;
         self.badgeLabel.text = [NSString stringWithFormat:@"%ld",(long)count];
    }
    else {
        self.badgeLabel.hidden = YES;
    }
    
    NSString *timeStr = [timeTool timeString:message.timestamp];
    self.timestampLabel.text = timeStr;
    
}

@end
