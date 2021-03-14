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

@property (strong) NSColorSpace* displayColorSpace;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

	[self setDisplayColorSpace:[NSColorSpace sRGBColorSpace]];

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

	/// Make sure that we are in the rgb colorspace, or else 'redComponent' etc. will fail.
	id converted = [c colorUsingColorSpace:[self displayColorSpace]];
	int r = [converted redComponent] * 255;
	int g = [converted greenComponent] * 255;
	int b = [converted blueComponent] * 255;

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
