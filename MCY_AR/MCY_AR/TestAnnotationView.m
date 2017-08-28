//
//  TestAnnotationView.m
//  MCY_AR
//
//  Created by machunyan on 2017/7/21.
//  Copyright © 2017年 machunyan. All rights reserved.
//

#import "TestAnnotationView.h"

@interface TestAnnotationView ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *infoButton;
@property (nonatomic) CGRect arFrame; // Just for test stacking

@end

@implementation TestAnnotationView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

#pragma mark - override

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self layoutUi];
}

- (void)bindUi
{
    if (self.annotaion && self.annotaion.title) {
        MCYARAnnotation *annotation = self.annotaion;
        NSString *title = self.annotaion.title;
        NSString *distance = annotation.distanceFromUser > 1000 ? [NSString stringWithFormat:@"%.1fkm", annotation.distanceFromUser / 1000] : [NSString stringWithFormat:@"%.0fm", annotation.distanceFromUser];
        NSString *text = [NSString stringWithFormat:@"%@\nAZ: %.0f°\nDST: %@", title, annotation.azimuth, distance];
        
        self.titleLabel.text = text;
    }
}

- (void)initialize
{
    [super initialize];
    [self loadUi];
}

- (void)loadUi
{
    [self.titleLabel removeFromSuperview];
    [self addSubview:self.titleLabel];
    
    [self.infoButton removeFromSuperview];
    [self addSubview:self.infoButton];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture)];
    [self addGestureRecognizer:tapGesture];
    
    self.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.5];
    self.layer.cornerRadius = 5;
    
    if (self.annotaion != nil) {
        [self bindUi];
    }
}

- (void)layoutUi
{
    CGFloat buttonWidth = 40;
    CGFloat buttonHeight = 40;
    
    self.titleLabel.frame = CGRectMake(10, 0, self.frame.size.width - buttonWidth - 5, self.frame.size.height);
    self.infoButton.frame = CGRectMake(self.frame.size.width - buttonWidth, self.frame.size.height / 2 - buttonHeight / 2, buttonWidth, buttonHeight);
}

- (void)tapGesture
{
    if (self.annotaion != nil) {
        MCYARAnnotation *annotation = self.annotaion;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:annotation.title message:@"Tapped" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}

#pragma mark - Setter

- (UILabel*)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:10];
        _titleLabel.numberOfLines = 0;
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = [UIColor whiteColor];
    }
    
    return _titleLabel;
}

- (UIButton*)infoButton
{
    if (!_infoButton) {
        _infoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_infoButton setUserInteractionEnabled:false];
    }
    
    return _infoButton;
}

@end
