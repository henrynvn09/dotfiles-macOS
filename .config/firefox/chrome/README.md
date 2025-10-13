## Live Edit userChrome

Step 0: Make sure you know what userChrome.css is, and that you get a basic grip on CSS. You cannot skip these prerequisites.

Step 1: Enable the remote debugging tool. Press F12 on any tab to open DevTool, go to DevTools settings, then check "Enable browser chrome and add-on debugging toolboxes" and "Enable remote debugging" options found in Advanced Settings. (Also uncheck them once you're done; you don't want to expose the DevTool to other stuff in your network. It's just a security precaution.)

Step 2: Turn on the local "remote" debugger by pressing Ctrl+Alt+Shift+I. You should get a prompt from the debugger asking to connect to your own Firefox. Press OK.

Step 3: Start fiddling around. The whole browser's chrome (UI) is written in XUL, which is kinda like HTML. Inpsect and play with the style properties as you would in a normal webpage.

