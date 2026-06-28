#import <dlfcn.h>
#import "Tweak.h"

// typedef void (*MSHookMessageEx_t)(Class _class, SEL message, IMP hook, IMP *old);
// static MSHookMessageEx_t MSHookMessageEx_p = NULL;

%config(generator=internal);

@implementation ExtractionUIHandler

+ (instancetype)sharedHandler {
    static ExtractionUIHandler *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ instance = [[self alloc] init]; });
    return instance;
}

- (void)showOverlayAndStartTask {
	UIWindow *window = [ExportManager getKeyWindow];

	// 1. 创建全屏遮罩 (毛玻璃效果)
	UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
	blurEffectView.frame = window.bounds;
	blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.overlayView = blurEffectView;

	UIView *container = blurEffectView.contentView;

	UIStackView *stackView = [[UIStackView alloc] init];
	stackView.axis = UILayoutConstraintAxisVertical;
	stackView.spacing = 10;
	stackView.alignment = UIStackViewAlignmentFill;
	stackView.frame = CGRectMake(50, window.center.y - 75, window.bounds.size.width - 100, 150);

	[container addSubview:stackView];
	stackView.center = container.center;

	// 添加状态标签
	self.statusLabel = [[UILabel alloc] init];
	self.statusLabel.text = @"";
	self.statusLabel.textColor = [UIColor whiteColor];
	self.statusLabel.textAlignment = NSTextAlignmentCenter;
	self.statusLabel.numberOfLines = 3;
	self.statusLabel.font = [UIFont systemFontOfSize:12];
	[stackView addArrangedSubview:self.statusLabel];

	// 添加标题标签
	self.titleLabel = [[UILabel alloc] init];
	self.titleLabel.text = @"Wait for extraction...";
	self.titleLabel.textColor = [UIColor whiteColor];
	self.titleLabel.textAlignment = NSTextAlignmentCenter;
	[stackView addArrangedSubview:self.titleLabel];
    
  // 添加总进度条
	self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
	self.progressView.frame = CGRectMake(50, window.center.y, window.bounds.size.width - 100, 20);
	self.progressView.progress = 0;
	[stackView addArrangedSubview:self.progressView];
    
	// 添加副进度标签
	self.subStatusLabel = [[UILabel alloc] init];
	self.subStatusLabel.text = @"Processing book...";
	self.subStatusLabel.textColor = [UIColor whiteColor];
	self.subStatusLabel.textAlignment = NSTextAlignmentCenter;
	[stackView addArrangedSubview:self.subStatusLabel];

	// 添加副进度条
	self.subProgressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
	self.subProgressView.frame = CGRectMake(50, window.center.y + 30, window.bounds.size.width - 100, 20);
	self.subProgressView.progress = 0;
	[stackView addArrangedSubview:self.subProgressView];
    
	[window addSubview:self.overlayView];
}

- (void)dismissAndReset {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.overlayView) {
            [self.overlayView removeFromSuperview];
            self.overlayView = nil;
        }
        self.titleLabel = nil;
        self.progressView = nil;
        self.statusLabel = nil;
        self.subProgressView = nil;
        self.subStatusLabel = nil;
    });
}
@end

@implementation ExportManager
+ (instancetype)shared {
	static ExportManager *instance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		instance = [[ExportManager alloc] init];
		instance.canceled = NO;
	});
	return instance;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
+ (id)getRootViewController {
    return [UIApplication sharedApplication].keyWindow.rootViewController;
}

+ (id)getKeyWindow {
	return [UIApplication sharedApplication].keyWindow;
}
#pragma clang diagnostic pop

+ (NSString *)replaceIllegalCharacters:(NSString *)string {
    string = [string stringByReplacingOccurrencesOfString:@"/" withString:kUnicodeDivisionSlash];
	return [string stringByReplacingOccurrencesOfString:@":" withString:kUnicodeCompactColon];
}

