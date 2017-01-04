//
//  KKKNCustomAlertView.m
//  KKKWANSDK2017
//
//  Created by caf on 2016/12/27.
//  Copyright © 2016年 kkkwan. All rights reserved.
//

#import "KKKNCustomAlertView.h"

#ifndef kCFCoreFoundationVersionNumber_iOS_7_0
#define kCFCoreFoundationVersionNumber_iOS_7_0 847.20
#endif

#ifndef kCFCoreFoundationVersionNumber_iOS_8_0
#define kCFCoreFoundationVersionNumber_iOS_8_0 1129.15
#endif

#define KKKNCAVMainThreadAssert() NSAssert([NSThread isMainThread], @"KKKNCustomAlertView needs to be accessed on the main thread.");

//static const CGFloat KKKNCAVDefaultPadding = 10.f;
static const CGFloat KKKNCAVDefaultTitleLabelFontSize = 21.f;
static const CGFloat KKKNCAVDefaultLabelFontSize = 16.f;
//static const CGFloat KKKNCAVDefaultDetailsLabelFontSize = 12.f;
static const CGFloat KKKNCAVDefaultButtonFontSize = 20.f;
static const CGFloat KKKNCAVDefaultLineWidth = 0.5f;


static const CGFloat KKKNCAVDefaultFixedTextviewWidth = 250.f;

@interface KKKNCustomAlertView ()
@property (nonatomic, assign) BOOL useAnimation;
@property (nonatomic, assign, getter=hasFinished) BOOL finished;
@property (nonatomic, strong) NSDate *showStarted;
@property (nonatomic, strong) NSArray *paddingConstraints;
@property (nonatomic, strong) NSArray *bezelConstraints;
@property (nonatomic, strong) UIView *topSpacer;
@property (nonatomic, strong) UIView *bottomSpacer;

@property (nonatomic, strong) UIView *bHoriLine;
@property (nonatomic, strong) UIView *verLine;
@property (nonatomic, weak) NSTimer *minShowTimer;
@property (nonatomic, weak) NSTimer *graceTimer;
@property (nonatomic, weak) NSTimer *hideDelayTimer;

@end

@interface KKKNCAVRoundedButton : UIButton
@end

@interface KKKNCAVButton : UIButton
@end


@interface KKKNCAVTextView : UITextView
@end


@interface KKKNCAVLabel : UILabel
@end

@implementation KKKNCustomAlertView

+ (instancetype)showAlertAddedTo:(UIView *)view animated:(BOOL)animated
{
    KKKNCustomAlertView *av = [[self alloc] initWithView:view];
    av.removeFromSuperViewOnHide = YES;
    [view addSubview:av];
    [av showAnimated:animated];
    return av;
}

+ (BOOL)hideAlertForView:(UIView *)view animated:(BOOL)animated
{
    KKKNCustomAlertView *hud = [self HUDForView:view];
    
    if (hud != nil) {
        hud.removeFromSuperViewOnHide = YES;
        [hud hideAnimated:animated];
        return YES;
    }
    return NO;
}

+ (KKKNCustomAlertView *)HUDForView:(UIView *)view {
    NSEnumerator *subviewsEnum = [view.subviews reverseObjectEnumerator];
    for (UIView *subview in subviewsEnum) {
        if ([subview isKindOfClass:self]) {
            return (KKKNCustomAlertView *)subview;
        }
    }
    return nil;
}

- (id)initWithView:(UIView *)view {
    NSAssert(view, @"View must not be nil.");
    return [self initWithFrame:view.bounds];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    // Set default values for properties
    _animationType = KKKCAVAnimationZoomOut;
    _mode = KKKCAVModeSimple;
    _margin = 20.0f;
    _defaultMotionEffectsEnabled = YES;
    
    // Default color, depending on the current iOS version
    BOOL isLegacy = kCFCoreFoundationVersionNumber < kCFCoreFoundationVersionNumber_iOS_7_0;
    _contentColor = isLegacy ? [UIColor whiteColor] : [UIColor colorWithWhite:0.f alpha:0.7f];
    // Transparent background
    self.opaque = NO;
    self.backgroundColor = [UIColor clearColor];
    // Make it invisible for now
    self.alpha = 0.0f;
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.layer.allowsGroupOpacity = NO;
    
    [self setupViews];
}
#pragma mark - UI

