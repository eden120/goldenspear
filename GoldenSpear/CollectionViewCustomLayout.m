//
//  CollectionViewCustomLayout.m
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 22/06/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "CollectionViewCustomLayout.h"
#import "CollectionViewDecorationReusableView.h"

#import "tgmath.h"

#define ADNUM 5

NSString *const CollectionViewCustomLayoutElementKindTopDecorationView = @"CollectionViewCustomLayoutElementKindTopDecorationView";
NSString *const CollectionViewCustomLayoutElementKindSectionHeader = @"CollectionViewCustomLayoutElementKindSectionHeader";
NSString *const CollectionViewCustomLayoutElementKindSectionFooter = @"CollectionViewCustomLayoutElementKindSectionFooter";

@interface CollectionViewCustomLayout ()
/// The delegate will point to collection view's delegate automatically.
@property (nonatomic, weak) id <UICollectionViewDelegateCustomLayout> delegate;
/// Array to store height for each column
@property (nonatomic, strong) NSMutableArray *columnHeights;
/// Array of arrays. Each array stores item attributes for each section
@property (nonatomic, strong) NSMutableArray *sectionItemAttributes;
/// Array to store attributes for all items includes headers, cells, and footers
@property (nonatomic, strong) NSMutableArray *allItemAttributes;
/// Dictionary to store decoration view's attribute
@property (nonatomic, strong) NSMutableDictionary *decorationAttribute;
/// Dictionary to store section headers' attribute
@property (nonatomic, strong) NSMutableDictionary *headersAttribute;
/// Dictionary to store section footers' attribute
@property (nonatomic, strong) NSMutableDictionary *footersAttribute;
/// Array to store union rectangles
@property (nonatomic, strong) NSMutableArray *unionRects;
@end

@implementation CollectionViewCustomLayout

/// How many items to be union into a single rectangle
static const NSInteger unionSize = 20;

static CGFloat FloorCGFloat(CGFloat value) {
    CGFloat scale = [UIScreen mainScreen].scale;
    return floor(value * scale) / scale;
}


#pragma mark - Public Accessors


- (void)setForceEqualHeights:(BOOL)forceEqualHeights{
    if (_forceEqualHeights != forceEqualHeights) {
        _forceEqualHeights = forceEqualHeights;
        [self invalidateLayout];
    }
}

- (void)setForceStagging:(BOOL)forceStagging{
    if (_forceStagging != forceStagging) {
        _forceStagging = forceStagging;
        [self invalidateLayout];
    }
}

- (void)setNumberOfColumns:(NSInteger)numberOfColumns{
    if (_numberOfColumns != numberOfColumns) {
        _numberOfColumns = numberOfColumns;
        [self invalidateLayout];
    }
}

- (void)setMinimumHorizontalSpacing:(CGFloat)minimumHorizontalSpacing{
    if (_minimumHorizontalSpacing != minimumHorizontalSpacing) {
        _minimumHorizontalSpacing = minimumHorizontalSpacing;
        [self invalidateLayout];
    }
}

- (void)setMinimumVerticalSpacing:(CGFloat)minimumVerticalSpacing{
    if (_minimumVerticalSpacing != minimumVerticalSpacing) {
        _minimumVerticalSpacing = minimumVerticalSpacing;
        [self invalidateLayout];
    }
}

- (void)setHeaderHeight:(CGFloat)headerHeight {
    if (_headerHeight != headerHeight) {
        _headerHeight = headerHeight;
        [self invalidateLayout];
    }
}

- (void)setFooterHeight:(CGFloat)footerHeight {
    if (_footerHeight != footerHeight) {
        _footerHeight = footerHeight;
        [self invalidateLayout];
    }
}

- (void)setHeaderInset:(UIEdgeInsets)headerInset {
    if (!UIEdgeInsetsEqualToEdgeInsets(_headerInset, headerInset)) {
        _headerInset = headerInset;
        [self invalidateLayout];
    }
}

