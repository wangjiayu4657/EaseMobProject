//
//  showImageView.m
//  RingLetter
//
//  Created by fangjs on 16/4/18.
//  Copyright © 2016年 fangjs. All rights reserved.
//

#import "showImageView.h"
#import "UIImageView+WebCache.h"

@implementation showImageView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void) didMoveToSuperview {
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:imageView];
    NSLog(@"%@",NSStringFromCGRect(self.bounds));
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:self.imagePath]) {
        [imageView sd_setImageWithURL:[NSURL fileURLWithPath:self.imagePath] placeholderImage:[UIImage imageNamed:@"downloading"]];
    }
    else {
        [imageView sd_setImageWithURL:[NSURL URLWithString:self.imagePath] placeholderImage:[UIImage imageNamed:@"downloading"]];
    }
}

- (void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self removeFromSuperview];
}


@end
