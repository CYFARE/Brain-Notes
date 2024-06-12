# User Interface Snippets

## Rounded Controls

```vb.net
Public Shared Sub RoundedControl(sender As Control, clr As Color, arcsize As Integer)
        Dim obj = CType(sender, Control)
        Dim DGP As New Drawing2D.GraphicsPath
        obj.BackColor = clr
        DGP.StartFigure()
        'top left corner
        DGP.AddArc(New Rectangle(0, 0, arcsize, arcsize), 180, 90)
        DGP.AddLine(40, 0, obj.Width - arcsize, 0)
        'top right corner
        DGP.AddArc(New Rectangle(obj.Width - arcsize, 0, arcsize, arcsize), -90, 90)
        DGP.AddLine(obj.Width, arcsize, obj.Width, obj.Height - arcsize)
        'buttom right corner
        DGP.AddArc(New Rectangle(obj.Width - arcsize, obj.Height - arcsize, arcsize, arcsize), 0, 90)
        DGP.AddLine(obj.Width - arcsize, obj.Height, arcsize, obj.Height)
        'buttom left corner
        DGP.AddArc(New Rectangle(0, obj.Height - arcsize, arcsize, arcsize), 90, 90)
        DGP.CloseFigure()
        obj.Region = New Region(DGP)
    End Sub
```

## Control Hover Effect

```vb.net
Public Shared Sub ControlHoverEffect(cntrl As Control, effectType As String, hoverType As Boolean)
        If effectType = "size" Then
            Dim change_value As Integer = 2
            If hoverType = True Then
                cntrl.Size = New Size(cntrl.Size.Width + change_value, cntrl.Size.Height + change_value)
                cntrl.Location = New Point(cntrl.Location.X - change_value, cntrl.Location.Y)
            Else
                cntrl.Size = New Size(cntrl.Size.Width - change_value, cntrl.Size.Height - change_value)
                cntrl.Location = New Point(cntrl.Location.X + change_value, cntrl.Location.Y)
            End If
        End If
    End Sub
```

## Get Image 

```vb.net
Public Shared Sub GetImage(sender As Control, imgpath As String)
        Try
            If TypeOf sender Is PictureBox Then
                Dim obj = CType(sender, PictureBox)
                obj.Image = Image.FromFile(Application.StartupPath + "/" + imgpath)
            Else
                Dim obj = CType(sender, Control)
                obj.BackgroundImage = Image.FromFile(Application.StartupPath + "/" + imgpath)
            End If
        Catch ex As Exception
            MsgBox(ex.ToString)
        End Try
    End Sub
```
