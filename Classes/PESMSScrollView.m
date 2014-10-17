//
//  ScrollView.m
//  chat
//
//  Created by Pedro Enrique on 8/12/11.
//  Copyright 2011 Appcelerator. All rights reserved.
//

#import "PESMSScrollView.h"
#import "PESMSIcon.h"
#import "TiUtils.h"

@implementation PESMSScrollView
@synthesize labelsPosition;
@synthesize sColor;
@synthesize rColor;
@synthesize animated;
@synthesize selectedColor;
@synthesize folder;
@synthesize allMessages;
@synthesize numberOfMessage;
@synthesize tempDict;
@synthesize leftIcon;
@synthesize rightIcon;
@synthesize refreshDelegate;

-(void)dealloc
{
	RELEASE_TO_NIL(allMessages);
    [header release];
    [footer release];
    if(rightIcon) {
        [rightIcon release];
    }
    if(leftIcon) {
        [leftIcon release];
    }
	//[tempDict release];
	[super dealloc];
}

- (id)initWithFrame:(CGRect)aRect{
    self = [super initWithFrame:aRect];
    if (self) {
		self.labelsPosition = self.frame;
		self.animated = YES;
		tempDict = [[NSMutableDictionary alloc] init];
		self.tempDict = tempDict;
		allMessages = [[NSMutableArray alloc] init];
		self.allMessages = allMessages;
		self.numberOfMessage = 0;
        self.delegate = self;
        self.userInteractionEnabled = YES;
        self.bouncesZoom = NO;
        
        // pull to load
        header = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, -60, self.frame.size.width, 60)];
        header.delegate = self;
        [self addSubview:header];
        [header refreshLastUpdatedDate];
        footer = [[EGORefreshTableFooterView alloc] initWithFrame:CGRectMake(0.0f, 60, self.frame.size.width, 60)];
        footer.delegate = self;
        [self addSubview:footer];
        [footer refreshLastUpdatedDate];
	}
    return self;
}

-(PESMSTextLabel *)textLabel:(NSString *)text
{
	[self performSelectorOnMainThread:@selector(reloadContentSize) withObject:nil waitUntilDone:YES];
	
	textLabel = [[PESMSTextLabel alloc] initWithFrame:self.frame];
	[textLabel addText:text];
	[textLabel resize:self.frame];
    textLabel.font = [UIFont systemFontOfSize:11];
	
	CGRect frame = textLabel.frame;
	frame.origin.y += labelsPosition.origin.y + 5;
	[textLabel setFrame:frame];
	
	CGRect a = self.labelsPosition;
	a.origin.y = frame.origin.y+frame.size.height - 5;
	self.labelsPosition = a;
    
	[textLabel setIndex_:self.numberOfMessage];

	[self.tempDict setObject:[NSString stringWithFormat:@"%i",self.numberOfMessage] forKey:@"index"];
	
	self.numberOfMessage++;
	
	[self.allMessages addObject:[NSDictionary dictionaryWithDictionary:self.tempDict]];
	
	[self addSubview:textLabel];

	return textLabel;
}

-(PESMSTextLabel *)preTextLabel:(NSString *)text
{
	[self performSelectorOnMainThread:@selector(reloadContentSize) withObject:nil waitUntilDone:YES];
	
	textLabel = [[PESMSTextLabel alloc] initWithFrame:self.frame];
	[textLabel addText:text];
	[textLabel resize:self.frame];
    textLabel.font = [UIFont systemFontOfSize:11];
	
    CGRect frame = textLabel.frame;
    frame.origin.y += 5;
    [textLabel setFrame:frame];
    
    for (int i = 0; i < self.subviews.count; i++) {
        UIView *view = [self.subviews objectAtIndex:i];
        if(view != textLabel && view != header && view != footer) {
            CGRect dest = view.frame;
            dest.origin.y += frame.origin.y + frame.size.height - 5;
            [view setFrame:dest];
        }
    }
    
    CGRect a = self.labelsPosition;
	a.origin.y = a.origin.y + frame.origin.y + frame.size.height - 5;
	self.labelsPosition = a;
    
	[textLabel setIndex_:self.numberOfMessage];
    
	[self.tempDict setObject:[NSString stringWithFormat:@"%i",self.numberOfMessage] forKey:@"index"];
	
	self.numberOfMessage++;
	
    [self.allMessages insertObject:[NSDictionary dictionaryWithDictionary:self.tempDict] atIndex:0];
	
	[self addSubview:textLabel];
    
	return textLabel;
    
}

