#RequireAdmin

#include <EventLog.au3>
#include <File.au3>
#include <FileConstants.au3>
#include <AutoItConstants.au3>
#include <MsgBoxConstants.au3>
#include <Date.au3>

Opt("MustDeclareVars",0)
Opt("ExpandEnvStrings",1)

$i  = 1;
$iMsg = ''
While 1
   $aSubKey = RegEnumKey("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList", $i)
   if @error Then ExitLoop
   $strPath = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\" & $aSubKey,"ProfileImagePath")
   if @error=0 Then
	  if FileExists($strPath) Then
		 If StringInStr($strPath,"Documents and Settings",2)>0 Then
			$iMsg &= @CRLF & clear_1c_cache_xp($strPath)
		 Else
			$iMsg &= @CRLF & clear_1c_cache_7($strPath)
		 EndIf
	    ;MsgBox(0,$strPath,$iMsg)
	 EndIf
   EndIf
   $i += 1
WEnd

Local $aData[4] = [3,1,2,3]
$hEventLog = _EventLog__Open("", "Application")
_EventLog__Report($hEventLog, 4, 0, 2, "", $iMsg, $aData)
_EventLog__Close($hEventLog)


Func clear_1c_cache_7($UsrPath)
   Local $aAppPaths[] = ["\AppData\Local\1C\1cv8","\AppData\Local\1C\1cv82"]
   Local $aAppWDPaths[] = ["\Config","\ConfigSave","\DBNameCache","\SICache","\cgf-cache"]
   Local $log = ""

   If FileExists($UsrPath) Then
	  For $i = 0 To UBound($aAppPaths) - 1
		 Local $UserApp = $UsrPath & $aAppPaths[$i]
		 If FileExists($UserApp) Then
		   $log = $log & $UserApp & @CRLF
		   Local $aFolderList = _FileListToArray($UserApp, "????????-????-????-????-????????????",$FLTA_FOLDERS)
		   if @error=0 Then
			  if $aFolderList[0]>0 Then
				 for $c=1 to $aFolderList[0]
					For $j = 0 to UBound($aAppWDPaths)-1
					   Local $UserAppFolder = $UserApp & "\" & $aFolderList[$c] & $aAppWDPaths[$j]
					   if FileExists($UserAppFolder) Then
						  $res = DirRemove($UserAppFolder, $DIR_REMOVE)
						  $log = $log & $UserAppFolder & " => " & $res & @CRLF
					   EndIf
					Next
				 Next
			  EndIf
		   EndIf
		 EndIf
	  Next
   EndIf

   Return $log
EndFunc

Func clear_1c_cache_xp($UsrPath)
   Local $aAppPaths[] = ["\Local Settings\Application Data\1C\1cv8","\Local Settings\Application Data\1C\1cv82"]
   Local $aAppWDPaths[] = ["\Config","\ConfigSave","\DBNameCache","\SICache","\cgf-cache"]
   Local $log = ""

   If FileExists($UsrPath) Then
	  For $i = 0 To UBound($aAppPaths) - 1
		 Local $UserApp = $UsrPath & $aAppPaths[$i]
		 If FileExists($UserApp) Then
		   $log = $log & $UserApp & @CRLF
		   Local $aFolderList = _FileListToArray($UserApp, "????????-????-????-????-????????????",$FLTA_FOLDERS)
		   if @error=0 Then
			  if $aFolderList[0]>0 Then
				 for $c=1 to $aFolderList[0]
					For $j = 0 to UBound($aAppWDPaths)-1
					   Local $UserAppFolder = $UserApp & "\" & $aFolderList[$c] & $aAppWDPaths[$j]
					   if FileExists($UserAppFolder) Then
						  $res = DirRemove($UserAppFolder, $DIR_REMOVE)
						  $log = $log & $UserAppFolder & " => " & $res & @CRLF
					   EndIf
					Next
				 Next
			  EndIf
		   EndIf
		 EndIf
	  Next
   EndIf

   Return $log
EndFunc
