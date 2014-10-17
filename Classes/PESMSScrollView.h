//
//  ScrollView.h
//  chat
//
//  Created by Pedro Enrique on 8/12/11.
//  Copyright 2011 Appcelerator. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PESMSLabel.h"
#import "PESMSTextLabel.h"
#import "TiUIView.h"
#import "EGORefreshTableHeaderView.h"
#import "EGORefreshTableFooterView.h"

#define RIGHT_ICON_TAG 998
#define LEFT_ICON_TAG 999

@protocol RefreshDelegate
-(void)prevLoad;
-(void)nextLoad;
@end

@interface PESMSScrollView : UIScrollView<UIScrollViewDelegate, EGORefreshTableHeaderDelegate, EGORefreshTableFooterDelegate> {
	UILabel *sentLabel;
	UILabel *recieveLabel;
	PESMSLabel *label;
	PESMSTextLabel *textLabel;
	NSMutableArray *allMessages;
	NSMutableDictionary *tempDict;
    UIImage *leftIcon;
    UIImage *rightIcon;
    id<RefreshDelegate> refreshDelegate;
    EGORefreshTableHeaderView *header;
    EGORefreshTableFooterView *footer;
}

@property(nonatomic) CGRect labelsPosition;
@property(nonatomic, retain)NSString *sColor;
@property(nonatomic, retain)NSString *rColor;
@property(nonatomic, retain)NSString *selectedColor;
@property(nonatomic, retain)NSString *folder;
@property(nonatomic, retain)NSMutableArray *allMessages;
@property(nonatomic, retain)NSMutableDictionary *tempDict;
@property(nonatomic, retain)UIImage *leftIcon;
@property(nonatomic, retain)UIImage *rightIcon;
@property(nonatomic, retain)id<RefreshDelegate> refreshDelegate;
@property(nonatomic)BOOL animated;
@property(nonatomic)int numberOfMessage;

// prepend methods
-(void)preSendMessage:(NSString *)text;
-(void)preRecieveMessage:(NSString *)text;
-(void)preSendImageView:(TiUIView *)view;
-(void)preRecieveImageView:(TiUIView *)view;
-(void)preSendImage:(UIImage *)image;
-(void)preRecieveImage:(UIImage *)image;

-(void)sendMessage:(NSString *)text;
-(void)recieveMessage:(NSString *)text;
-(void)addLabel:(NSString *)msg;
-(void)addLeftLabel:(NSString *)text;
-(void)addRightLabel:(NSString *)text;
-(void)preAddLabel:(NSString *)msg;
-(void)preAddLeftLabel:(NSString *)text;
-(void)preAddRightLabel:(NSString *)text;
-(void)sendImageView:(TiUIView *)view;
-(void)recieveImageView:(TiUIView *)view;
-(void)sendImage:(UIImage *)image;
-(void)recieveImage:(UIImage *)image;
-(void)reloadContentSize;
-(void)backgroundColor:(UIColor *)col;
-(void)sendColor:(NSString *)col;
-(void)recieveColor:(NSString *)col;
-(void)animate:(BOOL)arg;
-(void)selectedColor:(NSString *)col;
-(void)empty;
-(void)scrollToBottom;

@end