- (void)setFooterInset:(UIEdgeInsets)footerInset {
    if (!UIEdgeInsetsEqualToEdgeInsets(_footerInset, footerInset)) {
        _footerInset = footerInset;
        [self invalidateLayout];
    }
}

- (void)setSectionInset:(UIEdgeInsets)sectionInset {
    if (!UIEdgeInsetsEqualToEdgeInsets(_sectionInset, sectionInset)) {
        _sectionInset = sectionInset;
        [self invalidateLayout];
    }
}

- (void)setItemRenderDirection:(CollectionViewCustomLayoutItemRenderDirection)itemRenderDirection {
    if (_itemRenderDirection != itemRenderDirection) {
        _itemRenderDirection = itemRenderDirection;
        [self invalidateLayout];
    }
}

- (NSInteger)numberOfColumnsForSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:numberOfColumnsForSection:)]) {
        return [self.delegate collectionView:self.collectionView layout:self numberOfColumnsForSection:section];
    } else {
        return self.numberOfColumns;
    }
}

- (CGFloat)itemWidthInSectionAtIndex:(NSInteger)section {
    UIEdgeInsets sectionInset;
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:)]) {
        sectionInset = [self.delegate collectionView:self.collectionView layout:self insetForSectionAtIndex:section];
    } else {
        sectionInset = self.sectionInset;
    }
    CGFloat width = self.collectionView.bounds.size.width - sectionInset.left - sectionInset.right;
    NSInteger numberOfColumns = [self numberOfColumnsForSection:section];
    
    CGFloat horizontalSpacing = self.minimumHorizontalSpacing;
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:minimumHorizontalSpacingForSectionAtIndex:)]) {
        horizontalSpacing = [self.delegate collectionView:self.collectionView layout:self minimumHorizontalSpacingForSectionAtIndex:section];
    }
    
    return FloorCGFloat((width - (numberOfColumns - 1) * horizontalSpacing) / numberOfColumns);
}

#pragma mark - Private Accessors

- (NSMutableDictionary *)decorationAttribute {
    if (!_decorationAttribute) {
        _decorationAttribute = [NSMutableDictionary dictionary];
    }
    return _decorationAttribute;
}

- (NSMutableDictionary *)headersAttribute {
    if (!_headersAttribute) {
        _headersAttribute = [NSMutableDictionary dictionary];
    }
    return _headersAttribute;
}

- (NSMutableDictionary *)footersAttribute {
    if (!_footersAttribute) {
        _footersAttribute = [NSMutableDictionary dictionary];
    }
    return _footersAttribute;
}

- (NSMutableArray *)unionRects {
    if (!_unionRects) {
        _unionRects = [NSMutableArray array];
    }
    return _unionRects;
}

- (NSMutableArray *)columnHeights {
    if (!_columnHeights) {
        _columnHeights = [NSMutableArray array];
    }
    return _columnHeights;
}

- (NSMutableArray *)allItemAttributes {
    if (!_allItemAttributes) {
        _allItemAttributes = [NSMutableArray array];
    }
    return _allItemAttributes;
}

- (NSMutableArray *)sectionItemAttributes {
    if (!_sectionItemAttributes) {
        _sectionItemAttributes = [NSMutableArray array];
    }
    return _sectionItemAttributes;
}

- (id <UICollectionViewDelegateCustomLayout> )delegate {
    return (id <UICollectionViewDelegateCustomLayout> )self.collectionView.delegate;
}

#pragma mark - Init
- (void)commonInit {
    _forceStagging = NO;
    _forceEqualHeights = NO;
    _numberOfColumns = 2;
    _minimumHorizontalSpacing = 10;
    _minimumVerticalSpacing = 10;
    _headerHeight = 0;
    _footerHeight = 0;
    _sectionInset = UIEdgeInsetsZero;
    _headerInset  = UIEdgeInsetsZero;
    _footerInset  = UIEdgeInsetsZero;
    _itemRenderDirection = CollectionViewCustomLayoutItemRenderDirectionShortestFirst;
    
    [self createRandomPercentages];
}

