#import <UIKit/UIKit.h>

@interface VCGridOfImagesViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource>

@property(nonatomic,retain) IBOutlet UICollectionView* collectionView;

-(void) displayAllSectionsFromDictionary:(NSDictionary*) inputDictionary;
-(void) displayOneSectionNamed:(NSString*) sectionName fromDictionary:(NSDictionary*) licensesInSection;

@end
