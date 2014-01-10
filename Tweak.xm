#import <Pandora/PMRadio.h>
#import <Pandora/TrackDescriptor.h>
#import <Pandora/NowPlayingDrawerCell.h>
#import <UIKit/UIImage+Private.h>
#import <UIKit/UIKit.h>

@interface _RUTrackActionsTableViewCell : UITableViewCell

@property (nonatomic,retain) UIImage *accessoryImage;
@property (assign,nonatomic) UIOffset accessoryImageOffset;

@end

@interface RUTrackActionsView

@property (nonatomic,copy) NSString *songText;
@property (nonatomic,copy) NSString *artistText;

@end


UIImage *iconForPandora, *iconForRadio;

void HBRSOpenSpotify(NSString *songName, NSString *artistName) {

	NSString *query = [NSString stringWithFormat:@"%@ - %@", songName, [artistName stringByReplacingOccurrencesOfString:@" &" withString:@""]];

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

		if (!iconForPandora) {
			iconForPandora = [[UIImage imageNamed:@"spotify.png" inBundle:[NSBundle bundleWithPath:@"/Library/Application Support/RadiSpot.bundle"]] retain];
		}

		cell.leftImageView.image = iconForPandora;

		return cell;

	} else if (indexPath.section > 4) {
		indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section - 1];
	}

	return %orig;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 5) {
		[tableView deselectRowAtIndexPath:indexPath animated:YES];

        TrackDescriptor *track = ((PMRadio *)[%c(PMRadio) sharedRadio]).activeTrack;

		HBRSOpenSpotify(track.songName, track.artistName);
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
        TrackDescriptor *track = ((PMRadio *)[%c(PMRadio) sharedRadio]).activeTrack;

		HBRSOpenSpotify(track.songName, track.artistName);
	}
}

%end

#pragma mark - iTunes Radio

%hook RUTrackActionsView

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return %orig(tableView, section) + 1;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {


    if (indexPath.row == 3) {

        _RUTrackActionsTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"OpenSpotifyCell"];

        if (cell == nil) {
            cell = [[%c(_RUTrackActionsTableViewCell) alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"OpenSpotifyCell"];
        }
        
        if (!iconForRadio) {
			iconForRadio = [[UIImage imageNamed:@"spotify-color.png" inBundle:[NSBundle bundleWithPath:@"/Library/Application Support/RadiSpot.bundle"]] retain];
		}
        
        cell.textLabel.text = @"Open in Spotify";
        cell.accessoryImage = iconForRadio;
        cell.accessoryImageOffset = UIOffsetMake(-1, 5);

        return cell;
    }
        
    return %orig(tableView, indexPath);
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.row == 3) {

        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        %orig(tableView, [NSIndexPath indexPathForRow:([tableView numberOfRowsInSection:0] - 1) inSection:0]);
        HBRSOpenSpotify([self songText], [self artistText]);

    } else {

        %orig(tableView, indexPath);
    }

}

%end