// Create random percentages at load so that they are consistent
- (void)createRandomPercentages
{
    // Create a temporary mutable array that we add objects to
    NSMutableArray *randomPercentages = [NSMutableArray arrayWithCapacity:32];
    
    CGFloat percentage = 0.0f;
    
    for (NSInteger i = 0; i < 32; i++)
    {
        // Ensure that each height is different enough to be seen
        
        CGFloat newPercentage = 0.0f;
        
        // Create a random percentage between -1.1% and 1.1%, at least 0.6% different than the one generated beforehand
        do
        {
            newPercentage = ((CGFloat)(arc4random() % 220) - 10) * 0.002f;
        }
        while (fabs(percentage - newPercentage) < 0.06);
        
        percentage = newPercentage;
        
        // Add it to the temporary array by wrapping it in an NSValue
        [randomPercentages addObject:@(percentage)];
    }
    
    self.randomPercentages = randomPercentages;
}

- (id)init {
    if (self = [super init]) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self commonInit];
    }
    return self;
}

#pragma mark - Methods to Override
- (void)prepareLayout
{
    [super prepareLayout];
    
    [self.decorationAttribute removeAllObjects];
    [self.headersAttribute removeAllObjects];
    [self.footersAttribute removeAllObjects];
    [self.unionRects removeAllObjects];
    [self.columnHeights removeAllObjects];
    [self.allItemAttributes removeAllObjects];
    [self.sectionItemAttributes removeAllObjects];
    
    NSString *celltype = [self.delegate getCellType:self.collectionView];
    
    NSInteger numberOfSections = [self.collectionView numberOfSections];
    
    if (numberOfSections == 0)
    {
        return;
    }
    
    //NSAssert([self.delegate conformsToProtocol:@protocol(UICollectionViewDelegateCustomLayout)], @"UICollectionView's delegate should conform to UICollectionViewDelegateCustomLayout protocol");
    
//    NSAssert([self.delegate respondsToSelector:@selector(collectionView:layout:sizeForItemAtIndexPath:)], @"UICollectionView's delegate must implement sizeForItemAtIndexPath:");
    if(![self.delegate respondsToSelector:@selector(collectionView:layout:sizeForItemAtIndexPath:)])
    {
        NSLog(@"XXXX UICollectionView's delegate must implement sizeForItemAtIndexPath: XXXX");
    }
    
//    NSAssert(self.numberOfColumns > 0 || [self.delegate respondsToSelector:@selector(collectionView:layout:numberOfColumnsForSection:)], @"UICollectionViewWaterfallLayout's numberOfColumns should be greater than 0, or delegate must implement numberOfColumnsForSection:");
    
    if(!(self.numberOfColumns > 0 || [self.delegate respondsToSelector:@selector(collectionView:layout:numberOfColumnsForSection:)]))
    {
        NSLog(@"XXXX UICollectionViewWaterfallLayout's numberOfColumns should be greater than 0, or delegate must implement numberOfColumnsForSection: XXXX");
        
        if(!(self.numberOfColumns > 0))
        {
            self.numberOfColumns = 2;
        }
    }

    // Initialize variables
    NSInteger idx = 0;
    
    for (NSInteger section = 0; section < numberOfSections; section++) {
        NSInteger numberOfColumns = [self numberOfColumnsForSection:section];
        NSMutableArray *sectionColumnHeights = [NSMutableArray arrayWithCapacity:numberOfColumns];
        for (idx = 0; idx < numberOfColumns; idx++) {
            [sectionColumnHeights addObject:@(0)];
        }
        [self.columnHeights addObject:sectionColumnHeights];
    }
    // Create attributes
    CGFloat top = 0;
    UICollectionViewLayoutAttributes *attributes;
    
    BOOL bShouldShowDecoration;
    
    if ([self.delegate respondsToSelector:@selector(shouldShowDecorationInCollectionView:layout:)])
    {
        bShouldShowDecoration = [self.delegate shouldShowDecorationInCollectionView:self.collectionView layout:self];
    }
    else
    {
        bShouldShowDecoration = NO;
    }
    
    if(bShouldShowDecoration)
    {
        attributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:CollectionViewCustomLayoutElementKindTopDecorationView withIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
        attributes.frame = [self frameForDecorationView];
        self.decorationAttribute[@(0)] = attributes;
        [self.allItemAttributes addObject:attributes];
    }
    
    for (NSInteger section = 0; section < numberOfSections; ++section) {
        /*
         * 1. Get section-specific metrics (minimumVerticalSpacing, sectionInset)
         */
        CGFloat minimumVerticalSpacing;
        if ([self.delegate respondsToSelector:@selector(collectionView:layout:minimumVerticalSpacingForSectionAtIndex:)]) {
            minimumVerticalSpacing = [self.delegate collectionView:self.collectionView layout:self minimumVerticalSpacingForSectionAtIndex:section];
        } else {
            minimumVerticalSpacing = self.minimumVerticalSpacing;
        }
        
        CGFloat horizontalSpacing = self.minimumHorizontalSpacing;
        if ([self.delegate respondsToSelector:@selector(collectionView:layout:minimumHorizontalSpacingForSectionAtIndex:)]) {
            horizontalSpacing = [self.delegate collectionView:self.collectionView layout:self minimumHorizontalSpacingForSectionAtIndex:section];
        }
        
        UIEdgeInsets sectionInset;
        if ([self.delegate respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:)]) {
            sectionInset = [self.delegate collectionView:self.collectionView layout:self insetForSectionAtIndex:section];
        } else {
            sectionInset = self.sectionInset;
        }
        
        CGFloat width = self.collectionView.bounds.size.width - sectionInset.left - sectionInset.right;
        NSInteger numberOfColumns = [self numberOfColumnsForSection:section];
        CGFloat itemWidth = FloorCGFloat((width - (numberOfColumns - 1) * horizontalSpacing) / numberOfColumns);
        
        /*
         * 2. Section header
         */
        CGFloat headerHeight;
        if ([self.delegate respondsToSelector:@selector(collectionView:layout:heightForHeaderInSection:)]) {
            headerHeight = [self.delegate collectionView:self.collectionView layout:self heightForHeaderInSection:section];
        } else {
            headerHeight = self.headerHeight;
        }
        
        UIEdgeInsets headerInset;
        
        if(headerHeight > 0)
        {
            if ([self.delegate respondsToSelector:@selector(collectionView:layout:insetForHeaderInSection:)]) {
                headerInset = [self.delegate collectionView:self.collectionView layout:self insetForHeaderInSection:section];
            } else {
                headerInset = self.headerInset;
            }
        }
        else
        {
            headerInset  = UIEdgeInsetsZero;
        }
        
        top += headerInset.top;
        
        if (headerHeight > 0) {
            attributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:CollectionViewCustomLayoutElementKindSectionHeader withIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
            attributes.frame = CGRectMake(headerInset.left,
                                          top,
                                          self.collectionView.bounds.size.width - (headerInset.left + headerInset.right),
                                          headerHeight);
            
            self.headersAttribute[@(section)] = attributes;
            [self.allItemAttributes addObject:attributes];
            
            top = CGRectGetMaxY(attributes.frame) + headerInset.bottom;
        }
        
        if([self.collectionView numberOfItemsInSection:section] > 0)
        {
            top += sectionInset.top;
        }
        
        for (idx = 0; idx < numberOfColumns; idx++) {
            self.columnHeights[section][idx] = @(top);
        }
        
        /*
         * 3. Section items
         */
        NSInteger itemCount = [self.collectionView numberOfItemsInSection:section];
        
        NSInteger adCount = (itemCount % ADNUM == ADNUM - 1)? (itemCount / ADNUM) : (itemCount / ADNUM) + 1;
        
        NSInteger adNum;
        if ([celltype isEqualToString:@"ResultCell"]) {
            adNum = [self.delegate getAdNums:self.collectionView];
        }
        
        adNum = (adNum < adCount) ? adNum : adCount;
        
        NSMutableArray *itemAttributes = [NSMutableArray arrayWithCapacity:itemCount];
        
        // Item will be put into shortest column.
        if ([celltype isEqualToString:@"ResultCell"]) {
            for (idx = 0; idx < itemCount; idx++) {
                CGFloat xOffset;
                CGFloat yOffset;
                NSInteger index = idx / ADNUM;
                if (!(index < adNum)) {
                    index = adNum;
                }
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:idx inSection:section];
                NSUInteger columnIndex = (idx - index) % 2;
                
                if (idx % ADNUM == ADNUM - 1) {
                    if (idx / ADNUM < adNum) {
                        columnIndex = 0;
                    }
                }
                xOffset = sectionInset.left + (itemWidth + horizontalSpacing) * columnIndex;
                yOffset = [self.columnHeights[section][columnIndex] floatValue];
                // Since we took out the NSAssert, had to check thay the delegate responds ot the proper selection. Otherwise, set an arbitrary itemSize
                CGSize itemSize = (([self.delegate respondsToSelector:@selector(collectionView:layout:sizeForItemAtIndexPath:)]) ? ([self.delegate collectionView:self.collectionView layout:self sizeForItemAtIndexPath:indexPath]) : (CGSizeMake([self itemWidthInSectionAtIndex:1], ([self itemWidthInSectionAtIndex:1]/2))));
                CGFloat itemHeight = 0;
                if (itemSize.height > 0 && itemSize.width > 0) {
                    itemHeight = FloorCGFloat(itemSize.height * itemWidth / itemSize.width);
                }
                
//                if (idx % ADNUM == 1 && idx > ADNUM) {
//                    if (!(idx / ADNUM > adNum)) {
//                        yOffset = yOffset + itemHeight + minimumVerticalSpacing;
//                    }
//                }
                attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
                attributes.frame = CGRectMake(xOffset, yOffset, itemWidth, itemHeight);
                if (idx % ADNUM == ADNUM - 1) {
                    if (idx / ADNUM < adNum) {
                        CGRect frame = attributes.frame;
                        frame.size.width = frame.size.width * 2 + horizontalSpacing;
                        frame.size.height = itemSize.height;
                        attributes.frame = frame;
                    }
                }
                [itemAttributes addObject:attributes];
                [self.allItemAttributes addObject:attributes];
                self.columnHeights[section][columnIndex] = @(CGRectGetMaxY(attributes.frame) + minimumVerticalSpacing);
                if (idx % ADNUM == ADNUM - 1) {
                    if (idx / ADNUM < adNum) {
                        self.columnHeights[section][columnIndex + 1] = @(CGRectGetMaxY(attributes.frame) + minimumVerticalSpacing);
                    }
                }
            }
        }
        else {
            for (idx = 0; idx < itemCount; idx++) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:idx inSection:section];
                NSUInteger columnIndex = [self nextColumnIndexForItem:idx inSection:section];
                CGFloat xOffset = sectionInset.left + (itemWidth + horizontalSpacing) * columnIndex;
                CGFloat yOffset = [self.columnHeights[section][columnIndex] floatValue];
                // Since we took out the NSAssert, had to check thay the delegate responds ot the proper selection. Otherwise, set an arbitrary itemSize
                CGSize itemSize = (([self.delegate respondsToSelector:@selector(collectionView:layout:sizeForItemAtIndexPath:)]) ? ([self.delegate collectionView:self.collectionView layout:self sizeForItemAtIndexPath:indexPath]) : (CGSizeMake([self itemWidthInSectionAtIndex:1], ([self itemWidthInSectionAtIndex:1]/2))));
                CGFloat itemHeight = 0;
                if (itemSize.height > 0 && itemSize.width > 0) {
                    itemHeight = FloorCGFloat(itemSize.height * itemWidth / itemSize.width);
                }
                
                attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
                attributes.frame = CGRectMake(xOffset, yOffset, itemWidth, itemHeight);
                [itemAttributes addObject:attributes];
                [self.allItemAttributes addObject:attributes];
                self.columnHeights[section][columnIndex] = @(CGRectGetMaxY(attributes.frame) + minimumVerticalSpacing);
            }

        }
        
        [self.sectionItemAttributes addObject:itemAttributes];
        
        /*
         * 4. Section footer
         */
        CGFloat footerHeight;
        NSUInteger columnIndex = [self longestColumnIndexInSection:section];
        top = [self.columnHeights[section][columnIndex] floatValue] - minimumVerticalSpacing + sectionInset.bottom;
        
        if ([self.delegate respondsToSelector:@selector(collectionView:layout:heightForFooterInSection:)]) {
            footerHeight = [self.delegate collectionView:self.collectionView layout:self heightForFooterInSection:section];
        } else {
            footerHeight = self.footerHeight;
        }
        
        UIEdgeInsets footerInset;
        
        if(footerHeight > 0)
        {
            if ([self.delegate respondsToSelector:@selector(collectionView:layout:insetForFooterInSection:)]) {
                footerInset = [self.delegate collectionView:self.collectionView layout:self insetForFooterInSection:section];
            } else {
                footerInset = self.footerInset;
            }
        }
        else
        {
            footerInset  = UIEdgeInsetsZero;
        }
        
        top += footerInset.top;
        
        if (footerHeight > 0) {
            attributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:CollectionViewCustomLayoutElementKindSectionFooter withIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
            attributes.frame = CGRectMake(footerInset.left,
                                          top,
                                          self.collectionView.bounds.size.width - (footerInset.left + footerInset.right),
                                          footerHeight);
            
            self.footersAttribute[@(section)] = attributes;
            [self.allItemAttributes addObject:attributes];
            
            top = CGRectGetMaxY(attributes.frame) + footerInset.bottom;
        }
        
        for (idx = 0; idx < numberOfColumns; idx++) {
            self.columnHeights[section][idx] = @(top);
        }
    } // end of for (NSInteger section = 0; section < numberOfSections; ++section)
    
    // Build union rects
    idx = 0;
    NSInteger itemCounts = [self.allItemAttributes count];
    while (idx < itemCounts) {
        CGRect unionRect = ((UICollectionViewLayoutAttributes *)self.allItemAttributes[idx]).frame;
        NSInteger rectEndIndex = MIN(idx + unionSize, itemCounts);
        
        for (NSInteger i = idx + 1; i < rectEndIndex; i++) {
            unionRect = CGRectUnion(unionRect, ((UICollectionViewLayoutAttributes *)self.allItemAttributes[i]).frame);
        }
        
        idx = rectEndIndex;
        
        [self.unionRects addObject:[NSValue valueWithCGRect:unionRect]];
    }
}

