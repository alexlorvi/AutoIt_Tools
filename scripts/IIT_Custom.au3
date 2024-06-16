#include <AutoItConstants.au3>
#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <StringConstants.au3>
#include <WindowsConstants.au3>

#include <Array.au3>
#include <GuiEdit.au3>
#include <WinAPISysWin.au3>

Global $hGUI
Global $Group_path, $input_crt_path, $btp_path_change, $chkbx_path_auto_refresh, $chkbx_path_save_certs
Global $Group_proxy, $chkbx_proxy_enable, $input_proxy_name, $lbl_proxy_name, $lbl_proxy_port, $input_proxy_port
Global $chkbx_proxy_auth_enable, $lbl_proxy_user, $input_proxy_user, $lbl_proxy_user_password, $input_proxy_user_password
Global $group_ocsp, $chkbx_ocsp_enable, $input_ocsp_name, $lbl_ocsp
Global $lbl_info,$save, $btn_set_def
Global $_NeedSkeleton

; Setting preset
; Change before compile
Global $IIT_CERT_PATH = @MyDocumentsDir & "\Сертифікати"
Global $IIT_PATH_AutoRefresh = $GUI_CHECKED
Global $IIT_PATH_SaveCerts = $GUI_CHECKED
Global $IIT_ProxyEnable = $GUI_UNCHECKED
Global $IIT_ProxyName = ""
Global $IIT_ProxyPort = ""
Global $IIT_ProxyAuth = $GUI_UNCHECKED
Global $IIT_ProxyUser = ""
Global $IIT_ProxyPass = ""
Global $IIT_OCSP_Enable = $GUI_CHECKED
Global $IIT_OCSP_Name = "ca.tax.gov.ua;uakey.com.ua/services/ocsp/"

Func _IsChecked($idControlID)
    Return BitAND(GUICtrlRead($idControlID), $GUI_CHECKED) = $GUI_CHECKED
EndFunc