- (void)setupViews {
    UIColor *defaultColor = self.contentColor;
    
    KKKCAVBackgroundView *backgroundView = [[KKKCAVBackgroundView alloc] initWithFrame:self.bounds];
    backgroundView.style = KKKCAVBackgroundStyleSolidColor;
    backgroundView.backgroundColor = [UIColor clearColor];
    backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    backgroundView.alpha = 0.f;
    [self addSubview:backgroundView];
    _backgroundView = backgroundView;
    
    KKKCAVBackgroundView *bezelView = [KKKCAVBackgroundView new];
    bezelView.translatesAutoresizingMaskIntoConstraints = NO;
    bezelView.layer.cornerRadius = 5.f;
    bezelView.alpha = 0.f;
    bezelView.userInteractionEnabled = YES;
    [self addSubview:bezelView];
    _bezelView = bezelView;
    
    [self updateBezelMotionEffects];
    
    
    UIButton *closeButton = [KKKNCAVRoundedButton buttonWithType:UIButtonTypeCustom];
    closeButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    closeButton.titleLabel.font = [UIFont boldSystemFontOfSize:KKKNCAVDefaultButtonFontSize];
    [closeButton setTitleColor:defaultColor forState:UIControlStateNormal];
    [closeButton setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    closeButton.translatesAutoresizingMaskIntoConstraints = NO;
    [closeButton setContentCompressionResistancePriority:998.f forAxis:UILayoutConstraintAxisHorizontal];
    [closeButton setContentCompressionResistancePriority:998.f forAxis:UILayoutConstraintAxisVertical];
    [self addSubview:closeButton];
    _closeButton = closeButton;
    
    
    
    
    
    UILabel *titleLabel = [KKKNCAVLabel new];
    titleLabel.adjustsFontSizeToFitWidth = NO;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = defaultColor;
    titleLabel.numberOfLines = 1;
    titleLabel.font = [UIFont boldSystemFontOfSize:KKKNCAVDefaultTitleLabelFontSize];
    titleLabel.opaque = NO;
    titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel = titleLabel;
    
    
    
    UITextView *textv = [KKKNCAVTextView new];
    textv.textAlignment = NSTextAlignmentCenter;
    textv.textColor = defaultColor;
    textv.font = [UIFont systemFontOfSize:KKKNCAVDefaultLabelFontSize];
    textv.opaque = NO;
    textv.backgroundColor = [UIColor clearColor];
    _centerTextView = textv;
    
    
    UIImageView *detailLabelBackGround = [UIImageView new];
    detailLabelBackGround.backgroundColor = [UIColor clearColor];
    _detailTextLabelBackGround = detailLabelBackGround;
    
    
    
    UILabel *detailsLabel = [KKKNCAVLabel new];
    detailsLabel.adjustsFontSizeToFitWidth = NO;
    detailsLabel.textAlignment = NSTextAlignmentCenter;
    detailsLabel.textColor = defaultColor;
    detailsLabel.numberOfLines = 0;
    detailsLabel.font = [UIFont systemFontOfSize:KKKNCAVDefaultLabelFontSize];
    detailsLabel.opaque = NO;
    detailsLabel.backgroundColor = [UIColor clearColor];
    _detailTextLabel = detailsLabel;
    
    
    
    
    UIView *bottomHoriLine = [UIView new];
    bottomHoriLine.backgroundColor = [UIColor lightGrayColor];
    _bHoriLine = bottomHoriLine;
    
    
    UIButton *leftbutton = [KKKNCAVButton buttonWithType:UIButtonTypeCustom];
    leftbutton.titleLabel.textAlignment = NSTextAlignmentCenter;
    leftbutton.titleLabel.font = [UIFont boldSystemFontOfSize:KKKNCAVDefaultButtonFontSize];
    [leftbutton setTitleColor:defaultColor forState:UIControlStateNormal];
    _leftButton = leftbutton;
    
    
    UIView *verline = [UIView new];
    verline.backgroundColor = [UIColor lightGrayColor];
    _verLine = verline;
    
    
    
    UIButton *rightbutton = [KKKNCAVButton buttonWithType:UIButtonTypeCustom];
    rightbutton.titleLabel.textAlignment = NSTextAlignmentCenter;
    rightbutton.titleLabel.font = [UIFont boldSystemFontOfSize:KKKNCAVDefaultButtonFontSize];
    [rightbutton setTitleColor:defaultColor forState:UIControlStateNormal];
    _rightButton = rightbutton;
    
    UIButton *centerButton = [KKKNCAVButton buttonWithType:UIButtonTypeCustom];
    centerButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    centerButton.titleLabel.font = [UIFont boldSystemFontOfSize:KKKNCAVDefaultButtonFontSize];
    [centerButton setTitleColor:defaultColor forState:UIControlStateNormal];
    _centerButton = centerButton;
    
    
    for (UIView *view in @[titleLabel,textv, detailLabelBackGround,detailsLabel, leftbutton, rightbutton, bottomHoriLine, verline, centerButton]) {
        view.translatesAutoresizingMaskIntoConstraints = NO;
        [view setContentCompressionResistancePriority:998.f forAxis:UILayoutConstraintAxisHorizontal];
        [view setContentCompressionResistancePriority:998.f forAxis:UILayoutConstraintAxisVertical];
        [bezelView addSubview:view];
    }
    
    UIView *topSpacer = [UIView new];
    topSpacer.translatesAutoresizingMaskIntoConstraints = NO;
    topSpacer.hidden = YES;
    [bezelView addSubview:topSpacer];
    _topSpacer = topSpacer;
    
    UIView *bottomSpacer = [UIView new];
    bottomSpacer.translatesAutoresizingMaskIntoConstraints = NO;
    bottomSpacer.hidden = YES;
    [bezelView addSubview:bottomSpacer];
    _bottomSpacer = bottomSpacer;
    
}

- (void)updateBezelMotionEffects {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000 || TARGET_OS_TV
    KKKCAVBackgroundView *bezelView = self.bezelView;
    if (![bezelView respondsToSelector:@selector(addMotionEffect:)]) return;
    
    if (self.defaultMotionEffectsEnabled) {
        CGFloat effectOffset = 10.f;
        UIInterpolatingMotionEffect *effectX = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
        effectX.maximumRelativeValue = @(effectOffset);
        effectX.minimumRelativeValue = @(-effectOffset);
        
        UIInterpolatingMotionEffect *effectY = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
        effectY.maximumRelativeValue = @(effectOffset);
        effectY.minimumRelativeValue = @(-effectOffset);
        
        UIMotionEffectGroup *group = [[UIMotionEffectGroup alloc] init];
        group.motionEffects = @[effectX, effectY];
        
        [bezelView addMotionEffect:group];
    } else {
        NSArray *effects = [bezelView motionEffects];
        for (UIMotionEffect *effect in effects) {
            [bezelView removeMotionEffect:effect];
        }
    }
#endif
}
- (void)updateViewsForColor:(UIColor *)color
{
    
    if (!self.contentColor) return;
    self.centerTextView.textColor = self.contentColor;
    [self.leftButton setTitleColor:self.contentColor forState:UIControlStateNormal];
    [self.rightButton setTitleColor:self.contentColor forState:UIControlStateNormal];
    [self.centerButton setTitleColor:self.contentColor forState:UIControlStateNormal];
    
    
    [self setNeedsUpdateConstraints];
}



#pragma mark - Layout


- (void)layoutSubviews
{
    
    CGSize minimumSize = self.minSize;
    if (CGSizeEqualToSize(minimumSize, CGSizeZero)) {
        self.detailTextLabel.preferredMaxLayoutWidth = KKKNCAVDefaultFixedTextviewWidth - 20;
        
        CGSize textViewFitSize = [self.centerTextView sizeThatFits:CGSizeMake(KKKNCAVDefaultFixedTextviewWidth , 0)];
        
        [self.centerTextView addConstraint:[NSLayoutConstraint constraintWithItem:self.centerTextView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:textViewFitSize.width]];
        [self.centerTextView addConstraint:[NSLayoutConstraint constraintWithItem:self.centerTextView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:textViewFitSize.height]];
        [self setNeedsUpdateConstraints];
    } else {
        self.detailTextLabel.preferredMaxLayoutWidth = minimumSize.width - 40;
        
        [self.centerTextView addConstraint:[NSLayoutConstraint constraintWithItem:self.centerTextView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:
                                            minimumSize.width - 40]];
        [self.centerTextView addConstraint:[NSLayoutConstraint constraintWithItem:self.centerTextView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:minimumSize.height - 100]];
        [self setNeedsUpdateConstraints];
    }
   
   
    
    [super layoutSubviews];
}

 
 

- (void)updateConstraints {
    UIView *bezel = self.bezelView;
    UIButton *closeButton = self.closeButton;
    UIView *topSpacer = self.topSpacer;
    UIView *bottomSpacer = self.bottomSpacer;
    CGFloat margin = self.margin;
    NSMutableArray *bezelConstraints = [NSMutableArray array];
    NSDictionary *metrics = @{@"margin": @(margin)};
    
    NSMutableArray *subviews = [NSMutableArray arrayWithObjects:self.topSpacer,self.titleLabel, self.centerTextView, self.detailTextLabelBackGround,self.detailTextLabel, self.bHoriLine ,self.leftButton, self.verLine,self.rightButton, self.centerButton,self.bottomSpacer, nil];
    
    // Remove existing constraints
    [self removeConstraints:self.constraints];
    [topSpacer removeConstraints:topSpacer.constraints];
    [bottomSpacer removeConstraints:bottomSpacer.constraints];
    
    if (self.bezelConstraints) {
        [bezel removeConstraints:self.bezelConstraints];
        self.bezelConstraints = nil;
    }
    
    // Center bezel in container (self), applying the offset if set
    CGPoint offset = self.offset;
    NSMutableArray *centeringConstraints = [NSMutableArray array];
    [centeringConstraints addObject:[NSLayoutConstraint constraintWithItem:bezel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.f constant:offset.x]];
    [centeringConstraints addObject:[NSLayoutConstraint constraintWithItem:bezel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.f constant:offset.y]];
    [self applyPriority:998.f toConstraints:centeringConstraints];
    [self addConstraints:centeringConstraints];
    
    
    // Ensure minimum side margin is kept
    NSMutableArray *sideConstraints = [NSMutableArray array];
    [sideConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(>=margin)-[bezel]-(>=margin)-|" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(bezel)]];
    [sideConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=margin)-[bezel]-(>=margin)-|" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(bezel)]];
    [self applyPriority:999.f toConstraints:sideConstraints];
    [self addConstraints:sideConstraints];
    
    // Minimum bezel size, if set
    CGSize minimumSize = self.minSize;
    if (!CGSizeEqualToSize(minimumSize, CGSizeZero)) {
        NSMutableArray *minSizeConstraints = [NSMutableArray array];
        [minSizeConstraints addObject:[NSLayoutConstraint constraintWithItem:bezel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:minimumSize.width]];
        [minSizeConstraints addObject:[NSLayoutConstraint constraintWithItem:bezel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:minimumSize.height]];
        [self applyPriority:997.f toConstraints:minSizeConstraints];
        [bezelConstraints addObjectsFromArray:minSizeConstraints];
    }
    
   
    
    // Top and bottom spacing
    [topSpacer addConstraint:[NSLayoutConstraint constraintWithItem:topSpacer attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:margin/2.0]];
    [bottomSpacer addConstraint:[NSLayoutConstraint constraintWithItem:bottomSpacer attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:0.0]];
    

    [self addConstraint:[NSLayoutConstraint constraintWithItem:closeButton attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:bezel attribute:NSLayoutAttributeTrailing multiplier:1.f constant:0.f]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:closeButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:bezel attribute:NSLayoutAttributeTop multiplier:1.f constant:-5.f]];
    
    
    
    CGFloat leftCenterX_mp = 0.5f;
    
    
    if (self.left_rightRadio > 0.0) {
        leftCenterX_mp = leftCenterX_mp * self.left_rightRadio;
    }
    
    
    // Layout subviews in bezel
    NSMutableArray *paddingConstraints = [NSMutableArray new];
    [subviews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
        // Center in bezel
        
        
        //  x height width
        if (idx == subviews.count - 6) {
            //horizon Line
            [bezelConstraints addObject:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:bezel attribute:NSLayoutAttributeCenterX multiplier:1.f constant:0.f]];
            
            [view addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:KKKNCAVDefaultLineWidth]];
            [bezelConstraints addObject:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:bezel attribute:NSLayoutAttributeWidth multiplier:1.f constant:0.f]];
            
        } else if (idx == subviews.count - 5) {
            [bezelConstraints addObject:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:bezel attribute:NSLayoutAttributeCenterX multiplier:leftCenterX_mp constant:0.f]];
            [bezelConstraints addObject:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:bezel attribute:NSLayoutAttributeLeading multiplier:1.f constant:0.f]];

           
        } else if (idx == subviews.count - 4)
        {
            
            [view addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:KKKNCAVDefaultLineWidth]];
            [bezelConstraints addObject:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:subviews[idx - 1] attribute:NSLayoutAttributeHeight multiplier:1.f constant:0.5f]];
            
            [bezelConstraints addObject:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:subviews[idx - 1] attribute:NSLayoutAttributeTrailing multiplier:1.f constant:0.5f]];
            [bezelConstraints addObject:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:subviews[idx + 1] attribute:NSLayoutAttributeLeading multiplier:1.f constant:0.f]];

            
        } else if (idx == subviews.count - 3)
        {
            [bezelConstraints addObject:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:bezel attribute:NSLayoutAttributeTrailing multiplier:1.f constant:0.f]];
            
            
        }
        else if (idx == subviews.count - 2)
        {
            [bezelConstraints addObject:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:bezel attribute:NSLayoutAttributeLeading multiplier:1.f constant:0.f]];
            [bezelConstraints addObject:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:bezel attribute:NSLayoutAttributeTrailing multiplier:1.f constant:0.f]];
            
        }
        else
        {
            [bezelConstraints addObject:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:bezel attribute:NSLayoutAttributeCenterX multiplier:1.f constant:0.f]];
            
            // Ensure the minimum edge margin is kept
            [bezelConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(>=margin)-[view]-(>=margin)-|" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(view)]];
        }
        
        
       
        // Element spacing
        if (idx == 0) {
            // First, ensure spacing to bezel edge
            [bezelConstraints addObject:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:bezel attribute:NSLayoutAttributeTop multiplier:1.f constant:0.f]];
        } else if (idx == subviews.count - 1) {
            // Last, ensure spacing to bezel edge
            [bezelConstraints addObject:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:bezel attribute:NSLayoutAttributeBottom multiplier:1.f constant:0.f]];
        }
        
        //Atttri_top
        if (idx > 0 && idx != subviews.count - 3 && idx != subviews.count - 4 && idx != subviews.count - 5 && idx != subviews.count - 2) { //除去topSpacer和rightButtonView,leftbuttonView,centerButton,verline
            // Has previous
            NSLayoutConstraint *padding = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:subviews[idx - 1] attribute:NSLayoutAttributeBottom multiplier:1.f constant:0.f];
            [bezelConstraints addObject:padding];
            [paddingConstraints addObject:padding];
        } else if(idx == subviews.count - 3 || idx == subviews.count - 4 || idx == subviews.count - 5 ){
            // rightButtonView,leftbuttonView,centerButton,verline
            // Has previous
            NSLayoutConstraint *padding = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:subviews[subviews.count - 6] attribute:NSLayoutAttributeBottom multiplier:1.f constant:0.f];
            [bezelConstraints addObject:padding];
        } else if (idx == subviews.count - 2)
        {
            NSLayoutConstraint *padding = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:subviews[idx - 1] attribute:NSLayoutAttributeBottom multiplier:1.f constant:0.f];
            [bezelConstraints addObject:padding];
        }
    }];

    [bezel addConstraints:bezelConstraints];
    self.bezelConstraints = bezelConstraints;
    
    self.paddingConstraints = [paddingConstraints copy];
    [self updatePaddingConstraints];
    
    [super updateConstraints];
}