-(PESMSLabel *)label:(NSString *)text:(UIImage *)image:(TiUIView *)view:(NSString *)pos
{

	[self performSelectorOnMainThread:@selector(reloadContentSize) withObject:nil waitUntilDone:YES];

	label = [[PESMSLabel alloc] init];
	[label setFolder:self.folder];
	
	[self.tempDict removeAllObjects];
	
	[self addSubview:label];
	
	if(text)
	{
		[label addText:text];
		[self.tempDict setObject:text forKey:pos];
	}
	if(image)
	{
		[label addImage:image];
		TiBlob *blob = [[[TiBlob alloc] initWithImage:image] autorelease];
		[self.tempDict setObject:blob forKey:pos];
	}
	if(view)
	{
		[label addImageView:view];
		[self.tempDict setObject:view.proxy forKey:pos];
	}
	CGRect frame = label.frame;
	frame.origin.y += labelsPosition.origin.y;	
	[label setFrame:frame];
	
	CGRect a = self.labelsPosition;
	a.origin.y = frame.origin.y+frame.size.height;
	self.labelsPosition = a;
    
	[label setIndex_:self.numberOfMessage];

	[self.tempDict setObject:[NSString stringWithFormat:@"%i",self.numberOfMessage] forKey:@"index"];
	
	self.numberOfMessage++;
	
	[self.allMessages addObject:[NSDictionary dictionaryWithDictionary:self.tempDict]];
	return label;
}

-(PESMSLabel *)prepend:(NSString *)text:(UIImage *)image:(TiUIView *)view:(NSString *)pos
{
    
	[self performSelectorOnMainThread:@selector(reloadContentSize) withObject:nil waitUntilDone:YES];
    
	label = [[PESMSLabel alloc] init];
	[label setFolder:self.folder];
	
	[self.tempDict removeAllObjects];
	
	[self addSubview:label];
	
	if(text)
	{
		[label addText:text];
		[self.tempDict setObject:text forKey:pos];
	}
	if(image)
	{
		[label addImage:image];
		TiBlob *blob = [[[TiBlob alloc] initWithImage:image] autorelease];
		[self.tempDict setObject:blob forKey:pos];
	}
	if(view)
	{
		[label addImageView:view];
		[self.tempDict setObject:view.proxy forKey:pos];
	}
    
	CGRect frame = label.frame;
	for (int i = 0; i < self.subviews.count; i++) {
        UIView *view = [self.subviews objectAtIndex:i];
        if(view != label && view != header && view != footer) {
            CGRect dest = view.frame;
            dest.origin.y += frame.origin.y + frame.size.height;
            [view setFrame:dest];
        }
    }
	
	CGRect a = self.labelsPosition;
	a.origin.y = a.origin.y + frame.origin.y + frame.size.height;
	self.labelsPosition = a;
    
	[label setIndex_:0];
    
	[self.tempDict setObject:[NSString stringWithFormat:@"%i",self.numberOfMessage] forKey:@"index"];
	
	self.numberOfMessage++;
	
    [self.allMessages insertObject:[NSDictionary dictionaryWithDictionary:self.tempDict] atIndex:0];
	return label;
}

-(void)renderRightIcon:(CGRect)frame {
    if(self.rightIcon) {
        PESMSIcon *image = [[PESMSIcon alloc] initWithImage:self.rightIcon];
        image.userInteractionEnabled = YES;
        image.tag = RIGHT_ICON_TAG;
        CGRect f = image.frame;
        f.origin.x = frame.origin.x + frame.size.width;
        f.origin.y = frame.origin.y + frame.size.height - 25;
        f.size.width = 30;
        f.size.height = 30;
        image.frame = f;
        [self addSubview:image];
        [image release];
    }
}

-(void)renderLeftIcon:(CGRect)frame {
    if(self.leftIcon) {
        PESMSIcon *image = [[PESMSIcon alloc] initWithImage:self.leftIcon];
        image.userInteractionEnabled = YES;
        image.tag = LEFT_ICON_TAG;
        CGRect f = image.frame;
        f.origin.x = frame.origin.x - 30;
        f.origin.y = frame.origin.y + frame.size.height - 25;
        f.size.width = 30;
        f.size.height = 30;
        image.frame = f;
        [self addSubview:image];
        [image becomeFirstResponder];
        [image release];
    }
}

