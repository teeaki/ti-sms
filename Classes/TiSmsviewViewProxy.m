//
//  PecTfTextFieldProxy.m
//  textfield
//
//  Created by Pedro Enrique on 7/3/11.
//  Copyright 2011 Appcelerator. All rights reserved.
//

#import "TiSmsviewView.h"
#import "TiSmsviewViewProxy.h"
#import "TiUtils.h"
#import "UIImage+Resize.h"

@implementation TiSmsviewViewProxy

-(void)_destroy
{
	// This method is called from the dealloc method and is good place to
	// release any objects and memory that have been allocated for the view proxy.
	[super _destroy];
}

-(void)dealloc
{
	// This method is called when the view proxy is being deallocated. The superclass
	// method calls the _destroy method.

	[super dealloc];
}

-(TiSmsviewView *)ourView
{
	if(!ourView)
	{
		ourView = (TiSmsviewView *)[self view];
	}
	return ourView;
}

-(void)viewDidAttach
{
	[[NSNotificationCenter defaultCenter] addObserver:[self ourView] 
											 selector:@selector(keyboardWillShow:) 
												 name:UIKeyboardWillShowNotification 
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:[self ourView] 
											 selector:@selector(keyboardWillHide:) 
												 name:UIKeyboardWillHideNotification 
											   object:nil];	
	[self retain];
	[super viewDidAttach];
}

-(void)viewDidDetach
{
	[self autorelease];
	[super viewDidDetach];
}

-(void)blur:(id)args
{
	ENSURE_UI_THREAD(blur, args);
	
	if([self viewAttached])
	{
		[[self ourView] _blur];
	}
}

-(void)focus:(id)args
{
	ENSURE_UI_THREAD(focus, args);
	if([self viewAttached])
	{
		[[self ourView] _focus];
	}
}


-(UIImage *)returnImage:(id)arg
{
	if([self viewAttached])
	{
		UIImage *image = nil;
		if ([arg isKindOfClass:[UIImage class]]) 
		{
			image = (UIImage*)arg;
		}
		else if ([arg isKindOfClass:[TiBlob class]])
		{
			TiBlob *blob = (TiBlob*)arg;
			image = [blob image];
			
		}
		else
		{
			NSLog(@"[WARN] The image MUST be a blob.");
			NSLog(@"[WARN]");
			NSLog(@"[WARN] This is a workaround:");
			NSLog(@"[WARN]");
			NSLog(@"[WARN] var img = Ti.UI.createImageView({image:'whatever.png'}).toImage();");
			NSLog(@"[WARN] xx.sendMessage(img);");
			NSLog(@"[WARN]      or");
			NSLog(@"[WARN] xx.recieveMessage(img);");
			NSLog(@"[WARN]");
		}
		
		if(image != nil)
		{
			CGSize imageSize = image.size;		
			if(imageSize.width > 270.0)//[[self ourView] superview].frame.size.width-100)
			{
				float x = 270.0;//([[self ourView] superview].frame.size.width-100);
				float y = ((x/imageSize.width)*imageSize.height);
				CGSize newSize = CGSizeMake(x, y);
				image = [UIImageResize resizedImage:newSize interpolationQuality:kCGInterpolationDefault image:image  hires:YES];
			}
			
		}		
		return image;
	}
	return nil;	
}

-(void)empty:(id)args
{
	ENSURE_UI_THREAD(empty, args);
	if([self viewAttached])
	{
		[ourView empty];
	}
}

-(void)emptyTextArea:(id)args {
    ENSURE_UI_THREAD(emptyTextArea, args);

    if ([self viewAttached]) {
        [ourView emptyTextArea];
    }
}

-(void)preSendMessage:(id)args
{
	ENSURE_UI_THREAD(preSendMessage,args);
	ENSURE_TYPE(args, NSArray);
	if([self viewAttached])
	{
		id arg = [args objectAtIndex:0];
		if([arg isKindOfClass:[NSString class]])
			[ourView preSendMessage:arg];
		else if ([arg isKindOfClass:[TiViewProxy class]])
		{
			TiViewProxy *a = arg;
			[ourView preSendImageView:a.view];
		}
		else
			[ourView preSendImage:[self returnImage:arg]];
	}
}

