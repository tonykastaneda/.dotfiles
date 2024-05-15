#!/usr/bin/osascript

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title ClipNCrop
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🤖
# @raycast.packageName clipncrop

# Documentation:
# @raycast.description clipncrop
# @raycast.author Tony Castaneda

tell application "Adobe Illustrator"
    activate
    tell application "System Events"
        tell process "Adobe Illustrator"
            click menu item "clipcropAction" of menu 1 of menu item "Scripts" of menu 1 of menu bar item "File" of menu bar 1
        end tell
    end tell
end tell

