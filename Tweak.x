#import <dlfcn.h>
#import "Tweak.h"

#define TLog(fmt, ...) NSLog((@"[ReaderSonyDumper] " fmt), ##__VA_ARGS__)

%config(generator=internal);

typedef void (*MSHookMessageEx_t)(Class _class, SEL message, IMP hook, IMP *old);
static MSHookMessageEx_t MSHookMessageEx_p = NULL;

typedef NSData *(*MetaParser_getData__t)(id self, SEL _cmd, NSString *path);
static MetaParser_getData__t orig_MetaParser_getData_ = NULL;
static NSData *hook_MetaParser_getData_(id self, SEL _cmd, NSString *path){
	NSData* data = orig_MetaParser_getData_(self, _cmd, path);

	TLog(@"%@, %@", path, data);
	return data;
}

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
            // 使用标准样式，可以带图标和主标题
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        // 配置你的 Tweak 按钮样式，使其看起来与原 App 融为一体
        cell.textLabel.text = @"Decrypt Selected";
        cell.textLabel.textColor = [UIColor systemBlueColor]; // 也可以使用原 App 的品牌色
        
        return cell;
    }
    
    // 否则，返回原 App 的正常 Cell
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
					for (Books *book in selectedBooks) {
						TLog(@"BOOK %@", book);
						ContentExtractor* extractor = [[NSClassFromString(@"ContentExtractor") alloc] initWithContentPath:[book bookFullPath]];
						NSDictionary<NSString *, NSNumber *> *fileSizeList = [extractor getFileSizeList];
						for (NSString *filePath in fileSizeList) {
							if ([filePath hasSuffix:@"/"]) continue;
							@autoreleasepool {
								NSData* data = [extractor getDataWithFilePath:filePath];
								TLog(@"%@, %@", filePath, data);
							}
						}
						[extractor close];
						break;
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

%ctor {
    MSHookMessageEx_p = (MSHookMessageEx_t)dlsym(RTLD_DEFAULT, "MSHookMessageEx");
    if (!MSHookMessageEx_p) {
        TLog(@"%@", @"Cannot find MSHookMessageEx");
        return;
    }

	Class metaParser = NSClassFromString(@"MetaParser");
	if (metaParser) {
		MSHookMessageEx_p(
			metaParser,
			@selector(getData:),
			(IMP)hook_MetaParser_getData_,
			(IMP*)&orig_MetaParser_getData_
		);
	}
}