-(void)sendMessage:(id)args
{
	ENSURE_UI_THREAD(sendMessage,args);
	ENSURE_TYPE(args, NSArray);
	if([self viewAttached])
	{
		id arg = [args objectAtIndex:0];
		if([arg isKindOfClass:[NSString class]])
			[ourView sendMessage:arg];
		else if ([arg isKindOfClass:[TiViewProxy class]])
		{
			TiViewProxy *a = arg;
			[ourView sendImageView:a.view];
		}
		else
			[ourView sendImage:[self returnImage:arg]];
	}
}

-(void)preRecieveMessage:(id)args
{
	ENSURE_UI_THREAD(preRecieveMessage,args);
	ENSURE_TYPE(args, NSArray);
	if([self viewAttached])
	{
		
		id arg = [args objectAtIndex:0];
		
		if([arg isKindOfClass:[NSString class]])
			[ourView preRecieveMessage:arg];
		else if ([arg isKindOfClass:[TiViewProxy class]])
		{
			TiViewProxy *a = arg;
			[ourView preRecieveImageView:a.view];
		}
		else
			[ourView preRecieveImage:[self returnImage:arg]];
	}
}

-(void)recieveMessage:(id)args
{
	ENSURE_UI_THREAD(recieveMessage,args);
	ENSURE_TYPE(args, NSArray);
	if([self viewAttached])
	{
		
		id arg = [args objectAtIndex:0];
		
		if([arg isKindOfClass:[NSString class]])
			[ourView recieveMessage:arg];
		else if ([arg isKindOfClass:[TiViewProxy class]])
		{
			TiViewProxy *a = arg;
			[ourView recieveImageView:a.view];
		}
		else
			[ourView recieveImage:[self returnImage:arg]];
	}
}

-(void)addLabel:(id)args
{
	ENSURE_UI_THREAD(addLabel,args);
	ENSURE_TYPE(args, NSArray);
	if([self viewAttached])
	{
		id arg = [TiUtils stringValue: [args objectAtIndex:0]];
        id pos = @"center";
        if([args count] > 1) {
            pos = [TiUtils stringValue: [args objectAtIndex:1]];
        }
		if([arg isKindOfClass:[NSString class]])
			[ourView addLabel:arg at:pos];
	}
}

-(void)preAddLabel:(id)args
{
	ENSURE_UI_THREAD(preAddLabel,args);
	ENSURE_TYPE(args, NSArray);
	if([self viewAttached])
	{
		id arg = [TiUtils stringValue: [args objectAtIndex:0]];
        id pos = @"center";
        if([args count] > 1) {
            pos = [TiUtils stringValue: [args objectAtIndex:1]];
        }
		if([arg isKindOfClass:[NSString class]])
			[ourView preAddLabel:arg at:pos];
	}
}

-(void)loadMessages:(id)args
{
	ENSURE_SINGLE_ARG(args,NSArray);
	if([self viewAttached])
	{
		for(int i = 0; i < [args count]; i++)
		{
			id obj = [args objectAtIndex:i];
			ENSURE_SINGLE_ARG(obj, NSObject);
			if([obj objectForKey:@"send"])
			{
				[self sendMessage: [NSArray arrayWithObject:[obj objectForKey:@"send"]]];
			}
			if([obj objectForKey:@"recieve"])
			{
				[self recieveMessage: [NSArray arrayWithObject:[obj objectForKey:@"recieve"]]];
			}
		}
	}
}

-(NSArray *)getAllMessages:(id)arg
{
	if([self viewAttached])
	{
		return [ourView getMessages];
	}
	return nil;
}

-(id)value
{
	if([self viewAttached])
	{
		return [[self ourView] value];
	}
	return nil;
}

-(id)scrollY
{
	if([self viewAttached])
	{
        CGPoint contentOffset = [[self ourView] contentOffset];
        return [NSNumber numberWithInt:contentOffset.y];
	}
	return nil;
}

-(id)contentHeight
{
	if([self viewAttached])
	{
        CGSize contentSize = [[self ourView] contentSize];
        return [NSNumber numberWithInt:contentSize.height];
	}
	return nil;
}

-(void)scrollToBottom:(id)args
{
    ENSURE_UI_THREAD(scrollToBottom,args);
    [[self ourView] scrollToBottom];
}

-(void)setRightIcon:(id)val
{
    ENSURE_UI_THREAD_1_ARG(val);
    if(val) {
        [[self ourView] setRightIcon:[TiUtils toImage:val proxy:self]];
    }
}

-(void)setLeftIcon:(id)val
{
    ENSURE_UI_THREAD_1_ARG(val);
    if(val) {
        [[self ourView] setLeftIcon:[TiUtils toImage:val proxy:self]];
    }
}
@end
