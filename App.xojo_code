#tag Class
Protected Class App
Inherits WebApplication
	#tag Event
		Function HandleSpecialURL(Request As WebRequest) As Boolean
		  
		  //
		  // this must be added to the app.HandleSpecialURL event in order for the requests to be handled
		  //
		  If cMediaFile.handleSpecialURL( request) Then
		    Return True
		  End If
		End Function
	#tag EndEvent


	#tag ViewBehavior
	#tag EndViewBehavior
End Class
#tag EndClass
