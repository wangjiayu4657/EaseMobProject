//
//  timeTool.m
//  RingLetter
//
//  Created by fangjs on 16/4/22.
//  Copyright © 2016年 fangjs. All rights reserved.
//

#import "timeTool.h"

@implementation timeTool


+ (NSString *) timeString:(long long)timestamp {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    //湖区当前时间
    NSDate *currentDate = [NSDate date];
    
    //获取年, 月, 日
    NSDateComponents *components = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:currentDate];
    NSInteger currentYear = components.year;
    NSInteger currentMonth = components.month;
    NSInteger currentDay = components.day;
    
    //获取年, 月, 日
    NSDate *messageDate = [NSDate dateWithTimeIntervalSince1970:timestamp/1000.0];
    components = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:messageDate];
    NSInteger messageYear = components.year;
    NSInteger messageMonth = components.month;
    NSInteger messageDay = components.day;
    
    /*
     *今天：(HH:mm)
     *昨天: (昨天 HH:mm)
     *昨天以前:（2015-09-26 15:27）
     */
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if (currentYear == messageYear && currentMonth == messageMonth && currentDay == messageDay) {
        formatter.dateFormat = @"HH:mm";
    }
    else if (currentYear == messageYear && currentMonth == messageMonth && currentDay-1 == messageDay) {
        formatter.dateFormat = @"昨天 HH:mm";
    }
    else {
        formatter.dateFormat = @"yyyy-MM-dd HH:mm";
    }
    
    return [formatter stringFromDate:messageDate];
}

@end
