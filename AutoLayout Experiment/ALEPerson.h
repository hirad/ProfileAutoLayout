//
//  ALEPerson.h
//  AutoLayout Experiment
//
//  Created by Hirad Motamed on 2015-06-26.
//  Copyright (c) 2015 Pendar-Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ALEPerson : NSObject

+(instancetype)hirad;

@property (nonatomic, copy) NSString* name;
@property (nonatomic, copy) NSString* title;
@property (nonatomic, copy) NSString* handle;
@property (nonatomic, strong) UIImage* profilePicture;

@end
