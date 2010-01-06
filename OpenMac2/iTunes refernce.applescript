on run {}
	tell application "ircle 3.1 English Carbon"
		-- get full argument string
		set arg to argstring
		set olddelimiter to AppleScript's text item delimiters
		set AppleScript's text item delimiters to {" "}
		-- make sure command is typed
		if (arg is not "play" and arg is not "last" and arg is not "next" and arg is not "fastforward" and arg is not "rewind" and arg is not "resume" and arg is not "stop" and arg is not "pause" and arg is not "mute" and arg is not "restart" and arg is not "broadcast" and arg is not "quit") then
			echo serverprefix & "Syntax: /itunes [play, last, next, fastforward, rewind, resume, stop, pause, mute, restart, broadcast, quit]"
			set AppleScript's text item delimiters to olddelimiter
			return true
		end if
		tell application "iTunes"
			set versionstring to the version as string
			if versionstring is not greater than or equal to "2.0.4" then
				tell application "ircle 3.1 English Carbon"
					echo serverprefix & "Sorry, this script requires iTunes 2.0.4 or better."
				end tell
				set AppleScript's text item delimiters to olddelimiter
				return true
			end if
			if arg = "play" then
				play
			end if
			if arg = "last" then
				previous track
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
				tell application "ircle 3.1 English Carbon"
					if theName is not "" then
						echo serverprefix & "you are now listening to \"" & theName & "\"" & theartist & thealbum & ". \"" & theName & "\" is " & thetime & Â
							" long, and running at " & therate & "kbps, is " & thesize & "MB."
						say "you are now listening to \"" & theName & theartist
					end if
				end tell
			end if
			if arg = "next" then
				next track
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
				tell application "ircle 3.1 English Carbon"
					if theName is not "" then
						echo serverprefix & "you are now listening to \"" & theName & "\"" & theartist & thealbum & ". \"" & theName & "\" is " & thetime & Â
							" long, and running at " & therate & "kbps, is " & thesize & "MB."
						say "you are now listening to \"" & theName & theartist
					end if
				end tell
				
			end if
			if arg = "fastforward" then
				fast forward
			end if
			if arg = "rewind" then
				rewind
			end if
			if arg = "resume" then
				resume
			end if
			if arg = "stop" then
				stop
			end if
			if arg = "pause" then
				playpause
			end if
			if arg = "mute" then
				if mute is true then
					set mute to false
				else
					set mute to true
				end if
			end if
			if arg = "restart" then
				back track
			end if
			if arg = "broadcast" then
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
				tell application "ircle 3.1 English Carbon"
					if theName is not "" then
						type "/me is listening to \"" & theName & "\"" & theartist & thealbum & ". \"" & theName & "\" is " & thetime & Â
							" long, and running at " & therate & "kbps, so for those who don't want to do the math, it is " & thesize & "MB."
					else
						echo serverprefix & "You are not currently listening to anything in iTunes."
					end if
				end tell
			end if
			if arg = "quit" then
				quit
			end if
		end tell
		set AppleScript's text item delimiters to olddelimiter
		return true
	end tell
end run