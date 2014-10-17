//
//  PecTfTextField.m
//  textfield
//
//  Created by Pedro Enrique on 7/3/11.
//  Copyright 2011 Appcelerator. All rights reserved.
//

#import "TiSmsviewView.h"
#import "PESMSIcon.h"
#import "TiBase.h"
#import "TiUtils.h"
#import "TiHost.h"


@implementation TiSmsviewView
@synthesize value;
@synthesize firstTime;
@synthesize returnType;
@synthesize font;
@synthesize textColor;
@synthesize textAlignment;
@synthesize autocorrect;
@synthesize beditable;
@synthesize hasCam;
@synthesize folder;
@synthesize buttonTitle;
@synthesize shouldAnimate;
@synthesize sendDisabled;
@synthesize camDisabled;
@synthesize hasTabbar;
@synthesize bottomOfWin;
@synthesize initY;
@synthesize scrollHeight;

@synthesize textAreaHeight;

-(void)dealloc
{
	RELEASE_TO_NIL(textArea);
	RELEASE_TO_NIL(scrollView);
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
	
	[super dealloc];
}

-(id)init
{
    if(self = [super init])
	{
		self.firstTime = YES;
		self.autocorrect = YES;
		self.beditable = YES;
		self.hasCam = NO;
		self.shouldAnimate = YES;
		self.sendDisabled = NO;
		self.camDisabled = NO;
		self.hasTabbar = NO;
		self.bottomOfWin = 0.0;
        self.initY = -1;
        self.scrollHeight = -1;
	}
	return self;
}

#pragma mark UI Elements

-(PESMSTextArea *)textArea 
{
	if(!textArea){
		textArea = [[PESMSTextArea alloc] initWithFrame:self.frame];
		textArea.delegate = self;
	}
	return textArea;
}

-(PESMSScrollView *)scrollView
{
	if(!scrollView)
	{
		CGFloat h = CGRectGetHeight(self.frame);
		CGRect a = self.frame;
		a.size.height = h - 40;
		a.origin.y = 0;
		scrollView = [[PESMSScrollView alloc] initWithFrame:a];
		clickGestureRecognizer = [[UITapGestureRecognizer alloc]
														  initWithTarget:self action:@selector(handleClick:)];
		clickGestureRecognizer.numberOfTapsRequired = 1; 
		[scrollView addGestureRecognizer:clickGestureRecognizer];
        
        scrollView.refreshDelegate = self;
	}
	return scrollView;
}

#pragma mark Keyboard stuff

-(NSInteger)keyboardHeight:(NSNotification *)val
{
    // get keyboard size and location
	NSDictionary* info = [val userInfo];
	NSValue* aValue = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
	CGSize keyboardSize = [aValue CGRectValue].size;
	int tabHeight = 0;
	if(self.hasTabbar == YES){
		tabHeight = 49;
	}
	
	if ([[UIApplication sharedApplication]statusBarOrientation] == UIDeviceOrientationPortrait ||
		[[UIApplication sharedApplication]statusBarOrientation] == UIDeviceOrientationPortraitUpsideDown)
		self.bottomOfWin = keyboardSize.height - tabHeight;
	 else
		self.bottomOfWin = keyboardSize.width - tabHeight;
		
	return self.bottomOfWin;
}

//Code from Brett Schumann
-(void) keyboardWillShow:(NSNotification *)note{
    
	// get the height since this is the main value that we need.
	NSInteger kbSizeH = [self keyboardHeight:note];
	
	// get a rect for the textView frame
	CGRect containerFrame = [self textArea].frame;
    // iOS5 fix
    if(initY == -1) {
        initY = containerFrame.origin.y;
    } else {
        containerFrame.origin.y = initY;
    }
    
	containerFrame.origin.y -= (kbSizeH + (textAreaHeight * -1)); // placeholder
    //containerFrame.origin.y = [self scrollView].frame.size.height - kbSizeH - textAreaHeight;
    
    NSLog(@"a - b - c = %d", [self scrollView].frame.size.height - kbSizeH - textAreaHeight);
    NSLog(@"  a: [self scrollView].frame.size.height: %d", [self scrollView].frame.size.height);
    NSLog(@"  b: kbSizeH: %d", kbSizeH);
    NSLog(@"  c: textAreaHeight: %d %d", textAreaHeight, self.textAreaHeight);
    
	CGRect scrollViewFrame = [self scrollView].frame;
    // iOS5 fix
    if(self.scrollHeight == -1) {
        self.scrollHeight = scrollViewFrame.size.height;
    } else {
        scrollViewFrame.size.height = self.scrollHeight;
    }
	scrollViewFrame.size.height -= (kbSizeH + (textAreaHeight * -1));
	
	// animations settings
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.25f];
	
	// set views with new info
	[self scrollView].frame = scrollViewFrame;
	[self textArea].frame = containerFrame;
	
	// commit animations
	[UIView commitAnimations];
	[[self scrollView] performSelector:@selector(reloadContentSize) withObject:nil afterDelay:0.2f];
    [[self scrollView] performSelector:@selector(scrollToBottom) withObject:nil afterDelay:0.2f];
}


