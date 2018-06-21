//
//  ViewController.m
//  CircleIrregularTransform
//
//  Created by thatsoul on 15/12/13.
//  Copyright © 2015年 chenms.m2. All rights reserved.
//

#import "ViewController.h"
#import "CircleIrregularTransformLayer.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIView *animationView;
@property (nonatomic) CircleIrregularTransformLayer *animationLayer;
@end

@implementation ViewController

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    [self addAnimationLayer];
}

- (void)addAnimationLayer {
    self.animationLayer = [CircleIrregularTransformLayer layer];
    self.animationLayer.contentsScale = [UIScreen mainScreen].scale;
    self.animationLayer.frame = self.animationView.bounds;
    self.animationLayer.progress = 0;
    [self.animationView.layer addSublayer:self.animationLayer];
}


#pragma mark - user event
- (IBAction)onTapStartAnimation:(id)sender {
    // reset
    [self.animationLayer removeAllAnimations];
    
    // end status
    self.animationLayer.progress = 1;

    // animation
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"progress"];
    animation.duration = 2;
    animation.fromValue = @(0.0);
    animation.toValue = @(1.0);
    [self.animationLayer addAnimation:animation forKey:nil];
}

@end
