//
//  DTSettingsViewController.m
//  DataTracker
//
//  Created by Thomas Wilson on 29/10/2013.
//  Copyright (c) 2013 Thomas Wilson. All rights reserved.
//

#import "DTSettingsViewController.h"
#import "DTMainViewController.h"
@interface DTSettingsViewController ()

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
		
		fGLabel.frame = CGRectMake((self.view.bounds.size.width/2)-(size.width/2), ((self.view.bounds.size.height/2) + (size.height+fGSwitch.bounds.size.height)), size.width, size.height);
		fGLabel.attributedText = labelString;
		
			//set up switch
		fGSwitch.frame = CGRectMake(fGLabel.frame.origin.x, fGLabel.frame.origin.y+size.height, 0, 0);
		[fGSwitch addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
		
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		fGSwitch.on = [defaults boolForKey:kDataType4G];
		
		[self.view addSubview:fGSwitch];
		[self.view addSubview:fGLabel];
	}
	
	[self setUpSegmentControl];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setUpSegmentControl{
	NSArray *array = @[@"Map", @"Hybrid", @"Satlite"];
	UISegmentedControl *segmentControl = [[UISegmentedControl alloc]initWithItems:array];
	if (!segmentControl) {
		NSLog(@"Nil segmentControll");
	}
	segmentControl.frame = CGRectMake((self.view.bounds.size.width/2) - (segmentControl.bounds.size.width/2), self.view.bounds.size.height - segmentControl.bounds.size.height - 30, segmentControl.bounds.size.width, segmentControl.bounds.size.height);
	
	segmentControl.bounds = CGRectMake(0,0,segmentControl.bounds.size.width + 50, segmentControl.bounds.size.height +20);
	[segmentControl addTarget:self action:@selector(segmentControlChanged:) forControlEvents:UIControlEventValueChanged];
	
	switch ([[NSUserDefaults standardUserDefaults]integerForKey:kMapType]) {
		case MKMapTypeStandard:
			segmentControl.selectedSegmentIndex = 0;
			break;
		case MKMapTypeHybrid:
			segmentControl.selectedSegmentIndex = 1;
			break;
		case MKMapTypeSatellite:
			segmentControl.selectedSegmentIndex = 2;
			break;
		default:
			break;
	}
	
	[self.view addSubview:segmentControl];
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
@end
