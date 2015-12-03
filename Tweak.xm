@interface SBControlCenterContainerView : UIView
-(UIView *)dynamicsContainerView;

@end

@interface SBControlCenterContentView : UIView 
@end
@interface UIView (mine) 
-(void)setBlurRadius:(CGFloat)radius;
@end

@interface _UIBackdropView : UIView
- (id)outputSettings;
-(id)initWithFrame:(CGRect)frame autosizesToFitSuperview:(BOOL)size settings:(id)settings;
-(void)setBlurRadius:(CGFloat)arg1;
-(void)setRequiresColorStatistics:(BOOL)arg1;
-(void)setUsesColorTintView:(BOOL)arg1;
-(void)setColorTintAlpha:(float)arg1;
-(void)setColorTintMaskAlpha:(float)arg1;
- (void)setColorTint:(id)arg1;
@end

@interface _UIBackdropViewSettings
- (void)setColorTint:(id)arg1;
- (void)setUsesColorTintView:(BOOL)arg1;
- (void)setStyle:(int)arg1;
- (id)initWithDefaultValues;
- (void)setBlurRadius:(CGFloat)arg1;
- (void)setBlurHardEdges:(int)arg1;
- (void)setBlurQuality:(id)arg1;
-(void)setTintColor:(id)arg1;
@end

@interface SBControlCenterSectionView : UIView
@end

@interface SBControlCenterContentContainerView : UIView 
-(_UIBackdropView *)backdropView;
-(double)contentHeight;
-(void)setContentHeight:(double)arg1;
@end

static SBControlCenterContentContainerView *containerView = nil;
static _UIBackdropView *customBackdrop = nil;
static NSMutableDictionary *dict = nil;
static BOOL enabled;
static BOOL customColor;
static CGFloat red;
static CGFloat blue;
static CGFloat green;

static void syncPreferences() { //call this to force syncronize your prefs when you change them  
    CFStringRef appID = CFSTR("com.irepo.float");
    CFPreferencesSynchronize(appID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost); 
}

static void PreferencesChangedCallback() {
    
    // [dict release];
    syncPreferences();
 
    CFStringRef appID = CFSTR("com.irepo.float");
    CFArrayRef keyList = CFPreferencesCopyKeyList(appID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    if (!keyList) {
        return;
    }
    
    dict = (NSMutableDictionary *)CFBridgingRelease(CFPreferencesCopyMultiple(keyList, appID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost)); 
    if (!dict) {     
        NSLog(@"There's been an error getting the preferences dictionary!");
    }
    
    CFRelease(keyList);
    enabled = [[dict objectForKey:@"enabled"] boolValue];
    customColor = [[dict objectForKey:@"color"] boolValue];
    red = [[dict objectForKey:@"red"] floatValue];
    green = [[dict objectForKey:@"green"] floatValue];
    blue = [[dict objectForKey:@"blue"] floatValue];

}

%ctor {
  BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:@"/var/mobile/Library/Preferences/com.irepo.float.plist"];
  if (!fileExists) {

      NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] initWithDictionary:@{@"enabled" : [NSNumber numberWithBool:YES] , @"color" : [NSNumber numberWithBool:NO]}];

      [tempDict writeToFile:@"/var/mobile/Library/Preferences/com.irepo.float.plist" atomically:YES];

  }
	PreferencesChangedCallback();
}

%hook SBControlCenterContentContainerView 

%end

%hook SBControlCenterContentView

-(void)layoutSubviews {
	%orig;
}

%end

%hook SBControlCenterViewController

- (void)setRevealPercentage:(CGFloat)fp8 {
	customBackdrop.alpha = fp8;
	%orig;
} 
%end

%hook SBControlCenterGrabberView 
-(id)chevronView {
	if (enabled) {
	 UIView *i  = %orig;
	 i.alpha = 0.0;
	 return i;
	} else {
		return %orig;
	}
}
-(CGRect)_grabberRect {
	if (enabled) {
		return CGRectMake(0,0,0,0);
	} else {
		return %orig;
	}
}

%end

%hook SBControlCenterContainerView

-(void)layoutSubviews {
	PreferencesChangedCallback();
	%orig;
if (enabled) {
	Class UIBackDropView = objc_getClass("_UIBackdropView");
    if (UIBackDropView)
    {
        _UIBackdropViewSettings *settings = [[%c(_UIBackdropViewSettings) alloc] initWithDefaultValues];
    	if (customColor) {
	    	 settings = [[%c(_UIBackdropViewSettingsColored) alloc] initWithDefaultValues];
	 	}	
	    [settings setStyle:1];
	    [settings setBlurRadius:16.0];
	    [settings setBlurHardEdges:3];
	    if (customColor) {
			[settings setColorTint:[UIColor colorWithRed:red green:green blue:blue alpha:0.5]];
		}
		[settings setBlurQuality:@"default"];
	    customBackdrop = [[_UIBackdropView alloc] initWithFrame:CGRectZero autosizesToFitSuperview:YES settings:settings];
	    [customBackdrop.outputSettings setBlurRadius:3];
	    customBackdrop.alpha = 0.0;
	  
     } 
	UIView *view = MSHookIvar<UIView *>(self,"_darkeningView");
	view.alpha = 0.0;
	containerView = MSHookIvar<SBControlCenterContentContainerView *>(self,"_contentContainerView");
//	containerView.contentHeight = 400;
	UIView *back = containerView.subviews[0];
	UIView *test = containerView.subviews[1];
	[self insertSubview:customBackdrop atIndex:0];
	back.alpha = 0.0;
	test.alpha = 0.0;
  }
}

- (void)_updateDarkeningFrame {
	if (!enabled) {
		%orig;
	}
}

%end