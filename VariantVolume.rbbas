#tag Class
Class VariantVolume
	#tag Method, Flags = &h0
		Sub Close()
		  mVolume.Flush
		  mVolume = Nil
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub Constructor(VolumeRef As VirtualVolume)
		  If VolumeRef = Nil Then Raise New NilObjectException
		  mVolume = VolumeRef
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		 Shared Function Create(RegFile As FolderItem) As VariantVolume
		  Try
		    Return New VariantVolume(RegFile.CreateVirtualVolume)
		  Catch
		    Return Nil
		  End Try
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function CreateDirectory(Path As String) As Boolean
		  Dim f As FolderItem = Me.Locate(Path, True)
		  If f = Nil Or f.Exists Then Return False
		  f.CreateAsFolder
		  Me.WriteType(f, TYPE_DIRECTORY)
		  Return True
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Delete(Path As String, Dereference As Boolean = False)
		  Dim f As FolderItem = Me.Locate(Path, Dereference)
		  If f <> Nil And f.AbsolutePath <> mVolume.Root.AbsolutePath Then
		    f.Parent.Child(f.Name + ".META").Delete
		    f.Delete
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function GetType(Path As String) As Integer
		  Dim meta As FolderItem = Me.Locate(Path, False)
		  If meta <> Nil Then Return Me.ReadType(meta)
		  Return TYPE_INVALID
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function GetValue(Path As String, Dereference As Boolean = True) As Variant
		  Dim f As FolderItem = Me.Locate(Path, Dereference)
		  If f <> Nil Then Return Me.ReadValue(f)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function Locate(Path As String, Dereference As Boolean) As FolderItem
		  Dim parts() As String = Split(Path, ".")
		  Dim item As FolderItem = mVolume.Root
		  For i As Integer = 0 To UBound(parts)
		    If item <> Nil Then
		      item = item.Child(parts(i))
		      Select Case True
		      Case Me.ReadType(item) = TYPE_SYMLINK And Dereference
		        item = Me.Locate(Me.ReadValue(item), True)
		      Case Not item.Directory And i <> UBound(parts)
		        Return Nil
		      End Select
		    Else
		      Return Nil
		    End If
		  Next
		  Return item
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		 Shared Function Open(RegFile As FolderItem) As VariantVolume
		  Try
		    Return New VariantVolume(RegFile.OpenAsVirtualVolume)
		  Catch
		    Return Nil
		  End Try
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function ReadType(File As FolderItem) As Integer
		  If File.AbsolutePath = mVolume.Root.AbsolutePath Then Return TYPE_DIRECTORY
		  If File <> Nil And File.Parent <> Nil Then File = File.Parent.Child(File.Name + ".META")
		  If File = Nil Or Not File.Exists Or File.Directory Then Return TYPE_INVALID
		  Dim bs As BinaryStream = BinaryStream.Open(File)
		  bs.LittleEndian = False
		  Dim type As Integer = bs.ReadInt32
		  bs.Close
		  Return type
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function ReadValue(File As FolderItem) As Variant
		  If File.AbsolutePath = mVolume.Root.AbsolutePath Then Return mVolume.Root
		  Dim reader As BinaryStream
		  Try
		    #pragma BreakOnExceptions Off
		    reader = BinaryStream.Open(File)
		    #pragma BreakOnExceptions On
		  Catch Err As IOException
		    Return Nil
		  End Try
		  reader.LittleEndian = False
		  Dim ret As Variant
		  Dim type As Integer = Me.ReadType(File)
		  Select Case type
		  Case Variant.TypeBoolean
		    ret = reader.ReadBoolean
		  Case Variant.TypeColor
		    Dim mb As New MemoryBlock(4)
		    mb.Int32Value(0) = reader.ReadInt32
		    ret = mb.ColorValue(0, 32)
		  Case Variant.TypeCurrency
		    ret = reader.ReadCurrency
		  Case Variant.TypeDate
		    Dim d As Double = reader.ReadDouble
		    Dim dt As New Date
		    dt.TotalSeconds = d
		    ret = dt
		  Case Variant.TypeDouble
		    ret = reader.ReadDouble
		  Case Variant.TypeSingle
		    ret = reader.ReadSingle
		  Case Variant.TypeLong
		    ret = reader.ReadInt64
		  Case Variant.TypeInteger
		    ret = reader.ReadInt32
		  Case Variant.TypeNil
		    ret = Nil
		  Case Variant.TypeString
		    ret = reader.Read(reader.Length)
		  Case TYPE_PNG
		    ret = Picture.FromData(reader.Read(reader.Length))
		  Case TYPE_FILE
		    Dim path As String = reader.Read(reader.Length)
		    If path.Trim <> "" Then ret = GetFolderItem(path, FolderItem.PathTypeAbsolute) Else ret = Nil
		  Case TYPE_SYMLINK
		    ret = reader.Read(reader.Length)
		  Else
		    If Not RaiseEvent DeserializeValue(reader, type, ret) Then Raise New UnsupportedFormatException
		  End Select
		  reader.Close
		  Return ret
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SetType(Path As String, Dereference As Boolean = True, Assigns NewType As Integer)
		  Dim meta As FolderItem = Me.Locate(Path, Dereference)
		  If meta <> Nil Then Me.WriteType(meta, NewType)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SetValue(Path As String, Dereference As Boolean = True, Assigns NewValue As Variant)
		  Dim f As FolderItem = Me.Locate(Path, Dereference)
		  If f <> Nil Then Me.WriteValue(f, NewValue)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub WriteType(File As FolderItem, Type As Integer)
		  If File.AbsolutePath = mVolume.Root.AbsolutePath Then Return
		  If File <> Nil And File.Parent <> Nil Then File = File.Parent.Child(File.Name + ".META")
		  If File = Nil Then Raise New IOException
		  If File.Exists Then File.Delete
		  Dim bs As BinaryStream = BinaryStream.Create(File, True)
		  bs.LittleEndian = False
		  bs.WriteInt32(Type)
		  bs.Close
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub WriteValue(File As FolderItem, Value As Variant)
		  If File.AbsolutePath = mVolume.Root.AbsolutePath Then Raise New IOException
		  If File.Exists Then File.Delete
		  Dim writer As BinaryStream = BinaryStream.Create(File, True)
		  Dim type As Integer = VarType(Value)
		  Select Case type
		  Case Variant.TypeBoolean
		    writer.WriteBoolean(value)
		  Case Variant.TypeColor
		    Dim mb As New MemoryBlock(4)
		    mb.ColorValue(0, 32) = Value
		    writer.WriteInt32(mb.Int32Value(0))
		  Case Variant.TypeCurrency
		    writer.WriteCurrency(value)
		  Case Variant.TypeDate
		    Dim d As Double = Value.DateValue.TotalSeconds
		    writer.WriteDouble(d)
		  Case Variant.TypeDouble
		    writer.WriteDouble(value)
		  Case Variant.TypeSingle
		    writer.WriteSingle(value)
		  Case Variant.TypeLong
		    writer.WriteInt64(value)
		  Case Variant.TypeInteger
		    writer.WriteInt32(value)
		  Case Variant.TypeNil
		    ' nothing
		  Case Variant.TypeString
		    writer.Write(value)
		  Case Variant.TypeObject
		    Select Case True
		    Case Value IsA Picture
		      Dim p As Picture = Value
		      writer.Write(p.GetData(Picture.FormatPNG))
		      type = TYPE_PNG
		    Case Value IsA FolderItem
		      Dim source As FolderItem = Value
		      writer.Write(source.AbsolutePath)
		      type = TYPE_FILE
		    Else
		      If Not RaiseEvent SerializeValue(writer, type, Value) Then Raise New UnsupportedFormatException
		    End Select
		  Else
		    If Not RaiseEvent SerializeValue(writer, type, Value) Then Raise New UnsupportedFormatException
		  End Select
		  Me.WriteType(File, type)
		  Writer.Close
		End Sub
	#tag EndMethod


	#tag Hook, Flags = &h0
		Event DeserializeValue(ByteStream As Readable, Type As Integer, ByRef Value As Variant) As Boolean
	#tag EndHook

	#tag Hook, Flags = &h0
		Event SerializeValue(ByteStream As Writeable, ByRef Type As Integer, Value As Variant) As Boolean
	#tag EndHook


	#tag Property, Flags = &h21
		Private mVolume As VirtualVolume
	#tag EndProperty


	#tag Constant, Name = CURRENT_VERSION, Type = Double, Dynamic = False, Default = \"1", Scope = Private
	#tag EndConstant

	#tag Constant, Name = TYPE_DIRECTORY, Type = Double, Dynamic = False, Default = \"-7", Scope = Public
	#tag EndConstant

	#tag Constant, Name = TYPE_FILE, Type = Double, Dynamic = False, Default = \"-4", Scope = Public
	#tag EndConstant

	#tag Constant, Name = TYPE_INVALID, Type = Double, Dynamic = False, Default = \"-1", Scope = Public
	#tag EndConstant

	#tag Constant, Name = TYPE_PNG, Type = Double, Dynamic = False, Default = \"-2", Scope = Public
	#tag EndConstant

	#tag Constant, Name = TYPE_SYMLINK, Type = Double, Dynamic = False, Default = \"-5", Scope = Public
	#tag EndConstant


	#tag ViewBehavior
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			InheritedFrom="Object"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