- (void)updatePaddingConstraints {
    // Set padding dynamically, depending on whether the view is visible or not
    __block BOOL hasVisibleAncestors = NO;
    [self.paddingConstraints enumerateObjectsUsingBlock:^(NSLayoutConstraint *padding, NSUInteger idx, BOOL *stop) {
        UIView *firstView = (UIView *)padding.firstItem;
        UIView *secondView = (UIView *)padding.secondItem;
        BOOL firstVisible = !firstView.hidden && !CGSizeEqualToSize(firstView.intrinsicContentSize, CGSizeZero);
        BOOL secondVisible = !secondView.hidden && !CGSizeEqualToSize(secondView.intrinsicContentSize, CGSizeZero);
        // Set if both views are visible or if there's a visible view on top that doesn't have padding
        // added relative to the current view yet
        padding.constant = (firstVisible && (secondVisible || hasVisibleAncestors)) ? self.margin/2.0 : 0.f;//KKKNCAVDefaultPadding
        hasVisibleAncestors |= secondVisible;
    }];
}


- (void)applyPriority:(UILayoutPriority)priority toConstraints:(NSArray *)constraints {
    for (NSLayoutConstraint *constraint in constraints) {
        constraint.priority = priority;
    }
}


#pragma mark - Show & hide

- (void)showAnimated:(BOOL)animated {
    KKKNCAVMainThreadAssert();
    [self.minShowTimer invalidate];
    self.useAnimation = animated;
    self.finished = NO;
    // If the grace time is set, postpone the HUD display
    if (self.graceTime > 0.0) {
        NSTimer *timer = [NSTimer timerWithTimeInterval:self.graceTime target:self selector:@selector(handleGraceTimer:) userInfo:nil repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        self.graceTimer = timer;
    }
    // ... otherwise show the HUD immediately
    else {
        [self showUsingAnimation:self.useAnimation];
    }
    
    
}

- (void)hideAnimated:(BOOL)animated {
    KKKNCAVMainThreadAssert();
    [self.graceTimer invalidate];
    self.useAnimation = animated;
    self.finished = YES;
    // If the minShow time is set, calculate how long the HUD was shown,
    // and postpone the hiding operation if necessary
    if (self.minShowTime > 0.0 && self.showStarted) {
        NSTimeInterval interv = [[NSDate date] timeIntervalSinceDate:self.showStarted];
        if (interv < self.minShowTime) {
            NSTimer *timer = [NSTimer timerWithTimeInterval:(self.minShowTime - interv) target:self selector:@selector(handleMinShowTimer:) userInfo:nil repeats:NO];
            [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
            self.minShowTimer = timer;
            return;
        }
    }
    // ... otherwise hide the HUD immediately
    [self hideUsingAnimation:self.useAnimation];
}

- (void)hideAnimated:(BOOL)animated afterDelay:(NSTimeInterval)delay {
    NSTimer *timer = [NSTimer timerWithTimeInterval:delay target:self selector:@selector(handleHideTimer:) userInfo:@(animated) repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    self.hideDelayTimer = timer;
}

- (void)showUsingAnimation:(BOOL)animated {
    // Cancel any previous animations
    [self.bezelView.layer removeAllAnimations];
    [self.backgroundView.layer removeAllAnimations];
    
    // Cancel any scheduled hideDelayed: calls
    [self.hideDelayTimer invalidate];
    
    self.showStarted = [NSDate date];
    self.alpha = 1.f;
    
    
    if (animated) {
        [self animateIn:YES withType:self.animationType completion:NULL];
    } else {

        self.backgroundView.alpha = 1.f;
    }
}

- (void)hideUsingAnimation:(BOOL)animated {
    if (animated && self.showStarted) {
        self.showStarted = nil;
        [self animateIn:NO withType:self.animationType completion:^(BOOL finished) {
            [self done];
        }];
    } else {
        self.showStarted = nil;
        self.bezelView.alpha = 0.f;
        self.backgroundView.alpha = 1.f;
        [self done];
    }
}


- (void)animateIn:(BOOL)animatingIn withType:(KKKCAVAnimation)type completion:(void(^)(BOOL finished))completion {
    
    // Automatically determine the correct zoom animation type
    if (type == KKKCAVAnimationZoom) {
        type = animatingIn ? KKKCAVAnimationZoomIn : KKKCAVAnimationZoomOut;
    }
    
    CGAffineTransform small = CGAffineTransformMakeScale(0.1f, 0.1f);
    CGAffineTransform large = CGAffineTransformMakeScale(1.5f, 1.5f);
    
    // Set starting state
    UIView *bezelView = self.bezelView;
    UIButton *closeButton = self.closeButton;
    if (animatingIn && bezelView.alpha == 0.f && type == KKKCAVAnimationZoomIn) {
        bezelView.transform = small;
        closeButton.transform = small;
    } else if (animatingIn && bezelView.alpha == 0.f && type == KKKCAVAnimationZoomOut) {
        bezelView.transform = large;
        closeButton.transform = large;
    }
    
    // Perform animations
    dispatch_block_t animations = ^{
        if (animatingIn) {
            bezelView.transform = CGAffineTransformIdentity;
            closeButton.transform = CGAffineTransformIdentity;
        } else if (!animatingIn && type == KKKCAVAnimationZoomIn) {
            bezelView.transform = large;
            closeButton.transform = large;
        } else if (!animatingIn && type == KKKCAVAnimationZoomOut) {
            bezelView.transform = small;
            closeButton.transform = small;
        }

        bezelView.alpha = animatingIn ? 1.f : 0.f;
        closeButton.alpha = animatingIn ? 1.f : 0.f;
        self.backgroundView.alpha = animatingIn ? 1.f : 0.f;
    };
    
    // Spring animations are nicer, but only available on iOS 7+
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000 || TARGET_OS_TV
    if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_7_0) {
        [UIView animateWithDuration:0.3 delay:0. usingSpringWithDamping:1.f initialSpringVelocity:0.f options:UIViewAnimationOptionBeginFromCurrentState animations:animations completion:completion];
        return;
    }
#endif
    [UIView animateWithDuration:0.3 delay:0. options:UIViewAnimationOptionBeginFromCurrentState animations:animations completion:completion];
}

- (void)done {
    // Cancel any scheduled hideDelayed: calls
    [self.hideDelayTimer invalidate];

    
    if (self.hasFinished) {
        self.alpha = 0.0f;
        if (self.removeFromSuperViewOnHide) {
            [self removeFromSuperview];
        }
    }
    KKKCAVCompletionBlock completionBlock = self.completionBlock;
    if (completionBlock) {
        completionBlock();
    }
}

#pragma mark - Timer callbacks

- (void)handleGraceTimer:(NSTimer *)theTimer {
    // Show the HUD only if the task is still running
    if (!self.hasFinished) {
        [self showUsingAnimation:self.useAnimation];
    }
}

- (void)handleMinShowTimer:(NSTimer *)theTimer {
    [self hideUsingAnimation:self.useAnimation];
}

- (void)handleHideTimer:(NSTimer *)timer {
    [self hideAnimated:[timer.userInfo boolValue]];
}



#pragma mark - Properties

- (void)setMode:(KKKCAVMode)mode {
    if (mode != _mode) {
        _mode = mode;
        [self updateViewsForColor:self.contentColor];
    }
}



- (void)setOffset:(CGPoint)offset {
    if (!CGPointEqualToPoint(offset, _offset)) {
        _offset = offset;
       [self setNeedsUpdateConstraints];
    }
}

- (void)setMargin:(CGFloat)margin {
    if (margin != _margin) {
        _margin = margin;
        [self setNeedsUpdateConstraints];
    }
}

- (void)setMinSize:(CGSize)minSize {
    if (!CGSizeEqualToSize(minSize, _minSize)) {
        _minSize = minSize;
        [self setNeedsUpdateConstraints];
    }
}



- (void)setLeft_rightRadio:(CGFloat)left_rightRadio
{
    if (left_rightRadio != _left_rightRadio) {
        _left_rightRadio = left_rightRadio;
        [self setNeedsUpdateConstraints];
    }
}





- (void)setContentColor:(UIColor *)contentColor {
    if (contentColor != _contentColor && ![contentColor isEqual:_contentColor]) {
        _contentColor = contentColor;
        [self updateViewsForColor:contentColor];
    }
}

- (void)setDefaultMotionEffectsEnabled:(BOOL)defaultMotionEffectsEnabled {
    if (defaultMotionEffectsEnabled != _defaultMotionEffectsEnabled) {
        _defaultMotionEffectsEnabled = defaultMotionEffectsEnabled;
        [self updateBezelMotionEffects];
    }
}



@end




@interface KKKCAVBackgroundView ()

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000 || TARGET_OS_TV
@property UIVisualEffectView *effectView;
#endif
#if !TARGET_OS_TV
@property UIToolbar *toolbar;
#endif

@end

@implementation KKKCAVBackgroundView

#pragma mark - Lifecycle

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_7_0) {
            _style = KKKCAVBackgroundStyleBlur;
            if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_8_0) {
                _color = [UIColor colorWithWhite:0.8f alpha:0.6f];
            } else {
                _color = [UIColor colorWithWhite:0.95f alpha:0.6f];
            }
        } else {
            _style = KKKCAVBackgroundStyleSolidColor;
            _color = [[UIColor blackColor] colorWithAlphaComponent:0.8];
        }
        
        self.clipsToBounds = YES;
        
        
        [self updateForBackgroundStyle];
    }
    return self;
}

