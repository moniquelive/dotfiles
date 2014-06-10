<?php

	// Require the twitter oauth library
	require_once('twitteroauth.php');

	// If settings file didn't exist, create it, then load it
	if (!file_exists("settings.xml")) {

		// create the base element
		$settings = new SimpleXMLElement("<settings></settings>");

		// create all child elements
		$settings->addChild("oauth_token");
		$settings->addChild("oauth_token_secret");
		$settings->addChild("pin");
		$settings->addChild("split_tweets", true);
		$settings->addChild("tweets_command", "tweets");
		$settings->addChild("mentions_command", "mentions");
		$settings->addChild("dm_command", "dm");
		$settings->addChild("info_command", "info");
		$settings->addChild("follow_command", "follow");
		$settings->addChild("unfollow_command", "unfollow");
		$settings->addChild("create_command", "create");
		$settings->addChild("delete_command", "delete");
		$settings->addChild("lists_command", "lists");
		$settings->addChild("add_command", "add");
		$settings->addChild("remove_command", "remove");
		$settings->addChild("block_command", "block");
		$settings->addChild("unblock_command", "unblock");
		$settings->addChild("search_command", "search");
		$settings->addChild("playing_command", "playing");
		$settings->addChild("playing_format", "#Nowplaying @song by @artist in @player @url #alfredtweet");

		// save the xml to the settings.xml file
		$settings->asXML("settings.xml");
	}

	// Load user settings
	$settings = simplexml_load_file("settings.xml");
	
	if (!isset($settings->split_tweets)) { $settings->addChild("split_tweets", true); }
	if (!isset($settings->tweets_command)) { $settings->addChild("tweets_command", "tweets"); }
	if (!isset($settings->mentions_command)) { $settings->addChild("mentions_command", "mentions"); }
	if (!isset($settings->dm_command)) { $settings->addChild("dm_command", "dm"); }
	if (!isset($settings->info_command)) { $settings->addChild("info_command", "info"); }
	if (!isset($settings->follow_command)) { $settings->addChild("follow_command", "follow"); }
	if (!isset($settings->unfollow_command)) { $settings->addChild("unfollow_command", "unfollow"); }
	if (!isset($settings->create_command)) { $settings->addChild("create_command", "create"); }
	if (!isset($settings->delete_command)) { $settings->addChild("delete_command", "delete"); }
	if (!isset($settings->lists_command)) { $settings->addChild("lists_command", "lists"); }
	if (!isset($settings->add_command)) { $settings->addChild("add_command", "add"); }
	if (!isset($settings->remove_command)) { $settings->addChild("remove_command", "remove"); }
	if (!isset($settings->block_command)) { $settings->addChild("block_command", "block"); }
	if (!isset($settings->unblock_command)) { $settings->addChild("unblock_command", "unblock"); }
	if (!isset($settings->search_command)) { $settings->addChild("search_command", "search"); }
	if (!isset($settings->playing_command)) { $settings->addChild("playing_command", "playing"); }
	if (!isset($settings->playing_format)) { $settings->addChild("playing_format", "@song by @artist on @player. #Nowplaying via #alfredtweet @url"); }
	$settings->asXML("settings.xml");
	
	// Split the input to see what the first word is.
	// Done to check and see if a function is being called.
	$input = explode(" ", $argv[1]);
	$ckey1 = '41EXk56kJ2QnIRRupBZ8w';
	$ckey2 = 'QVbe9kY8UppBXxktXYyimfKbTCvg0ZshKUcvtZqPw';
		
	// Display the help menu
	if ($input[0] == "help" && !isset($input[1])) {
		$pin = $settings->pin;
		
		// If the user hasn't authenticated yet, instruct them on how to do it.
		if ($pin == "") { echo "The first step to setting up AlfredTweet is to authenticate this application with Twitter. To do that, use the setup command for this extension. \re.g. tw setup. \r\rAfter you authenticate, Twitter will provide you with a pin number to authenticate the application. Use the pin command to enter it. \re.g. tw pin <number>"; }
		
		else {
			
			// Check alfredtweet authentication settings
			$auth = check_auth();
			
			// if the
			if ($auth == false) { echo "Your pin number has been set, but your authentication keys aren't available. If it has been a while since you set the pin, reset all your settings and try setup again. To reset all settings, type 'tw reset'."; }

			// authentication has been completed, display the regular help menu
			else {
				echo "Usernames do not require the @ for DM's, follow, unfollow, block, or unblock. Preceed all commands with 'tw'. (eg. tw setup)\r\r";
				echo "¬ setup - Setup extension\r";
				echo "¬ pin <number> - Save pin number\r";
				echo "¬ <tweet> - Send tweet\r";
				echo "¬ $settings->tweets_command - Last 5 tweets in timeline\r";
				echo "¬ $settings->mentions_command - Last 5 Mentions\r";
				echo "¬ $settings->dm_command <user> <message> - Send DM\r";
				echo "¬ $settings->info_command <user> - Get User Info\r";
				echo "¬ $settings->follow_command <user> - Follow user\r";
				echo "¬ $settings->unfollow_command <user> - Unfollow user\r";
				echo "¬ $settings->create_command <name> - Create new list\r";
				echo "¬ $settings->delete_command <name> - Delete list\r";
				echo "¬ $settings->lists_command - Show lists\r";
				echo "¬ $settings->add_command <user> <list> - Add user to list\r";
				echo "¬ $settings->remove_command <user> <list> - Remove user from list\r";
				echo "¬ $settings->block_command <user> - Block user\r";
				echo "¬ $settings->unblock_command <user> - Unblock user\r";
				echo "¬ $settings->search_command <term> - Recent 5 matches\r";
				echo "¬ $settings->playing_command - Tweet current song\r";
				echo "¬ set <command> <new> - Change command keyword\r";
				echo "¬ split <on/off> - Turn off tweet splitting\r\r";
				echo "Troubleshooting:\rIf experiencing issues, use the reset command to clear all authentication settings and start over.\r";
				echo "¬ reset - Clears all settings/authentication\r\r";
				echo "Note: List names must use hypens in place of spaces and special characters. Use 'tw lists' to view your current lists.";
			} //end else ($auth is set)
			
		} //end else !$pin
		
	} //end if help
	
	else {
		
		// setup twitter
		if ($input[0] == "setup") {

			// Create a new instance
			$authtweet = new TwitterOAuth($ckey1, $ckey2);

			// Generate request token and open url to authenticate
			$token = $authtweet->getRequestToken("oob");
			$url =  $authtweet->getAuthorizeUrl($token);

			$result = system("open \"$url\"");
		
			// Set counter to limit wait looping
			$inc = 0;
		
			// Wait until the pin is set before continuing
			do {
			
				// Check the number of times the loop has executed. At 
				// 50 loops, assuming that the script has errored or
				// timed out, or other bad things are brewing.
				if ($inc > 20) {
					break;
				}
			
				// Check for pin value. $settings has to be reloaded to detect changes because a separate instance
				// of the script is run to add the pin number, so changing the pin number won't be reflected
				// unless it is reloaded.
				unset($settings);
				$settings = simplexml_load_file("settings.xml");
				$pin = $settings->pin;
			
				// Increment loop, sleep 5 seconds, try again.
				$inc++;
				sleep(2);
			
			}
			while($pin == "");
		
			// This should only occur if something bad happened and the request timed out
			// or errored out or something. Using to kill this script execution.
			if ($inc > 20 && $pin == "") {
				echo "Twitter setup timed out waiting for a pin number. Please try again.";
			}
		
			else {
		
				// Request the access token
				$access_token = $authtweet->getAccessToken($pin);

				// Write oauth tokens to auth.xml
				$settings->oauth_token = $access_token['oauth_token'];
				$settings->oauth_token_secret = $access_token['oauth_token_secret'];
				$settings->asXML("settings.xml");
		
				// Show completion
				echo "Tweeting with Alfred setup is now complete. Start tweeting!";
			
			} // end else (no timeout)
		
		} // end if setup
	
		// Set the pin number
		else if ($input[0] == "pin") {
		
			// Write the pin number to pin.txt
			$settings->pin = $input[1];
			$settings->asXML("settings.xml");
			//$result = system("echo $input[1] > pin.txt");
			echo "Pin number set. Please wait while authorization is completed.";
		
		} // end else pin

		// display the about information for this extension
		else if ($input[0] == "about" && !isset($input[1])) {
			echo "AlfredTweet is an Alfred extension created by David Ferguson (@jdfwarrior) to allow basic Twitter interaction through Alfred. AlfredTweet was designed to be extremely easy to set up. For help getting started, type 'tw help'.\r\r AlfredTweet - Fast, easy tweeting with Alfred.";
		} // end else about

		// display version information on this extension
		else if ($input[0] == "version" && !isset($input[1])) {
			
			// if update.xml exists, display version info
			if (file_exists("update.xml")) {
				$xml = simplexml_load_file("update.xml");
				echo "AlfredTweet $xml->version";
			}

			// if update.xml doesn't exist, show an error
			else {
				echo "No version information found for this extension";
			}

		} // end else version

		// display the changelog for this extension
		else if ($input[0] == "changelog" && !isset($input[1])) {
			
			// if changelog exists, show contents
			if (file_exists("changelog.txt")) {
				$f = fopen("changelog.txt", "r");
				while ($output = fgets($f)) {
					echo $output."\r";
				}
				fclose($f);
			}

			// if changelog doesn't exist, display error
			else {
				echo "No changelog found.";
			}

		} // end else changelog

		// reset all setting for this extension
		else if ($input[0] == "reset" && !isset($input[1])) {

			// Remove the settings.xml file, it will be recreated on next run
			exec("rm settings.xml");
			echo "All settings have been reset. Please run setup again.";
			
			// Kill all running php processes to make sure none are hung in a loop
			// Also hoping there are aren't others that this kills that aren't mine :)
			exec("killall php");

		} // end else reset

		// enable/disable auto tweet splitting
		else if ($input[0] == "split" && ($input[1] == "on" || $input[1] == "off") && !isset($input[2])) {

			// set split_tweets to on and write setting to settings.xml
			if ($input[1] == "on") { 
				$settings->split_tweets = 1; 
				$settings->asXML("settings.xml"); 
				echo "Auto splitting long tweets into multiple is now enabled.";
			}

			// set split_tweets to off and write setting to settings.xml
			else if ($input[1] == "off") { 
				$settings->split_tweets = 0; 
				$settings->asXML("settings.xml"); 
				echo "Auto splitting long tweets into multiple is now disabled.";
			}
			else { echo "Invalid setting value. Please try again"; }

		} // end else split tweets
		
		// if user is attempting to set a new command alias
		else if ($input[0] == "set" && ($input[1] == "tweets_command" || $input[1] == "mentions_command" || $input[1] == "info_command" || $input[1] == "dm_command" || 
			$input[1] == "follow_command" || $input[1] == "unfollow_command" || $input[1] == "create_command" || $input[1] == "delete_command" || $input[1] == "lists_command" || 
			$input[1] == "add_command" || $input[1] == "remove_command" || $input[1] == "block_command" || $input[1] == "unblock_command" || $input[1] == "search_command" || 
			$input[1] == "playing_command" || $input[1] == "playing_format")) {
			
			// grab user input
			$command = $input[1];
			unset($input[0]);
			unset($input[1]);
			$value   = implode(" ", $input);
			
			// determine what setting the user is attempting to change
			switch($command) {
				
				case "tweets_command": 		$settings->tweets_command = $value; break;
				case "mentions_command":	$settings->mentions_command = $value; break;
				case "info_command": 		$settings->info_command = $value; break;
				case "dm_command": 			$settings->dm_command = $value; break;
				case "follow_command": 		$settings->follow_command = $value; break;
				case "unfollow_command": 	$settings->unfollow_command = $value; break;
				case "create_command": 		$settings->create_command = $value; break;
				case "delete_command": 		$settings->delete_command = $value; break;
				case "lists_command": 		$settings->lists_command = $value; break;
				case "add_command": 		$settings->add_command = $value; break;
				case "remove_command": 		$settings->remove_command = $value; break;
				case "block_command": 		$settings->block_command = $value; break;
				case "unblock_command": 	$settings->unblock_command = $value; break;
				case "search_command": 		$settings->search_command = $value; break;
				case "playing_command":		$settings->playing_command = $value; break;
				case "playing_format":		$settings->playing_format = $value; break;
				default:					echo "Unable to find specified command"; exit(1);
				
			}
			
			// show success and save setting
			echo "$command is now set to \"$value\".";
			$settings->asXML("settings.xml");
			
			exit(1);
		}

		// if user is attempting to use "now playing" feature
		else if ($input[0] == $settings->playing_command && !isset($input[1])) {
			
			// list of all players to check
			$players = array("iTunes", "Ecoute", "Rdio", "Spotify", "Sonora");
			$flag = false;
			
			// loop through each player and determine if its running and if its playing a track
			foreach($players as $player):
			
				// get running status of the player
				$running = `osascript -e 'tell application "System Events" to count every process whose name is "$player"'`;
				
				// if the player is open
				if ($running == 1) {
					
					// get track name and artist if available
					if ($player == "Sonora") {
						$name 	= `osascript -e 'tell application "$player" to return track'`;
						$artist = `osascript -e 'tell application "$player" to return artist'`;
						$state  = `osascript -e 'tell application "$player" to return player state'`;
					}
					else {
						$name 	= `osascript -e 'tell application "$player" to return name of current track'`;
						$artist = `osascript -e 'tell application "$player" to return artist of current track'`;
						$state  = `osascript -e 'tell application "$player" to return player state'`;
					}
					$name   = str_replace("\n", "", $name);
					$artist = str_replace("\n", "", $artist);
					
					// if values were available, assume its the current player
					if (($name != "" && $artist != "") && (strtolower(trim($state)) == "playing" || $state == 2)) {
						
						// get tinysong url to track
						$search="$name $artist";
						$search=urlencode($search);
						$url = "http://tinysong.com/a/$search?format=json&limit=3&key=72e02527f928b966e461dbcfffcb8238";

						// initialize curl to grab song url
						$curl = curl_init();
						curl_setopt($curl, CURLOPT_URL, $url);
						curl_setopt ($curl, CURLOPT_RETURNTRANSFER, 1);
						$ret = curl_exec($curl);

						if (strpos($ret, "http")) {
							$ret = str_replace("\\", "", $ret);
							$ret = str_replace("\"", "", $ret);

							$np_tweet = str_replace("@song", $name, $settings->playing_format);
							$np_tweet = str_replace("@artist", $artist, $np_tweet);
							$np_tweet = str_replace("@player", $player, $np_tweet);
							$np_tweet = str_replace("@url", $ret, $np_tweet);

							// tweet the currently playing song
							send_tweet($ckey1, $ckey2, "$np_tweet");
						}
						else {

							$np_tweet = str_replace("@song", $name, $settings->playing_format);
							$np_tweet = str_replace("@artist", $artist, $np_tweet);
							$np_tweet = str_replace("@player", $player, $np_tweet);
							$np_tweet = str_replace("@url", "", $np_tweet);

							// tweet the currently playing song
							send_tweet($ckey1, $ckey2, "$np_tweet");
						}

						// set a flag to show that a track was found. Used to show an error if nothing was found
						$flag = true;
						
						// break the player search loop
						break;
						
					}
				
				}
				
			endforeach;
			
			// display an error if no active player was found
			if (!$flag) {
				echo "Error: either your player isn't supported, or a track isn't playing. No tweets were sent.";
			}
			
			exit(1);
		}
	
		else if ($input[0] == $settings->dm_command) {
		
			// grab username to dm, remove 'dm' and username from overall input so all that is left is the message
			$username = $input[1];
			unset($input[0]);
			unset($input[1]);
			$message = implode(" ", $input);
					
			// ensure that the users authentication credentials are available
			$auth = check_auth();
		
			// If oauth values aren't set, assumed that the user hasn't run setup yet.
			if ($auth == false) { echo "Unable to send dm. You must run setup and authenticate first."; }
			else {
				
				// create a new instance
				$tweet = new TwitterOAuth($ckey1, $ckey2, $auth['oAuthKey'], $auth['oAuthSecret']);
				 		
				//send dm
				$res = $tweet->post('direct_messages/new', array('screen_name' => $username, 'wrap_links' => true, 'text' => $message));
				 			
				//display result/dm
				if (isset($res->error)) { echo $res->error; }
				else { echo "Direct message to $username successfully sent!"; }
							
			} // end else
		
		} // end else if direct messages
	
		else if ($input[0] == $settings->tweets_command) {
		
			// ensure that the users authentication credentials are available
			$auth = check_auth();
		
			// If oauth values aren't set, assumed that the user hasn't run setup yet.
			if ($auth == false) {  echo "Unable to grab tweets. You must run setup and authenticate first."; }
			else {

				// create a new instance
				$tweet = new TwitterOAuth($ckey1, $ckey2, $auth['oAuthKey'], $auth['oAuthSecret']);
		
				//get recent tweets
				$res = $tweet->get('statuses/home_timeline', array('count' => 6));
			
				// display result/tweets
				if (isset($res->error)) { echo $res->error; }
				else { 
					$inc=1;
					foreach($res as $timeline):
						$user = $timeline->user->screen_name;
						if ($inc == count($res)) { echo "¬ $user: $timeline->text"; }
						else { echo "¬ $user: $timeline->text\r\r"; }
						$inc++;
					endforeach;
				}
			
			} // end else
		
		} // end else tweets

		else if ($input[0] == $settings->info_command) {
		
			// ensure that the users authentication credentials are available
			$auth = check_auth();
		
			// If oauth values aren't set, assumed that the user hasn't run setup yet.
			if ($auth == false) {  echo "Unable to grab user info. You must run setup and authenticate first."; }
			else {

				// create a new instance
				$tweet = new TwitterOAuth($ckey1, $ckey2, $auth['oAuthKey'], $auth['oAuthSecret']);
		
				// get user info
				$res = $tweet->get('users/show', array('count' => 6, 'screen_name'=>$input[1]));
			
				// display result/user info
				if (isset($res->error)) { 
					if ($res->error == "Not found") {
						echo "Unable to find info for that user.";	
					}
					else { echo $res->error; }
				}
				else { 
					$status = $res->status->text;
					
					// Note if you are following this user
					if ($res->following) { $following = "(following)"; }
					else { $following = ""; }
					
					// Fallback values. Hopefully you wont need these?
					if ($status == "") { $status = "Unable to find last tweet"; }
					if ($res->name == "") { $res->name = "N/a"; }
					if ($res->url == "") { $res->url = "N/a"; }
					if ($res->description == "") { $res->description = "N/a"; }
					
					echo "User: $res->screen_name $following\r";
					echo "Name: $res->name\r";
					echo "Location: $res->location\r";
					echo "URL: $res->url\r";
					echo "Tweets: $res->statuses_count\r";
					echo "Followers: $res->followers_count\r\r";
					echo "Description:\r $res->description\r\r";
					echo "Last tweet:\r $status";
				}
			
			} // end else
		
		} // end else if tweets

		else if ($input[0] == $settings->mentions_command) {
		
			// ensure that the users authentication credentials are available
			$auth = check_auth();
		
			// If oauth values aren't set, assumed that the user hasn't run setup yet.
			if ($auth == false) {  echo "Unable to grab mentions. You must run setup and authenticate first."; }
			else {

				// create a new instance
				$tweet = new TwitterOAuth($ckey1, $ckey2, $auth['oAuthKey'], $auth['oAuthSecret']);
		
				// get mentions
				$res = $tweet->get('statuses/mentions', array('count' => 6));
			
				// display result/mentions
				if (isset($res->error)) { echo $res->error; }
				else { 
					$inc=1;
					foreach($res as $mention):
						$user = $mention->user->screen_name;
						if ($inc == count($res)) { echo "¬ $user: $mention->text"; }
						else { echo "¬ $user: $mention->text\r\r"; }
						$inc++;
					endforeach;
				}
			
			} // end else
		
		} // end else mentions
	
		else if ($input[0] == $settings->follow_command) {
		
			// ensure that the users authentication credentials are available
			$auth = check_auth();
		
			// If oauth values aren't set, assumed that the user hasn't run setup yet.
			if ($auth == false) {  echo "Unable to follow user. You must run setup and authenticate first."; }
			else {

				// create a new instance
				$tweet = new TwitterOAuth($ckey1, $ckey2, $auth['oAuthKey'], $auth['oAuthSecret']);
		
				// follow user
				$res = $tweet->post('friendships/create', array('screen_name' => $input[1]));
			
				// display result
				if (isset($res->error)) { echo $res->error; }
				else { echo "Now following ".$input[1]; }
			
			} // end else
		
		} // end else follow user
	
		else if ($input[0] == $settings->unfollow_command) {
		
			// ensure that the users authentication credentials are available
			$auth = check_auth();
		
			// If oauth values aren't set, assumed that the user hasn't run setup yet.
			if ($auth == false) {  echo "Unable to unfollow user. You must run setup and authenticate first."; }
			else {

				// create a new instance
				$tweet = new TwitterOAuth($ckey1, $ckey2, $auth['oAuthKey'], $auth['oAuthSecret']);
		
				// unfollow user
				$res = $tweet->post('friendships/destroy', array('screen_name' => $input[1]));
			
				// display result
				if (isset($res->error)) { echo $res->error; }
				else { echo "Now following ".$input[1]; }
			
			} // end else authenticated
		
		} // end else unfollow user
		
		else if ($input[0] == $settings->create_command) {
			
			// ensure that the users authentication credentials are available
			$auth = check_auth();

			// if auth values aren't set, assumed that the user hasn't run setup yet
			if ($auth == false) {
				echo "Unable show lists. You must run setup and authenticate first."; 
			}

			// user has run setup and authenticated
			else {

				// grab user input on the name of the list to create
				$list_name = $input[1];

				// create a new instance
				$tweet = new TwitterOAuth($ckey1, $ckey2, $auth['oAuthKey'], $auth['oAuthSecret']);

				// create the new twitter list
				$res = $tweet->post('lists/create', array('name'=>$list_name));

				// display result
				if (isset($res->error)) { echo $res->error; }
				else { echo "Successfully created $list_name list."; }

			} // end else authenticated

		} // end else create list

		else if ($input[0] == $settings->delete_command) {
			
			// ensure that the users authentication credentials are available
			$auth = check_auth();

			// if auth values aren't set, assumed that the user hasn't run setup yet
			if ($auth == false) {
				echo "Unable show lists. You must run setup and authenticate first."; 
			}

			// user has run setup and authenticated
			else {

				// grab user input of the list to delete
				$list_name = $input[1];

				// create a new instance
				$tweet = new TwitterOAuth($ckey1, $ckey2, $auth['oAuthKey'], $auth['oAuthSecret']);

				// Get the users screen name to obtain thier lists
				$screen_name = get_screen_name($ckey1, $ckey2);

				// Grab a list of all the users lists
				$lists = $tweet->get('lists', array('screen_name' => $screen_name)); 

				// Determine if that lists exists and if so save its ID for deletion
				foreach($lists->lists as $list):
					if (strtolower($list->name) == strtolower($list_name) ||
						strtolower($list->slug) == strtolower($list_name)) {
						$list_id = $list->id;
					}
				endforeach;

				// If no list was found with that name, show an error
				if (!isset($list_id)) {
					echo "Unable to find the specified list";
				}

				// If a matching list was found, delete it
				else {

					// delete the list
					$res = $tweet->post('lists/destroy', array('list_id'=>$list_id));

					// display the result
					if (isset($res->error)) { echo $res->error; }
					else { echo "Successfully deleted $list_name list."; }

				}

			} // end else authenticated

		} // end if delete list

		else if ($input[0] == $settings->lists_command) {
		
			// ensure that the users authentication credentials are available
			$auth = check_auth();
		
			// If oauth values aren't set, assumed that the user hasn't run setup yet.
			if ($auth == false) { 
				echo "Unable show lists. You must run setup and authenticate first."; 
			}		
			else {		
						
				// get logged in user's screen_name
				$screen_name = get_screen_name($ckey1, $ckey2);

				// create a new instance
				$tweet = new TwitterOAuth($ckey1, $ckey2, $auth['oAuthKey'], $auth['oAuthSecret']);
		
				// add user to list
				$res = $tweet->get('lists', array('screen_name' => $screen_name));
			
				// display result(s)
				if (isset($res->error)) { echo $res->error; }
				else { 
					
					$num_lists = count($res->lists);

					// If no lists have been created, inform the user so a blank notification isn't shown
					if ($num_lists == 0) {
						echo "You don't currently have any lists available. Try creating a new one with 'tw create <name>'";
					}

					// Display all lists
					else {
						$inc=1;
						echo "Twitter lists:\r";
						echo "--------------\r";
						foreach($res->lists as $list):
							$slug = $list->slug;
							if ($inc == $num_lists) { echo ucfirst($slug); }
							else { echo ucfirst($slug)."\r"; }
							$inc++;
						endforeach;
					}

				} // end else (if no error)
			
			} // end else
		
		} //end if lists
		
		else if ($input[0] == $settings->add_command) {
			
			// grab the username and the list to add them to
			$username = $input[1];
			$list = $input[2];
		
			// ensure that the users authentication credentials are available
			$auth = check_auth();
		
			// If oauth values aren't set, assumed that the user hasn't run setup yet.
			if ($auth == false) { 
				echo "Unable to modify list. You must run setup and authenticate first."; 
			}		
			else {		
						
				// get logged in user's screen_name
				$screen_name = get_screen_name($ckey1, $ckey2);

				// create a new instance
				$tweet = new TwitterOAuth($ckey1, $ckey2, $auth['oAuthKey'], $auth['oAuthSecret']);
		
				// add user to list
				$res = $tweet->post('lists/members/create', array('screen_name' => $username, 'slug' => $list, 'owner_screen_name' => $screen_name));
			
				// display result
				if (isset($res->error)) { echo $res->error; }
				else { echo "$username successfully added to the $list list!"; }
			
			} // end else
		
		} //end if add to list
		
		else if ($input[0] == $settings->remove_command) {
		
			// grab the user name and the list to remove them from
			$username = $input[1];
			$list = $input[2];

			// ensure that the users authentication credentials are available
			$auth = check_auth();
		
			// If oauth values aren't set, assumed that the user hasn't run setup yet.
			if ($auth == false) { 
				echo "Unable to modify list. You must run setup and authenticate first."; 
			}		
			else {		
						
				// get logged in user's screen_name
				$screen_name = get_screen_name($ckey1, $ckey2);

				// create a new instance
				$tweet = new TwitterOAuth($ckey1, $ckey2, $auth['oAuthKey'], $auth['oAuthSecret']);
		
				// remove user from list
				$res = $tweet->post('lists/members/destroy', array('screen_name' => $username, 'slug' => $list, 'owner_screen_name' => $screen_name));
			
				// display result
				if (isset($res->error)) { echo $res->error; }
				else { echo "$username successfully removed from the $list list!"; }
			
			} // end else
		
		} // end if remove from list
	
		else if ($input[0] == $settings->block_command) {
		
			// ensure that the users authentication credentials are available
			$auth = check_auth();
		
			// If oauth values aren't set, assumed that the user hasn't run setup yet.
			if ($auth == false) {  echo "Unable to block user. You must run setup and authenticate first."; }
			else {

				// create a new instance
				$tweet = new TwitterOAuth($ckey1, $ckey2, $auth['oAuthKey'], $auth['oAuthSecret']);
		
				//block user
				$res = $tweet->post('blocks/create', array('screen_name' => $input[1]));
			
				// display result
				if (isset($res->error)) { echo $res->error; }
				else { echo "Successfully blocked ".$input[1]; }
			
			} // end else
		
		} // end if block user
	
		else if ($input[0] == $settings->unblock_command) {
		
			// ensure that the users authentication credentials are available
			$auth = check_auth();
		
			// If oauth values aren't set, assumed that the user hasn't run setup yet.
			if ($auth == false) {  echo "Unable to unblock user. You must run setup and authenticate first."; }
			else {

				// create a new instance
				$tweet = new TwitterOAuth($ckey1, $ckey2, $auth['oAuthKey'], $auth['oAuthSecret']);
		
				// unblock user
				$res = $tweet->post('blocks/destroy', array('screen_name' => $input[1]));
			
				// display result
				if (isset($res->error)) { echo $res->error; }
				else { echo "No longer blocking ".$input[1]; }
			
			} // end else
		
		} // end if unblock user

		else if ($input[0] == $settings->search_command) {
		
			// ensure that the users authentication credentials are available
			$auth = check_auth();
		
			// If oauth values aren't set, assumed that the user hasn't run setup yet.
			if ($auth == false) {  echo "Unable to perform search. You must run setup and authenticate first."; }
			else {

				// create a new instance
				$tweet = new TwitterOAuth($ckey1, $ckey2, $auth['oAuthKey'], $auth['oAuthSecret']);
		
				// get search results
				$res = $tweet->get('search', array('q' => $input[1], 'result_type'=>'recent', 'rpp'=>5));
			
				// display result(s)
				if (isset($res->error)) { echo $res->error; }
				else { 
					$inc=1;
					foreach($res->results as $result):
						$user = $result->from_user;
						if ($inc == count($res->results)) { echo "$result->text - @$user "; }
						else { echo "$result->text\r - @$user \r\r"; }
						$inc++;
					endforeach;
				}
			
			} // end else
		
		} // end if search
	
		// assuming setup is complete
		else {
		
			send_tweet($ckey1, $ckey2, "".$argv[1]."");
		
		} //end else (searching for commands)
	}
	
	
	function check_auth() {
		// Read auth.xml for credentials
		$settings = simplexml_load_file("settings.xml");
		
		// Grab oauth token values
		$ret['oAuthKey'] = "$settings->oauth_token";
		$ret['oAuthSecret'] = "$settings->oauth_token_secret";

		// If oauth values aren't set, assumed that the user hasn't run setup yet.
		if ($ret['oAuthKey'] == "" || $ret['oAuthSecret'] == "") {  return false; }
		else { return $ret; }
	}
	

	function get_screen_name($ckey1, $ckey2) {		
		// check authentication status
		$auth = check_auth();
		
		// If oauth values aren't set, assumed that the user hasn't run setup yet.
		if ($auth == false) { return false; }		
		else {		

			// create a new instance
			$tweet = new TwitterOAuth($ckey1, $ckey2, $auth['oAuthKey'], $auth['oAuthSecret']);
		
			// get logged in user's details
			$res = $tweet->get('account/verify_credentials');
			
			// pass results if successful
			if (isset($res->error)) { return false; }
			else { 
				// get logged in user's screen_name
				$screen_name = $res->{'screen_name'};
				return $screen_name; 
			}		
				
		}	
						
	}
	
	function send_tweet($ckey1, $ckey2, $text) {
		
	// ensure that the users authentication credentials are available
	$auth = check_auth();

	$settings = simplexml_load_file("settings.xml");
		
	// If oauth values aren't set, assumed that the user hasn't run setup yet.
	if ($auth == false) { echo "Unable to post tweet. You must run setup and authenticate first."; }
	else {

		// create a new instance
		$tweet = new TwitterOAuth($ckey1, $ckey2, $auth['oAuthKey'], $auth['oAuthSecret']);
		$tweet_text = $text;
		$tweets = array();

		// Check tweet length and break it into multiple tweets if needed.
		if (strlen($tweet_text) > 140 && $settings->split_tweets == 1) {

			// Set the regex pattern to grab mentions from the total tweet
			// then grab all mentions as an array, and reassemble as a string.
			// This will be used to make the mentions flow to the multiple tweets
			$user_pattern = '/@[a-z0-9]+/';
			preg_match_all($user_pattern, $tweet_text, $men);
			$um = implode(" ", $men[0]);

			// Split the overall tweet into an array of words, count the number of words,
			// and create a few utility variables. $totaltweets will be used as a counter 
			// when posting the multiple tweets. $newtweet will construct the new tweet
			// that has been length limited.
			$tweet_words = explode(" ", $tweet_text);
			$words = count($tweet_words);
			$newtweet = "";
			$totaltweets=1;

			// Iterate over every word, reassembling the multiple tweets
			foreach($tweet_words as $word):

				// Create a temp tweet to test value
				$temp = $newtweet." ".$word;

				// Check the tweet length with the new word added. Set to 136 instead of 140
				// characters to compensate for the counter at the end.
				if (strlen($temp) > 136) {

					// If its over 136 characters, then break here and make the current value its
					// own tweet. Then reset the $newtweet value with the mentioned users in the 
					// beginning of the tweet.
					array_push($tweets,"$newtweet [$totaltweets]");
					$newtweet = $um." ".$word;
					unset($temp);
					$totaltweets++;

				}

				// If the length is less than 136 characters, append the word and continue to the next word.
				else {

					// Append word
					$newtweet = $newtweet." ".$word;

				}

			endforeach;

			// Append the remaining tweet text to the array as the final tweet.
			array_push($tweets,"$newtweet [".$totaltweets."]");

		}

		// If the tweet was less than 140 characters, just add that tweet to the array to be tweeted
		else {

			array_push($tweets, $tweet_text);

		}
				
		// Iterate over each tweet item and send the tweet.
		foreach($tweets as $t):
		 
			//send a tweet
		 	$res = $tweet->post('statuses/update', array('status' => $t, 'wrap_links' => true));		
		 
		endforeach;
				
		if (isset($res->error)) { echo $res->error; }
		else { 
			echo "Tweeted: ".$tweet_text; 
		}
		
	}
		
	}
	
?>