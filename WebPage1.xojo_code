#tag WebPage
Begin WebPage WebPage1
   Compatibility   =   ""
   Cursor          =   0
   Enabled         =   True
   Height          =   758
   HelpTag         =   ""
   HorizontalCenter=   0
   ImplicitInstance=   True
   Index           =   -2147483648
   IsImplicitInstance=   False
   Left            =   0
   LockBottom      =   False
   LockHorizontal  =   False
   LockLeft        =   False
   LockRight       =   False
   LockTop         =   False
   LockVertical    =   False
   MinHeight       =   400
   MinWidth        =   600
   Style           =   "None"
   TabOrder        =   0
   Title           =   "Range Capable cMediaFile Class Example"
   Top             =   0
   VerticalCenter  =   0
   Visible         =   True
   Width           =   968
   ZIndex          =   1
   _DeclareLineRendered=   False
   _HorizontalPercent=   0.0
   _ImplicitInstance=   False
   _IsEmbedded     =   False
   _Locked         =   False
   _NeedsRendering =   True
   _OfficialControl=   False
   _OpenEventFired =   False
   _ShownEventFired=   False
   _VerticalPercent=   0.0
   Begin WebMoviePlayer MoviePlayerFail
      AllowFullScreen =   False
      AutoPlay        =   True
      Cursor          =   0
      DesktopURL      =   ""
      Enabled         =   True
      Height          =   159
      HelpTag         =   ""
      HorizontalCenter=   0
      Index           =   -2147483648
      Left            =   172
      LockBottom      =   False
      LockedInPosition=   False
      LockHorizontal  =   False
      LockLeft        =   True
      LockRight       =   False
      LockTop         =   True
      LockVertical    =   False
      MobileCellularURL=   ""
      MobileWifiURL   =   ""
      Scope           =   0
      Style           =   "-1"
      TabOrder        =   -1
      Top             =   20
      VerticalCenter  =   0
      Visible         =   True
      Width           =   549
      ZIndex          =   1
      _NeedsRendering =   True
   End
   Begin WebLabel Label1
      Cursor          =   1
      Enabled         =   True
      HasFocusRing    =   True
      Height          =   89
      HelpTag         =   ""
      HorizontalCenter=   0
      Index           =   -2147483648
      Left            =   20
      LockBottom      =   False
      LockedInPosition=   False
      LockHorizontal  =   False
      LockLeft        =   True
      LockRight       =   False
      LockTop         =   True
      LockVertical    =   False
      Multiline       =   True
      Scope           =   0
      Style           =   "-1"
      TabOrder        =   0
      Text            =   "Using a built in webFile this movie player will refuse to play the movie on Safari"
      TextAlign       =   0
      Top             =   57
      VerticalCenter  =   0
      Visible         =   True
      Width           =   140
      ZIndex          =   1
      _NeedsRendering =   True
   End
   Begin WebLabel Label2
      Cursor          =   1
      Enabled         =   True
      HasFocusRing    =   True
      Height          =   89
      HelpTag         =   ""
      HorizontalCenter=   0
      Index           =   -2147483648
      Left            =   20
      LockBottom      =   False
      LockedInPosition=   False
      LockHorizontal  =   False
      LockLeft        =   True
      LockRight       =   False
      LockTop         =   True
      LockVertical    =   False
      Multiline       =   True
      Scope           =   0
      Style           =   "0"
      TabOrder        =   0
      Text            =   "Using the range capable cMediaFile class allows it to load "
      TextAlign       =   0
      Top             =   241
      VerticalCenter  =   0
      Visible         =   True
      Width           =   140
      ZIndex          =   1
      _NeedsRendering =   True
   End
   Begin WebMoviePlayer MoviePlayerWorks
      AllowFullScreen =   False
      AutoPlay        =   True
      Cursor          =   0
      DesktopURL      =   ""
      Enabled         =   True
      Height          =   326
      HelpTag         =   ""
      HorizontalCenter=   0
      Index           =   -2147483648
      Left            =   172
      LockBottom      =   False
      LockedInPosition=   False
      LockHorizontal  =   False
      LockLeft        =   True
      LockRight       =   False
      LockTop         =   True
      LockVertical    =   False
      MobileCellularURL=   ""
      MobileWifiURL   =   ""
      Scope           =   0
      Style           =   "0"
      TabOrder        =   -1
      Top             =   204
      VerticalCenter  =   0
      Visible         =   True
      Width           =   549
      ZIndex          =   1
      _NeedsRendering =   True
   End
   Begin WebLink DownloadLink
      Cursor          =   0
      Enabled         =   True
      HasFocusRing    =   True
      Height          =   22
      HelpTag         =   ""
      HorizontalCenter=   0
      Index           =   -2147483648
      Left            =   360
      LockBottom      =   False
      LockedInPosition=   False
      LockHorizontal  =   False
      LockLeft        =   True
      LockRight       =   False
      LockTop         =   True
      LockVertical    =   False
      Multiline       =   False
      Scope           =   0
      Style           =   "-1"
      TabOrder        =   1
      Target          =   1
      Text            =   "Download Link Example"
      TextAlign       =   0
      Top             =   542
      URL             =   ""
      VerticalCenter  =   0
      Visible         =   True
      Width           =   172
      ZIndex          =   1
      _NeedsRendering =   True
   End