-(void) keyboardWillHide:(NSNotification *)note{

	// get the height since this is the main value that we need.
	NSInteger kbSizeH = [self keyboardHeight:note];

	// get a rect for the textView frame
	CGRect containerFrame = [self textArea].frame;
	containerFrame.origin.y += kbSizeH;
	CGRect scrollViewFrame = [self scrollView].frame;
    
    NSLog(@"kbSizeH: %d", kbSizeH);
    NSLog(@"textareaHeight: %d", textAreaHeight * -1);
    
	scrollViewFrame.size.height += (kbSizeH + (textAreaHeight * -1));
	
	// animations settings
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.25f];
	
	// set views with new info
	[[self scrollView]setFrame: scrollViewFrame];
	[[self textArea] setFrame: containerFrame];
	
	// commit animations
	[UIView commitAnimations];
    [[self scrollView] reloadContentSize];
	self.bottomOfWin = 0.0;
    self.scrollHeight = -1;
}

// placeholder
-(void)heightOfTextViewDidChange:(float)height
{
    NSLog(@"START heightOfTextViewDidChange");
    
    textAreaHeight += height;
    
    NSLog(@"height: %d  (%d)", textAreaHeight, height);
    
	CGRect scrollViewFrame = [self scrollView].frame;	
	scrollViewFrame.size.height +=height;
	[[self scrollView]setFrame: scrollViewFrame];
	[[self scrollView] reloadContentSize];

    if (height < 0) {
        // animations settings
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:0.25f];

        // placeholder: commitAnimation が必要かもしれない
        [UIView commitAnimations];
        [[self scrollView] performSelector:@selector(scrollToBottom) withObject:nil afterDelay:0.2f];
    }
}

#pragma mark methods to be used in Javascript

-(void)_blur
{
	[[[self textArea] textView] performSelectorOnMainThread:@selector(resignFirstResponder) withObject:nil waitUntilDone:YES];
}
-(void)_focus
{
	[[[self textArea] textView] performSelectorOnMainThread:@selector(becomeFirstResponder) withObject:nil waitUntilDone:YES];
}

-(void)sendImage:(UIImage *)image
{
	ENSURE_UI_THREAD(sendImage, image);
	[[self scrollView] sendImage:image];
	[[self scrollView] reloadContentSize];
}
-(void)recieveImage:(UIImage *)image
{
	ENSURE_UI_THREAD(recieveImage, image);
	[[self scrollView] recieveImage:image];
	[[self scrollView] reloadContentSize];
}

-(void)sendImageView:(TiUIView *)view
{
	ENSURE_UI_THREAD(sendImageView, view);
	[[self scrollView] sendImageView:view];
	[[self scrollView] reloadContentSize];
}
-(void)recieveImageView:(TiUIView *)view
{
	ENSURE_UI_THREAD(recieveImageView, view);
	[[self scrollView] recieveImageView:view];
	[[self scrollView] reloadContentSize];
}

-(void)sendMessage:(NSString *)msg
{
	ENSURE_UI_THREAD(sendMessage,msg);
	if([msg isEqualToString:@""])
		return;
	[[self scrollView] sendMessage:msg];
	[[self scrollView] reloadContentSize];
}

-(void)recieveMessage:(NSString *)msg
{
	ENSURE_UI_THREAD(recieveMessage, msg);
	if([msg isEqualToString:@""])
		return;
	[[self scrollView] recieveMessage:msg];
	[[self scrollView] reloadContentSize];
}

// prepend methods
-(void)preSendImage:(UIImage *)image
{
	ENSURE_UI_THREAD(preSendImage, image);
	[[self scrollView] preSendImage:image];
	[[self scrollView] reloadContentSize];
}
-(void)preRecieveImage:(UIImage *)image
{
	ENSURE_UI_THREAD(preRecieveImage, image);
	[[self scrollView] preRecieveImage:image];
	[[self scrollView] reloadContentSize];
}