#pragma mark - Layout

- (CGSize)intrinsicContentSize {
    // Smallest size possible. Content pushes against this.
    
    return CGSizeZero;
}



#pragma mark - Appearance

- (void)setStyle:(KKKCAVBackgroundStyle)style {
    if (style == KKKCAVBackgroundStyleBlur && kCFCoreFoundationVersionNumber < kCFCoreFoundationVersionNumber_iOS_7_0) {
        style = KKKCAVBackgroundStyleSolidColor;
    }
    if (_style != style) {
        _style = style;
        [self updateForBackgroundStyle];
    }
}

- (void)setColor:(UIColor *)color {
    NSAssert(color, @"The color should not be nil.");
    if (color != _color && ![color isEqual:_color]) {
        _color = color;
        [self updateViewsForColor:color];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Views

- (void)updateForBackgroundStyle {
    KKKCAVBackgroundStyle style = self.style;
    if (style == KKKCAVBackgroundStyleBlur) {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000 || TARGET_OS_TV
        if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_8_0) {
            UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
            UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
            [self addSubview:effectView];
            effectView.frame = self.bounds;
            effectView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
            self.backgroundColor = self.color;
            self.layer.allowsGroupOpacity = NO;
            self.effectView = effectView;
        } else {
#endif
#if !TARGET_OS_TV
            UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectInset(self.bounds, -100.f, -100.f)];
            toolbar.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
            toolbar.barTintColor = self.color;
            toolbar.translucent = YES;
            [self addSubview:toolbar];
            self.toolbar = toolbar;
#endif
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000 || TARGET_OS_TV
        }
#endif
    } else {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000 || TARGET_OS_TV
        if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_8_0) {
            [self.effectView removeFromSuperview];
            self.effectView = nil;
        } else {
#endif
#if !TARGET_OS_TV
            [self.toolbar removeFromSuperview];
            self.toolbar = nil;
#endif
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000 || TARGET_OS_TV
        }
#endif
        self.backgroundColor = self.color;
    }
}

