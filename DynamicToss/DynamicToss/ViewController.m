//
//  ViewController.m
//  DynamicToss
//
//  Created by rushyourmind on 15/6/26.
//  Copyright (c) 2015年 rym. All rights reserved.
//

#import "ViewController.h"

static const CGFloat ThrowingThreshold = 1000;
static const CGFloat ThrowingVelocityPadding = 35;
@interface ViewController ()

@property (nonatomic, weak) IBOutlet UIView *image;
@property (nonatomic, weak) IBOutlet UIView *redSquare;
@property (nonatomic, weak) IBOutlet UIView *blueSquare;

@property (nonatomic, assign) CGRect originalBounds;
@property (nonatomic, assign) CGPoint originalCenter;

@property (nonatomic) UIDynamicAnimator *animator;
@property (nonatomic) UIAttachmentBehavior *attachmentBehavior;
@property (nonatomic) UIPushBehavior *pushBehavior;
@property (nonatomic) UIDynamicItemBehavior *itemBehavior;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    self.originalBounds = self.image.bounds;
    self.originalCenter = self.image.center;
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)resetDemo
{
    [self.animator removeAllBehaviors];
    
    [UIView animateWithDuration:0.45 animations:^{
        self.image.bounds = self.originalBounds;
        self.image.center = self.originalCenter;
        self.image.transform = CGAffineTransformIdentity;
    }];
}
- (IBAction)handleAttachmentGesture :(UIPanGestureRecognizer* )gesture
{
    CGPoint location = [gesture locationInView:self.view];
    CGPoint boxLocation = [gesture locationInView:self.image];
    
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:{
            
            NSLog(@"you touch started position %@", NSStringFromCGPoint(location));
            NSLog(@"location in image started is %@",NSStringFromCGPoint(boxLocation));
            [self.animator removeAllBehaviors];
            UIOffset centerOffset = UIOffsetMake(boxLocation.x - CGRectGetMidX(self.image.bounds), boxLocation.y - CGRectGetMidY(self.image.bounds));
            self.attachmentBehavior = [[UIAttachmentBehavior alloc] initWithItem:self.image offsetFromCenter:centerOffset attachedToAnchor:location];
            self.redSquare.center = self.attachmentBehavior.anchorPoint;
            self.blueSquare.center = location;
            
            [self.animator addBehavior:self.attachmentBehavior];
            break;
        }
        case UIGestureRecognizerStateEnded:{
            NSLog(@"you touch ended position %@", NSStringFromCGPoint(location));
            NSLog(@"location in image ended is %@", NSStringFromCGPoint(boxLocation));
            [self.animator removeBehavior:self.attachmentBehavior];
            
            CGPoint velocity = [gesture velocityInView:self.view];
            CGFloat magnitude = sqrtf(velocity.x * velocity.x + velocity.y*velocity.y);
            
            if (magnitude > ThrowingThreshold){
                UIPushBehavior *pushBehavior = [[UIPushBehavior alloc] initWithItems:@[self.image] mode:UIPushBehaviorModeInstantaneous];
                pushBehavior.pushDirection = CGVectorMake((velocity.x/10), (velocity.y/10));
                pushBehavior.magnitude = magnitude/50;
                
                self.pushBehavior = pushBehavior;
                
                [self.animator addBehavior:self.pushBehavior];
                
                NSInteger angle = arc4random_uniform(20) -  10;
                self.itemBehavior.friction = 0.2;
                self.itemBehavior.allowsRotation = YES;
                [self.itemBehavior addAngularVelocity:angle forItem:self.image];
                [self.animator addBehavior:self.itemBehavior];
                
                
                [self performSelector:@selector(resetDemo) withObject:nil afterDelay:0.4];
            }else{
            
            [self resetDemo];
            }
            break;
        }
        default:
            [self.attachmentBehavior setAnchorPoint:[gesture locationInView:self.view]];
            self.redSquare.center = self.attachmentBehavior.anchorPoint;
            break;
    }
    
}
@end
