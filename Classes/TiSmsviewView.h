//
//  PecTfTextField.h
//  textfield
//
//  Created by Pedro Enrique on 7/3/11.
//  Copyright 2011 Appcelerator. All rights reserved.
//

#import "TiUIView.h"
#import "PESMSTextArea.h"
#import "PESMSScrollView.h"


@interface TiSmsviewView : TiUIView<PESMSTextAreaDelegate, RefreshDelegate> {
	PESMSTextArea *textArea;
	PESMSScrollView *scrollView;
	BOOL deallocOnce;
	NSString *value;
	UITapGestureRecognizer *clickGestureRecognizer;
}

@property(nonatomic, retain)NSString *value;
@property(nonatomic, retain)NSString *folder;
@property(nonatomic, retain)NSString *buttonTitle;
@property(nonatomic)BOOL firstTime;
@property(nonatomic)UIReturnKeyType returnType;
@property(nonatomic, retain)WebFont* font;
@property(nonatomic, retain)TiColor *textColor;
@property(nonatomic)UITextAlignment textAlignment;
@property(nonatomic)BOOL autocorrect;
@property(nonatomic)BOOL beditable;
@property(nonatomic)BOOL hasCam;
@property(nonatomic)BOOL shouldAnimate;
@property(nonatomic)BOOL sendDisabled;
@property(nonatomic)BOOL camDisabled;
@property(nonatomic)BOOL hasTabbar;
@property(nonatomic)float bottomOfWin;


@property(nonatomic)int textAreaHeight; // なぜか [self textArea].frame.size.height が 0 なので・・


// prepend methods
-(void)preSendImageView:(TiUIView *)view;
-(void)preRecieveImageView:(TiUIView *)view;
-(void)preSendImage:(UIImage *)image;
-(void)preRecieveImage:(UIImage *)image;
-(void)preSendMessage:(NSString *)msg;
-(void)preRecieveMessage:(NSString *)msg;

-(void)sendImageView:(TiUIView *)view;
-(void)recieveImageView:(TiUIView *)view;
-(void)sendImage:(UIImage *)image;
-(void)recieveImage:(UIImage *)image;
-(void)sendMessage:(NSString *)msg;
-(void)recieveMessage:(NSString *)msg;
-(void)addLabel:(NSString *)msg at:(NSString *)pos;
-(void)preAddLabel:(NSString *)msg at:(NSString *)pos;
-(void)_blur;
-(void)_focus;
-(void)empty;
-(NSArray *)getMessages;
-(CGPoint) contentOffset;
-(CGSize) contentSize;
-(void)setRightIcon:(UIImage *)val;
-(void)setLeftIcon:(UIImage *)val;
-(void)scrollToBottom;

-(void)emptyTextArea;

// save init text origin y
@property(nonatomic)int initY;
@property(nonatomic)int scrollHeight;

@end
