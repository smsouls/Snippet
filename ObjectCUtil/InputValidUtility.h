//
//  InputValidUtility.h
//  Member_THappy
//
//  Created by 123 on 2018/7/13.
//  Copyright © 2018年 NoName. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InputValidUtility : NSObject

///验证手机号码是否合法
+ (BOOL)phoneValidMobile:(NSString *)mobile;

///验证身份证号是否正确
+ (BOOL)checkIDCard:(NSString *)identityCard;

///验证名字的合法性
+ (BOOL)isVaildRealName:(NSString *)realName;
@end
