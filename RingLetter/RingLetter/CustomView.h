//
//  CustomView.h
//  RingLetter
//
//  Created by fangjs on 16/4/18.
//  Copyright © 2016年 fangjs. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CustomView;
@protocol CustomViewDelegate <NSObject>

-(void) customeView:(CustomView *) customView WithTag:(NSInteger) tag;

@end

@interface CustomView : UIView

@property (assign , nonatomic) CGFloat viewHeight;
@property (assign , nonatomic) id<CustomViewDelegate> delegate;

+ (instancetype) shareCustomView;
- (instancetype) init;


@end
