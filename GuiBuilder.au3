#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=guibuild.ico
#AutoIt3Wrapper_Outfile=FormBuilder.exe
#AutoIt3Wrapper_Res_Description=PaletteCAD Gui
#AutoIt3Wrapper_Res_Fileversion=1.0.0.11
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=Y
#AutoIt3Wrapper_Res_Fileversion_First_Increment=Y
#AutoIt3Wrapper_Res_ProductVersion=1.0.0.0
#AutoIt3Wrapper_Res_LegalCopyright="Michael Mönter"
#AutoIt3Wrapper_Res_Language=1031
#Au3Stripper_Parameters=/StripUnusedVars=0 /PE /MI=5
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#region -- developer defination ; added by Daniel
#include-once
#pragma compile(ExecLevel, none)
#pragma compile(Console, False)
#pragma compile(AutoItExecuteAllowed, False)
#AutoIt3Wrapper_Run_Debug_Mode=n                 ;(Y/N) Run Script with console debugging. Default=N
#AutoIt3Wrapper_Run_Debug=Off
#pragma compile(x64, false)
#Au3Stripper_Ignore_Funcs= _Edit*,_ChooseColor,EditFontPopUp
#EndRegion

#region ------ INCLUDEs OPTs ------ ;Razionated by Daniel
#include <StructureConstants.au3>
#Include <AVIConstants.au3>
#Include <ButtonConstants.au3>
#Include <ComboConstants.au3>
#Include <DateTimeConstants.au3>
#Include <EditConstants.au3>
#Include <GuiConstantsEx.au3>
#Include <ListBoxConstants.au3>
#Include <ListViewConstants.au3>
#Include <ProgressConstants.au3>
#Include <SliderConstants.au3>
#Include <StaticConstants.au3>
#Include <TabConstants.au3>
#Include <TreeViewConstants.au3>
#Include <UpDownConstants.au3>
#Include <WindowsConstants.au3>
#include <Constants.au3>				; for popup section
#include "Include\conexion_db.au3" 	; Db routines (Daniel)
#include "Include\ModernMenuRaw.au3" ; New Menu (Daniel)
#include "Include\Debug.au3" 	; Debug (Daniel)
#include "Include\Various.au3" 		; Various (Daniel)
#include "Include\base_db.au3" 		; More Db routines (Daniel)
#Au3Stripper_Off
#include <Array.au3>
#include <Misc.au3>						; for choose color control (Daniel)
#include <GuiComboBoxEx.au3> 			; for popup section
#include <GUIListView.au3>  			; for style property (Daniel
#include <GuiStatusBar.au3>
#include <GuiEdit.au3>
#include <GuiImageList.au3>
#Au3Stripper_On
;;;;;;;;;;;;;;;;;;;;;;;;;;

Opt("WinTitleMatchMode", 4) ;advanced
Opt("WinWaitDelay", 10)     ;speeds up WinMove
Opt("GuiResizeMode", 802)   ;controls will never move when window is resized
Opt("WinTitleMatchMode", 1) ;1=start, 2=subStr, 3=exact, 4=advanced, -1 to -4=Nocase
opt("MustDeclareVars",0)
#endregion ------ includes opts -----

$iMsgBoxAnswer = MsgBox(65,"ACHTUNG!","Dieses Programm Kommt >NICHT< von Palette CAD." & @CRLF & "D.h. Palette CAD ist nicht zum Support verflichtet.")
IF $iMsgBoxAnswer = 2 Then Exit

#Region ---------------Global const and variable -------------------------
Global $pusch
Global const $db_acct=1
Global const $gui="$hGUI"
Global const $_make="style_make"
Local const $vars="carga_variables"
Global $_valor=0
Global $_class=""
Global $_pjtfile=""
Global $destination
Global $code
global $hDB=-1
Global $lfld,$autoit_exe
;;;; Local;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Local $db_file=""
Global $MCL[1000][24]


$db_file=Load_ini()
mensaje_("Db_file",number($db_file))
if $db_file<>"" then
	$hDB=dbopen($db_file)
EndIf

if hex2dec($hDB)<1 then
	msgbox(0,"Database","Die Datenbank konnte nicht gefunden werden")
	Exit
EndIf
carga_variables($vars)
mensaje_("Main","carga de variables ","$lfld=",$lfld)

global $cmdln = $CmdLine[0]
Global $tip

Global $MODE = 2
Global $INITDRAW = 0, $DRAWING = 1, $INITMOVE = 2, $MOVING = 3, $INITRESIZE = 4, $RESIZING = 5
Global $mode_SnapGrid = 1, $mode_pastePos = 1, $mode_ShowGrid,$GripSnapCtrl,$GripSnapAllCtrl
Global $px = -99, $py = -99

Global $currentCtrl=0, $currentType, $p, $lock, $prevX, $prevY, $cursorInfo, $hover, $numCtrls, $grippyCtrl, $delCtrls = 0 , $aj, $includes
Global $GriProp, $ctrlCounter,$oldctrl
Global $papply=-9999
Global $pCancel=-9999
Global $copiedWidth = 0, $copiedHeight = 0
Global $defaultWidth = 80, $defaultHeight = 20

local $oldmode

Global $lock = 0
Global $N = 24
Global $type[$N+1]

Global $menu0,$menu1,$menu2,$menu3,$menu4,$menu5,$menu6,$menu8,$menu9,$menu10,$menu11,$menu12,$menu13,$menu14
Global $properties,$showHidden,$showGrid,$gridSnap,$pastePos,$menu71,$menu72,$menu70,$menu73,$menu74 ,$menu7,$menu8,$menu81

Global $_tmp0,$_tmp1="larata",$_tmp2=null,$_tmp3=null,$_tmp4=null
Global $_tmp5=null,$_tmp6=null,$_tmp7=null,$_tmp8=null

Global $grippySize = 6
Dim $grippy[9]
Global $AgdOutFile = ""

#EndRegion -------- Global const and variable ---------

#Region ------ Main ------

Global $main= GuiCreate("PaletteCad XML Builder - Form", 1, 40, -99999, -99999, 0x94CE0000)
Dim $overlayTarget
Dim $AgdInfile, $cmdchk, $done, $gdtitle, $gdvar, $lfld, $mygui


Global $overlay = GuiCtrlCreateLabel("foo", -99, -99, 1, 1, 0x107)
local $junk=GUICtrlCreateDummy()
local $junk=GUICtrlCreateDummy()
Global $rect = GUICtrlCreateLabel("foo", -1, -1, 1, 1,0x107)

For $i = 1 to 8
	$grippy[$i] = GuiCtrlCreateLabel("", -99,-99, $grippySize, $grippySize, 0x104)
Next

Global $NorthWest_Grippy =  $grippy[1]
Global $North_Grippy     =  $grippy[2]
Global $NorthEast_Grippy =  $grippy[3]
Global $West_Grippy      =  $grippy[4]
Global $East_Grippy      =  $grippy[5]
Global $SouthWest_Grippy =  $grippy[6]
Global $South_Grippy     =  $grippy[7]
Global $SouthEast_Grippy =  $grippy[8]

global const $BACKG_STYLE = 0x5000000E
global const $tab_style = 0x50010200
Global $background = GUICtrlCreatePic(@ScriptDir & "\background.bmp", 0, 0, 1024,768)
mensaje_("inicio:"," $background=",$background)
GUICtrlSetState($background, 128)

Global $firstControl = 0

GuiSetState(@SW_SHOW,$main)
WinMove($main,"", 290, @DesktopHeight/2-175, 400,350)

completa_mcl($main)

;;; Create other windows ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
$toolbar=__Create_Toolbar($main)
Global $Prop=__Create_Propeties($main)
$host=__Create_host($main)
AdlibRegister("_FIX")
#endregion ------ Main ------

#region ------ MESSAGE LOOP ------
GUISetState(@SW_SHOW,$host)
GUISetState(@SW_SHOW,$toolbar)
GuiSetState(@SW_SHOW,$main)
GUISwitch($main) ;Rather important!
WinActivate($main)
__Load_Properties($currentCtrl)

Local $ctrlinterp
While 1
	Global $winSize = WinGetClientsize($main)
	If "PaletteCad XML Builder - Form (" & $winSize[0] & " x " & $winSize[1] & ")" <> WinGetTitle($main) Then
		WinSetTitle($main, "", "PaletteCad XML Builder - Form (" & $winSize[0] & " x " & $winSize[1] & ")")
	EndIf
	;
	If WinActive($main) Then
			EnableHotKeys()
		Else
			DisableHotKeys()
	EndIf

	Global $msg = GuiGetMsg(1)
	if $msg[1]=2 then $ctrlinterp=$msg[2]
	Select
		case $msg[0]=$papply	; accept in Property windows
			Prop2MCL($currentCtrl)
			__EditProperties($currentCtrl)
		case $msg[0]=$pCancel	; cancel properties
			__Load_Properties($currentCtrl)
		Case $msg[0] = $menu2 OR $msg[0] = $GUI_EVENT_CLOSE ;-3 ;exit
			Global $ans = MsgBox(4096+3, "Quit?", "Do you want to Save a GUI?")
			If $ans = 6 Then ExitLoop
			If $ans = 7 Then Exit
			;ExitLoop

		Case $msg[0] = $menu3 		;About
			MsgBox(64, "About PaletteCad XML Builder", "Prototype 1.0 - created by Michael Mönter"&@CRLF&"E-Mail:michael_moenter@web.de")

		Case $msg[0] = $menu4		; Save to file .agd
			_SaveGuiDefinition()

		Case $msg[0] = $menu5		; Load from file .agd
			_LoadGuiDefinition()
			$currentCtrl=0
			$oldctrl=0
			__Load_Properties($currentCtrl)

		Case $msg[0] = $properties	; Show Properties
			If $grippyCtrl = 0 Then
					Msgbox(4096, "Error", "Please select a control first!")
				Else
					__EditProperties($grippyCtrl) ;New Grid function
			EndIf

		Case $msg[0] = $menu9
			$_pjtfile=make_aui3($_pjtfile,0)

		Case $msg[0] = $showGrid	;mostrar ocultar grilla
			If Toolbar_Get($showGrid)  Then
				Toolbar_Set($showGrid,0)
				GUICtrlSetImage($background, @ScriptDir & "\blank.bmp")
			Else
				Toolbar_Set($showGrid,1)
				GUICtrlSetImage($background, @ScriptDir & "\background.bmp")
			EndIf
			$mode_ShowGrid = NOT $mode_ShowGrid
			WinActivate($main)
			_repaintWindow()

		Case $msg[0] = $gridSnap
			Toolbar_Set($gridSnap)
			$mode_SnapGrid = NOT $mode_SnapGrid
			WinActivate($main)

		case $msg[0]=$GripSnapCtrl
			if $currentCtrl>0 then
				CtrlSnap($currentCtrl)
				__Load_Properties($currentCtrl)
				WinActivate($main)
				_repaintWindow()
			EndIf

		case $msg[0]=$GripSnapAllCtrl
			for $i=$firstControl to $firstControl+$numCtrls+1
				if $MCL[$i][0]<>"" then
					CtrlSnap($i)
				EndIf
			next
			__Load_Properties($currentCtrl)
			WinActivate($main)
			_repaintWindow()

		Case $msg[0] = $pastePos
			Toolbar_Set($pastePos)
			$mode_PastePos = NOT $mode_PastePos
			WinActivate($main)

		Case $msg[0] = $type[1]
				$mode = $INITMOVE
			WinActivate($main)
		Case $msg[0] >= $type[2] And $msg[0] <= $type[$N]
				mensaje_(">=2 y <N: $msg[0]=",$msg[0])
			_clickType($msg[0])

		Case $msg[0] = $background
			If $Mode = $INITDRAW Then
					$p = GuiGetCursorInfo($main)
					$currentCtrl = _CreateCtrl('')
					$grippyCtrl = $currentCtrl
					$Mode = $DRAWING
					$MCL[$currentCtrl][14]=get_class_id($MCL[$currentCtrl][0])
			EndIf

		Case $msg[0] = $overlay
			$grippyCtrl = $hover
			$mode = $MOVING
			$currentCtrl = $hover
			Global $c = ControlGetPos($main,"",$currentCtrl)
			$p = _MouseSnapPos()
			Global $xOffset = $p[0] - $c[0]
			Global $yOffset = $p[1] - $c[1]
			ToolTip($xOffset & "," & $yOffset)
			GuiCtrlSetPos($overlay, -99, -99, 1, 1)

		Case $msg[0] >= $grippy[1] And $msg[0] <= $grippy[8]
			handleGrippy($msg[0], $grippyCtrl)
			$pusch = $grippyCtrl

		case Else

	EndSelect

	If $done = "" Then
		$done = 1
		CheckCommandline()
		GetScriptTitle()
	EndIf

	If WinActive($main) Then
		$cursorInfo = GuiGetCursorInfo($main)
	EndIf
	Select
		Case $cursorInfo[4] = $grippy[1]
			GuiSetCursor(12, 1)

		Case $cursorInfo[4] = $grippy[2]
			GuiSetCursor(11, 1)

		Case $cursorInfo[4] = $grippy[3]
			GuiSetCursor(10, 1)

		Case $cursorInfo[4] = $grippy[4]
			GuiSetCursor(13, 1)

		Case $cursorInfo[4] = $grippy[5]
			GuiSetCursor(13, 1)

		Case $cursorInfo[4] = $grippy[6]
			GuiSetCursor(10, 1)

		Case $cursorInfo[4] = $grippy[7]
			GuiSetCursor(11, 1)

		Case $cursorInfo[4] = $grippy[8]
			GuiSetCursor(12, 1)
	EndSelect


	Global $wgcs = WinGetClientSize($main)
	If $cursorInfo[0] <= 0 Or $cursorInfo[1] <= 0 Or $cursorInfo[0] >= $wgcs[0] Or $cursorInfo[1] >= $wgcs[1] Then
		ContinueLoop
	EndIf

	If $cursorInfo[4] = 0  or $cursorInfo[4] = $background or ($cursorInfo[4] >= $grippy[1] And $cursorInfo[4] <= $grippy[8]) Then
		$hover = 0
		If ($cursorInfo[4] < $grippy[1] Or $cursorInfo[4] > $grippy[8]) Then GUISetCursor(3, 1) ;3=crosshair cursor
		GuiCtrlSetPos($overlay, -99, -99, 1, 1)
	Else
		If $cursorInfo[4] <> $overlay Then
			$hover = $cursorInfo[4]
			global $cp = ControlGetPos("","",$cursorInfo[4])
		EndIf
		If $mode = $INITMOVE Then
			GuiCtrlSetPos($overlay, $cp[0], $cp[1], $cp[2]+1, $cp[3]+1)
			If ($cursorInfo[4] < $grippy[1] Or $cursorInfo[4] > $grippy[8]) Then GUISetCursor(2, 1)
		EndIf
	EndIf

	If $Mode = $DRAWING Then
		Local $c = GUIGetCursorInfo($main)  ;$p[0] = x  and $p[1] = y
		$c = _MouseSnapPos()
		ToolTip("(" & $c[0] - $p[0] & ", " & $c[1] - $p[1] & ")")
		GUICtrlSetPos($currentCtrl, $p[0], $p[1], $c[0] - $p[0], $c[1] - $p[1])
		If $cursorInfo[2] = 0 Then
			$Mode = $INITMOVE
			If $c[0] - $p[0] <= 0 OR $c[1] - $p[1] <= 0 Then
				GUICtrlSetPos($currentCtrl, $p[0], $p[1], $defaultWidth, $defaultHeight)
			EndIf
			GUICtrlSetState($background, 128)
			$currentType = ""
			ToolTip('')
			$MCL[$currentCtrl][16]=$p[0]
			$MCL[$currentCtrl][17]=$p[1]
			$MCL[$currentCtrl][18]=$c[0] - $p[0]
			$MCL[$currentCtrl][19]=$c[1] - $p[1]
			$MCL[$currentCtrl][20]=""
			$MCL[$currentCtrl][21]=""
			$MCL[$currentCtrl][22]=""
			__Load_Properties($currentCtrl)
			ControlClick("Choose Control Type","",$type[1])
			WinActivate($main)
			$qaz=1
		EndIf
	EndIf
	;
	If $Mode = $MOVING Then
		GUISetCursor(9, 1)
		$p = _MouseSnapPos()
		ToolTip("(" & $p[0] & ", " & $p[1] & ")")
		GuiCtrlSetPos($currentCtrl, $p[0]-$xOffset, $p[1]-$yOffset, $c[2], $c[3])
		For $i = 1 to 8
			GuiCtrlSetPos($grippy[$i], -99, -99, $grippySize, $grippySize)
		Next
		If $cursorInfo[2] = 0 Then
			$Mode = $INITMOVE
			GUICtrlSetState($background, 128)
			$currentType = ""
			ToolTip('')
			$MCL[$currentCtrl][16]=$p[0]-$xOffset
			$MCL[$currentCtrl][17]=$p[1]-$yOffset
			$MCL[$currentCtrl][18]=$c[2]
			$MCL[$currentCtrl][19]=$c[3]
			__Load_Properties($currentCtrl)
		EndIf
	EndIf

	If $grippyCtrl > 0 And $mode <> $MOVING And $mode <> $DRAWING Then
		showGrippies($grippyCtrl)
    EndIf

	If $mode = $DRAWING Then
		Local $h = ControlGetPos("","",$currentCtrl)
		Local $size =  $h[3] - 20
		If $h[2] - 20 < $size Then $size = $h[2] - 20
		GuiCtrlSendMsg($currentCtrl, 27+0x0400, $size, 0)
		if $mode<>$oldmode then
			$oldmode=$mode
		EndIf
	EndIf

	if $OldCtrl<>$currentCtrl then
		__Load_Properties($currentCtrl)
		$OldCtrl=$currentCtrl
	EndIf


	if $msg[0]=$GUI_EVENT_PRIMARYDOWN then
		Local $qm=GUIGetCursorInfo($main)
		if $qm[4]=$background then
			$OldCtrl=$currentCtrl
			$currentCtrl=0
			$grippyCtrl=0
			showGrippies(0)
		EndIf
	EndIf