End
#tag EndWebPage

#tag WindowCode
	#tag Event
		Sub Open()
		  
		  dim f as FolderItem
		  
		  #If DebugBuild Then
		    f = app.ExecutableFile.parent.parent.Child( "test.mp4")
		  #Else
		    f = GetFolderItem( "test.mp4")
		  #EndIf
		  
		  //
		  // test with a regular Xojo webFile
		  //
		  myMovieWebFile = webFile.Open( f)
		  myMovieWebFile.MIMEType = "video/mp4"
		  
		  
		  //
		  // test with cMediaFile
		  //
		  
		  myMovieMediaFile = cMediaFile.open( f)
		  myMovieMediaFile.mimeType = "video/mp4"
		  
		  //
		  // download link example
		  //
		  
		  DownloadLink.URL = myMovieMediaFile.url + "?download=true"
		End Sub
	#tag EndEvent


	#tag Property, Flags = &h0
		myMovieMediaFile As cMediaFile
	#tag EndProperty

	#tag Property, Flags = &h0
		myMovieWebFile As webFile
	#tag EndProperty


#tag EndWindowCode

#tag Events MoviePlayerFail
	#tag Event
		Sub Shown()
		  Me.DesktopURL = myMovieWebFile.URL
		  
		End Sub
	#tag EndEvent
#tag EndEvents
#tag Events MoviePlayerWorks
	#tag Event
		Sub Shown()
		  Me.DesktopURL = myMovieMediaFile.URL
		  
		End Sub
	#tag EndEvent