- (void)updateViewsForColor:(UIColor *)color {
    if (self.style == KKKCAVBackgroundStyleBlur) {
        if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_8_0) {
            self.backgroundColor = self.color;
        } else {
#if !TARGET_OS_TV
            self.toolbar.barTintColor = color;
#endif
        }
    } else {
        self.backgroundColor = self.color;
    }
}


- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    if (view == nil) {
        for (UIView *subView in self.subviews) {
            CGPoint p = [subView convertPoint:point fromView:self];
            if (CGRectContainsPoint(subView.bounds, p)) {
                view = subView;
            }
        }
    }
    return view;
}

@end


@implementation KKKNCAVRoundedButton


- (CGSize)intrinsicContentSize {
    // Only show if we have associated control events
    if (self.allControlEvents == 0) return CGSizeZero;
    CGSize size = [super intrinsicContentSize];
    // Add some side padding
    size.width -= 10.f;
    size.height -= 10.f;
    return size;
}


@end

@implementation KKKNCAVButton
#pragma mark - Lifecycle

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        /* 边框
         CALayer *layer = self.layer;
         layer.borderWidth = 1.f;
         */
    }
    return self;
}

#pragma mark - Layout

- (void)layoutSubviews {
    [super layoutSubviews];
    /* Fully rounded corners
     CGFloat height = CGRectGetHeight(self.bounds);
     self.layer.cornerRadius = ceil(height / 2.f);
     */
}

