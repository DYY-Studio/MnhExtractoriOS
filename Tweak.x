#import <dlfcn.h>
#import "Tweak.h"

#define TLog(fmt, ...) NSLog((@"[ReaderSonyDumper] " fmt), ##__VA_ARGS__)

%config(generator=internal);

typedef void (*MSHookMessageEx_t)(Class _class, SEL message, IMP hook, IMP *old);
static MSHookMessageEx_t MSHookMessageEx_p = NULL;

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
}