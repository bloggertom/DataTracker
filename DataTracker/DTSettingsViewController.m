//
//  DTSettingsViewController.m
//  DataTracker
//
//  Created by Thomas Wilson on 29/10/2013.
//  Copyright (c) 2013 Thomas Wilson. All rights reserved.
//

#import "DTSettingsViewController.h"
#import "DTMainViewController.h"
#import <QuartzCore/QuartzCore.h>
#define DisabledAlpha 0.5
#define EnabledAlpha 1.0

@interface DTSettingsViewController ()
@property (nonatomic, strong)UIButton *removeButton;
@property (nonatomic, strong)UISegmentedControl *segmentControl;
@end

@implementation DTSettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	//set up remove button
	self.view.backgroundColor = [UIColor whiteColor];
	
		
	[self setUpUI];
	
}
-(void)setUpUI{
	
	[self setUpSegmentControl];
	
	//check if 4G is possible
	if ([DTMainViewController FourGEnabledModel]) {
		UILabel *fGLabel = [[UILabel alloc]init];
		UISwitch *fGSwitch = [[UISwitch alloc]init];
			//set up label for switch
		fGLabel.font = [UIFont boldSystemFontOfSize:13];
		
		NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
		[dic setObject:fGLabel.font	forKey:NSFontAttributeName];
		[dic setObject:[UIColor darkTextColor] forKey:NSForegroundColorAttributeName];
		NSMutableAttributedString *labelString = [[NSMutableAttributedString alloc]initWithString:@"4G Mode:" attributes:dic];
		CGSize size = [labelString.string sizeWithAttributes:dic];
		
		fGLabel.frame = CGRectMake((self.view.bounds.size.width/2)-(size.width/2), (self.view.bounds.size.height/2) + 25
																					//+(size.height+fGSwitch.bounds.size.height))
								   , size.width, size.height);
		fGLabel.attributedText = labelString;
		
			//set up switch
		fGSwitch.frame = CGRectMake(fGLabel.frame.origin.x, fGLabel.frame.origin.y+size.height, 0, 0);
		[fGSwitch addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
		
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		fGSwitch.on = [defaults boolForKey:kDataType4G];
		
		[self.view addSubview:fGSwitch];
		[self.view addSubview:fGLabel];
		
	}
	
		//build remove button
	_removeButton = [UIButton buttonWithType:UIButtonTypeSystem];
	[_removeButton setTitle:@"Remove All Results" forState:UIControlStateNormal];
	_removeButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
	[_removeButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
	[_removeButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
	_removeButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
	_removeButton.layer.borderWidth = 1;
		
	[_removeButton sizeToFit];
	CGRect bounds= _removeButton.frame;
	bounds.size.height += 20;
	bounds.size.width += 30;
	bounds.origin.y = _segmentControl.frame.origin.y - bounds.size.height - 20;
	bounds.origin.x = self.view.bounds.size.width - (bounds.size.width) - 30;
	_removeButton.frame = bounds;
	_removeButton.enabled = NO;
	_removeButton.alpha = DisabledAlpha;
	
	[_removeButton addTarget:self action:@selector(userHasRequestedDataWhipe) forControlEvents:UIControlEventTouchUpInside];
	
	[self.view addSubview:_removeButton];
	
	UISwitch *confirmationSwith = [[UISwitch alloc]init];
	bounds.origin.x = 30;
	bounds.origin.y += _removeButton.bounds.size.height/4;
	confirmationSwith.frame = bounds;
	[confirmationSwith addTarget:self action:@selector(confirmationSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
	confirmationSwith.on = NO;
	[self.view addSubview:confirmationSwith];
	
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setUpSegmentControl{
	NSArray *array = @[@"Map", @"Hybrid", @"Satlite"];
	_segmentControl = [[UISegmentedControl alloc]initWithItems:array];
	if (!_segmentControl) {
		NSLog(@"Nil segmentControll");
	}
	_segmentControl.frame = CGRectMake((self.view.bounds.size.width/2) - (_segmentControl.bounds.size.width/2), self.view.bounds.size.height - _segmentControl.bounds.size.height - 30, _segmentControl.bounds.size.width, _segmentControl.bounds.size.height);
	
	_segmentControl.bounds = CGRectMake(0,0,_segmentControl.bounds.size.width + 50, _segmentControl.bounds.size.height +20);
	[_segmentControl addTarget:self action:@selector(segmentControlChanged:) forControlEvents:UIControlEventValueChanged];
	
	switch ([[NSUserDefaults standardUserDefaults]integerForKey:kMapType]) {
		case MKMapTypeStandard:
			_segmentControl.selectedSegmentIndex = 0;
			break;
		case MKMapTypeHybrid:
			_segmentControl.selectedSegmentIndex = 1;
			break;
		case MKMapTypeSatellite:
			_segmentControl.selectedSegmentIndex = 2;
			break;
		default:
			break;
	}
	
	[self.view addSubview:_segmentControl];
}

-(void)switchValueChanged:(id)sender{
	if ([sender isKindOfClass:[UISwitch class]]) {
		UISwitch *fgSwitch = (UISwitch *)sender;
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		[defaults setBool:fgSwitch.on forKey:kDataType4G];
		[self.callBack switchValueDidChanged:fgSwitch.on];
	}
}

-(void)segmentControlChanged:(id)sender{
	if ([sender isKindOfClass:[UISegmentedControl class]]) {
		UISegmentedControl *control = (UISegmentedControl*)sender;
		
		[self.callBack segmentControlValueDidChange:control.selectedSegmentIndex];
	}
}
-(void)confirmationSwitchValueChanged:(id)sender{
	if ([sender isKindOfClass:[UISwitch class]]) {
		UISwitch *conSwitch = (UISwitch *)sender;
		if (conSwitch.on) {
			_removeButton.alpha = EnabledAlpha;
			_removeButton.enabled = YES;
			_removeButton.layer.borderColor = [UIColor redColor].CGColor;
		}else{
			_removeButton.alpha = DisabledAlpha;
			_removeButton.enabled = NO;
			_removeButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
		}
	}
}

-(void)userHasRequestedDataWhipe{
	[self.callBack userDidRequestDataWhipe];
}
@end
