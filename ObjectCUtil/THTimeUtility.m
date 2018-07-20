//
//  THTimeUtility.m
//  Member_THappy
//
//  Created by 123 on 2018/7/20.
//  Copyright © 2018年 NoName. All rights reserved.
//

#import "THTimeUtility.h"

@implementation THTimeUtility

///获取当前时间
+ (NSString *)currentDateStr {
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"YYYY/MM/dd hh:mm:ss SS"];
    NSString *dateString = [dateFormatter stringFromDate:currentDate];
    return dateString;
}


///获取当前时间戳
+ (NSTimeInterval)currentTimeStamp {
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval time = [date timeIntervalSince1970] * 1000;
    return time;
}


///时间戳转时间
+ (NSString *)getDateStringWithTimeStamp:(long)timeStamp {
    NSDate *detailDate = [NSDate dateWithTimeIntervalSince1970:timeStamp];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"YYYY/MM/dd hh:mm:ss SS"];
    NSString *currentDateStr = [dateFormatter stringFromDate:detailDate];
    return currentDateStr;
}


///给定日期的时间戳
+ (NSString *)getTimeStrWithString:(NSString *)str {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"YYYY/MM/dd hh:mm:ss"];
    NSDate *tempDate = [dateFormatter dateFromString:str];
    NSString *timeStr = [NSString stringWithFormat:@"%ld", (long)[tempDate timeIntervalSince1970] * 1000];
    return timeStr;
    
}



@end