- (CGRect)frameForDecorationView
{
    CGSize size = [CollectionViewDecorationReusableView defaultSize];
    
    CGFloat originX = floorf((self.collectionView.bounds.size.width - size.width) * 0.5f);
    CGFloat originY = -size.height - 30.0f;
    
    BOOL bShouldShowDecoration;

    if ([self.delegate respondsToSelector:@selector(shouldShowDecorationInCollectionView:layout:)])
    {
        bShouldShowDecoration = [self.delegate shouldShowDecorationInCollectionView:self.collectionView layout:self];
    }
    else
    {
        bShouldShowDecoration = NO;
    }

    if(bShouldShowDecoration)
    {
        return CGRectMake(originX, originY, size.width, size.height);
    }
    else
    {
        return CGRectZero;
    }
}

- (CGSize)collectionViewContentSize {
    NSInteger numberOfSections = [self.collectionView numberOfSections];
    if (numberOfSections == 0) {
        return CGSizeZero;
    }
    
    CGSize contentSize = self.collectionView.bounds.size;
    contentSize.height = [[[self.columnHeights lastObject] firstObject] floatValue];
    
    if (contentSize.height < self.minimumContentHeight) {
        contentSize.height = self.minimumContentHeight;
    }
    
    return contentSize;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)path {
    if (path.section >= [self.sectionItemAttributes count]) {
        return nil;
    }
    if (path.item >= [self.sectionItemAttributes[path.section] count]) {
        return nil;
    }
    return (self.sectionItemAttributes[path.section])[path.item];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {

    UICollectionViewLayoutAttributes *attribute = nil;
    
    if ([kind isEqualToString:CollectionViewCustomLayoutElementKindTopDecorationView])
    {
        attribute = self.decorationAttribute[@(0)];
    }
    else if ([kind isEqualToString:CollectionViewCustomLayoutElementKindSectionHeader])
    {
        attribute = self.headersAttribute[@(indexPath.section)];
    }
    else if ([kind isEqualToString:CollectionViewCustomLayoutElementKindSectionFooter])
    {
        attribute = self.footersAttribute[@(indexPath.section)];
    }
    
    return attribute;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSInteger i;
    NSInteger begin = 0, end = self.unionRects.count;
    NSMutableArray *attrs = [NSMutableArray array];
    
    for (i = 0; i < self.unionRects.count; i++) {
        if (CGRectIntersectsRect(rect, [self.unionRects[i] CGRectValue])) {
            begin = i * unionSize;
            break;
        }
    }
    for (i = self.unionRects.count - 1; i >= 0; i--) {
        if (CGRectIntersectsRect(rect, [self.unionRects[i] CGRectValue])) {
            end = MIN((i + 1) * unionSize, self.allItemAttributes.count);
            break;
        }
    }
    for (i = begin; i < end; i++) {
        UICollectionViewLayoutAttributes *attr = self.allItemAttributes[i];
        if (CGRectIntersectsRect(rect, attr.frame)) {
            [attrs addObject:attr];
        }
    }
    
    return [NSArray arrayWithArray:attrs];
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    CGRect oldBounds = self.collectionView.bounds;
    if (CGRectGetWidth(newBounds) != CGRectGetWidth(oldBounds)) {
        return YES;
    }
    return NO;
}

#pragma mark - Private Methods

/**
 *  Find the shortest column.
 *
 *  @return index for the shortest column
 */
- (NSUInteger)shortestColumnIndexInSection:(NSInteger)section {
    __block NSUInteger index = 0;
    __block CGFloat shortestHeight = MAXFLOAT;
    
    [self.columnHeights[section] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CGFloat height = [obj floatValue];
        if (height < shortestHeight) {
            shortestHeight = height;
            index = idx;
        }
    }];
    
    return index;
}