WEnd
#endregion ------ message loop ------

$_pjtfile=make_aui3($_pjtfile,1)
Exit
Func _FIX()
	Local $pos = WinGetPos($host)
	Local $pos2 = WinGetPos($main)
	WinMove($main,"",$pos[0]+150,$pos[1]+$pos[3])
	WinMove($toolbar,"",$pos[0],$pos[1]+$pos[3])
	Local $c = $pos2[2]+150+$pos[0]
	If $c > $pos[0]+$pos[2] Then
	WinMove($Prop,"",$c,$pos[1])
	Else
	WinMove($Prop,"",$pos[0]+$pos[2],$pos[1])
	EndIf
EndFunc

#region ------ CODE GENERATION ------
Func make_aui3($source,$borra)

	mensaje_("make_aui3("&$source&","&$borra&") : Recibido")
	Local $comm,$meta,$includ,$declara,$msg_loop,$start_up,$functions 	; parts of the code
	Local $destination,$code

	$start_up=au3_gui()

	$code=$start_up
	if $source="" then
			$destination = FileSaveDialog("Save Form to file?", "", "Extensible Markup Language (*.xml)", 19, "MyForm.xml")
			$desrination=only_name($destination)
		Else
			$destination=only_name($source)&".xml"
   EndIf
   If @error = 1 Or $destination = "" Then
		ClipPut($code)
		SplashTextOn("Done", @CRLF & "XML copied to clipboard!", 200, 100)
	Else
		FileDelete($destination)
		FileWrite($destination, $code)
		SplashTextOn("Done", @CRLF & "Saved to file!", 200, 100)
	EndIf
	Sleep(1000)
	SplashOff()
	return $destination
EndFunc


Func au3_gui()
	const $vh='$'
	const $es=''
	const $cm=","
	local $ret='<PropertyDialog Name="">'&@LF&'<Controls>'&@LF
	Local $mat,$cant,$clasid,$error=0,$sent

	For $i = 0 To UBound($MCL) - 1
		if $MCL[$i][1]="" then ContinueLoop
		$_tmp0= $MCL[$i][0]
		$cant=dbprep4("create_ctrl",$mat)
		mensaje_("au3_gui()"," row="&$i," Class=",$_tmp1," $cant=",$cant)
		if $cant<1 then ; clase not found
			$error=$error+1
			ContinueLoop
		EndIf
		ConsoleWrite($i&@CRLF)
		$ret&=_NameToXML($MCL[$i][0],$mcl[$i][1],$mcl[$i][2],$MCL[$i][4],$MCL[$i][5],$mcl[$i][16],$mcl[$i][17],$mcl[$i][18],$mcl[$i][19],$MCL[$i][14],$MCL[$i][13])
	Next
	$ret&='</Controls>'&@LF&'</PropertyDialog>'

	return $ret
EndFunc

Func _NameToXML($name,$prop,$text,$enable,$Visible,$posx,$posy,$width,$hight,$classid,$Tip)
	$posx = Round($posx*0.706,0)	; Anpassung der Größe
	$posy = Round($posy*0.706,0)	; Anpassung der Größe
	$width = Round($width*0.706,0)	; Anpassung der Größe
	$hight = Round($hight*0.706,0)	; Anpassung der Größe
	If $name = "Radio" Then
		$ret = '<Control Type="RADIOBUTTON" VarType="STRING" PropertyName="'&$prop&'" Default="" Enable="'&$enable&'" Tooltip="'&$Tip&'" Visible="'&$Visible&'">'&@LF
		$ret &= '<Item Value="'&$classid&'" Pos="'&$posx&','&$posy&'" Width="'&$width&'" Height="'&$hight&'">'&$text&'</Item>'&@LF
        $ret &= '</Control>'&@LF
		Return $ret
	ElseIf $name = "Label" Then
		Return '<Control Type="TEXT" Pos="'&$posx&','&$posy&'" Width="'&$width&'" Height="'&$hight&'" Enable="'&$enable&'" Tooltip="'&$Tip&'" Visible="'&$Visible&'">'&$text&'</Control>'&@LF
	ElseIf $name = "Color_Chooser" Then
		Return '<Control Type="COLORBUTTON" Pos="'&$posx&','&$posy&'" Width="'&$width&'" Height="'&$hight&'" Enable="'&$enable&'" Tooltip="'&$Tip&'" Visible="'&$Visible&'"/>'&@LF
	ElseIf $name = "Date" Then
		Return '<Control Type="DATEPICKER" Pos="'&$posx&','&$posy&'" Width="'&$width&'" Height="'&$hight&'" Enable="'&$enable&'" Tooltip="'&$Tip&'" Visible="'&$Visible&'"/>'&@LF
	ElseIf $name = "Button" Then
		Return '<Control Type="BUTTON" Pos="'&$posx&','&$posy&'" Width="'&$width&'" Height="'&$hight&'" Enable="'&$enable&'" Tooltip="'&$Tip&'" Visible="'&$Visible&'">'&$text&'</Control>'&@LF
	ElseIf $name = "Input" Then
		Return '<Control Type="EDIT" Pos="'&$posx&','&$posy&'" Width="'&$width&'" Height="'&$hight&'" Enable="'&$enable&'" Tooltip="'&$Tip&'" Visible="'&$Visible&'" Default="'&$text&'" />'&@LF
	ElseIf $name = "Group" Then
		Return '<Control Type="GROUPBOX" Pos="'&$posx&','&$posy&'" Width="'&$width&'" Height="'&$hight&'" Enable="'&$enable&'" Tooltip="'&$Tip&'" Visible="'&$Visible&'">'&$text&'</Control>'&@LF
	ElseIf $name = "Checkbox" Then
		Return '<Control Type="CHECKBOX" Pos="'&$posx&','&$posy&'" Width="'&$width&'" Height="'&$hight&'" Enable="'&$enable&'" Tooltip="'&$Tip&'" Visible="'&$Visible&'">'&$text&'</Control>'&@LF
	ElseIf $name = "Date" Then
		Return '<Control Type="DATEPICKER" Pos="'&$posx&','&$posy&'" Width="'&$width&'" Height="'&$hight&'" Enable="'&$enable&'" Tooltip="'&$Tip&'" Visible="'&$Visible&'">'&$text&'</Control>'&@LF
	ElseIf $name = "Pic" Then
		Return '<Control Type="PICTURE" Rect="'&$posx&','&$posy&','&$width&','&$hight&'" Tooltip="'&$Tip&'">'&$text&'</Control>'&@LF
	ElseIf $name = "Combo" Then
		$ret = '<Control Type="COMBOBOX" Pos="'&$posx&','&$posy&'" Width="'&$width&'" Height="'&$hight&'" VarType="STRING" PropertyName="'&$prop&'" Default="" Enable="'&$enable&'" Tooltip="'&$Tip&'" Visible="'&$Visible&'">'&@LF
		$ret &= '<Item Value="'&$classid&'">'&$text&'</Item>'&@LF
        $ret &= '</Control>'&@LF
		Return $ret
	Else
		Return ""
	EndIf
EndFunc

Func Make_add_code($tipo)

	Local $code=""
	Local $clases,$class,$vacio
	$clases=_ArrayExtract($MCL,-1,-1,14,14)
	$class=_ArrayUnique($clases,0,0,0,0,0)
	$vacio=_ArraySearch($class,"")
	if $vacio>0 then _ArrayDelete($class,$vacio)
	$_tmp1=_ArrayToString($class,",")
	$_tmp0=$tipo
	$code=dbprep3("load_dependencias",@crlf)
	return $code&@CRLF
EndFunc
#endregion ------ code generation ------

#region ------ Controls  ------
Func _CreateCtrl($arg)
	Local $w = 1, $h = 1
	Local $p, $winSize, $ret
	$p = _MouseSnapPos()
	If $arg <> "" Then
		$currentType = $arg
		$w = $copiedWidth
		$h = $copiedHeight
		If $mode_PastePos = 0 Then
			$p[0] = 0
			$p[1] = 0
		Else
			$winSize = WinGetClientSize($main)
			If $p[0] < 0 Or $p[1] < 0 Or $p[0] > $winSize[0] Or $p[1] > $winSize[1] Then
				$p[0] = 0
				$p[1] = 0
			Endif
		EndIf
	EndIf
	$numCtrls = $numCtrls + 1
	$ctrlCounter = $ctrlCounter + 1
	$ret=_CreateCtrlLow($currentType,enc($currentType&"_"& $ctrlCounter),$p[0],$p[1],$w,$h)
	if $ret<1 then return

	If $firstControl = 0 Then $firstControl = $ret
	$MCL[$ret][0] = $currentType
	$MCL[$ret][1] = $currentType & "_" & $ctrlCounter
	$MCL[$ret][2] = $currentType & "_" & $ctrlCounter
	$MCL[$ret][3] = ""
	$MCL[$ret][8] = 0x000000
	$MCL[$ret][4] = "True"
    $MCL[$ret][5] = "True"
	Return $ret
EndFunc

