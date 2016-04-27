//
//  BadgeTableViewCell.h
//  RingLetter
//
//  Created by fangjs on 16/4/25.
//  Copyright © 2016年 fangjs. All rights reserved.
//

#import <UIKit/UIKit.h>


static NSString * const badgeCell = @"badgeCell";

@interface BadgeTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;

@property (weak, nonatomic) IBOutlet UILabel *contentLabel;

@property (weak, nonatomic) IBOutlet UILabel *timestampLabel;

@property (weak, nonatomic) IBOutlet UILabel *badgeLabel;

@property (weak, nonatomic) IBOutlet UIImageView *userPhoto;


- (void) showBageCount:(NSInteger) count WithMessage:(EMMessage *) message;


@end
