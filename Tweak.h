#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "ZipArchive/SSZipArchive/SSZipArchive.h"

#define kUnicodeCompactColon @"\u2236"
#define kUnicodeDivisionSlash @"\u2215"
#define TLog(fmt, ...) NSLog((@"[ReaderSonyDumper] " fmt), ##__VA_ARGS__)

@interface ContentExtractor : NSObject {
@private
    NSString *_contentPath;
    void *_extractor;
    NSString *_opfFilePath;
    NSString *_opfXml;
    NSLock *_lock;
}

- (instancetype)initWithContentPath:(NSString *)contentPath;
- (void)dealloc;
- (void)close;

- (NSData *)getDataWithFilePath:(NSString *)filePath;
- (NSUInteger)getDataSizeWithFilePath:(NSString *)filePath;
- (NSDictionary<NSString *, NSNumber *> *)getFileSizeList;

- (NSString *)getOpf;
- (NSString *)getOpfFilePath;
- (NSString *)getText:(NSString *)filePath;
- (NSData *)getData:(NSString *)filePath;

@end

@interface MetaParser : NSObject {
@private
    void *_parser;
    ContentExtractor *_extractor;
    NSString *_currentContentPath;
    NSString *_opfFilePath;
    NSString *_opfXml;
    BOOL _isFixed;
    BOOL _isRtL;
    BOOL _isWebtoonEnabled;
    NSString *_renditionOrientation;
    NSString *_renditionSpread;
    int _totalPageCount;
}

@property (readonly) NSUInteger hash;
@property (readonly) Class superclass;
@property (nonatomic, copy, readonly) NSString *description;
@property (nonatomic, copy, readonly) NSString *debugDescription;

+ (instancetype)sharedInstance;

- (instancetype)init;

- (void)setContentPath:(NSString *)contentPath;

- (void)parser:(NSXMLParser *)parser
didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
    attributes:(NSDictionary<NSString *, NSString *> *)attributeDict;

- (void)closeBook;
- (void)dealloc;

- (NSInteger)getElementCount;
- (NSArray *)getElementsWithName:(NSString *)name;
- (id)getElementWithName:(NSString *)name;
- (NSString *)getElementValueWithName:(NSString *)name;
- (id)createElement:(id)element;
- (id)getElementByIndex:(NSInteger)index;
- (NSArray *)getElementsAll;

- (BOOL)isReflow;
- (BOOL)isFixed;
- (BOOL)isLtR;
- (BOOL)isRtL;
- (BOOL)isWebtoonEnabled;
- (BOOL)isScrolled;

- (NSString *)getRenditionOrientation;
- (NSString *)getRenditionSpread;

- (NSString *)getTitle;
- (NSString *)getAuthor;
- (id)getCoverImage;

- (int)getTotalPageCount;

- (id)processWebtoonCoverImageData:(NSData *)data;

- (NSString *)getOpf;
- (NSString *)getOpf:(id)arg;
- (NSString *)getOpfFilePath;

- (NSString *)getText:(NSString *)path;
- (NSData *)getData:(NSString *)path;

@end

@interface HomeNavigationController : UINavigationController
@end


@interface SRContentSelectionViewController : UITableViewController

@property (nonatomic, assign) BOOL isAllSelected;
@property (nonatomic, assign) BOOL isPopOverFromSearchScreen;
@property (nonatomic, assign) NSInteger isNoneSelected;

- (instancetype)initWithStyle:(UITableViewStyle)style;

- (void)viewDidLoad;
- (void)closePopover;

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@class Collection_Book;