Func _CreateCtrlLow($arg,$text,$x,$y,$width,$height,$style=-1,$style_ex=-1,$filename="",$subfile=0,$order=0,$mark=0,$pid=0)
	Local $returnValue,$params,$cant
	$_tmp0=$arg
	$_tmp1=$text
	$_tmp2=$x
	$_tmp3=$y
	$_tmp4=$width
	$_tmp5=$height
	$_tmp6=$style
	$_tmp7=$style_ex
	$_tmp8=$filename
	$_tmp9=$subfile
	$_tmp10=$order
	$_tmp11=$mark
	$_tmp12=$pid
	$cant=dbprep4("create_ctrl",$params)
	if number($cant)<5 then return -2
    $returnValue=execstring($params[1][2],"::")
	if  $returnValue=0 then return -1
	$defaultWidth=$params[1][3]
	$defaultHeight=$params[1][4]

	Switch $arg
		case  "Tab"
			_createAnotherTabItem($returnValue, "Tab Num 1")
			GuiSwitch($main)
			GuiSetState()
			Global $background = GUICtrlCreatePic(@ScriptDir & "\background.bmp", 0, 0, 1024,768)
		case "TreeView"
			GUICtrlCreateTreeViewItem($text, $returnValue)
			$numCtrls = $numCtrls + 1
			$ctrlCounter = $ctrlCounter + 1
		case "Updown"
			GUICtrlSetData($returnValue, 100)
		case "Progress"
			GUICtrlSetData($returnValue, 100)
		Case Else
	EndSwitch
	Return $returnValue
EndFunc

Func showGrippies($ref)
	Local $GS = $grippySize
	Local $p = ControlGetPos($main, "", $ref)
	Local $L = $p[0]
	Local $T = $p[1]
	Local $W = $p[2]
	Local $H = $p[3]
	Local $i
		GuiCtrlSetPos($grippy[1], $L-$GS,        $T-$GS, $GS,$GS)  ;NW
		GuiCtrlSetPos($grippy[2], $L+($W-$GS)/2, $T-$GS, $GS,$GS)  ;N
		GuiCtrlSetPos($grippy[3], $L+($W), $T-$GS, $GS,$GS)        ;NE
		GuiCtrlSetPos($grippy[4], $L-$GS, $T+($H-$GS)/2, $GS,$GS)  ;W
		GuiCtrlSetPos($grippy[5], $L+$W,  $T+($H-$GS)/2, $GS,$GS)  ;E
		GuiCtrlSetPos($grippy[6], $L-$GS,        $T+$H, $GS,$GS)   ;SW
		GuiCtrlSetPos($grippy[7], $L+($W-$GS)/2, $T+$H, $GS,$GS)   ;S
		GuiCtrlSetPos($grippy[8], $L+($W), $T+$H, $GS,$GS)         ;SE
EndFunc

Func handleGrippy($grippyRef, $refSelected)
	Global $grippyPos = ControlGetPos($main,"", $grippyRef)
	_mouseClientMove( Int($grippyPos[0] + $GrippySize/2), Int($grippyPos[1] + $GrippySize/2) )
   Select
   Case $grippyRef = $South_Grippy
      While 1
         Local $i = GuiGetCursorInfo()
         If $i[2] = 0 Then ExitLoop
         Local $cp = ControlGetPos($main, "", $refSelected)
         ToolTip($cp[2] & ' x' & $cp[3])
         Global $mp = _mouseSnapPos()
         $cp[3] = $mp[1] - $cp[1]
         If $cp[3] < 1 Then $cp[3] = 1
         GuiCtrlSetPos($refSelected, $cp[0], $cp[1], $cp[2], $cp[3])
         showGrippies($refSelected)
         Local $h = ControlGetPos("","",$currentCtrl)
         GuiCtrlSendMsg($currentCtrl, 27+0x0400, $h[3] - 20, 0)
      WEnd
   Case $grippyRef = $North_Grippy
      Local $bottom = $cp[1] + $cp[3]
      While 1
         Local $i = GuiGetCursorInfo()
         If $i[2] = 0 Then ExitLoop
         Local $cp = ControlGetPos($main, "", $refSelected)
         ToolTip($cp[2] & ' x' & $cp[3])
   		$mp = _mouseSnapPos()
         $cp[1] = $mp[1]
         $cp[3] = $bottom - $mp[1]
         If $cp[3] < 1 Then
            $cp[3] = 1
            $cp[1] = $bottom
         EndIf
         GuiCtrlSetPos($refSelected, $cp[0], $cp[1], $cp[2], $cp[3])
         showGrippies($refSelected)
         Local $h = ControlGetPos("","",$currentCtrl)
         GuiCtrlSendMsg($currentCtrl, 27+0x0400, $h[3] - 20, 0)
      WEnd
   Case $grippyRef = $East_Grippy
      While 1
         Local $i = GuiGetCursorInfo()
         If $i[2] = 0 Then ExitLoop
         Local $cp = ControlGetPos($main, "", $refSelected)
         ToolTip($cp[2] & ' x' & $cp[3])
         $mp = _mouseSnapPos()
         $cp[2] = $mp[0] - $cp[0]
         If $cp[2] < 1 Then $cp[2] = 1
         GuiCtrlSetPos($refSelected, $cp[0], $cp[1], $cp[2], $cp[3])
         showGrippies($refSelected)
      WEnd
   Case $grippyRef = $West_Grippy
      Local $right = $cp[0] + $cp[2]
      While 1
         Local $i = GuiGetCursorInfo()
         If $i[2] = 0 Then ExitLoop
         Local $cp = ControlGetPos($main, "", $refSelected)
         ToolTip($cp[2] & ' x' & $cp[3])
         $mp = _mouseSnapPos()
         $cp[2] = $mp[0] - $cp[0]
         If $cp[2] < 1 Then $cp[2] = 1
         $mp = _mouseSnapPos()
         $cp[0] = $mp[0]
         $cp[2] = $right - $mp[0]
         If $cp[2] < 1 Then
            $cp[2] = 1
            $cp[0] = $right
         EndIf
         GuiCtrlSetPos($refSelected, $cp[0], $cp[1], $cp[2], $cp[3])
         showGrippies($refSelected)
         Local $h = ControlGetPos("","",$currentCtrl)
         GuiCtrlSendMsg($currentCtrl, 27+0x0400, $h[3] - 20, 0)
      WEnd
   Case $grippyRef = $SouthEast_Grippy
      While 1
         Local $i = GuiGetCursorInfo()
		 IF IsArray($i) Then
         If $i[2] = 0 Then ExitLoop
         Local $cp = ControlGetPos($main, "", $refSelected)
         ToolTip($cp[2] & ' x' & $cp[3])
         Local $prevWidth = $cp[2]
         Local $prevHeight = $cp[3]
         $mp = _mouseSnapPos()
         $cp[2] = $mp[0] - $cp[0]
         $cp[3] = $mp[1] - $cp[1]
         If $cp[2] < 1 Then $cp[2] = 1
         If $cp[3] < 1 Then $cp[3] = 1
         GuiCtrlSetPos($refSelected, $cp[0], $cp[1], $cp[2], $cp[3])
         showGrippies($refSelected)
         Local $h = ControlGetPos("","",$currentCtrl)
         GuiCtrlSendMsg($currentCtrl, 27+0x0400, $h[3] - 20, 0)
		 EndIf
      WEnd
   Case $grippyRef = $SouthWest_Grippy
      Local $right = $cp[0] + $cp[2]
      While 1
         Local $i = GuiGetCursorInfo()
         If $i[2] = 0 Then ExitLoop
         Local $cp = ControlGetPos($main, "", $refSelected)
         ToolTip($cp[2] & ' x' & $cp[3])
         Local $prevWidth = $cp[2]
         Local $prevHeight = $cp[3]
         $mp = _mouseSnapPos()
         $cp[3] = $mp[1] - $cp[1]
         If $cp[3] < 1 Then $cp[3] = 1
         $cp[0] = $mp[0]
         $cp[2] = $right - $mp[0]
         If $cp[2] < 1 Then
            $cp[2] = 1
            $cp[0] = $right
         EndIf
         GuiCtrlSetPos($refSelected, $cp[0], $cp[1], $cp[2], $cp[3])
         showGrippies($refSelected)
         Local $h = ControlGetPos("","",$currentCtrl)
         GuiCtrlSendMsg($currentCtrl, 27+0x0400, $h[3] - 20, 0)
      WEnd
   Case $grippyRef = $NorthEast_Grippy
      Local $bottom = $cp[1] + $cp[3]
      While 1
         Local $i = GuiGetCursorInfo()
         If $i[2] = 0 Then ExitLoop
         Local $cp = ControlGetPos($main, "", $refSelected)
         ToolTip($cp[2] & ' x' & $cp[3])
         Local $prevWidth = $cp[2]
         Local $prevHeight = $cp[3]
         $mp = _mouseSnapPos()
         $cp[2] = $mp[0] - $cp[0]
         If $cp[2] < 1 Then $cp[2] = 1
         $mp = _mouseSnapPos()
         $cp[1] = $mp[1]
         $cp[3] = $bottom - $mp[1]
         If $cp[3] < 1 Then
            $cp[3] = 1
            $cp[1] = $bottom
         EndIf
         GuiCtrlSetPos($refSelected, $cp[0], $cp[1], $cp[2], $cp[3])
         showGrippies($refSelected)
         Local $h = ControlGetPos("","",$currentCtrl)
         GuiCtrlSendMsg($currentCtrl, 27+0x0400, $h[3] - 20, 0)
      WEnd
   Case $grippyRef = $NorthWest_Grippy
      Local $right = $cp[0] + $cp[2]
      Local $bottom = $cp[1] + $cp[3]
      While 1
         Local $i = GuiGetCursorInfo()
         If $i[2] = 0 Then ExitLoop
         Local $cp = ControlGetPos($main, "", $refSelected)
         ToolTip($cp[2] & ' x' & $cp[3])
         Local $prevWidth = $cp[2]
         Local $prevHeight = $cp[3]
         $mp = _mouseSnapPos()
         $cp[1] = $mp[1]
         $cp[3] = $bottom - $mp[1]
         If $cp[3] < 1 Then
            $cp[3] = 1
            $cp[1] = $bottom
         EndIf
         $cp[2] = $mp[0] - $cp[0]
         If $cp[2] < 1 Then $cp[2] = 1
         $mp = _mouseSnapPos()
         $cp[0] = $mp[0]
         $cp[2] = $right - $mp[0]
         If $cp[2] < 1 Then
            $cp[2] = 1
            $cp[0] = $right
         EndIf
         GuiCtrlSetPos($refSelected, $cp[0], $cp[1], $cp[2], $cp[3])
         showGrippies($refSelected)
         Local $h = ControlGetPos("","",$currentCtrl)
         GuiCtrlSendMsg($currentCtrl, 27+0x0400, $h[3] - 20, 0)
      WEnd
   EndSelect
   ToolTip('')
	$i=ControlGetPos($main,"",$currentCtrl)
	$MCL[$currentCtrl][16]=$i[0]
	$MCL[$currentCtrl][17]=$i[1]
	$MCL[$currentCtrl][18]=$i[2]
	$MCL[$currentCtrl][19]=$i[3]
	__Load_Properties($currentCtrl)
   	mensaje_("handleGrippy("&$grippyRef&","&$refSelected&")","Salida")
EndFunc

Func _GuiCtrlCreateSlider($left, $top, $width, $height, $style)
	Local $ref = GuiCtrlCreateSlider($left, $top, $width, $height)
	If $style <= 0 Then $style = 0x50020001
	GuiCtrlSetStyle($ref, BitOr($style,0x040))
	Local $size =  $height - 20
	If $width - 20 < $size Then $size = $width - 20
	GuiCtrlSendMsg($ref, 27+0x0400, $size, 0)
	Return $ref
EndFunc

Func _createAnotherTab($left, $top, $width, $height)
  Local $parentGui = WinGetHandle("")
  Local $style = 0x56000000
  Global $tabCtrlWin = GuiCreate("", $width, $height, $left,$top, $style, -1, $parentGui)
  GuiCtrlCreateTab(0, 0, $width, $height)
  GuiSetState()
  GuiSwitch($parentGui)
  Return $tabCtrlWin
EndFunc

Func _createAnotherTabItem($tabHandle, $text)
	Local $parentGui = WinGetHandle("")
	GuiSwitch($tabHandle)
	Local $item = GuiCtrlCreateTabItem($text)
	If $text = "" Then GuiSwitch($parentGui)
	Return $item
EndFunc

Func DeleteControl()
	If $grippyCtrl > 0 And $MODE <> $DRAWING And $MODE <> $RESIZING And $MODE <> $MOVING Then
		mensaje_(" DeleteControl()"," =>",$grippyCtrl)
		Tooltip("Control Deleted")
		GuiCtrlDelete($grippyCtrl)
		$MCL[$grippyCtrl][0] = 0
		for $i=1 to ubound($MCL,2)-1
			$MCL[$grippyCtrl][$i]=""
		next
		$numCtrls = $numCtrls - 1
		$delCtrls = $delCtrls + 1
		$grippyCtrl = 0
		For $i = 1 to 8
			GuiCtrlSetPos($grippy[$i], -99, -99, $grippySize, $grippySize)
			GuiCtrlSetPos($overlay, -99, -99, 1, 1)
		Next
		sleep(300)
		Tooltip('')
	EndIf
EndFunc

Func CopyControl()
   If $grippyCtrl <= 0 Then Return
   if StringLen($MCL[$grippyCtrl][0])=0 then Return
   Local $size = ControlGetPos($main, "", $grippyCtrl)
   ClipPut("AutoBuilderData " & $MCL[$grippyCtrl][0] & " " & $size[2] & " " & $size[3])
EndFunc

Func PasteControl()

   Local $x = ClipGet()

  If StringLeft($x, 15) <> 'AutoBuilderData' Then Return
   Local $y = StringSplit($x, " ")
   $copiedWidth = $y[3]
   $copiedHeight = $y[4]
   $grippyCtrl = _CreateCtrl($y[2])
   showGrippies($grippyCtrl)

