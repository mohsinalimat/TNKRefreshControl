//
//  TNKActivityIndicatorView.m
//  Pods
//
//  Created by David Beck on 1/13/15.
//
//

#import "TNKActivityIndicatorView.h"

#import <CKShapeView/CKShapeView.h>


#define TNKActivityIndicatorViewLineWidth (2.0)


@interface TNKActivityIndicatorView ()
{
    CKShapeView *_spinnerView;
    CGAffineTransform _defaultTransform;
    
    BOOL _animating;
}

@end

@implementation TNKActivityIndicatorView

#pragma mark - Properties

- (void)setProgress:(CGFloat)progress
{
    _progress = MAX(MIN(progress, 1.0), 0.0);
    
    [self _updateProgress];
}

- (void)_updateProgress
{
    [CATransaction setDisableActions:YES];
    if (!_animating) {
        _spinnerView.strokeEnd = 0.9 * _progress + _spinnerView.strokeStart;
    } else {
        _spinnerView.strokeEnd = 0.95;
    }
    [CATransaction setDisableActions:NO];
}

- (BOOL)isAnimating
{
    return _animating;
}

- (void)tintColorDidChange
{
    [super tintColorDidChange];
    
    _spinnerView.strokeColor = self.tintColor;
}


#pragma mark - Initialization

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _defaultTransform = CGAffineTransformMakeRotation(-M_PI_2);
        
        _spinnerView = [CKShapeView new];
        _spinnerView.fillColor = [UIColor clearColor];
        _spinnerView.strokeColor = self.tintColor;
        _spinnerView.strokeStart = 0.05;
        _spinnerView.strokeEnd = 0.95;
        _spinnerView.transform = _defaultTransform;
        [self addSubview:_spinnerView];
    }
    return self;
}


#pragma mark - Layout

- (CGSize)intrinsicContentSize
{
    return CGSizeMake(34.0, 34.0);
}

- (CGSize)sizeThatFits:(CGSize)size
{
    return self.intrinsicContentSize;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // because we are transforming this view all over the place, we can't set the frame
    _spinnerView.bounds = self.bounds;
    _spinnerView.center = CGPointMake(self.bounds.size.width / 2.0, self.bounds.size.height / 2.0);
    
    CGRect pathRect = CGRectInset(_spinnerView.bounds, TNKActivityIndicatorViewLineWidth / 2.0, TNKActivityIndicatorViewLineWidth / 2.0);
    UIBezierPath *path = path = [UIBezierPath bezierPathWithOvalInRect:pathRect];
    path.lineWidth = TNKActivityIndicatorViewLineWidth;
    _spinnerView.path = path;
}


#pragma mark - Animation

- (void)startAnimating
{
    [self startAnimatingWithFadeInAnimation:self.progress <= 0.0 completion:nil];
}

- (void)startAnimatingWithFadeInAnimation:(BOOL)animated completion:(void (^)())completion
{
    if (!_animating) {
        _animating = YES;
        
        [self _updateProgress];
        
        CABasicAnimation *refreshingAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        refreshingAnimation.duration = 1.0;
        refreshingAnimation.repeatCount = CGFLOAT_MAX;
        refreshingAnimation.fromValue = @(-M_PI_2);
        refreshingAnimation.toValue = @(M_PI * 2.0 - M_PI_2);
        [_spinnerView.layer addAnimation:refreshingAnimation forKey:@"refreshing"];
        
        if (animated) {
            _spinnerView.alpha = 0.0;
            
            [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                _spinnerView.alpha = 1.0;
                _spinnerView.transform = _defaultTransform;
            } completion:^(BOOL finished) {
                if (completion != nil) {
                    completion();
                }
            }];
        }
    }
}

- (void)stopAnimating
{
    [self stopAnimatingWithFadeAwayAnimation:YES completion:nil];
}

- (void)stopAnimatingWithFadeAwayAnimation:(BOOL)animated completion:(void (^)())completion
{
    if (_animating) {
        if (animated) {
            [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                _spinnerView.alpha = 0.0;
                _spinnerView.transform = CGAffineTransformMakeScale(0.1, 0.1);
            } completion:^(BOOL finished) {
                _spinnerView.alpha = 1.0;
                _spinnerView.transform = _defaultTransform;
                
                _animating = NO;
                [_spinnerView.layer removeAnimationForKey:@"refreshing"];
                [self _updateProgress];
                
                if (completion != nil) {
                    completion();
                }
            }];
        } else {
            _animating = NO;
            [_spinnerView.layer removeAnimationForKey:@"refreshing"];
            [self _updateProgress];
            
            if (completion != nil) {
                completion();
            }
        }
    }
}

@end