-(void)preSendImageView:(TiUIView *)view
{
	ENSURE_UI_THREAD(preSendImageView, view);
	[[self scrollView] preSendImageView:view];
	[[self scrollView] reloadContentSize];
}
-(void)preRecieveImageView:(TiUIView *)view
{
	ENSURE_UI_THREAD(preRecieveImageView, view);
	[[self scrollView] preRecieveImageView:view];
	[[self scrollView] reloadContentSize];
}

-(void)preSendMessage:(NSString *)msg
{
	ENSURE_UI_THREAD(preSendMessage,msg);
	if([msg isEqualToString:@""])
		return;
	[[self scrollView] preSendMessage:msg];
	[[self scrollView] reloadContentSize];
}

-(void)preRecieveMessage:(NSString *)msg
{
	ENSURE_UI_THREAD(preRecieveMessage, msg);
	if([msg isEqualToString:@""])
		return;
	[[self scrollView] preRecieveMessage:msg];
	[[self scrollView] reloadContentSize];
}

-(void)addLabel:(NSString *)msg at:(NSString *)pos
{
	ENSURE_UI_THREAD(addLabel,msg);
	if([msg isEqualToString:@""])
		return;
	[[self scrollView] animate:NO];	
	if([@"LEFT" isEqualToString:[pos uppercaseString]]) {
        [[self scrollView] addLeftLabel:msg];
    } else if([@"RIGHT" isEqualToString:[pos uppercaseString]]) {
        [[self scrollView] addRightLabel:msg];
    } else {
        [[self scrollView] addLabel:msg];
    }
	[[self scrollView] reloadContentSize];
	[[self scrollView] animate:self.shouldAnimate];	
}

-(void)preAddLabel:(NSString *)msg at:(NSString *)pos
{
	ENSURE_UI_THREAD(preAddLabel,msg);
	if([msg isEqualToString:@""])
		return;
	[[self scrollView] animate:NO];
	if([@"LEFT" isEqualToString:[pos uppercaseString]]) {
        [[self scrollView] preAddLeftLabel:msg];
    } else if([@"RIGHT" isEqualToString:[pos uppercaseString]]) {
        [[self scrollView] preAddRightLabel:msg];
    } else {
        [[self scrollView] preAddLabel:msg];
    }
	[[self scrollView] reloadContentSize];
	[[self scrollView] animate:self.shouldAnimate];
}

-(void)empty
{
	[[self scrollView] empty];
}

-(void)emptyTextArea {
    [[self textArea] emptyTextView];
}

-(NSArray *)getMessages
{
	return [[self scrollView] allMessages];
}

#pragma mark Event listeners

-(void)textViewCamButtonPressed:(NSString *)text
{
	NSMutableDictionary *tiEvent = [NSMutableDictionary dictionary];
	[tiEvent setObject:text forKey:@"value"];
	[self.proxy fireEvent:@"camButtonClicked" withObject:tiEvent];
}

-(void)textViewSendButtonPressed:(NSString *)text
{
	NSMutableDictionary *tiEvent = [NSMutableDictionary dictionary];
	[tiEvent setObject:text forKey:@"value"];
	[self.proxy fireEvent:@"buttonClicked" withObject:tiEvent];
	[[self scrollView] reloadContentSize];
}
-(void)textViewTextChange:(NSString *)text
{
	NSMutableDictionary *tiEvent = [NSMutableDictionary dictionary];
	[tiEvent setObject:text forKey:@"value"];
	[self.proxy fireEvent:@"change" withObject:tiEvent];
	
	self.value = text;
}


