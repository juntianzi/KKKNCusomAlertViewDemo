//
//  ViewController.m
//  KKKNCustomAlertViewDemo
//
//  Created by caf on 2017/1/4.
//  Copyright © 2017年 kkkwan. All rights reserved.
//

#import "ViewController.h"
#import "KKKNCustomAlertView.h"
@interface KKKCustomView:UIView
@end

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)type:(UIButton *)sender {
    
    KKKNCustomAlertView *customAlertView =  [KKKNCustomAlertView showAlertAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    customAlertView.bezelView.backgroundColor = [UIColor whiteColor];
    customAlertView.bezelView.alpha = 1.0;
    customAlertView.animationType = KKKCAVAnimationZoomOut;
    customAlertView.backgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    
    
    switch (sender.tag) {
        case 1: // simple toast
            customAlertView.detailTextLabel.text = @" textview 动态布局 textview 动态布局 动态布局  动态布局 动态布局";
            customAlertView.margin = 0.f;
            customAlertView.userInteractionEnabled = NO; //下层允许点击
            break;
        case 2: //动态textView
            customAlertView.titleLabel.text = @"大大的标题";
            customAlertView.centerTextView.text = @" textview 动态布局 textview 动态布局 textview 动态布局 textview 动态布局 textview 动态布局 textview 动态布局 textview 动态布局 textview 动态布局 textview 动态布局 ";
            customAlertView.centerTextView.editable = NO;
            customAlertView.userInteractionEnabled = NO; //下层允许点击
            break;
        case 3://动态textView 带按钮
            customAlertView.titleLabel.text = @"大大的标题";
            customAlertView.centerTextView.text = @" textview 动态布局 textview 动态布局 textview 动态布局 textview 动态布局 textview 动态布局 textview 动态布局 textview 动态布局 textview 动态布局 textview 动态布局 textview 动态布局 textview 动态布局 textview 动态布局 textview 动态布局 textview 动态布局 textview 动态布局 textview 动态布局 textview 动态布局 textview 动态布局 textview 动态布局 textview 动态布局 textview 动态布局 textview 动态布局 textview 动态布局 textview 动态布局 textview 动态布局 textview 动态布局 textview 动态布局";
            customAlertView.centerTextView.textColor = [UIColor lightGrayColor];
            customAlertView.centerTextView.editable = NO;
            [customAlertView.centerButton setTitle:@"OK" forState:UIControlStateNormal];
            [customAlertView.centerButton addTarget:self action:@selector(hide:) forControlEvents:UIControlEventTouchUpInside];
            break;
        case 4:// 双按钮 可自定比例
            customAlertView.titleLabel.text = @"大大的标题";
            customAlertView.centerTextView.text = @" textview 动态布局 textview 动态布局 textview 动态布局 textview 动态布局 textview 动态布局 textview 动态布局 textview 动态布局 textview 动态布局 textview 动态布局";
            customAlertView.centerTextView.textColor = [UIColor lightGrayColor];
            customAlertView.centerTextView.editable = NO;
            [customAlertView.leftButton setTitle:@"是嘛" forState:UIControlStateNormal];
            [customAlertView.leftButton addTarget:self action:@selector(hide:) forControlEvents:UIControlEventTouchUpInside];
            
            
            [customAlertView.rightButton setTitle:@"隐藏弹窗" forState:UIControlStateNormal];
            [customAlertView.rightButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
            [customAlertView.rightButton addTarget:self action:@selector(hide:) forControlEvents:UIControlEventTouchUpInside];
            
            customAlertView.left_rightRadio = 0.9;//按钮left 和 右按钮宽度比 默认 1
            break;
        case 5: // 右上角关闭按钮
            customAlertView.titleLabel.text = @"大大的标题";
            customAlertView.centerTextView.text = @"您的兑换码是如下如下如下";
            customAlertView.centerTextView.textColor = [UIColor lightGrayColor];
            customAlertView.centerTextView.editable = NO;
            [customAlertView.leftButton setTitle:@"是嘛" forState:UIControlStateNormal];
            [customAlertView.leftButton addTarget:self action:@selector(hide:) forControlEvents:UIControlEventTouchUpInside];
            
            
            [customAlertView.rightButton setTitle:@"隐藏弹窗" forState:UIControlStateNormal];
            [customAlertView.rightButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
            [customAlertView.rightButton addTarget:self action:@selector(hide:) forControlEvents:UIControlEventTouchUpInside];
            
            customAlertView.detailTextLabel.text = @"XXXXXXXXXXXXXX";
            customAlertView.detailTextLabel.backgroundColor = [UIColor colorWithRed:242/255.0 green:243/255.0 blue:245/255.0 alpha:1];
            
            
            customAlertView.left_rightRadio = 0.9;//按钮left 和 右按钮宽度比 默认 1
            
            [customAlertView.closeButton addTarget:self action:@selector(hide:) forControlEvents:UIControlEventTouchUpInside];//设置关闭按钮
            break;
        case 6: // 固定textView大小，当显示内容太多
            customAlertView.titleLabel.text = @"大大的标题";
            customAlertView.centerTextView.text = @"固定textView大小，当显示内容太多 固定textView大小，当显示内容太多 固定textView大小，当显示内容太多 固定textView大小，当显示内容太多 固定textView大小，当显示内容太多 固定textView大小，当显示内容太多 固定textView大小，当显示内容太多 固定textView大小，当显示内容太多 固定textView大小，当显示内容太多 固定textView大小，当显示内容太多 固定textView大小，当显示内容太多 固定textView大小，当显示内容太多 固定textView大小，当显示内容太多 固定textView大小，当显示内容太多 固定textView大小，当显示内容太多 固定textView大小，当显示内容太多 固定textView大小，当显示内容太多 固定textView大小，当显示内容太多 固定textView大小，当显示内容太多 固定textView大小，当显示内容太多 固定textView大小，当显示内容太多 固定textView大小，当显示内容太多 固定textView大小，当显示内容太多 固定textView大小，当显示内容太多";
            customAlertView.centerTextView.textColor = [UIColor lightGrayColor];
            customAlertView.centerTextView.editable = NO;
            [customAlertView.centerButton setTitle:@"OK" forState:UIControlStateNormal];
            [customAlertView.centerButton addTarget:self action:@selector(hide:) forControlEvents:UIControlEventTouchUpInside];
            
            customAlertView.minSize = CGSizeMake(300, 300);
            break;
            
        default:
            break;
    }
}
- (IBAction)hide:(id)sender {
    [KKKNCustomAlertView hideAlertForView:[UIApplication sharedApplication].keyWindow animated:YES];
    
}

@end


@implementation KKKCustomView



@end