EndFunc

Func CtrlSnap($ctrl)

	const $dx=10
	const $dy=10
	local $x,$y,$w,$h
	Local $ret

	$x=round($MCL[$ctrl][16]/$dx,0)*$dx
	$y=round($MCL[$ctrl][17]/$dy,0)*$dy
	$w=round($MCL[$ctrl][18]/$dx,0)*$dx
	$h=round($MCL[$ctrl][19]/$dy,0)*$dy

	$MCL[$ctrl][16]=$x
	$MCL[$ctrl][17]=$y
	$MCL[$ctrl][18]=$w
	$MCL[$ctrl][19]=$h

	$ret=GUICtrlSetPos($ctrl,$x,$y,$w,$h)

	return $ret
endfunc

Func _updateWind($Ctrl)

EndFunc

Func _ctrlsetDefault($cid,$tipo)

	local $ret="",$cant=0,$Defaults
	mensaje_("_ctrlsetDefault("&$cid&","&$tipo&")"," Entrada")
	$_tmp1=$cid
	$cant=dbprep4("load_defaults",$Defaults)
 	mensaje_("_ctrlsetDefault()"," [2]=",$Defaults[1][2]," [3]=",$Defaults[1][3]," [4]=",$Defaults[1][4])
	;_ArrayDisplay($Defaults,"para $cid="&$cid")
	if $cant<1 then return ""
	return $Defaults[1][$tipo]
EndFunc

Func _updatectrl($Ctrl)
	GUICtrlSetData($Ctrl,$mcl[$Ctrl][2])
	GUICtrlSetPos($ctrl,$mcl[$Ctrl][16],$mcl[$Ctrl][17],$mcl[$Ctrl][18],$mcl[$Ctrl][19])
	;image
	ConsoleWrite("!"&$mcl[$Ctrl][20]&@CRLF&enc($mcl[$Ctrl][20])&@CRLF)
	GUICtrlSetImage($Ctrl,enc($mcl[$Ctrl][20]))
;~ 	GUICtrlSetColor
EndFunc

func _combosetcursel($combo,$valor)

	Local $a=_GUICtrlComboBoxEx_GetListArray($combo)
	for $i=1 to $a[0]
		if Execute($a[$i])=$valor then return $i
	next
   Return -1
EndFunc

Func _botonesEstilos($weight,$estilos,$hBold,$hItalic,$hunderline,$hstrike)
	local $tmp=0
	; italic
	$tmp=bitand($estilos,2)>0?$WS_EX_CLIENTEDGE:0
	GUICtrlSetStyle($hItalic,-1,$tmp)

	;underline
	$tmp=bitand($estilos,4)>0?$WS_EX_CLIENTEDGE:0
	GUICtrlSetStyle($hunderline,-1,$tmp)

	;strike
	$tmp=bitand($estilos,8)>0?$WS_EX_CLIENTEDGE:0
	GUICtrlSetStyle($hstrike,-1,$tmp)

     ;Bold
    $tmp=$weight>100?$WS_EX_CLIENTEDGE:0
    GUICtrlSetStyle($hBold,-1,$tmp)
EndFunc


#endregion ------  Controls  ------

#region ---------- Load Save and Test ------------------

Func _SaveGuiDefinition()

	Local $w, $h, $p
	Local $n = 0, $Key, $Text
	local $WHnd=0

	If $AgdOutFile = "" Then
		If $lfld = "" Then $lfld = @ScriptDir
		If Not FileExists($lfld) Then $lfld = ""
		If $lfld = "" Then $lfld =  @ScriptDir
		if $AgdOutFile="" then $AgdOutFile = FileSaveDialog("Save GUI Definition to file?", $lfld, "AutoIt Gui Definitions (*.agd)", 2+16, StringReplace($gdtitle, '"',""))
		If @error = 1 Or $AgdOutFile = "" Then
			If $AgdOutFile = 1 Then $AgdOutFile = ""
			SplashTextOn("Save GUI Definition to file", @CRLF & "Definition not saved!", 200, 80)
			Sleep(1000)
			SplashOff()
			Return
		Else
			$lfld=only_name($AgdOutFile,3)
			salva_variable("lfld",$lfld)
			If only_name($AgdOutFile,8) <> ".agd" Then $AgdOutFile = $AgdOutFile & ".agd"
			$_pjtfile=only_name($AgdOutFile)
			mensaje_("_SaveGuiDefinition()","Luego de salvar ",$AgdOutFile," , ",$_pjtfile)
			$mygui=only_name($AgdOutFile,7)
			mensaje_("_SaveGuiDefinition()","$mygui=",$mygui)
			$gdtitle=enc($mygui)
			$mygui = $mygui & ".au3"
			mensaje_("_SaveGuiDefinition()","$mygui=",$mygui,",$gdtitle=",$gdtitle)
		EndIf
	EndIf
	;
	FileDelete($AgdOutFile)
	If @error Then
		SplashTextOn("Save GUI Definition to file", @CRLF & "Definition not saved!", 200, 80)
		Sleep(1000)
		SplashOff()
		Return
	EndIf

	IniWrite($AgdOutFile, "Main", "Left",$MCL[$WHnd][16])
	IniWrite($AgdOutFile, "Main", "Top",$MCL[$WHnd][17])
	IniWrite($AgdOutFile, "Main", "Width",$MCL[$WHnd][18])
	IniWrite($AgdOutFile, "Main", "Height",$MCL[$WHnd][19])
	IniWrite($AgdOutFile, "Main", "ClaseId",$MCL[$WHnd][14])
	IniWrite($AgdOutFile, "Main", "Style",$MCL[$WHnd][12])
	IniWrite($AgdOutFile, "Main", "StyleEx",$MCL[$WHnd][15])
	IniWrite($AgdOutFile, "Main", "Pid",$MCL[$WHnd][23])
	;
	For $i = $firstControl To $firstControl+$numCtrls-1
		If $MCL[$i][0] Then
			$n = $n + 1
			$Key = "Control_" & $n
			IniWrite($AgdOutFile, $Key, "Type", $MCL[$i][0])
			IniWrite($AgdOutFile, $Key, "Name", $MCL[$i][1])
			IniWrite($AgdOutFile, $Key, "Text", $MCL[$i][2])
			IniWrite($AgdOutFile, $Key, "Default", $MCL[$i][3])
			IniWrite($AgdOutFile, $Key, "Enabled", $MCL[$i][4])
			IniWrite($AgdOutFile, $Key, "Visible", $MCL[$i][5])
			IniWrite($AgdOutFile, $Key, "State", $MCL[$i][6])
			IniWrite($AgdOutFile, $Key, "DbId", $MCL[$i][7])
			IniWrite($AgdOutFile, $Key, "Color", $MCL[$i][8])
			IniWrite($AgdOutFile, $Key, "Font", $MCL[$i][9])
		    IniWrite($AgdOutFile, $Key, "Style", $MCL[$i][12])
			IniWrite($AgdOutFile, $Key, "Tip", $MCL[$i][13])
			IniWrite($AgdOutFile, $Key, "ClaseId", $MCL[$i][14])
			IniWrite($AgdOutFile, $Key, "StyleEx", $MCL[$i][15])
			IniWrite($AgdOutFile, $Key, "Left", $MCL[$i][16])
			IniWrite($AgdOutFile, $Key, "Top", $MCL[$i][17])
			IniWrite($AgdOutFile, $Key, "Width", $MCL[$i][18])
			IniWrite($AgdOutFile, $Key, "Height", $MCL[$i][19])
			IniWrite($AgdOutFile, $Key, "Image", $MCL[$i][20])
			IniWrite($AgdOutFile, $Key, "Cursor", $MCL[$i][21])
			IniWrite($AgdOutFile, $Key, "Backcolor", $MCL[$i][22])
			IniWrite($AgdOutFile, $Key, "Pid",$MCL[$WHnd][23])
	   EndIf
	Next
	IniWrite($AgdOutFile, "Main", "numctrls", $n)

	SplashTextOn("Save GUI Definition to file", @LF & "Saved to " & @LF & $AgdOutFile, 500, 100)
	Sleep(2000)
	SplashOff()
EndFunc

Func _LoadGuiDefinition()

	Const $WHnd=0
	Const $cm=",",$pi="|"
	Local $w, $h, $p[4], $rv, $ac = 0
	Local $n = 0, $Key , $i, $nc,$f,$obj_id
	Local $Type, $Name, $Text,$style,$style_ex
	Local $Visible,$Enabled,$Default,$color,$DBid
	Local $Font,$tip,$state,$handle	,$Backcolor
	Local $Image,$cursor,$clase,$pid
	Local $version
	local $dire
	local $new_version=0
	Global $_modulo
	Local $clase,$clase_id

	If $numCtrls > 0 Then
		If MsgBox(52,"Load Gui Definition from file", _
			"Loading a Gui Definition will clear existing controls." & @CRLF & _
			"Are you sure?" & @CRLF) = 7 Then
			Return
		EndIf
	EndIf

	If $lfld = "" Then $lfld = @scriptdir

	If $cmdln = "" or $cmdln = 0  Then
		$AgdInfile = FileOpenDialog("Load GUI Definition from file?", $lfld, "AutoIt Gui Definitions (*.agd)", 1)
		If @error Then 	Return
	Else
		$cmdln = ""
	EndIf

	$w = IniRead($AgdInfile, "Main", "Width",-1)
	If $w = -1 Then

		MsgBox(16,"Load Gui Error", "Error loading gui definition. ")
		Return
	EndIf

	For $i = $firstControl To $firstControl+$numCtrls-1
		If $MCL[$i][0] Then
			GUICtrlDelete($i)
		EndIf
	Next

	ReDim $MCL[1][24]
	ReDim $MCL[1000][24]

	$h = IniRead($AgdInfile, "Main", "guiheight",-1)
	$p[0] = IniRead($AgdInfile, "Main", "Left",-1)
	$p[1] = IniRead($AgdInfile, "Main", "Top",-1)
	$p[2] = IniRead($AgdInfile, "Main", "Width",-1)
	$p[3] = IniRead($AgdInfile, "Main", "Height",-1)
	$version= IniRead($AgdInfile, "Main", "Version",-1)
	$clase= IniRead($AgdInfile, "Main", "Type","Window")
	$style=	IniRead($AgdInfile, "Main", "Style",-1)
	$style_Ex=IniRead($AgdInfile, "Main", "StyleEx",-1)
	$clase_id=IniRead($AgdInfile, "Main", "ClaseId",-1)
	$clase	=IniRead($AgdInfile, "Main", "Clase","")
	$pid	=IniRead($AgdInfile, "Main", "Pid",0)

	if $clase="" then
		$clase="Window"
	EndIf

	if $clase_id=-1 then
		$clase_id=get_class_id($clase)
	EndIf

		if $pid=-1 then
		$pid=0
	EndIf

	WinMove($main, "", $p[0], $p[1], $p[2], $p[3])
	GUISetStyle($style,$style_Ex,$main)

	$MCL[$WHnd][0]=$clase
	$MCL[$WHnd][12]=$style
	$MCL[$WHnd][14]=$clase_id
	$MCL[$WHnd][15]=$Style_Ex
	$MCL[$WHnd][16]=$p[0]
	$MCL[$WHnd][17]=$p[1]
	$MCL[$WHnd][18]=$p[2]
	$MCL[$WHnd][19]=$p[3]
	$MCL[$WHnd][23]=$pid

	$nc = IniRead($AgdInfile, "Main", "numctrls",-1)

	For $i = 1 To $nc
		$Key = "Control_" & $i
		$Type = 	IniRead($AgdInfile, $Key, "Type",-1)
		$Name = 	IniRead($AgdInfile, $Key, "Name",-1)
		$Text = 	IniRead($AgdInfile, $Key, "Text",-1)
		$p[0] = 	IniRead($AgdInfile, $Key, "Left",-1)
		$p[1] = 	IniRead($AgdInfile, $Key, "Top",-1)
		$p[2] = 	IniRead($AgdInfile, $Key, "Width",-1)
		$p[3] =		IniRead($AgdInfile, $Key, "Height",-1)
		$Default = 	IniRead($AgdInfile, $Key, "Default",-1)
		$Enabled = 	IniRead($AgdInfile, $Key, "Enabled",-1)
		$Visible = 	IniRead($AgdInfile, $Key, "Visible",-1)
		$style=		IniRead($AgdInfile, $Key, "Style",-1)
	    $DBid = 	IniRead($AgdInfile, $Key, "Dbid",-1)
		$color = 	IniRead($AgdInfile, $Key, "Color",-1)
		$Font = 	IniRead($AgdInfile, $Key, "Font","")
		$clase_id = IniRead($AgdInfile,$Key, "ClaseId",-1)
		$style_Ex=	IniRead($AgdInfile, $Key, "StyleEx",-1)
		$Tip=		IniRead($AgdInfile, $Key, "Tip","")
		$State=		IniRead($AgdInfile, $Key, "State","")
		$handle=	IniRead($AgdInfile, $Key, "handle","")
		$Image=   	IniRead($AgdInfile, $Key, "Image","")
		$cursor=  	IniRead($AgdInfile, $Key, "Cursor","")
		$Backcolor=	IniRead($AgdInfile, $Key, "Backcolor","")
		$pid	=	IniRead($AgdInfile, $Key, "Pid",0)


		mensaje_("_LoadGuiDefinition()","x,y,ancho y alto recibidos ",$p[0],",",$p[1],",",$p[2],",",$p[3])

		if $clase_id=-1 then $clase_id=get_class_id($Type)
		if $handle="" then $handle="$"&$Key

		if $style=-1 or $style=""	 	then  $style=_ctrlsetDefault($clase_id,2)
		if $style_Ex=-1 or $style_Ex="" then  $style_ex=_ctrlsetDefault($clase_id,3)
		if $State="" 				 	then  $State=_ctrlsetDefault($clase_id,4)

		$rv=_CreateCtrlLow($type,enc($Text), $p[0], $p[1], $p[2], $p[3],pi2st($style),pi2st($style_Ex),enc($Image))
		mensaje_("_LoadGuiDefinition()","Info ",$AgdInfile," Control=",$rv," Type ",$Type)
		if $rv<1 then ContinueLoop ; Error

		Switch $type
			case ""

			case Else

		EndSwitch

		if $tip<>"" then GUICtrlSetStyle(-1,$tip)
		if $state<>-1 then GUICtrlSetState(-1,$state)

		if $font<>"" then
			$f=StringSplit($font,"|",0)
			GUICtrlSetFont ( -1, $f[2] , $f[4], $f[5], $f[1], 5 )
        EndIf

		If $Enabled = "False" Or $Visible = "False" Then
			GuiCtrlSetState(-1, $GUI_DISABLE)
		EndIf

		If $i = 1 then $firstControl = $rv
		$MCL[$rv][0] = $Type
		$MCL[$rv][1] = $Name
		$MCL[$rv][2] = $Text
		$MCL[$rv][3] = $Default
		$MCL[$rv][4] = $Enabled
		$MCL[$rv][5] = $Visible
		$MCL[$rv][6] = $State
		$MCL[$rv][7] = $DBid
		$MCL[$rv][8] = $color
		$MCL[$rv][9] = $font
	    $MCL[$rv][12] = $style
		$MCL[$rv][13] = $tip
		$MCL[$rv][14] = $clase_id
		$MCL[$rv][15] = $Style_Ex
		$MCL[$rv][16] = $p[0]
		$MCL[$rv][17] = $p[1]
		$MCL[$rv][18] = $p[2]
		$MCL[$rv][19] = $p[3]
		$MCL[$rv][20]= $Image
		$MCL[$rv][21]= $cursor
		$MCL[$rv][22]= $Backcolor
		$MCL[$rv][23]=$pid

	Next
	$numCtrls = $nc + $ac
	$ctrlCounter = $numCtrls
    $grippyCtrl = 0
	Beep(500,100)
	sleep(20)

	SplashTextOn("Load GUI Definition from file", @LF & "Loaded from " & @LF & $AgdInfile, 500, 100)

	$AgdOutFile = $AgdInfile
    $_pjtfile=only_name($AgdOutFile)

	$dire=only_name($AgdOutFile,3)
	salva_variable("lfld",$dire)

	Sleep(200)
	SplashOff()
EndFunc

func guitest($destination)

	const $cd=Chr(34)
	mensaje_("guitest("&$destination&") : Recibido")
	mensaje_("guitest(): $main="&$main)
	mensaje_("guitest(): $autoit_exe="&$autoit_exe&" Exist?="&FileExists($autoit_exe))
	if FileExists($autoit_exe)=0 then
		msgbox(0,"Warning, Auto_it.exe not found","Change varible autoit_exe in Db")
		return ""
	EndIf


	const $path=$cd&$autoit_exe&$cd ; program with path

	if $destination="" then
		msgbox(0,"Warning","Export After the run")
		return ""
	EndIf

	make_aui3(only_name($destination)&".au3",0)
	local $exe=$path&" "&$cd&$destination&".au3"&$cd
	mensaje_("guitest(): $exe="&$exe)
	local $pid=RunWait($exe,@ScriptDir,@SW_MAXIMIZE, 0x10000  )
	mensaje_("guitest(): $pid="&$pid)
endfunc

#endregion - Load Save and Test --------------------

#region ------ HOTKEYS ------
Func EnableHotKeys()

	HotKeySet("{Delete}", "DeleteControl")
	HotKeySet("^c", "CopyControl")
	HotKeySet("^v", "PasteControl")
	HotKeySet("{Esc}", "Nulo") ;trap Esc just because I don't want Esc closing the whole GUI
EndFunc

Func DisableHotKeys()

	HotKeySet("{Delete}")
	HotKeySet("^c")
	HotKeySet("^v")
	HotKeySet("{Esc}")
EndFunc

#endregion ------ hotkeys ------

#Region ---------------------Properties-------------------
Func __Create_Propeties($pid)
	Local const $prop_load="propiedades_load"
	Local $p,$resul,$a
	Global $_clase=27

	Local $hPGUI = GUICreate("Properties", 232, 590, 750, 80, -1,$WS_EX_DLGMODALFRAME,$pid)
	$papply=GUICtrlCreateButton("Apply",120,510,100,40)
	$pCancel=GUICtrlCreateButton("Cancel",10,510,100,40)
	GUISetBkColor(0xffEBA6,$hPGUI)

	$hpropiedades = GUICtrlCreateListView(".|.|...", 0, 0, 230,500,bitor(0x0001,$LVS_SINGLESEL,$WS_VSCROLL),bitor($LVS_EX_FULLROWSELECT,$LVS_EX_GRIDLINES,$LVS_EX_INFOTIP))
	_GUICtrlListView_SetBkColor ($hpropiedades,  0xA6ffEB)
	 _GUICtrlListView_SetTextBkColor($hpropiedades, 0xA6ffEB)
	_GUICtrlListView_SetColumn($hpropiedades,0,"Properties",100)
	_GUICtrlListView_SetColumn($hpropiedades,1,"Value",125)
	_GUICtrlListView_SetColumn($hpropiedades,2,"id",0)
	$p=dbprep4($prop_load, $resul)
	for $i=1 to $db_filas
		_GUICtrlListView_AddItem($hpropiedades,$resul[$i][1])							;label
		_GUICtrlListView_AddSubItem($hpropiedades,$i-1,"",1, -1 )						;Value
		_GUICtrlListView_AddSubItem($hpropiedades,$i-1,String($resul[$i][0]),2, -1 )	;id (hidden)
	next
	$GriProp=GUICtrlGetHandle($hpropiedades)
	GUISetState(@SW_SHOW,$hPGUI)
	;GUISetStyle($WS_MINIMIZEBOX+$WS_SIZEBOX,-1,$hPGUI)
	GUIRegisterMsg($WM_NOTIFY, "WM_NOTIFY")
	Return $hPGUI

Do
	$pMsg = GuiGetMsg(1)
	switch $pMsg[0]
		case $LVN_ITEMACTIVATE
		Case -3	; close event
	EndSwitch
until $pMsg[0]=-3

EndFunc

Func __Load_Properties($Ctrlid)
	const $cmax=3
	const $borrado="||"
	Const $prop_sql="propiedades_load"
	Local $f=_GUICtrlListView_GetItemCount($GriProp)
	Local $clase_id=$MCL[$Ctrlid][14]
	Local $properties
	Local $ret=0,$dev	,$col,$valor


	for $i=0 to $f-1
		for $j=0 to $cmax-1
			_GUICtrlListView_SetItem($GriProp,Null,$i,$j)
		next
	next

	$_clase=$clase_id
	$dev=dbprep4($prop_sql,$properties)
	if $dev<1 then return -1
	for $i=1 to $db_filas
		if $i>$f then
			_GUICtrlListView_AddItem($GriProp,"")				;label
			_GUICtrlListView_AddSubItem($GriProp,$i-1,"",1,-1)	;value
			_GUICtrlListView_AddSubItem($GriProp,$i-1,"",2,-1)	; prop_id
		EndIf
		_GUICtrlListView_SetItem($GriProp,$properties[$i][1],$i-1,0)
		_GUICtrlListView_SetItem($GriProp,$properties[$i][0],$i-1,2)
	next


	for $i=1 to $db_filas
		$col=$properties[$i][6]
		switch $col
			case -1
				$valor=$ctrlid
				$ret+=1
			case 0 to 99
				$valor=$MCL[$ctrlid][$col]
				$ret+=1
			case Else
				$valor="##Error##"
		EndSwitch
		_GUICtrlListView_SetItem($GriProp,$valor,$i-1,1)
	next
	return $ret
EndFunc

Func Prop2MCL($Ctrlid)

	Local $f=_GUICtrlListView_GetItemCount($GriProp)
	Local $j,$k
	for $i=0 to $f-1
		$j=_GUICtrlListView_GetItemText($GriProp,$i,2)
		$k=get_mcl_idx($j)

		switch $k
			case -2

			case -1

			case 0 to 99
				$MCL[$Ctrlid][$k]=_GUICtrlListView_GetItemtext($GriProp,$i,1)
			case Else

		EndSwitch
	next
EndFunc

Func __EditProperties($Ctrl)
	ConsoleWrite("!"&$Ctrl&@CRLF)
	if $ctrl>0 then _updatectrl($Ctrl)
	if $ctrl=0 then _updateWind($Ctrl)
EndFunc

Func get_property_id($property_name)
	if IsDeclared("$_tmp1")=0 then Global $_tmp1
	$_tmp1=$property_name
	return dbprep2("get_property_id")
EndFunc

Func get_mcl_idx($property_id)
	if IsDeclared("$_tmp1")=0 then Global $_tmp1
	$_tmp1=$property_id
	return dbprep2("get_MCL_idx")
EndFunc

Func _PropiedadesEventos($hWnd, $iMsg, $wParam, $lParam, $ctrlhandle)
    #forceref $hWnd, $iMsg, $wParam
	const $ss="::"
	Global $_actual
    Local $hWndFrom, $iIDFrom, $iCode, $tNMHDR, $hWndListView, $tInfo,$resul,$handle, $m, $a
    ; Local $tBuffer
    $hWndListView =$ctrlhandle
	If Not IsHWnd($ctrlhandle) Then $hWndListView = GUICtrlGetHandle($ctrlhandle)
    $tNMHDR = DllStructCreate($tagNMHDR, $lParam)
    $hWndFrom = HWnd(DllStructGetData($tNMHDR, "hWndFrom"))
    $iIDFrom = DllStructGetData($tNMHDR, "IDFrom")
    $iCode = DllStructGetData($tNMHDR, "Code")
	Switch $hWndFrom
        Case $hWndListView
            Switch $iCode
                Case $NM_DBLCLK ; Sent by a list-view control when the user double-clicks an item with the left mouse button
                    $tInfo = DllStructCreate($tagNMITEMACTIVATE, $lParam)
					Local $indice=DllStructGetData($tInfo, "Index")
					global $_id=_GUICtrlListView_GetItemText( $ctrlhandle, $indice,2 )
					$_clase=$MCL[$currentCtrl][14]
					local $metodo=dbprep4("propiedades_acciones",$resul)

                    $_actual=_GUICtrlListView_GetItemText( $ctrlhandle, $indice,1)


					if $resul[1][0]="" Then
						return
					EndIf
					if $resul[1][3]<>"" Then
						$_tmp1=execstring($resul[1][3],$ss)
					EndIf
					Local $dinpar
					string2parameters($resul[1][1], ",", $dinpar)

					#Au3Stripper_Off
					$a=Call($resul[1][0],$dinpar)

					#Au3Stripper_On

					$_tmp1=StringSplit($a,"|",0)

					switch $_id
						case 14
							$a=$_tmp1[1]
						case 15
							$a=$_tmp1[2]
						case 16
							$a=($_tmp1[4]>100)?"B":""

							$a=$a&" "&((bitand($_tmp1[5],2)>0)?"I":"")
							$a=$a&" "&((bitand($_tmp1[5],4)>0)?"U":"")
							$a=$a&" "&((bitand($_tmp1[5],8)>0)?"S":"")
						case 19
							$a=$_tmp1[3]
						case 20
							$a=($_tmp1[4]>100)?"B":""
						case 21
							$a=((bitand($_tmp1[5],2)>0)?"I":"")
						case 22
							$a=((bitand($_tmp1[5],4)>0)?"U":"")
						case 23
							$a=((bitand($_tmp1[5],8)>0)?"S":"")
					EndSwitch

					if $resul[1][2]<>Null Then
						execstring($resul[1][2],$ss)
						ConsoleWrite($resul[1][2])
						GUISetState()
					EndIf

					_GUICtrlListView_SetItemText($ctrlhandle,$indice,$a,1)

				Case $NM_CLICK
					$tInfo = DllStructCreate($tagNMITEMACTIVATE, $lParam)

			EndSwitch

	EndSwitch
	GUISwitch($main)
    Return 'GUI_RUNDEFMSG'
	;$GUI_RUNDEFMSG
EndFunc   ;==>WM_NOTIFY

func completa_mcl($obj)

	const $pos=0
	Local $rect, $text,$state,$stylos,$junk,$color,$bkcolor,$textmetric,$tInfo

	$rect=WinGetPos($obj)
	$text=WinGetTitle($obj)
	$state=WinGetState($obj)
	$stylos=GUIGetStyle($obj)
	$bkcolor=_WinAPI_GetSysColor($COLOR_APPWORKSPACE)
	$color=_WinAPI_GetSysColor($COLOR_WINDOWTEXT)

	$junk=_WinAPI_GetDC($obj)
	$textmetric=_WinAPI_GetTextMetrics($junk)
	$tInfo=DllStructCreate($tagTEXTMETRIC,$textmetric)

	Local $junk2="tmHeight:"&DllStructGetData($tInfo, "tmHeight")&",tmAscent:"&DllStructGetData($tInfo, "tmAscent")&",tmAveCharWidth:"&DllStructGetData($tInfo, "tmAveCharWidth")&",tmMaxCharWidth:"&DllStructGetData($tInfo, "tmMaxCharWidth") &",tmPitchAndFamily:"&DllStructGetData($tInfo, "tmPitchAndFamily")


	mensaje_("completa_mcl("&$obj&")"," color=",hex($color),",",hex($bkcolor),",",$junk2)


	$mcl[$pos][00]="Window"
	$mcl[$pos][01]="Win_Main"
	$mcl[$pos][02]=$text
	$mcl[$pos][06]=$state
	$mcl[$pos][07]=-1
	$mcl[$pos][08]="0x"&hex($color)

	$mcl[$pos][12]="0x"&hex($Stylos[0])

	$mcl[$pos][14]=get_class_id($mcl[$pos][00])
	$mcl[$pos][15]="0x"&hex($Stylos[1])
	$mcl[$pos][16]=$rect[0]
	$mcl[$pos][17]=$rect[1]
	$mcl[$pos][18]=$rect[2]
	$mcl[$pos][19]=$rect[3]

	$mcl[$pos][22]="0x"&hex($bkcolor)

endfunc

#EndRegion ---------------------Properties-------------------

#region ------------------------ Eventos --------------------
Func WM_NOTIFY($hWnd, $iMsg, $wParam, $lParam)
	Local $ret,$class
	Local $handle=$hWnd
	If Not IsHWnd($hWnd) Then $handle = GUICtrlGetHandle($hWnd)
	$handle=_WinAPI_GetFocus()
	$class=_WinAPI_GetClassName ($handle)

	if $class="SysListView32" then
		if IsDeclared("debug_donde") Then
			mensaje_("WM_NOTIFY("&$hWnd&","&$iMsg&","&$wParam&","&$lParam&")"," Inicio")
		EndIf
		$ret=_PropiedadesEventos($hWnd, $iMsg, $wParam, $lParam,$handle)
		if IsDeclared("debug_donde") Then
			mensaje_("WM_NOTIFY("&$hWnd&","&$iMsg&","&$wParam&","&$lParam&")"," Final")
		EndIf

	EndIf

    return False
EndFunc

#endregion ------------------------ Eventos --------------------

#region recursos Popup
Func _EditDataPopUp($phandle,$titulo,$contenido,$cancela,$salva)
$cancela = "cancel"
$salva = "Save"

	#include-once
	if IsDeclared("GUI_DISABLE")=0 then
		#include <GUIConstantsEx.au3>
	EndIf

	mensaje_("_EditDataPopUp("&$phandle&","&$titulo&","&$contenido&","&$cancela&","&$salva&")")
	Local $hEditingData,$hDataGUI,$hControlDataEdit,$hDataSave,$hDataCancel,$ret,$aMsg

	$hDataGUI = GUICreate($titulo, 622, 296, -1, -1)
	$hControlDataEdit = GUICtrlCreateEdit($contenido, 10, 10, 602, 230)
	GUICtrlCreateLabel(null, 0, 252, 622, 45)
	GUICtrlSetState(-1, $GUI_DISABLE)
	GUICtrlSetBkColor(-1, 0xFFFFFF)
	GUICtrlCreateLabel(null, 0, 251, 634, 1)
	GUICtrlSetBkColor(-1, 0xA0A0A0)
	$hDataSave = GUICtrlCreateButton($salva, 463, 260, 150, 28)
	GUICtrlSetFont(-1, 8, 400, 0, "Verdana")
	$hDataCancel = GUICtrlCreateButton($cancela, 303, 260, 150, 28)
	GUICtrlSetFont(-1, 8, 400, 0, "Verdana", 5)
	GUISetState()
	Sleep(11)

	$hEditingData = True
	While $hEditingData = True
		Sleep(11)
		$aMsg = GUIGetMsg()
		Switch $aMsg
			Case $GUI_EVENT_CLOSE, $hDataCancel
				$hEditingData = False
				$ret=$contenido
			Case $hDataSave
				$hEditingData = False
			    $ret=GUICtrlRead($hControlDataEdit)
		EndSwitch
	WEnd
	GUIDelete($hDataGUI)
	return $ret
Endfunc

Func _EditComboPopUp($Window,$titulo,$contenido,$cancela,$salva,$opciones,$combo_label)

$cancela = "cancel"
$salva = "Save"

	const $sep="|"
	Local $OptionsGUI , $OptionsCombo, $AddOptionsButton, $OptionsListView, $hSaveButton, $hCancelButton, $hDeleteOptionsButton  ; objects
	Local $AddingOptions, $contenido2, $hSelect,$index, $opciones2, $hMsg	; strings and one event
	Local $ret=""

	$OptionsGUI = GUICreate($titulo, 313,363, -1, -1)
	GUICtrlCreateLabel($combo_label&":", 6, 10, 38, 13)
	$OptionsCombo = GUICtrlCreateCombo(Null, 45, 5, 230, 21, 0x0003)
	$AddOptionsButton = GUICtrlCreateButton("+", 281, 3, 25, 25)
	GUICtrlSetFont($AddOptionsButton, 12, 800, 0)
	$OptionsListView = GUICtrlCreateListView($combo_label, 34, 31, 271, 300, 0x00280000)
	_GUICtrlListView_SetColumnWidth($OptionsListView, 0, 220)
	$hSaveButton = GUICtrlCreateButton($salva, 227, 334, 80, 25)
	$hCancelButton = GUICtrlCreateButton($cancela, 144, 334, 80, 25)
	$hDeleteOptionsButton = GUICtrlCreateButton("-", 5, 55, 25, 25)
	GUICtrlSetFont($hDeleteOptionsButton, 8.5, 800, 0)

	$contenido2=StringReplace($contenido,"+",$sep,0,0)
	_string2ListView($OptionsListView,$contenido2,$sep,0)
	$opciones2=_StringQuitDuplicates($opciones,$contenido2,$sep)
	GUICtrlSetData($OptionsCombo, $opciones2, Null)
	_GUICtrlComboBox_SetCurSel($OptionsCombo, 0)

	GUISetState()

	$AddingOptions=True
	While $AddingOptions = True
		Sleep(11)
		$hMsg = GUIGetMsg()
		Switch $hMsg
			Case -3, $hCancelButton
				$AddingOptions = False
				$ret=$contenido
			Case $AddOptionsButton
				$hSelect = GUICtrlRead($OptionsCombo)
				If $hSelect <> Null Then
					_GUICtrlListView_AddItem($OptionsListView, $hSelect)
					$index=_GUICtrlComboBox_GetCurSel ($OptionsListView)
					_GUICtrlComboBox_DeleteString ($OptionsCombo,$index)
					_GUICtrlComboBox_SetCurSel ($OptionsCombo,$index)
				EndIf
			Case $hDeleteOptionsButton
				$hSelect=_GUICtrlListView_GetItemTextString ($OptionsListView,-1)
				_GUICtrlListView_DeleteItemsSelected(GUICtrlGetHandle($OptionsListView))
				_GUICtrlComboBox_AddString ( $OptionsCombo,$hSelect)


			Case $hSaveButton
				$AddingOptions = False
				$ret=_ListView2String($OptionsListView,$sep)
		EndSwitch
	WEnd
	$hMsg=0

	GUIDelete($OptionsGUI)
	return $ret
EndFunc

func EditFontPopUp($Hwnd,$titulo,$actuales,$salva,$cancela,$textos,$sep,$opciones=255)

$cancela = "cancel"
$salva = "Save"

	#include-once
	if IsDeclared("SS_LEFT")=0 then
		#include <StaticConstants.au3>
	EndIf
	If  IsDeclared("ES_NUMBER")=0 then
		#include <GuiEdit.au3>
	endif


	static $back
	if $back<>1 then

	Global const $COLOR_DRAKMAROON=0x422100
	Global const $COLOR_MEDMAROON=0xA65300
	Global const $COLOR_MEDMAROON2=0x9F5000
	Global const $COLOR_LIGHTORANGE=0xFFE7CE
	Global const $COLOR_MEDORANGE=0xFDB879
	Global const $COLOR_ORANGE=0xFC881F
	Global const $COLOR_DARKORANGE=0xDF4A02
	Global const $COLOR_LIGHTBLUE=0xDFFDFF
	Global const $COLOR_POORVIOLET=0xCECEFF
	Global const $COLOR_LIGHTVIOLET=0x9191FF
	Global const $COLOR_MEDYELLOW=0x422100
	Global CONST $COLOR_LIGHTYELLOW=0XFFFFA8
	Global CONST $COLOR_INTENSEYELLOW=0XECEC00
	Global const $botones=0x122436 ;0xC8B380
	$back=1
	EndIf

    const $fondo=0xDED1B4


	Const $color_def=$COLOR_ORANGE
	local $ilumbk=(rgb2Luminancia($fondo)<121)?0:1

	const $colores="$COLOR_AQUA,$COLOR_BLACK,$COLOR_BLUE,$COLOR_CREAM,$COLOR_FUCHSIA,$COLOR_GRAY,$COLOR_GREEN,$COLOR_LIME,$COLOR_MAROON,$COLOR_MEDBLUE,$COLOR_MEDGRAY,$COLOR_MONEYGR,$COLOR_NAVY,$COLOR_OLIVE,$COLOR_PURPLE,$COLOR_RED,$COLOR_SILVER,$COLOR_SKYBLUE,$COLOR_TEAL,$COLOR_WHITE,$COLOR_YELLOW,$COLOR_DRAKMAROON,$COLOR_MEDMAROON,$COLOR_MEDMAROON2,$COLOR_LIGHTORANGE,$COLOR_MEDORANGE,$COLOR_ORANGE,$COLOR_DARKORANGE,$COLOR_LIGHTBLUE,$COLOR_POORVIOLET,$COLOR_LIGHTVIOLET,$COLOR_MEDYELLOW,$COLOR_LIGHTYELLOW,$COLOR_INTENSEYELLOW"
	const $evt=999999
	Local const $cm=","


	Global $hcolor=$evt


	Local $hFntW,$hCombo=$evt,$hsize=$evt,$hColor=$evt,$hbold=$evt,$hitalic=$evt
	Local $hunderline=$evt,$hstrike=$evt,$hsave,$hfoMsg,$hcancel
	Local $hImage,$hmuestra,$hLabel, $hLabel2,$hLabel3,$hLabel4
	Local $texto,$actual,$opcion[8],$color,$original
	Local $yd=0,$xd=0,$ws,$ind
	Local $iIndex,$sText,$ilumft,$mfondo
	Local $modif,$ret,$fin=0

	Local $DefaultFont = "Comic Sans MS"
	Local $Fonts = $DefaultFont & "|Arial|Arial Black|Comic Sans MS|Courier|Courier New|Estrangelo Edessa|Franklin Gothic Medium|Gautami|Georgia|Georgia Italic Impact|Impact|Latha|Lucida Console|Lucida Sans Console|Lucida Sans Unicode|Marlett|Modern|Modern MS Sans Serif|MS Sans Serif|MS Serif|MV Boli|Palatino Linotype|Roman|Segoe UI|Script|Small Fonts|Symbol|Tahoma|Times New Roman|Trebuchet|Verdana|Webdings|Wingdings"
	Local $texto=StringSplit($textos&$sep&$sep&$sep&$sep,$sep,0)
	local $actual=StringSplit($actuales,$sep,0)
	if $actual[1]="" then $actual[1]=$DefaultFont
	if $actual[2]="" then $actual[2]=18
	if $actual[3]="" then $actual[3]=$color_def
	if $actual[4]="" then $actual[4]=600
	if $actual[5]="" then $actual[5]=0
    for $i=0 to 7
		$opcion[$i]=bitand($opciones,1)
		$opciones=$opciones/2
	next

	$ws=120+30*($opcion[7]+$opcion[6]+$opcion[5]+BitOR($opcion[4],$opcion[3],$opcion[2],$opcion[1]))

	$hFntW = GUICreate($titulo, 313, $ws, -1, -1,$WS_OVERLAPPED + $WS_CAPTION + $WS_VISIBLE + $WS_CLIPSIBLINGS,-1,$Hwnd)
	GUISetBkColor($fondo,$hFntW)

	if $opcion[7]=1 then
		$hLabel = GUICtrlCreateLabel($texto[1], 50,20+$yd, 40, 20)
		$hCombo = GUICtrlCreateCombo($actual[1], 100, 20+$yd, 165, 21,$CBS_DROPDOWNLIST,$CBES_EX_NOSIZELIMIT)
		GUICtrlSetData($hCombo,$Fonts)
		$yd=$yd+30
    endif

	if $opcion[6]=1 then
		$hLabel2 = GUICtrlCreateLabel($texto[2], 50,20+$yd, 40, 20)
		$hsize=GUICtrlCreateEdit($actual[2],100,20+$yd,30,20,$ES_NUMBER)
		$yd=$yd+30
    EndIf

	if $opcion[5]=1 then
		Local $color=StringSplit($colores,$cm,0)
		$hImage = _GUIImageList_Create(16, 14, 5, 3)
		$hLabel3 = GUICtrlCreateLabel($texto[3], 50,20+$yd, 40, 20)
		$hColor=_GUICtrlComboBoxEx_Create($hFntW,"",100,20+$yd,165,120,$CBS_DROPDOWNLIST,$CBES_EX_NOSIZELIMIT )
		_GUICtrlComboBoxEx_InitStorage($hColor, $color[0]+2, 300)
    	_GUICtrlComboBoxEx_BeginUpdate($hColor)
		for $i=1 to $color[0]
			_GUIImageList_Add($hImage, _GUICtrlComboBoxEx_CreateSolidBitMap($hColor, Execute($color[$i]), 16, 16))
			_GUICtrlComboBoxEx_AddString($hColor,StringLower($color[$i]), $i-1, $i-1)
		next
		_GUICtrlComboBoxEx_SetImageList($hColor, $hImage)
		$ind=_combosetcursel($hColor, $actual[3])
		_GUICtrlComboBoxEx_SetCurSel ($hColor, $ind)
		_GUICtrlComboBoxEx_EndUpdate($hColor)
		$yd=$yd+30
	endif

	if $opcion[4]=1 then
		$hBold = GUICtrlCreateButton("B", 100+$xd, 20+$yd, 20, 21)
		$xd=$xd+30
    endif

	if $opcion[3]=1 then
		$hItalic = GUICtrlCreateButton("I", 100+$xd, 20+$yd, 20, 21)
		$xd=$xd+30
    endif

	if $opcion[2]=1 then
		$hunderline = GUICtrlCreateButton("U", 100+$xd, 20+$yd, 20, 21)
		$xd=$xd+30
    endif

	if $opcion[1]=1 then
		$hstrike = GUICtrlCreateButton("S", 100+$xd, 20+$yd, 20, 21)
		$xd=$xd+30
    endif

    if BitOR($opcion[4],$opcion[3],$opcion[2],$opcion[1])>0 then
		$hLabel4 = GUICtrlCreateLabel($texto[4], 50, 20+$yd, 40, 20)
		$yd=$yd+30
	EndIf

	if BitOR($opcion[4],$opcion[3],$opcion[2],$opcion[1])>0 then
		_botonesEstilos($actual[4],$actual[5],$hBold,$hItalic,$hunderline,$hstrike)
    EndIf

	$hmuestra = GUICtrlCreateLabel("Hospital Universal", 20, 20+$yd, 273, 36,$SS_CENTER)
	GUICtrlSetFont($hmuestra,$actual[2],$actual[4],$actual[5],$actual[1],5)
	GUICtrlSetColor($hmuestra,execute($actual[3]))
	$yd=$yd+50

	$hcancel = GUICtrlCreateButton($cancela, 40, 20+$yd, 80, 25)
	$hsave = GUICtrlCreateButton($salva, 190, 20+$yd, 80, 25)

	GUISetState(@SW_SHOW,$hFntW)

	While $fin=0
		$modif=0
		$hfoMsg = GUIGetMsg()
		Switch $hfoMsg
			Case $hBold
			    $actual[4]=700-$actual[4]
				GUICtrlSetState($hmuestra,$GUI_FOCUS)
				$modif=1


			Case $hItalic
			    $actual[5]=bitxor($actual[5],2)
				GUICtrlSetState($hmuestra,$GUI_FOCUS)
				$modif=1

			case $hstrike
				$actual[5]=bitxor($actual[5],8)
				GUICtrlSetState($hmuestra,$GUI_FOCUS)
				$modif=1

			case $hunderline
				$actual[5]=bitxor($actual[5],4)
				GUICtrlSetState($hmuestra,$GUI_FOCUS)
				$modif=1

			Case $hCombo,$hColor,$hsize,-8
				$modif=1
				if $opcion[6]=1 then $actual[2]=GUICtrlRead($hsize)
				$iIndex=_GUICtrlComboBox_GetCurSel($hcombo)
				_GUICtrlComboBoxEx_GetItemText ($hcombo, $iIndex, $actual[1])

			Case $hsave
				$original=StringSplit($actuales,$sep,0)
				$ret=""
				for $i=1 to 5
					Switch $i
						case 1
						   $ret=($opcion[7]=1)?$actual[1]:$original[1]
						case 2
						   $ret=$ret&$sep&(($opcion[6]=1)?$actual[2]:$original[2])
						case 3
							$ret=$ret&$sep&(($opcion[5]=1)?$actual[3]:$original[3])
						case 4
							$ret=$ret&$sep&(($opcion[4]=1)?$actual[4]:$original[4])
						case 5
							$ret=$ret&$sep&((($opcion[3]+$opcion[2]+$opcion[1])>0)?$actual[5]:$original[5])
					EndSwitch

				next
				$fin=1
			Case $GUI_EVENT_CLOSE,$hcancel
				$ret=$actuales
				$fin=1
		EndSwitch
	    if $modif=1 then
			GUICtrlSetFont($hmuestra,$actual[2],number($actual[4]),$actual[5],$actual[1],5)
			_botonesEstilos($actual[4],$actual[5],$hBold,$hItalic,$hunderline,$hstrike)

			$iIndex=_GUICtrlComboBoxEx_GetCurSel ($hcolor)
			_GUICtrlComboBoxEx_GetItemText ($hcolor, $iIndex, $actual[3])
			$stext=execute($actual[3])
			if $opcion[5]=1 then
				GUICtrlSetColor($hmuestra,$stext)
				local $ilumft=(rgb2Luminancia($stext)<120)?0:1
				local $mfondo=($ilumft<>$ilumbk)?$fondo:abs($stext-0x804080)
				GUICtrlSetBkColor($hmuestra,$mfondo)
			EndIf
			$modif=0
		EndIf
		sleep(10)
	WEnd
	GUIDelete($hFntW)

	return $ret
EndFunc

Func _EditCheckBoxPopUp($hPhandle,$titulo,$contenido,$checks,$cancela,$salva,$sep,$modo)

$cancela = "cancel"
$salva = "Save"

	Local $Apply ,$Cancel
	Local $suma
	Local $Info
	Local $A,$B,$C
	Local $devo
	Local $size
	Local $tmp112
	Local $ECBC
	Local Const $hECB = GUICreate($titulo, 300, 300, -1, -1, BitOR( $WS_CAPTION,$WS_CLIPCHILDREN,$DS_MODALFRAME,$WS_DLGFRAME),$WS_EX_TOPMOST,$hPhandle)
    Local $iListView = GUICtrlCreateListView("", 0, 0, 300, 250,$LVS_NOCOLUMNHEADER)
    Local Const $hListView = GUICtrlGetHandle($iListView)
    _GUICtrlListView_SetExtendedListViewStyle($hListView, BitOR($LVS_EX_FULLROWSELECT, $LVS_EX_CHECKBOXES))
	GUICtrlSetResizing(-1, $GUI_DOCKBORDERS)
	GUICtrlSetResizing(-1, $GUI_DOCKRIGHT + $GUI_DOCKSIZE + $GUI_DOCKBOTTOM)
	 $Cancel = GuiCtrlCreateButton($cancela, 40, 260, 100, 30)
	$Apply = GuiCtrlCreateButton($salva, 160, 260, 100, 30)
	GUISetBkColor(0xFFFFFF,$hECB)
	GUISetState(@SW_SHOWNORMAL, $hECB)
    $info=stringsplit($checks,$sep,0)
	$b=UBound($Info,1)-1
	if $b<1 then return -1
	$size =ControlGetPos("","",$hListView)
	_GUICtrlListView_InsertColumn($hListView, $A, "",$size[2]-20)
	$c=$sep&$contenido&$sep
		_GUICtrlListView_AddItem($hListView, "TRUE", 1)
		_GUICtrlListView_AddItem($hListView, "FALSE", 2)
	For $A = 1 To 2
		if StringInStr($c,$sep&$info[$A]&$sep,1)>0 then
			_GUICtrlListView_SetItemChecked($hListView, $A-1,True)
		EndIf
	Next
	GUISetState(@SW_SHOW,$hECB)

	While 1
		$ECBC=GUIGetMsg()
		Switch $ECBC
			Case $GUI_EVENT_CLOSE,$Cancel
				$suma=$contenido
				ExitLoop
			Case $Apply
				$suma=""
				For $A=1 to $b
					if _GUICtrlListView_GetItemChecked($hListView,$A-1) Then
						$suma=$suma&$sep&_GUICtrlListView_GetItemText($hListView,$A-1,0)
					endif
				next
				$suma=StringMid($suma,2,9999)
				ExitLoop
			Case -8,$iListView	;Grid event
				$tmp112=_ListViewCheckValidate($hListView,0, $modo)
			Case 0,-11
			Case else
		EndSwitch
		Sleep(4)
   WEnd
   GUIDelete($hECB)

   Return $suma
EndFunc

func _ListViewCheckValidate($Listview, $columna, $maximo)

	Local $total,$ch
	$total=_GUICtrlListView_GetItemCount($Listview)
	For $A=1 to $total
		$ch=$ch+_GUICtrlListView_getItemChecked($Listview, $A-1)
	next
	if $ch<=$maximo then return $ch
	For $A=1 to $total
		_GUICtrlListView_SetItemChecked($Listview, $A-1,false)
	next
	GUISetState()
	return 0
endfunc

Func Multiplechoice($titulo,$DB,$clave,$checks)

	Local $Apply ,$Cancel
	Local $suma=number($checks)
	Local $Info
	Local $A,$B
	Local $devo
	Local $size

	Local Const $hMCGUI = GUICreate($titulo, 300, 300, -1, -1, BitOR( $WS_CAPTION,$WS_CLIPCHILDREN,$DS_MODALFRAME,$WS_DLGFRAME),$WS_EX_TOPMOST)
    Local $iListView = GUICtrlCreateListView("", 0, 0, 300, 250,$LVS_NOCOLUMNHEADER)
    Local Const $hListView = GUICtrlGetHandle($iListView)
    _GUICtrlListView_SetExtendedListViewStyle($hListView, BitOR($LVS_EX_FULLROWSELECT, $LVS_EX_CHECKBOXES))
	GUICtrlSetResizing(-1, $GUI_DOCKBORDERS)
	GUICtrlSetResizing(-1, $GUI_DOCKRIGHT + $GUI_DOCKSIZE + $GUI_DOCKBOTTOM)
	$Apply = GuiCtrlCreateButton("Apply", 40, 260, 100, 30)
    $Cancel = GuiCtrlCreateButton("Cancel", 160, 260, 100, 30)
	GUISetState(@SW_SHOWNORMAL, $hMCGUI)
	$devo=dbprep4($clave,$Info)
	$b=UBound($Info,1)
	if $b=0 then return -1
	$size =ControlGetPos("","",$hListView)
	_GUICtrlListView_InsertColumn($hListView, $A, "",$size[2]-20)
	For $A = 1 To $b-1
		_GUICtrlListView_AddItem($hListView, $info[$A][1], $A)
		if bitand(number($info[$A][2]),number($checks))>0 then
			_GUICtrlListView_SetItemChecked($hListView, $A-1,True)
		EndIf
	Next
	While 1
		Switch GUIGetMsg()
			Case $GUI_EVENT_CLOSE,$Cancel
				$suma=number($checks)
				ExitLoop
			Case $Apply
				$suma=0
				For $A=1 to $b-1
					if _GUICtrlListView_GetItemChecked($hListView,$A-1) Then
						$suma=$suma+number($info[$A][2])
					endif
				next
			ExitLoop
		EndSwitch
	WEnd
	GUIDelete($hMCGUI)
	Return $suma
EndFunc

#endregion

#region funciones de string
Func _String2ListView($ListView,$string,$sep,$opcionales)
	Local $Split,$i,$ret=0
	If StringInStr($string,$sep)=0 Then
			if Stringlen($string)>0 Then
				_GUICtrlListView_AddItem($ListView,$string)
				$ret=1
			EndIf
		Else
			$Split = StringSplit($string,$sep)
			For $i = 1 To $Split[0] Step 1
				_GUICtrlListView_AddItem($ListView, $Split[$i])
			Next
			$ret=$Split[0]
	EndIf
	return $ret
EndFunc

Func  _ListView2String($ListView,$sep)

	Local $opciones,$LVItemText,$i,$count
	$Count = _GUICtrlListView_GetItemCount($ListView)
	For $i = 1 To $Count Step 1
		$LVItemText = _GUICtrlListView_GetItemText($ListView, $i - 1)
		If $i>1 Then $opciones &=  $sep
		$opciones &= $LVItemText
	Next
	return $opciones
EndFunc

Func _StringQuitDuplicates($StringMain,$StringReference,$Sep)

	local $ret,$Split,$compara
	$Split=StringSplit($StringMain,$sep)
	$compara=$Sep&$StringReference&$Sep
	for $i=1 to $Split[0]
		if  StringInStr($compara,$Sep&$Split[$i]&$Sep,0)=0 then ;  not found
			if StringLen($ret)>0 then $ret&=$sep
			$ret&=$Split[$i]
		EndIf
	Next
	return $ret
EndFunc

Func Pi2Cm($cadena)

	Const $cm=",",$pi="|"
	return StringReplace($cadena,$pi,$cm)
EndFunc

Func Pi2st($cadena)

	Local $cc=0

	Local $ret=Pi2Cm($cadena)
	$cc=StringInStr($ret,",")
	if $cc>0 then $ret="bitor("&$ret&")"
	return $ret
EndFunc

Func _addCondition(ByRef $var,$id)

   const $evt="$msg"
   const $opl=" OR "
   const $eq=" = "
   if StringLen($var)>0 then $var=$var&$opl
   $var=$var&$evt&$eq&"$"&$id
endfunc

Func _addVarDec(ByRef $var,$new)

	const $opl=" OR "
	const $cm=" , "
	$var=$var&(StringLen($var)=0?"Local ":$cm)
	$var=$var&$new
endfunc

Func only_name($filename,$mode=4)
	Mensaje_("only_name(",$filename,",",$mode,") entrada)")
	Local $tmp,$resul="",$junk
    $tmp=_PathSplit($filename,$junk,$junk,$junk,$junk)
	for $i=1 to 4
		if bitand($mode,2^($i-1))>0 then $resul=$resul&$tmp[$i]
	Next
	Mensaje_("only_name(",$filename,",",$mode,") Salida==>",$resul)
	return $resul
EndFunc

Func mat_search(byref $matriz,$column,$valor)
	Local $ret
	$ret=_ArraySearch($matriz,$valor,0,0,0,0,1,$column)
	$ret=(_ArraySearch($matriz,$valor,0,0,0,0,1,$column)=-1)? False : True
	return $ret
EndFunc
#EndRegion

#region ------------------------------- Creacion de Ventanas ---------------------------------

Func __Create_Toolbar($pid)
	Local $toolbar = GuiCreate("Choose Control Type", 150, 450, 10, @DesktopHeight/2-175, 0x00C00000, -1, $pid)
	$tip = StringSplit("Cursor|Tab|Group|Button|Checkbox|Radio|Edit|Input|Label|UpDown|List|Combo|Date|TreeView|Progress|Avi|Icon|Pic|Menu|ContextMenu|Slider|Color_Chooser|Free|Free", "|")
	Local $notYetImplemented = ",2,7,10,11,14,15,16,17,19,20,21,21,23,24,25,"  ;cursor is index 1
	Local $i
	For $row = 0 to 7
	   For $col = 0 to 2
		  $i = 3*$row + $col + 1
		  $type[$i] = GUICtrlCreateRadio("", $col*50, $row*50, 50, 50, 0x1040)
		  GUICtrlSetTip(-1, $tip[$i])

		  If Not StringInStr($notYetImplemented, "," &  $i & ",") Then GUICtrlSetImage(-1, @ScriptDir & "\IconSet.dll", $i+1)

		  ConsoleWrite("ICON:"&$row&":"&$col&":"&$i + 1&@CRLF)
		  If StringInStr($notYetImplemented, "," &  $i & ",") Then GuiCtrlSetState($type[$i], $GUI_DISABLE)
	  Next
	Next
	GuiCtrlSetState($type[1], $GUI_CHECKED)
	Return $toolbar
EndFunc

Func __Create_host($pid)

	const $prg="PaletteCad XML Builder"
	Local $hhost=GUICreate($prg,1000,55,0,0,-1,-1,$pid)
	GUISetBkColor(0xC3C4C6,$hhost)

	_SetMenuSelectBkColor(0xC0D010)
	_SetMenuSelectRectColor(0xE5AE78)
	_SetMenuBkColor(0xF0E5E0)
	_SetMenuIconBkColor(0xF0E5E0)
	_SetMenuIconBkGrdColor(0xE0E0E5)
	_SetMenuSelectTextColor(0x000000)
	_SetMenuTextColor(0x050540)
	local $mc=Modern_menu_creacion($hhost,-1,"load_menu")
    local $hh=ToolBar_creacion("load_toolbar",0,0,25,25)

	return $hhost
EndFunc

Func Modern_menu_creacion($pid,$hdb,$sql)

   const $cm=","
   const $cd=chr(34)
   local $m=0
   local $i
   local $menues
   local $menu_id=0
   local $item_id
   local $j=0
   local $consul
   Local $xant=-1
   local $modo=Opt("GUIOnEventMode")

	$j=dbprep4($sql, $menues)
    if $j=-1 then return -1

	for $i=1 to $db_filas
		if $menues[$i][2]<>$xant Then
			$menu_id=0
			$xant=$menues[$i][2]
		endif
		if $menues[$i][11]=0 and $modo=0 then
			$item_id=GUICtrlCreateDummy()
			$j=Assign($menues[$i][4],$item_id,4)
			ContinueLoop
		EndIf
		if $menues[$i][3]=0 Then
			$icono_metodo=tipo($menues[$i][9])
			$icon_file=icon_file($icono_metodo,$menues[$i][9])
			$icon_id=icon_id($icono_metodo,$menues[$i][9])
			$menu_id=_GUICtrlCreateODMenu($menues[$i][1], -1, $Icon_File, $Icon_ID)
			$m=$m+1
		else
			if $menu_id=0 then
				$item_id=GUICtrlCreateDummy()
				$j=Assign($menues[$i][4],$item_id,4)
				ContinueLoop
			EndIf
			$icono_metodo=tipo($menues[$i][9])
			$icon_file=icon_file($icono_metodo,$menues[$i][9])
			$icon_id=icon_id($icono_metodo,$menues[$i][9])
			$item_id=_GUICtrlCreateODMenuItem($menues[$i][1],$menu_id , $Icon_File, $Icon_ID,$menues[$i][7])
			if $menues[$i][8]=1 then  GUICtrlSetState($item_id, $GUI_CHECKED)
			if $menues[$i][4]<>"" then
				#Au3Stripper_Off
				if $modo=0 then
						$j=Assign($menues[$i][4],$item_id,4)
					else
						$j=GUICtrlSetOnEvent($item_id,$menues[$i][4])
				endif
				#Au3Stripper_On
			endif
			if $menues[$i][10]<>"" then GUICtrlSetTip($item_id,$menues[$i][10])
			$m=$m+1
		endif
	next
	return $m
EndFunc

Func ToolBar_creacion($definiciones,$x,$y,$width,$height)

	const $dx=5
	const $dy=5

	local $tb
	Local $ne
	local $ht
	Local $m=0
	Local $j=-1
	Local $x1,$y1
	$ne=dbprep4($definiciones,$tb)
	if $ne<1 then return $ne
	for $i=1 to $db_filas
		if $tb[$i][9]=1 then
				$ht = GUICtrlCreateButton("0",($tb[$i][2]-1)*($width+$dx)+$dx, ($tb[$i][3]-1)*($height+$dy-1)+$dy, $width,$height, 0x1040,-1)
				if $tb[$i][8]<>"" then GUICtrlSetTip(-1, $tb[$i][8])
				GUICtrlSetImage(-1, @ScriptDir & "\IconSet.dll", $tb[$i][7] )
				if $tb[$i][6]=1 then
					Toolbar_Set(-1,1)
				endif
				$m=$m+1
			Else
				$ht = GUICtrlCreateDummy()
		EndIf
		$j=Assign($tb[$i][4],$ht,4)
	Next
	return $m
EndFunc

Func Toolbar_Get($ctrl)
	return number(GuiCtrlRead($ctrl))
EndFunc

Func Toolbar_Set($ctrl,$estado=-1)
	local $ns=$estado
	if $ns=-1 then $ns=1-Toolbar_Get($ctrl)
	GUICtrlSetData($ctrl,String($ns))
	GUICtrlSetStyle($ctrl,0x1040,($ns=1)?$WS_EX_CLIENTEDGE:0)
	return number($ns)
EndFunc

#EndRegion

#Region ------------------------------ Miscellaneous Functions ---------------------------------------------------

Func CheckCommandline()
	If $cmdchk = "" Then
		$cmdchk = 1
		If $cmdln = 1 Then
			If StringRight($CmdLine[1], 4) = ".agd" Then
				$AgdInfile = FileGetLongName($CmdLine[1])
				_LoadGuiDefinition()
			EndIf
		EndIf
	EndIf
EndFunc

Func GetScriptTitle()

	If $AgdInfile = "" Then
		$gdtitle = WinGetTitle("classname=SciTEWindow", "")
	Else
		$gdtitle = $AgdOutFile
	EndIf
	If $gdtitle <> "" Then
		$gdvar = StringSplit($gdtitle, "\")
		$lfld = StringLeft($gdtitle, StringInStr($gdtitle, $gdvar[$gdvar[0]]) - 2)
		$gdtitle = $gdvar[$gdvar[0]]
		If $AgdInfile = "" Then
			$gdvar = StringInStr($gdtitle, ".au3")
		Else
			$gdvar = StringInStr($gdtitle, ".agd")
		EndIf
		$gdtitle = StringLeft($gdtitle, $gdvar - 1)
	Else
		$gdtitle = "MyGUI"
	EndIf
	$mygui = $gdtitle & ".au3"
	$gdtitle = '"' & $gdtitle & '"'
EndFunc

Func iif($condicion,$verdad,$falso)

   if execute($condicion) Then
		return $verdad
	  Else
		return $falso
	 EndIf
Endfunc

func tipo($entrada)
	local $ret
	local $tmp
	$tmp=number($entrada)
	if $tmp<>0 then return "Int32"
	$tmp=String($entrada)
	if StringLen($tmp)>0 then return "String"
	$tmp=$entrada
	if string($tmp)>0 then return "Binary"
	return Null
EndFunc

Func menu_mudo()
	mensaje_("menu_mudo()")
EndFunc

Func _clickType($ref)

   $lock = 1
   WinActivate($main)
   GUICtrlSetState($background, 64)
   $CurrentType = $tip[$ref - 15]
   $Mode = $INITDRAW
   $lock = 0
	WinActivate($main)
EndFunc

Func _mouseSnapPos()
	Local $gridTicks = 10
	Local $tmp = GUIGetCursorInfo($main)
	If $mode_SnapGrid Then
		$tmp[0] = $gridTicks * Int( $tmp[0] / $gridTicks - 0.5) + $gridTicks
		$tmp[1] = $gridTicks * Int( $tmp[1] / $gridTicks - 0.5) + $gridTicks
	EndIf
	Return $tmp
EndFunc

Func _mouseClientMove($x, $y)
	Global $client = WinGetClientSize($main)
	Global $window = WinGetPos($main)
	Global $border = ($window[2] - $client[0]) / 2
	Global $titlebar = $window[3] - 2 * $border - $client[1]
	Local $mouseCoordModeBAK = Opt("MouseCoordMode", 0)
	Local $mouseCoord = MouseGetPos()
	Local $border = ($window[2] - $client[0]) / 2
	Local $left = $x + $window[2] - $client[0] - $border
	Local $top  = $y + $window[3] - $client[1] - $border
	MouseMove($left, $top, 0)
	Opt("MouseCoordMode", $mouseCoordModeBAK)
EndFunc

Func _repaintWindow()
	Local $p = WinGetPos($main)
	SplashTextOn("", "", $p[2], $p[3], $p[0], $p[1], 1)
	SplashOff()
EndFunc

func icon_file($tipo,$entrada)
	const $icons="iconset.dll"; nombre de Dll con los iconos
	local $retro			 ; devolucion funcion

	switch $tipo
		case "Binary"
			$retro=null
		case "Int32"
			$retro=$icons
		case "String"
			$retro=$entrada
		Case Else
			$retro=Null
	EndSwitch
	return $retro
EndFunc

func icon_id($tipo,$entrada)
	local $retro

	switch $tipo
		case "Binary"
			$retro=null
		case "Int32"
			$retro=$entrada
		case "String"
			$retro=Null
		Case Else
			$retro=Null
	EndSwitch
	return $retro
EndFunc

Func _DebugPrint($s_Text, $sLine = @ScriptLineNumber)
    mensaje_( "_DebugPrint","-->Line(" & StringFormat("%04d", $sLine) & "):" & @TAB & $s_Text & "+=============================================")
EndFunc   ;==>_DebugPrint

func string2parameters($origen, $sepa, byref $destino)
    Local $i
	$destino=StringSplit($origen,$sepa,0)
	$destino[0]="CallArgArray"
	for $i=1 to ubound($destino)-1
		$destino[$i]=repvar($destino[$i])
	next
	return $i
endfunc

func execstring($cadena,$sep)
    Mensaje_("execstring("&$cadena&","&$sep&")"," Valores Recibidos")
	local $ret=0,$sexc
    local $orden=StringSplit($cadena,$sep,1)
	for $i=1 to $orden[0]
		$sexc=repvar($orden[$i])
		ConsoleWrite("!!"&$sexc&@CRLF)
		If StringInStr($sexc,"GuiCtrlCreatePic(,") Then
			$sexc=StringReplace($sexc,"GuiCtrlCreatePic(,",'GuiCtrlCreatePic("avi.bmp",')
		ElseIf StringInStr($sexc,'GuiCtrlCreateDate("') And StringInStr($sexc,',1,1,-1,-1)') Then
			$sexc=StringReplace($sexc,",1,1,-1,-1)",',190,20,0x00,-1)')
		EndIf
		Mensaje_("execstring()","sentencia a ejecutar:",$orden,"["&$i&"]=",$sexc)
		$ret=execute($sexc)
		$pusch = $ret
		Mensaje_("execstring(["&$i&"]","Resultado=",$ret," error=",@error)
	next
	return $ret
endfunc

Func get_class_id($class_name)

	if IsDeclared("$_tmp1")=0 then Global $_tmp1
	$_tmp1=$class_name
	return dbprep2("get_class_id")
EndFunc

func prueba($par1,$par2,$par3,$par4)

	mensaje_("Dentro de prueba("&$par1&"|"&$par2&"|"&$par3&")")
EndFunc

Func rgb2Luminancia($color)

	local $r,$g,$b,$ma,$mi,$ret

    $r=bitand($color,0xFF0000)/65536
	$g=bitand($color,0x00FF00)/256
	$b=bitand($color,0x00FF)

    $mi=__min($r,$g,$b)
	$ma=__max($r,$g,$b)
	$ret=int(($mi/255+$ma/255)/2*240)
	return $ret
EndFunc

Func __Max($iNum1, $iNum2,$iNum3="")

	Local $imax
	If Not IsNumber($iNum1) Then Return SetError(1, 0, 0)
	If Not IsNumber($iNum2) Then Return SetError(2, 0, 0)
	$imax=($iNum1 > $iNum2) ? $iNum1 : $iNum2
	If Not IsNumber($iNum3) then return $imax
	Return ($imax > $iNum3) ? $imax : $iNum3
EndFunc   ;==>_Max

Func __Min($iNum1, $iNum2,$iNum3="")

	Local $imin
	If Not IsNumber($iNum1) Then Return SetError(1, 0, 0)
	If Not IsNumber($iNum2) Then Return SetError(2, 0, 0)
	$imin=($iNum1 > $iNum2) ? $iNum2 : $iNum1
	Return ($imin > $iNum3) ? $iNum3 : $imin
EndFunc   ;==>_Min

Func Load_ini()
	return IniRead(@ScriptDir & "\Gbuild.ini", "Files", "Db", "")
EndFunc

Func Nulo()
   return Null
EndFunc

#EndRegion