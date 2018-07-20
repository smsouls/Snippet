//
//  THTimeUtility.h
//  Member_THappy
//
//  Created by 123 on 2018/7/20.
//  Copyright © 2018年 NoName. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface THTimeUtility : NSObject

///获取当前时间
+ (NSString *)currentDateStr;

///获取当前时间戳
+ (NSTimeInterval)currentTimeStamp;

///时间戳转时间
+ (NSString *)getDateStringWithTimeStamp:(long)timeStamp;

///给定日期的时间戳
+ (NSString *)getTimeStrWithString:(NSString *)str;

@end
