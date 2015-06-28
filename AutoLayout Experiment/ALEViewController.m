//
//  ALEViewController.m
//  AutoLayout Experiment
//
//  Created by Hirad Motamed on 11/8/2013.
//  Copyright (c) 2013 Pendar-Labs. All rights reserved.
//

#import "ALEViewController.h"


CGFloat const kDefaultHeaderHeight = 120.0;
CGFloat const kDefaultProfilePictureWidth = 70.0;
CGFloat const kDefaultProfilePictureLead = 30.0;
CGFloat const kSmallProfilePictureWidth = 40.0;
CGFloat const kShiftThreshold = -50.0; // translation after which to move the profile pic behind.
CGFloat const kDefaultProfilePictureOffset = -30.0;
CGFloat const kTranslationForFullyTransparentHeaderNameLabel = -110;
CGFloat const kTranslationForFullyOpaqueHeaderNameLabel = -150;

CGFloat translationMultiplierForCurrentValue(CGFloat value) {
    CGFloat adjustedValue = value;
    if (adjustedValue < kShiftThreshold) {
        adjustedValue = kShiftThreshold;
    }
    else if (adjustedValue > 0.0) {
        adjustedValue = 0.0;
    }
    return adjustedValue/(kShiftThreshold);
}

CGFloat currentValueForMultiplier(CGFloat multiplier, CGFloat start, CGFloat end) {
    return multiplier * (end - start) + start;
}

CGFloat boundedNumber(CGFloat number, CGFloat min, CGFloat max) {
    if (number < min) {
        return min;
    }
    else if (number > max) {
        return max;
    }
    else {
        return number;
    }
}


@interface UIView (SubviewArrangementConvenience)

-(void)bringSubviewsToFront:(NSArray*)subviews;

@end

@implementation UIView (SubviewArrangementConvenience)

-(void)bringSubviewsToFront:(NSArray *)subviews {
    for (UIView* aSubview in subviews) {
        NSAssert([aSubview isDescendantOfView:self],
                 @"Views provided to `bringSubviewsToFront:` must be subviews of receiver.");
        [self bringSubviewToFront:aSubview];
    }
}

@end


@interface ALEViewController ()
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIImageView *profilePictureView;
@property (weak, nonatomic) IBOutlet UIButton *composeButton;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *handleLabel;
@property (weak, nonatomic) IBOutlet UILabel *headerNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *headerHandleLabel;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *profilePictureWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *profilePictureOffsetConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentAndHeaderAttachmentConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *profilePictureLeadingConstraint;

@property (assign, nonatomic) CGFloat currentOffset;
@end

@implementation ALEViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.person = [ALEPerson hirad];
    self.profilePictureView.image = self.person.profilePicture;
    self.nameLabel.text = self.headerNameLabel.text = self.person.name;
    self.handleLabel.text = self.headerHandleLabel.text = self.person.handle;
    _currentOffset = 0.0;
//    self.headerNameLabel.hidden = self.headerHandleLabel.hidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)moveContentView:(UIPanGestureRecognizer *)sender {
    CGFloat yTranslation = [sender translationInView:self.view].y;
    CGFloat yOffset = self.currentOffset + yTranslation;
    
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:
            [self panViewWithTranslation:yOffset animated:NO];
            break;
        case UIGestureRecognizerStateChanged:
            [self panViewWithTranslation:yOffset animated:NO];
            break;
        case UIGestureRecognizerStateEnded:
            if (yOffset < 0) {
                self.currentOffset = yOffset;
            }
            else {
                [self panViewWithTranslation:0.0 animated:YES];
                self.currentOffset = 0;
            }
        default:
            break;
    }
}

-(void)panViewWithTranslation:(CGFloat)translation animated:(BOOL)animated {
    CGFloat distance = self.headerViewHeightConstraint.constant - kDefaultHeaderHeight;
    CGFloat newHeaderHeight = kDefaultHeaderHeight + translation;
    
    CGFloat multiplier = translationMultiplierForCurrentValue(translation);
    CGFloat newProfilePictureOffset = currentValueForMultiplier(multiplier, kDefaultProfilePictureOffset, 0.0);
    CGFloat newProfilePictureWidth = currentValueForMultiplier(multiplier, kDefaultProfilePictureWidth, kSmallProfilePictureWidth);
    CGFloat profilePictureLeadingAdjustment = (int)((kDefaultProfilePictureWidth - newProfilePictureWidth)/2 + 0.5);
    
    CGFloat contentViewHeightOffset;
    if (translation < kShiftThreshold) {
        contentViewHeightOffset = (translation - kShiftThreshold);
        newHeaderHeight = kDefaultHeaderHeight + kShiftThreshold;
        [self.view bringSubviewsToFront:@[self.headerView, self.composeButton, self.searchButton]];
    }
    else {
        [self.view bringSubviewsToFront:@[self.contentView, self.composeButton, self.searchButton, self.profilePictureView]];
        contentViewHeightOffset = 0.0;
    }
    
    // show the header labels if the current name label has crossed the header
    CGFloat nameLabelY = [self.view convertPoint:self.nameLabel.frame.origin fromView:self.contentView].y;
    if (nameLabelY < newHeaderHeight) {
        CGFloat delta = newHeaderHeight - nameLabelY;
        CGFloat nameLabelAlpha = boundedNumber((translation - kTranslationForFullyOpaqueHeaderNameLabel)/(kTranslationForFullyTransparentHeaderNameLabel - kTranslationForFullyOpaqueHeaderNameLabel), 0, 1);
        CGFloat headerNameLabelAlpha = 1 - nameLabelAlpha;
        self.headerNameLabel.alpha = self.headerHandleLabel.alpha = headerNameLabelAlpha;
        self.nameLabel.alpha = self.handleLabel.alpha = nameLabelAlpha;
        NSLog(@"Label Delta: %f at translation: %f\tAlpha: %f", delta, translation, nameLabelAlpha);
    }
    CGFloat headerLabelOffset = MAX(kDefaultHeaderHeight + contentViewHeightOffset, 20.0);
    
//    NSLog(@"Xlation: %f\tOffset: %f\tHeader: %f\tHeader Offset: %f",
//          translation, newProfilePictureOffset, newHeaderHeight, contentViewHeightOffset);
    
    self.headerLabelTopConstraint.constant = headerLabelOffset;
    self.headerViewHeightConstraint.constant = newHeaderHeight;
    self.contentAndHeaderAttachmentConstraint.constant = contentViewHeightOffset;
    self.profilePictureOffsetConstraint.constant = newProfilePictureOffset;
    self.profilePictureWidthConstraint.constant = newProfilePictureWidth;
    self.profilePictureLeadingConstraint.constant = kDefaultProfilePictureLead + profilePictureLeadingAdjustment;
    [self.view setNeedsUpdateConstraints];
    void (^animationBlock)() = ^{
        [self.view layoutIfNeeded];
    };
    
    if (animated) {
        CGFloat speed = 200.0; // px/sec
        NSTimeInterval duration = ceil(fabs(distance/speed));
        [UIView animateWithDuration:duration
                              delay:0.0
             usingSpringWithDamping:0.8
              initialSpringVelocity:0.9
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:animationBlock
                         completion:nil];
    }
    else {
        animationBlock();
    }
}

@end