Func _ReadSettings()
	$_NeedSkeleton = False
	Local $itemsTotal = 0
	Local $itemsFailed = 0
	
	Local $tmpVal = RegRead("HKEY_CURRENT_USER\SOFTWARE\Institute of Informational Technologies\Certificate Authority-1.3\End User\FileStore","Path")
	$itemsTotal += 1
	if @error=0 Then 
		GUICtrlSetData($input_crt_path, $tmpVal)
	Else
		$itemsFailed += 1
	EndIf
	$tmpVal = RegRead("HKEY_CURRENT_USER\SOFTWARE\Institute of Informational Technologies\Certificate Authority-1.3\End User\FileStore","AutoRefresh")
	$itemsTotal += 1
	if @error=0 Then 
		GUICtrlSetState($chkbx_path_auto_refresh,BitAND($tmpVal, $GUI_CHECKED) = $GUI_CHECKED)
	Else
		$itemsFailed += 1
	EndIf
	$tmpVal = RegRead("HKEY_CURRENT_USER\SOFTWARE\Institute of Informational Technologies\Certificate Authority-1.3\End User\FileStore","SaveLoadedCerts")
	$itemsTotal += 1
	if @error=0 Then 
		GUICtrlSetState($chkbx_path_save_certs,BitAND($tmpVal, $GUI_CHECKED) = $GUI_CHECKED)
	Else
		$itemsFailed += 1
	EndIf
	
	$tmpVal = RegRead("HKEY_CURRENT_USER\SOFTWARE\Institute of Informational Technologies\Certificate Authority-1.3\End User\Proxy","Use")
	$itemsTotal += 1
	if @error=0 Then 
		GUICtrlSetState($chkbx_proxy_enable,BitAND($tmpVal, $GUI_CHECKED) = $GUI_CHECKED)
 	    _FixChkBoxs()
	Else
		$itemsFailed += 1
	EndIf
	$tmpVal = RegRead("HKEY_CURRENT_USER\SOFTWARE\Institute of Informational Technologies\Certificate Authority-1.3\End User\Proxy","Address")
	$itemsTotal += 1
	if @error=0 Then 
		GUICtrlSetData($input_proxy_name, $tmpVal)
	Else
		$itemsFailed += 1
	EndIf
	$tmpVal = RegRead("HKEY_CURRENT_USER\SOFTWARE\Institute of Informational Technologies\Certificate Authority-1.3\End User\Proxy","Port")
	$itemsTotal += 1
	if @error=0 Then 
		GUICtrlSetData($input_proxy_port, $tmpVal)
	Else
		$itemsFailed += 1
	EndIf
	$tmpVal = RegRead("HKEY_CURRENT_USER\SOFTWARE\Institute of Informational Technologies\Certificate Authority-1.3\End User\Proxy","Anonymous")
	$itemsTotal += 1
	if @error=0 Then 
		GUICtrlSetState($chkbx_proxy_auth_enable,BitXOR($tmpVal, $GUI_CHECKED) = $GUI_CHECKED)
 	    _FixChkBoxs()
	Else
		$itemsFailed += 1
	EndIf
	$tmpVal = RegRead("HKEY_CURRENT_USER\SOFTWARE\Institute of Informational Technologies\Certificate Authority-1.3\End User\Proxy","User")
	$itemsTotal += 1
	if @error=0 Then 
		GUICtrlSetData($input_proxy_user, $tmpVal)
	Else
		$itemsFailed += 1
	EndIf
	$tmpVal = RegRead("HKEY_CURRENT_USER\SOFTWARE\Institute of Informational Technologies\Certificate Authority-1.3\End User\Proxy","Password")
	$itemsTotal += 1
	if @error=0 Then 
		GUICtrlSetData($input_proxy_user_password, $tmpVal)
	Else
		$itemsFailed += 1
	EndIf
	
	$tmpVal = RegRead("HKEY_CURRENT_USER\SOFTWARE\Institute of Informational Technologies\Certificate Authority-1.3\End User\OCSP","Use")
	$itemsTotal += 1
	if @error=0 Then 
		GUICtrlSetState($chkbx_ocsp_enable,BitAND($tmpVal, $GUI_CHECKED) = $GUI_CHECKED)
 	    _FixChkBoxs()
	Else
		$itemsFailed += 1
	EndIf
	$tmpVal = RegRead("HKEY_CURRENT_USER\SOFTWARE\Institute of Informational Technologies\Certificate Authority-1.3\End User\OCSP","Address")
	$tmpVal2 = RegRead("HKEY_CURRENT_USER\SOFTWARE\Institute of Informational Technologies\Certificate Authority-1.3\End User\OCSP","OtherAddresses")
	$itemsTotal += 1
	if @error=0 Then 
		GUICtrlSetData($input_ocsp_name, $tmpVal & "," & $tmpVal2)
	Else
		$itemsFailed += 1
	EndIf
	
	GUICtrlSetData($lbl_info, "Успішно вичитано " & $itemsTotal-$itemsFailed & " з " & $itemsTotal & " збережених значень")
	if ($itemsFailed=$itemsTotal) Then $_NeedSkeleton = True
EndFunc


Func _FixChkBoxs()
   if _isChecked($chkbx_proxy_enable) Then
	  GUICtrlSetState($chkbx_proxy_auth_enable, $GUI_ENABLE)
	  GUICtrlSetState($input_proxy_name, $GUI_ENABLE)
	  GUICtrlSetState($input_proxy_port, $GUI_ENABLE)
	  if _isChecked($chkbx_proxy_auth_enable) Then
		 GUICtrlSetState($input_proxy_user, $GUI_ENABLE)
		 GUICtrlSetState($input_proxy_user_password, $GUI_ENABLE)
	  Else
		 GUICtrlSetState($input_proxy_user, $GUI_DISABLE)
		 GUICtrlSetState($input_proxy_user_password, $GUI_DISABLE)
	 endIf
   Else
	  GUICtrlSetState($chkbx_proxy_auth_enable, $GUI_DISABLE)
	  GUICtrlSetState($input_proxy_name, $GUI_DISABLE)
	  GUICtrlSetState($input_proxy_port, $GUI_DISABLE)
	  GUICtrlSetState($input_proxy_user, $GUI_DISABLE)
	  GUICtrlSetState($input_proxy_user_password, $GUI_DISABLE)
   endIf
   if _isChecked($chkbx_ocsp_enable) Then
	  GUICtrlSetState($input_ocsp_name, $GUI_ENABLE)
   Else
	  GUICtrlSetState($input_ocsp_name, $GUI_DISABLE)
  endIf
