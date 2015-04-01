#import "VCGridOfImagesViewController.h"

#import "SampleFileInfo.h"
#import "DetailViewController.h"
@interface VCGridOfImagesViewController ()
@property(nonatomic,retain) NSMutableArray* sectionNames;
@property(nonatomic,retain) NSMutableDictionary* itemArraysBySectionName;
@end

@implementation VCGridOfImagesViewController

-(void) displayAllSectionsFromDictionary:(NSDictionary*) inputDictionary
{
	self.itemArraysBySectionName = [NSMutableDictionary dictionary];
	self.sectionNames = [NSMutableArray array];
	for( NSString* key in inputDictionary )
	{
		[self.sectionNames addObject:key];
		
		NSDictionary* licensesInSection = [inputDictionary objectForKey:key];
		if( licensesInSection != nil )
		{
			NSMutableArray* temp = [NSMutableArray array];
			for( NSString* subkey in licensesInSection )
			{
				NSDictionary* license = [licensesInSection objectForKey:subkey];
				SampleFileInfo* info = [SampleFileInfo sampleFileInfoWithFilename:subkey source:[NSURL URLWithString:[license objectForKey:@"Source URL"]]];
				[temp addObject:info];
			}
			
			[self.itemArraysBySectionName setObject:temp forKey:key];
		}
	}
}

-(void) displayOneSectionNamed:(NSString*) sectionName fromDictionary:(NSDictionary*) licensesInSection
{
	self.itemArraysBySectionName = [NSMutableDictionary dictionary];
	self.sectionNames = [NSMutableArray arrayWithArray:@[sectionName]];
	
	NSMutableArray* temp = [NSMutableArray array];
	for( NSString* subkey in licensesInSection )
	{
		NSDictionary* license = [licensesInSection objectForKey:subkey];
		SampleFileInfo* info = [SampleFileInfo sampleFileInfoWithFilename:subkey source:[NSURL URLWithString:[license objectForKey:@"Source URL"]]];
		[temp addObject:info];
	}
	
	[self.itemArraysBySectionName setObject:temp forKey:sectionName];
	self.title = sectionName;
}

-(void)viewDidLoad
{
	if( self.sectionNames == nil
	|| self.itemArraysBySectionName == nil )
	{
		NSLog(@"Probable mistake; you should call displayOneSectionNamed:fromDictionary: or displayAllSectionsFromDictionary: before displaying this class");
		
		NSString* path = [[NSBundle mainBundle] pathForResource:@"Licenses" ofType:@"plist"];
		
		NSDictionary* allLicenses = [NSDictionary dictionaryWithContentsOfFile:path];
		[self displayAllSectionsFromDictionary:allLicenses];
	}
}

-(NSArray*) sectionAtIndex:(NSInteger) index
{
	NSString* sectionName = [self.sectionNames objectAtIndex:index];
	NSArray* section = [self.itemArraysBySectionName objectForKey:sectionName];
	return section;
}

-(SampleFileInfo*) itemAtIndexPath:(NSIndexPath*) indexPath
{
	NSArray* section = [self sectionAtIndex:indexPath.section];
	SampleFileInfo* item = [section objectAtIndex:indexPath.row];
	return item;
}

#pragma mark - UICollectionView

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	UICollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
	
	SampleFileInfo* item = [self itemAtIndexPath:indexPath];
	
	UILabel* l = (UILabel*) [cell viewWithTag:1];
	l.text = item.filename;
	
	UIImageView* iv = (UIImageView*) [cell viewWithTag:2];
	NSString* filenameNoExtension = [item.filename stringByDeletingPathExtension];
	UIImage* savedImage = [UIImage imageNamed:filenameNoExtension];
	if( savedImage != nil )
	{
		iv.image = savedImage;
	}
	else
		iv.image = nil;
	
	return cell;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
	return [self.sectionNames count];
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	return [self sectionAtIndex:section].count;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	//SampleFileInfo* item = [self itemAtIndexPath:indexPath];
	
	[self performSegueWithIdentifier:@"ViewSVG" sender:nil];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if( [segue.destinationViewController isKindOfClass:[DetailViewController class]])
	{
		DetailViewController* nextVC = (DetailViewController*) segue.destinationViewController;
		
		SampleFileInfo* item = [self itemAtIndexPath:[self.collectionView indexPathsForSelectedItems][0]];
		nextVC.detailItem = item.filename;
	}
}

@end
