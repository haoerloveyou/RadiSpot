#import <Pandora/PMRadio.h>
#import <Pandora/TrackDescriptor.h>
#import <Pandora/NowPlayingDrawerCell.h>
#import <UIKit/UIImage+Private.h>

UIImage *icon;

void HBRSOpenSpotify() {
	TrackDescriptor *track = ((PMRadio *)[%c(PMRadio) sharedRadio]).activeTrack;
	NSString *query = [NSString stringWithFormat:@"%@ - %@", track.songName, [track.artistName stringByReplacingOccurrencesOfString:@" &" withString:@""]];

	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"spotify:search:" stringByAppendingString:[(NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)query, NULL, CFSTR("!*'();:@&=+$,/?%#[]"), kCFStringEncodingUTF8) autorelease]]]];
}

#pragma mark - iPhone

%hook NowPlayingDrawerViewController

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return %orig + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 5) {
		NowPlayingDrawerCell *cell = [[%c(NowPlayingDrawerCell) alloc] init]; // y u no cell reuse?
		cell.backgroundColor = nil;
		cell.backgroundView = nil;
		cell.textLabel.text = @"Open in Spotify";

		if (!icon) {
			icon = [[UIImage imageNamed:@"spotify.png" inBundle:[NSBundle bundleWithPath:@"/Library/Application Support/RadiSpot.bundle"]] retain];
		}

		cell.leftImageView.image = icon;

		return cell;
	} else if (indexPath.section > 4) {
		indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section - 1];
	}

	return %orig;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 5) {
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
		HBRSOpenSpotify();
	} else {
		%orig;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 5) {
		indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:3];
	} else if (indexPath.section > 4) {
		indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section - 1];
	}

	return %orig;
}

%end

#pragma mark - iPad

%hook PMNowPlayingMenuBarMoreOptionsViewController

- (void)setContentSizeForViewInPopover:(CGSize)size {
	size.height += 44.f;
	%orig;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return %orig + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = %orig;

	if (indexPath.section == 4) {
		cell.textLabel.text = @"Open in Spotify";
	}

	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	%orig;

	if (indexPath.section == 4) {
		HBRSOpenSpotify();
	}
}

%end
