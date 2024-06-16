#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <ProgressConstants.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <MsgBoxConstants.au3>

#include <Array.au3>
#include <File.au3>

Opt("ExpandEnvStrings", 1)

Global $arPreset, $INI_title,$INI_timer

Func readlog($logfilepath, ByRef $bytes, ByRef $lines)
	$bytes = 0
	$logfile = FileOpen($logfilepath, 0)
	$lines = -1  ; number of files = number of lines in logfile -1
	While 1
		$line = FileReadLine($logfile)
		If @error Then ExitLoop
		$lines += 1
		$position = StringInStr($line, @TAB, 0, -1)
		If $position > 0 Then
			$tmpbytes = StringLeft($line, $position - 1)
			$tmpbytes = StringStripWS($tmpbytes, 3)
			$tmpbytes = Int($tmpbytes)
			$bytes += $tmpbytes
		EndIf
	WEnd
	FileClose($logfile)
EndFunc

Func robocopy($source, $destination, $logfilepath, $params, $gui_title=$INI_title)
	Local $totalbytes = 0
	Local $totalfiles = 0
	Local $donebytes = 0
	Local $donefiles = 0

	; check if pathes end with a \ then remove it
	if StringRight($source,1) = "\" Then $source = StringLeft($source, StringLen($source)-1)
	if StringRight($destination,1) = "\" Then $destination = StringLeft($destination, StringLen($destination)-1)

	If (IsArray($arPreset) and UBound($arPreset)>0) Then
		For $iStp = 1 to $arPreset[0][0]
			If (StringLower($params)=StringLower($arPreset[$iStp][0])) Then
				$params = $arPreset[$iStp][1]
			EndIf
		Next
	EndIf
	
    ;MsgBox(0,"",@ComSpec & ' /c ' & 'robocopy.exe "' & $source & '" "' & $destination & '" ' & $params & ' /log:"' & $logfilepath & '" /l')
	;Return False
	RunWait(@ComSpec & ' /c ' & 'robocopy.exe "' & $source & '" "' & $destination & '" ' & $params & ' /log:"' & $logfilepath & '" /l', @TempDir, @SW_HIDE)
	readlog($logfilepath, $totalbytes, $totalfiles)
	if $totalbytes = 0 Then Exit

	$str_total_bytes = StringRegExpReplace($totalbytes, '(\A\d{1,3}(?=(\d{3})+\z)|\d{3}(?=\d))', '\1.')
	$str_total_files = StringRegExpReplace($totalfiles, '(\A\d{1,3}(?=(\d{3})+\z)|\d{3}(?=\d))', '\1.')
	ConsoleWrite("Total Bytes: " & $str_total_bytes & @CRLF)
	ConsoleWrite("Total Files: " & $str_total_files & @CRLF)

	$Form1 = GUICreate($gui_title, 580, 180, 192, 124)
	GUICtrlCreateLabel("Звідки", 16, 12, 36, 17)
	$quelle = GUICtrlCreateInput("", 60, 8, 500, 21)
	GUICtrlSetState($quelle, $GUI_DISABLE)
	GUICtrlCreateLabel("Куди", 16, 44, 36, 17)
	$ziel = GUICtrlCreateInput("", 60, 40, 500, 21)
	GUICtrlSetState($ziel, $GUI_DISABLE)
	$lbl_files = GUICtrlCreateLabel("", 16, 72, 560, 17)
	$Progress1 = GUICtrlCreateProgress(16, 88, 544, 25)
	$lbl_bytes = GUICtrlCreateLabel("", 16, 120, 560, 17)
	$Progress2 = GUICtrlCreateProgress(16, 136, 544, 25)
	GUISetState(@SW_SHOW)

	GUICtrlSetData($quelle, $source)
	GUICtrlSetData($ziel, $destination)

	FileDelete($logfilepath)
	$pid = Run(@ComSpec & ' /c ' & 'robocopy.exe "' & $source & '" "' & $destination & '" ' & $params & ' /log:"' & $logfilepath & '"', @TempDir, @SW_HIDE)
	While ProcessExists($pid)
		Sleep($INI_timer)
		readlog($logfilepath, $donebytes, $donefiles)
		$str_done_bytes = StringRegExpReplace($donebytes, '(\A\d{1,3}(?=(\d{3})+\z)|\d{3}(?=\d))', '\1.')
		$str_done_files = StringRegExpReplace($donefiles, '(\A\d{1,3}(?=(\d{3})+\z)|\d{3}(?=\d))', '\1.')
		$percent_bytes = $donebytes * 100 / $totalbytes
		$percent_files = $donefiles * 100 / $totalfiles
		ConsoleWrite("Transfered Bytes: " & $str_done_bytes & ", percentage : " & $percent_bytes & "%" & @CRLF)
		ConsoleWrite("Transfered Files: " & $str_done_files & ", percentage : " & $percent_files & "%" & @CRLF)

		GUICtrlSetData($Progress1, $percent_bytes )
		GUICtrlSetData($Progress2, $percent_files)
		GUICtrlSetData($lbl_bytes, $str_done_bytes & " of " & $str_total_bytes & " (" & StringFormat("%.2f", $percent_bytes) & "%)")
		GUICtrlSetData($lbl_files, $str_done_files & " of " & $str_total_files & " (" & StringFormat("%.2f", $percent_files) & "%)")
	WEnd
EndFunc


$aTmp = _PathSplit(@ScriptFullPath,"", "", "", "")
$sINIFile = @ScriptDir & "\" & $aTmp[$PATH_FILENAME] & ".ini"

If FileExists($sINIFile) Then
	$arPreset = IniReadSection($sINIFile,"Preset")
	$INI_title = IniRead($sINIFile,"Main","title","")
	$INI_timer = IniRead($sINIFile,"Main","timer",10)
	$INI_param = IniRead($sINIFile,"Main","defaultParam","")
	$aINISections = IniReadSectionNames($sINIFile)
	_ArrayDelete($aINISections,_ArraySearch($aINISections,"Preset"))
	_ArrayDelete($aINISections,_ArraySearch($aINISections,"Main"))
	_ArrayDelete($aINISections,0)
	If IsArray($aINISections) Then
		;_ArrayDisplay($aINISections)
		for $iStp=0 to ubound($aINISections)-1
			$JobName = $aINISections[$iStp]
			$JobSource = IniRead($sINIFile,$JobName,"Source","")
			$JobDest = IniRead($sINIFile,$JobName,"Dest","")
			$JobLog = IniRead($sINIFile,$JobName,"Log","")
			$JobParams = IniRead($sINIFile,$JobName,"Params",$INI_param)
			robocopy($JobSource, $JobDest, $JobLog, $JobParams, $JobName & " [" & $iStp+1 & "/" & ubound($aINISections) & "]")
		Next
	Else
		MsgBox(0,"Помилка завантаження налаштувань","Завдання копіюваня відсутні")
	EndIf
Else
	MsgBox(0,"Помилка завантаження налаштувань","Файл " & $sINIFile & "не знайдено")
EndIf
