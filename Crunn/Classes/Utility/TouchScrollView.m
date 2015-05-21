//
//  TouchScrollView.m
//  mqApp
//
//  Created by Scott Guyer on 12/3/09.
//  Copyright 2009 Erixir Inc Limited. All rights reserved.
//

#import "TouchScrollView.h"


@implementation TouchScrollView


- (void) touchesEnded: (NSSet *) touches withEvent: (UIEvent *) event 
{
	if (!self.dragging) 
	{
		[self.nextResponder touchesEnded:touches withEvent:event]; 
		return;
	}
	
	[super touchesEnded: touches withEvent: event];
}


@end