-(void)handleClick:(UITapGestureRecognizer*)recognizer
{
	NSMutableDictionary *tiEvent = [NSMutableDictionary dictionary];

	id view = recognizer.view;
	CGPoint loc = [recognizer locationInView:view];
	id subview = [view hitTest:loc withEvent:nil];
	NSString *where;
	if([subview isKindOfClass: [PESMSLabel class]])
	{
		PESMSLabel * a = subview;
		where = @"message";
		if(a.isText)
			[tiEvent setObject:a.textValue forKey:@"text"];
		if(a.isImage)
		{
			TiBlob *blob = [[[TiBlob alloc] initWithImage:a.imageValue] autorelease];
			[tiEvent setObject:blob forKey:@"image"];

		}
		if(a.isView)
			[tiEvent setObject:a.prox forKey:@"view"];
		[tiEvent setObject:[NSString stringWithFormat:@"%i",a.index_] forKey:@"index"];
	} else if([subview isKindOfClass:[PESMSIcon class]]) {
        UIButton* i = subview;
        NSLog(@"%d", i.tag);
        if(i.tag == RIGHT_ICON_TAG) {
            where = @"rightIcon";
            [self.proxy fireEvent:@"rightIconClick"];
        } else if(i.tag == LEFT_ICON_TAG) {
            where = @"leftIcon";
            [self.proxy fireEvent:@"leftIconClick"];
        }
    } else {
		where = @"scrollView";
		[tiEvent setObject:@"scrollView" forKey:@"scrollView"];
	}
	[tiEvent setObject:where forKey:@"where"];
	[self.proxy fireEvent:@"click" withObject:tiEvent];
	[self.proxy fireEvent:@"messageClicked" withObject:tiEvent];
	
}


-(void)label:(NSSet *)touches withEvent:(UIEvent *)event :(UIImage *)image :(NSString *)text :(TiProxy *)view
{
	
	NSMutableDictionary *tiEvent = [NSMutableDictionary dictionary];
	if(text)
		[tiEvent setObject:text forKey:@"text"];
	if(image)
	{
		TiBlob *blob = [[[TiBlob alloc] initWithImage:image] autorelease];
		[tiEvent setObject:blob forKey:@"image"];
	}
	if(view)
	{
		[tiEvent setObject:view forKey:@"view"];
	}
	[self.proxy fireEvent:@"messageClicked" withObject:tiEvent];
}

-(void)changeHeightOfScrollView
{
	// Empty for now, we don't need this, it is completely useless for the JS app
}

#pragma mark Titanium's resize/init function

-(void)frameSizeChanged:(CGRect)frame bounds:(CGRect)bounds
{
    [TiUtils setView:self positionRect:self.superview.bounds];

    CGRect a = self.frame;
    CGFloat h = CGRectGetHeight(self.frame);
	float meh = h - 40;
    a.size.height = meh;
	
	if(self.firstTime == YES)
	{
		self.firstTime = NO;
		[self addSubview: [self scrollView]];
		[self addSubview: [self textArea]];
		if(![self.proxy valueForUndefinedKey:@"backgroundColor"])
		   self.backgroundColor = [[TiUtils colorValue:(id)@"#dae1eb"] _color];
		
		if(self.returnType)
			[[[self textArea] textView] setReturnKeyType:self.returnType];
		if(self.font)
			[[[self textArea] textView] setFont:[self.font font]];
		if(self.textColor)
			[[[self textArea] textView] setTextColor:[self.textColor _color]];
		if(self.textAlignment)
			[[[self textArea] textView] setTextAlignment:self.textAlignment];
		if(self.value)
			[[[self textArea] textView]setText:self.value];
		if(self.folder)
		{
			[[self textArea] setFolder:self.folder];
			[[self scrollView] setFolder:self.folder];
		}
		if(self.buttonTitle)
			[[self textArea] buttonTitle:self.buttonTitle];
		[[self textArea] setCamera:self.hasCam];
		[[[self textArea] textView] setEditable:self.beditable];
		[[[self textArea] textView] setAutocorrectionType:self.autocorrect ? UITextAutocorrectionTypeYes : UITextAutocorrectionTypeNo];
		[[[self textArea] textView] setDataDetectorTypes:UIDataDetectorTypeAll];
		if(self.sendDisabled)
			[[self textArea] disableDoneButon:self.sendDisabled];
		if(self.camDisabled)	
			[[self textArea] disableCamButon:self.camDisabled];
			

	}
	[[self scrollView] setFrame:a];
	[[self scrollView] reloadContentSize];
	[[self textArea] resize:self.bottomOfWin];
}

#pragma mark Titanium's setters

-(void)setCamButton_:(id)args
{
	self.hasCam = [TiUtils boolValue:args];
	if(!self.firstTime)
	{
		[[self textArea] setCamera:self.hasCam];
		[[self textArea] resize:self.bottomOfWin];
	}
}	

-(void)setSendColor_:(id)col
{
    [[self scrollView] performSelectorOnMainThread:@selector(sendColor:) withObject:[TiUtils stringValue:col] waitUntilDone:YES];
}