/**
 *  Find the longest column.
 *
 *  @return index for the longest column
 */
- (NSUInteger)longestColumnIndexInSection:(NSInteger)section {
    __block NSUInteger index = 0;
    __block CGFloat longestHeight = 0;
    
    [self.columnHeights[section] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CGFloat height = [obj floatValue];
        if (height > longestHeight) {
            longestHeight = height;
            index = idx;
        }
    }];
    
    return index;
}

/**
 *  Find the index for the next column.
 *
 *  @return index for the next column
 */
- (NSUInteger)nextColumnIndexForItem:(NSInteger)item inSection:(NSInteger)section {
    NSUInteger index = 0;
    NSInteger numberOfColumns = [self numberOfColumnsForSection:section];
    switch (self.itemRenderDirection) {
        case CollectionViewCustomLayoutItemRenderDirectionShortestFirst:
            index = [self shortestColumnIndexInSection:section];
            break;
            
        case CollectionViewCustomLayoutItemRenderDirectionLeftToRight:
            index = (item % numberOfColumns);
            break;
            
        case CollectionViewCustomLayoutItemRenderDirectionRightToLeft:
            index = (numberOfColumns - 1) - (item % numberOfColumns);
            break;
            
        default:
            index = [self shortestColumnIndexInSection:section];
            break;
    }
    return index;
}

@end