-(void)reloadContentSize
{
    if(CGRectIsEmpty(self.labelsPosition))
        self.labelsPosition = self.frame;
    
	CGFloat bottomOfContent = MAX(self.labelsPosition.origin.y + 5, self.frame.size.height + 1);//+self.labelsPosition.size.height;
	
	CGSize contentSize1 = CGSizeMake(self.frame.size.width , bottomOfContent);
	
	
	[self setContentSize:contentSize1];
    [header removeFromSuperview];
    [self addSubview:header];
    [footer removeFromSuperview];
    [footer setFrame:CGRectMake(0.0f, self.contentSize.height, self.bounds.size.width, 60)];
    [self addSubview:footer];
	//CGRect contentSize2 = CGRectMake(0,0,self.frame.size.width, bottomOfContent);
	//[self scrollRectToVisible: contentSize2 animated: self.animated];
}

-(void) scrollToBottom {
    [self scrollRectToVisible: CGRectMake(0,0,self.frame.size.width, self.labelsPosition.origin.y + 5) animated: self.animated];
}

-(void)sendColor:(NSString *)col
{
    self.sColor = col;
}
-(void)recieveColor:(NSString *)col
{
    self.rColor = col;
}

-(void)selectedColor:(NSString *)col
{
	self.selectedColor = col;
}

-(void)backgroundColor:(UIColor *)col
{
	self.backgroundColor = col;
}

-(void)recieveImage:(UIImage *)image
{
	if(!self.rColor)
		self.rColor = @"White";
    PESMSLabel *l = [self label:nil:image:nil:@"recieve"];
	[l position:@"Left":self.rColor:self.selectedColor icon:!!self.leftIcon];
    [self renderLeftIcon:l.frame];
	RELEASE_TO_NIL(label);
}

-(void)sendImage:(UIImage *)image
{
	if(!self.sColor)
		self.sColor = @"Green";
    PESMSLabel *l = [self label:nil:image:nil:@"send"];
	[l position:@"Right":self.sColor:self.selectedColor icon:!!self.rightIcon];
    [self renderRightIcon:l.frame];
	RELEASE_TO_NIL(label);
}

-(void)recieveImageView:(TiUIView *)view
{
	if(!self.rColor)
		self.rColor = @"White";
    PESMSLabel *l = [self label:nil:nil:view:@"recieve"];
	[l position:@"Left":self.rColor:self.selectedColor icon:!!self.leftIcon];
    [self renderLeftIcon:l.frame];
	RELEASE_TO_NIL(label);
}

-(void)sendImageView:(TiUIView *)view
{
	if(!self.sColor)
		self.sColor = @"Green";
    PESMSLabel *l = [self label:nil:nil:view:@"send"];
	[l position:@"Right":self.sColor:self.selectedColor icon:!!self.rightIcon];
    [self renderRightIcon:l.frame];
	RELEASE_TO_NIL(label);
}

-(void)recieveMessage:(NSString *)text;
{
    if(!self.rColor)
        self.rColor = @"White";
    
    PESMSLabel *l = [self label:text:nil:nil:@"recieve"];
	[l position:@"Left":self.rColor:self.selectedColor icon:!!self.leftIcon];
    [self renderLeftIcon:l.frame];
	RELEASE_TO_NIL(label);
}

-(void)sendMessage:(NSString *)text;
{	
    if(!self.sColor)
        self.sColor = @"Green";
	PESMSLabel *l = [self label:text:nil:nil:@"send"];
	[l position:@"Right":self.sColor:self.selectedColor icon:!!self.rightIcon];
    [self renderRightIcon:l.frame];
	RELEASE_TO_NIL(label);
}

// prepend methods
-(void)preRecieveImage:(UIImage *)image
{
	if(!self.rColor)
		self.rColor = @"White";
    PESMSLabel *l = [self prepend:nil:image:nil:@"recieve"];
	[l position:@"Left":self.rColor:self.selectedColor icon:!!self.leftIcon];
    [self renderLeftIcon:l.frame];
	RELEASE_TO_NIL(label);
}

-(void)preSendImage:(UIImage *)image
{
	if(!self.sColor)
		self.sColor = @"Green";
    PESMSLabel *l = [self prepend:nil:image:nil:@"send"];
	[l position:@"Right":self.sColor:self.selectedColor icon:!!self.rightIcon];
    [self renderRightIcon:l.frame];
	RELEASE_TO_NIL(label);
}

