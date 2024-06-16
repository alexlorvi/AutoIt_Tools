#include <File.au3>
#include <Array.au3>
#include <FileConstants.au3>
#include <AutoItConstants.au3>
#include <WindowsConstants.au3>
#include <GuiComboBox.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <MsgBoxConstants.au3>
#include <Date.au3>

Local $UserFolder = _PathFull(@WindowsDir & "\..\Users")
Local $UserName = @UserName

;MsgBox(0,"",clear_1c_cache($UserName))

Local $hGUI
$hGUI = GUICreate("Очистка кеша 1С користувача", 400, 296)
GUICtrlCreateLabel("Оберіть користувача з локального переліку:", 2,2)
$g_hCombo = _GUICtrlComboBox_Create($hGUI, "", 2, 20, 396, 296)
Local $idLog = GUICtrlCreateEdit("Тут буде результат роботи" & @CRLF & "========"&_now()&"========" & @CRLF, 2, 50, 396, 200, $ES_AUTOVSCROLL + $WS_VSCROLL)
Local $idButtonRun = GUICtrlCreateButton("Почистити", 100, 260, 200, 25)
GUISetState(@SW_SHOW)

; Add files
_GUICtrlComboBox_BeginUpdate($g_hCombo)
_GUICtrlComboBox_AddDir($g_hCombo, $UserFolder & "\*", $DDL_DIRECTORY+$DDL_EXCLUSIVE, False)
_GUICtrlComboBox_EndUpdate($g_hCombo)

; Loop until the user exits.
While 1
   Switch GUIGetMsg()
      Case $GUI_EVENT_CLOSE
      ExitLoop

      Case $idButtonRun
		 Switch _GUICtrlComboBox_GetEditText($g_hCombo)
		   Case "", "[..]"
			 $UserName = @UserName
		   Case Else
			 $UserName = StringTrimLeft(StringTrimRight(_GUICtrlComboBox_GetEditText($g_hCombo),1),1)
		 EndSwitch
		 GUICtrlSetData($idLog, clear_1c_cache($UserName) & @CRLF & "========"&_now()&"========" & @CRLF, 1)
   EndSwitch
WEnd
GUIDelete()



Func clear_1c_cache($UsrNm)
   Local $aAppPaths[] = ["\AppData\Local\1C\1cv8","\AppData\Local\1C\1cv82"]
   Local $aAppWDPaths[] = ["\Config","\ConfigSave","\DBNameCache","\SICache","\cgf-cache"]
   Local $log = ""

   If FileExists($UserFolder) Then
	  For $i = 0 To UBound($aAppPaths) - 1
		 Local $UserApp = $UserFolder & "\" & $UsrNm & $aAppPaths[$i]
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
