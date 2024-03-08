#import "VCMainMenuViewController.h"

#import "VCGridOfImagesViewController.h"
#import "DetailViewController.h" // for web loading directly
#import "SVGKSourceURL.h" // for web loading directly

#import "VCAllSpecImages.h" // spec images have special settings in their VC, to wokraround XCode Groups/Folder References/Virtual folder build bugs (UNFIXED BY APPLE FOR 8+  years!)

@interface VCMainMenuViewController ()

@end

@implementation VCMainMenuViewController

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
	if( [identifier isEqualToString:@"ViewURL"])
	{
		NSString* s = self.textWebURL.text;
		
		if( s != nil && [[s lowercaseString] hasPrefix:@"http"])
		{
			return TRUE;
		}
		else
		{
			[[[UIAlertView alloc] initWithTitle:@"Enter a URL" message:@"Enter a URL starting 'http://'" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show
			 ];
			return FALSE;
		}
	}
	
	return TRUE;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if( [segue.identifier isEqualToString:@"ViewURL"])
	{
		NSString* s = self.textWebURL.text;
		
		if( s != nil && [[s lowercaseString] hasPrefix:@"http"])
		{
			DetailViewController* nextVC = (DetailViewController*)segue.destinationViewController;
			
			nextVC.detailItem = [SVGKSourceURL sourceFromURL:[NSURL URLWithString:s]];
		}
	}
	else if( [segue.identifier hasPrefix:@"W3CTestSuite"] )
	{
		VCAllSpecImages* nextVC = (VCAllSpecImages*) segue.destinationViewController;
		nextVC.pathInBundleToSVGSpecTestSuiteFolder = @"W3C_SVG_11_TestSuite";
	}
	else if( [segue.identifier hasPrefix:@"View"] )
	{
		NSString* sectionName = nil;
		
		if( [segue.identifier isEqualToString:@"ViewSVGSpec"])
		{
			sectionName = @"SVG Spec";
		}
		else if( [segue.identifier isEqualToString:@"ViewContributed"])
		{
			sectionName = @"Contributed";
		}
		else if( [segue.identifier isEqualToString:@"ViewWeb"])
		{
			sectionName = @"Online / from Web";
		}
		else if( [segue.identifier isEqualToString:@"ViewSpecialTests"])
		{
			sectionName = @"Special";
		}
		
		NSString* path = [[NSBundle mainBundle] pathForResource:@"Licenses" ofType:@"plist"];
		
		NSDictionary* allLicenses = [NSDictionary dictionaryWithContentsOfFile:path];
		
		if( sectionName == nil )
			[((VCGridOfImagesViewController*)segue.destinationViewController)  displayAllSectionsFromDictionary:allLicenses];
		else
		{
			[((VCGridOfImagesViewController*)segue.destinationViewController) displayOneSectionNamed:sectionName fromDictionary:[allLicenses objectForKey:sectionName]];
		}
	}
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	[self performSegueWithIdentifier:@"ViewURL" sender:self];
	
	return TRUE;
}

@end