EndFunc

Func _SetDefaults()
	GUICtrlSetData($input_crt_path, $IIT_CERT_PATH)
	GUICtrlSetState($chkbx_path_auto_refresh,$IIT_PATH_AutoRefresh)
	GUICtrlSetState($chkbx_path_save_certs,$IIT_PATH_SaveCerts)
	
	GUICtrlSetState($chkbx_proxy_enable,$IIT_ProxyEnable)
	GUICtrlSetData($input_proxy_name, $IIT_ProxyName)
	GUICtrlSetData($input_proxy_port, $IIT_ProxyPort)
	GUICtrlSetState($chkbx_proxy_auth_enable,$IIT_ProxyAuth)
	GUICtrlSetData($input_proxy_user, $IIT_ProxyUser)
	GUICtrlSetData($input_proxy_user_password, $IIT_ProxyPass)

	GUICtrlSetState($chkbx_ocsp_enable, $IIT_OCSP_Enable)
	GUICtrlSetData($input_ocsp_name, $IIT_OCSP_Name)
	
	_FixChkBoxs()
	_WinAPI_SetFocus(ControlGetHandle("","",$input_proxy_user_password))
	_GUICtrlEdit_ShowBalloonTip(ControlGetHandle("","",$input_proxy_user_password),"Введіть Ваш пароль","входу на компютер",$TTI_INFO)
EndFunc

