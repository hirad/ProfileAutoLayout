//
//  ALEPerson.m
//  AutoLayout Experiment
//
//  Created by Hirad Motamed on 2015-06-26.
//  Copyright (c) 2015 Pendar-Labs. All rights reserved.
//

#import "ALEPerson.h"

@implementation ALEPerson

+(instancetype)hirad {
    ALEPerson* instance = [ALEPerson new];
    instance.name = @"Hirad M.";
    instance.title = @"iOS Dev";
    instance.handle = @"@theHirad";
    instance.profilePicture = [UIImage imageNamed:@"face"];
    
    return instance;
}

@end