- (void)showExtractionAlert:(NSUInteger)bookCount {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"ReaderSonyDumper" 
                                                                   message:[NSString stringWithFormat:@"Extract %lu books?", bookCount] 
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        // 阻止抽取流程
        self.canceled = YES;
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[ExtractionUIHandler sharedHandler] showOverlayAndStartTask];
    }]];
    
    [[ExportManager getRootViewController] presentViewController:alert animated:YES completion:nil];
}

- (void)showFailedAlert {
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Extraction Failed!" 
																   message:@"Please check Console.app"
															preferredStyle:UIAlertControllerStyleAlert];
	[alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];

	[[ExportManager getRootViewController] presentViewController:alert animated:YES completion:nil];
}

- (void)showSuccessAlertWithCount:(NSInteger)count {
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Extraction Completed!" 
																   message:[NSString stringWithFormat:@"Successfully extracted %ld book(s)!", (long)count] 
															preferredStyle:UIAlertControllerStyleAlert];
	[alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];

	[[ExportManager getRootViewController] presentViewController:alert animated:YES completion:nil];
}

- (NSString *)extractBook:(Books *)bookData totalProgress:(float)totalProgress singlePercent:(float)singlePercent; {
	NSString *bookDirName = [ExportManager replaceIllegalCharacters:[bookData title]];
	TLog(@"bookDirName: %@, tempdir: %@", bookDirName, self.currentTempDir);
	NSString *zipPath = [self.currentTempDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.zip", bookDirName]];
	if ([@"application/epub+zip" isEqual:[bookData format]]) {
		zipPath = [self.currentTempDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.epub", bookDirName]];
	}
	TLog(@"zipPath: %@", zipPath);

	SSZipArchive *archive = [[SSZipArchive alloc] initWithPath:zipPath];
	BOOL isOpen = [archive open];

	if (!isOpen) {
		TLog(@"Failed to open zip archive: %@", zipPath);
		return nil;
	}

	ContentExtractor* extractor = [[NSClassFromString(@"ContentExtractor") alloc] initWithContentPath:[bookData bookFullPath]];
	NSDictionary<NSString *, NSNumber *> *fileSizeList = [extractor getFileSizeList];
	size_t idx = 0;
	unsigned long int succ_files = 0;
	if ([fileSizeList valueForKey:@"mimetype"] != nil) {
		NSData* data = [extractor getDataWithFilePath:@"mimetype"];
		BOOL write_succ = [archive writeData:data 
									filename:@"mimetype"
									withPassword:nil];
		if (!write_succ) {
			TLog(@"Dump failed on %@, %@", [bookData title], @"mimetype");
		} else {
			succ_files++;
		}
	} else if ([bookData format]) {
		[archive writeData:[[bookData format] dataUsingEncoding:NSASCIIStringEncoding] 
				filename:@"mimetype"
				withPassword:nil];
	}
	for (NSString *filePath in fileSizeList) {
		if ([filePath isEqualToString:@"mimetype"]) continue;
		if ([filePath hasSuffix:@"/"]) continue;
		@autoreleasepool {
			NSData* data = [extractor getDataWithFilePath:filePath];
			BOOL write_succ = [archive writeData:data 
                                       filename:filePath
                                       withPassword:nil];
			if (!write_succ) {
				TLog(@"Dump failed on %@, %@", [bookData title], filePath);
			} else {
				succ_files++;
			}
		}
		dispatch_async(dispatch_get_main_queue(), ^{
			float curr_book_progress = (float)(idx) / fileSizeList.count;
			[ExtractionUIHandler sharedHandler].progressView.progress = totalProgress + curr_book_progress * singlePercent;
			[ExtractionUIHandler sharedHandler].subProgressView.progress = curr_book_progress;
			[ExtractionUIHandler sharedHandler].subStatusLabel.text = [NSString stringWithFormat:@"Extracting: %zu/%lu", idx, fileSizeList.count];
        });
		idx++;
	}
	[extractor close];
  
	BOOL success = [archive close];
	TLog(@"zip archive closed: %d", success);
	if (succ_files) {
		return zipPath;
	} else {
		NSFileManager *fm = [NSFileManager defaultManager];
		NSError *error = nil;
		[fm removeItemAtPath:zipPath error:&error];
		return nil;
	}
}

- (void)startDumpWithBooks:(NSArray<Books *>*)books; {
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		if (books.count > 0) {
			// 询问用户是否开始抽取
			dispatch_async(dispatch_get_main_queue(), ^{
				self.canceled = NO;
				[self showExtractionAlert:books.count];
			});
			// 等待用户响应后继续执行抽取流程
			while ([ExtractionUIHandler sharedHandler].overlayView == nil) {
				[NSThread sleepForTimeInterval:0.1];
				if (self.canceled) {
					TLog(@"User canceled the extraction process.");
					self.canceled = NO; // 重置状态以便下次使用
					return;
				}
			}
		} else {
			return;
		}

		NSFileManager* defaultManager = [NSFileManager defaultManager];
		NSString* cachesPath = [[defaultManager URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] firstObject].path;
		self.currentTempDir = [cachesPath stringByAppendingPathComponent:@"DumpedBooks"];

		[defaultManager removeItemAtPath:self.currentTempDir error:nil];
		[defaultManager createDirectoryAtPath:self.currentTempDir withIntermediateDirectories:YES attributes:nil error:nil];
		TLog(@"Temp Dir: %@", self.currentTempDir);

		dispatch_async(dispatch_get_main_queue(), ^{
			[ExtractionUIHandler sharedHandler].statusLabel.text = [NSString stringWithFormat:@"Found %lu MNH file(s)...", (unsigned long)books.count];
			[ExtractionUIHandler sharedHandler].progressView.progress = 0;
			[ExtractionUIHandler sharedHandler].subProgressView.progress = 0;
			[ExtractionUIHandler sharedHandler].subStatusLabel.text = @"Please wait...";
		});
		TLog(@"Start extraction...");

		bool anySuccess = false;

		for (int idx = 0; idx < books.count; idx++) {
			Books* bookData = [books objectAtIndex:idx];
			TLog(@"Processing Book: %@", [bookData title]);

			dispatch_async(dispatch_get_main_queue(), ^{
				[ExtractionUIHandler sharedHandler].titleLabel.text = [NSString stringWithFormat:@"Processing Book(s) %d/%lu", idx + 1, (unsigned long)books.count];
				[ExtractionUIHandler sharedHandler].statusLabel.text = [NSString stringWithFormat:@"%@", [bookData title]];
			});

			NSString *zipPath = nil;
			@try {
				zipPath = [self extractBook:bookData totalProgress:(float)idx/books.count singlePercent:1.0f/books.count];
			} @catch (NSException *e) {
				TLog(@"Caught Exception inside extract call: %@", e);
				return;
			}

			if (zipPath) {
				TLog(@"Extraction succeeded: %@", zipPath);
				if (!anySuccess) {
					anySuccess = true;
				}
			} else {
				TLog(@"Extraction failed");
			}
			dispatch_async(dispatch_get_main_queue(), ^{
				[ExtractionUIHandler sharedHandler].progressView.progress = (float)(idx + 1) / books.count;
			});
		}

		dispatch_async(dispatch_get_main_queue(), ^{
			[[ExtractionUIHandler sharedHandler] dismissAndReset];
			if (anySuccess) {
				[self presentFolderPickerWithTempDir];
			} else {
				[self showFailedAlert];
			}
		});
	});   
}

