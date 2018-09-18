
Imports System

Namespace myNameSpace
  Public Class myMainClass

    Public Shared Function matchCronParam(cfgParam As String, actVal As Integer) As Boolean
      Dim tmpArr As Array
      Dim i As String
      Dim j As Integer
      cfgParam = cfgParam.Replace(" ", "")
      If (cfgParam="" Or cfgParam="*") Then
        Return True
      Else
        For Each i In cfgParam.Split(",")
          If Int32.TryParse(i,j) Then
            If j=actVal Then Return True
          Else
            tmpArr = i.Split("-")
            If tmpArr.Length >= 2 Then
              For j = Convert.ToInt32(tmpArr(0)) To Convert.ToInt32(tmpArr(1))
                If j=actVal Then Return True
              Next
            End If
          End If
        Next
      End If
      Return False
    End Function

    Public Shared Function matchSchedule(datetime As DateTime, mi As String, hr As String, dd As String, mm As String, wd As String) As Boolean
      If Not matchCronParam(mi, datetime.Minute) Then Return False
      If Not matchCronParam(hr, datetime.Hour) Then Return False
      If Not matchCronParam(dd, datetime.Day) Then Return False
      If Not matchCronParam(mm, datetime.Month) Then Return False
      If Not matchCronParam(wd, datetime.DayOfWeek-1) Then Return False
      Return True
    End Function

    Public Shared Function getCronJobs(crontab As String, Optional currentTime As DateTime = Nothing) As String()
      Dim cronJobs As New System.Collections.Generic.List(Of String), line As String
      Dim reader As System.IO.StreamReader = System.IO.File.OpenText(crontab)
      If (currentTime=Nothing) Then currentTime=DateTime.Now
      Do
         line = reader.ReadLine
         If line Is Nothing Then Exit Do
         line = line.Trim
         If line.Length > 12 Then 
           If Not line.StartsWith("#") Then
             Dim m As System.Text.RegularExpressions.Match
             m = System.Text.RegularExpressions.Regex.Match(line, "^(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(.+)$")
             If (m.Success) Then
               Dim mi, hh, dd, mm, wd, cmdln As String
               mi = m.Groups(1).ToString
               hh = m.Groups(2).ToString
               dd = m.Groups(3).ToString
               mm = m.Groups(4).ToString
               wd = m.Groups(5).ToString
               cmdln = m.Groups(6).ToString
               If matchSchedule(currentTime, mi, hh, dd, mm, wd) Then
                 cronJobs.Add(cmdln)
               End If
             End If
           End If
         End If
      Loop Until line Is Nothing
      reader.Close()
      Return cronJobs.ToArray()
    End Function

    Public Shared Function Main(ByVal args() As String)
      Dim currentTime As DateTime = DateTime.Now
      Dim crontab As String = Environment.CurrentDirectory + "\crontab.txt"
      'MsgBox(crontab)
      Console.WriteLine(crontab)
      Dim cronJobs As String()

      cronJobs = getCronJobs(crontab) '' currentTime
      ''Console.WriteLine(cronJobs.Length)

      Dim j As String
      For Each j In cronJobs
        Console.WriteLine(j)
      Next

      Return Nothing
    End Function

  End Class
End Namespace