Func _MakeSkeleton()
	RegWrite("HKEY_CURRENT_USER\SOFTWARE\Institute of Informational Technologies\Certificate Authority-1.3\End User\CMP","Use","REG_DWORD",0)
	RegWrite("HKEY_CURRENT_USER\SOFTWARE\Institute of Informational Technologies\Certificate Authority-1.3\End User\CMP","Address","REG_SZ","")
	RegWrite("HKEY_CURRENT_USER\SOFTWARE\Institute of Informational Technologies\Certificate Authority-1.3\End User\CMP","Port","REG_SZ","")
	RegWrite("HKEY_CURRENT_USER\SOFTWARE\Institute of Informational Technologies\Certificate Authority-1.3\End User\CMP","OtherAddresses","REG_SZ","")
	RegWrite("HKEY_CURRENT_USER\SOFTWARE\Institute of Informational Technologies\Certificate Authority-1.3\End User\CMP","CommonName","REG_SZ","")

	RegWrite("HKEY_CURRENT_USER\SOFTWARE\Institute of Informational Technologies\Certificate Authority-1.3\End User\FileStore","Path","REG_SZ","")
	RegWrite("HKEY_CURRENT_USER\SOFTWARE\Institute of Informational Technologies\Certificate Authority-1.3\End User\FileStore","CheckCRLs","REG_DWORD",0)
	RegWrite("HKEY_CURRENT_USER\SOFTWARE\Institute of Informational Technologies\Certificate Authority-1.3\End User\FileStore","AutoRefresh","REG_DWORD",1)
	RegWrite("HKEY_CURRENT_USER\SOFTWARE\Institute of Informational Technologies\Certificate Authority-1.3\End User\FileStore","OnlyOwnCRLs","REG_DWORD",0)
	RegWrite("HKEY_CURRENT_USER\SOFTWARE\Institute of Informational Technologies\Certificate Authority-1.3\End User\FileStore","FullAndDeltaCRLs","REG_DWORD",0)
	RegWrite("HKEY_CURRENT_USER\SOFTWARE\Institute of Informational Technologies\Certificate Authority-1.3\End User\FileStore","AutoDownloadCRLs","REG_DWORD",0)
	RegWrite("HKEY_CURRENT_USER\SOFTWARE\Institute of Informational Technologies\Certificate Authority-1.3\End User\FileStore","SaveLoadedCerts","REG_DWORD",1)
	RegWrite("HKEY_CURRENT_USER\SOFTWARE\Institute of Informational Technologies\Certificate Authority-1.3\End User\FileStore","ExpireTime","REG_SZ","3600")

	RegWrite("HKEY_CURRENT_USER\SOFTWARE\Institute of Informational Technologies\Certificate Authority-1.3\End User\LDAP","Use","REG_DWORD",0)
	RegWrite("HKEY_CURRENT_USER\SOFTWARE\Institute of Informational Technologies\Certificate Authority-1.3\End User\LDAP","Address","REG_SZ","")
	RegWrite("HKEY_CURRENT_USER\SOFTWARE\Institute of Informational Technologies\Certificate Authority-1.3\End User\LDAP","Port","REG_SZ","")
	RegWrite("HKEY_CURRENT_USER\SOFTWARE\Institute of Informational Technologies\Certificate Authority-1.3\End User\LDAP","Anonimous","REG_DWORD",0)
	RegWrite("HKEY_CURRENT_USER\SOFTWARE\Institute of Informational Technologies\Certificate Authority-1.3\End User\LDAP","User","REG_SZ","")
	RegWrite("HKEY_CURRENT_USER\SOFTWARE\Institute of Informational Technologies\Certificate Authority-1.3\End User\LDAP","Password","REG_SZ","")
	RegWrite("HKEY_CURRENT_USER\SOFTWARE\Institute of Informational Technologies\Certificate Authority-1.3\End User\LDAP","LookupCert","REG_DWORD",0)

	RegWrite("HKEY_CURRENT_USER\SOFTWARE\Institute of Informational Technologies\Certificate Authority-1.3\End User\Libraries\Sign\KeyMedia","SourceType","REG_DWORD",1)
	RegWrite("HKEY_CURRENT_USER\SOFTWARE\Institute of Informational Technologies\Certificate Authority-1.3\End User\Libraries\Sign\KeyMedia","ShowErrors","REG_DWORD",1)
	RegWrite("HKEY_CURRENT_USER\SOFTWARE\Institute of Informational Technologies\Certificate Authority-1.3\End User\Libraries\Sign\KeyMedia","Type","REG_DWORD",0)
	RegWrite("HKEY_CURRENT_USER\SOFTWARE\Institute of Informational Technologies\Certificate Authority-1.3\End User\Libraries\Sign\KeyMedia","Device","REG_DWORD",0)
	RegWrite("HKEY_CURRENT_USER\SOFTWARE\Institute of Informational Technologies\Certificate Authority-1.3\End User\Libraries\Sign\KeyMedia","ProtectPassword","REG_DWORD",1)
	RegWrite("HKEY_CURRENT_USER\SOFTWARE\Institute of Informational Technologies\Certificate Authority-1.3\End User\Libraries\Sign\KeyMedia","Password","REG_SZ","")

	RegWrite("HKEY_CURRENT_USER\SOFTWARE\Institute of Informational Technologies\Certificate Authority-1.3\End User\Libraries\Sign Agent\Common","AutoRun","REG_DWORD",1)
	RegWrite("HKEY_CURRENT_USER\SOFTWARE\Institute of Informational Technologies\Certificate Authority-1.3\End User\Libraries\Sign Agent\Common","RunAsProcess","REG_DWORD",1)
	RegWrite("HKEY_CURRENT_USER\SOFTWARE\Institute of Informational Technologies\Certificate Authority-1.3\End User\Libraries\Sign Agent\Common","HTTPPort","REG_SZ","8081")
	RegWrite("HKEY_CURRENT_USER\SOFTWARE\Institute of Informational Technologies\Certificate Authority-1.3\End User\Libraries\Sign Agent\Common","HTTPSPort","REG_SZ","8083")
	RegWrite("HKEY_CURRENT_USER\SOFTWARE\Institute of Informational Technologies\Certificate Authority-1.3\End User\Libraries\Sign Agent\Common","PrivKeyPath","REG_SZ","C:\ProgramData\Institute of Informational Technologies\Certificate Authority-1.3\End User\Sign Agent\EUSignAgent.pem")
	RegWrite("HKEY_CURRENT_USER\SOFTWARE\Institute of Informational Technologies\Certificate Authority-1.3\End User\Libraries\Sign Agent\Common","CertPath","REG_SZ","C:\ProgramData\Institute of Informational Technologies\Certificate Authority-1.3\End User\Sign Agent\EUSignAgent.cer")
	RegWrite("HKEY_CURRENT_USER\SOFTWARE\Institute of Informational Technologies\Certificate Authority-1.3\End User\Libraries\Sign Agent\Common","CertImportedMozillaFF","REG_DWORD",1)
	RegWrite("HKEY_CURRENT_USER\SOFTWARE\Institute of Informational Technologies\Certificate Authority-1.3\End User\Libraries\Sign Agent\Common","CertImportedSystem","REG_DWORD",1)
	RegWrite("HKEY_CURRENT_USER\SOFTWARE\Institute of Informational Technologies\Certificate Authority-1.3\End User\Libraries\Sign Agent\Common","RootDirectory","REG_SZ","")
	RegWrite("HKEY_CURRENT_USER\SOFTWARE\Institute of Informational Technologies\Certificate Authority-1.3\End User\Libraries\Sign Agent\Common","CACertPath","REG_SZ","C:\ProgramData\Institute of Informational Technologies\Certificate Authority-1.3\End User\Sign Agent\EUSignAgentCA.cer")
	
	RegWrite("HKEY_CURRENT_USER\SOFTWARE\Institute of Informational Technologies\Certificate Authority-1.3\End User\Libraries\Sign Agent\TrustedSites")
	RegWrite("HKEY_CURRENT_USER\SOFTWARE\Institute of Informational Technologies\Certificate Authority-1.3\End User\Libraries\Sign Web")
	
	RegWrite("HKEY_CURRENT_USER\SOFTWARE\Institute of Informational Technologies\Certificate Authority-1.3\End User\Log","System","REG_DWORD",0)
	RegWrite("HKEY_CURRENT_USER\SOFTWARE\Institute of Informational Technologies\Certificate Authority-1.3\End User\Log","ReportAgent","REG_DWORD",0)
	RegWrite("HKEY_CURRENT_USER\SOFTWARE\Institute of Informational Technologies\Certificate Authority-1.3\End User\Log","Address","REG_SZ","")
	RegWrite("HKEY_CURRENT_USER\SOFTWARE\Institute of Informational Technologies\Certificate Authority-1.3\End User\Log","Port","REG_SZ","10111")
	RegWrite("HKEY_CURRENT_USER\SOFTWARE\Institute of Informational Technologies\Certificate Authority-1.3\End User\Log","OtherAddresses","REG_SZ","")
	RegWrite("HKEY_CURRENT_USER\SOFTWARE\Institute of Informational Technologies\Certificate Authority-1.3\End User\Log","OnlyErrors","REG_DWORD",0)
	
	RegWrite("HKEY_CURRENT_USER\SOFTWARE\Institute of Informational Technologies\Certificate Authority-1.3\End User\Mode","Offline","REG_DWORD",0)
	RegWrite("HKEY_CURRENT_USER\SOFTWARE\Institute of Informational Technologies\Certificate Authority-1.3\End User\Mode","ResetPKey","REG_DWORD",0)
	
	RegWrite("HKEY_CURRENT_USER\SOFTWARE\Institute of Informational Technologies\Certificate Authority-1.3\End User\OCSP","Use","REG_DWORD",0)
	RegWrite("HKEY_CURRENT_USER\SOFTWARE\Institute of Informational Technologies\Certificate Authority-1.3\End User\OCSP","BeforeFStore","REG_DWORD",0)
	RegWrite("HKEY_CURRENT_USER\SOFTWARE\Institute of Informational Technologies\Certificate Authority-1.3\End User\OCSP","Address","REG_SZ","")
	RegWrite("HKEY_CURRENT_USER\SOFTWARE\Institute of Informational Technologies\Certificate Authority-1.3\End User\OCSP","Port","REG_SZ","80")
	RegWrite("HKEY_CURRENT_USER\SOFTWARE\Institute of Informational Technologies\Certificate Authority-1.3\End User\OCSP","OtherAddresses","REG_SZ","")
	
	RegWrite("HKEY_CURRENT_USER\SOFTWARE\Institute of Informational Technologies\Certificate Authority-1.3\End User\OCSPAccessInfo","Enabled","REG_DWORD",0)
	
	RegWrite("HKEY_CURRENT_USER\SOFTWARE\Institute of Informational Technologies\Certificate Authority-1.3\End User\Proxy","Use","REG_DWORD",0)
	RegWrite("HKEY_CURRENT_USER\SOFTWARE\Institute of Informational Technologies\Certificate Authority-1.3\End User\Proxy","Address","REG_SZ","")
	RegWrite("HKEY_CURRENT_USER\SOFTWARE\Institute of Informational Technologies\Certificate Authority-1.3\End User\Proxy","Port","REG_SZ","")
	RegWrite("HKEY_CURRENT_USER\SOFTWARE\Institute of Informational Technologies\Certificate Authority-1.3\End User\Proxy","Anonymous","REG_DWORD",1)
	RegWrite("HKEY_CURRENT_USER\SOFTWARE\Institute of Informational Technologies\Certificate Authority-1.3\End User\Proxy","User","REG_SZ","")
	RegWrite("HKEY_CURRENT_USER\SOFTWARE\Institute of Informational Technologies\Certificate Authority-1.3\End User\Proxy","Password","REG_SZ","")
	RegWrite("HKEY_CURRENT_USER\SOFTWARE\Institute of Informational Technologies\Certificate Authority-1.3\End User\Proxy","SavePassword","REG_DWORD",0)
	
	RegWrite("HKEY_CURRENT_USER\SOFTWARE\Institute of Informational Technologies\Certificate Authority-1.3\End User\TSP","GetStamps","REG_DWORD",0)
	RegWrite("HKEY_CURRENT_USER\SOFTWARE\Institute of Informational Technologies\Certificate Authority-1.3\End User\TSP","Address","REG_SZ","")
	RegWrite("HKEY_CURRENT_USER\SOFTWARE\Institute of Informational Technologies\Certificate Authority-1.3\End User\TSP","Port","REG_SZ","")
	RegWrite("HKEY_CURRENT_USER\SOFTWARE\Institute of Informational Technologies\Certificate Authority-1.3\End User\TSP","OtherAddresses","REG_SZ","")
	
	GUICtrlSetData($lbl_info, "Створено шаблон налаштувань")
	Sleep(1000)