- (void)presentFolderPickerWithTempDir {
	NSError *error = nil;
	NSArray<NSURLResourceKey> *keys = @[NSURLIsDirectoryKey];
  NSArray<NSURL *> *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:[NSURL fileURLWithPath:self.currentTempDir]
                                          includingPropertiesForKeys:keys
                                                              options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                error:&error];
    
    if (error) {
        TLog(@"%@", error.localizedDescription);
        return;
    }

    NSMutableArray<NSURL *> *filesToExport = [NSMutableArray array];
    for (NSURL *url in contents) {
        NSNumber *isDirectory = nil;
        [url getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:nil];
        
        if (isDirectory && ![isDirectory boolValue]) {
            [filesToExport addObject:url];
        }
    }

    if (filesToExport.count == 0) {
        TLog(@"No files found in temp directory to export.");
        return;
    }
    
    // 开启文件夹选择模式
    UIDocumentPickerViewController *picker = [[UIDocumentPickerViewController alloc] initForExportingURLs:filesToExport asCopy:NO];
	
    picker.delegate = self;
    picker.allowsMultipleSelection = NO;
    
    // 获取当前最顶层的 ViewController 来弹出
    [[ExportManager getRootViewController] presentViewController:picker animated:YES completion:nil];
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    NSURL *targetFolderURL = urls.firstObject;
	TLog(@"User selected folder: %@", targetFolderURL.path);

	[[NSFileManager defaultManager] removeItemAtPath:self.currentTempDir error:nil];
}

- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller {
    TLog(@"User canceled folder picker.");
    [[NSFileManager defaultManager] removeItemAtPath:self.currentTempDir error:nil];
}
@end

%hook SRContentSelectionViewController
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSInteger originalCount = %orig;
    if (section == 0) {
        return originalCount + 1;
    }
    return originalCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSInteger totalRows = [tableView numberOfRowsInSection:indexPath.section];

	TLog(@"cellForRowAtIndexPath %@", indexPath);
    
    if (indexPath.section == 0 && indexPath.row == totalRows - 1) {
        static NSString *CellIdentifier = @"BookDumpMenuCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        cell.textLabel.text = @"Decrypt Selected";
        cell.textLabel.textColor = [UIColor systemBlueColor];
        
        return cell;
    }
    return %orig;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSInteger totalRows = [tableView numberOfRowsInSection:indexPath.section];

	TLog(@"didSelectRowAtIndexPath %@", indexPath);
    
    if (indexPath.section == 0 && indexPath.row == totalRows - 1) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];

		__block HomeNavigationController *homeNavController = (HomeNavigationController *)[self presentingViewController];
        
        [self dismissViewControllerAnimated:YES completion:^{
            TLog(@"%@", @"Popover row tapped!");
			NSArray* childVCs = [homeNavController childViewControllers];
			TLog(@"%@, %@, %@", @"Popover row tapped!", homeNavController, childVCs);
			for (id vc in childVCs) {
				if ([[vc description] containsString:@"ContentSwitchController"]) {
					ContentsListViewController* curContentsListCtl = [(ContentSwitchController *)vc valueForKey:@"curContentsListCtl"];
					NSArray<Books *>* selectedBooks = [curContentsListCtl getSelectedItems];
					if (selectedBooks && selectedBooks.count) {
						[[ExportManager shared] startDumpWithBooks:selectedBooks];
					}
					break;
				}
			}
        }];
        return;
    }
    %orig;
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
	TLog(@"willDisplayCell %@ %@", cell, indexPath);
	if ([self isAllSelected] && indexPath.row == 0) {
		return;
	} else if ([self isNoneSelected] && indexPath.row >= 1) {
		[cell setHidden:YES];
	}
}

- (void)viewDidLoad {
	%orig;
	if (![self isNoneSelected]) {
		CGSize previousSize = [self preferredContentSize];
		previousSize.height += 44.0;
		[self setPreferredContentSize:previousSize];
	}
}
%end

// %ctor {
//     MSHookMessageEx_p = (MSHookMessageEx_t)dlsym(RTLD_DEFAULT, "MSHookMessageEx");
//     if (!MSHookMessageEx_p) {
//         TLog(@"%@", @"Cannot find MSHookMessageEx");
//         return;
//     }
// }