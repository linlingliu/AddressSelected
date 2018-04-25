//
//  MMTPickView.h
//  111
//
//  Created by LX on 2018/4/2.
//  Copyright © 2018年 LX. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^AddressBlock)(NSString *provice, NSString *city, NSString *area);

@interface MMTPickView : UIView

+ (instancetype)showWithAddressBlock:(AddressBlock)block;

@end
