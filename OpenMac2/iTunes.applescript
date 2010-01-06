-- iTunes integration.applescript
-- ThinkSecret

--  Created by Nate Friedman on Thu May 30 2002.
--  Copyright (c) 2001 __MyCompanyName__. All rights reserved.
on run
	say "it works"
	--tell application "\iTunes\" to say \"Fuck the Fucking Fuckers!\"
	tell application "iTunes"
		
		try
			set theName to (name of current track)
			set theartist to (artist of current track)
			if theartist = "" then
				set theartist to ""
			else
				set theartist to " by \"" & theartist & "\""
			end if
			set thealbum to (album of current track)
			if thealbum = "" then
				set thealbum to ""
			else
				set thealbum to " from the album \"" & thealbum & "\""
			end if
			set thetime to (time of current track)
			set therate to (bit rate of current track)
			set thesize to (((size of current track) / 1024) / 1024)
			set thesize to (((thesize * 10) div 1) / 10)
		on error
			set theName to ""
		end try
		if theName is not "" then return "is listening to \"" & theName & "\"" & theartist & thealbum & ". \"" & theName & Â
			"\" is " & thetime & " long, and running at " & therate & "kbps, therfore, it must be " & thesize & "MB."
	end tell
end run

on open (anItemsList)
	repeat with theItem in anItemsList
		--tell application "Finder"
		say "open " & theItem
		--set theName to name of theItem
		--end tell
		--say "Opening folder " & theName
	end repeat
	
end open