EndFunc

Func _SaveSettings()
	Local $tmpVal = GUICtrlRead($input_crt_path)
	If (Not FileExists($tmpVal)) Then DirCreate($tmpVal)
	RegWrite("HKEY_CURRENT_USER\SOFTWARE\Institute of Informational Technologies\Certificate Authority-1.3\End User\FileStore","Path","REG_SZ",$tmpVal)	
	
	if _isChecked($chkbx_path_auto_refresh) Then
		$tmpVal = 1
	Else
		$tmpVal = 0
	EndIf
	RegWrite("HKEY_CURRENT_USER\SOFTWARE\Institute of Informational Technologies\Certificate Authority-1.3\End User\FileStore","AutoRefresh","REG_DWORD",$tmpVal)
		
	if _isChecked($chkbx_path_save_certs) Then
		$tmpVal = 1
	Else
		$tmpVal = 0
	EndIf
	RegWrite("HKEY_CURRENT_USER\SOFTWARE\Institute of Informational Technologies\Certificate Authority-1.3\End User\FileStore","SaveLoadedCerts","REG_DWORD",$tmpVal)
	
	if _isChecked($chkbx_proxy_enable) Then
		$tmpVal = GUICtrlRead($input_proxy_name)
		RegWrite("HKEY_CURRENT_USER\SOFTWARE\Institute of Informational Technologies\Certificate Authority-1.3\End User\Proxy","Address","REG_SZ",$tmpVal)
		$tmpVal = GUICtrlRead($input_proxy_port)
		RegWrite("HKEY_CURRENT_USER\SOFTWARE\Institute of Informational Technologies\Certificate Authority-1.3\End User\Proxy","Port","REG_SZ",$tmpVal)
		$tmpVal = 1
	Else
		$tmpVal = 0
	EndIf
	RegWrite("HKEY_CURRENT_USER\SOFTWARE\Institute of Informational Technologies\Certificate Authority-1.3\End User\Proxy","Use","REG_DWORD",$tmpVal)
	
	if _isChecked($chkbx_proxy_auth_enable) Then
		$tmpVal = GUICtrlRead($input_proxy_user)
		RegWrite("HKEY_CURRENT_USER\SOFTWARE\Institute of Informational Technologies\Certificate Authority-1.3\End User\Proxy","User","REG_SZ",$tmpVal)
		$tmpVal = GUICtrlRead($input_proxy_user_password)
		If (StringLen($tmpVal)>0 and not StringIsSpace($tmpVal)) Then
			RegWrite("HKEY_CURRENT_USER\SOFTWARE\Institute of Informational Technologies\Certificate Authority-1.3\End User\Proxy","SavePassword","REG_DWORD",1)
			RegWrite("HKEY_CURRENT_USER\SOFTWARE\Institute of Informational Technologies\Certificate Authority-1.3\End User\Proxy","Password","REG_SZ",$tmpVal)
		Else
			RegWrite("HKEY_CURRENT_USER\SOFTWARE\Institute of Informational Technologies\Certificate Authority-1.3\End User\Proxy","SavePassword","REG_DWORD",0)
			RegWrite("HKEY_CURRENT_USER\SOFTWARE\Institute of Informational Technologies\Certificate Authority-1.3\End User\Proxy","Password","REG_SZ","")			
		EndIf
		$tmpVal = 0
	Else
		$tmpVal = 1
	EndIf
	RegWrite("HKEY_CURRENT_USER\SOFTWARE\Institute of Informational Technologies\Certificate Authority-1.3\End User\Proxy","Anonymous","REG_DWORD",$tmpVal)
	
	if _isChecked($chkbx_proxy_auth_enable) Then
		$tmpVal = GUICtrlRead($input_ocsp_name)
		Local $aTmp = StringSplit($tmpVal,";",$STR_NOCOUNT)
		RegWrite("HKEY_CURRENT_USER\SOFTWARE\Institute of Informational Technologies\Certificate Authority-1.3\End User\OCSP","Address","REG_SZ", StringStripWS($aTmp[0],$STR_STRIPLEADING+$STR_STRIPTRAILING))
		If UBound($aTmp)>1 Then
			_ArrayDelete($aTmp,0)
			RegWrite("HKEY_CURRENT_USER\SOFTWARE\Institute of Informational Technologies\Certificate Authority-1.3\End User\OCSP","OtherAddresses","REG_SZ",_ArrayToString($aTmp,";"))
		EndIf
		$tmpVal = 1
	Else
		$tmpVal = 0
	EndIf
	RegWrite("HKEY_CURRENT_USER\SOFTWARE\Institute of Informational Technologies\Certificate Authority-1.3\End User\OCSP","Use","REG_DWORD",$tmpVal)

    GUICtrlSetData($lbl_info, "Дані збережено")
	Sleep(1000)