@interface Books : NSManagedObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *sort_title;
@property (nonatomic, strong) NSString *groupfield;
@property (nonatomic, strong) NSNumber *grouprank;
@property (nonatomic, strong) NSString *author;
@property (nonatomic, strong) NSString *sort_author;
@property (nonatomic, strong) NSNumber *created;
@property (nonatomic, strong) NSNumber *modified;
@property (nonatomic, strong) NSString *bookid;
@property (nonatomic, strong) NSData *currentpos;
@property (nonatomic, strong) NSNumber *readlevel;
@property (nonatomic, strong) NSNumber *currentpage;
@property (nonatomic, strong) NSNumber *totalpage;
@property (nonatomic, strong) NSString *shortdesc;
@property (nonatomic, strong) NSString *bookstate;
@property (nonatomic, strong) NSString *contenturl;
@property (nonatomic, strong) NSString *thumbnailurl;
@property (nonatomic, strong) NSString *webdetail;
@property (nonatomic, strong) NSData *networkpos;
@property (nonatomic, strong) NSString *extstorage;
@property (nonatomic, strong) NSString *entitlementbookid;
@property (nonatomic, strong) NSNumber *purchasetime;
@property (nonatomic, strong) NSNumber *readingtime;
@property (nonatomic, strong) NSString *favourite;
@property (nonatomic, strong) NSNumber *marked;
@property (nonatomic, strong) NSString *markup_synctime;
@property (nonatomic, strong) NSString *markups;
@property (nonatomic, strong) NSString *purchasedcontent;
@property (nonatomic, strong) NSString *filesize;
@property (nonatomic, strong) NSNumber *user_prefs;
@property (nonatomic, strong) NSString *book_type;
@property (nonatomic, strong) NSString *original_book_type;
@property (nonatomic, strong) NSString *isarchivebook;
@property (nonatomic, strong) NSString *content_owner;
@property (nonatomic, strong) NSString *epubversion;
@property (nonatomic, strong) NSString *sync_id;
@property (nonatomic, strong) NSString *format;
@property (nonatomic, strong) NSString *sonypublicationNameID;
@property (nonatomic, strong) NSString *prismpublicationName;
@property (nonatomic, strong) NSString *publisher;
@property (nonatomic, strong) NSString *sony_episodeSortKey;
@property (nonatomic, strong) NSString *title_sorter;
@property (nonatomic, strong) NSString *author_sorter;
@property (nonatomic, strong) NSString *priceIncludeTax;
@property (nonatomic, strong) NSString *link_webpreview_href;
@property (nonatomic, strong) NSString *publication_sorter;
@property (nonatomic, strong) NSString *language;
@property (nonatomic, strong) NSString *subject;
@property (nonatomic, strong) NSString *genre;
@property (nonatomic, strong) NSString *genre_sorter;
@property (nonatomic, strong) NSString *accrual_method;
@property (nonatomic, strong) NSString *enhanced_content;
@property (nonatomic, strong) NSString *authors_all;
@property (nonatomic, strong) NSString *authors_all_sorter;
@property (nonatomic, strong) NSString *last_page_cfi;
@property (nonatomic, strong) NSString *last_audio_cfi;
@property (nonatomic, strong) NSNumber *last_spine_index;
@property (nonatomic, strong) NSNumber *distribution_period_start;
@property (nonatomic, strong) NSNumber *distribution_period_end;
@property (nonatomic, strong) NSNumber *reading_period_start;
@property (nonatomic, strong) NSNumber *reading_period_end;
@property (nonatomic, strong) NSString *awards_all;
@property (nonatomic, strong) NSString *display_status;
@property (nonatomic, strong) NSNumber *file_lastmodified;
@property (nonatomic, strong) NSString *reading_devicename;
@property (nonatomic, strong) NSNumber *entry_updated;
@property (nonatomic, strong) NSString *webrelated;
@property (nonatomic, strong) NSString *webstreaming;
@property (nonatomic, strong) Collection_Book *collection_book;

- (void)awakeFromInsert;

- (id)dumpUserPrefs;

- (id)get_userpref_book_read_lr;
- (void)set_userpref_book_read_lr:(id)value;

- (id)get_userpref_page_landscape;
- (void)set_userpref_page_landscape:(id)value;

- (id)get_userpref_page_shift;
- (void)set_userpref_page_shift:(id)value;

- (id)get_userpref_page_portrait;
- (void)set_userpref_page_portrait:(id)value;

- (void)updateBookSorter;
- (NSString *)bookFullPath;

- (BOOL)hasReadingPeriod;
- (BOOL)isBookExpired;

- (id)getSeriesOrder;

@end

@interface ContentsListViewController : UIViewController
- (NSArray<Books *>*)getSelectedItems;
@end

@interface ContentSwitchController : UIViewController {
    ContentsListViewController* curContentsListCtl;
    ContentsListViewController* nextContentsListCtl;
}
@end

@interface ExportManager : 	NSObject <UIDocumentPickerDelegate>
@property (nonatomic, strong) NSString *currentTempDir;
@property (nonatomic, strong) UIWindow *floatingWindow;
@property (atomic, assign) BOOL canceled;
+ (instancetype)shared;
+ (id)getRootViewController;
+ (id)getKeyWindow;
- (void)showExtractionAlert:(NSUInteger)bookCount;
- (void)showFailedAlert;
- (NSString *)extractBook:(Books *)bookData totalProgress:(float)totalProgress singlePercent:(float)singlePercent;
- (void)startDumpWithBooks:(NSArray<Books *>*)books;
- (void)presentFolderPickerWithTempDir;
@end

@interface ExtractionUIHandler : NSObject
@property (nonatomic, strong) UIView *overlayView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UIProgressView *subProgressView;
@property (nonatomic, strong) UILabel *subStatusLabel;

+ (instancetype)sharedHandler;
- (void)showOverlayAndStartTask;
- (void)dismissAndReset;
@end