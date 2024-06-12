# Core Helper Functions

## Check Internet Connectivity

```vb.net
Public Shared Function CheckForInternetConnection() As Boolean
        Try
            Using client = New WebClient()
                Using stream = client.OpenRead("https://www.google.com")
                    Return True
                End Using
            End Using
        Catch
            Return False
        End Try
    End Function
```

## Run Shell Command

```vb.net
Public Shared Sub RunShell(command As String, arguments As String, permanent As Boolean)
        Try
            Dim p As Process = New Process()
            Dim pi As ProcessStartInfo = New ProcessStartInfo()
            pi.UseShellExecute = False
            pi.CreateNoWindow = True
            pi.Arguments = " " + If(permanent = True, "/K", "/C") + " " + command + " " + arguments
            pi.FileName = "cmd.exe"
            p.StartInfo = pi
            p.Start()
        Catch ex As Exception
            MsgBox(ex.ToString)
        End Try
    End Sub
```

## Run Application

```vb.net
Public Shared Sub RunApp(proc_path As String, args As String, elevated As Boolean)
        Dim procStartInfo As New ProcessStartInfo
        With procStartInfo
            .UseShellExecute = True
            .FileName = proc_path
            .Arguments = args
            .WindowStyle = ProcessWindowStyle.Normal
            If elevated = True Then
                .Verb = "runas" 'add this to prompt for elevation
            End If
        End With
        Try
            Process.Start(procStartInfo)
        Catch ex As Exception
            MsgBox(ex.ToString)
        End Try
    End Sub
```

## Read File Lines

```vb.net
Public Shared Function ReadFileLines(fpath As String)
        Dim filelist As New List(Of String)
        Try
            Using Reader As New StreamReader(fpath)
                While Reader.EndOfStream = False
                    filelist.Add(Reader.ReadLine())
                End While
                Return filelist
            End Using
        Catch ex As Exception
            Return "None"
        End Try
    End Function
```

## Read JSON File

```vb.net
Public Shared Function ReadJSONFile(fpath As String)
        Try
            Dim jsonString As String = File.ReadAllText(fpath)
            Dim jsonObject As JObject = JObject.Parse(jsonString)
            Dim jsonArray As JArray = JArray.Parse(jsonObject.SelectToken("items").ToString)
            Return jsonArray
        Catch ex As Exception
            MsgBox(ex.ToString)
            Return Nothing
        End Try
    End Function
```

### Call Function

```vb.net
Dim jsonArray As JArray = CoreFunctions.ReadJSONFile(Application.StartupPath + "\\data\\pinned_tools.json")

        For Each item As JObject In jsonArray
            SharedSettings.pinned_flowItem_ID.Add(item.SelectToken("ID").ToString)
            SharedSettings.pinned_flowItem_Name.Add(item.SelectToken("Name").ToString)
            SharedSettings.pinned_flowItem_Path.Add(item.SelectToken("Path").ToString)
            SharedSettings.pinned_flowItem_Args.Add(item.SelectToken("Args").ToString)
            SharedSettings.pinned_flowItem_Elevations.Add(item.SelectToken("Elevated").ToString)
```

## Write JSON File

```vb.net
Public Shared Sub WriteJSONFile(fpath As String, jsonString As String)
        Try
            If Not File.Exists(fpath) Then
                File.Create(fpath).Dispose()
            End If
            File.WriteAllText(fpath, jsonString)
        Catch ex As Exception
            MsgBox(ex.ToString)
        End Try
    End Sub
```

## Convert Escape '\' To String Or Replace For Paths

```vb.net
Public Shared Function Convert_EscapeSlashToString(xstr As String)
        Dim nstr As String = xstr.Replace("\", "\\")
        Return nstr
    End Function
```

## Calculate File MD5 Signature

```vb.net
Public Shared Function Calc_MD5(file_name As String)
        Try
            Dim hash = MD5.Create()
            Dim hashValue() As Byte
            Dim fileStream As FileStream = File.OpenRead(file_name)
            fileStream.Position = 0
            hashValue = hash.ComputeHash(fileStream)
            Dim hash_hex = _print_byte_(hashValue)
            fileStream.Close()
            Return hash_hex
        Catch ex As Exception
            Return Nothing
        End Try
    End Function

    Public Shared Function _print_byte_(array() As Byte)
        Dim hex_value As String = ""
        Dim i As Integer
        For i = 0 To array.Length - 1
            hex_value += array(i).ToString("X2")
        Next i
        Return hex_value.ToLower
    End Function
```

## Check Download Speed

```vb.net
Private tmp = IO.Path.Combine(My.Computer.FileSystem.SpecialDirectories.Temp, "snafu.fubar")
Private Downloading As Boolean = False

Private Sub checkdownloadspeed()
        If Downloading Then Exit Sub
        Downloading = True
        Dim wc As New WebClient
        AddHandler wc.DownloadProgressChanged, AddressOf bgwNetworking_ProgressChanged
        AddHandler wc.DownloadFileCompleted, AddressOf bgwNetworking_RunWorkerCompleted
        Try
            wc.DownloadFileAsync(New Uri("http://cachefly.cachefly.net/1mb.test"), tmp, Stopwatch.StartNew)
        Catch ex As Exception
            MsgBox(ex.ToString)
        End Try
    End Sub
```

## Get Public IP

```vb.net
Private Sub SetPublicIP()
        Dim client As New WebClient
        client.Headers.Add("user-agent", "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.2; .NET CLR1.0.3705;)")
        Dim baseurl As String = "http://icanhazip.com/"
        Dim proxy As IWebProxy = WebRequest.GetSystemWebProxy()
        proxy.Credentials = CredentialCache.DefaultNetworkCredentials
        client.Proxy = proxy
        Dim data As Stream
        Try
            data = client.OpenRead(baseurl)
        Catch ex As Exception
            MsgBox("open url " & ex.Message)
            Exit Sub
        End Try
        Dim reader As StreamReader = New StreamReader(data)
        Dim s As String = reader.ReadToEnd()
        data.Close()
        reader.Close()
        lblNetworking_3.Text = s.ToString
        SharedSettings.publicIP = s.ToString
    End Sub
```

## Open File Dialog

```vb.net
Private Sub picAppPath_Click(sender As Object, e As EventArgs) Handles picAppPath.Click
        Dim ofd As New OpenFileDialog
        ofd.Filter = "Executable Files (*.exe)|*.exe|Text Files (*.txt)|*.txt|C# File (*.cs)|*.cs|HTML File (*.html)|*.html|HTML File (*.htm)|*.htm|JavaScript File (*.js)|*.js|LUA File (*.lua)|*.lua|PHP File (*.php)|*.php|SQL File (*.sql)|*.sql|VisualBasic File (*.vb)|*.vb|VBScript File (*.vbs)|*.vbs|XML File (*.xml)|*.xml|RTF Files (*.rtf) |*.rtf|All Files (*.*)|*.*"
        Dim result As DialogResult = ofd.ShowDialog()
        If result = Windows.Forms.DialogResult.OK Then
            If ofd.FileName IsNot Nothing Then
                If File.Exists(ofd.FileName) = True Then
                    SharedSettings.pinned_flowItem_Path(CInt(lblID.Text)) = ofd.FileName
                    txtAppPath.Text = ofd.FileName
                    txtAppHash.Text = CoreFunctions.Calc_MD5(ofd.FileName)
                Else
                    MsgBox("File Does Not Exist!")
                End If
            Else
                MsgBox("No Filepath")
            End If
        End If
        CoreFunctions.SavePinnedTools()
    End Sub
```