#tag EndEvents
#tag ViewBehavior
	#tag ViewProperty
		Name="Cursor"
		Visible=true
		Group="Behavior"
		InitialValue="0"
		Type="Integer"
		EditorType="Enum"
		#tag EnumValues
			"0 - Automatic"
			"1 - Standard Pointer"
			"2 - Finger Pointer"
			"3 - IBeam"
			"4 - Wait"
			"5 - Help"
			"6 - Arrow All Directions"
			"7 - Arrow North"
			"8 - Arrow South"
			"9 - Arrow East"
			"10 - Arrow West"
			"11 - Arrow Northeast"
			"12 - Arrow Northwest"
			"13 - Arrow Southeast"
			"14 - Arrow Southwest"
			"15 - Splitter East West"
			"16 - Splitter North South"
			"17 - Progress"
			"18 - No Drop"
			"19 - Not Allowed"
			"20 - Vertical IBeam"
			"21 - Crosshair"
		#tag EndEnumValues
	#tag EndViewProperty
	#tag ViewProperty
		Name="Enabled"
		Group="Behavior"
		InitialValue="True"
		Type="Boolean"
	#tag EndViewProperty
	#tag ViewProperty
		Name="Height"
		Visible=true
		Group="Behavior"
		InitialValue="400"
		Type="Integer"
	#tag EndViewProperty
	#tag ViewProperty
		Name="HelpTag"
		Visible=true
		Group="Behavior"
		Type="String"
		EditorType="MultiLineEditor"
	#tag EndViewProperty
	#tag ViewProperty
		Name="HorizontalCenter"
		Group="Behavior"
		Type="Integer"
	#tag EndViewProperty
	#tag ViewProperty
		Name="Index"
		Group="ID"
		InitialValue="-2147483648 "
		Type="Integer"
	#tag EndViewProperty
	#tag ViewProperty
		Name="IsImplicitInstance"
		Group="Behavior"
		Type="Boolean"
	#tag EndViewProperty
	#tag ViewProperty
		Name="Left"
		Group="Position"
		InitialValue="0"
		Type="Integer"
	#tag EndViewProperty
	#tag ViewProperty
		Name="LockBottom"
		Group="Behavior"
		InitialValue="False"
		Type="Boolean"
	#tag EndViewProperty
	#tag ViewProperty
		Name="LockHorizontal"
		Group="Behavior"
		Type="Boolean"
	#tag EndViewProperty
	#tag ViewProperty
		Name="LockLeft"
		Group="Behavior"
		InitialValue="False"
		Type="Boolean"
	#tag EndViewProperty
	#tag ViewProperty
		Name="LockRight"
		Group="Behavior"
		InitialValue="False"
		Type="Boolean"
	#tag EndViewProperty
	#tag ViewProperty
		Name="LockTop"
		Group="Behavior"
		InitialValue="False"
		Type="Boolean"
	#tag EndViewProperty
	#tag ViewProperty
		Name="LockVertical"
		Group="Behavior"
		Type="Boolean"
	#tag EndViewProperty
	#tag ViewProperty
		Name="MinHeight"
		Visible=true
		Group="Behavior"
		InitialValue="400"
		Type="Integer"
	#tag EndViewProperty
	#tag ViewProperty
		Name="MinWidth"
		Visible=true
		Group="Behavior"
		InitialValue="600"
		Type="Integer"
	#tag EndViewProperty
	#tag ViewProperty
		Name="myMovieWebFile"
		Group="Behavior"
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
		Name="TabOrder"
		Group="Behavior"
		Type="Integer"
	#tag EndViewProperty
	#tag ViewProperty
		Name="Title"
		Visible=true
		Group="Behavior"
		InitialValue="Untitled"
		Type="String"
		EditorType="MultiLineEditor"
	#tag EndViewProperty
	#tag ViewProperty
		Name="Top"
		Group="Position"
		InitialValue="0"
		Type="Integer"
	#tag EndViewProperty
	#tag ViewProperty
		Name="VerticalCenter"
		Group="Behavior"
		Type="Integer"
	#tag EndViewProperty
	#tag ViewProperty
		Name="Visible"
		Group="Behavior"
		InitialValue="True"
		Type="Boolean"
	#tag EndViewProperty
	#tag ViewProperty
		Name="Width"
		Visible=true
		Group="Behavior"
		InitialValue="600"
		Type="Integer"
	#tag EndViewProperty
	#tag ViewProperty
		Name="ZIndex"
		Group="Behavior"
		InitialValue="1"
		Type="Integer"
	#tag EndViewProperty
	#tag ViewProperty
		Name="_DeclareLineRendered"
		Group="Behavior"
		InitialValue="False"
		Type="Boolean"
	#tag EndViewProperty
	#tag ViewProperty
		Name="_HorizontalPercent"
		Group="Behavior"
		Type="Double"
	#tag EndViewProperty
	#tag ViewProperty
		Name="_ImplicitInstance"
		Group="Behavior"
		InitialValue="False"
		Type="Boolean"
	#tag EndViewProperty
	#tag ViewProperty
		Name="_IsEmbedded"
		Group="Behavior"
		Type="Boolean"
	#tag EndViewProperty
	#tag ViewProperty
		Name="_Locked"
		Group="Behavior"
		Type="Boolean"
	#tag EndViewProperty
	#tag ViewProperty
		Name="_NeedsRendering"
		Group="Behavior"
		InitialValue="True"
		Type="Boolean"
	#tag EndViewProperty
	#tag ViewProperty
		Name="_OfficialControl"
		Group="Behavior"
		InitialValue="False"
		Type="Boolean"
	#tag EndViewProperty
	#tag ViewProperty
		Name="_OpenEventFired"
		Group="Behavior"
		Type="Boolean"
	#tag EndViewProperty
	#tag ViewProperty
		Name="_ShownEventFired"
		Group="Behavior"
		Type="Boolean"
	#tag EndViewProperty
	#tag ViewProperty
		Name="_VerticalPercent"
		Group="Behavior"
		Type="Double"
	#tag EndViewProperty
#tag EndViewBehavior
