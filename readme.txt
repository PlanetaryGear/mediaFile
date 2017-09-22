If this software was helpful to you or you have made improvements to it I would very 
much appreciate an email letting me know if at all possible. 

Version 1.0  9/22/2017 james@sentman.com 

cMediaFile classes work similarly to the built in WebFile class but support Range requests on files.
This is important as Safari on MacOS and MobileSafari on iOS absolutely require you to properly 
support the Range request or they will refuse to play the audio or video file. There may be other
reasons why you would want to support range requests for large files as well.

To use this class in your software requires 2 steps:

Import the cMediaFile class into your application.
Add the following code to the app.HandleSpecialURL event:

If cMediaFile.handleSpecialURL( request) Then
  Return True
End If

After that you can add any other code to the handleSpecialURL event that you wish, only links that begin with the 
cMediaFile.urlPrefix constant will be handled there. Everything else will fall through.

You must hold a reference to the created cMediaFile for as long as you want the file to be available.
After it has gone out of scope in your code a request for it will return a not found error.

No attempt is made to try to validate sessions requesting the file. You should only keep the files
available and in scope for as long as a session is using them.  This is the same as setting the
.session class to nil in the existing xojo webFile class.

to create a class reference use the shared Open method, do not create the class via the new operator:

dim myMediaFile as cMediaFile = cMediaFile.open( FolderItem)

like the webFile class you must set the MimeType that you wish to be sent:
myMediaFile.mimeType = "video/mp4"

like the webFile class it has a cMediaFile.URL property that will contain the url necessary to use the data.

it differs from the webFile class in that there is no .download property. If you wish to force the file to download rather than open in
the browser add "?download=true" to the end of the URL like:

webLink.url = myMediaFile.url + "?download=true"

if you wish to try to stop the browser from caching the output from this you can set the .noCache boolean to true:
myMediaFile.noCache = true
this will send every no-cache header that I've ever been able to find to try to keep the browser from keeping the data in memory.
this doesn't always work however it's worth a try.

Once the file is first accessed by a browser the binaryStream connected to the file is kept open until the object goes out of scope.
This speeds up getting other chunks from it, but is a potential problem if too many files are opened. If a page is closed
without the user specifically going to another page the page will stay open until the session expires at which point the
page and the referenced cMediaFile will be cleaned up. You can force it immediately to close it's file and remove itself from 
the index by calling the .close method. If this is going to be a problem for you the solution is as simple as closing the
myStream reference at the end of the handleRequest Method and setting it to nil. It will be recreated upon further
accesses to the same class.

To run the example project in debug mode the example movie file "test.mp4" must be in the same folder with the xojo project.
To run the project as a compiled app the movie file must be in the same folder with the compiled app.