-(void)setRecieveColor_:(id)col
{
    [[self scrollView] performSelectorOnMainThread:@selector(recieveColor:) withObject:[TiUtils stringValue:col] waitUntilDone:YES];
	
}

-(void)setSelectedColor_:(id)col
{
	[[self scrollView] performSelectorOnMainThread:@selector(selectedColor:) withObject:[TiUtils stringValue:col] waitUntilDone:YES];
}

-(void)setButtonTitle_:(id)title
{
	self.buttonTitle = [TiUtils stringValue:title];
	if(!self.firstTime)
	{
		[[self textArea] buttonTitle:[TiUtils stringValue:title]];
		[[self scrollView] reloadContentSize];
	}
}

-(void)setReturnKeyType_:(id)val
{
	self.returnType = [TiUtils intValue:val];
	if(!self.firstTime)
		[[[self textArea] textView] setReturnKeyType:self.returnType];
}

-(void)setFont_:(id)val
{
	self.font = [TiUtils fontValue:val def:nil];
	if(!self.firstTime)
		[[[self textArea] textView] setFont:[self.font font]];
}

-(void)setTextColor_:(id)val
{
	self.textColor = [TiUtils colorValue:val];
	if(!self.firstTime)
		[[[self textArea] textView] setTextColor:[self.textColor _color]];
}

-(void)setTextAlignment_:(id)val
{
	self.textAlignment = [TiUtils textAlignmentValue:val];
	if(!self.firstTime)
		[[[self textArea] textView] setTextAlignment:self.textAlignment];
}

-(void)setAutocorrect_:(id)val
{
	self.autocorrect = [TiUtils boolValue:val];
	if(!self.firstTime)
		[[[self textArea] textView ]setAutocorrectionType:[TiUtils boolValue:val] ? UITextAutocorrectionTypeYes : UITextAutocorrectionTypeNo];
}

-(void)setEditable_:(id)val
{
	self.beditable = [TiUtils boolValue:val];
	if(!self.firstTime)
		[[[self textArea] textView] setEditable:self.beditable];
}

-(void)setValue_:(id)val
{
	self.value = [TiUtils stringValue:val];
	if(!self.firstTime)
		[[[self textArea] textView]setText:self.value];
}

-(void)setAnimated_:(id)args
{
	[[self scrollView] animate:[TiUtils boolValue:args]];
	self.shouldAnimate = [TiUtils boolValue:args];
}

-(void)setAssets_:(id)args
{
	self.folder =  [[TiUtils stringValue:args] stringByAppendingString:@"/"];
	if(!self.firstTime)
	{
		[[self textArea] setFolder:args];
		[[self scrollView] setFolder:args];
	}
}
 
-(void)setReturnType_:(id)arg
{
	self.returnType = [TiUtils boolValue:arg];
	if(!self.firstTime)
		[[[self textArea] textView] setReturnKeyType:self.returnType];
}

-(void)setMaxLines_:(id)arg
{
	[[self textArea] setMaxLines:[TiUtils intValue:arg]];	
}

-(void)setMinLines_:(id)arg
{
	[[self textArea] setMinLines:[TiUtils intValue:arg]];
}

-(void)setSendButtonDisabled_:(id)arg
{
	self.sendDisabled = [TiUtils boolValue:arg];
	if(!self.firstTime)
	{
		[[self textArea] disableDoneButon:self.sendDisabled];
	}
}

-(void)setHasTab_:(id)args
{
	self.hasTabbar = [TiUtils boolValue:args];
}

-(void)setCamButtonDisabled_:(id)arg
{
	self.camDisabled = [TiUtils boolValue:arg];
	if(!self.firstTime)
	{
		[[self textArea] disableCamButon:self.camDisabled];
	}
}



-(void)setRightIcon:(UIImage *)val
{
    [self scrollView].rightIcon = val;
}

-(void)setLeftIcon:(UIImage *)val
{
    [self scrollView].leftIcon = val;
}

-(void)prevLoad {
    [self.proxy fireEvent:@"prevLoad"];
}

-(void)nextLoad {
    [self.proxy fireEvent:@"nextLoad"];
}

-(void) scrollToBottom {
    [[self scrollView] scrollToBottom];
}

-(CGPoint) contentOffset {
    return [[self scrollView] contentOffset];
}

-(CGSize) contentSize {
    return [[self scrollView] contentSize];
}

@end
