//
//  AppDelegate.m
//  DSFStepperView ObjC Demo
//
//  Created by Darren Ford on 16/1/21.
//

#import "AppDelegate.h"

@import DSFStepperView;

@interface AppDelegate () <DSFStepperViewDelegateProtocol>

@property (strong) IBOutlet NSWindow *window;

@property (weak) IBOutlet DSFStepperView *red;
@property (weak) IBOutlet DSFStepperView *green;
@property (weak) IBOutlet DSFStepperView *blue;
@property (weak) IBOutlet NSColorWell *colorWell;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application
	[[self red] setDelegate: self];
	[[self green] setDelegate: self];
	[[self blue] setDelegate: self];

	[[self red] setIndicatorColor:[NSColor systemRedColor]];
	[[self green] setIndicatorColor:[NSColor systemGreenColor]];
	[[self blue] setIndicatorColor:[NSColor systemBlueColor]];

	[self colorDidChange: self];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
	// Insert code here to tear down your application
}

- (IBAction)colorDidChange:(id)sender {
	NSColor* c = [[self colorWell] color];

	int r = [c redComponent] * 255;
	int g = [c greenComponent] * 255;
	int b = [c blueComponent] * 255;

	[[self red] setNumberValue:@(r)];
	[[self green] setNumberValue:@(g)];
	[[self blue] setNumberValue:@(b)];
}

- (void)stepperView:(DSFStepperView * _Nonnull)view didChangeValueTo:(NSNumber * _Nullable)value {

	NSColor* c = [NSColor colorWithRed:[[_red numberValue] floatValue] / 255.0
								 green:[[_green numberValue] floatValue] / 255.0
								  blue:[[_blue numberValue] floatValue] / 255.0
								 alpha:1.0];
	[_colorWell setColor:c];
}

@end