-(void)preRecieveImageView:(TiUIView *)view
{
	if(!self.rColor)
		self.rColor = @"White";
    PESMSLabel *l = [self prepend:nil:nil:view:@"recieve"];
	[l position:@"Left":self.rColor:self.selectedColor icon:!!self.leftIcon];
    [self renderLeftIcon:l.frame];
	RELEASE_TO_NIL(label);
}

-(void)preSendImageView:(TiUIView *)view
{
	if(!self.sColor)
		self.sColor = @"Green";
    PESMSLabel *l = [self prepend:nil:nil:view:@"send"];
	[l position:@"Right":self.sColor:self.selectedColor icon:!!self.rightIcon];
    [self renderRightIcon:l.frame];
	RELEASE_TO_NIL(label);
}

-(void)preRecieveMessage:(NSString *)text;
{
    if(!self.rColor)
        self.rColor = @"White";
    
    PESMSLabel *l = [self prepend:text:nil:nil:@"recieve"];
	[l position:@"Left":self.rColor:self.selectedColor icon:!!self.leftIcon];
    [self renderLeftIcon:l.frame];
	RELEASE_TO_NIL(label);
}

-(void)preSendMessage:(NSString *)text;
{
    if(!self.sColor)
        self.sColor = @"Green";
	PESMSLabel *l = [self prepend:text:nil:nil:@"send"];
	[l position:@"Right":self.sColor:self.selectedColor icon:!!self.rightIcon];
    [self renderRightIcon:l.frame];
	RELEASE_TO_NIL(label);
}

-(void)addLabel:(NSString *)text;
{	
	[self textLabel:text];
	RELEASE_TO_NIL(textLabel);
}

-(void)addLeftLabel:(NSString *)text;
{
	[self textLabel:text].textAlignment = UITextAlignmentLeft;
	RELEASE_TO_NIL(textLabel);
}

-(void)addRightLabel:(NSString *)text;
{
	[self textLabel:text].textAlignment = UITextAlignmentRight;
	RELEASE_TO_NIL(textLabel);
}

-(void)preAddLabel:(NSString *)text;
{
	[self preTextLabel:text];
	RELEASE_TO_NIL(textLabel);
}

-(void)preAddLeftLabel:(NSString *)text;
{
	[self preTextLabel:text].textAlignment = UITextAlignmentLeft;
	RELEASE_TO_NIL(textLabel);
}

-(void)preAddRightLabel:(NSString *)text;
{
	[self preTextLabel:text].textAlignment = UITextAlignmentRight;
	RELEASE_TO_NIL(textLabel);
}


-(void)animate:(BOOL)arg
{
	self.animated = arg;
}

-(void)empty
{
	ENSURE_UI_THREAD_0_ARGS
	[[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
	self.labelsPosition = self.frame;
	[self.allMessages removeAllObjects];
	self.numberOfMessage = 0;
	[self reloadContentSize];
	[self setNeedsDisplay];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	[header egoRefreshScrollViewDidScroll:scrollView];
    [footer egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	[header egoRefreshScrollViewDidEndDragging:scrollView];
    [footer egoRefreshScrollViewDidEndDragging:scrollView];
}

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
    if(self.refreshDelegate) {
        [self.refreshDelegate prevLoad];
    }
    [self performSelector:@selector(endHeaderLoading) withObject:nil afterDelay:1.0];
}

- (void)egoRefreshTableFooterDidTriggerRefresh:(EGORefreshTableFooterView*)view{
    if(self.refreshDelegate) {
        [self.refreshDelegate nextLoad];
    }
    [self performSelector:@selector(endFooterLoading) withObject:nil afterDelay:1.0];
}

- (void)endHeaderLoading {
    [header egoRefreshScrollViewDataSourceDidFinishedLoading:self];
}

- (void)endFooterLoading {
    [footer egoRefreshScrollViewDataSourceDidFinishedLoading:self];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	return NO; // should return if data source model is reloading
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	return [NSDate date]; // should return date data source was last changed
}

- (BOOL)egoRefreshTableFooterDataSourceIsLoading:(EGORefreshTableFooterView*)view{
	return NO; // should return if data source model is reloading
}

- (NSDate*)egoRefreshTableFooterDataSourceLastUpdated:(EGORefreshTableFooterView*)view{
	return [NSDate date]; // should return date data source was last changed
}

@end
