#tag Class
Protected Class App
Inherits Application
	#tag Event
		Sub Open()
		  'Dim prefs As VariantVolume = VariantVolume.Create(SpecialFolder.Desktop.Child("httpreqconfig.dat"))
		  'Call prefs.CreateDirectory("HTTP", True)
		  'prefs.SetValue("HTTP.Client") = "Profiles.0.HTTP.Client"
		  'prefs.SetType("HTTP.Client") = VariantVolume.TYPE_DIRECTORY
		  'prefs.SetValue("HTTP.Server") = "Profiles.0.HTTP.Server"
		  'prefs.SetType("HTTP.Server") = VariantVolume.TYPE_DIRECTORY
		  'Call prefs.CreateDirectory("Profiles.0.HTTP.Client", True)
		  'Call prefs.CreateDirectory("Profiles.0.HTTP.Server", True)
		  'Call prefs.CreateDirectory("GUI.Options", True)
		  'prefs.SetValue("HTTP.Client.Protocol") = 1.1
		  'prefs.SetValue("HTTP.Server.Protocol") = 1.1
		  'prefs.SetValue("HTTP.Client.GZip") = True
		  'prefs.SetValue("HTTP.Server.GZip") = True
		  'prefs.SetValue("HTTP.Server.EnforceTypes") = True
		  'prefs.Close
		  'Quit
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h0
		Sub Assert(BoolExpression As Boolean)
		  If Not BoolExpression Then Raise New RuntimeException
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function CreateNewTestPrefs() As FolderItem
		  Dim preffile As FolderItem = SpecialFolder.Desktop.Child("VariantVolumeTest.dat")
		  Dim v As VariantVolume = VariantVolume.Create(preffile)
		  If Not v.CreateDirectory("1.2.3.4", True) Then Break
		  If Not v.CreateDirectory("1.7.8", True) Then Break
		  If Not v.CreateDirectory("1.2.3.4.5", True) Then Break
		  v.SetValue("1.7.3.4") = "1.2.3.4.5"
		  v.SetType("1.7.3.4") = v.TYPE_SYMLINK
		  If Not v.CreateDirectory("1.7.3.4.12", True) Then Break
		  If Not v.CreateDirectory("1.7.3.4.01", True) Then Break
		  v.SetValue("1.7.3.4.12.Test") = "Hello, world!"
		  v.SetValue("1.7.3.4.12.Dalink") = "App.Config.Color"
		  v.SetType("1.7.3.4.12.Dalink") = v.TYPE_SYMLINK
		  v.SetValue("1.7.3.4.Link") = "1.2.Link"
		  v.SetType("1.7.3.4.Link") = VariantVolume.TYPE_SYMLINK
		  v.SetValue("1.7.3.4.Name") = "Andrew"
		  v.SetValue("1.7.3.4.Password") = "Password123"
		  v.SetValue("1.Link") = "1.2.Link"
		  v.SetType("1.Link") = VariantVolume.TYPE_SYMLINK
		  v.SetValue("1.2.Link") = "1.2.3.Link"
		  v.SetType("1.2.Link") = VariantVolume.TYPE_SYMLINK
		  v.SetValue("1.2.3.Link") = "1.2.3.4.Link"
		  v.SetType("1.2.3.Link") = VariantVolume.TYPE_SYMLINK
		  v.SetValue("1.2.3.4.Link") = &c00000000
		  If Not v.CreateDirectory("App.Config", True) Then Break
		  v.SetValue("App.Config.Color") = "1.link"
		  v.SetType("App.Config.Color") = VariantVolume.TYPE_SYMLINK
		  v.SetValue("App.Config.Color") = &cFF000000
		  v.Close
		  Return preffile
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub PopulateVolume(v As VariantVolume)
		  Dim oi As Runtime.ObjectIterator = Runtime.IterateObjects
		  Dim items As New Dictionary
		  Dim d As New Date
		  Dim root As String = d.SQLDateTime
		  Call v.CreateDirectory(root, True)
		  v.SetValue("lastrun", False) = root
		  v.SetType("lastrun") = v.TYPE_SYMLINK
		  While oi.MoveNext
		    Dim p() As Introspection.PropertyInfo = Introspection.GetType(oi.Current).GetProperties
		    For i As Integer = 0 To UBound(p)
		      Dim value As Variant = p(i).Value(oi.Current)
		      Dim path As String = Introspection.GetType(oi.Current).Name
		      If items.HasKey(path) Then
		        Dim x As Integer
		        While items.HasKey(path + Str(x))
		          x = x + 1
		        Wend
		        path = path + Str(x)
		      End If
		      Call v.CreateDirectory("lastrun." + path, True)
		      Try
		        v.SetValue("lastrun." + path + v.PathSeparator + p(i).Name) = value
		      Catch
		        Continue
		      End Try
		    Next
		  Wend
		  
		End Sub
	#tag EndMethod


	#tag Note, Name = Untitled
		
		  ''
		  '''Dim oi As Runtime.ObjectIterator = Runtime.IterateObjects
		  '''Dim items As New Dictionary
		  '''While oi.MoveNext
		  '''Dim p() As Introspection.PropertyInfo = Introspection.GetType(oi.Current).GetProperties
		  '''For i As Integer = 0 To UBound(p)
		  '''Dim value As Variant = p(i).Value(oi.Current)
		  '''Dim path As String = Introspection.GetType(oi.Current).Name
		  '''If items.HasKey(path) Then
		  '''Dim x As Integer
		  '''While items.HasKey(path + Str(x))
		  '''x = x + 1
		  '''Wend
		  '''path = path + Str(x)
		  '''End If
		  '''Call v.CreateDirectory(path)
		  '''Try
		  '''v.SetValue(path + PathSeparator + p(i).Name) = value
		  '''Catch
		  '''Continue
		  '''End Try
		  '''Next
		  '''Wend
	#tag EndNote


	#tag Constant, Name = kEditClear, Type = String, Dynamic = False, Default = \"&Delete", Scope = Public
		#Tag Instance, Platform = Windows, Language = Default, Definition  = \"&Delete"
		#Tag Instance, Platform = Linux, Language = Default, Definition  = \"&Delete"
	#tag EndConstant

	#tag Constant, Name = kFileQuit, Type = String, Dynamic = False, Default = \"&Quit", Scope = Public
		#Tag Instance, Platform = Windows, Language = Default, Definition  = \"E&xit"
	#tag EndConstant

	#tag Constant, Name = kFileQuitShortcut, Type = String, Dynamic = False, Default = \"", Scope = Public
		#Tag Instance, Platform = Mac OS, Language = Default, Definition  = \"Cmd+Q"
		#Tag Instance, Platform = Linux, Language = Default, Definition  = \"Ctrl+Q"
	#tag EndConstant


	#tag ViewBehavior
	#tag EndViewBehavior
End Class
#tag EndClass