EndFunc

Func _KillProcess($PName)
	If ProcessExists($PName) Then ProcessClose($PName)
EndFunc

Func _guiCreate()
	$hGUI = GUICreate("IIT WOG Config 0.0.1", 406, 400)

   $group_path = GUICtrlCreateGroup("Файлове сховище сертифікатів на СВС", 3, -1, 400, 91)
   $input_crt_path = GUICtrlCreateInput("", 13, 19, 300, 21)
   $btp_path_change = GUICtrlCreateButton("Змінити", 320, 19, 75, 21)
   $chkbx_path_auto_refresh = GUICtrlCreateCheckbox("Автоматично перечитувати при виявленні змін", 20, 42, 375, 21)
   $chkbx_path_save_certs = GUICtrlCreateCheckbox("Зберегати сертифікати, що отримані з OCSP-, LDAP- чи CMP-серверів", 20, 60, 375, 21)
   GUICtrlCreateGroup("", -99, -99, 1, 1)

   $group_proxy = GUICtrlCreateGroup("Proxy-сервер", 3, 94, 400, 165)
   $chkbx_proxy_enable = GUICtrlCreateCheckbox("Використовувати Proxy-сервер", 16, 112, 200, 21)
   $lbl_proxy_name = GUICtrlCreateLabel("Адреса серверу", 40, 135, 120, 21)
   $input_proxy_name = GUICtrlCreateInput("proxy2.oil.gcc.corp", 180, 135, 150, 21)
   GUICtrlSetState(-1,$GUI_DISABLE)
   $lbl_proxy_port = GUICtrlCreateLabel("Порт серверу", 40, 159, 120, 21)
   $input_proxy_port = GUICtrlCreateInput("3128", 180, 159, 150, 21)
   GUICtrlSetState(-1,$GUI_DISABLE)
   $chkbx_proxy_auth_enable = GUICtrlCreateCheckbox("Авторизуватися на сервері", 16, 183, 176, 21)
   GUICtrlSetState(-1,$GUI_DISABLE)
   $lbl_proxy_user = GUICtrlCreateLabel("Імя користувача", 40, 206, 120, 11)
   $input_proxy_user = GUICtrlCreateInput("", 180, 206, 210, 21)
   GUICtrlSetState(-1,$GUI_DISABLE)
   $lbl_proxy_user_password = GUICtrlCreateLabel("Пароль", 40, 230, 120, 11)
   $input_proxy_user_password = GUICtrlCreateInput("", 180, 230, 210, 21,$ES_PASSWORD)
   GUICtrlSetState(-1,$GUI_DISABLE)
   GUICtrlCreateGroup("", -99, -99, 1, 1)

   $group_ocsp = GUICtrlCreateGroup("OCSP-сервер ЦСК", 3, 261, 400, 76)
   $chkbx_ocsp_enable = GUICtrlCreateCheckbox("Використовувати OCSP-сервер", 13, 276, 236, 21)
   $lbl_ocsp = GUICtrlCreateLabel("DNS-імя чи IP-адреса сервера:", 13, 302, 156, 21)
   $input_ocsp_name = GUICtrlCreateInput("ca.tax.gov.ua;uakey.com.ua/services/ocsp/", 175, 300, 220, 21)
   GUICtrlSetState(-1,$GUI_DISABLE)
   GUICtrlCreateGroup("", -99, -99, 1, 1)

   $lbl_info = GUICtrlCreateLabel("", 3, 382, 400, 15,BitOR($SS_SIMPLE, $SS_SUNKEN))
   $save = GUICtrlCreateButton("Зберегти", 312, 338, 85, 42,$BS_ICON)
   GUICtrlSetTip(-1,"Зберегти")
   GUICtrlSetImage(-1, "shell32.dll",41)
   $btn_set_def = GUICtrlCreateButton("Заповнити за-замовчуванням", 7, 339, 171, 40)
EndFunc

Func _main()
	_guiCreate()
	_ReadSettings()
	GUISetState(@SW_SHOWNORMAL)

	While 1
		Switch GUIGetMsg()
			Case $GUI_EVENT_CLOSE
				ExitLoop
			Case $chkbx_proxy_auth_enable
				_FixChkBoxs()
			Case $chkbx_proxy_enable
				_FixChkBoxs()
			Case $chkbx_ocsp_enable
				_FixChkBoxs()
			Case $btp_path_change
			  $sMessage = "Файлове сховище сертифікатів на СВС"
			  FileSelectFolder($sMessage, "")
			Case $btn_set_def
			  _SetDefaults()
		    Case $save
			  _KillProcess("EUSAProcess.exe")
			  If ($_NeedSkeleton) Then _MakeSkeleton()
			  _SaveSettings()
			  GUICtrlSetData($lbl_info, "Завершуємось")
			  Sleep(1000)
			  ExitLoop
			Case Else
				;
		EndSwitch
	WEnd
EndFunc

_main()

