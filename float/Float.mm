#import <Preferences/Preferences.h>
#import "RSColorPickerView.h"
#import "RSColorFunctions.h"
#import "RSBrightnessSlider.h"
#import "RSOpacitySlider.h"
#define PLIST_PATH @"/var/mobile/Library/Preferences/com.irepo.float.plist"

#define IDIOM    UI_USER_INTERFACE_IDIOM()

#define IPAD     UIUserInterfaceIdiomPad

#define SYSTEM_VERSION_LESS_THAN(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

#define isiPhone5  ([[UIScreen mainScreen] bounds].size.height == 568)?TRUE:FALSE

static NSMutableDictionary *dict;

static void syncPreferences() { //call this to force syncronize your prefs when you change them
    
    CFStringRef appID = CFSTR("com.irepo.float");
    
    CFPreferencesSynchronize(appID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    
    
}

static void savePrefs (id key, id value) {
    
    CFPreferencesSetValue ((__bridge CFStringRef)key,(__bridge CFStringRef)value, CFSTR("com.irepo.float"), kCFPreferencesCurrentUser , kCFPreferencesAnyHost);
    
    syncPreferences();
    
}

static void PreferencesChangedCallback() {
    
    // [dict release];
    syncPreferences();
    
    CFStringRef appID = CFSTR("com.irepo.float");
    
    CFArrayRef keyList = CFPreferencesCopyKeyList(appID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    
    if (!keyList) {
        
        NSLog(@"There's been an error getting the key list!");
        return;
        
    }
    
    dict = (NSMutableDictionary *)CFPreferencesCopyMultiple(keyList, appID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    
    if (!dict) {
        
        NSLog(@"There's been an error getting the preferences dictionary!");
        
    }
    
    CFRelease(keyList);
    
}

@interface FloatColorPickerCell : PSTableCell <RSColorPickerViewDelegate> {
    RSColorPickerView *_colorPicker;
    RSBrightnessSlider *_brightnessSlider;
    //RSOpacitySlider *_opacitySlider;
    UIImageView *imageView2;
}
@end

@implementation FloatColorPickerCell //font color


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]))
    {
        self.backgroundView = [[UIView alloc] init];
        
        self.backgroundColor = [UIColor clearColor];
        
        _colorPicker = [[RSColorPickerView alloc] initWithFrame:CGRectZero];
        [self addSubview:_colorPicker];
        
        // View that controls brightness
        _brightnessSlider = [[RSBrightnessSlider alloc] initWithFrame:CGRectZero];
        [_brightnessSlider setColorPicker:_colorPicker];
        [self addSubview:_brightnessSlider];
        
        // View that controls opacity
        /*  _opacitySlider = [[RSOpacitySlider alloc] initWithFrame:CGRectZero];
         [_opacitySlider setColorPicker:_colorPicker];
         [self addSubview:_opacitySlider];*/
    }
    
    return self;
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    
    CGFloat yPadding = 20.0;
    CGFloat xPadding;
    
    
    if (IDIOM != IPAD) {
        
        
        xPadding = (self.bounds.size.width / 2) - 149.0;
        
    } else {
        
        xPadding = (self.bounds.size.width / 2) - 179;
        
    }
    
    [_colorPicker setFrame:CGRectMake(xPadding, 0.0, 300.0, 300.0)];
    
    [_brightnessSlider setFrame:CGRectMake(xPadding, _colorPicker.frame.origin.y + _colorPicker.bounds.size.height + yPadding, 300.0, 30.0)];
    
    //[_opacitySlider setFrame:CGRectMake(xPadding, _brightnessSlider.frame.origin.y + _brightnessSlider.bounds.size.height + yPadding, 300.0, 30.0)];
}

- (id)value

{
    return [_colorPicker selectionColor];
}

- (void)dealloc
{
    [_colorPicker release];
    [_brightnessSlider release];
    //[_opacitySlider release];
    [imageView2 release];
    [super dealloc];
}

@end


@interface FloatListController: PSListController {
}
@end

@implementation FloatListController
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"Float" target:self] retain];
	}
	return _specifiers;
}
@end

@interface FloatColorController : PSListController
{
}
@end


@implementation FloatColorController



- (id)specifiers
{
    if (_specifiers == nil)
    {
        _specifiers = [[self loadSpecifiersFromPlistName:@"FloatColorController" target:self] retain];
        
    }
    return _specifiers;
}

- (void)apply
{
    FloatColorPickerCell *colorPicker = [self cachedCellForSpecifierID:@"floatColorPicker"];
    CGFloat r, g, b, a;
    [[colorPicker value] getRed:&r green:&g blue:&b alpha:&a];
    
    savePrefs(@"red", [NSNumber numberWithFloat:r] );
    savePrefs(@"green", [NSNumber numberWithFloat:g] );
    savePrefs(@"blue", [NSNumber numberWithFloat:b] );
    savePrefs(@"alphaF", [NSNumber numberWithFloat:a] );

    [self reload];
    
    //[dict writeToFile:PLIST_PATH atomically:TRUE];
}

@end


@interface floatSelectedColorCell : PSTableCell  {
    
}

@end

@implementation floatSelectedColorCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]))
        
    {
        PreferencesChangedCallback();
        
        self.backgroundView = [[UIView alloc] init];
        
        [self.layer setCornerRadius:7.0f];
        
        [self.backgroundView.layer setCornerRadius:7.0f];
        
        [self.layer setMasksToBounds:YES];
        
        [self.layer setBorderWidth:0.0f];
        
        //  NSMutableDictionary *rootObj=[[NSMutableDictionary alloc] initWithContentsOfFile:PLIST_PATH];
        
        CGFloat red_s = [[dict objectForKey:@"red"] floatValue];
        
        CGFloat green_s = [[dict objectForKey:@"green"] floatValue];
        
        CGFloat blue_s = [[dict objectForKey:@"blue"] floatValue];
        
        self.backgroundView.backgroundColor = [UIColor colorWithRed:red_s green:green_s blue:blue_s alpha:1.0];
    }
    
    
    return self;
    
}


- (void)layoutSubviews
{
    
    [super layoutSubviews];
    
    if (IDIOM != IPAD) {
        if (!isiPhone5) {
            [self.layer setFrame:CGRectMake(CGRectGetMidX(self.superview.frame) - 130,210,260,50)];
        } else {
            [self.layer setFrame:CGRectMake(30,210,260,50)];
        }
        
    } else {
        
        [self.layer setFrame:CGRectMake(40,240,380,50)];
        
    }
    
    
}

- (void)dealloc {
    
    [super dealloc];
    
}
@end

// vim:ft=objc
