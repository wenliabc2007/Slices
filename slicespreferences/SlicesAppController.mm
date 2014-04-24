#import <AppList/AppList.h>
#import "SlicesAppDetailController.h"

// from rpertich
static NSInteger DictionaryTextComparator(id a, id b, void *context)
{
	return [[(__bridge NSDictionary *)context objectForKey:a] localizedCaseInsensitiveCompare:[(__bridge NSDictionary *)context objectForKey:b]];
}

@interface SlicesAppController : PSListController
@end

@implementation SlicesAppController
- (id)specifiers
{
	if(_specifiers == nil)
	{
		NSMutableArray *specifiers = [[NSMutableArray alloc] init];
		[specifiers addObject:[PSSpecifier preferenceSpecifierNamed:@"User Applications" target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil]];

		ALApplicationList *applicationList = [ALApplicationList sharedApplicationList];
		NSDictionary *applications = applicationList.applications;
		NSMutableArray *displayIdentifiers = [[applications allKeys] mutableCopy];

		[displayIdentifiers sortUsingFunction:DictionaryTextComparator context:(__bridge void *)applications];

		for (NSString *displayIdentifier in displayIdentifiers)
		{
			NSString *applicationPath = [applicationList valueForKey:@"path" forDisplayIdentifier:displayIdentifier];
			if (![applicationPath hasPrefix:@"/private/var/mobile/Applications/"])
				continue;

			PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:applications[displayIdentifier] target:nil set:nil get:nil detail:[SlicesAppDetailController class] cell:PSLinkListCell edit:nil];
			[specifier.properties setValue:displayIdentifier forKey:@"displayIdentifier"];

			UIImage *icon = [applicationList iconOfSize:ALApplicationIconSizeSmall forDisplayIdentifier:displayIdentifier];
			if (icon)
				[specifier setProperty:icon forKey:@"iconImage"];

			[specifiers addObject:specifier];
		}

		_specifiers = [specifiers copy];
	}

	return _specifiers;
}
@end