- (CGSize)intrinsicContentSize {
    // Only show if we have associated control events
    if (self.allControlEvents == 0) return CGSizeZero;
    CGSize size = [super intrinsicContentSize];
    size.width += 20.f;
    size.height += 10.f;
    return size;
}

#pragma mark - Color

- (void)setTitleColor:(UIColor *)color forState:(UIControlState)state {
    [super setTitleColor:color forState:state];
    // Update related colors
    [self setHighlighted:self.highlighted];
    
    /* 边框颜色
     self.layer.borderColor = color.CGColor;
     */
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    UIColor *baseColor = [self titleColorForState:UIControlStateSelected];
    self.backgroundColor = highlighted ? [baseColor colorWithAlphaComponent:0.1f] : [UIColor clearColor];
}


@end



@implementation KKKNCAVLabel

#pragma mark - Lifecycle



- (CGSize)intrinsicContentSize {
    
    if (self.text.length == 0) return CGSizeZero;
    CGSize size = [super intrinsicContentSize];
    // Add some side padding
    size.width += 20.f;
    size.height += 20.f;
    return size;
}

@end

@implementation KKKNCAVTextView

- (CGSize)sizeThatFits:(CGSize)size
{
    if (self.text.length == 0) return CGSizeZero;
    CGSize nsize = [super sizeThatFits:size];
    
    return nsize;
    
}

@end




