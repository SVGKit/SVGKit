#import "VCAllSpecImages.h"

#import "DetailViewController.h"
#import "SVGKSourceLocalFile.h"

@interface VCAllSpecImages ()
@property(nonatomic,strong) NSString* xcodeVirtualFolderPath;
@property(nonatomic,strong) NSMutableArray* svgFileNames;
@end

@implementation VCAllSpecImages

-(void)viewDidLoad
{
	[super viewDidLoad];
	
	if( self.svgFileNames == nil )
	{	
		NSError *error = nil;
		
		self.xcodeVirtualFolderPath = [[[NSBundle mainBundle] resourcePath]
									stringByAppendingPathComponent:self.pathInBundleToSVGSpecTestSuiteFolder];
		
		NSArray  *xcodeVirtualFolderSVGContents = [[NSFileManager defaultManager] 
										contentsOfDirectoryAtPath:[self.xcodeVirtualFolderPath stringByAppendingPathComponent:@"svg"] error:&error];
		
		self.svgFileNames = [NSMutableArray arrayWithArray: xcodeVirtualFolderSVGContents];
	}
}

-(NSArray*) sectionAtIndex:(NSInteger) index
{
	return self.svgFileNames;
}

-(NSString*) filenameAtIndexPath:(NSIndexPath*) indexPath
{
	NSArray* section = [self sectionAtIndex:indexPath.section];
	NSString* item = [section objectAtIndex:indexPath.row];
	return item;
}

#pragma mark - UICollectionView

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	UICollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
	
	NSString* filename = [self filenameAtIndexPath:indexPath];
	
	UILabel* l = (UILabel*) [cell viewWithTag:1];
	l.text = filename;
	
	UIImageView* iv = (UIImageView*) [cell viewWithTag:2];
	/** Xcode 3, 4, 5 and even version 6 -- all SUCK. "Groups", "Folders", and "Folder References" are all STILL broken by default 
	 
	 Spec adds hundreds of files, and Xcode deletes the folders. So must use folder-references. But Apple folder-references STILL break Apple's UIImage, so we have to specify manual path.
	 */ 
	NSString* fullPathImageFileName = [[self.xcodeVirtualFolderPath stringByAppendingPathComponent:@"png"] stringByAppendingPathComponent:filename];
	
	UIImage* savedImage = [UIImage imageNamed: [fullPathImageFileName stringByDeletingPathExtension]];
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
	return 1;
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
		
		NSString* filename = [self filenameAtIndexPath:[self.collectionView indexPathsForSelectedItems][0]];
		nextVC.detailItem = [SVGKSourceLocalFile sourceFromFilename:[[self.xcodeVirtualFolderPath stringByAppendingPathComponent:@"svg"] stringByAppendingPathComponent:filename]];
	}
}

@end

