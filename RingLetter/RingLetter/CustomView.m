//
//  CustomView.m
//  RingLetter
//
//  Created by fangjs on 16/4/18.
//  Copyright © 2016年 fangjs. All rights reserved.
//

#import "CustomView.h"

@interface CustomView()

//@property (weak, nonatomic) IBOutlet UIButton *VoiceCallBtn;
//@property (weak, nonatomic) IBOutlet UIButton *TakingPhotosBtn;
//@property (weak, nonatomic) IBOutlet UIButton *PositioningBtn;
//@property (weak, nonatomic) IBOutlet UIButton *PicturesBtn;
//@property (weak, nonatomic) IBOutlet UIButton *VideoBtn;
//@property (weak, nonatomic) IBOutlet UIButton *ShootingBtn;

@end


@implementation CustomView


-(instancetype)init {
    if (self = [super init]) {
        self = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil] lastObject];
    }
    return self;
}


-(void)didMoveToSuperview {
    
//    [self.VoiceCallBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
//    [self.TakingPicturesBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
//    [self.PositioningBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
//    [self.PhotosBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
//    [self.VideoBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
//    [self.ShootingBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
}

+(instancetype)shareCustomView {
    return [[[NSBundle mainBundle] loadNibNamed:@"CustomView" owner:nil options:nil] lastObject];
}

//
//- (void) btnClick:(UIButton *) btn {
//    switch (btn.tag) {
//        case 0:
//        {
//          [self showMessage];
//          break;
//        }
//        case 1:
//        {
//            [self showMessage];
//            break;
//        }
//        case 2:
//        {
//            [self showMessage];
//            break;
//        }
//        case 3:
//        {
//            if ([self.delegate respondsToSelector:@selector(customeView:WithTag:)]) {
//                [self.delegate customeView:self WithTag:btn.tag];
//            }
//            break;
//        }
//        case 4:
//        {
//            [self showMessage];
//            break;
//        }
//            
//        default:
//            break;
//    }
//}


- (void) showMessage {
    
    UIAlertController *alter = [UIAlertController alertControllerWithTitle:@"消息提示" message:@"正在开发中,敬请期待" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"我知道了" style:UIAlertActionStyleDefault handler:nil];
    [alter addAction:ok];

    [self.window.rootViewController presentViewController:alter animated:YES completion:nil];
}


#pragma mark - buttonAction

- (IBAction)VoiceCallBtn:(id)sender {
    [self showMessage];
}
- (IBAction)TakingPhotosBtn:(id)sender {
    [self showMessage];
}
- (IBAction)PositioningBtn:(id)sender {
    [self showMessage];
}
- (IBAction)PicturesBtn:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(customeView:WithTag:)]) {
        [self.delegate customeView:self WithTag:sender.tag];
    }
}
- (IBAction)VideoBtn:(id)sender {
    [self showMessage];
}
- (IBAction)ShootingBtn:(id)sender {
    [self showMessage];
}


@end
