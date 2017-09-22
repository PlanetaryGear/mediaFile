#tag Class
Protected Class cMediaFile
	#tag Method, Flags = &h0
		Sub close()
		  // all this will happen when the class goes out of scope but you can force it by calling this method
		  
		  
		  // close our stream
		  If myStream <> Nil Then
		    myStream.Close
		    myStream = Nil
		  End If
		  
		  // remove us from the index
		  
		  If cMediaFile.MediaFileIndex <> Nil And cMediaFile.MediaFileIndex.HasKey( uniqueID) Then
		    cMediaFile.MediaFileIndex.Remove( uniqueID)
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub destructor()
		  
		  // idiot check, it should not be possible for the class to be created without this unless 
		  // you create it via the new command rather than using the shared cMediaFile.open command
		  If MediaFileIndex = Nil Then
		    Return
		  End If
		  
		  // remove the WeakRef from the index
		  // since it's a WeakRef it won't keep us from firing our destructor event when other 
		  // references go out of scope
		  
		  If MediaFileIndex.HasKey( uniqueID) Then
		    MediaFileIndex.Remove( uniqueID)
		  End If
		  
		  // close our binary stream if it's been opened
		  
		  If myStream <> Nil Then
		    myStream.close
		    myStream = Nil
		  End If
		  
		  // Print( "we are in a destructor")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function HandleRequest(request as WebRequest) As Boolean
		  // called from the code in the handleSpecialRequest event to do the actual work of loading and sending the range of the file
		  
		  
		  //
		  // check to be sure the file exists and isn't 0 length or something
		  // it can't be nil here as we already return an error for that in the Open handler
		  //
		  
		  If (Not myFile.Exists) Or myFile.Length = 0 Then
		    request.Status = 404
		    Return True
		  end if
		  
		  
		  //
		  // you can force a download by adding "?download=true" to the end of the URL
		  // changing the mimeType to application/octetstream forces the browser to just download the file
		  // at least on more modern browsers, This may not work with older browser versions.
		  //
		  
		  If request.GetParameter( "download") = "true" Then
		    request.MIMEType = "application/octetstream" 
		  Else
		    request.MIMEType = mimeType
		  End If
		  
		  Dim isRange As Boolean = False
		  Dim startRange, endRange As Integer
		  
		  
		  //
		  // look for the range header. If it's present then send it as a range response
		  // otherwise send it as a normal 200 response
		  //
		  
		  Dim rangeHeader As String = request.GetRequestHeader( "Range")
		  
		  If rangeHeader <> "" Then
		    isRange = True
		    request.Status = 206 // partial response code, required for a range response
		    
		    //
		    // parse out the range request header line.
		    // examples of range headers:
		    // bytes=0- is requesting the entire file anyway
		    // bytes=100-200 remember that it starts as 0 is the first byte
		    // bytes=50- from 51st byte to the end of the file
		    // there may be others, but these are the ones this currently supports
		    // and only "bytes" as the range type
		    //
		    
		    Dim s As String = NthField( rangeHeader, "=", 2) // should now just have the 100-200 portion
		    
		    startRange = Val( NthField( rangeHeader, "-", 1)) // start range must always be present
		    
		    // the end point may be empty so we have to fill in the size of the file if this is the case
		    Dim workEnd As String = NthField( s, "-", 2)
		    Dim workContentSize As Integer = myFile.Length
		    
		    //
		    // manage the end of range options
		    //
		    If workEnd = "" Then
		      // no end was specified, use the file length
		      endRange = workContentSize - 1 // minus one becuase the range uses 0 as the first byte
		    Else
		      // an end range was specified, we have to validate it however
		      endRange = Val( workEnd)
		      If endRange > workContentSize -1 Then
		        endRange = workContentSize - 1
		      End If
		    End If
		    
		    //
		    // add necessary headers
		    //
		    
		    request.Header( "Accept-Ranges") = "bytes"
		    //
		    // the content-range header in the format of "start-end/total" where total is the count, 
		    // so end range will always be one less than it since they start counting at 0
		    //
		    request.Header( "Content-Range") = "bytes " + Str( startRange) + "-" + Str( endRange) + "/" + Str( workContentSize)
		    //
		    // it is rumored that Safari will also refuse some media connections unless the connection can be kept-alive so this
		    // header is also required. The Xojo web framework does properly support this HTTP1/1 feature so it is safe to set this
		    //
		    request.Header( "Connection") = "Keep-Alive"
		    
		  Else
		    //
		    // it is NOT a range request so we can just return the entirety of the file as a regular response and no range headers
		    //
		    
		    request.Status = 200
		    isRange = False
		  End If
		  
		  //
		  // send every single cache defeating option possible
		  // though some browsers still do what they want with it so this
		  // doesn't always work.
		  //
		  If noCache Then
		    Request.header("Pragma-directive") = "no-cache"
		    Request.header("Cache-directive") = "no-cache"
		    Request.header("Cache-control") = "no-store, no-cache, max-age=0, must-revalidate, post-check=0, pre-check=0"
		    Request.header("Pragma") = "no-cache"
		    Request.header("Expires") = "Sat, 26 Jul 1997 05:00:00 GMT"
		  End If
		  
		  //
		  // these headers may not be necessary
		  // but I am sending them to help with some theoritical problems
		  //
		  
		  // Request.header( "X-Content-Type-Options") = "nosniff"
		  // Request.header( "X-Frame-Options") = "SAMEORIGIN"
		  Request.header( "Content-Transfer-Encoding") = "binary"
		  
		  //
		  // additionally we SHOULD be sending a Content-Length header with the full size of the file and not just the amount of data we are sending
		  // xojo will not allow me to add to this header and instead automatically generates the header based on the amount of data actually being sent
		  // in this partial response. Though this is incorrect it doesn't seem to cause the browsers too much trouble and it still works.
		  // it would be nice to be able to override this.
		  
		  //
		  // if it's a full page request then we want to set the start and end at the total size of the file
		  //
		  
		  If Not isRange Then
		    startRange = 0
		    endRange = myFile.Length
		  End If
		  
		  //
		  // use the cached stream if available, otherwise create it.
		  //
		  if myStream = nil then
		    try
		      myStream = BinaryStream.Open( myFile, False)
		    Catch re As runtimeException
		      //
		      // an error occurred while trying to open the file for read only
		      // send an error to the browser and return
		      // perhaps a 403 forbidden error? Since it's a permissions problem
		      // that is likely keeping us from opening the file
		      //
		      request.Status = 403
		      Return True
		    End Try
		  end if
		  
		  //
		  // if we're not starting at the beginning then advance us into the file
		  // or if we're asking for a place not where we left off also adjust it
		  if myStream.Position <> startRange then
		    myStream.Position = startRange
		  End If
		  
		  //
		  // read and send in 64k chunks just like the regular webFile
		  // you can alternatively just do this:
		  //  request.Print( b.read( endRange - startRange + 1))
		  // but that is a real memory waste and you won't be able to serve up files bigger than 3gb 
		  //
		  
		  Dim bytesSent As Integer
		  Dim bytesLeft As Integer = (endRange + 1) - myStream.Position // how much left to send before we're done
		  Dim bytesToSend As Integer // this loops amount to send. It will be the readChunk size unless there isn't that much left in the request
		  Const readChunk = 65536 // 64k chunks to read from the file at a time. This is the same default as the regular webFile but you can change it if you choose
		  
		  While bytesLeft > 0 And Not myStream.EOF
		    
		    //
		    // figure out how much to read this time through the loop
		    //
		    If bytesLeft < readChunk Then
		      bytesToSend = bytesLeft
		    Else
		      bytesToSend = readChunk
		    End If
		    
		    request.Print( myStream.read( bytesToSend))
		    bytesLeft = bytesLeft - bytesToSend
		    
		  Wend
		  
		  return true
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Shared Function handleSpecialURL(request as WebRequest) As Boolean
		  // call this from the handleSpecialURL event
		  // if it was a mediaFile request it will handle it and return true
		  // if it's not a media file request then we will return false so you can continue to process in the handleSpecial event
		  
		  
		  Dim pathParts() As String = Split( request.Path, "/")
		  
		  //must have at least 4 elements, /special/urlPrefix/uniqueID/filename
		  // but the /special is filtered out by xojo before it gets sent to us, so just look for 3
		  //
		  
		  If pathParts.Ubound <> 2 Then
		    // not one of ours
		    Return False
		  End If
		  
		  If pathParts( 0) <> cMediaFile.urlPrefix Then
		    // not one of ours
		    Return False
		  End If
		  
		  //
		  // idiot check to make sure our index is valid
		  // use the cMediaFile.open to create a media file object to make sure this doesn't happen
		  //
		  
		  If cMediaFile.MediaFileIndex = Nil Then
		    // this is an error
		    request.Status = 500
		    request.Print( "<h1>cMediaFile Index is invalid. Please use the .Open method to create cMediaFile objects!</h1>")
		    Return True
		  end if
		  
		  // see if the uniqueID is still in our index
		  
		  If Not cMediaFile.MediaFileIndex.HasKey( pathParts( 1)) Then
		    request.Status = 410 // gone
		    request.Print( "The cMediaFile object has gone out of scope before your request was received")
		    Return True
		  End If
		  
		  // get the object
		  //
		  Dim w As WeakRef = WeakRef( cMediaFile.MediaFileIndex.Value( pathParts( 1)))
		  
		  // it should not be possible for this to happen, if the class has detructed then it should be removed from our index
		  // but you never know...
		  If w.Value = Nil Then
		    request.Status = 410 // gone
		    request.Print( "The cMediaFile object has gone out of scope without removing itself from the index.")
		    Return True
		  End If
		  
		  Dim workMediaFile As cMediaFile = cMediaFile( w.Value)
		  // and pass it the request
		  
		  If workMediaFile.HandleRequest( request) Then
		    Return True
		  Else
		    // an error happened in the actual class
		    request.Status = 500
		    request.Print( "an error occurred processing the cMediaFile request")
		    Return True
		  end if
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Shared Function open(theFile as FolderItem) As cMediaFile
		  //
		  // Safari and Mobile Safari require that a server support the Range header in order to serve up a movie or an audio file
		  // the built in WebFile support in Xojo does not support this at the moment and so it's necessary to add in some support for that
		  // luckily we can do that via the handle special capability in the web target.
		  //
		  
		  //
		  // idiot check for a nil FolderItem
		  // check for existing or not will be done when it's asked for, but it can't be nil
		  //
		  
		  If theFile = Nil Then
		    Return Nil
		  end if
		  
		  Dim workMediaFile As New cMediaFile
		  workMediaFile.myFile = theFile
		  workMediaFile.uniqueID = Format( Microseconds, "#.#####")
		  
		  //
		  // the url format:
		  //
		  //  /special for the handleSpecialURL handler in the app class you could remove this and manage it through the HandleURL handler now, this keeps it compatible with older versions of the IDE
		  // the URL prefix constant that you can change. The defailt is just "mediaFile"
		  // the uniqueID of the class that was set when you created it.
		  // the name of the file URL encoded though thats not important for receiving it, it is just for link readability.
		  //
		  // when you set the link to something you can add "?download=true" to the end of the URL to force it to download.
		  // this way you can use the same object for both a display and a separate download link rather than having to create 2 and set a property in one to force it.
		  // this is different from how the xojo webFile behaves.
		  //
		  // /special/mediaFile/1234567890/someMovie.mp4
		  //
		  
		  workMediaFile.url = "/special/" + urlPrefix + "/" + workMediaFile.uniqueID + "/" + EncodeURLComponent( theFile.Name)
		  
		  //
		  // make sure the dictionary is valid so that we can find it when the request comes in
		  //
		  If cMediaFile.MediaFileIndex = Nil Then
		    cMediaFile.MediaFileIndex = New Dictionary
		  End If
		  
		  
		  
		  
		  //
		  // save a weak ref in the dictionary so that when the local reference to the class goes out of scope it
		  // can get it's destructor event and remove itself from the index as you're not longer needing it,
		  // removes the necessity of forcing you to call .close or something like that.
		  //
		  
		  Dim w As New WeakRef( workMediaFile)
		  cMediaFile.MediaFileIndex.Value( workMediaFile.uniqueID) = w
		  
		  
		  return workMediaFile
		End Function
	#tag EndMethod


	#tag Note, Name = Usage
		
		This is free and unencumbered software released into the public domain.
		
		Anyone is free to copy, modify, publish, use, compile, sell, or
		distribute this software, either in source code form or as a compiled
		binary, for any purpose, commercial or non-commercial, and by any
		means.
		
		In jurisdictions that recognize copyright laws, the author or authors
		of this software dedicate any and all copyright interest in the
		software to the public domain. We make this dedication for the benefit
		of the public at large and to the detriment of our heirs and
		successors. We intend this dedication to be an overt act of
		relinquishment in perpetuity of all present and future rights to this
		software under copyright law.
		
		THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
		EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
		MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
		IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
		OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
		ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
		OTHER DEALINGS IN THE SOFTWARE.
		
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
		
	#tag EndNote


	#tag Property, Flags = &h0
		Shared MediaFileIndex As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h0
		mimeType As String
	#tag EndProperty

	#tag Property, Flags = &h0
		myFile As FolderItem
	#tag EndProperty

	#tag Property, Flags = &h0
		#tag Note
			the binaryStream To the file Is held open after the first request Until the Object Is destructed To
			make further requests faster As the file does Not have To be re-opened And re-cached by the OS.
			
		#tag EndNote
		myStream As BinaryStream
	#tag EndProperty

	#tag Property, Flags = &h0
		#tag Note
			set To True To add the headers that should keep anything from being cached though this doesn't really work on most browsers 
			who do whatever the heck they want to anyway
		#tag EndNote
		noCache As Boolean = false
	#tag EndProperty

	#tag Property, Flags = &h0
		uniqueID As string
	#tag EndProperty

	#tag Property, Flags = &h0
		url As string
	#tag EndProperty


	#tag Constant, Name = urlPrefix, Type = String, Dynamic = False, Default = \"mediaFile", Scope = Public
	#tag EndConstant


	#tag ViewBehavior
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			Type="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			Type="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
