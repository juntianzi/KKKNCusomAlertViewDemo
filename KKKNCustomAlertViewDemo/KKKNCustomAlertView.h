//
//  KKKNCustomAlertView.h
//  KKKWANSDK2017
//
//  Created by caf on 2016/12/27.
//  Copyright © 2016年 kkkwan. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, KKKCAVMode) {
    /// UIActivityIndicatorView.
    KKKCAVModeSimple,
    /// A round, pie-chart like, progress view.
    KKKCAVModeClose
};

typedef NS_ENUM(NSInteger, KKKCAVAnimation) {
    /// Opacity animation
    KKKCAVAnimationFade,
    /// Opacity + scale animation (zoom in when appearing zoom out when disappearing)
    KKKCAVAnimationZoom,
    /// Opacity + scale animation (zoom out style)
    KKKCAVAnimationZoomOut,
    /// Opacity + scale animation (zoom in style)
    KKKCAVAnimationZoomIn
};
typedef NS_ENUM(NSInteger, KKKCAVBackgroundStyle) {
    /// Solid color background
    KKKCAVBackgroundStyleSolidColor,
    /// UIVisualEffectView or UIToolbar.layer background view
    KKKCAVBackgroundStyleBlur
};

typedef void (^KKKCAVCompletionBlock)();
NS_ASSUME_NONNULL_BEGIN
@interface KKKCAVBackgroundView : UIView

@property (nonatomic) KKKCAVBackgroundStyle style;


@property (nonatomic, strong) UIColor *color;
@end



@interface KKKNCustomAlertView : UIView
+ (instancetype)showAlertAddedTo:(UIView *)view animated:(BOOL)animated;

+ (BOOL)hideAlertForView:(UIView *)view animated:(BOOL)animated;

@property (copy, nonatomic) KKKCAVCompletionBlock completionBlock;

@property (assign, nonatomic) NSTimeInterval graceTime;
@property (assign, nonatomic) NSTimeInterval minShowTime;
@property (assign, nonatomic) BOOL removeFromSuperViewOnHide;
@property (nonatomic)KKKCAVMode mode;
@property (nonatomic)KKKCAVAnimation animationType  UI_APPEARANCE_SELECTOR;
@property (assign, nonatomic) CGPoint offset UI_APPEARANCE_SELECTOR;
@property (nonatomic)CGFloat margin  UI_APPEARANCE_SELECTOR;
@property (nonatomic)CGFloat left_rightRadio UI_APPEARANCE_SELECTOR;
@property (assign, nonatomic) CGSize minSize UI_APPEARANCE_SELECTOR;
@property (assign, nonatomic, getter=areDefaultMotionEffectsEnabled) BOOL defaultMotionEffectsEnabled UI_APPEARANCE_SELECTOR;
@property (strong, nonatomic, nullable) UIColor *contentColor UI_APPEARANCE_SELECTOR;

@property (nonatomic, strong, readonly) KKKCAVBackgroundView *backgroundView;
@property (nonatomic, strong, readonly) KKKCAVBackgroundView *bezelView;

@property (nonatomic, strong, readonly) UILabel *titleLabel;
@property (nonatomic, strong, readonly) UITextView *centerTextView;

@property (nonatomic, strong, readonly) UIImageView *detailTextLabelBackGround;
@property (nonatomic, strong, readonly) UILabel *detailTextLabel;

@property (nonatomic, strong, readonly) UIView *bottomSeperatorLine;
@property (nonatomic, strong, readonly) UIButton *closeButton;
@property (nonatomic, strong, readonly) UIButton *leftButton;
@property (nonatomic, strong, readonly) UIButton *rightButton;
@property (nonatomic, strong, readonly) UIButton *centerButton;
@end
NS_ASSUME_NONNULL_END
