#tag Window
Begin Window Window1
   BackColor       =   &hFFFFFF
   Backdrop        =   ""
   CloseButton     =   True
   Composite       =   False
   Frame           =   0
   FullScreen      =   False
   HasBackColor    =   False
   Height          =   4.0e+2
   ImplicitInstance=   True
   LiveResize      =   True
   MacProcID       =   0
   MaxHeight       =   32000
   MaximizeButton  =   False
   MaxWidth        =   32000
   MenuBar         =   1658941439
   MenuBarVisible  =   True
   MinHeight       =   64
   MinimizeButton  =   True
   MinWidth        =   64
   Placement       =   0
   Resizeable      =   True
   Title           =   "Variant Volume Explorer"
   Visible         =   True
   Width           =   6.45e+2
   Begin Listbox Listbox1
      AutoDeactivate  =   True
      AutoHideScrollbars=   True
      Bold            =   ""
      Border          =   True
      ColumnCount     =   3
      ColumnsResizable=   True
      ColumnWidths    =   "75%"
      DataField       =   ""
      DataSource      =   ""
      DefaultRowHeight=   -1
      Enabled         =   True
      EnableDrag      =   True
      EnableDragReorder=   True
      GridLinesHorizontal=   0
      GridLinesVertical=   0
      HasHeading      =   True
      HeadingIndex    =   -1
      Height          =   400
      HelpTag         =   ""
      Hierarchical    =   True
      Index           =   -2147483648
      InitialParent   =   ""
      InitialValue    =   "Name	Type	Value"
      Italic          =   ""
      Left            =   0
      LockBottom      =   True
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   True
      LockTop         =   True
      RequiresSelection=   ""
      Scope           =   0
      ScrollbarHorizontal=   ""
      ScrollBarVertical=   True
      SelectionType   =   1
      TabIndex        =   0
      TabPanelIndex   =   0
      TabStop         =   True
      TextFont        =   "System"
      TextSize        =   0
      TextUnit        =   0
      Top             =   0
      Underline       =   ""
      UseFocusRing    =   True
      Visible         =   True
      Width           =   645
      _ScrollWidth    =   -1
   End
End
#tag EndWindow

