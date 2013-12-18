#import "SVGElementInstance.h"
#import "SVGElementInstance_Mutable.h"

#import "SVGElementInstanceList_Internal.h"

@implementation SVGElementInstance

@synthesize correspondingElement;
@synthesize correspondingUseElement;
@synthesize parentNode;
@synthesize childNodes;

- (void)dealloc {
    self.parentNode = nil;
    self.childNodes = nil;
    self.correspondingElement = nil;
    self.correspondingUseElement = nil;
    [super dealloc];
}

-(void)setParentNode:(SVGElementInstance *)newParentNode
{
	if( newParentNode != self.parentNode )
	{
		if( newParentNode == nil )
		{
			/* additionally remove self from parent's childNodes */
			[self.parentNode.childNodes.internalArray removeObject:self];
			
			[parentNode release];
			parentNode = newParentNode;
		}
		else
		{
			/* additionally ADD self to parent's childNodes */
			parentNode = newParentNode;
			[parentNode retain];
			
			NSAssert( NSNotFound != [self.parentNode.childNodes.internalArray indexOfObject:self], @"Found that I was already a child of the node that I was being added to - should be impossible!" );
			
			[self.parentNode.childNodes.internalArray addObject:self];
		}
	}
}

-(SVGElementInstance *)firstChild
{
	if( [self.childNodes length] < 1 )
		return nil;
	else
		return [self.childNodes item:0];
}

-(SVGElementInstance *)lastChild
{
	if( [self.childNodes length] < 1 )
		return nil;
	else
		return [self.childNodes item: [self.childNodes length] - 1];
}

-(SVGElementInstance *)previousSibling
{
	if( self.parentNode == nil )
		return nil;
	else
	{
		NSInteger indexInParent = [self.parentNode.childNodes.internalArray indexOfObject:self];
		
		if( indexInParent < 1 )
			return nil;
		else
			return [self.parentNode.childNodes item:indexInParent-1];
	}
}

-(SVGElementInstance *)nextSibling
{
	if( self.parentNode == nil )
		return nil;
	else
	{
		NSInteger indexInParent = [self.parentNode.childNodes.internalArray indexOfObject:self];
		
		if( indexInParent >= [self.parentNode.childNodes length] )
			return nil;
		else
			return [self.parentNode.childNodes item:indexInParent + 1];
	}
}

@end