#tag WindowCode
	#tag Event
		Sub Open()
		  'Dim f As FolderItem = GetOpenFolderItem("")
		  Dim v As VariantVolume = VariantVolume.Open(App.CreateNewTestPrefs)
		  AddHandler v.DeserializeValue, WeakAddressOf DeserializerHandler
		  AddHandler v.SerializeValue, WeakAddressOf SerializerHandler
		  Me.Explore(v)
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h21
		Private Function DeserializerHandler(Sender As VariantVolume, ByteStream As Readable, Type As Integer, ByRef Value As Variant) As Boolean
		  Break
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Explore(v As VariantVolume)
		  mVolume = v
		  Listbox1.DeleteAllRows
		  Listbox1.AddFolder("/")
		  Listbox1.RowTag(Listbox1.LastIndex) = RootDir:0
		  Listbox1.Cell(Listbox1.LastIndex, 1) = "Directory"
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function Locate(File As FolderItem) As String
		  Dim s As String = File.AbsolutePath
		  While InStr(s, "//") > 0
		    s = ReplaceAll(s, "//", "/")
		  Wend
		  s = ReplaceAll(s, "/", ".")
		  If Left(s, 1) = "." Then s = Right(s, s.Len - 1)
		  Return s.Trim
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function RootDir() As FolderItem
		  Return mVolume.GetValue("", False)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function SerializerHandler(Sender As VariantVolume, ByteStream As Writeable, ByRef Type As Integer, Value As Variant) As Boolean
		  Break
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function TypeName(Path As String) As String
		  Try
		    Select Case mVolume.GetType(Path)
		    Case mVolume.TYPE_PNG
		      Return "Image"
		    Case mVolume.TYPE_FILE
		      Return "File path"
		    Case mVolume.TYPE_DIRECTORY
		      Return "Directory"
		    Case mVolume.TYPE_SYMLINK
		      Return "Symbolic link"
		    Case mVolume.TYPE_INVALID
		      Return ""
		    Case Variant.TypeBoolean
		      Return "Boolean"
		    Case Variant.TypeColor
		      Return "Color"
		    Case Variant.TypeCurrency
		      Return "Currency"
		    Case Variant.TypeDate
		      Return "Date"
		    Case Variant.TypeDouble
		      Return "Double"
		    Case Variant.TypeInteger
		      Return "Integer"
		    Case Variant.TypeNil
		      Return "Null"
		    Case Variant.TypeString
		      Return "String"
		    Else
		      Return "Custom Type"
		    End Select
		  Catch
		    Return "Unknown type"
		  End Try
		  
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function ValueName(Path As String) As String
		  Try
		    Select Case mVolume.GetType(Path)
		    Case mVolume.TYPE_SYMLINK
		      Dim link As String = mVolume.GetValue(Path, False)
		      Return ValueName(link)
		    Case Variant.TypeBoolean
		      Return Str(mVolume.GetValue(Path).BooleanValue)
		    Case Variant.TypeColor
		      Dim c As Color = mVolume.GetValue(Path)
		      Return "#" + Left(Hex(c.Red) + "00", 2) + Left(Hex(c.Green) + "00", 2) + Left(Hex(c.Blue) + "00", 2)
		    Case Variant.TypeCurrency, Variant.TypeDouble, Variant.TypeInteger
		      Return Format(mVolume.GetValue(Path), "###,###,###,###,##0.00")
		    Case Variant.TypeDate
		      Return mVolume.GetValue(Path).DateValue.SQLDateTime
		    Case Variant.TypeString
		      Return mVolume.GetValue(Path)
		    Else
		      Return "No String Value"
		    End Select
		  Catch
		    Return "No Value"
		  End Try
		End Function
	#tag EndMethod


	#tag Property, Flags = &h0
		HideMetafiles As Boolean = True
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected mVolume As VariantVolume
	#tag EndProperty


#tag EndWindowCode

#tag Events Listbox1
	#tag Event
		Sub ExpandRow(row As Integer)
		  Dim f As FolderItem = Pair(Me.RowTag(row)).Left
		  Dim parent As String = Listbox1.CellTag(row, 0)
		  Dim indent As Integer = Pair(Me.RowTag(row)).Right + 1
		  Dim c As Integer = f.Count '- 1
		  Dim files(), folders() As String
		  For i As Integer = 1 To c
		    Dim item As FolderItem = f.Item(i)
		    If Right(item.Name, 5) = ".META" And HideMetafiles Then Continue
		    If item.Directory Then
		      folders.Append(item.Name)
		    Else
		      files.Append(item.Name)
		    End If
		  Next
		  files.Sort
		  folders.Sort
		  For i As Integer = UBound(folders) DownTo 0
		    files.Insert(0, folders(i))
		  Next
		  For i As Integer = UBound(files) DownTo 0
		    Dim item As FolderItem = f.Child(files(i))
		    If item.Directory Then
		      Listbox1.InsertFolder(row + 1, item.Name, indent)
		      Listbox1.RowTag(Listbox1.LastIndex) = item:indent
		    Else
		      Dim type As Integer = mVolume.GetType(item.Name)
		      Listbox1.InsertRow(row + 1, item.Name, indent)
		      Dim tv As Pair = type:mVolume.GetValue(Locate(item))
		      Listbox1.RowTag(Listbox1.LastIndex) = tv
		    End If
		    Dim p As String = parent
		    If parent.Trim <> "" Then p = p + "."
		    p = p + item.Name
		    Listbox1.CellTag(Listbox1.LastIndex, 0) = p
		    Listbox1.Cell(Listbox1.LastIndex, 1) = TypeName(p)
		    Listbox1.Cell(Listbox1.LastIndex, 2) = ValueName(p)
		  Next
		End Sub
	#tag EndEvent
#tag EndEvents
