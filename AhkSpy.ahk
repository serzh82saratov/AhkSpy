/*
©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©
©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©© AhkSpy ©©
©©©©©©©©©©©     ©   ©©©©©©   ©©©©©©©©        ©©©©©©©©©©©©©©©©©©©©©©©
©©©©©©©©©©      ©   ©©©©©©   ©©©©©©©    ©©    ©©©©©©©©©©©©©©©©©©©©©©
©©©©©©©©©       ©   ©©©©©©   ©©©©©©©     ©©©©©©©©©©©©©©©©©©©©©©©©©©©
©©©©©©©©    ©   ©       ©©   ©©©  ©©©       ©©©       ©©   ©©   ©©©©
©©©©©©©    ©©   ©   ©    ©   ©    ©©©©©©      ©   ©    ©   ©©   ©©©©
©©©©©©    ©©©   ©   ©©   ©       ©©©©©©©©©    ©   ©©   ©   ©©   ©©©©
©©©©©           ©   ©©   ©   ©    ©©    ©©    ©   ©    ©    ©   ©©©©
©©©©    ©©©©©   ©   ©©   ©   ©©©  ©©©        ©©       ©©©       ©©©©
©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©   ©©©©©©©©©©©   ©©©©
©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©   ©©©©©©   ©    ©©©©
©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©   ©©©©©©©      ©©©©©
©© AhkSpy ©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©
©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©©

    Автор - serzh82saratov
    E-Mail: serzh82saratov@mail.ru

    Спасибо Malcev и wisgest за помощь в создании HTML интерфейса
    Также благодарность Malcev, teadrinker, YMP, Irbis за их решения
    Описание - http://forum.script-coding.com/viewtopic.php?pid=72459#p72459
    Обсуждение - http://forum.script-coding.com/viewtopic.php?pid=72244#p72244
    Обсуждение на офф. форуме- https://autohotkey.com/boards/viewtopic.php?f=6&t=52872
    Актуальный исходник - https://raw.githubusercontent.com/serzh82saratov/AhkSpy/master/AhkSpy.ahk
*/

Global AhkSpyVersion := 3.87

	; _________________________________________________ Header _________________________________________________

p1 = %1%
If (p1 = "Zoom")
	GoTo ShowZoom

SingleInstance()
#NoEnv
#UseHook
SetBatchLines, -1
ListLines, Off
#KeyHistory 0
DetectHiddenWindows, On
CoordMode, Pixel
CoordMode, Menu

Gosub, CheckAhkVersion
Menu, Tray, UseErrorLevel
Menu, Tray, Icon, Shell32.dll, % A_OSVersion = "WIN_XP" ? 222 : 278

Global Path_User := A_AppData "\AhkSpy"
If !InStr(FileExist(Path_User), "D")
	FileCreateDir, % Path_User

Global MemoryFontSize := IniRead("MemoryFontSize", 0)
, FontSize := MemoryFontSize ? IniRead("FontSize", "15") : 15			;  Размер шрифта
, FontFamily :=  "Arial"												;  Шрифт - Times New Roman | Georgia | Myriad Pro | Arial
, ColorFont := "000000"													;  Цвет шрифта
, ColorBg := ColorBgOriginal := "FFFFFF"								;  Цвет фона          "F0F0F0" E4E4E4     F8F8F8
, ColorBgPaused := "FAFAFA"												;  Цвет фона при паузе     F0F0F0
, ColorSelMouseHover := "F9D886"										;  Цвет фона элемента при наведении мыши     96C3DC F9D886 8FC5FC AEC7E1
, ColorSelButton := "96C3DC"											;  Цвет фона при нажатии на кнопки
, ColorSelAnchor := "FFFF80"											;  Цвет фона заголовка для якоря
, HighLightBckg := "FFE0E0"												;  Цвет фона некоторых абзацев
, ColorDelimiter := "E14B30"											;  Цвет шрифта разделителя заголовков и параметров
, ColorTitle := "27419B"												;  Цвет шрифта заголовка
, ColorParam := "189200"												;  Цвет шрифта параметров
, HeigtButton := 32														;  Высота кнопок
, RangeTimer := 100														;  Период опроса данных, увеличьте на слабом ПК
  HeightStart := 530													;  Высота окна при старте
  wKey := 142															;  Ширина кнопок
  wColor := wKey//2														;  Ширина цветного фрагмента

Global ThisMode := IniRead("StartMode", "Control"), LastModeSave := (ThisMode = "LastMode"), ThisMode := ThisMode = "LastMode" ? IniRead("LastMode", "Control") : ThisMode
, ActiveNoPause := IniRead("ActiveNoPause", 0), MemoryPos := IniRead("MemoryPos", 0), MemorySize := IniRead("MemorySize", 0)
, MemoryZoomSize := IniRead("MemoryZoomSize", 0), MemoryStateZoom := IniRead("MemoryStateZoom", 0), StateLight := IniRead("StateLight", 1)
, StateLightAcc := IniRead("StateLightAcc", 1), SendCode := IniRead("SendCode", "vk"), StateLightMarker := IniRead("StateLightMarker", 1)
, StateUpdate := IniRead("StateUpdate", 0), SendMode := IniRead("SendMode", "send"), SendModeStr := Format("{:L}", SendMode), MemoryAnchor := IniRead("MemoryAnchor", 1)
, StateAllwaysSpot := IniRead("AllwaysSpot", 0), w_ShowStyles := IniRead("w_ShowStyles", 0), c_ShowStyles := IniRead("c_ShowStyles", 0), ViewStrPos := IniRead("ViewStrPos", 0)
, WordWrap := IniRead("WordWrap", 0), PreMaxHeightStr := IniRead("MaxHeightOverFlow", "1 / 3"), UseUIA := IniRead("UseUIA", 0), OnlyShiftTab := IniRead("OnlyShiftTab", 0)
, MoveTitles := IniRead("MoveTitles", 1), DetectHiddenText := IniRead("DetectHiddenText", "on"), MenuIdView := IniRead("MenuIdView", 0)
, DynamicControlPath := IniRead("DynamicControlPath", 0), DynamicAccPath := IniRead("DynamicAccPath", 0)
, UpdRegister := IniRead("UpdRegister2", 0), UpdRegisterLink := "https://u.to/zeONFA"

, ScrollPos := {}, AccCoord := [], oOther := {}, oFind := {}, Edits := [], oMS := {}, oMenu := {}, oPubObj := {}

, ClipAdd_Before := 0, ClipAdd_Delimiter := "`r`n"
, HTML_Win, HTML_Control, HTML_Hotkey, rmCtrlX, rmCtrlY, widthTB, FullScreenMode, hColorProgress, hFindAllText, MsgAhkSpyZoom, Sleep, oShowMarkers, oShowAccMarkers, oShowMarkersEx
, hGui, hTBGui, hActiveX, hFindGui, oDoc, ShowMarker, isFindView, isIE, isPaused, PreMaxHeight := MaxHeightStrToNum(), PreOverflowHide := !!PreMaxHeight, DecimalCode, GetVKCodeNameStr, GetSCCodeNameStr
, oDocEl, oPubObjGUID, oJScript, oBody, isConfirm, isAhkSpy := 1, TitleText, FreezeTitleText, TitleTextP1, oUIAInterface, Shift_Tab_Down, hButtonButton, hButtonControl, hButtonWindow
, TitleTextP2 := TitleTextP2_Reserved := "     ( Shift+Tab - Freeze | RButton - CopySelected | Pause - Pause )     v" AhkSpyVersion

#Include *i %A_AppData%\AhkSpy\IncludeSettings.ahk

Global _S1 := "<span>", _S2 := "</span>", _DB := "<span style='position: relative; margin-right: 1em;'></span>"
, _BT1 := "<span class='button' unselectable='on' oncontextmenu='return false' onmouseleave='OnButtonOut (this)' onmousedown='OnButtonDown (this)' "
	. "onmouseup='OnButtonUp (this)' onmouseover='OnButtonOver (this)' contenteditable='false' ", _BT2 := "</span>"
, _BP1 := "<span contenteditable='false' oncontextmenu='return false' class='BB'>" _BT1 "style='color: #" ColorParam "' name='pre' ", _BP2 := "</span></span>"

  ;	Решает проблему запуска ресайза кнопки когда выделен текст, но не получается установить свой курсор
; , _BP1 := "<span class='button' unselectable='on' oncontextmenu='return false' onmouseleave='OnButtonOut (this)' onmousedown='OnButtonDown (this)' "
	; . "onmouseup='OnButtonUp (this)' onmouseover='OnButtonOver (this)' contenteditable='false' style='color: #" ColorParam "' name='pre' ", _BP2 := "</span>"

, _BB1 := "<span contenteditable='false' oncontextmenu='return false' class='BB' style='height: 0px;'>" _BT1 " ", _BB2 := "</span></span>"
, _T1 := "<span class='box'><span class='line'><span class='hr'></span><span class='con'><span class='title' ", _T2 := "</span></span></span><br>"
, _T1P := " style='color: #" ColorParam "' "
, _T0 := "<span class='box'><span class='hr'></span></span>"
, _PRE1 := "<pre contenteditable='true'>", _PRE2 := "</pre>"
, _LPRE := "<pre contenteditable='true' class='lpre'"
, _DP := "  <span style='color: #" ColorDelimiter "'>&#9642</span>  "
, _StIf := "    <span style='color: #f0f0f0'>&#9642</span>    <span class='faded_color' name='MS:' style='color: #C0C0C0'>"
, _BR := "<p class='br'></p>", _DN := "`n"
, _INPHK := "<input onfocus='funchkinputevent (this, ""focus"")' onblur='funchkinputevent(this, ""blur"")' "

, _PreOverflowHideCSS := ".lpre {max-width: 99`%; max-height: " PreMaxHeight "px; overflow: auto; border: 1px solid #E2E2E2;}"
, _BodyWrapCSS := "body {word-wrap: break-word; overflow-x: hidden;} .lpre {overflow-x: hidden;}"

, _ButAccViewer := ExtraFile("AccViewer Source") ? _DB _BT1 " id='run_AccViewer'> run accviewer " _BT2 : ""
, _ButiWB2Learner := ExtraFile("iWB2 Learner") ? _DB _BT1 " id='run_iWB2Learner'> run iwb2 learner " _BT2 : ""
, _ButWindow_Detective := FileExist(Path_User "\Window Detective.lnk") ? _DB _BT1 " id='run_Window_Detective'> run window detective " _BT2 : ""

If UseUIA
	oUIAInterface := UIA_Interface()

BLGroup := ["Backlight allways","Backlight disable","Backlight hold shift button"]
oOther.anchor := {}, oOther.CurrentProcessId := DllCall("GetCurrentProcessId")

If MemoryAnchor
{
	If oOther.anchor["Win_text"] := IniRead("Win_Anchor")
		oOther.anchor["Win"] := 1
	If oOther.anchor["Control_text"] := IniRead("Control_Anchor")
		oOther.anchor["Control"] := 1
}
ObjRegisterActive(oPubObj, oPubObjGUID := CreateGUID())

FixIE()
SeDebugPrivilege()
OnExit, Exit

Gui, +AlwaysOnTop +HWNDhGui +ReSize -DPIScale
Gui, Color, %ColorBgPaused%
Gui, Add, ActiveX, Border voDoc HWNDhActiveX x0 y+0, HTMLFile

ComObjError(false)
LoadJScript()
oBody := oDoc.body
oDocEl := oDoc.documentElement 
oJScript := oDoc.Script
oJScript.WordWrap := WordWrap
oJScript.MoveTitles := MoveTitles
ComObjConnect(oDoc, Events)

OnMessage(0x133, "WM_CTLCOLOREDIT")
OnMessage(0x201, "WM_LBUTTONDOWN")
OnMessage(0x208, "WM_MBUTTONUP")
OnMessage(0xA1, "WM_NCLBUTTONDOWN")
OnMessage(0x7B, "WM_CONTEXTMENU")
OnMessage(0x6, "WM_ACTIVATE")
OnMessage(0x47, "WM_WINDOWPOSCHANGED")

OnMessage(MsgAhkSpyZoom := DllCall("RegisterWindowMessage", "Str", "MsgAhkSpyZoom"), "MsgZoom")
DllCall("PostMessage", "Ptr", A_ScriptHWND, "UInt", 0x50, "UInt", 0, "UInt", 0x409) ; eng layout

Gui, TB: +HWNDhTBGui -Caption -DPIScale +Parent%hGui% +E0x08000000 +0x40000000 -0x80000000
Gui, TB: Font, % " s" (A_ScreenDPI = 120 ? 8 : 10), Verdana
Gui, TB: Add, Button, x0 y0 h%HeigtButton% w%wKey% vBut1 gMode_Win hwndhButtonWindow, Window
Gui, TB: Add, Button, x+0 yp hp wp vBut2 gMode_Control hwndhButtonControl, Control
Gui, TB: Add, Progress, x+0 yp hp w%wColor% vColorProgress HWNDhColorProgress cWhite, 100
Gui, TB: Add, Button, x+0 yp hp w%wKey% vBut3 gMode_Hotkey hwndhButtonButton, Button
Gui, TB: Show, % "x0 y0 NA h" HeigtButton " w" widthTB := wKey*3+wColor

Gui, F: +HWNDhFindGui -Caption -DPIScale +Parent%hGui% +0x40000000 -0x80000000
Gui, F: Color, %ColorBgPaused%
Gui, F: Font, % " s" (A_ScreenDPI = 120 ? 10 : 12)
Gui, F: Add, Edit, x1 y0 w180 h26 gFindNew WantTab HWNDhFindEdit
SendMessage, 0x1501, 1, "Find to page",, ahk_id %hFindEdit%   ; EM_SETCUEBANNER
Gui, F: Add, UpDown, -16 Horz Range0-1 x+0 yp h26 w52 gFindNext vFindUpDown
GuiControl, F: Move, FindUpDown, h26 w52
Gui, F: Font, % (A_ScreenDPI = 120 ? "" : "s10")
Gui, F: Add, Text, x+10 yp+1 h24 c2F2F2F +0x201 gFindOption, % " case sensitive "
Gui, F: Add, Text, x+10 yp hp c2F2F2F +0x201 gFindOption, % " whole word "
Gui, F: Add, Text, x+3 yp hp +0x201 w52 vFindMatches HWNDhFindAllText
Gui, F: Add, Button, % "+0x300 +0xC00 y3 h20 w20 gFindHide x" widthTB - 21, X

	; _________________________________________________ Menu Create _________________________________________________

Menu, Sys, Add, % name := "Backlight allways", % oMenu.Sys[name] := "_Sys_Backlight"
Menu, Sys, Add, % name := "Backlight hold shift button", % oMenu.Sys[name] := "_Sys_Backlight"
Menu, Sys, Add, % name := "Backlight disable", % oMenu.Sys[name] := "_Sys_Backlight"
Menu, Sys, Check, % BLGroup[StateLight]
Menu, Sys, Add
Menu, Sys, Add, % name := "Window or control backlight", % oMenu.Sys[name] := "_Sys_WClight"
Menu, Sys, % StateLightMarker ? "Check" : "UnCheck", % name
Menu, Sys, Add, % name := "Acc object backlight", % oMenu.Sys[name] := "_Sys_Acclight"
Menu, Sys, % StateLightAcc ? "Check" : "UnCheck", % name
Menu, Sys, Add
Menu, Sys, Add, % name := "Spot together (low speed)", % oMenu.Sys[name] := "_Spot_Together"
Menu, Sys, % StateAllwaysSpot ? "Check" : "UnCheck", % name
Menu, Sys, Add, % name := "Work with the active window", % oMenu.Sys[name] := "_Active_No_Pause"
Menu, Sys, % ActiveNoPause ? "Check" : "UnCheck", % name
Menu, Sys, Add, % name := "Spot only Shift+Tab", % oMenu.Sys[name] := "_OnlyShiftTab"
Menu, Sys, % OnlyShiftTab ? "Check" : "UnCheck", % name

If !A_IsCompiled
{
	Menu, Sys, Add
	Menu, Sys, Add, % name := "Check updates", % oMenu.Sys[name] := "_CheckUpdate"
	Menu, Sys, % StateUpdate ? "Check" : "UnCheck", % name
	If StateUpdate
		SetTimer, UpdateAhkSpy, -1000
}
Else
	StateUpdate := 0

Menu, Sys, Add
Menu, Startmode, Add, % name := "Window", % oMenu.Startmode[name] := "_SelStartMode"
Menu, Startmode, Add, % name := "Control", % oMenu.Startmode[name] := "_SelStartMode"
Menu, Startmode, Add, % name := "Button", % oMenu.Startmode[name] := "_SelStartMode"
Menu, Startmode, Add
Menu, Startmode, Add, % name := "Last Mode", % oMenu.Startmode[name] := "_SelStartMode"

Menu, View, Add, % name := "Remember position", % oMenu.View[name] := "_MemoryPos"
Menu, View, % MemoryPos ? "Check" : "UnCheck", % name
Menu, View, Add, % name := "Remember size", % oMenu.View[name] := "_MemorySize"
Menu, View, % MemorySize ? "Check" : "UnCheck", % name
Menu, View, Add, % name := "Remember font size", % oMenu.View[name] := "_MemoryFontSize"
Menu, View, % MemoryFontSize ? "Check" : "UnCheck", % name
Menu, View, Add, % name := "Remember state zoom", % oMenu.View[name] := "_MemoryStateZoom"
Menu, View, % MemoryStateZoom ? "Check" : "UnCheck", % name
Menu, View, Add, % name := "Remember zoom size", % oMenu.View[name] := "_MemoryZoomSize"
Menu, View, % MemoryZoomSize ? "Check" : "UnCheck", % name
Menu, View, Add, % name := "Remember anchor", % oMenu.View[name] := "_MemoryAnchor"
Menu, View, % MemoryAnchor ? "Check" : "UnCheck", % name
Menu, View, Add
Menu, View, Add, % name := "Dynamic control path (low speed)", % oMenu.View[name] := "_DynamicControlPath"
Menu, View, % DynamicControlPath ? "Check" : "UnCheck", % name
Menu, View, Add, % name := "Dynamic accesible path (low speed)", % oMenu.View[name] := "_DynamicAccPath"
Menu, View, % DynamicAccPath ? "Check" : "UnCheck", % name
Menu, View, Add, % name := "Use UI Automation interface", % oMenu.View[name] := "_UseUIA"
Menu, View, % UseUIA ? "Check" : "UnCheck", % name
Menu, View, Add
Menu, View, Add, % name := "Moving titles", % oMenu.View[name] := "_MoveTitles"
Menu, View, % MoveTitles ? "Check" : "UnCheck", % name
Menu, View, Add, % name := "View position string for command", % oMenu.View[name] := "_ViewStrPos"
Menu, View, % ViewStrPos ? "Check" : "UnCheck", % name
Menu, View, Add, % name := "Word wrap", % oMenu.View[name] := "_WordWrap"
Menu, View, % WordWrap ? "Check" : "UnCheck", % name
Menu, Sys, Add, View settings, :View

Menu, Overflow, Add, % name := "Switch off", % oMenu.Overflow[name] := "_MenuOverflowLabel"
Menu, Overflow, Add, % name := "1 / 1", % oMenu.Overflow[name] := "_MenuOverflowLabel"
Menu, Overflow, Add, % name := "1 / 2", % oMenu.Overflow[name] := "_MenuOverflowLabel"
Menu, Overflow, Add, % name := "1 / 3", % oMenu.Overflow[name] := "_MenuOverflowLabel"
Menu, Overflow, Add, % name := "1 / 4", % oMenu.Overflow[name] := "_MenuOverflowLabel"
Menu, Overflow, Add, % name := "1 / 5", % oMenu.Overflow[name] := "_MenuOverflowLabel"
Menu, Overflow, Add, % name := "1 / 6", % oMenu.Overflow[name] := "_MenuOverflowLabel"
Menu, Overflow, Add, % name := "1 / 8", % oMenu.Overflow[name] := "_MenuOverflowLabel"
Menu, Overflow, Add, % name := "1 / 10", % oMenu.Overflow[name] := "_MenuOverflowLabel"
Menu, Overflow, Add, % name := "1 / 15", % oMenu.Overflow[name] := "_MenuOverflowLabel"
Menu, View, Add, Big text overflow hide, :Overflow

Menu, Sys, Add, Start mode, :Startmode
Menu, Startmode, Check, % {"Win":"Window","Control":"Control","Hotkey":"Button","LastMode":"Last Mode"}[IniRead("StartMode", "Control")]

Menu, Help, Add, % name := "Open script dir", % oMenu.Help[name] := "Help_OpenScriptDir"
Menu, Help, Add, % name := "Open user dir", % oMenu.Help[name] := "Help_OpenUserDir"
Menu, Help, Add
If FileExist(SubStr(A_AhkPath,1,InStr(A_AhkPath,"\",,0,1)) "AutoHotkey.chm")
	Menu, Help, Add, % name := "AutoHotKey help file", % oMenu.Help[name] := "LaunchHelp"
Menu, Help, Add, % name := "AutoHotKey official help online", % oMenu.Help[name] := "Sys_Help"
Menu, Help, Add, % name := "AutoHotKey russian help online", % oMenu.Help[name] := "Sys_Help"
Menu, Help, Add
Menu, Help, Add, % name := "About", % oMenu.Help[name] := "Sys_Help"
Menu, Help, Add, % name := "About english", % oMenu.Help[name] := "Sys_Help"
Menu, Sys, Add, Help, :Help

Menu, Script, Add, Reload, Reload
Menu, Script, Add, Exit, Exit
Menu, Sys, Add, Script, :Script

Menu, Sys, Add
Menu, Sys, Add, % name := "Pause", % oMenu.Sys[name] := "_PausedScript"
Menu, Sys, Add, % name := "Suspend hotkeys", % oMenu.Sys[name] := "_Suspend"
Menu, Sys, Add, % name := "Default size", % oMenu.Sys[name] := "DefaultSize"
Menu, Sys, Add, % name := "Full screen", % oMenu.Sys[name] := "FullScreenMode"
Menu, Sys, Add, % name := "Find to page", % oMenu.Sys[name] := "_FindView"

Menu, Overflow, Check, %PreMaxHeightStr%

Menu, Sys, Color, % ColorBgOriginal
Menu, Overflow, Color, % ColorBgOriginal

#Include *i %A_AppData%\AhkSpy\Include.ahk  ;	Для продолжения выполнения кода используйте GoTo IncludeLabel
IncludeLabel:

Gui, Show, % "NA " (MemoryPos ? " x" IniRead("MemoryPosX", "Center") " y" IniRead("MemoryPosY", "Center") : "")
. (MemorySize ? " h" IniRead("MemorySizeH", HeightStart) " w" IniRead("MemorySizeW", widthTB) : " h" HeightStart " w" widthTB)
Gui, % "+MinSize" widthTB "x" 313

If ThisMode = Hotkey
	Gui, Show
Gosub, Mode_%ThisMode%

Hotkey_Init("Write_HotkeyHTML", "MLRJ")

If (MemoryStateZoom && IniRead("ZoomShow", 0))
	AhkSpyZoomShow()

WinGetPos, WinX, WinY, WinWidth, WinHeight, ahk_id %hGui%
If !DllCall("WindowFromPoint", "Int64", WinX & 0xFFFFFFFF | WinY << 32)
&& !DllCall("WindowFromPoint", "Int64", (WinX + WinWidth) & 0xFFFFFFFF | (WinY) << 32)
&& !DllCall("WindowFromPoint", "Int64", (WinX + WinWidth) & 0xFFFFFFFF | (WinY + WinHeight) << 32)
&& !DllCall("WindowFromPoint", "Int64", (WinX) & 0xFFFFFFFF | (WinY + WinHeight) << 32)
	Gui, Show, NA xCenter yCenter
If !UpdRegister
	SetTimer, UpdRegister, -1000
Return

	; _________________________________________________ Hotkey`s _________________________________________________

#If isAhkSpy && Sleep != 1 && ActiveNoPause

+Tab:: Goto PausedScript

#If (isAhkSpy && Sleep != 1 && !isPaused && ThisMode != "Hotkey")

+Tab::
SpotProc:
SpotProc2:
	If (A_ThisHotkey != "")
		Shift_Tab_Down := 1
	(ThisMode = "Control" ? (Spot_Control() (StateAllwaysSpot ? Spot_Win() : 0) Write_Control()) : (Spot_Win() (StateAllwaysSpot ? Spot_Control() : 0) Write_Win()))
	If (!WinActive("ahk_id" hGui) && A_ThisLabel != "SpotProc2" && !OnlyShiftTab)
	{
		WinActivate ahk_id %hGui%
		GuiControl, 1:Focus, oDoc
	}
	Else
		ZoomMsg(3)
	KeyWait, Tab, T0.1
	Return

#Tab Up::
F8 Up:: ChangeMode()

#If isAhkSpy && (StateLight = 3 || Shift_Tab_Down)

~*RShift Up::
~*LShift Up:: 
ShiftUpHide:
	HideAllMarkers(), Shift_Tab_Down := 0, CheckHideMarker()
	Return

#If isAhkSpy && Sleep != 1

Break::
Pause::
PausedScript:
_PausedScript:
	If isConfirm
		Return
	isPaused := !isPaused
	Try SetTimer, Loop_%ThisMode%, % isPaused ? "Off" : "On"
	ZoomMsg(2, isPaused)
	ColorBg := isPaused ? ColorBgPaused : ColorBgOriginal
	oBody.style.backgroundColor := "#" ColorBg
	ChangeCSS("css_ColorBg", ".title, .button {background-color: #" ColorBg ";}")
	If (ThisMode = "Hotkey" && WinActive("ahk_id" hGui))
		Hotkey_Hook(!isPaused)
	If (isPaused && !WinActive("ahk_id" hGui))
		(ThisMode = "Control" ? Spot_Win() : ThisMode = "Win" ? Spot_Control() : 0)
	HideAllMarkers(), CheckHideMarker()
	Menu, Sys, % (isPaused ? "Check" : "UnCheck"), Pause
	isPaused ? TaskbarProgress(4, hGui, 100) : TaskbarProgress(0, hGui)
	TitleText := (TitleTextP1 := "AhkSpy - " ({"Win":"Window","Control":"Control","Hotkey":"Button"}[ThisMode]))
	. (TitleTextP2 := (isPaused ? "                Paused..." : TitleTextP2_Reserved))
	SendMessage, 0xC, 0, &TitleText, , ahk_id %hGui%
	PausedTitleText()
	Return

#If isAhkSpy && Sleep != 1 && WinActive("ahk_id" hGui)

^WheelUp::
^WheelDown::
	FontSize := InStr(A_ThisHotkey, "Up") ? ++FontSize : --FontSize
	FontSize := FontSize < 10 ? 10 : FontSize > 24 ? 24 : FontSize
	oBody.Style.fontSize := FontSize "px"
	TitleText("FontSize: " FontSize)
	If MemoryFontSize
		IniWrite(FontSize, "FontSize")
	Return

F1::
+WheelUp:: NextLink("-")

F2::
+WheelDown:: NextLink()

F3::
~!WheelUp:: WheelLeft

F4::
~!WheelDown:: WheelRight

F5:: Write_%ThisMode%()		;  Return original HTML

F6::
^vk46:: _FindView()											;  Ctrl+F

F7:: AnchorScroll()

F11:: FullScreenMode()

F12:: MouseGetPosScreen(x, y), ShowSys(x + 5, y + 5)

!Space:: SetTimer, ShowSys, -1

Esc::
	If isFindView
		FindHide()
	Else If FullScreenMode
		FullScreenMode()
	Else
		GoSub, Exit
	Return

+#Tab:: AhkSpyZoomShow()

#If isAhkSpy && Sleep != 1 && IsIEFocus() && (oDoc.selection.createRange().parentElement.isContentEditable)

~^+vk41:: oDoc.execCommand("SelectAll")							;  Ctrl+Shift+A

~^vk41:: oBody.createTextRange().select()						;  Ctrl+A

#If isAhkSpy && Sleep != 1 && IsIEFocus()

^vk5A:: oDoc.execCommand("Undo")							;  Ctrl+Z

^vk59:: oDoc.execCommand("Redo")							;  Ctrl+Y

^vk43:: GetSelected(CopyText) && ((Clipboard := CopyText), ToolTip("copy", 300))		;  Ctrl+C

^vk56:: ClipPaste()																		;  Ctrl+V

^vk58:: CutSelection()								;  Ctrl+X

Del:: DeleteSelection()							;  Delete

Tab:: PasteStrSelection("    ")							;  &emsp	"&#x9;"  PasteStrSelection("&#x9;")

Enter:: PasteHTMLSelection("<br>")

#If isAhkSpy && Sleep != 1 && ThisMode != "Hotkey" && (IsIEFocus() || MS_IsSelection())

#RButton:: ClipPaste()

#If isAhkSpy && Sleep != 1 && ThisMode != "Hotkey" && (IsIEFocus() || MS_IsSelection()) && IsTextArea() && GetSelected(CopyText)

RButton::
^RButton::
	If (A_ThisHotkey = "^RButton")
		CopyText := CopyCommaParam(CopyText)
	Clipboard := CopyText
	ToolTip("copy", 300)
	Return

+RButton:: ClipAdd(CopyText, 1)
^+RButton:: ClipAdd(CopyCommaParam(CopyText), 1)

#If isAhkSpy && Sleep != 1 && ThisMode = "Hotkey" && (IsIEFocus() || MS_IsSelection()) && IsTextArea() && GetSelected(CopyText) ;	Mode = Hotkey

RButton::
	KeyWait, RButton, T0.3
	If ErrorLevel
		ClipAdd(CopyText, 1)
	Else
		Clipboard := CopyText, ToolTip("copy", 300)
	Return

#If (isAhkSpy && Sleep != 1 && !isPaused && ThisMode != "Hotkey")

+#Up::MouseStep(0, -1)
+#Down::MouseStep(0, 1)
+#Left::MouseStep(-1, 0)
+#Right::MouseStep(1, 0)
^+#Up::MouseStep(0, -10)
^+#Down::MouseStep(0, 10)
^+#Left::MouseStep(-10, 0)
^+#Right::MouseStep(10, 0)

#If oJScript.ButtonOver

+LButton::
	obj := Func("ButtonClick").Bind(oJScript.ButtonOver)
	SetTimer, % obj, -10
	Return

#If !WinActive("ahk_id" hGui) && IsAhkSpyUnderMouse(hc)

+LButton::
	If (hc = hButtonButton)
		SetTimer, Mode_Hotkey, -1
	Else If (hc = hButtonControl)
		SetTimer, Mode_Control, -1
	Else If (hc = hButtonWindow)
		SetTimer, Mode_Win, -1
	Return

#If

IsAhkSpyUnderMouse(Byref hc) {
	MouseGetPos, , , hw, hc, 2
	Return (hw = hGui)
}
	; _________________________________________________ Mode_Win _________________________________________________

Mode_Win:
	If A_GuiControl
		GuiControl, 1:Focus, oDoc
	ZoomMsg(10, 0)
	oBody.createTextRange().execCommand("RemoveFormat")
	GuiControl, TB: -0x0001, But1
	If ThisMode = Win
		oDocEl.scrollLeft := 0
	If (ThisMode = "Hotkey")
		Hotkey_Hook(0)
	Try SetTimer, Loop_%ThisMode%, Off
	ScrollPos[ThisMode,1] := oDocEl.scrollLeft, ScrollPos[ThisMode,2] := oDocEl.scrollTop
	If ThisMode != Win
		HTML_%ThisMode% := oBody.innerHTML
	ThisMode := "Win"
	If (HTML_Win = "")
		Spot_Win(1)
	Write_Win(), oDocEl.scrollLeft := ScrollPos[ThisMode,1]
	If !oOther.anchor[ThisMode]
		oDocEl.scrollTop := ScrollPos[ThisMode,2]
	TitleText := (TitleTextP1 := "AhkSpy - Window") . TitleTextP2
	SendMessage, 0xC, 0, &TitleText, , ahk_id %hGui%
	If isFindView
		FindNewText()

Loop_Win:
	If ((WinActive("ahk_id" hGui) && !ActiveNoPause) || Sleep = 1)
		GoTo Repeat_Loop_Win
	If !OnlyShiftTab && Spot_Win()
		Write_Win(), StateAllwaysSpot ? Spot_Control() : 0
Repeat_Loop_Win:
	If (!isPaused && ThisMode = "Win" && !OnlyShiftTab)
		SetTimer, Loop_Win, -%RangeTimer%
	Return

Spot_Win(NotHTML = 0) {
	Static PrWinPID, ComLine, ProcessBitSize, IsAdmin, WinProcessPath, WinProcessName
	If NotHTML
		GoTo HTML_Win
	MouseGetPos, , , WinID, hChild, 3

	If (WinID = hGui || WinID = oOther.hZoom || WinID = oOther.hZoomLW)
		Return HideAllMarkers()

	WinGetTitle, WinTitle, ahk_id %WinID%
	WinTitle := TransformHTML(WinTitle)
	WinGetPos, WinX, WinY, WinWidth, WinHeight, ahk_id %WinID%
	WinX2 := WinX + WinWidth - 1, WinY2 := WinY + WinHeight - 1
	WinGetClass, WinClass, ahk_id %WinID%
	oOther.WinClass := WinClass
	WinGet, WinPID, PID, ahk_id %WinID%
	If (WinPID != PrWinPID) {
		GetCommandLineProc(WinPID, ComLine, ProcessBitSize, IsAdmin)
		ComLine := TransformHTML(ComLine), PrWinPID := WinPID
		WinGet, WinProcessPath, ProcessPath, ahk_id %WinID%
		Loop, %WinProcessPath%
			WinProcessPath = %A_LoopFileLongPath%
		SplitPath, WinProcessPath, WinProcessName
	}
	If (WinClass ~= "(Cabinet|Explore)WClass")
		CLSID := GetCLSIDExplorer(WinID)
	WinGet, WinCountProcess, Count, ahk_pid %WinPID%
	WinGet, WinStyle, Style, ahk_id %WinID%
	WinGet, WinExStyle, ExStyle, ahk_id %WinID% 
	{
		WinGet, WinTransparent, Transparent, ahk_id %WinID%
		If WinTransparent !=
			TransparentStr := _BP1 "id='set_button_Transparent'>Transparent:</span>" _BP2 "  <span id='get_win_Transparent' name='MS:'>"  WinTransparent "</span>"
	
		WinGet, WinTransColor, TransColor, ahk_id %WinID%
		If WinTransColor !=
			TransColorStr := _BP1 "id='set_button_TransColor'>TransColor:</span>" _BP2 "  <span id='get_win_TransColor' name='MS:'>"  WinTransColor "</span>"
	
		OwnedId := DllCall("GetWindow", "Ptr", WinID, UInt, 4, "Ptr")
		If OwnedId
			OwnedIdStr := "<span class='param'>Owned Id:</span> <span name='MS:'>" Format("0x{:x}", OwnedId) "</span>"
			
		EX1Str := Add_DP(1, OwnedIdStr, TransparentStr, TransColorStr)
	} 
	WinGet, CountControl, ControlListHwnd, ahk_id %WinID%
	RegExReplace(CountControl, "m`a)$", "", CountControl)
	GetClientPos(WinID, caX, caY, caW, caH)
	caWinRight := WinWidth - caW - caX , caWinBottom := WinHeight - caH - caY
	loop 1000
	{
		StatusBarGetText, SBFieldText, %A_Index%, ahk_id %WinID%
		if ErrorLevel
			Break
		(!sb_fields && sb_fields := []), sb_fields[A_Index] := SBFieldText
	}
	if sb_fields.maxindex()
	{
		while (sb_max := sb_fields.maxindex()) && (sb_fields[sb_max] = "")
			sb_fields.Delete(sb_max)
		for k, v in sb_fields
			SBText .= "<span class='param'>(" k "):</span> <span name='MS:' id='sb_field_" A_Index "'>" TransformHTML(v "") "</span>`n"
		If SBText !=
			SBText := _T1 " id='__StatusBarText'> ( StatusBarText ) </span>" _BT1 " id='copy_sbtext' name='" sb_max "'> copy " _BT2 _T2 _PRE1 "<span>" SBText "</span></span>" _PRE2
	}
	DetectHiddenText, % DetectHiddenText
	WinGetText, WinText, ahk_id %WinID%
	If WinText !=
		WinText := _T1 " id='__WindowText'> ( Window Text ) </span><a></a>" _BT1 " id='copy_wintext'> copy " _BT2 _DB _BT1 " id='wintext_hidden'> hidden - " DetectHiddenText " " _BT2 _T2
		. _LPRE  "><pre id='wintextcon'>" TransformHTML(WinText) "</pre>" _PRE2
	MenuText := GetMenu(WinID)

	If ViewStrPos
		ViewStrPos1 := _DP "<span name='MS:'>" WinX ", " WinY ", " WinX2 ", " WinY2 "</span>" _DP "<span name='MS:'>" WinX ", " WinY ", " WinWidth ", " WinHeight "</span>"

	IsWindowUnicodeStr := _DP "<span class='param'>Is unicode:</span>  <span>" (DllCall("user32\IsWindowUnicode", "Ptr", WinID) ? "True" : "False") "</span>"

	CoordMode, Mouse
	MouseGetPos, WinXS, WinYS, h
	If (h = hGui || h = oOther.hZoom || h = oOther.hZoomLW)
		Return HideAllMarkers()

	PixelGetColor, ColorRGB, %WinXS%, %WinYS%, RGB
	GuiControl, TB: -Redraw, ColorProgress
	GuiControl, % "TB: +c" SubStr(ColorRGB, 3), ColorProgress
	GuiControl, TB: +Redraw, ColorProgress

	; _________________________________________________ HTML_Win _________________________________________________

HTML_Win:
	If w_ShowStyles
		WinStyles := GetStyles(WinClass, WinStyle, WinExStyle, WinID)
	ButtonStyle_ := _DP _BB1 " id='get_styles_w'> " (!w_ShowStyles ? "show styles" : "hide styles") " " _BB2

	HTML_Win =
	( Ltrim
	<body id='body'>
	%_T1% id='__Title'> ( Title ) </span>%_BT1% id='pause_button'> pause %_BT2%%_DB%%_DB%%_BT1% id='run_zoom'> zoom %_BT2%%_T2%%_BR%
	%_PRE1%<span id='wintitle1' name='MS:'>%WinTitle%</span>%_PRE2%
	%_T1% id='__Class'> ( Class ) </span>%_T2%
	%_PRE1%<span id='wintitle2'><span class='param' id='wintitle2_' name='MS:S'>ahk_class </span><span name='MS:'>%WinClass%</span></span>%_PRE2%
	%_T1% id='__ProcessName'> ( ProcessName ) </span>%_BT1% id='copy_alltitle'> copy titles %_BT2%%_T2%
	%_PRE1%<span id='wintitle3'><span class='param' name='MS:S' id='wintitle3_'>ahk_exe </span><span name='MS:'>%WinProcessName%</span></span>%_PRE2%
	%_T1% id='__ProcessPath'> ( ProcessPath ) </span>%_BT1% id='infolder'> in folder %_BT2%%_DB%%_BT1% id='paste_process_path'> paste %_BT2%%_T2%
	%_PRE1%<span><span class='param' name='MS:S'>ahk_exe </span><span id='copy_processpath' name='MS:'>%WinProcessPath%</span></span>%_PRE2%
	%_T1% id='__CommandLine'> ( CommandLine ) </span>%_BT1% id='w_command_line'> launch %_BT2%%_DB%%_BT1% id='paste_command_line'> paste %_BT2%%_T2%
	%_PRE1%<span id='c_command_line' name='MS:'>%ComLine%</span>%_PRE2%
	%_T1% id='__Position'> ( Position ) </span>%_T2%
	%_PRE1%%_BP1% id='set_button_pos'>Pos:%_BP2%  <span name='MS:'>x%WinX% y%WinY%</span>%_DP%<span name='MS:'>x&sup2;%WinX2% y&sup2;%WinY2%</span>%_DP%%_BP1% id='set_button_pos'>Size:%_BP2%  <span name='MS:'>w%WinWidth% h%WinHeight%</span>%ViewStrPos1%
	<span class='param'>Client area size:</span>  <span name='MS:'>w%caW% h%caH%</span>%_DP%<span class='param'>left</span> %caX% <span class='param'>top</span> %caY% <span class='param'>right</span> %caWinRight% <span class='param'>bottom</span> %caWinBottom%%_PRE2%
	%_T1% id='__Other'> ( Other ) </span>%_BT1% id='flash_window'> flash %_BT2%%_ButWindow_Detective%%_T2%
	%_PRE1%<span class='param' name='MS:N'>PID:</span>  <span name='MS:'>%WinPID%</span>%_DP%%ProcessBitSize%%IsAdmin%<span class='param'>Window count:</span> %WinCountProcess%%_DP%%_BB1% id='process_close'> process close %_BB2%
	<span class='param' name='MS:N'>HWND:</span>  <span name='MS:'>%WinID%</span>%_DP%%_BB1% id='win_close'> win close %_BB2%%_DP%<span class='param'>Control count:</span>  %CountControl%%IsWindowUnicodeStr%%EX1Str%%CLSID%
	<span class='param'>Style:  </span><span id='w_Style' name='MS:'>%WinStyle%</span>%_DP%<span class='param'>ExStyle:  </span><span id='w_ExStyle' name='MS:'>%WinExStyle%</span>%ButtonStyle_%%_PRE2%
	<span id=WinStyles>%WinStyles%</span>%SBText%%WinText%%MenuText%<a></a>%_T0%
	</body>

	<style>
	* {
		margin: 0;
		background: none;
		font-family: %FontFamily%;
		font-weight: 500;
	}
	body {
		margin: 0.3em;
		background-color: #%ColorBg%;
		font-size: %FontSize%px;
	}
	.br {
		height:0.1em;
	}
	.box {
		position: absolute;
		overflow: hidden;
		width: 100`%;
		height: 1.5em;
		background: transparent;
		left: 0px;
	}
	.hr {
		position: absolute;
		width: 100`%;
		border-bottom: 0.2em dashed red;
		height: 0.5em;
	}
	.line {
		position: absolute;
		width: 100`%;
		top: 1px;
	}
	.con {
		position: absolute;
		left: 30`%;
	}
	.title {
		margin-right: 50px;
		white-space: pre;
		color: #%ColorTitle%;
	}
	pre {
		margin-bottom: 0.1em;
		margin-top: 0.1em;
		line-height: 1.3em;
	}
	.button {
		position: relative;
		border: 1px dotted;
		border-color: black;
		white-space: pre;
		cursor: hand;
	}
	.BB {
		display: inline-block;
	}
	.param {
		color: #%ColorParam%;
	}
	.titleparam {
		color: #%ColorTitle%;
	}
	#anchor {
		background-color: #%ColorSelAnchor%;
	}
	</style>
	)
	oOther.WinPID := WinPID
	oOther.WinID := WinID
	oOther.ChildID := hChild
	If StateLightMarker && (ThisMode = "Win") && (StateLight = 1 || (StateLight = 3 && GetKeyState("Shift", "P")))
		ShowMarker(WinX, WinY, WinWidth, WinHeight, 5)
	Return 1
}

Write_Win() {
	If (ThisMode != "Win")
		Return 0
	If oOther.anchor[ThisMode]
		HTML_Win := AnchorBefore(HTML_Win)
	oBody.innerHTML := HTML_Win
	If oOther.anchor[ThisMode]
		AnchorScroll()
	If oDocEl.scrollLeft
		oDocEl.scrollLeft := 0
	Return 1
}

	; _________________________________________________ Mode_Control _________________________________________________

Mode_Control:
	If A_GuiControl
		GuiControl, 1:Focus, oDoc
	ZoomMsg(10, 0)
	oBody.createTextRange().execCommand("RemoveFormat")
	GuiControl, TB: -0x0001, But2
	If (ThisMode = "Hotkey")
		Hotkey_Hook(0)
	If ThisMode = Control
		oDocEl.scrollLeft := 0
	Try SetTimer, Loop_%ThisMode%, Off
	ScrollPos[ThisMode,1] := oDocEl.scrollLeft, ScrollPos[ThisMode,2] := oDocEl.scrollTop
	If ThisMode != Control
		HTML_%ThisMode% := oBody.innerHTML
	ThisMode := "Control"
	If (HTML_Control = "")
		Spot_Control(1)
	Write_Control(), oDocEl.scrollLeft := ScrollPos[ThisMode,1]
	If !oOther.anchor[ThisMode]
		oDocEl.scrollTop := ScrollPos[ThisMode,2]
	TitleText := (TitleTextP1 := "AhkSpy - Control") . TitleTextP2
	SendMessage, 0xC, 0, &TitleText, , ahk_id %hGui%
	If isFindView
		FindNewText()

Loop_Control: 
	If (WinActive("ahk_id" hGui) && !ActiveNoPause) || Sleep = 1
		GoTo Repeat_Loop_Control
	If !OnlyShiftTab && Spot_Control()
		Write_Control(), StateAllwaysSpot ? Spot_Win() : 0
Repeat_Loop_Control:
	If (!isPaused && ThisMode = "Control" && !OnlyShiftTab)
		SetTimer, Loop_Control, -%RangeTimer%
	Return

Spot_Control(NotHTML = 0) {
	If NotHTML
		GoTo HTML_Control
	WinGet, ProcessName_A, ProcessName, A
	WinGet, HWND_A, ID, A
	WinGetClass, WinClass_A, A
	CoordMode, Mouse, Screen
	MouseGetPos, MXS, MYS, WinID, tControlNN
	CoordMode, Mouse, Window
	MouseGetPos, MXWA, MYWA, , tControlID, 2

	If (WinID = hGui || WinID = oOther.hZoom || WinID = oOther.hZoomLW)
		Return HideAllMarkers()

	CtrlInfo := "", isIE := 0
	ControlNN := tControlNN, ControlID := tControlID
	WinGetPos, WinX, WinY, WinW, WinH, ahk_id %WinID%
	WinGet, WinPID, PID, ahk_id %WinID%
	RWinX := MXS - WinX, RWinY := MYS - WinY
	GetClientPos(WinID, caX, caY, caW, caH)
	MXC := RWinX - caX, MYC := RWinY - caY

	WithRespectWin := "`n" _BP1 " id='set_pos'>Relative window:" _BP2 "  <span name='MS:'>"
		. Round(RWinX / WinW, 4) ", " Round(RWinY / WinH, 4) "</span>  <span class='param'>for</span> <span name='MS:'>w" WinW " h" WinH "</span>" _DP
	WithRespectClient := _BP1 " id='set_pos'>Relative client:" _BP2 "  <span name='MS:'>" Round(MXC / caW, 4) ", " Round(MYC / caH, 4)
		. "</span>  <span class='param'>for</span> <span name='MS:'>w" caW " h" caH "</span>"

	ControlGetPos, CtrlX, CtrlY, CtrlW, CtrlH,, ahk_id %ControlID%
	
	AccText := AccInfoUnderMouse(MXS, MYS, WinX, WinY, CtrlX, CtrlY, caX, caY, WinID, ControlID)
	If AccText !=
		AccText := _T1 " id='__AccInfo'> ( Accessible ) </span><a></a>" _BT1 " id='flash_acc'> flash " _BT2 _ButAccViewer _T2 AccText
	
	If ControlID
	{
		CtrlCAX := CtrlX - caX, CtrlCAY := CtrlY - caY
		
		CtrlX2 := CtrlX + CtrlW - 1, CtrlY2 := CtrlY + CtrlH - 1
		CtrlCAX2 := CtrlX2 - caX, CtrlCAY2 := CtrlY2 - caY
		
		CtrlSCX := WinX + CtrlX, CtrlSCY := WinY + CtrlY
		CtrlSCX2 := CtrlSCX + CtrlW - 1, CtrlSCY2 := CtrlSCY + CtrlH - 1 
		
		ControlGetText, CtrlText, , ahk_id %ControlID%
		If CtrlText !=
			CtrlText := _T1 " id='__Control_Text'> ( Control Text ) </span><a></a>" _BT1 " id='copy_button'> copy " _BT2 _T2 _LPRE ">" TransformHTML(CtrlText) _PRE2
			
		ControlGet, CtrlStyle, Style,,, ahk_id %ControlID%
		ControlGet, CtrlExStyle, ExStyle,,, ahk_id %ControlID%
		WinGetClass, CtrlClass, ahk_id %ControlID%
		
		If (hParent := DllCall("GetParent", "Ptr", ControlID)) && (hParent != WinID)
		{
			WinGetClass, ParentClass, ahk_id %hParent%
			_ParentControl := _DP "<span class='param'>Parent control:</span>  <span name='MS:'>" ParentClass "</span>" _DP "<span name='MS:'>" Format("0x{:x}", hParent) "</span>"
		}
		
		If ViewStrPos
			ViewStrPos1 := _DP "<span name='MS:'>" CtrlX ", " CtrlY ", " CtrlX2 ", " CtrlY2 "</span>" _DP "<span name='MS:'>" CtrlX ", " CtrlY ", " CtrlW ", " CtrlH "</span>"
			, ViewStrPos2 := _DP "<span name='MS:'>" CtrlCAX ", " CtrlCAY ", " CtrlCAX2 ", " CtrlCAY2 "</span>" _DP "<span name='MS:'>" CtrlCAX ", " CtrlCAY ", " CtrlW ", " CtrlH "</span>"
			. _DP "<span name='MS:'>" CtrlSCX ", " CtrlSCY ", " CtrlSCX2 ", " CtrlSCY2 "</span>" _DP "<span name='MS:'>" CtrlSCX ", " CtrlSCY ", " CtrlW ", " CtrlH "</span>" 	
		
		If DynamicControlPath
			control_path_value := ChildToPath(ControlID)
	} 
	If ControlNN !=
	{
		rmCtrlX := MXS - WinX - CtrlX, rmCtrlY := MYS - WinY - CtrlY
		ControlNN_Sub := RegExReplace(ControlNN, "S)\d+| ")
		If IsFunc("GetInfo_" ControlNN_Sub)
		{
			CtrlInfo := GetInfo_%ControlNN_Sub%(ControlID, ClassName)
			If CtrlInfo !=
			{
				If isIE
					CtrlInfo = %_T1% id='__Info_Class'> ( Info - %ClassName% ) </span><a></a>%_BT1% id='flash_IE'> flash %_BT2%%_ButiWB2Learner%%_T2%%CtrlInfo%
				Else
					CtrlInfo = %_T1% id='__Info_Class'> ( Info - %ClassName% ) </span><a></a>%_T2%%_PRE1%%CtrlInfo%%_PRE2%
			}
		}
		WithRespectControl := _DP "<span name='MS:'>" Round(rmCtrlX / CtrlW, 4) ", " Round(rmCtrlY / CtrlH, 4) "</span>"
	}
	Else
		rmCtrlX := rmCtrlY := ""
	
	ControlGetFocus, CtrlFocus, ahk_id %WinID%
	WinGet, ProcessName, ProcessName, ahk_id %WinID%
	WinGetClass, WinClass, ahk_id %WinID%
	
	MouseGetPos, , , h
	If (h = hGui || h = oOther.hZoom || h = oOther.hZoomLW)
		Return HideAllMarkers()
	
	If UseUIA 
	{
		UIAElement := oUIAInterface.ElementFromPoint(MXS, MYS)
		UIAPID := UIAElement.CurrentProcessId
		CurrentControlTypeIndex := Format("0x{:X}", UIAElement.CurrentControlType)
		CurrentControlTypeName := UIA_ControlType(CurrentControlTypeIndex)
		CurrentAutomationId := UIAElement.CurrentAutomationId  
		CurrentLocalizedControlType := UIAElement.CurrentLocalizedControlType
		UIAHWND := UIAElement.CurrentNativeWindowHandle
		
		WinGet, UIAProcessName, ProcessName, ahk_pid %UIAPID%
		WinGet, UIAProcessPath, ProcessPath, ahk_pid %UIAPID%
		Loop, %UIAProcessPath%
			UIAProcessPath = %A_LoopFileLongPath%
		
		If (UIAPID != WinPID)
			bc = style='background-color: #%HighLightBckg%'
		
		UseUIAStr := "`n" _T1 " id='P__UIA_Object'> ( UIA Interface ) </span><a></a>" _T2
		. _PRE1 "<div " bc "><span class='param' name='MS:N'>PID:</span>  <span name='MS:'>" UIAPID "</span>" 
		
		. (UIAHWND ? _DP
		. "<span class='param' name='MS:N'>HWND:</span>  <span name='MS:'>" Format("0x{:x}", UIAHWND) "</span>"
		. _DP "<span class='param' name='MS:N'>ControlClass:</span>  <span name='MS:'>" TransformHTML(UIAElement.CurrentClassName) "</span>" : _DP "HWND undefined")
		. _DN
		. (CurrentControlTypeIndex != "" ? ""
		. "<span class='param' name='MS:N'>ControlType:</span>  <span name='MS:'>" CurrentControlTypeName "</span>"
		. _DP " <span name='MS:'>" CurrentControlTypeIndex "</span>" : "ControlType undefined")
		
		. (CurrentAutomationId != "" ? _DP
		. "<span class='param' name='MS:N'>AutomationId:</span>  <span name='MS:'>" CurrentAutomationId "</span>" : _DP "AutomationId undefined")
		
		. (CurrentLocalizedControlType != "" ? _DP
		. "<span class='param' name='MS:N'>LocalizedControlType:</span>  <span name='MS:'>" CurrentLocalizedControlType "</span>" : _DP "LocalizedControlType undefined")
		
		. _DN "<span class='param' name='MS:N'>ProcessName:</span>  <span name='MS:'>" TransformHTML(UIAProcessName) "</span>"
		. _DP "<span class='param' name='MS:N'>ProcessPath:</span>  <span name='MS:'>" TransformHTML(UIAProcessPath) "</span></div>" _PRE2
	}
	PixelGetColor, ColorBGR, %MXS%, %MYS%
	ColorRGB := Format("0x{:06X}", (ColorBGR & 0xFF) << 16 | (ColorBGR & 0xFF00) | (ColorBGR >> 16))
	sColorBGR := SubStr(ColorBGR, 3)
	sColorRGB := SubStr(ColorRGB, 3)
	GuiControl, TB: -Redraw, ColorProgress
	GuiControl, % "TB: +c" sColorRGB, ColorProgress
	GuiControl, TB: +Redraw, ColorProgress

	If (!isIE && ThisMode = "Control" && (StateLight = 1 || (StateLight = 3 && GetKeyState("Shift", "P"))))
	{
		If ControlID && StateLightMarker 
			ShowMarker(CtrlSCX, CtrlSCY, CtrlW, CtrlH)
		Else
			HideMarker()
			
		StateLightAcc ? ShowAccMarker(AccCoord[1], AccCoord[2], AccCoord[3], AccCoord[4]) : 0
	}
	If ((S_CaretX := A_CaretX) != "")
		CaretPosStr = <span class='param'>Caret:</span>  <span name='MS:'>x%S_CaretX% y%A_CaretY%</span>
	Else 
		CaretPosStr = <span class='error'>Caret position undefined</span>
	
	; _________________________________________________ HTML_Control _________________________________________________

HTML_Control:
	If ControlID
	{
		If c_ShowStyles
			ControlStyles := GetStyles(CtrlClass, CtrlStyle, CtrlExStyle, ControlID)
		ButtonStyle_ := _DP _BB1 " id='get_styles_c'> " (!c_ShowStyles ? "show styles" : "hide styles") " " _BB2 
		
		Relativescreen = <span class='param'>Relative screen:</span>  <span name='MS:'>x%CtrlSCX% y%CtrlSCY%</span>%_DP%<span name='MS:'>x&sup2;%CtrlSCX2% y&sup2;%CtrlSCY2%</span>
		
		HTML_ControlExist =
		( Ltrim
		%_T1% id='__Control'> ( Control ) </span>%_BT1% id='flash_control'> flash %_BT2%%_ButWindow_Detective%%_T2%
		%_PRE1%<span class='param'>ClassNN:</span>  <span name='MS:'>%ControlNN%</span>%_DP%<span class='param'>Class:</span>  <span name='MS:'>%CtrlClass%</span>
		%_BP1% id='set_button_pos'>Pos:%_BP2%  <span name='MS:'>x%CtrlX% y%CtrlY%</span>%_DP%<span name='MS:'>x&sup2;%CtrlX2% y&sup2;%CtrlY2%</span>%_DP%%_BP1% id='set_button_pos'>Size:%_BP2%  <span name='MS:'>w%CtrlW% h%CtrlH%</span>%ViewStrPos1%
		<span class='param'>Relative client area:</span>  <span name='MS:'>x%CtrlCAX% y%CtrlCAY%</span>%_DP%<span name='MS:'>x&sup2;%CtrlCAX2% y&sup2;%CtrlCAY2%</span>%_DP%%Relativescreen%%ViewStrPos2%
		%_BP1% id='set_pos'>Mouse relative control:%_BP2%  <span name='MS:'>x%rmCtrlX% y%rmCtrlY%</span>%WithRespectControl%%_DP%%_BP1% id='control_path'> Get path: %_BP2%  <span id='control_path_value' name='MS:'>%control_path_value%</span>
		<span class='param'>HWND:</span>  <span name='MS:'>%ControlID%</span>%_ParentControl%
		<span class='param'>Style:</span>  <span id='c_Style' name='MS:'>%CtrlStyle%</span>%_DP%<span class='param'>ExStyle:</span>  <span id='c_ExStyle' name='MS:'>%CtrlExStyle%</span>%ButtonStyle_%%_PRE2%
		<span id=ControlStyles>%ControlStyles%</span>
		)
	}
	HTML_Control =
	( Ltrim
	<body id='body'>
	%_T1% id='__Mouse'> ( Mouse ) </span>%_BT1% id='pause_button'> pause %_BT2%%_DB%%_DB%%_BT1% id='run_zoom'> zoom %_BT2%%_T2%%_BR%
	%_PRE1%%_BP1% id='set_pos'>Screen:%_BP2%  <span name='MS:'>x%MXS% y%MYS%</span>%_DP%%_BP1% id='set_pos'>Window:%_BP2%  <span name='MS:'>x%RWinX% y%RWinY%</span>%_DP%%_BP1% id='set_pos'>Client:%_BP2%  <span name='MS:'>x%MXC% y%MYC%</span>%WithRespectWin%%WithRespectClient%
	<span class='param'>Relative active window:</span>  <span name='MS:'>x%MXWA% y%MYWA%</span>%_DP%<span class='param'>class</span> <span name='MS:'>%WinClass_A%</span> <span class='param'>exe</span> <span name='MS:'>%ProcessName_A%</span> <span class='param'>hwnd</span> <span name='MS:'>%HWND_A%</span>%_PRE2%
	%_T1% id='__PixelColor'> ( PixelColor ) </span>%_T2%
	%_PRE1%<span class='param'>RGB: </span> <span name='MS:'>%ColorRGB%</span>%_DP%<span name='MS:'>#%sColorRGB%</span>%_DP%<span class='param'>BGR: </span> <span name='MS:'>%ColorBGR%</span>%_DP%<span name='MS:'>#%sColorBGR%</span>%_PRE2%
	%_T1% id='__Window'> ( Window ) </span>%_BT1% id='flash_ctrl_window'> flash %_BT2%%_T2%
	%_PRE1%<span><span class='param' name='MS:S'>ahk_class</span> <span name='MS:'>%WinClass%</span></span> <span><span class='param' name='MS:S'>ahk_exe</span> <span name='MS:'>%ProcessName%</span></span> <span><span class='param' name='MS:S'>ahk_id</span> <span name='MS:'>%WinID%</span></span> <span><span class='param' name='MS:S'>ahk_pid</span> <span name='MS:'>%WinPID%</span></span>
	<span class='param'>Cursor:</span>  <span name='MS:'>%A_Cursor%</span>%_DP%%CaretPosStr%%_DP%<span class='param'>Client area:</span>  <span name='MS:'>x%caX% y%caY% w%caW% h%caH%</span>
	%_BP1% id='set_button_focus_ctrl'>Focus control:%_BP2%  <span name='MS:'>%CtrlFocus%</span>%_PRE2%
	%HTML_ControlExist%
	%CtrlInfo%%CtrlText%%UseUIAStr%%AccText%
	<a></a>%_T0%
	</body>

	<style>
	* {
		margin: 0;
		background: none;
		font-family: %FontFamily%;
		font-weight: 500;
	}
	body {
		margin: 0.3em;
		background-color: #%ColorBg%;
		font-size: %FontSize%px;
		scrollbar-y-position: 111px;
	}
	.br {
		height:0.1em;
	}
	.box {
		position: absolute;
		overflow: hidden;
		width: 100`%;
		height: 1.5em;
		background: transparent;
		left: 0px;
	}
	.line {
		position: absolute;
		width: 100`%;
		top: 1px;
	}
	.con {
		position: absolute;
		left: 30`%;
	}
	.title {
		margin-right: 50px;
		white-space: pre;
		color: #%ColorTitle%;
	}
	.hr {
		position: absolute;
		width: 100`%;
		border-bottom: 0.2em dashed red;
		height: 0.5em;
	}
	pre {
		margin-bottom: 0.1em;
		margin-top: 0.1em;
		line-height: 1.3em;
	}
	.button {
		position: relative;
		border: 1px dotted;
		border-color: black;
		white-space: pre;
		cursor: pointer;
	}
	.BB {
		display: inline-block;
	} 
	.param {
		color: #%ColorParam%;
	}
	.error {
		color: #%ColorDelimiter%;
	}
	#anchor {
		background-color: #%ColorSelAnchor%;
	}
	</style>
	)
	oOther.ControlID := ControlID
	oOther.MouseWinID := WinID
	oOther.CtrlClass := CtrlClass
	Return 1
}

Write_Control() {
	If (ThisMode != "Control")
		Return 0
	If oOther.anchor[ThisMode]
		HTML_Control := AnchorBefore(HTML_Control)
	oBody.innerHTML := HTML_Control
	If oOther.anchor[ThisMode]
		AnchorScroll()
	If oDocEl.scrollLeft
		oDocEl.scrollLeft := 0
	Return 1
}

	; _________________________________________________ Get Menu _________________________________________________

GetMenu(hWnd) {
	; Static prhWnd, MenuText
	; If (hWnd = prhWnd)
		; Return MenuText
	; prhWnd := hWnd
	SendMessage, 0x1E1, 0, 0, , ahk_id %hWnd%	;  MN_GETHMENU
	hMenu := ErrorLevel
	If !hMenu || (hMenu + 0 = "")
		Return
	Return _T1 " id='__Menu_text'> ( Menu text ) </span><a></a>" _BT1 " id='copy_menutext'> copy " _BT2 _DB
	. _BT1 " id='menu_idview'> id - " (MenuIdView ? "view" : "hide") " " _BT2 _T2 _LPRE " id='pre_menutext'>" RTrim(GetMenuText(hMenu), "`n")  _PRE2
}

GetMenuText(hMenu, child = 0)
{
	Loop, % DllCall("GetMenuItemCount", "Ptr", hMenu)
	{
		idx := A_Index - 1
		nSize++ := DllCall("GetMenuString", "Ptr", hMenu, "int", idx, "Uint", 0, "int", 0, "Uint", 0x400)   ;  MF_BYPOSITION
		nSize := (nSize * (A_IsUnicode ? 2 : 1))
		VarSetCapacity(sString, nSize)
		DllCall("GetMenuString", "Ptr", hMenu, "int", idx, "str", sString, "int", nSize, "Uint", 0x400)   ;  MF_BYPOSITION
		sString := TransformHTML(sString)
		idn := DllCall("GetMenuItemID", "Ptr", hMenu, "int", idx)
		IdItem := "<span class='param menuitemid' style='display: " (!MenuIdView ? "none" : "inline") ";'>`t`t`t<span name='MS:'>" idn "</span></span>"
		isSubMenu := (idn = -1) && (hSubMenu := DllCall("GetSubMenu", "Ptr", hMenu, "int", idx)) ? 1 : 0
		If isSubMenu
			sContents .= AddTab(child) "<span class='param'>" idx + 1 ":  </span><span name='MS:' class='titleparam'>" sString "</span>" IdItem "`n"
		Else If (sString = "")
			sContents .= AddTab(child) "<span class='param'>" idx + 1 ":  &#8212; &#8212; &#8212; &#8212; &#8212; &#8212; &#8212;</span>" IdItem "`n"
		Else
			sContents .= AddTab(child) "<span class='param'>" idx + 1 ":  </span><span name='MS:'>" sString "</span>" IdItem "`n"
		If isSubMenu
			sContents .= GetMenuText(hSubMenu, ++child), --child
	}
	Return sContents
}

AddTab(c) {
	loop % c
		Tab .= "<span class='param';'>&#8595;`t</span>"
	Return Tab
}

	; _________________________________________________ Get Info Control _________________________________________________

GetInfo_SysListView(hwnd, ByRef ClassNN) {
	ClassNN := "SysListView32"
	ControlGet, ListText, List,,, ahk_id %hwnd%
	ControlGet, RowCount, List, Count,, ahk_id %hwnd%
	ControlGet, ColCount, List, Count Col,, ahk_id %hwnd%
	ControlGet, SelectedCount, List, Count Selected,, ahk_id %hwnd%
	ControlGet, FocusedCount, List, Count Focused,, ahk_id %hwnd%
	Return	"<span class='param' name='MS:N'>Row count:</span> <span name='MS:'>" RowCount "</span>" _DP
			. "<span class='param' name='MS:N'>Column count:</span> <span name='MS:'>" ColCount "</span>`n"
			. "<span class='param' name='MS:N'>Selected count:</span> <span name='MS:'>" SelectedCount "</span>" _DP
			. "<span class='param' name='MS:N'>Focused row:</span> <span name='MS:'>" FocusedCount "</span>" _PRE2
			. _T1 " id='__Content_SysListView'> ( Content ) </span>" _BT1 " id='copy_button'> copy " _BT2 _T2 _LPRE ">" TransformHTML(ListText)
}

GetInfo_SysTreeView(hwnd, ByRef ClassNN) {
	ClassNN := "SysTreeView32"
	SendMessage 0x1105, 0, 0, , ahk_id %hwnd%   ; TVM_GETCOUNT
	ItemCount := ErrorLevel
	Return	"<span class='param' name='MS:N'>Item count:</span> <span name='MS:'>" ItemCount "</span>"
}

GetInfo_ListBox(hwnd, ByRef ClassNN) {
	ClassNN = ListBox
	Return GetInfo_ComboBox(hwnd, "", 1)
}
GetInfo_TListBox(hwnd, ByRef ClassNN) {
	ClassNN = TListBox
	Return GetInfo_ComboBox(hwnd, "", 1)
}
GetInfo_TComboBox(hwnd, ByRef ClassNN) {
	ClassNN = TComboBox
	Return GetInfo_ComboBox(hwnd, "")
}
GetInfo_ComboBox(hwnd, ByRef ClassNN, ListBox = 0) {
	ClassNN = ComboBox
	ControlGet, ListText, List,,, ahk_id %hwnd%
	SendMessage, (ListBox ? 0x188 : 0x147), 0, 0, , ahk_id %hwnd%   ; 0x188 - LB_GETCURSEL, 0x147 - CB_GETCURSEL
	SelPos := ErrorLevel
	SelPos := SelPos = 0xffffffff || SelPos < 0 ? "NoSelect" : SelPos + 1
	RegExReplace(ListText, "m`a)$", "", RowCount)
	Return	"<span class='param' name='MS:N'>Row count:</span> <span name='MS:'>" RowCount "</span>" _DP
			. "<span class='param' name='MS:N'>Row selected:</span> <span name='MS:'>" SelPos "</span>" _PRE2
			. _T1 " id='__Content_ComboBox'> ( Content ) </span>" _BT1 " id='copy_button'> copy " _BT2 _T2 _LPRE ">" TransformHTML(ListText)
}

GetInfo_CtrlNotifySink(hwnd, ByRef ClassNN) {
	ClassNN = CtrlNotifySink
	Return GetInfo_Scintilla(hwnd, "")
}

	;  http://forum.script-coding.com/viewtopic.php?pid=117128#p117128
	;  https://msdn.microsoft.com/en-us/library/windows/desktop/ms645478(v=vs.85).aspx

GetInfo_Edit(hwnd, ByRef ClassNN) {
	ClassNN = Edit
	Edit_GetFont(hwnd, FName, FSize)
	Return GetInfo_Scintilla(hwnd, "") "`n<span class='param' name='MS:N'>FontSize:</span> <span name='MS:'>" FSize "</span>" _DP "<span class='param' name='MS:N'>FontName:</span> <span name='MS:'>" FName "</span>"
		. "`n<span class='param' name='MS:N'>DlgCtrlID:</span> <span name='MS:'>" DllCall("GetDlgCtrlID", Ptr, hwnd) "</span>"
}

Edit_GetFont(hwnd, byref FontName, byref FontSize) {
	SendMessage 0x31, 0, 0, , ahk_id %hwnd% ; WM_GETFONT
	If ErrorLevel = FAIL
		Return
	hFont := Errorlevel, VarSetCapacity(LF, szLF := 60 * (A_IsUnicode ? 2 : 1))
	DllCall("GetObject", UInt, hFont, Int, szLF, UInt, &LF)
	hDC := DllCall("GetDC", UInt, hwnd), DPI := DllCall("GetDeviceCaps", UInt, hDC, Int, 90)
	DllCall("ReleaseDC", Int, 0, UInt, hDC), FontSize := Round((-NumGet(LF, 0, "Int") * 72) / DPI)
	FontName := DllCall("MulDiv", Int, &LF + 28, Int, 1, Int, 1, Str)
}

GetInfo_Scintilla(hwnd, ByRef ClassNN) {
	ClassNN = Scintilla
	ControlGet, LineCount, LineCount,,, ahk_id %hwnd%
	ControlGet, CurrentCol, CurrentCol,,, ahk_id %hwnd%
	ControlGet, CurrentLine, CurrentLine,,, ahk_id %hwnd%
	ControlGet, Selected, Selected,,, ahk_id %hwnd%
	SendMessage, 0x00B0, , , , ahk_id %hwnd%			;  EM_GETSEL
	EM_GETSEL := ErrorLevel >> 16
	SendMessage, 0x00CE, , , , ahk_id %hwnd%			;  EM_GETFIRSTVISIBLELINE
	EM_GETFIRSTVISIBLELINE := ErrorLevel + 1
	Return	"<span class='param' name='MS:N'>Row count:</span> <span name='MS:'>" LineCount "</span>" _DP
			. "<span class='param' name='MS:N'>Selected length:</span> <span name='MS:'>" StrLen(Selected) "</span>"
			. "`n<span class='param' name='MS:N'>Current row:</span> <span name='MS:'>" CurrentLine "</span>" _DP
			. "<span class='param' name='MS:N'>Current column:</span> <span name='MS:'>" CurrentCol "</span>"
			. "`n<span class='param' name='MS:N'>Current select:</span> <span name='MS:'>" EM_GETSEL "</span>" _DP
			. "<span class='param' name='MS:N'>First visible line:</span> <span name='MS:'>" EM_GETFIRSTVISIBLELINE "</span>"
}

GetInfo_msctls_progress(hwnd, ByRef ClassNN) {
	ClassNN := "msctls_progress32"
	SendMessage, 0x0400+7,"TRUE",,, ahk_id %hwnd%	;  PBM_GETRANGE
	PBM_GETRANGEMIN := ErrorLevel
	SendMessage, 0x0400+7,,,, ahk_id %hwnd%			;  PBM_GETRANGE
	PBM_GETRANGEMAX := ErrorLevel
	SendMessage, 0x0400+8,,,, ahk_id %hwnd%			;  PBM_GETPOS
	PBM_GETPOS := ErrorLevel
	Return	"<span class='param' name='MS:N'>Level:</span> <span name='MS:'>" PBM_GETPOS "</span>" _DP
			. "<span class='param'>Range:  </span><span class='param' name='MS:N'>Min: </span><span name='MS:'>" PBM_GETRANGEMIN "</span>"
			. "  <span class='param' name='MS:N'>Max:</span> <span name='MS:'>" PBM_GETRANGEMAX "</span>"
}

GetInfo_msctls_trackbar(hwnd, ByRef ClassNN) {
	ClassNN := "msctls_trackbar32"
	SendMessage, 0x0400+1,,,, ahk_id %hwnd%			;  TBM_GETRANGEMIN
	TBM_GETRANGEMIN := ErrorLevel
	SendMessage, 0x0400+2,,,, ahk_id %hwnd%			;  TBM_GETRANGEMAX
	TBM_GETRANGEMAX := ErrorLevel
	SendMessage, 0x0400,,,, ahk_id %hwnd%			;  TBM_GETPOS
	TBM_GETPOS := ErrorLevel
	ControlGet, CtrlStyle, Style,,, ahk_id %hwnd%
	(!(CtrlStyle & 0x0200)) ? (TBS_REVERSED := "No")
	: (TBM_GETPOS := TBM_GETRANGEMAX - (TBM_GETPOS - TBM_GETRANGEMIN), TBS_REVERSED := "Yes")
	Return	"<span class='param' name='MS:N'>Level:</span> <span name='MS:'>" TBM_GETPOS "</span>" _DP
			. "<span class='param'>Invert style:</span>" TBS_REVERSED
			. "`n<span class='param'>Range:  </span><span class='param' name='MS:N'>Min: </span><span name='MS:'>" TBM_GETRANGEMIN "</span>" _DP
			. "<span class='param' name='MS:N'>Max:</span> <span name='MS:'>" TBM_GETRANGEMAX "</span>"
}

GetInfo_msctls_updown(hwnd, ByRef ClassNN) {
	ClassNN := "msctls_updown32"
	SendMessage, 0x0400+102,,,, ahk_id %hwnd%		;  UDM_GETRANGE
	UDM_GETRANGE := ErrorLevel
	SendMessage, 0x400+114,,,, ahk_id %hwnd%		;  UDM_GETPOS32
	UDM_GETPOS32 := ErrorLevel
	Return	"<span class='param' name='MS:N'>Level:</span> <span name='MS:'>" UDM_GETPOS32 "</span>" _DP
			. "<span class='param'>Range:  </span><span class='param' name='MS:N'>Min: </span><span name='MS:'>" UDM_GETRANGE >> 16 "</span>"
			. "  <span class='param' name='MS:N'>Max: </span><span name='MS:'>" UDM_GETRANGE & 0xFFFF "</span>"
}

GetInfo_SysTabControl(hwnd, ByRef ClassNN) {
	ClassNN := "SysTabControl32"
	ControlGet, SelTab, Tab,,, ahk_id %hwnd%
	SendMessage, 0x1300+44,,,, ahk_id %hwnd%		;  TCM_GETROWCOUNT
	TCM_GETROWCOUNT := ErrorLevel
	SendMessage, 0x1300+4,,,, ahk_id %hwnd%			;  TCM_GETITEMCOUNT
	TCM_GETITEMCOUNT := ErrorLevel
	Return	"<span class='param' name='MS:N'>Item count:</span> <span name='MS:'>" TCM_GETITEMCOUNT "</span>" _DP
			. "<span class='param' name='MS:N'>Row count:</span> <span name='MS:'>" TCM_GETROWCOUNT "</span>" _DP
			. "<span class='param' name='MS:N'>Selected item:</span> <span name='MS:'>" SelTab "</span>"
}

GetInfo_ToolbarWindow(hwnd, ByRef ClassNN) {
	ClassNN := "ToolbarWindow32"
	SendMessage, 0x0418,,,, ahk_id %hwnd%		;  TB_BUTTONCOUNT
	BUTTONCOUNT := ErrorLevel
	Return	"<span class='param' name='MS:N'>Button count:</span> <span name='MS:'>" BUTTONCOUNT "</span>"
}

	; _________________________________________________ Get Internet Explorer Info _________________________________________________

	;  http://www.autohotkey.com/board/topic/84258-iwb2-learner-iwebbrowser2/

GetInfo_AtlAxWin(hwnd, ByRef ClassNN) {
	ClassNN = AtlAxWin
	Return GetInfo_InternetExplorer_Server(hwnd, "")
}

GetInfo_InternetExplorer_Server(hwnd, ByRef ClassNN) {
	Static IID_IWebBrowserApp := "{0002DF05-0000-0000-C000-000000000046}"
	, ratios := [], IID_IHTMLWindow2 := "{332C4427-26CB-11D0-B483-00C04FD90119}"

	isIE := 1, ClassNN := "Internet Explorer_Server"
	MouseGetPos, , , , hwnd, 3
	If !(pwin := WBGet(hwnd))
		Return
	If !ratios[hwnd]
	{
		ratio := pwin.window.screen.deviceXDPI / pwin.window.screen.logicalXDPI
		Sleep 10 ; при частом запросе deviceXDPI, возвращает пусто
		!ratio && (ratio := 1)
		ratios[hwnd] := ratio
	}
	ratio := ratios[hwnd]
	pelt := pwin.document.elementFromPoint(rmCtrlX / ratio, rmCtrlY / ratio)
	Tag := pelt.TagName
	If (Tag = "IFRAME" || Tag = "FRAME")
	{
		If pFrame := ComObjQuery(pwin.document.parentWindow.frames[pelt.id], IID_IHTMLWindow2, IID_IHTMLWindow2)
			iFrame := ComObject(9, pFrame, 1)
		Else
			iFrame := ComObj(9, ComObjQuery(pelt.contentWindow, IID_IHTMLWindow2, IID_IHTMLWindow2), 1)
		WB2 := ComObject(9, ComObjQuery(pelt.contentWindow, IID_IWebBrowserApp, IID_IWebBrowserApp), 1)
		If ((Var := WB2.LocationName) != "")
			Frame .= "`n<span class='param' name='MS:N'>Title:  </span><span name='MS:'>" Var "</span>"
		If ((Var := WB2.LocationURL) != "")
			Frame .= "`n<span class='param' name='MS:N'>URL:  </span><span name='MS:'>" Var "</span>"
		If (iFrame.length)
			Frame .= "`n<span class='param' name='MS:N'>Count frames:  </span><span name='MS:'>" iFrame.length "</span>"
		If (Tag != "")
			Frame .= "`n<span class='param' name='MS:N'>TagName:  </span><span name='MS:'>" Tag "</span>"
		If ((Var := pelt.id) != "")
			Frame .= "`n<span class='param' name='MS:N'>ID:  </span><span name='MS:'>" Var "</span>"
		If ((Var := pelt.ClassName) != "")
			Frame .= "`n<span class='param' name='MS:N'>Class:  </span><span name='MS:'>" Var "</span>"
		If ((Var := pelt.sourceIndex) != "")
			Frame .= "`n<span class='param' name='MS:N'>Index:  </span><span name='MS:'>" Var "</span>"
		If ((Var := pelt.name) != "")
			Frame .= "`n<span class='param' name='MS:N'>Name:  </span><span name='MS:'>" TransformHTML(Var) "</span>"

		If ((Var := pelt.OuterHtml) != "")
			HTML := _T1 " id='P__Outer_HTML_FRAME'" _T1P "> ( Outer HTML ) </span><a></a>" _BT1 " id='copy_button'> copy " _BT2 _T2 _LPRE ">" TransformHTML(Var) _PRE2
		If ((Var := pelt.OuterText) != "")
			Text := _T1 " id='P__Outer_Text_FRAME'" _T1P "> ( Outer Text ) </span><a></a>" _BT1 " id='copy_button'> copy " _BT2 _T2 _LPRE ">" TransformHTML(Var) _PRE2
		If Frame !=
			Frame := _T1 " id='__FrameInfo_FRAME'> ( FrameInfo ) </span>" _T2 "<a></a>" _PRE1 Frame _PRE2 HTML Text

		_pbrt := pelt.getBoundingClientRect()
		pelt := iFrame.document.elementFromPoint((rmCtrlX / ratio) - _pbrt.left, (rmCtrlY / ratio) - _pbrt.top)
		__pbrt := pelt.getBoundingClientRect(), pbrt := {}
		pbrt.left := __pbrt.left + _pbrt.left, pbrt.right := __pbrt.right + _pbrt.left
		pbrt.top := __pbrt.top + _pbrt.top, pbrt.bottom := __pbrt.bottom + _pbrt.top
	}
	Else
		pbrt := pelt.getBoundingClientRect()

	WB2 := ComObject(9, ComObjQuery(pwin, IID_IWebBrowserApp, IID_IWebBrowserApp), 1)

	If ((Location := WB2.LocationName) != "")
		Topic .= "<span class='param' name='MS:N'>Title:  </span><span name='MS:'>" Location "</span>`n"
	If ((URL := WB2.LocationURL) != "")
		Topic .= "<span class='param' name='MS:N'>URL:  </span><span name='MS:'>" URL "</span>"
	If Topic !=
		Topic := _PRE1 Topic _PRE2

	If ((Var := pelt.id) != "")
		Info .= "`n<span class='param' name='MS:N'>ID:  </span><span name='MS:'>" Var "</span>"
	If ((Var := pelt.ClassName) != "")
		Info .= "`n<span class='param' name='MS:N'>Class:  </span><span name='MS:'>" Var "</span>"
	If ((Var := pelt.sourceIndex) != "")
		Info .= "`n<span class='param' name='MS:N'>Index:  </span><span name='MS:'>" Var "</span>"
	If ((Var := pelt.name) != "")
		Info .= "`n<span class='param' name='MS:N'>Name:  </span><span name='MS:'>" TransformHTML(Var) "</span>"

	If ((Var := pelt.OuterHtml) != "")
		HTML := _T1 " id='P__Outer_HTML'" _T1P "> ( Outer HTML ) </span><a></a>" _BT1 " id='copy_button'> copy " _BT2 _T2 _LPRE ">" TransformHTML(Var) _PRE2
	If ((Var := pelt.OuterText) != "")
		Text := _T1 " id='P__Outer_Text'" _T1P "> ( Outer Text ) </span><a></a>" _BT1 " id='copy_button'> copy " _BT2 _T2 _LPRE ">" TransformHTML(Var) _PRE2

	x1 := pbrt.left * ratio, y1 := pbrt.top * ratio
	x2 := pbrt.right * ratio, y2 := pbrt.bottom * ratio
	ObjRelease(pwin), ObjRelease(pelt), ObjRelease(WB2), ObjRelease(iFrame), ObjRelease(pbrt)

	If (ThisMode = "Control") && (StateLight = 1 || (StateLight = 3 && GetKeyState("Shift", "P")))
	{
		WinGetPos, sX, sY, , , ahk_id %hwnd%
		StateLightMarker ? ShowMarker(sX + x1, sY + y1, x2 - x1, y2 - y1) : 0
		StateLightAcc ? ShowAccMarker(AccCoord[1], AccCoord[2], AccCoord[3], AccCoord[4]) : 0
	}
	If (pelt.TagName)
		Info := _T1 " id='P__Tag_name' name='MS:N'> ( Tag name: <span name='MS:' style='color: #" ColorFont ";'>"
		. pelt.TagName "</span>" (Frame ? " - (in frame)" : "") " ) </span>" _T2
		. _PRE1  "<span class='param'>Pos: </span><span name='MS:'>x" Round(x1) " y" Round(y1) "</span>"
		. _DP "<span name='MS:'>x&sup2;" Round(x2) - 1 " y&sup2;" Round(y2) - 1 "</span>"
		. _DP "<span class='param'>Size: </span><span name='MS:'>w" Round(x2 - x1) " h" Round(y2 - y1) "</span>" Info _PRE2

	oPubObj.IEElement := {Pos:[sX + x1, sY + y1, x2 - x1, y2 - y1], hwnd:hwnd}
	Return Topic Info HTML Text Frame
}

WBGet(hwnd) {
	Static Msg := DllCall("RegisterWindowMessage", "Str", "WM_HTML_GETOBJECT")
	, IID_IHTMLWindow2 := "{332C4427-26CB-11D0-B483-00C04FD90119}", GUID, _ := VarSetCapacity(GUID,16,0)
	SendMessage, Msg, , , , ahk_id %hwnd%
	DllCall("oleacc\ObjectFromLresult", "Ptr", ErrorLevel, "Ptr", &GUID, "Ptr", 0, PtrP, pdoc)
	Return ComObj(9, ComObjQuery(pdoc, IID_IHTMLWindow2, IID_IHTMLWindow2), 1), ObjRelease(pdoc)
}

	; _________________________________________________ Get Acc Info _________________________________________________

	;  http://www.autohotkey.com/board/topic/77888-accessible-info-viewer-alpha-release-2012-09-20/

AccInfoUnderMouse(mx, my, wx, wy, cx, cy, caX, caY, WinID, ControlID) {
	Static h
	If Not h
		h := DllCall("LoadLibrary", "Str", "oleacc", "Ptr")
	If DllCall("oleacc\AccessibleObjectFromPoint"
		, "Int64", mx&0xFFFFFFFF|my<<32, "Ptr*", pacc
		, "Ptr", VarSetCapacity(varChild,8+2*A_PtrSize,0)*0+&varChild) = 0
	Acc := ComObjEnwrap(9,pacc,1), child := NumGet(varChild,8,"UInt")
	If !IsObject(Acc)
		Return
	Count := (Var := Acc.accChildCount) != "" ? "<span name='MS:'>" Var "</span>" : "N/A"
	Var := child ? "Child" _DP "<span class='param' name='MS:N'>Id:  </span><span name='MS:'>" child "</span>"
		. _DP "<span class='param' name='MS:N'>Parent child count:  </span>" Count
		: "Parent" _DP "<span class='param' name='MS:N'>ChildCount:  </span>" Count

	If DynamicAccPath
		acc_path_value := GetAccPath(Acc, child)

	code := _PRE1 "<span class='param'>Type:</span>  " Var _DP _BP1 " id='acc_path'> Get path: " _BP2 "  <span id='acc_path_value' name='MS:'>" acc_path_value "</span>" _PRE2

	AccGetLocation(Acc, child)
	x := AccCoord[1], y := AccCoord[2], w := AccCoord[3], h := AccCoord[4]

	code .= _T1 " id='P__Position_relative_Acc'" _T1P "> ( Position relative ) </span>" _T2 _PRE1 "<span class='param'>Screen: </span>"
		. "<span name='MS:'>x" x " y" y "</span>"
		. _DP "<span name='MS:'>x&sup2;" x + w - 1 " y&sup2;" y + h - 1 "</span>"
		. _DP "<span class='param'>Size: </span><span name='MS:'>w" w " h" h "</span>"
		.  _DP  "<span class='param'>Mouse: </span><span name='MS:'>x" mx - AccCoord[1] " y" my - AccCoord[2] "</span>`n"

		. "<span class='param'>Window: </span><span name='MS:'>x" x - wx " y" y - wy "</span>"
		. _DP "<span name='MS:'>x&sup2;" x - wx + w - 1 " y&sup2;" y - wy + h - 1 "</span>"
		
		. _DP "<span class='param'>Client: </span><span name='MS:'>x" x - wx - caX " y" y - wy - caY "</span>"
		. _DP "<span name='MS:'>x&sup2;" x - wx + w - 1 - caX " y&sup2;" y - wy + h - 1 - caY "</span>"
		 
		. (cx != "" ? _DP "<span class='param'>Control: </span><span name='MS:'>x" (x - wx - cx) " y" (y - wy - cy) "</span>"
		. _DP "<span name='MS:'>x&sup2;" (x - wx - cx) + w - 1 " y&sup2;" (y - wy - cy) + h - 1 "</span>" : "")  _PRE2

	If ((Hwnd := AccWindowFromObject(pacc)) != ControlID && Hwnd != WinID) {   ;	можно Acc вместо pacc, then ComObjValue
		WinGetClass, CtrlClass, ahk_id %Hwnd%
		WinGet, WinProcess, ProcessName, ahk_id %Hwnd%
		WinGet, WinPID, PID, ahk_id %Hwnd%
		code .= _T1 " id='P__WindowFromObject'" _T1P "> ( WindowFromObject ) </span><a></a>" _T2 _PRE1
		. "<div style='background-color: #" HighLightBckg "'><span class='param' name='MS:N'>HWND:</span>  <span name='MS:'>" Format("0x{:x}", Hwnd) "</span>"
		. _DP "<span class='param' name='MS:N'>Class:</span>  <span name='MS:'>" TransformHTML(CtrlClass) "</span>"
		. _DP "<span class='param' name='MS:N'>Exe:</span>  <span name='MS:'>" TransformHTML(WinProcess) "</span>"
		. _DP "<span class='param' name='MS:N'>PID:</span>  <span name='MS:'>" WinPID "</span></div>" _PRE2
	}
	If ((Var := Acc.accName(child)) != "")
		code .= _T1 " id='P__Name_Acc'" _T1P "> ( Name ) </span><a></a>" _BT1 " id='copy_button'> copy " _BT2 _T2 _LPRE ">" TransformHTML(Var) _PRE2
	If ((Var := Acc.accValue(child)) != "")
		code .= _T1 " id='P__Value_Acc'" _T1P "> ( Value ) </span><a></a>" _BT1 " id='copy_button'> copy " _BT2 _T2 _LPRE ">" TransformHTML(Var) _PRE2
	AccState(Acc, child, style, strstyles)
	If (strstyles != "")
		code .= _T1 " id='P__State_Acc'" _T1P "> ( State: <span name='MS:' style='color: #" ColorFont ";'>" style "</span> ) </span>" _T2 _PRE1 strstyles _PRE2
	If ((Var := AccRole(Acc, child)) != "")
		code .= _T1 " id='P__Role_Acc'" _T1P "> ( Role ) </span>" _T2 _PRE1 "<span name='MS:'>" TransformHTML(Var) "</span>"
		. _DP "<span class='param' name='MS:N'>code: </span><span name='MS:'>" Acc.accRole(child) "</span>" _PRE2
	If (child &&(Var := AccRole(Acc)) != "")
		code .= _T1 " id='P__Role_parent_Acc'" _T1P "> ( Role - parent ) </span>" _T2 _PRE1 "<span name='MS:'>" TransformHTML(Var) "</span>"
		. _DP "<span class='param' name='MS:N'>code: </span><span name='MS:'>" Acc.accRole(0) "</span>" _PRE2
	If ((Var := Acc.accDefaultAction(child)) != "")
		code .= _T1 " id='P__Action_Acc'" _T1P "> ( Action ) </span>" _T2 _PRE1 "<span name='MS:'>" TransformHTML(Var) "</span>" _PRE2
	If ((Var := Acc.accSelection) > 0)
		code .= _T1 " id='P__Selection_parent_Acc'" _T1P "> ( Selection - parent ) </span>" _T2 _PRE1 "<span name='MS:'>" TransformHTML(Var) "</span>" _PRE2
	AccAccFocus(WinID, accFocusName, accFocusValue)
	If (accFocusName != "")
		code .= _T1 " id='P__Focus_name_Acc'" _T1P "> ( Focus - name ) </span><a></a>" _BT1 " id='copy_button'> copy " _BT2 _T2 _LPRE ">" TransformHTML(accFocusName) _PRE2
	If (accFocusValue != "")
		code .= _T1 " id='P__Focus_value_Acc'" _T1P "> ( Focus - value ) </span><a></a>" _BT1 " id='copy_button'> copy " _BT2 _T2 _LPRE ">" TransformHTML(accFocusValue) _PRE2
	If ((Var := Acc.accDescription(child)) != "")
		code .= _T1 " id='P__Description_Acc'" _T1P "> ( Description ) </span>" _T2 _PRE1 "<span name='MS:'>" TransformHTML(Var) "</span>" _PRE2
	If ((Var := Acc.accKeyboardShortCut(child)) != "")
		code .= _T1 " id='P__ShortCut_Acc'" _T1P "> ( ShortCut ) </span>" _T2 _PRE1 "<span name='MS:'>" TransformHTML(Var) "</span>" _PRE2
	If ((Var := Acc.accHelp(child)) != "")
		code .= _T1 " id='P__Help_Acc'" _T1P "> ( Help ) </span>" _T2 _PRE1 "<span name='MS:'>" TransformHTML(Var) "</span>" _PRE2
	If ((Var := Acc.AccHelpTopic(child)))
		code .= _T1 " id='P__HelpTopic_Acc'" _T1P "> ( HelpTopic ) </span>" _T2 _PRE1 "<span name='MS:'>" TransformHTML(Var) "</span>" _PRE2

	oPubObj.AccObj := {AccObj:Acc, child:child, WinID:WinID, ControlID:ControlID}
	Return code
}

	;	https://docs.microsoft.com/ru-ru/windows/desktop/WinAuto/object-state-constants
	;	http://forum.script-coding.com/viewtopic.php?pid=130762#p130762

AccState(Acc, child, byref style, byref str, i := 1) {
	style := Format("0x{1:08X}", Acc.accState(child))
	If (style = 0)
		Return "", str := "<span class='param' name='MS:'>" AccGetStateText(0) "</span>" _DP "<span name='MS:'>" 0x00000000 "</span>`n"
	While (i <= style) {
		if (i & style)
			str .= "<span class='param' name='MS:'>" AccGetStateText(i) "</span>" _DP "<span name='MS:'>" Format("0x{1:08X}", i) "</span>`n"
		i <<= 1
	}
}

AccWindowFromObject(pacc) {
	If DllCall("oleacc\WindowFromAccessibleObject", "Ptr", IsObject(pacc) ? ComObjValue(pacc) : pacc, "Ptr*", hWnd) = 0
		Return hWnd
}
	;	http://forum.script-coding.com/viewtopic.php?pid=130762#p130762

AccAccFocus(hWnd, byref name, byref value) {
	Acc := Acc_ObjectFromWindow(hWnd)
	While IsObject(Acc.accFocus)
		Acc := Acc.accFocus
	Child := Acc.accFocus
	try name := Acc.accName(child)
	try value := Acc.accValue(child)
}

AccRole(Acc, ChildId=0) {
	Return ComObjType(Acc, "Name") = "IAccessible" ? AccGetRoleText(Acc.accRole(ChildId)) : ""
}

AccGetRoleText(nRole) {
	nSize := DllCall("oleacc\GetRoleText", "UInt", nRole, "Ptr", 0, "UInt", 0)
	VarSetCapacity(sRole, (A_IsUnicode?2:1)*nSize)
	DllCall("oleacc\GetRoleText", "UInt", nRole, "str", sRole, "UInt", nSize+1)
	Return sRole
}

AccGetStateText(nState) {
	nSize := DllCall("oleacc\GetStateText", "UInt", nState, "Ptr", 0, "UInt", 0)
	VarSetCapacity(sState, (A_IsUnicode?2:1)*nSize)
	DllCall("oleacc\GetStateText", "UInt", nState, "str", sState, "UInt", nSize+1)
	Return sState
}

AccGetLocation(Acc, Child=0) {
	Acc.accLocation(ComObj(0x4003,&x:=0), ComObj(0x4003,&y:=0), ComObj(0x4003,&w:=0), ComObj(0x4003,&h:=0), Child)
	AccCoord[1]:=NumGet(x,0,"int"), AccCoord[2]:=NumGet(y,0,"int"), AccCoord[3]:=NumGet(w,0,"int"), AccCoord[4]:=NumGet(h,0,"int")
}

GetAccPath(Acc, child) {
	path := Acc_GetPath(Acc)
	if path !=
		Return child ? path "," child : path
	Else
		Return "object not found"
}

Acc_GetPath(Acc) {
	hwnd := Acc_WindowFromObject(Acc)
	WinObj := Acc_ObjectFromWindow(hwnd)
	WinObjPos := Acc_Location(WinObj)
	While Acc_WindowFromObject(Parent := Acc_Parent(Acc)) = hwnd {
		t2 := GetEnumIndex(Acc) "," t2
		if Acc_Location(Parent) = WinObjPos
			return SubStr(t2, 1, -1)
		Acc := Parent
	}
	While Acc_WindowFromObject(Parent := Acc_Parent(WinObj)) = hwnd
		t1 .= "P.", WinObj := Parent
	return t1 SubStr(t2, 1, -1)
}
GetEnumIndex(Acc, ChildId=0) {
	if Not ChildId {
		ChildPos := Acc_Location(Acc)
		For Each, child in Acc_Children(Acc_Parent(Acc))
			if IsObject(child) and Acc_Location(child) = ChildPos
				return A_Index
	}
	else {
		ChildPos := Acc_Location(Acc,ChildId)
		For Each, child in Acc_Children(Acc)
			if Not IsObject(child) and Acc_Location(Acc,child) = ChildPos
				return A_Index
	}
}
Acc_ObjectFromPoint(ByRef _idChild_ = "", x = "", y = "") {
	If DllCall("oleacc\AccessibleObjectFromPoint", "Int64", x==""||y==""?0*DllCall("GetCursorPos","Int64*",pt)+pt:x&0xFFFFFFFF|y<<32, "Ptr*", pacc, "Ptr", VarSetCapacity(varChild,8+2*A_PtrSize,0)*0+&varChild)=0
		Return ComObjEnwrap(9,pacc,1), _idChild_:=NumGet(varChild,8,"UInt")
}

Acc_ObjectFromWindow(hWnd, idObject = 0) {
	If DllCall("oleacc\AccessibleObjectFromWindow", "Ptr", hWnd, "UInt", idObject&=0xFFFFFFFF, "Ptr", -VarSetCapacity(IID,16)+NumPut(idObject==0xFFFFFFF0?0x46000000000000C0:0x719B3800AA000C81,NumPut(idObject==0xFFFFFFF0?0x0000000000020400:0x11CF3C3D618736E0,IID,"Int64"),"Int64"), "Ptr*", pacc)=0
		Return ComObjEnwrap(9,pacc,1)
}
Acc_WindowFromObject(pacc) {
	If DllCall("oleacc\WindowFromAccessibleObject", "Ptr", IsObject(pacc)?ComObjValue(pacc):pacc, "Ptr*", hWnd)=0
		Return	hWnd
}
Acc_Location(Acc, ChildId=0) {
	try Acc.accLocation(ComObj(0x4003,&x:=0), ComObj(0x4003,&y:=0), ComObj(0x4003,&w:=0), ComObj(0x4003,&h:=0), ChildId)
	return "x" (x:=NumGet(x,0,"int")) " y" (y:=NumGet(y,0,"int")) " w" (w:=NumGet(w,0,"int")) " h" (h:=NumGet(h,0,"int"))
}
Acc_Parent(Acc) {
	try parent:=Acc.accParent
	return parent?Acc_Query(parent):
}
Acc_Children(Acc) {
	if ComObjType(Acc,"Name")!="IAccessible"
		return
	else {
		cChildren:=Acc.accChildCount, Children:=[]
	if DllCall("oleacc\AccessibleChildren", "Ptr", ComObjValue(Acc), "Int", 0, "Int", cChildren, "Ptr", VarSetCapacity(varChildren,cChildren*(8+2*A_PtrSize),0)*0+&varChildren, "Int*", cChildren)=0 {
		Loop %cChildren%
			i:=(A_Index-1)*(A_PtrSize*2+8)+8, child:=NumGet(varChildren,i), Children.Insert(NumGet(varChildren,i-8)=3?child:Acc_Query(child)), ObjRelease(child)
		return Children
		}
	}
}
Acc_Query(Acc) {
	try return ComObj(9, ComObjQuery(Acc,"{618736e0-3c3d-11cf-810c-00aa00389b71}"), 1)
}

	; _________________________________________________ Mode_Hotkey _________________________________________________

Mode_Hotkey:
	Try SetTimer, Loop_%ThisMode%, Off
	ZoomMsg(10, 1) 
	If ThisMode = Hotkey
		oDocEl.scrollLeft := 0
	oBody.createTextRange().execCommand("RemoveFormat")
	ScrollPos[ThisMode,1] := oDocEl.scrollLeft, ScrollPos[ThisMode,2] := oDocEl.scrollTop
	If ThisMode != Hotkey
		HTML_%ThisMode% := oBody.innerHTML
	ThisMode := "Hotkey"
	If A_GuiControl  ;	WinActive("ahk_id" hGui)
		Hotkey_Hook(!isPaused)
	TitleText := (TitleTextP1 := "AhkSpy - Button") . TitleTextP2
	ShowMarker ? (HideAllMarkers()) : 0
	(HTML_Hotkey != "") ? Write_Hotkey() : Write_HotkeyHTML({Mods:"Waiting pushed buttons..."})
	oDocEl.scrollLeft := ScrollPos[ThisMode,1], oDocEl.scrollTop := ScrollPos[ThisMode,2]
	SendMessage, 0xC, 0, &TitleText, , ahk_id %hGui%
	GuiControl, TB: -0x0001, But3
	; WinActivate ahk_id %hGui%
	GuiControl, 1:Focus, oDoc
	If isFindView
		FindNewText()
	Return

Write_HotkeyHTML(K) {
	Static PrHK1, PrHK2, Name

	Mods := K.Mods, KeyName := K.Name
	Prefix := K.Pref
	Hotkey := K.HK = "" ? K.TK : K.HK
	LRMods := K.LRMods, LRPref := TransformHTML(K.LRPref)
	ThisKey := K.TK, VKCode := K.VK, SCCode := K.SC
	If (K.NFP && Mods KeyName != "")
		NotPhysical	:= " " _DP "<span style='color:#" ColorDelimiter "'> Emulated</span>"

	HK1 := K.IsCode ? Hotkey : ThisKey
	HK2 := HK1 = PrHK1 ? PrHK2 : PrHK1, PrHK1 := HK1, PrHK2 := HK2
	HKComm1 := "    `;  """ (StrLen(Name := GetKeyName(HK2)) = 1 ? Format("{:U}", Name) : Name)
	HKComm2 := (StrLen(Name := GetKeyName(HK1)) = 1 ? Format("{:U}", Name) : Name) """"

	If K.IsCode
		Comment := "<span class='param' name='MS:SP'>    `;  """ KeyName """</span>"
	If (Hotkey != "")
		FComment := "<span class='param' name='MS:SP'>    `;  """ (K.HK = "" ? K.TK : Mods KeyName) """</span>"

	If (LRMods != "")
	{
		LRMStr := "<span name='MS:'>" LRMods KeyName "</span>"
		If (K.HK != "")
			LRPStr := "  " _DP "  <span><span name='MS:'>" LRPref Hotkey "::</span><span class='param' name='MS:SP'>    `;  """ LRMods KeyName """</span></span>"
	}
	If Prefix !=
		DUMods := (K.MLCtrl ? "{LCtrl Down}" : "") (K.MRCtrl ? "{RCtrl Down}" : "")
			. (K.MLShift ? "{LShift Down}" : "") (K.MRShift ? "{RShift Down}" : "")
			. (K.MLAlt ? "{LAlt Down}" : "") (K.MRAlt ? "{RAlt Down}" : "")
			. (K.MLWin ? "{LWin Down}" : "") (K.MRWin ? "{RWin Down}" : "") . "{" Hotkey "}"
			. (K.MLCtrl ? "{LCtrl Up}" : "") (K.MRCtrl ? "{RCtrl Up}" : "")
			. (K.MLShift ? "{LShift Up}" : "") (K.MRShift ? "{RShift Up}" : "")
			. (K.MLAlt ? "{LAlt Up}" : "") (K.MRAlt ? "{RAlt Up}" : "")
			. (K.MLWin ? "{LWin Up}" : "") (K.MRWin ? "{RWin Up}" : "")

	SendHotkey := Hotkey

	ControlSend := DUMods = "" ? "{" SendHotkey "}" : DUMods

	VKCode_ := "0x" SubStr(VKCode, 3)
	SCCode_ := "0x" SubStr(SCCode, 3)

	If DecimalCode
		(VKCode_ += 0), SCCode_ += 0
	s_DecimalCode := DecimalCode ? "dec" : "hex"

	If (DUMods != "")
		LRSend := "  " _DP "  <span><span name='MS:'>" SendMode  " " DUMods "</span>" Comment "</span>"
	If SCCode !=
		ThisKeySC := "   " _DP "   <span name='MS:'>" VKCode "</span>   " _DP "   <span name='MS:'>" SCCode "</span>   "
		. _DP "   <span name='MS:' id='v_VKDHCode'>" VKCode_ "</span>   " _DP "   <span name='MS:' id='v_SCDHCode'>" SCCode_ "</span>"
	Else
		ThisKeySC := "   " _DP "   <span name='MS:' id='v_VKDHCode'>" VKCode_ "</span>"

	inp_hotkey := oDoc.getElementById("edithotkey").value, inp_keyname := oDoc.getElementById("editkeyname").value
	
	HTML_Hotkey =
	( Ltrim
	<body id='body'>
	%_T1%> ( Pushed buttons ) </span>%_BT1% id='pause_button'> pause %_BT2%%_DB%%_BT1% id='LButton_Hotkey'> LButton %_BT2%%_T2%
	%_PRE1%<br><span name='MS:'>%Mods%%KeyName%</span>%NotPhysical%<br><br>%LRMStr%<br>%_PRE2%
	%_T1%> ( Command syntax ) </span>%_BT1% id='SendCode'> %SendCode% %_BT2%%_DB%%_BT1% id='SendMode'> %SendModeStr% %_BT2%%_T2%
	%_PRE1%<br><span><span name='MS:'>%Prefix%%Hotkey%::</span>%FComment%</span>%LRPStr%
	<span name='MS:P'>        </span>
	<span><span name='MS:'>%SendMode% %Prefix%{%SendHotkey%}</span>%Comment%</span>  %_DP%  <span><span name='MS:'>ControlSend, ahk_parent, %ControlSend%, WinTitle</span>%Comment%</span>
	<span name='MS:P'>        </span>
	<span><span name='MS:'>%Prefix%{%SendHotkey%}</span>%Comment%</span>%LRSend%
	<span name='MS:P'>        </span>
	<span><span name='MS:'>GetKeyState("%SendHotkey%", "P")</span>%Comment%</span>   %_DP%   <span><span name='MS:'>KeyWait, %SendHotkey%, D T0.5</span>%Comment%</span>
	<span name='MS:P'>        </span>
	<span><span name='MS:'>%HK2% & %HK1%::</span><span class='param' name='MS:SP'>%HKComm1% & %HKComm2%</span></span>   %_DP%   <span><span name='MS:'>%HK2%::%HK1%</span><span class='param' name='MS:SP'>%HKComm1% &#8250 &#8250 %HKComm2%</span></span>
	<span name='MS:P'>        </span>%_PRE2%
	%_T1%> ( Key ) </span>%_BT1% id='numlock'> num %_BT2%%_DB%%_BT1% id='locale_change'> locale %_BT2%%_DB%%_BT1% id='hook_reload'> hook reload %_BT2%%_DB%%_BT1% id='b_DecimalCode'> %s_DecimalCode% %_BT2%%_T2%
	%_PRE1%<br><span name='MS:'>%ThisKey%</span>   %_DP%   <span name='MS:'>%VKCode%%SCCode%</span>%ThisKeySC%

	%_PRE2%
	%_T1%> ( GetKeyName ) </span>%_BT1% id='paste_keyname'> paste %_BT2%%_T2%
	<br>
	<span id='hotkeybox'>%_INPHK% id='edithotkey' value='%inp_hotkey%'><button id='keyname'> &#8250 </button>%_INPHK% id='editkeyname' value='%inp_keyname%'></span>
	<br>
	<br>
	<span id='vkname'>%GetVKCodeNameStr%</span><span id='scname'>%GetSCCodeNameStr%</span>
	%_T0%
	</body>

	<style>
	* {
		margin: 0;
		background: none;
		font-family: %FontFamily%;
		font-weight: 500;
	}
	body {
		margin: 0.3em;
		background-color: #%ColorBg%;
		font-size: %FontSize%px;
	}
	.br {
		height:0.1em;
	}
	.box {
		position: absolute;
		overflow: hidden;
		width: 100`%;
		height: 1.7em;
		background: transparent;
		left: 0px;
	}
	.line {
		position: absolute;
		width: 100`%;
		top: 1px;
	}
	.con {
		position: absolute;
		left: 30`%;
	}
	.title {
		margin-right: 50px;
		white-space: pre;
		color: #%ColorTitle%;
	}
	.hr {
		position: absolute;
		width: 100`%;
		border-bottom: 0.2em dashed red;
		height: 0.5em;
	}
	pre {
		margin-bottom: 0.1em;
		margin-top: 0.1em;
		line-height: 1.1em;
	}
	.button {
		position: relative;
		border: 1px dotted;
		border-color: black;
		white-space: pre;
		cursor: hand;
	}
	.BB {
		display: inline-block;
	}
	.param {
		color: #%ColorParam%;
	}
	#SendCode, #SendMode {
		text-align: center;
		position: absolute;
	}
	#SendCode {
		width: 3em; left: 12em;
	}
	#SendMode {
		width: 5em; left: 16em;
	}
	#hotkeybox {
		position: relative;
		white-space: pre;
		left: 5px;
		display: inline;
	}
	#edithotkey, #keyname, #editkeyname {
		font-size: 1.2em;
		text-align: center;
		border: 1px dotted black;
	}
	#keyname {
		position: relative;
		background-color: #%ColorParam%;
		top: 0px; left: 2px; width: 3em;
		width: 3em;
	}
	#editkeyname {
		position: relative;
		left: 4px; top: 0px;
	} 
	</style>
	)
	Write_Hotkey()
}

Write_Hotkey() {
	oBody.innerHTML := HTML_Hotkey
	If oDocEl.scrollLeft
		oDocEl.scrollLeft := 0
}

	; _________________________________________________ Hotkey Functions _________________________________________________

	;  http://forum.script-coding.com/viewtopic.php?pid=69765#p69765

Hotkey_Init(Func, Options = "") {
	#HotkeyInterval 0
	Hotkey_Arr("Func", Func)
	Hotkey_Arr("Up", !!InStr(Options, "U"))
	Hotkey_MouseAndJoyInit(Options)
	OnExit("Hotkey_SetHook"), Hotkey_SetHook()
	Hotkey_Arr("Hook") ? (Hotkey_Hook(0), Hotkey_Hook(1)) : 0
}

Hotkey_Main(In) {
	Static Prefix := {"LCtrl":"<^","LShift":"<+","LAlt":"<!","LWin":"<#"
	,"RCtrl":">^","RShift":">+","RAlt":">!","RWin":">#"}, K := {}, ModsOnly
	Local IsMod, sIsMod
	IsMod := In.IsMod
	If (In.Opt = "Down") {
		If (K["M" IsMod] != "")
			Return 1
		sIsMod := SubStr(IsMod, 2)
		K["M" sIsMod] := sIsMod "+", K["P" sIsMod] := SubStr(Prefix[IsMod], 2)
		K["M" IsMod] := IsMod "+", K["P" IsMod] := Prefix[IsMod]
	}
	Else If (In.Opt = "Up") {
		sIsMod := SubStr(IsMod, 2)
		K.ModUp := 1, K["M" IsMod] := K["P" IsMod] := ""
		If (K["ML" sIsMod] = "" && K["MR" sIsMod] = "")
			K["M" sIsMod] := K["P" sIsMod] := ""
		If (!Hotkey_Arr("Up") && K.HK != "")
			Return 1
	}
	Else If (In.Opt = "OnlyMods") {
		If !ModsOnly
			Return 0
		K.MCtrl := K.MShift := K.MAlt := K.MWin := K.Mods := ""
		K.PCtrl := K.PShift := K.PAlt := K.PWin := K.Pref := ""
		K.PRCtrl := K.PRShift := K.PRAlt := K.PRWin := ""
		K.PLCtrl := K.PLShift := K.PLAlt := K.PLWin := K.LRPref := ""
		K.MRCtrl := K.MRShift := K.MRAlt := K.MRWin := ""
		K.MLCtrl := K.MLShift := K.MLAlt := K.MLWin := K.LRMods := ""
		Func(Hotkey_Arr("Func")).Call(K)
		Return ModsOnly := 0
	}
	Else If (In.Opt = "GetMod")
		Return !!(K.PCtrl K.PShift K.PAlt K.PWin)
	Else If (In = "LButton")
		GoTo, Hotkey_PressLButton

	K.UP := In.UP, K.IsJM := 0, K.Time := In.Time, K.NFP := In.NFP, K.IsMod := IsMod
	K.Mods := K.MCtrl K.MShift K.MAlt K.MWin
	K.LRMods := K.MLCtrl K.MRCtrl K.MLShift K.MRShift K.MLAlt K.MRAlt K.MLWin K.MRWin
	K.VK := "vk" In.VK, K.SC := "sc" In.SC, K.TK := GetKeyName(K.VK K.SC)
	K.TK := K.TK = "" ? K.VK K.SC : (StrLen(K.TK) = 1 ? Format("{:U}", K.TK) : K.TK)
	(IsMod) ? (K.HK := K.Pref := K.LRPref := K.Name := K.IsCode := "", ModsOnly := K.Mods = "" ? 0 : 1)
	: (K.IsCode := (SendCode != "name" && StrLen(K.TK) = 1)  ;	 && !Instr("1234567890-=", K.TK)
	, K.HK := K.IsCode ? K[SendCode] : K.TK
	, K.Name := K.HK = "vkBF" ? "/" : K.TK
	, K.Pref := K.PCtrl K.PShift K.PAlt K.PWin
	, K.LRPref := K.PLCtrl K.PRCtrl K.PLShift K.PRShift K.PLAlt K.PRAlt K.PLWin K.PRWin
	, ModsOnly := 0)
	Func(Hotkey_Arr("Func")).Call(K)
	Return 1

Hotkey_PressLButton:
	ThisHotkey := "LButton"
	K.NFP := !GetKeyState(ThisHotkey, "P")
	GoTo, Hotkey_Drop

Hotkey_PressMouseRButton:
	If !WM_CONTEXTMENU() && !Hotkey_Hook(0)
		Return

Hotkey_PressJoy:
Hotkey_PressMouse:
	ThisHotkey := A_ThisHotkey
	K.NFP := !GetKeyState(ThisHotkey, "P")
Hotkey_Drop:
	K.Time := A_TickCount
	K.Mods := K.MCtrl K.MShift K.MAlt K.MWin
	K.LRMods := K.MLCtrl K.MRCtrl K.MLShift K.MRShift K.MLAlt K.MRAlt K.MLWin K.MRWin
	K.Pref := K.PCtrl K.PShift K.PAlt K.PWin
	K.LRPref := K.PLCtrl K.PRCtrl K.PLShift K.PRShift K.PLAlt K.PRAlt K.PLWin K.PRWin
	K.HK := K.Name := K.TK := ThisHotkey, ModsOnly := K.UP := K.IsCode := 0, K.IsMod := K.SC := ""
	K.IsJM := A_ThisLabel = "Hotkey_PressJoy" ? 1 : 2
	K.VK := A_ThisLabel = "Hotkey_PressJoy" ? "" : Format("vk{:X}", GetKeyVK(ThisHotkey))
	Func(Hotkey_Arr("Func")).Call(K)
	Return 1
}

#If Hotkey_Arr("Hook")
#If Hotkey_Arr("Hook") && GetKeyState("RButton", "P")
#If Hotkey_Arr("Hook") && !Hotkey_Main({Opt:"GetMod"})
#If

Hotkey_MouseAndJoyInit(Options) {
	Static MouseKey := "MButton|WheelDown|WheelUp|WheelRight|WheelLeft|XButton1|XButton2"
	Local S_FormatInteger, Option
	Option := InStr(Options, "M") ? "On" : "Off"
	Hotkey, IF, Hotkey_Arr("Hook")
	Loop, Parse, MouseKey, |
		Hotkey, %A_LoopField%, Hotkey_PressMouse, % Option
	Option := InStr(Options, "L") ? "On" : "Off"
	Hotkey, IF, Hotkey_Arr("Hook") && GetKeyState("RButton"`, "P")
	Hotkey, LButton, Hotkey_PressMouse, % Option
	Option := InStr(Options, "R") ? "On" : "Off"
	Hotkey, IF, Hotkey_Arr("Hook")
	Hotkey, RButton, Hotkey_PressMouseRButton, % Option
	Option := InStr(Options, "J") ? "On" : "Off"
	S_FormatInteger := A_FormatInteger
	SetFormat, IntegerFast, D
	Hotkey, IF, Hotkey_Arr("Hook") && !Hotkey_Main({Opt:"GetMod"})
	Loop, 128
		Hotkey % Ceil(A_Index / 32) "Joy" Mod(A_Index - 1, 32) + 1, Hotkey_PressJoy, % Option
	SetFormat, IntegerFast, %S_FormatInteger%
	Hotkey, IF
}

Hotkey_Hook(Val = 1) {
	Hotkey_Arr("Hook", Val)
	!Val && Hotkey_Main({Opt:"OnlyMods"})
}

Hotkey_Arr(P*) {
	Static Arr := {}
	Return P.MaxIndex() = 1 ? Arr[P[1]] : (Arr[P[1]] := P[2])
}

	;  http://forum.script-coding.com/viewtopic.php?id=6350

Hotkey_LowLevelKeyboardProc(nCode, wParam, lParam) {
	Static Mods := {"A4":"LAlt","A5":"RAlt","A2":"LCtrl","A3":"RCtrl"
	,"A0":"LShift","A1":"RShift","5B":"LWin","5C":"RWin"}, oMem := []
	, HEAP_ZERO_MEMORY := 0x8, Size := 16, hHeap := DllCall("GetProcessHeap", Ptr)
	Local pHeap, Lp, Ext, VK, SC, SC1, SC2, IsMod, Time, NFP, KeyUp
	Critical

	If !Hotkey_Arr("Hook")
		Return DllCall("CallNextHookEx", "Ptr", 0, "Int", nCode, "UInt", wParam, "UInt", lParam)
	pHeap := DllCall("HeapAlloc", Ptr, hHeap, UInt, HEAP_ZERO_MEMORY, Ptr, Size, Ptr)
	DllCall("RtlMoveMemory", Ptr, pHeap, Ptr, lParam, Ptr, Size), oMem.Push(pHeap)
	SetTimer, Hotkey_HookProcWork, -10
	Return nCode < 0 ? DllCall("CallNextHookEx", "Ptr", 0, "Int", nCode, "UInt", wParam, "UInt", lParam) : 1

	Hotkey_HookProcWork:
		While (oMem[1] != "") {
			If Hotkey_Arr("Hook") {
				Lp := oMem[1]
				VK := Format("{:X}", NumGet(Lp + 0, "UInt"))
				Ext := NumGet(Lp + 0, 8, "UInt")
				SC1 := NumGet(Lp + 0, 4, "UInt")
				NFP := (Ext >> 4) & 1				;  Не физическое нажатие
				KeyUp := Ext >> 7
				; Time := NumGet(Lp + 12, "UInt")
				IsMod := Mods[VK]
				If !SC1
					SC2 := GetKeySC("vk" VK), SC := SC2 = "" ? "" : Format("{:X}", SC2)
				Else
					SC := Format("{:X}", (Ext & 1) << 8 | SC1)
				If !KeyUp
					IsMod ? Hotkey_Main({VK:VK, SC:SC, Opt:"Down", IsMod:IsMod, NFP:NFP, Time:Time, UP:0})
					: Hotkey_Main({VK:VK, SC:SC, NFP:NFP, Time:Time, UP:0})
				Else
					IsMod ? Hotkey_Main({VK:VK, SC:SC, Opt:"Up", IsMod:IsMod, NFP:NFP, Time:Time, UP:1})
					: (Hotkey_Arr("Up") ? Hotkey_Main({VK:VK, SC:SC, NFP:NFP, Time:Time, UP:1}) : 0)
			}
			DllCall("HeapFree", Ptr, hHeap, UInt, 0, Ptr, Lp)
			oMem.RemoveAt(1)
		}
		Return
}

Hotkey_SetHook(On = 1) {
	Static hHook
	If (On = 1 && !hHook)
		hHook := DllCall("SetWindowsHookEx" . (A_IsUnicode ? "W" : "A")
				, "Int", 13   ;  WH_KEYBOARD_LL
				, "Ptr", RegisterCallback("Hotkey_LowLevelKeyboardProc", "Fast")
				, "Ptr", DllCall("GetModuleHandle", "UInt", 0, "Ptr")
				, "UInt", 0, "Ptr")
	Else If (On != 1)
		DllCall("UnhookWindowsHookEx", "Ptr", hHook), hHook := "", Hotkey_Hook(0)
}

GetVKCodeName(id) {  
  ;	https://docs.microsoft.com/en-us/windows/desktop/inputdev/virtual-key-codes
  ;	http://www.kbdedit.com/manual/low_level_vk_list.html

	Static Start, VK_, Chr, Num, Undefined, Reserved, Unassigned, VK_Names
	
	If !Start
	{
		Start := 1 
		VK_ := {01:"VK_LBUTTON",02:"VK_RBUTTON",03:"VK_CANCEL",04:"VK_MBUTTON",05:"VK_XBUTTON1",06:"VK_XBUTTON2",08:"VK_BACK",09:"VK_TAB",0C:"VK_CLEAR",0D:"VK_RETURN",10:"VK_SHIFT"
		,11:"VK_CONTROL",12:"VK_MENU",13:"VK_PAUSE",14:"VK_CAPITAL",15:"VK_KANA := VK_HANGEUL := VK_HANGUL := VK_HANGUEL",17:"VK_JUNJA",18:"VK_FINAL",19:"VK_HANJA := VK_KANJI",1B:"VK_ESCAPE"
		,1C:"VK_CONVERT",1D:"VK_NONCONVERT",1E:"VK_ACCEPT",1F:"VK_MODECHANGE",20:"VK_SPACE",21:"VK_PRIOR",22:"VK_NEXT",23:"VK_END",24:"VK_HOME",25:"VK_LEFT",26:"VK_UP",27:"VK_RIGHT"
		,28:"VK_DOWN",29:"VK_SELECT",2A:"VK_PRINT",2B:"VK_EXECUTE",2C:"VK_SNAPSHOT",2D:"VK_INSERT",2E:"VK_DELETE",2F:"VK_HELP",30:"VK_KEY_0",31:"VK_KEY_1",32:"VK_KEY_2",33:"VK_KEY_3"
		,34:"VK_KEY_4",35:"VK_KEY_5",36:"VK_KEY_6",37:"VK_KEY_7",38:"VK_KEY_8",39:"VK_KEY_9",41:"VK_KEY_A",42:"VK_KEY_B",43:"VK_KEY_C",44:"VK_KEY_D",45:"VK_KEY_E",46:"VK_KEY_F"
		,47:"VK_KEY_G",48:"VK_KEY_H",49:"VK_KEY_I",4A:"VK_KEY_J",4B:"VK_KEY_K",4C:"VK_KEY_L",4D:"VK_KEY_M",4E:"VK_KEY_N",4F:"VK_KEY_O",50:"VK_KEY_P",51:"VK_KEY_Q",52:"VK_KEY_R"
		,53:"VK_KEY_S",54:"VK_KEY_T",55:"VK_KEY_U",56:"VK_KEY_V",57:"VK_KEY_W",58:"VK_KEY_X",59:"VK_KEY_Y",5A:"VK_KEY_Z",5B:"VK_LWIN",5C:"VK_RWIN",5D:"VK_APPS",5F:"VK_SLEEP"
		,60:"VK_NUMPAD0",61:"VK_NUMPAD1",62:"VK_NUMPAD2",63:"VK_NUMPAD3",64:"VK_NUMPAD4",65:"VK_NUMPAD5",66:"VK_NUMPAD6",67:"VK_NUMPAD7",68:"VK_NUMPAD8",69:"VK_NUMPAD9",6A:"VK_MULTIPLY"
		,6B:"VK_ADD",6C:"VK_SEPARATOR",6D:"VK_SUBTRACT",6E:"VK_DECIMAL",6F:"VK_DIVIDE",70:"VK_F1",71:"VK_F2",72:"VK_F3",73:"VK_F4",74:"VK_F5",75:"VK_F6",76:"VK_F7",77:"VK_F8",78:"VK_F9"
		,79:"VK_F10",7A:"VK_F11",7B:"VK_F12",7C:"VK_F13",7D:"VK_F14",7E:"VK_F15",7F:"VK_F16",80:"VK_F17",81:"VK_F18",82:"VK_F19",83:"VK_F20",84:"VK_F21",85:"VK_F22",86:"VK_F23",87:"VK_F24"}
	
		VK__ := {90:"VK_NUMLOCK",91:"VK_SCROLL",92:"VK_OEM_FJ_JISHO := VK_OEM_NEC_EQUAL",93:"VK_OEM_FJ_MASSHOU",94:"VK_OEM_FJ_TOUROKU",95:"VK_OEM_FJ_LOYA",96:"VK_OEM_FJ_ROYA",A0:"VK_LSHIFT",A1:"VK_RSHIFT",A2:"VK_LCONTROL"
		,A3:"VK_RCONTROL",A4:"VK_LMENU",A5:"VK_RMENU",A6:"VK_BROWSER_BACK",A7:"VK_BROWSER_FORWARD",A8:"VK_BROWSER_REFRESH",A9:"VK_BROWSER_STOP",AA:"VK_BROWSER_SEARCH",AB:"VK_BROWSER_FAVORITES"
		,AC:"VK_BROWSER_HOME",AD:"VK_VOLUME_MUTE",AE:"VK_VOLUME_DOWN",AF:"VK_VOLUME_UP",B0:"VK_MEDIA_NEXT_TRACK",B1:"VK_MEDIA_PREV_TRACK",B2:"VK_MEDIA_STOP",B3:"VK_MEDIA_PLAY_PAUSE",B4:"VK_LAUNCH_MAIL"
		,B5:"VK_LAUNCH_MEDIA_SELECT",B6:"VK_LAUNCH_APP1",B7:"VK_LAUNCH_APP2",BA:"VK_OEM_1",BB:"VK_OEM_PLUS",BC:"VK_OEM_COMMA",BD:"VK_OEM_MINUS",BE:"VK_OEM_PERIOD",BF:"VK_OEM_2",C0:"VK_OEM_3",C1:"VK_ABNT_C1",C2:"VK_ABNT_C2",DB:"VK_OEM_4"
		,DC:"VK_OEM_5",DD:"VK_OEM_6",DE:"VK_OEM_7",DF:"VK_OEM_8",E1:"VK_OEM_AX",E2:"VK_OEM_102",E3:"VK_ICO_HELP",E4:"VK_ICO_00",E5:"VK_PROCESSKEY",E6:"VK_ICO_CLEAR",E7:"VK_PACKET",E9:"VK_OEM_RESET"
		,EA:"VK_OEM_JUMP",EB:"VK_OEM_PA1",EC:"VK_OEM_PA2",ED:"VK_OEM_PA3",EE:"VK_OEM_WSCTRL",EF:"VK_OEM_CUSEL",F0:"VK_OEM_ATTN",F1:"VK_OEM_FINISH",F2:"VK_OEM_COPY",F3:"VK_OEM_AUTO",F4:"VK_OEM_ENLW",F5:"VK_OEM_BACKTAB"
		,F6:"VK_ATTN",F7:"VK_CRSEL",F8:"VK_EXSEL",F9:"VK_EREOF",FA:"VK_PLAY",FB:"VK_ZOOM",FC:"VK_NONAME",FD:"VK_PA1",FE:"VK_OEM_CLEAR",FF:"VK__none_"}
	 
		for k, v in VK__
			VK_[k] := v
		VK_Names := {}
		for k, v in VK_
			for a, b in StrSplit(v, ":=", " ")
				VK_Names[b] := k
			 
		Undefined := "07|0E|0F|16|1A|3A|3B|3C|3D|3E|3F|40"
		Reserved := "0A|0B|5E|B8|B9|C3|C4|C5|C6|C7|C8|C9|CA|CB|CC|CD|CE|CF|D0|D1|D2|D3|D4|D5|D6|D7|E0"
		Unassigned := "88|89|8A|8B|8C|8D|8E|8F|97|98|99|9A|9B|9C|9D|9E|9F|D8|D9|DA|E8"
	}
	If (id ~= "i)^vk_") && VK_Names.HasKey(id)
		Return QVK(oDoc.getElementById("edithotkey").value := Format("{:U}", id), "0x" VK_Names[id])  ;	vK_EreOF
		
	If VK := GetKeyVK(id)  
		id := Format("0x{:02X}", VK)
	Else If (id ~= "i)^vk")
		id := "0x" RegExReplace(id, "i)(^vk([0-9a-f]+)).*", "$2")  
		
	If !(InStr(id, "0x") && id > 0 && id < 256)
		Return   ;	"Is not virtual key code" 
	id := Format("{:02X}", id) 
	If VK_[id]
		Return  QVK(VK_[id], "0x" id)  
	If InStr("|" Undefined "|", "|" id "|")
		Return QVK("0x" id " is Undefined", "", 0)
	If InStr("|" Reserved "|", "|" id "|")
		Return QVK("0x" id " is Reserved", "", 0)
	If InStr("|" Unassigned "|", "|" id "|")
		Return QVK("0x" id " is Unassigned", "", 0) 
} 

QVK(key, value, VK = 1) {
	Static S, T, Description1, Description2
	If !S && S := 1 
		T := _T1 "> ( GetKeyVK ) </span>" _T2 "<br>"
		, Description1 := "<span style='color: #" ColorParam "'>Virtual-key code symbolic names:  </span>"
		, Description2 := "<span style='color: #" ColorDelimiter "'>Virtual-key code symbolic names:  </span>"
	If VK
		Return T _PRE1 Description1 "<span><span name='MS:'>" key "</span><span class='param' name='MS:SP'> := " value "</span></span><br>" _PRE2
	Return T _PRE1 Description2 "<span style='color: #C0C0C0'>" key "</span><br>" _PRE2
}

GetScanCode(id) { 
	If SC := GetKeySC(id) 
		Return _T1 "> ( GetKeySC ) </span>" _T2 "<br>" _PRE1 "<span name='MS:'>" Format("0x{:03X}", SC) "</span><br>" _PRE2 
}


	; _________________________________________________ Menu Labels _________________________________________________

ShowSys(x, y) {
ShowSys:
	ZoomMsg(9, 1)
	DllCall("SetTimer", "Ptr", A_ScriptHwnd, "Ptr", 1, "UInt", 116, "Ptr", RegisterCallback("MenuCheck", "Fast"))
	Menu, Sys, Show, % x, % y
	ZoomMsg(9, 0)
	Return
}

MenuCheck()  {
	DllCall("KillTimer", "Ptr", A_ScriptHwnd, "Ptr", 1)
	If !WinExist("ahk_class #32768 ahk_pid " oOther.CurrentProcessId)
		Return
	If GetKeyState("RButton", "P")
	{
		MouseGetPos, , , WinID
		Menu := MenuGetName(GetMenuForMenu(WinID))
		If Menu && (F := oMenu[Menu][oOther.ThisMenuItem := AccUnderMouse(WinID, Id).accName(Id)]) && (F ~= "^_")
		{
			; If !(F ~= "^_") ; Return DllCall("mouse_event", "UInt", 0x0002|0x0004)  ;	WinClose("ahk_class #32768 ahk_pid " oOther.CurrentProcessId), SetTimer(F, -1)
			oOther.MenuItemExist := 1
			If IsLabel(F)
				GoSub, % F
			Else
				%F%()
			oOther.MenuItemExist := 0
		}
		KeyWait, RButton
	}
	DllCall("SetTimer", "Ptr", A_ScriptHwnd, "Ptr", 1, "UInt", 16, "Ptr", RegisterCallback("MenuCheck", "Fast"))
}

GetMenuForMenu(hWnd) {
	SendMessage, 0x1E1, 0, 0, , ahk_id %hWnd%	;  MN_GETHMENU
	hMenu := ErrorLevel
	If (hMenu + 0)
		Return hMenu
}

AccUnderMouse(WinID, ByRef child) {
	Static h
	If Not h
		h := DllCall("LoadLibrary", "Str", "oleacc", "Ptr")
	If DllCall("oleacc\AccessibleObjectFromPoint"
		, "Int64", 0 * DllCall("GetCursorPos", "Int64*", pt) + pt, "Ptr*", pacc
		, "Ptr", VarSetCapacity(varChild, 8 + 2 * A_PtrSize, 0) * 0 + &varChild) = 0
	Acc := ComObjEnwrap(9, pacc, 1)
	If IsObject(Acc)
		Return Acc, child := NumGet(varChild, 8, "UInt")
}

MaxHeightStrToNum()  {
	Return Round(A_ScreenHeight / SubStr(PreMaxHeightStr, 5))
}

_MenuOverflowLabel:
	ThisMenuItem := oOther.MenuItemExist ? oOther.ThisMenuItem : A_ThisMenuItem
	PreOverflowHide := ThisMenuItem = "Switch off" ? 0 : 1
	IniWrite(ThisMenuItem, "MaxHeightOverFlow")
	for k, v in ["Switch off","1 / 1","1 / 2","1 / 3","1 / 4","1 / 5","1 / 6","1 / 8","1 / 10","1 / 15"]
		Menu, Overflow, UnCheck, % v
	Menu, Overflow, Check, % PreMaxHeightStr := ThisMenuItem
	PreMaxHeight := MaxHeightStrToNum()
	_PreOverflowHideCSS := ".lpre {max-width: 99`%; max-height: " PreMaxHeight "px; overflow: auto; border: 1px solid #E2E2E2;}"
	ChangeCSS("css_PreOverflowHide", PreOverflowHide ? _PreOverflowHideCSS : "")
	AnchorScroll()
	Return

_Sys_Backlight:
	ThisMenuItem := oOther.MenuItemExist ? oOther.ThisMenuItem : A_ThisMenuItem
	Menu, Sys, UnCheck, % BLGroup[StateLight]
	Menu, Sys, Check, % ThisMenuItem
	IniWrite((StateLight := InArr(ThisMenuItem, BLGroup)), "StateLight")
	Return

_MemoryAnchor:
	IniWrite(MemoryAnchor := !MemoryAnchor, "MemoryAnchor")
	If MemoryAnchor
		IniWrite(oOther.anchor["Win_text"], "Win_Anchor")
		, IniWrite(oOther.anchor["Control_text"], "Control_Anchor")
	Menu, View, % MemoryAnchor ? "Check" : "UnCheck", Remember anchor
	Return

_DynamicControlPath:
	ThisMenuItem := oOther.MenuItemExist ? oOther.ThisMenuItem : A_ThisMenuItem
	IniWrite(DynamicControlPath := !DynamicControlPath, "DynamicControlPath")
	Menu, View, % DynamicControlPath ? "Check" : "UnCheck", % ThisMenuItem
	Return

_DynamicAccPath:
	ThisMenuItem := oOther.MenuItemExist ? oOther.ThisMenuItem : A_ThisMenuItem
	IniWrite(DynamicAccPath := !DynamicAccPath, "DynamicAccPath")
	Menu, View, % DynamicAccPath ? "Check" : "UnCheck", % ThisMenuItem
	Return

_UseUIA:
	ThisMenuItem := oOther.MenuItemExist ? oOther.ThisMenuItem : A_ThisMenuItem
	IniWrite(UseUIA := !UseUIA, "UseUIA")
	If UseUIA && !IsObject(oUIAInterface)
		oUIAInterface := UIA_Interface()
	Menu, View, % UseUIA ? "Check" : "UnCheck", % ThisMenuItem
	Return

_SelStartMode:
	ThisMenuItem := oOther.MenuItemExist ? oOther.ThisMenuItem : A_ThisMenuItem
	for k, v in ["Window","Control","Button","Last Mode"]
		Menu, Startmode, UnCheck, % v
	IniWrite({"Window":"Win","Control":"Control","Button":"Hotkey","Last Mode":"LastMode"}[ThisMenuItem], "StartMode")
	LastModeSave := (ThisMenuItem = "Last Mode")
	Menu, Startmode, Check, % ThisMenuItem
	Return

_OnlyShiftTab:
	IniWrite(OnlyShiftTab := !OnlyShiftTab, "OnlyShiftTab")
	Menu, Sys, % (OnlyShiftTab ? "Check" : "UnCheck"), Spot only Shift+Tab
	ZoomMsg(12, OnlyShiftTab)
	If !OnlyShiftTab
		Try SetTimer, Loop_%ThisMode%, -100
	If OnlyShiftTab && ActiveNoPause
		GoSub _Active_No_Pause
	Return

_Active_No_Pause:
	ActiveNoPause := IniWrite(!ActiveNoPause, "ActiveNoPause")
	Menu, Sys, % (ActiveNoPause ? "Check" : "UnCheck"), Work with the active window
	ZoomMsg(6, ActiveNoPause)
	If OnlyShiftTab && ActiveNoPause
		GoSub _OnlyShiftTab
	Return

_Suspend:
	isAhkSpy := !isAhkSpy
	Menu, Sys, % !isAhkSpy ? "Check" : "UnCheck", Suspend hotkeys
	ZoomMsg(8, !isAhkSpy)
	Return

_CheckUpdate:
	StateUpdate := IniWrite(!StateUpdate, "StateUpdate")
	Menu, Sys, % (StateUpdate ? "Check" : "UnCheck"), Check updates
	If StateUpdate
		SetTimer, UpdateAhkSpy, -1
	Else
	{
		SetTimer, UpdateAhkSpy, Off
		SetTimer, Upd_Verifi, Off
	}
	Return

_Sys_Acclight:
	StateLightAcc := IniWrite(!StateLightAcc, "StateLightAcc"), HideAccMarker()
	Menu, Sys, % (StateLightAcc ? "Check" : "UnCheck"), Acc object backlight
	Return

_Sys_WClight:
	StateLightMarker := IniWrite(!StateLightMarker, "StateLightMarker"), HideMarker()
	Menu, Sys, % (StateLightMarker ? "Check" : "UnCheck"), Window or control backlight
	Return

_Spot_Together:
	StateAllwaysSpot := IniWrite(!StateAllwaysSpot, "AllwaysSpot")
	Menu, Sys, % (StateAllwaysSpot ? "Check" : "UnCheck"), Spot together (low speed)
	Return

_MemoryPos:
	IniWrite(MemoryPos := !MemoryPos, "MemoryPos")
	Menu, View, % MemoryPos ? "Check" : "UnCheck", Remember position
	SavePos()
	Return

_MemorySize:
	IniWrite(MemorySize := !MemorySize, "MemorySize")
	Menu, View, % MemorySize ? "Check" : "UnCheck", Remember size
	SaveSize()
	Return

_MemoryFontSize:
	IniWrite(MemoryFontSize := !MemoryFontSize, "MemoryFontSize")
	Menu, View, % MemoryFontSize ? "Check" : "UnCheck", Remember font size
	If MemoryFontSize
		IniWrite(FontSize, "FontSize")
	Return

_MemoryZoomSize:
	IniWrite(MemoryZoomSize := !MemoryZoomSize, "MemoryZoomSize")
	Menu, View, % MemoryZoomSize ? "Check" : "UnCheck", Remember zoom size
	ZoomMsg(4, MemoryZoomSize)
	Return

_MoveTitles:
	IniWrite(MoveTitles := !MoveTitles, "MoveTitles")
	Menu, View, % MoveTitles ? "Check" : "UnCheck", Moving titles
	if oJScript.MoveTitles := MoveTitles
		oJScript.shift(0)
	else
		oDocEl.scrollLeft := 0, oJScript.conleft30()
	Return

_ViewStrPos:
	IniWrite(ViewStrPos := !ViewStrPos, "ViewStrPos")
	Menu, View, % ViewStrPos ? "Check" : "UnCheck", View position string for command
	Return

_MemoryStateZoom:
	IniWrite(MemoryStateZoom := !MemoryStateZoom, "MemoryStateZoom")
	Menu, View, % MemoryStateZoom ? "Check" : "UnCheck", Remember state zoom
	IniWrite(oOther.ZoomShow, "ZoomShow")
	Return

_WordWrap:
	IniWrite(WordWrap := !WordWrap, "WordWrap")
	Menu, View, % WordWrap ? "Check" : "UnCheck", Word wrap
	If WordWrap
		oDocEl.scrollLeft := 0
	oJScript.WordWrap := WordWrap
	ChangeCSS("css_Body", WordWrap ? _BodyWrapCSS : "")
	Return

Sys_Help:
	ThisMenuItem := oOther.MenuItemExist ? oOther.ThisMenuItem : A_ThisMenuItem
	If ThisMenuItem = AutoHotKey official help online
		RunPath("http://ahkscript.org/docs/AutoHotkey.htm")
	Else If ThisMenuItem = AutoHotKey russian help online
		RunPath("http://www.script-coding.com/AutoHotkeyTranslation.html")
	Else If ThisMenuItem = About
		RunPath("http://forum.script-coding.com/viewtopic.php?pid=72459#p72459")
	Else If ThisMenuItem = About english
		RunPath("https://www.autohotkey.com/boards/viewtopic.php?f=6&t=52872") 
	Return

LaunchHelp:
	If !FileExist(SubStr(A_AhkPath,1,InStr(A_AhkPath,"\",,0,1)) "AutoHotkey.chm")
		Return
	IfWinNotExist AutoHotkey Help ahk_class HH Parent ahk_exe hh.exe
		Run % SubStr(A_AhkPath,1,InStr(A_AhkPath,"\",,0,1)) "AutoHotkey.chm"
	WinActivate
	Minimize()
	Return

DefaultSize:
	If FullScreenMode
	{
		FullScreenMode()
		Gui, 1: Restore
		Sleep 200
	}
	Gui, 1: Show, % "NA w" widthTB "h" HeightStart
	ZoomMsg(5)
	If !MemoryFontSize
		oDoc.getElementById("pre").style.fontSize := FontSize := 15
	Return

Reload:
	Reload
	Return

Help_OpenUserDir:
	RunPath(Path_User)
	Return

Help_OpenScriptDir:
	SelectFilePath(A_ScriptFullPath)
	Minimize()
	Return

	; _________________________________________________ Functions _________________________________________________

WM_ACTIVATE(wp, lp) {
	Critical
	If isConfirm
		Return
	If ((wp & 0xFFFF = 0) && lp != hGui)  ;	Deactivated
	{
		ZoomMsg(7, 0)
		If Hotkey_Arr("Hook")
			Hotkey_Hook(0)
	}
	Else If (wp & 0xFFFF != 0 && WinActive("ahk_id" hGui)) ;	Activated
	{
		ZoomMsg(7, 1)
		If (ThisMode = "Hotkey" && !isPaused)
			Hotkey_Hook(1)
		If !ActiveNoPause
			HideAllMarkers(), CheckHideMarker()
	}
}

WM_WINDOWPOSCHANGED(Wp, Lp) {
	Static PtrAdd := A_PtrSize = 8 ? 8 : 0
	Critical
	If (NumGet(Lp + 0, 0, "UInt") != hGui) || Sleep = 1
		Return
	If oOther.ZoomShow
	{
		x := NumGet(Lp + 0, 8 + PtrAdd, "UInt")
		y := NumGet(Lp + 0, 12 + PtrAdd, "UInt")
		w := NumGet(Lp + 0, 16 + PtrAdd, "UInt")
		hDWP := DllCall("BeginDeferWindowPos", "Int", 3)
		hDWP := DllCall("DeferWindowPos"
		, "Ptr", hDWP, "Ptr", hGui, "UInt", -1  ;	for +AlwaysOnTop
		, "Int", 0, "Int", 0, "Int", 0, "Int", 0
		, "UInt", 0x0003)    ;  SWP_NOMOVE := 0x0002 | SWP_NOSIZE := 0x0001
		hDWP := DllCall("DeferWindowPos"
		, "Ptr", hDWP, "Ptr", oOther.hZoom, "UInt", 0
		, "Int", x + w, "Int", y, "Int", 0, "Int", 0
		, "UInt", 0x0011)    ; 0x0010 := SWP_NOACTIVATE | 0x0001 := SWP_NOSIZE | SWP_NOOWNERZORDER := 0x0200
		hDWP := DllCall("DeferWindowPos"
		, "Ptr", hDWP, "Ptr", oOther.hZoomLW, "UInt", 0
		, "Int", x + w + 1, "Int", y + 46, "Int", 0, "Int", 0
		, "UInt", 0x0211)    ; 0x0010 := SWP_NOACTIVATE | 0x0001 := SWP_NOSIZE | SWP_NOOWNERZORDER := 0x0200
		DllCall("EndDeferWindowPos", "Ptr", hDWP)
	}
	If MemoryPos
		SetTimer, SavePos, -400
}

GuiSize:
	If A_Gui != 1
		Return
	If A_EventInfo = 1
		ZoomMsg(11, 1)
	Sleep := A_EventInfo  ;	= 1 minimize
	If A_EventInfo != 1
	{
		ControlsMove(A_GuiWidth, A_GuiHeight)
		If MemorySize
			SetTimer, SaveSize, -400
	}
	Else
		HideAllMarkers(), CheckHideMarker()
	Try SetTimer, Loop_%ThisMode%, % A_EventInfo = 1 || isPaused ? "Off" : "On"
	Return

Minimize() {
	Sleep := 1
	Gui, 1: Minimize

}

TimerFunc(hFunc, Time) {
	Try SetTimer, % hFunc, % Time
}

Exit:
GuiClose:
	oDoc := ""
	If LastModeSave
		IniWrite(ThisMode, "LastMode")
	ExitApp

CheckAhkVersion:
	If A_AhkVersion < 1.1.23.00
	{
		MsgBox Requires AutoHotkey_L version 1.1.23.00+
		RunPath("http://ahkscript.org/download/")
		ExitApp
	}
	Return

ChangeMode() {
	Try SetTimer, Loop_%ThisMode%, Off
	HideAllMarkers(), MS_Cancel()
	GoSub % "Mode_" (ThisMode = "Control" ? "Win" : "Control")
}

WM_NCLBUTTONDOWN(wp) {
	Static HTMINBUTTON := 8
	If (wp = HTMINBUTTON)
	{
		SetTimer, Minimize, -10
		Return 0
	}
}

WM_LBUTTONDOWN(wp, lp, msg, hwnd) {
	If (hwnd = hFindGui)
	{
		MouseGetPos, , , , hControl, 2
		If (hControl = hFindAllText)
			SetTimer, FindAll, -250
		Return
	}
	If A_GuiControl = ColorProgress
	{
		If ThisMode = Hotkey
			oDoc.execCommand("Paste"), ToolTip("Paste", 300)
		Else
		{ 
			SendInput {LAlt Down}{Escape}{LAlt Up}
			ToolTip("Alt+Escape", 300)
			ZoomMsg(7, 0)
			If (OnlyShiftTab && !isPaused)
			{
				OnlyShiftTab := 0
				ZoomMsg(12, 0)
				SetTimer, Loop_%ThisMode%, -1
				SetTimer, OnlyShiftTab_LButton_Up_Wait, -1
			}
		}
	}
}

OnlyShiftTab_LButton_Up_Wait:
	KeyWait, LButton
	OnlyShiftTab := 1
	ZoomMsg(12, 1)
	SetTimer, Loop_%ThisMode%, Off
	SetTimer, ShiftUpHide, -300
	return
	
ChildToPath(hwnd, str = "", WinID = 0, i = "")
{
	Static GA_ROOT := 2, GW_HWNDPREV := 3
	If !WinID && hwnd
		WinID := DllCall("GetAncestor", "Ptr", hwnd, Uint, GA_ROOT), i := 1
	While prhwnd := DllCall("GetWindow", "Ptr", hwnd, UInt, GW_HWNDPREV, "Ptr")
		++i, hwnd := prhwnd
	thwnd := DllCall("GetParent", "Ptr", hwnd)
	if !thwnd || (thwnd = WinID)
		return Rtrim(i "," str, ",")
	return ChildToPath(thwnd, i "," str, WinID, 1)
}

ActivateUnderMouse() {
	MouseGetPos, , , WinID
 	WinActivate, ahk_id %WinID%
}

MouseGetPosScreen(ByRef x, ByRef y) {
	VarSetCapacity(POINT, 8, 0)
	NumPut(x, &POINT, 0,"Int")
	NumPut(y, &POINT, 4,"Int")
	DllCall("GetCursorPos", "Ptr", &POINT)
	x := NumGet(POINT, 0, "Int"), y := NumGet(POINT, 4, "Int")
}

WM_MBUTTONUP(wp) {
	If (A_GuiControl = "ColorProgress")
		Return 0, ToolTip("Zoom", 300), AhkSpyZoomShow()
}

WM_CONTEXTMENU() {
	MouseGetPos, , , wid, cid, 2
	If (hColorProgress = cid) {
		Gosub, PausedScript
		ToolTip("Pause", 300)
		Return 0
	}
	Else If (cid != hActiveX && wid = hGui) {
		SetTimer, ShowSys, -1
		Return 0
	}
	Return 1
}

IsTextArea() {
	MouseGetPos, , , , cid, 3
	Return (DllCall("GetParent", Ptr, cid) = hActiveX)
}

ControlsMove(Width, Height) {
	hDWP := DllCall("BeginDeferWindowPos", "Int", isFindView ? 3 : 2)
	hDWP := DllCall("DeferWindowPos"
	, "Ptr", hDWP, "Ptr", hTBGui, "UInt", 0
	, "Int", (Width - widthTB) // 2.2, "Int", 0, "Int", 0, "Int", 0
	, "UInt", 0x0011)    ; 0x0010 := SWP_NOACTIVATE | 0x0001 := SWP_NOSIZE
	hDWP := DllCall("DeferWindowPos"
	, "Ptr", hDWP, "Ptr", hActiveX, "UInt", 0
	, "Int", 0, "Int", HeigtButton
	, "Int", Width, "Int", Height - HeigtButton - (isFindView ? 28 : 0)
	, "UInt", 0x0010)    ; 0x0010 := SWP_NOACTIVATE
	If isFindView
		hDWP := DllCall("DeferWindowPos"
		, "Ptr", hDWP, "Ptr", hFindGui, "UInt", 0
		, "Int", (Width - widthTB) // 2.2, "Int", (Height - (Height < HeigtButton * 2 ? -2 : 27))
		, "Int", 0, "Int", 0
		, "UInt", 0x0011)    ; 0x0010 := SWP_NOACTIVATE | 0x0001 := SWP_NOSIZE
	DllCall("EndDeferWindowPos", "Ptr", hDWP)
}

ZoomSpot() {
	If (!isPaused && Sleep != 1 && WinActive("ahk_id" hGui))
		(ThisMode = "Control" ? (Spot_Control() (StateAllwaysSpot ? Spot_Win() : 0) Write_Control()) : (Spot_Win() (StateAllwaysSpot ? Spot_Control() : 0) Write_Win()))
}

MsgZoom(wParam, lParam) {  ;	получает
	If (wParam = 1)  ;	шаг мыши
		SetTimer, ZoomSpot, -1
	Else If (wParam = 2)  ;	ZoomShow
		oOther.ZoomShow := lParam, (MemoryStateZoom && IniWrite(lParam, "ZoomShow"))
	Else If (wParam = 0)  ;	хэндл окна
		oOther.hZoom := lParam
	Else If (wParam = 3)  ;	хэндл окна LW
		oOther.hZoomLW := lParam
}

ZoomMsg(wParam = -1, lParam = -1) {  ;	отправляет
	If WinExist("AhkSpyZoom ahk_id" oOther.hZoom)
		SendMessage, % MsgAhkSpyZoom, wParam, lParam, , % "ahk_id" oOther.hZoom
}

AhkSpyZoomShow() {
	If !WinExist("ahk_id" oOther.hZoom) {
		Hotkey := ThisMode = "Hotkey"
		Suspend := !isAhkSpy
		If A_IsCompiled
			Run "%A_ScriptFullPath%" "Zoom" "%hGui%" "%ActiveNoPause%" "%isPaused%" "%Suspend%" "%Hotkey%" "%OnlyShiftTab%", , , PID
		Else
			Run "%A_AHKPath%" "%A_ScriptFullPath%" "Zoom" "%hGui%" "%ActiveNoPause%" "%isPaused%" "%Suspend%" "%Hotkey%" "%OnlyShiftTab%", , , PID
		WinWait, % "ahk_pid" PID, , 1
	}
	Else If DllCall("IsWindowVisible", "Ptr", oOther.hZoom)
		ZoomMsg(0)
	Else
		ZoomMsg(1)
}

SavePos() {
	If FullScreenMode || !MemoryPos
		Return
	WinGet, Min, MinMax, ahk_id %hGui%
	If (Min = 0)
	{
		WinGetPos, WinX, WinY, , , ahk_id %hGui%
		IniWrite(WinX, "MemoryPosX"), IniWrite(WinY, "MemoryPosY")
	}
}

SaveSize() {
	If FullScreenMode || !MemorySize
		Return
	WinGet, Min, MinMax, ahk_id %hGui%
	If (Min = 0)
	{
		GetClientPos(hGui, _, _, WinWidth, WinHeight)
		IniWrite(WinWidth, "MemorySizeW"), IniWrite(WinHeight, "MemorySizeH")
	}
}

	;  http://forum.script-coding.com/viewtopic.php?pid=87817#p87817
	;  http://www.autohotkey.com/board/topic/93660-embedded-ie-shellexplorer-render-issues-fix-force-it-to-use-a-newer-render-engine/

FixIE() {
	Key := "Software\Microsoft\Internet Explorer\MAIN"
	. "\FeatureControl\FEATURE_BROWSER_EMULATION", ver := 8000
	If A_IsCompiled
		ExeName := A_ScriptName
	Else
		SplitPath, A_AhkPath, ExeName
	RegRead, value, HKCU, %Key%, %ExeName%
	If (value != ver)
		RegWrite, REG_DWORD, HKCU, %Key%, %ExeName%, %ver%
}

ObjRegisterActive(Object, CLSID, Flags := 0) {
   static cookieJar := {}
   if !CLSID  {
      if (( cookie := cookieJar.Delete(Object) ) != "")
         DllCall("oleaut32\RevokeActiveObject", UInt, cookie, Ptr, 0)
      Return
   }
   if cookieJar[Object]
      throw Exception("Object is already registered", -1)
   VarSetCapacity(_clsid, 16, 0)
   if (hr := DllCall("ole32\CLSIDFromString", WStr, CLSID, Ptr, &_clsid)) < 0
      throw Exception("Invalid CLSID", -1, CLSID)
   hr := DllCall("oleaut32\RegisterActiveObject", Ptr, &Object, Ptr, &_clsid, UInt, Flags, UIntP, cookie, UInt)
   if hr < 0
      throw Exception(format("Error 0x{:x}", hr), -1)
   cookieJar[Object] := cookie
}

CreateGUID()
{
   VarSetCapacity(pguid, 16, 0)
   if !DllCall("ole32.dll\CoCreateGuid", Ptr, &pguid)  {
      size := VarSetCapacity(sguid, (38 << !!A_IsUnicode) + 1, 0)
      if DllCall("ole32.dll\StringFromGUID2", Ptr, &pguid, Ptr, &sguid, UInt, size)
         Return StrGet(&sguid)
   }
}

RunPath(Link, WorkingDir = "", Option = "") {
	Run %Link%, %WorkingDir%, %Option%
	Minimize()
}

RunRealPath(Path) {
	SplitPath, Path, , Dir
	Dir := LTrim(Dir, """")
	While !InStr(FileExist(Dir), "D")
		Dir := SubStr(Dir, 1, -1)
	Run, %Path%, %Dir%
}

RunAhkPath(Path, Param = "") {
	SplitPath, Path, , , Extension
	If Extension = exe
		RunPath(Path)
	Else If (!A_IsCompiled && Extension = "ahk")
		RunPath("""" A_AHKPath """ """ Path """ """ Param """")
}

RunShell(Path) {
	ComObjCreate("WScript.Shell").Exec(Path)
}

ExtraFile(Name, GetNoCompile = 0) {
	If FileExist(Path_User "\" Name ".exe")
		Return Path_User "\" Name ".exe"
	If !A_IsCompiled && FileExist(Path_User "\" Name ".ahk")
		Return Path_User "\" Name ".ahk"
}

ShowMarker(x, y, w, h, b := 4) {
	If !oShowMarkers
		ShowMarkersCreate("oShowMarkers", "E14B30")
	(w < 8 || h < 8) && (b := 2)
	ShowMarkers(oShowMarkers, x, y, w, h, b)
}

ShowAccMarker(x, y, w, h, b := 2) {
	If !oShowAccMarkers
		ShowMarkersCreate("oShowAccMarkers", "26419F")
	ShowMarkers(oShowAccMarkers, x, y, w, h, b)
}

ShowMarkerEx(x, y, w, h, b := 4) {
	If !oShowMarkersEx
		ShowMarkersCreate("oShowMarkersEx", "5DCC3B")
	(w < 8 || h < 8) && (b := 2)
	ShowMarkers(oShowMarkersEx, x, y, w, h, b)
}

HideMarker() {
	HideMarkers(oShowMarkers)
}

HideAccMarker() {
	HideMarkers(oShowAccMarkers)
}

HideMarkerEx() {
	HideMarkers(oShowMarkersEx)
}

HideAllMarkers() {
	HideMarker(), HideAccMarker()
}

ShowMarkers(arr, x, y, w, h, b) {
	hDWP := DllCall("BeginDeferWindowPos", "Int", 4)
	for k, v in [[x, y, b, h],[x, y+h-b, w, b],[x+w-b, y, b, h],[x, y, w, b]]
		{
			hDWP := DllCall("DeferWindowPos"
			, "Ptr", hDWP, "Ptr", arr[k], "UInt", -1  ;	-1 := HWND_TOPMOST
			, "Int", v[1], "Int", v[2], "Int", v[3], "Int", v[4]
			, "UInt", 0x0250)    ; 0x0010 := SWP_NOACTIVATE | 0x0040 := SWP_SHOWWINDOW | SWP_NOOWNERZORDER := 0x0200
		}
	DllCall("EndDeferWindowPos", "Ptr", hDWP)
	ShowMarker := 1
}

HideMarkers(arr) {
	hDWP := DllCall("BeginDeferWindowPos", "Int", 4)
	Loop 4
		hDWP := DllCall("DeferWindowPos"
		, "Ptr", hDWP, "Ptr", arr[A_Index], "UInt", 0
		, "Int", 0, "Int", 0, "Int", 0, "Int", 0
		, "UInt", 0x0083)    ; 0x0080 := SWP_HIDEWINDOW | SWP_NOMOVE := 0x0002 | SWP_NOSIZE := 0x0001
	DllCall("EndDeferWindowPos", "Ptr", hDWP)
	ShowMarker := 0
}

ShowMarkersCreate(arr, color) {
	If !!%arr%
		Return
	S_DefaultGui := A_DefaultGui, %arr% := {}
	loop 4
	{
		Gui, New
		Gui, Margin, 0, 0
		Gui, -DPIScale +HWNDHWND -Caption +Owner +0x40000000 +E0x20 -0x80000000 +E0x08000000 +AlwaysOnTop +ToolWindow
		Gui, Color, %color%
		WinSet, TransParent, 250, ahk_id %HWND%
		%arr%[A_Index] := HWND
		Gui, Show, NA Hide
	}
	Gui, %S_DefaultGui%:Default
}

CheckHideMarker() {
	Static Try
	Try := 0
	SetTimer, __CheckHideMarker, -50
	Return

	__CheckHideMarker:
		If (Sleep = 1 || (WinActive("ahk_id" hGui) && !ActiveNoPause) || isPaused)
			HideAllMarkers()
		If (Try := ++Try > 2 ? 0 : Try)
			SetTimer, __CheckHideMarker, -150
		Return
}

SetEditColor(hwnd, BG, FG) {
	Edits[hwnd] := {BG:BG,FG:FG}
	WM_CTLCOLOREDIT(DllCall("GetDC", "Ptr", hwnd), hwnd)
	DllCall("RedrawWindow", "Ptr", hwnd, "Uint", 0, "Uint", 0, "Uint", 0x1|0x4)
}

WM_CTLCOLOREDIT(wParam, lParam) {
	If !Edits.HasKey(lParam)
		Return 0
	hBrush := DllCall("CreateSolidBrush", UInt, Edits[lParam].BG)
	DllCall("SetTextColor", Ptr, wParam, UInt, Edits[lParam].FG)
	DllCall("SetBkColor", Ptr, wParam, UInt, Edits[lParam].BG)
	DllCall("SetBkMode", Ptr, wParam, UInt, 2)
	Return hBrush
}

InArr(Val, Arr) {
	For k, v in Arr
		If (v == Val)
			Return k
}

TransformHTML(str) {
	Transform, str, HTML, %str%, 3
	StringReplace, str, str, <br>, , 1
	Return str
}

PausedTitleText() {
	Static i := 0, Str := "           Paused..."
 	If !isPaused
		Return i := 0
	i := i > 20 ? 2 : i + 1
	TitleTextP2 := "     " SubStr(Str, i) . SubStr(Str, 1, i - 1)
	TitleText := TitleTextP1 . TitleTextP2
	If !FreezeTitleText
		SendMessage, 0xC, 0, &TitleText, , ahk_id %hGui%
	SetTimer, PausedTitleText, -200
}

TitleText(Text, Time = 1000) {
	FreezeTitleText := 1
	StringReplace, Text, Text, `r`n, % Chr(8629), 1
	StringReplace, Text, Text, %A_Tab%, % "      ", 1
	SendMessage, 0xC, 0, &Text, , ahk_id %hGui%
	SetTimer, TitleShow, -%Time%
}

TitleShow:
	SendMessage, 0xC, 0, &TitleText, , ahk_id %hGui%
	FreezeTitleText := 0
	Return

ClipAdd(Text, AddTip = 0) {
	If ClipAdd_Before
		Clipboard := Text ClipAdd_Delimiter Clipboard
	Else
		Clipboard := Clipboard ClipAdd_Delimiter Text
	If AddTip
		ToolTip("add", 300)
}

ClipPaste() {
 	If oMS.ELSel && (oMS.ELSel.OuterText != "" || MS_Cancel())
		oMS.ELSel.innerHTML := TransformHTML(Clipboard), oMS.ELSel.Name := "MS:"
		, MoveCaretToSelection(0)
	Else
		oDoc.execCommand("Paste")
	ToolTip("paste", 300)
}

CutSelection() {
 	If MS_IsSelection()
		MoveCaretToSelection(0), Clipboard := oMS.ELSel.OuterText
		, oMS.ELSel.OuterText := "", MS_Cancel()
	Else
		oDoc.execCommand("Cut")
	ToolTip("cut", 300)
}

DeleteSelection() {
 	If MS_IsSelection()
		MoveCaretToSelection(0), oMS.ELSel.OuterText := "", MS_Cancel()
	Else
		oDoc.execCommand("Delete")
}

PasteStrSelection(Str) {
 	If MS_IsSelection()
		MoveCaretToSelection(0), oMS.ELSel.OuterText := TransformHTML(Str), MS_Cancel()
	Else
		oDoc.selection.createRange().text := Str
}

PasteTab() {
	TempClipboard := ClipboardAll
	Clipboard := "" A_Tab ""
	oDoc.execCommand("Paste")
	Clipboard := TempClipboard 
}

PasteHTMLSelection(Str) {
 	If MS_IsSelection()
		oMS.ELSel.innerHTML := Str, MoveCaretToSelection(0)
	Else
		oDoc.selection.createRange().pasteHTML(Str)
}

MoveCaretToSelection(start) {
	R := oBody.createTextRange(), R.moveToElementText(oMS.ELSel), R.collapse(start), R.select()
}

GetSelected(ByRef Text, ByRef IsoMS = "") {
	Text := oMS.ELSel.OuterText
 	If (Text != "")
		IsoMS := 1
	Else
		Text := oDoc.selection.createRange().text, IsoMS := 0
	Return (Text != "")
}

CopyCommaParam(Text) {
 	If !(Text ~= "(x|y|w|h|" Chr(178) ")-*\d+")
		Return Text
	Text := RegExReplace(Text, "i)(x|y|w|h|#|\s|" Chr(178) "|" Chr(9642) ")+", " ")
	Text := TRim(Text, " "), Text := RegExReplace(Text, "(\s|,)+", ", ")
	Return Text
}

Add_DP(addN, Items*) {
 	For k, v in Items 
		If v != 
			Ret .= v _DP
	If Ret =
		Return
	Return (addN ? "`n" : "") SubStr(Ret, 1, -StrLen(_DP))
}

	;  http://forum.script-coding.com/viewtopic.php?pid=53516#p53516

; GetCommandLineProc(pid) {
	; ComObjGet("winmgmts:").ExecQuery("Select * from Win32_Process WHERE ProcessId = " pid)._NewEnum.next(X)
	; Return Trim(X.CommandLine)
; }

	;  http://forum.script-coding.com/viewtopic.php?pid=111775#p111775

GetCommandLineProc(PID, ByRef Cmd, ByRef Bit, ByRef IsAdmin) {
	Static PROCESS_QUERY_INFORMATION := 0x400, PROCESS_VM_READ := 0x10, STATUS_SUCCESS := 0

	hProc := DllCall("OpenProcess", UInt, PROCESS_QUERY_INFORMATION|PROCESS_VM_READ, Int, 0, UInt, PID, Ptr)
	if A_Is64bitOS
		DllCall("IsWow64Process", Ptr, hProc, UIntP, IsWow64), Bit := (IsWow64 ? "32" : "64") " bit" _DP
	if (!A_Is64bitOS || IsWow64)
		PtrSize := 4, PtrType := "UInt", pPtr := "UIntP", offsetCMD := 0x40
	else
		PtrSize := 8, PtrType := "Int64", pPtr := "Int64P", offsetCMD := 0x70
	hModule := DllCall("GetModuleHandle", "str", "Ntdll", Ptr)
	if (A_PtrSize < PtrSize) {            ; скрипт 32, целевой процесс 64
		if !QueryInformationProcess := DllCall("GetProcAddress", Ptr, hModule, AStr, "NtWow64QueryInformationProcess64", Ptr)
			failed := "NtWow64QueryInformationProcess64"
		if !ReadProcessMemory := DllCall("GetProcAddress", Ptr, hModule, AStr, "NtWow64ReadVirtualMemory64", Ptr)
			failed := "NtWow64ReadVirtualMemory64"
		info := 0, szPBI := 48, offsetPEB := 8
	}
	else  {
		if !QueryInformationProcess := DllCall("GetProcAddress", Ptr, hModule, AStr, "NtQueryInformationProcess", Ptr)
			failed := "NtQueryInformationProcess"
		ReadProcessMemory := "ReadProcessMemory"
		if (A_PtrSize > PtrSize)            ; скрипт 64, целевой процесс 32
			info := 26, szPBI := 8, offsetPEB := 0
		else                                ; скрипт и целевой процесс одной битности
			info := 0, szPBI := PtrSize * 6, offsetPEB := PtrSize
	}
	if failed  {
		DllCall("CloseHandle", Ptr, hProc)
		Return
	}
	VarSetCapacity(PBI, 48, 0)
	if DllCall(QueryInformationProcess, Ptr, hProc, UInt, info, Ptr, &PBI, UInt, szPBI, UIntP, bytes) != STATUS_SUCCESS  {
		DllCall("CloseHandle", Ptr, hProc)
		Return
	}
	pPEB := NumGet(&PBI + offsetPEB, PtrType)
	DllCall(ReadProcessMemory, Ptr, hProc, PtrType, pPEB + PtrSize * 4, pPtr, pRUPP, PtrType, PtrSize, UIntP, bytes)
	DllCall(ReadProcessMemory, Ptr, hProc, PtrType, pRUPP + offsetCMD, UShortP, szCMD, PtrType, 2, UIntP, bytes)
	DllCall(ReadProcessMemory, Ptr, hProc, PtrType, pRUPP + offsetCMD + PtrSize, pPtr, pCMD, PtrType, PtrSize, UIntP, bytes)
	VarSetCapacity(buff, szCMD, 0)
	DllCall(ReadProcessMemory, Ptr, hProc, PtrType, pCMD, Ptr, &buff, PtrType, szCMD, UIntP, bytes)
	Cmd := StrGet(&buff, "UTF-16")

	DllCall("advapi32\OpenProcessToken", "ptr", hProc, "uint", 0x0008, "ptr*", hToken)
	DllCall("advapi32\GetTokenInformation", "ptr", hToken, "int", 20, "uint*", IsAdmin, "uint", 4, "uint*", size)
	DllCall("CloseHandle", "ptr", hToken)
	IsAdmin := (IsAdmin ? "Admin" _DP : "")

	DllCall("CloseHandle", Ptr, hProc)
}

SeDebugPrivilege() {
	Static PROCESS_QUERY_INFORMATION := 0x400, TOKEN_ADJUST_PRIVILEGES := 0x20, SE_PRIVILEGE_ENABLED := 0x2

	hProc := DllCall("OpenProcess", UInt, PROCESS_QUERY_INFORMATION, Int, false, UInt, oOther.CurrentProcessId, Ptr)
	DllCall("Advapi32\OpenProcessToken", Ptr, hProc, UInt, TOKEN_ADJUST_PRIVILEGES, PtrP, token)
	DllCall("Advapi32\LookupPrivilegeValue", Ptr, 0, Str, "SeDebugPrivilege", Int64P, luid)
	VarSetCapacity(TOKEN_PRIVILEGES, 16, 0)
	NumPut(1, TOKEN_PRIVILEGES, "UInt")
	NumPut(luid, TOKEN_PRIVILEGES, 4, "Int64")
	NumPut(SE_PRIVILEGE_ENABLED, TOKEN_PRIVILEGES, 12, "UInt")
	DllCall("Advapi32\AdjustTokenPrivileges", Ptr, token, Int, false, Ptr, &TOKEN_PRIVILEGES, UInt, 0, Ptr, 0, Ptr, 0)
	res := A_LastError
	DllCall("CloseHandle", Ptr, token)
	DllCall("CloseHandle", Ptr, hProc)
	Return res  ; в случае удачи 0
}

	;  http://www.autohotkey.com/board/topic/69254-func-api-getwindowinfo-ahk-l/#entry438372

GetClientPos(hwnd, ByRef left, ByRef top, ByRef w, ByRef h) {
	Static _ := VarSetCapacity(pwi, 60, 0)
	DllCall("GetWindowInfo", "Ptr", hwnd, "Ptr", &pwi)
	left := NumGet(pwi, 20, "Int") - NumGet(pwi, 4, "Int")
	top := NumGet(pwi, 24, "Int") - NumGet(pwi, 8, "Int")
	w := NumGet(pwi, 28, "Int") - NumGet(pwi, 20, "Int")
	h := NumGet(pwi, 32, "Int") - NumGet(pwi, 24, "Int")
}

	;  http://forum.script-coding.com/viewtopic.php?pid=81833#p81833

SelectFilePath(FilePath) {
	If !FileExist(FilePath)
		Return
	SplitPath, FilePath,, Dir
	for window in ComObjCreate("Shell.Application").Windows  {
		ShellFolderView := window.Document
		Try If ((Folder := ShellFolderView.Folder).Self.Path != Dir)
			Continue
		Catch
			Continue
		for item in Folder.Items  {
			If (item.Path != FilePath)
				Continue
			ShellFolderView.SelectItem(item, 1|4|8|16)
			WinActivate, % "ahk_id" window.hwnd
			Return
		}
	}
	Run, %A_WinDir%\explorer.exe /select`, "%FilePath%", , UseErrorLevel
}

GetCLSIDExplorer(hwnd) {
	for window in ComObjCreate("Shell.Application").Windows
		If (window.hwnd = hwnd)
			Return (CLSID := window.Document.Folder.Self.Path) ~= "^::\{" ? "`n<span class='param'>CLSID: </span><span name='MS:'>" CLSID "</span>": ""
}

ChangeLocal(hWnd) {
	Static WM_INPUTLANGCHANGEREQUEST := 0x0050, INPUTLANGCHANGE_FORWARD := 0x0002
	SendMessage, WM_INPUTLANGCHANGEREQUEST, INPUTLANGCHANGE_FORWARD, , , % "ahk_id" hWnd
}

GetLangName(hWnd) {
	Static LOCALE_SENGLANGUAGE := 0x1001
	Locale := DllCall("GetKeyboardLayout", Ptr, DllCall("GetWindowThreadProcessId", Ptr, hWnd, UInt, 0, Ptr), Ptr) & 0xFFFF
	Size := DllCall("GetLocaleInfo", UInt, Locale, UInt, LOCALE_SENGLANGUAGE, UInt, 0, UInt, 0) * 2
	VarSetCapacity(lpLCData, Size, 0)
	DllCall("GetLocaleInfo", UInt, Locale, UInt, LOCALE_SENGLANGUAGE, Str, lpLCData, UInt, Size)
	Return lpLCData
}

ConfirmAction(Action) {
	If !WinActive("ahk_id" hGui) || GetKeyState("Shift", "P")
		Return
	If (!isPaused && bool := 1)
		Gosub, PausedScript
	isConfirm := 1
	bool2 := MsgConfirm(Action, "AhkSpy", hGui)
	isConfirm := 0
	If bool
		Gosub, PausedScript
	If !bool2
		Exit
	Return 1
}

MsgConfirm(Info, Title, hWnd) {
	Static IsStart, hMsgBox, Text, Yes, No, WinW, WinH
	If !IsStart && (IsStart := 1) {
		Gui, MsgBox:+HWNDhMsgBox -DPIScale -SysMenu +Owner%hWnd% +AlwaysOnTop
		Gui, MsgBox:Font, % "s" (A_ScreenDPI = 120 ? 10 : 12)
		Gui, MsgBox:Color, FFFFFF
		Gui, MsgBox:Add, Text, w200 vText r1 Center
		Gui, MsgBox:Font
		Gui, MsgBox:Add, Button, w88 vYes xp+4 y+20 gMsgBoxLabel, Yes
		Gui, MsgBox:Add, Button, w88 vNo x+20 gMsgBoxLabel, No
		Gui, MsgBox:Show, Hide NA
		Gui, MsgBox:Show, Hide AutoSize
		WinGetPos, , , WinW, WinH, ahk_id %hMsgBox%
	}
	Gui, MsgBox:+Owner%hWnd% +AlwaysOnTop
	Gui, %hWnd%:+Disabled
	GuiControl, MsgBox:Text, Text, % Info
	CoordMode, Mouse
	MouseGetPos, X, Y
	x := X - (WinW / 2)
	y := Y - WinH - 10
	Gui, MsgBox: Show, NA Hide x%x% y%y%, % Title
	Gui, MsgBox: Show, x%x% y%y%, % Title
	GuiControl, MsgBox:+Default, No
	GuiControl, MsgBox:Focus, No
	While (RetValue = "")
		Sleep 30
	Gui, %hWnd%:-Disabled
	Gui, MsgBox: Show, Hide
	Return RetValue

	MsgBoxLabel:
		RetValue := {Yes:1,No:0}[A_GuiControl]
		Return
}

MouseStep(x, y) {
	MouseMove, x, y, 0, R
	If (WinActive("ahk_id" hGui) && !ActiveNoPause) || OnlyShiftTab
	{
		(ThisMode = "Control" ? (Spot_Control() (StateAllwaysSpot ? Spot_Win() : 0) Write_Control()) : (Spot_Win() (StateAllwaysSpot ? Spot_Control() : 0) Write_Win()))
		If DllCall("IsWindowVisible", "Ptr", oOther.hZoom)
			ZoomMsg(3)
	}
	Shift_Tab_Down := 1
}

IsIEFocus() {
	If !WinActive("ahk_id" hGui)
		Return 0
	ControlGetFocus, Focus
	Return InStr(Focus, "Internet")
}

NextLink(s = "") {
	curpos := oDocEl.scrollTop, oDocEl.scrollLeft := 0
	If (!curpos && s = "-")
		Return
	While (pos := oDoc.getElementsByTagName("a").item(A_Index-1).getBoundingClientRect().top) != ""
		(s 1) * pos > 0 && (!res || abs(res) > abs(pos)) ? res := pos : ""       ; http://forum.script-coding.com/viewtopic.php?pid=82360#p82360
	If (res = "" && s = "")
		Return
	st := !res ? -curpos : res, co := abs(st) > 150 ? 20 : 10
	Loop % co
		oDocEl.scrollTop := curpos + (st*(A_Index/co))
	oDocEl.scrollTop := curpos + res
}

AnchorBefore(HTML) {
	Static T1
	If !T1
		T1 := SubStr(_T1, 54)
	N := " id='" oOther.anchor[ThisMode "_text"] "'"
	Return StrReplace(HTML, T1 N, " id = 'anchor' " T1 N, , 1)
}

AnchorScroll() {
	EL := oDoc.getElementById("anchor")
	If !EL
		Return
	oDocEl.scrollTop := oDocEl.scrollTop + EL.getBoundingClientRect().top - 6
}

TaskbarProgress(state, hwnd, pct = "") {
	static tbl
	if !tbl {
		try tbl := ComObjCreate("{56FDF344-FD6D-11d0-958A-006097C9A090}", "{ea1afb91-9e28-4b86-90e9-9e9f8a5eefaf}")
		catch
			tbl := "error"
	}
	if tbl = error
		Return
	DllCall(NumGet(NumGet(tbl+0)+10*A_PtrSize), "ptr", tbl, "ptr", hwnd, "uint", state)
	if pct !=
		DllCall(NumGet(NumGet(tbl+0)+9*A_PtrSize), "ptr", tbl, "ptr", hwnd, "int64", pct, "int64", 100)
}

HighLight(elem, time = "", RemoveFormat = 1) {
	If (elem.OuterText = "")
		Return
	Try SetTimer, UnHighLight, % "-" time
	R := oBody.createTextRange()
	(RemoveFormat ? R.execCommand("RemoveFormat") : 0)
	R.collapse(1), R.select()
	R.moveToElementText(elem)
	R.execCommand("ForeColor", 0, "FFFFFF")
	R.execCommand("BackColor", 0, "3399FF")
	Return

	UnHighLight:
		oBody.createTextRange().execCommand("RemoveFormat")
		Return
}

FlashArea(x, y, w, h, att = 1) {
	Static hFunc, max := 6
	If (att = 1)
		Try SetTimer, % hFunc, Off
	Mod(att, 2) ? ShowMarkerEx(x, y, w, h, 5) : HideMarkerEx()
	If (att = max)
		Return
	hFunc := Func("FlashArea").Bind(x, y, w, h, ++att)
	SetTimer, % hFunc, -100
}

	; _________________________________________________ Command as function _________________________________________________

IniRead(Key, Error := " ") {
	IniRead, Value, %A_AppData%\AhkSpy\Settings.ini, AhkSpy, %Key%, %Error%
	If (Value = "" && Error != " ")
		Value := Error
	Return Value
}

IniWrite(Value, Key) {
	IniWrite, %Value%, %A_AppData%\AhkSpy\Settings.ini, AhkSpy, %Key%
	Return Value
}

WinClose(title) {
	WinClose % title
}

Sleep(time) {
	Sleep time
}

SendInput(key) {
	SendInput % key
}

SetTimer(funcorlabel, time) {
	SetTimer, % funcorlabel, % time
}

ToolTip(text, time = 500) {
	CoordMode, Mouse
	CoordMode, ToolTip
	MouseGetPos, X, Y
	ToolTip, %text%, X-10, Y-45
	SetTimer, HideToolTip, -%time%
	Return 1

	HideToolTip:
		ToolTip
		Return
}

	; _________________________________________________ Update _________________________________________________

UpdateAhkSpy(in = 1) {
	Static att, Ver, req
		, url1 := "https://raw.githubusercontent.com/serzh82saratov/AhkSpy/master/Readme.txt"
		, url2 := "https://raw.githubusercontent.com/serzh82saratov/AhkSpy/master/AhkSpy.ahk"

	If !req
		req := ComObjCreate("WinHttp.WinHttpRequest.5.1"), req.Option(6) := 0
	req.open("GET", url%in%, 1), req.send(), att := 0
	SetTimer, Upd_Verifi, -3000
	Return

	Upd_Verifi:
		If (Status := req.Status) = 200
		{
			Text := req.responseText
			If (req.Option(1) = url1)
				Return (Ver := RegExReplace(Text, "i).*?version\s*(.*?)\R.*", "$1")) > AhkSpyVersion ? UpdateAhkSpy(2) : 0
			If (!InStr(Text, "AhkSpyVersion"))
				Return
			HideAllMarkers()
			If InStr(FileExist(A_ScriptFullPath), "R")
			{
				MsgBox, % 16+262144+8192, AhkSpy, Exist new version %Ver%!`n`nBut the file has an attribute "READONLY".`nUpdate imposible.
				Return
			}
			MsgBox, % 4+32+262144+8192, AhkSpy, Exist new version!`nUpdate v%AhkSpyVersion% to v%Ver%?
			IfMsgBox, No
				Return
			File := FileOpen(A_ScriptFullPath, "w", "UTF-8")
			File.Length := 0, File.Write(Text), File.Close()
			Reload
		}
		Error := (++att = 20 || Status != "")
		SetTimer, % Error ? "UpdateAhkSpy" : "Upd_Verifi", % Error ? -60000 : -3000
		Return
}

UpdRegister() {
	Static req, att := 0
	req := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	req.open("post", UpdRegisterLink, 1), req.send()
	SetTimer, UpdRegister_Verifi, -2000
	Return

	UpdRegister_Verifi:
		++att
		If (req.Status = 200)
			IniWrite(1, "UpdRegister2")
		Else If (att <= 3)
			SetTimer, UpdRegister_Verifi, -2000
		Return
}

	; _________________________________________________ WindowStyles _________________________________________________

ViewStylesWin(elem) {  ;
	elem.innerText := !(w_ShowStyles := !w_ShowStyles) ? " show styles " : " hide styles "
	IniWrite(w_ShowStyles, "w_ShowStyles")

	If w_ShowStyles
		Styles := "<a></a>" GetStyles(oOther.WinClass
			, oDoc.getElementById("w_Style").innerText
			, oDoc.getElementById("w_ExStyle").innerText
			, oOther.WinID)

	oDoc.getElementById("WinStyles").innerHTML := Styles
	HTML_Win := oBody.innerHTML
}

ViewStylesControl(elem) {
	elem.innerText := !(c_ShowStyles := !c_ShowStyles) ? " show styles " : " hide styles "
	IniWrite(c_ShowStyles, "c_ShowStyles")
	If c_ShowStyles
		Styles := "<a></a>" GetStyles(oOther.CtrlClass
			, oDoc.getElementById("c_Style").innerText
			, oDoc.getElementById("c_ExStyle").innerText
			, oOther.ControlID)
			
	oDoc.getElementById("ControlStyles").innerHTML := Styles
	HTML_Control := oBody.innerHTML
} 

GetStyles(Class, Style, ExStyle, hWnd, IsChild = 0, IsChildInfoExist = 0) {
	;	http://msdn.microsoft.com/en-us/library/windows/desktop/ms632600(v=vs.85).aspx			Styles
	;	http://msdn.microsoft.com/en-us/library/windows/desktop/ff700543(v=vs.85).aspx			ExStyles
	;	https://www.autohotkey.com/boards/viewtopic.php?p=25880#p25880							Forum Constants
	;	https://github.com/AHK-just-me/AHK_Gui_Constants/tree/master/Sources			GitHub Constants
	
	;	http://www.frolov-lib.ru/books/bsp/v11/ch3_2.htm   русский фак по стилям
	;	https://github.com/strobejb/winspy/blob/master/src/DisplayStyleInfo.c			Логика WinSpy++
	;	http://forum.script-coding.com/viewtopic.php?pid=130846#p130846
	
	Static Styles, ExStyles, ClassStyles, DlgStyles, ToolTipStyles, GCL_STYLE := -26
	
	If !hWnd
		Return
	If !Styles
		Styles := {"WS_BORDER":"0x00800000", "WS_SYSMENU":"0x00080000"
		, "WS_CLIPCHILDREN":"0x02000000", "WS_CLIPSIBLINGS":"0x04000000", "WS_DISABLED":"0x08000000"
		, "WS_HSCROLL":"0x00100000", "WS_MAXIMIZE":"0x01000000"
		, "WS_VISIBLE":"0x10000000", "WS_VSCROLL":"0x00200000"}

		, ExStyles := {"WS_EX_ACCEPTFILES":"0x00000010", "WS_EX_APPWINDOW":"0x00040000", "WS_EX_CLIENTEDGE":"0x00000200"
		, "WS_EX_CONTROLPARENT":"0x00010000", "WS_EX_DLGMODALFRAME":"0x00000001", "WS_EX_LAYOUTRTL":"0x00400000"
		, "WS_EX_LEFTSCROLLBAR":"0x00004000", "WS_EX_WINDOWEDGE":"0x00000100"
		, "WS_EX_MDICHILD":"0x00000040", "WS_EX_NOACTIVATE":"0x08000000", "WS_EX_NOINHERITLAYOUT":"0x00100000"
		, "WS_EX_NOPARENTNOTIFY":"0x00000004", "WS_EX_NOREDIRECTIONBITMAP":"0x00200000", "WS_EX_RIGHT":"0x00001000"
		, "WS_EX_RTLREADING":"0x00002000", "WS_EX_STATICEDGE":"0x00020000"
		, "WS_EX_TOOLWINDOW":"0x00000080", "WS_EX_TOPMOST":"0x00000008", "WS_EX_TRANSPARENT":"0x00000020"}

		, ClassStyles := {"CS_BYTEALIGNCLIENT":"0x00001000", "CS_BYTEALIGNWINDOW":"0x00002000", "CS_CLASSDC":"0x00000040", "CS_IME":"0x00010000"
		, "CS_DBLCLKS":"0x00000008", "CS_DROPSHADOW":"0x00020000", "CS_GLOBALCLASS":"0x00004000", "CS_HREDRAW":"0x00000002"
		, "CS_NOCLOSE":"0x00000200", "CS_OWNDC":"0x00000020", "CS_PARENTDC":"0x00000080", "CS_SAVEBITS":"0x00000800", "CS_VREDRAW":"0x00000001"}
	
	orStyle := Style
	Style := sStyle := Style & 0xffff0000

	IF (Style & 0x00C00000) = 0x00C00000  && (WS_CAPTION := 1, WS_BORDER := 1, Style -= 0x00C00000)  ;	WS_CAPTION && WS_BORDER 
		Ret .= QStyle("WS_CAPTION", "0x00C00000") QStyle("WS_BORDER", "0x00800000") 
		
	IF !WS_CAPTION && (Style & 0x00400000) && (WS_DLGFRAME := 1, Style -= 0x00400000)  ;	WS_DLGFRAME 
		Ret .= QStyle("WS_DLGFRAME", "0x00400000", "!(WS_CAPTION)")
		
	For K, V In Styles
		If (Style & V) = V && (%K% := 1, Style -= V) 
			Ret .= QStyle(K, V)
 
	IF (Style & 0x00040000) && (WS_SIZEBOX := 1, WS_THICKFRAME := 1, Style -= 0x00040000)  ;	WS_SIZEBOX := WS_THICKFRAME 
		Ret .= QStyle("WS_SIZEBOX := WS_THICKFRAME", "0x00040000")

	IF (Style & 0x40000000) && (WS_CHILD := 1, Style -= 0x40000000)  ;	WS_CHILD := WS_CHILDWINDOW := 0x40000000
		Ret .= QStyle("WS_CHILD := WS_CHILDWINDOW", "0x40000000") 
		
	IF (Style & 0x00010000) && WS_CHILD && (WS_TABSTOP := 1, Style -= 0x00010000)  ;	WS_TABSTOP
		Ret .= QStyle("WS_TABSTOP", "0x00010000", "(WS_CHILD)") 
		
	IF (Style & 0x00020000) && WS_CHILD && (WS_GROUP := 1, Style -= 0x00020000)  ;	WS_GROUP
		Ret .= QStyle("WS_GROUP", "0x00020000", "(WS_CHILD)")  

	IF (Style & 0x20000000) && (WS_MINIMIZE := 1, Style -= 0x20000000)  ;	WS_MINIMIZE := WS_ICONIC
		Ret .= QStyle("WS_MINIMIZE := WS_ICONIC", "0x20000000")   

	IF (Style & 0x80000000) && !WS_CHILD && (WS_POPUP := 1, Style -= 0x80000000)  ;	WS_POPUP
		Ret .= QStyle("WS_POPUP", "0x80000000", "!(WS_CHILD)")  

	IF (WS_POPUP && WS_BORDER && WS_SYSMENU) && (WS_POPUPWINDOW := 1)  ;	WS_POPUPWINDOW
		Ret .= QStyle("WS_POPUPWINDOW", "0x80880000", "(WS_POPUP | WS_BORDER | WS_SYSMENU)")

	IF !WS_POPUP && !WS_CHILD && WS_BORDER && WS_CAPTION && (WS_OVERLAPPED := 1)  ;	WS_OVERLAPPED := WS_TILED
		Ret .= QStyle("WS_OVERLAPPED := WS_TILED", "0x00000000", "(WS_BORDER | WS_CAPTION) & !(WS_POPUP | WS_CHILD)")

	IF WS_SYSMENU && (sStyle & 0x00020000) && (WS_MINIMIZEBOX := 1, (Style & 0x00020000) && (Style -= 0x00020000))  ;	WS_MINIMIZEBOX
		Ret .= QStyle("WS_MINIMIZEBOX", "0x00020000", "(WS_SYSMENU)") 

	IF WS_SYSMENU && (sStyle & 0x00010000) && (WS_MAXIMIZEBOX := 1)  ;	WS_MAXIMIZEBOX
		Ret .= QStyle("WS_MAXIMIZEBOX", "0x00010000", "(WS_SYSMENU)")

	If (WS_OVERLAPPED && WS_SIZEBOX && WS_SYSMENU && WS_MINIMIZEBOX && WS_MAXIMIZEBOX)  ;	WS_OVERLAPPEDWINDOW := WS_TILEDWINDOW
		Ret .= QStyle("WS_OVERLAPPEDWINDOW := WS_TILEDWINDOW", "0x00CF0000", "(WS_OVERLAPPED | WS_SIZEBOX | WS_SYSMENU | WS_MINIMIZEBOX | WS_MAXIMIZEBOX)") 

	If IsFunc("GetStyle_" Class)
		ChildStyles := GetStyle_%Class%(orStyle, hWnd, ChildExStyles)
				
	sExStyle := ExStyle
	For K, V In ExStyles
		If (ExStyle & V) && (%K% := 1, ExStyle -= V)
			RetEx .= QStyle(K, V)  

	IF !CS_OWNDC && !CS_CLASSDC && (ExStyle & 0x02000000) && (1, ExStyle -= 0x02000000)  ;	WS_EX_COMPOSITED
		RetEx .= QStyle("WS_EX_COMPOSITED", "0x02000000", "!(CS_OWNDC | CS_CLASSDC)")  

	IF !WS_MAXIMIZEBOX && !WS_MINIMIZEBOX && (ExStyle & 0x00000400) && (1, ExStyle -= 0x00000400)  ;	WS_EX_CONTEXTHELP
		RetEx .= QStyle("WS_EX_CONTEXTHELP", "0x00000400", "!(WS_MAXIMIZEBOX | WS_MINIMIZEBOX)")   
		
	IF !CS_OWNDC && !CS_CLASSDC && (ExStyle & 0x00080000) && (1, ExStyle -= 0x00080000)  ;	WS_EX_LAYERED
		RetEx .= QStyle("WS_EX_LAYERED", "0x00080000", "!(CS_OWNDC | CS_CLASSDC)")   

	IF !WS_EX_RIGHT  ;	WS_EX_LEFT
		RetEx .= QStyle("WS_EX_LEFT", "0x00000000", "!(WS_EX_RIGHT)")    

	IF !WS_EX_LEFTSCROLLBAR  ;	WS_EX_RIGHTSCROLLBAR
		RetEx .= QStyle("WS_EX_RIGHTSCROLLBAR", "0x00000000", "!(WS_EX_LEFTSCROLLBAR)")     

	IF !WS_EX_RTLREADING  ;	WS_EX_LTRREADING
		RetEx .= QStyle("WS_EX_LTRREADING", "0x00000000", "!(WS_EX_RTLREADING)")      

	IF WS_EX_WINDOWEDGE && WS_EX_CLIENTEDGE  ;	WS_EX_OVERLAPPEDWINDOW
		RetEx .= QStyle("WS_EX_OVERLAPPEDWINDOW", "0x00000300", "(WS_EX_WINDOWEDGE | WS_EX_CLIENTEDGE)")       

	IF WS_EX_WINDOWEDGE && WS_EX_TOOLWINDOW && WS_EX_TOPMOST  ;	WS_EX_PALETTEWINDOW 
		RetEx .= QStyle("WS_EX_PALETTEWINDOW", "0x00000188", "(WS_EX_WINDOWEDGE | WS_EX_TOOLWINDOW | WS_EX_TOPMOST)")
 
	IF Style
		Ret .= QStyleRest(8, Style) 
	If Ret !=
		Res .= _T1 " id='__Styles_Win'>" QStyleTitle("Styles", "", 4, sStyle) "</span>" _T2 _PRE1 Ret _PRE2  
	Res .= ChildStyles
	IF ExStyle
		RetEx .= QStyleRest(8, ExStyle)  
	If RetEx !=
		Res .= _T1 " id='__ExStyles_Win'>" QStyleTitle("ExStyles", "", 8, sExStyle) "</span>" _T2 _PRE1 RetEx _PRE2 
	Res .= ChildExStyles 
		
	StyleBits := DllCall("GetClassLong", "Ptr", hWnd, "int", GCL_STYLE)	;  https://docs.microsoft.com/en-us/windows/desktop/api/winuser/nf-winuser-setclasslongw
	For K, V In ClassStyles
		If (StyleBits & V) && (%K% := 1)
				RetClass .= QStyle(K, V) 
	
	If RetClass !=
		Res .= _T1 " id='__ClassStyles_Win'>" QStyleTitle("Class Styles", "", 8, StyleBits) "</span>" _T2 _PRE1 RetClass _PRE2

	Return Res
}

QStyleTitle(Title, Name, F, V) {
	If Name !=
		Return " ( " Title " - <span name='MS:' style='color: #" ColorParam ";'>" Name "</span>: <span name='MS:' style='color: #" ColorFont ";'>" Format("0x{:0" F "X}", V) "</span> ) " 
	Return " ( " Title ": <span name='MS:' style='color: #" ColorFont ";'>" Format("0x{:0" F "X}", V) "</span> ) "  
}
QStyleRest(F, V) {
	Return "<span style='color: #" ColorDelimiter ";' name='MS:'>" Format("0x{1:0" F "X}", V) "</span>`n"
}
QStyle(k, v, q = "") {
	Return "<span name='MS:Q'>" k " := <span class='param' name='MS:'>" v "</span></span>" . (q != "" ? _StIf q "</span>`n" : "`n")
}
	; _________________________________________________ ControlStyles _________________________________________________

/*
	Added:
	Button, Edit, Static, SysListView32, SysTabControl32, SysDateTimePick32, SysMonthCal32, ComboBox, ListBox
	, msctls_trackbar32, msctls_statusbar32, msctls_progress32, msctls_updown32, SysLink, SysHeader32
	, ToolbarWindow32, SysTreeView32, ReBarWindow32, SysAnimate32, SysPager, #32770, tooltips_class32
*/  
	
GetStyle_#32770(Style, hWnd)  {
	;	https://docs.microsoft.com/en-us/windows/desktop/dlgbox/dialog-box-styles
	Static oStyles
	If !oStyles
		oStyles := {"DS_3DLOOK":"0x00000004","DS_ABSALIGN":"0x00000001","DS_CENTER":"0x00000800","DS_CENTERMOUSE":"0x00001000","DS_CONTEXTHELP":"0x00002000"
		,"DS_CONTROL":"0x00000400","DS_FIXEDSYS":"0x00000008","DS_LOCALEDIT":"0x00000020","DS_MODALFRAME":"0x00000080","DS_NOFAILCREATE":"0x00000010"
		,"DS_NOIDLEMSG":"0x00000100","DS_SETFONT":"0x00000040","DS_SETFOREGROUND":"0x00000200","DS_SHELLFONT":"0x00000048","DS_SYSMODAL":"0x00000002"}

	Style := sStyle := Style & 0xffff
	For K, V In oStyles
		If ((Style & V) = V) && (1, Style -= V)
			Ret .= QStyle(K, V)   
	IF Style
		Ret .= GetStyle_CommonСontrol(Style, Style)
	IF Style
		Ret .= QStyleRest(4, Style)
	If Ret !=
		Res .= _T1 " id='__Styles_Control'>" QStyleTitle("Styles", "#32770", 4, sStyle) "</span>" _T2 _PRE1 Ret _PRE2
	
	Return Res
}


GetStyle_tooltips_class32(Style, hWnd)  {
	;	https://docs.microsoft.com/en-us/windows/desktop/controls/tooltip-styles
	Static oStyles
	If !oStyles
		oStyles := {"TTS_ALWAYSTIP":"0x00000001","TTS_BALLOON":"0x00000040","TTS_CLOSE":"0x00000080","TTS_NOANIMATE":"0x00000010","TTS_NOFADE":"0x00000020"
		,"TTS_NOPREFIX":"0x00000002","TTS_USEVISUALSTYLE":"0x00000100"}

	Style := sStyle := Style & 0xffff
	For K, V In oStyles
		If ((Style & V) = V) && (1, Style -= V)
			Ret .= QStyle(K, V)   
	IF Style
		Ret .= GetStyle_CommonСontrol(Style, Style)
	IF Style
		Ret .= QStyleRest(4, Style)
	If Ret !=
		Res .= _T1 " id='__Styles_Control'>" QStyleTitle("Styles", "tooltips_class32", 4, sStyle) "</span>" _T2 _PRE1 Ret _PRE2
	
	Return Res
}



GetStyle_Static(Style, hWnd)  {
	;	https://www.autohotkey.com/boards/viewtopic.php?p=25869#p25869
	;	https://docs.microsoft.com/en-us/windows/desktop/controls/static-control-styles
	Static oStyles, oEx
	If !oStyles
		oStyles := {"SS_ELLIPSISMASK":"0xC000"
		,"SS_REALSIZECONTROL":"0x0040","SS_NOPREFIX":"0x0080","SS_NOTIFY":"0x0100","SS_CENTERIMAGE":"0x0200","SS_RIGHTJUST":"0x0400"
		,"SS_REALSIZEIMAGE":"0x0800","SS_SUNKEN":"0x1000","SS_EDITCONTROL":"0x2000","SS_ENDELLIPSIS":"0x4000","SS_PATHELLIPSIS":"0x8000"
		,"SS_WORDELLIPSIS":"0xC000"}

		, oEx := {"SS_CENTER":"0x0001","SS_RIGHT":"0x0002","SS_ICON":"0x0003","SS_BLACKRECT":"0x0004"
		,"SS_GRAYRECT":"0x0005","SS_WHITERECT":"0x0006","SS_BLACKFRAME":"0x0007","SS_GRAYFRAME":"0x0008","SS_WHITEFRAME":"0x0009"
		,"SS_USERITEM":"0x000A","SS_SIMPLE":"0x000B","SS_LEFTNOWORDWRAP":"0x000C","SS_OWNERDRAW":"0x000D","SS_BITMAP":"0x000E"
		,"SS_ENHMETAFILE":"0x000F","SS_ETCHEDHORZ":"0x0010","SS_ETCHEDVERT":"0x0011","SS_ETCHEDFRAME":"0x0012","SS_TYPEMASK":"0x001F"}

	Style := sStyle := Style & 0xffff
	For K, V In oEx
		If ((Style & 0x1F) = V) && (%K% := 1, Style -= V)
		{ 
			Ret .= QStyle(K, V)
			Break
		}
	For K, V In oStyles
		If Style && ((Style & V) = V) && (%K% := 1, Style -= V) 
			Ret .= QStyle(K, V)
	IF !SS_CENTER && !SS_RIGHT  ;	SS_LEFT
		Ret .= QStyle("SS_LEFT", "0x0000", "!(SS_CENTER | SS_RIGHT)")
	IF Style
		Ret .= GetStyle_CommonСontrol(Style, Style)
	IF Style
		Ret .= QStyleRest(4, Style)
	If Ret !=
		Res .= _T1 " id='__Styles_Control'>" QStyleTitle("Styles", "Static", 4, sStyle) "</span>" _T2 _PRE1 Ret _PRE2
	
	Return Res
}

GetStyle_Button(Style, hWnd)  {
	;	https://www.autohotkey.com/boards/viewtopic.php?p=25841#p25841
	;	https://docs.microsoft.com/en-us/windows/desktop/controls/button-styles
	Static oStyles, oEx
	If !oStyles
		oStyles := {"BS_ICON":"0x0040","BS_BITMAP":"0x0080","BS_LEFT":"0x0100","BS_RIGHT":"0x0200","BS_CENTER":"0x0300"
		,"BS_TOP":"0x0400","BS_BOTTOM":"0x0800","BS_VCENTER":"0x0C00","BS_PUSHLIKE":"0x1000","BS_MULTILINE":"0x2000"
		,"BS_NOTIFY":"0x4000","BS_FLAT":"0x8000"}

		, oEx := {"BS_DEFPUSHBUTTON":"0x0001","BS_CHECKBOX":"0x0002","BS_AUTOCHECKBOX":"0x0003"
		,"BS_RADIOBUTTON":"0x0004","BS_3STATE":"0x0005","BS_AUTO3STATE":"0x0006","BS_GROUPBOX":"0x0007","BS_USERBUTTON":"0x0008"
		,"BS_AUTORADIOBUTTON":"0x0009","BS_PUSHBOX":"0x000A","BS_OWNERDRAW":"0x000B","BS_COMMANDLINK":"0x000E"
		,"BS_DEFCOMMANDLINK":"0x000F","BS_SPLITBUTTON":"0x000C","BS_DEFSPLITBUTTON":"0x000D","BS_PUSHBUTTON":"0x0000","BS_TEXT":"0x0000"}
		  ; "BS_TYPEMASK":"0x000F"

	Style := sStyle := Style & 0xffff
	For K, V In oEx
		If ((Style & 0xF) = V) && (%K% := 1, Style -= V)
		{
			Ret .= QStyle(K, V)
			Break
		}
	If ((Style & 0x0020) = 0x0020)  ;	BS_LEFTTEXT  ;	BS_RIGHTBUTTON
		Ret .= QStyle("BS_LEFTTEXT := BS_RIGHTBUTTON", "0x0020")

	For K, V In oStyles
		If ((Style & V) = V) && (%K% := 1, Style -= V)
			Ret .= QStyle(K, V)

	IF !BS_ICON && !BS_BITMAP && !BS_AUTOCHECKBOX && !BS_AUTORADIOBUTTON && !BS_CHECKBOX && !BS_RADIOBUTTON  ;	BS_TEXT
		Ret .= QStyle("BS_TEXT", "0x0000", "!(BS_ICON | BS_BITMAP | BS_AUTOCHECKBOX | BS_AUTORADIOBUTTON | BS_CHECKBOX | BS_RADIOBUTTON)")

	IF !BS_DEFPUSHBUTTON && !BS_CHECKBOX && !BS_AUTOCHECKBOX && !BS_RADIOBUTTON && !BS_GROUPBOX && !BS_AUTORADIOBUTTON  ;	BS_PUSHBUTTON
		Ret .= QStyle("BS_PUSHBUTTON", "0x0000", "!(BS_DEFPUSHBUTTON | BS_CHECKBOX | BS_AUTOCHECKBOX | BS_RADIOBUTTON | BS_GROUPBOX | BS_AUTORADIOBUTTON)")

	IF Style
		Ret .= GetStyle_CommonСontrol(Style, Style)
	IF Style
		Ret .= QStyleRest(4, Style)
	If Ret !=
		Res .= _T1 " id='__Styles_Control'>" QStyleTitle("Styles", "Button", 4, sStyle) "</span>" _T2 _PRE1 Ret _PRE2
	
	Return Res
}

GetStyle_Edit(Style, hWnd)  {
	;	https://www.autohotkey.com/boards/viewtopic.php?p=25848#p25848
	;	https://docs.microsoft.com/en-us/windows/desktop/controls/edit-control-styles
	Static oStyles
	If !oStyles
		oStyles := {"ES_CENTER":"0x0001","ES_RIGHT":"0x0002","ES_MULTILINE":"0x0004"
		,"ES_UPPERCASE":"0x0008","ES_LOWERCASE":"0x0010","ES_PASSWORD":"0x0020","ES_AUTOVSCROLL":"0x0040"
		,"ES_AUTOHSCROLL":"0x0080","ES_NOHIDESEL":"0x0100","ES_OEMCONVERT":"0x0400","ES_READONLY":"0x0800"
		,"ES_WANTRETURN":"0x1000","ES_NUMBER":"0x2000"}

	Style := sStyle := Style & 0xffff
	For K, V In oStyles
		If ((Style & V) = V) && (%K% := 1, Style -= V)
			Ret .= QStyle(K, V)

	IF !ES_CENTER && !ES_RIGHT  ;	ES_LEFT
		Ret .= QStyle("ES_LEFT", "0x0000", "!(ES_CENTER | ES_RIGHT)")

	IF Style
		Ret .= GetStyle_CommonСontrol(Style, Style)
	IF Style
		Ret .= QStyleRest(4, Style)
	If Ret !=
		Res .= _T1 " id='__Styles_Control'>" QStyleTitle("Styles", "Edit", 4, sStyle) "</span>" _T2 _PRE1 Ret _PRE2
	
	Return Res
}

GetStyle_ComboLBox(Style, hWnd)  {
	Return GetStyle_ListBox(Style, hWnd)
}

GetStyle_ListBox(Style, hWnd)  {
	;	https://www.autohotkey.com/boards/viewtopic.php?p=25855#p25855
	;	https://docs.microsoft.com/en-us/windows/desktop/controls/list-box-styles
	Static oStyles
	If !oStyles
		oStyles := {"LBS_NOTIFY":"0x0001","LBS_SORT":"0x0002","LBS_NOREDRAW":"0x0004","LBS_MULTIPLESEL":"0x0008"
		,"LBS_OWNERDRAWFIXED":"0x0010","LBS_OWNERDRAWVARIABLE":"0x0020","LBS_HASSTRINGS":"0x0040"
		,"LBS_USETABSTOPS":"0x0080","LBS_NOINTEGRALHEIGHT":"0x0100","LBS_MULTICOLUMN":"0x0200"
		,"LBS_WANTKEYBOARDINPUT":"0x0400","LBS_EXTENDEDSEL":"0x0800","LBS_DISABLENOSCROLL":"0x1000","LBS_NODATA":"0x2000"
		,"LBS_NOSEL":"0x4000","LBS_COMBOBOX":"0x8000"}
		, WS_VSCROLL := 0x200000, WS_BORDER := 0x800000

	wStyle := Style, Style := sStyle := Style & 0xffff

	For K, V In oStyles
		If ((Style & V) = V) && (%K% := 1, Style -= V)
			Ret .= QStyle(K, V) 

	IF LBS_NOTIFY && LBS_SORT && (wStyle & WS_VSCROLL) && (wStyle & WS_BORDER) && (1, Style -= 0x0003)  ;	LBS_STANDARD 
		Ret .= QStyle("LBS_STANDARD", "0xA00003", "(LBS_NOTIFY | LBS_SORT | WS_VSCROLL | WS_BORDER)")

	IF Style
		Ret .= GetStyle_CommonСontrol(Style, Style)
	IF Style
		Ret .= QStyleRest(4, Style)
	If Ret !=
		Res .= _T1 " id='__Styles_Control'>" QStyleTitle("Styles", "ListBox", 4, sStyle) "</span>" _T2 _PRE1 Ret _PRE2
	
	Return Res
}

GetStyle_SysAnimate32(Style, hWnd)  {
	;	https://docs.microsoft.com/en-us/windows/desktop/controls/animation-control-styles
	Static oStyles
	If !oStyles
		oStyles := {"ACS_CENTER":"0x0001","ACS_TRANSPARENT":"0x0002","ACS_AUTOPLAY":"0x0004","ACS_TIMER":"0x0008"}

	Style := sStyle := Style & 0xffff
	For K, V In oStyles
		If ((Style & V) = V) && (1, Style -= V)
			Ret .= QStyle(K, V)  
	IF Style
		Ret .= GetStyle_CommonСontrol(Style, Style)
	IF Style
		Ret .= QStyleRest(4, Style)
	If Ret !=
		Res .= _T1 " id='__Styles_Control'>" QStyleTitle("Styles", "SysAnimate32", 4, sStyle) "</span>" _T2 _PRE1 Ret _PRE2
	
	Return Res
}

GetStyle_SysPager(Style, hWnd)  {
	;	https://docs.microsoft.com/en-us/windows/desktop/controls/pager-control-styles
	Static oStyles, oEx
	If !oStyles
		oStyles := {"PGS_HORZ":"0x0001","PGS_AUTOSCROLL":"0x0002","PGS_DRAGNDROP":"0x0004"}
		, oEx := {"PGS_VERT":"0x0000"}
	Style := sStyle := Style & 0xffff
	If !(Style & oStyles.PGS_HORZ)
		Ret .= "<span name='MS:'>PGS_VERT := <span class='param' name='MS:'>0x0000   !(PGS_HORZ)</span></span>`n"
	For K, V In oStyles
		If ((Style & V) = V) && (1, Style -= V)
			Ret .= QStyle(K, V)
	IF Style
		Ret .= GetStyle_CommonСontrol(Style, Style)
	IF Style
		Ret .= QStyleRest(4, Style)  
	If Ret !=
		Res .= _T1 " id='__Styles_Control'>" QStyleTitle("Styles", "SysPager", 4, sStyle) "</span>" _T2 _PRE1 Ret _PRE2
	
	Return Res
}

GetStyle_msctls_updown32(Style, hWnd)  {
	;	https://www.autohotkey.com/boards/viewtopic.php?p=25878#p25878
	;	https://docs.microsoft.com/en-us/windows/desktop/controls/up-down-control-styles
	Static oStyles
	If !oStyles
		oStyles := {"UDS_WRAP":"0x0001","UDS_SETBUDDYINT":"0x0002","UDS_ALIGNRIGHT":"0x0004","UDS_ALIGNLEFT":"0x0008"
		,"UDS_AUTOBUDDY":"0x0010","UDS_ARROWKEYS":"0x0020","UDS_HORZ":"0x0040","UDS_NOTHOUSANDS":"0x0080","UDS_HOTTRACK":"0x0100"}

	Style := sStyle := Style & 0xffff
	For K, V In oStyles
		If ((Style & V) = V) && (1, Style -= V) 
			Ret .= QStyle(K, V) 
	IF Style
		Ret .= GetStyle_CommonСontrol(Style, Style)
	IF Style
		Ret .= QStyleRest(4, Style)  
	If Ret !=
		Res .= _T1 " id='__Styles_Control'>" QStyleTitle("Styles", "msctls_updown32", 4, sStyle) "</span>" _T2 _PRE1 Ret _PRE2
	
	Return Res
}

GetStyle_SysDateTimePick32(Style, hWnd)  {
	;	https://www.autohotkey.com/boards/viewtopic.php?p=25878#p25878
	;	https://docs.microsoft.com/en-us/windows/desktop/controls/date-and-time-picker-control-styles
	Static oStyles
	If !oStyles
		oStyles := {"DTS_UPDOWN":"0x0001","DTS_SHOWNONE":"0x0002","DTS_LONGDATEFORMAT":"0x0004","DTS_TIMEFORMAT":"0x0009"
			,"DTS_SHORTDATECENTURYFORMAT":"0x000C","DTS_APPCANPARSE":"0x0010","DTS_RIGHTALIGN":"0x0020"}

	Style := sStyle := Style & 0xffff
	For K, V In oStyles
		If ((Style & V) = V) && (%K% := 1, Style -= V)
			Ret .= QStyle(K, V) 
	IF !DTS_LONGDATEFORMAT  ;	DTS_SHORTDATEFORMAT
		Ret .= QStyle("DTS_SHORTDATEFORMAT", "0x0000", "!(DTS_LONGDATEFORMAT)")

	IF Style
		Ret .= GetStyle_CommonСontrol(Style, Style)
	IF Style
		Ret .= QStyleRest(4, Style)  
	If Ret !=
		Res .= _T1 " id='__Styles_Control'>" QStyleTitle("Styles", "SysDateTimePick32", 4, sStyle) "</span>" _T2 _PRE1 Ret _PRE2
	
	Return Res
}

GetStyle_SysMonthCal32(Style, hWnd)  {
	;	https://www.autohotkey.com/boards/viewtopic.php?p=25861#p25861
	;	https://docs.microsoft.com/en-us/windows/desktop/controls/month-calendar-control-styles
	Static oStyles
	If !oStyles
		oStyles := {"MCS_DAYSTATE":"0x0001","MCS_MULTISELECT":"0x0002","MCS_WEEKNUMBERS":"0x0004","MCS_NOTODAYCIRCLE":"0x0008"
		,"MCS_NOTODAY":"0x0010","MCS_NOTRAILINGDATES":"0x0040","MCS_SHORTDAYSOFWEEK":"0x0080","MCS_NOSELCHANGEONNAV":"0x0100"}

	Style := sStyle := Style & 0xffff
	For K, V In oStyles
		If ((Style & V) = V) && (1, Style -= V)
			Ret .= QStyle(K, V) 
	IF Style
		Ret .= GetStyle_CommonСontrol(Style, Style)
	IF Style
		Ret .= QStyleRest(4, Style) 
	If Ret !=
		Res .= _T1 " id='__Styles_Control'>" QStyleTitle("Styles", "SysMonthCal32", 4, sStyle) "</span>" _T2 _PRE1 Ret _PRE2
	
	Return Res
}

GetStyle_msctls_trackbar32(Style, hWnd)  {
	;	https://www.autohotkey.com/boards/viewtopic.php?p=25875#p25875
	;	https://docs.microsoft.com/en-us/windows/desktop/controls/trackbar-control-styles
	Static oStyles
	If !oStyles
		oStyles := {"TBS_AUTOTICKS":"0x0001","TBS_VERT":"0x0002"
		,"TBS_BOTH":"0x0008","TBS_NOTICKS":"0x0010","TBS_ENABLESELRANGE":"0x0020"
		,"TBS_FIXEDLENGTH":"0x0040","TBS_NOTHUMB":"0x0080","TBS_TOOLTIPS":"0x0100","TBS_REVERSED":"0x0200"
		,"TBS_DOWNISLEFT":"0x0400","TBS_NOTIFYBEFOREMOVE":"0x0800","TBS_TRANSPARENTBKGND":"0x1000"}

	Style := sStyle := Style & 0xffff
	For K, V In oStyles
		If ((Style & V) = V) && (%K% := 1, Style -= V)
			Ret .= QStyle(K, V)

	IF !TBS_VERT
	{
		Ret .= QStyle("TBS_HORZ", "0x0000", "!(TBS_VERT)")  ;	TBS_HORZ
		IF ((Style & 0x0004) = 0x0004) && (1, Style -= 0x0004)  ;	TBS_TOP 
			Ret .= QStyle("TBS_TOP", "0x0004", "(TBS_HORZ)")
		IF !TBS_TOP  ;	TBS_BOTTOM 
			Ret .= QStyle("TBS_BOTTOM", "0x0000", "!(TBS_TOP) && (TBS_HORZ)")
	}
	Else
	{
		IF ((Style & 0x0004) = 0x0004) && (TBS_LEFT := 1, Style -= 0x0004)  ;	TBS_LEFT
			Ret .= QStyle("TBS_LEFT", "0x0004", "(TBS_VERT)")

		IF !TBS_LEFT  ;	TBS_RIGHT 
			Ret .= QStyle("TBS_RIGHT", "0x0000", "!(TBS_LEFT) && (TBS_VERT)")
	}
	IF Style
		Ret .= GetStyle_CommonСontrol(Style, Style)
	IF Style
		Ret .= QStyleRest(4, Style)  
	If Ret !=
		Res .= _T1 " id='__Styles_Control'>" QStyleTitle("Styles", "msctls_trackbar32", 4, sStyle) "</span>" _T2 _PRE1 Ret _PRE2
	
	Return Res
}

GetStyle_msctls_statusbar32(Style, hWnd)  {
	;	https://www.autohotkey.com/boards/viewtopic.php?p=25870#p25870
	;	https://docs.microsoft.com/en-us/windows/desktop/controls/status-bar-styles
	Static oStyles
	If !oStyles
		oStyles := {"SBARS_SIZEGRIP":"0x0100","SBARS_TOOLTIPS":"0x0800"}

	Style := sStyle := Style & 0xffff
	For K, V In oStyles
		If ((Style & V) = V) && (1, Style -= V)
			Ret .= QStyle(K, V)
	IF Style
		Ret .= GetStyle_CommonСontrol(Style, Style)
	IF Style
		Ret .= QStyleRest(4, Style)  
	If Ret !=
		Res .= _T1 " id='__Styles_Control'>" QStyleTitle("Styles", "msctls_statusbar32", 4, sStyle) "</span>" _T2 _PRE1 Ret _PRE2
	
	Return Res
}

GetStyle_msctls_progress32(Style, hWnd)  {
	;	https://www.autohotkey.com/boards/viewtopic.php?p=25864#p25864
	;	https://docs.microsoft.com/en-us/windows/desktop/controls/progress-bar-control-styles
	Static oStyles
	If !oStyles
		oStyles := {"PBS_SMOOTH":"0x0001","PBS_VERTICAL":"0x0004","PBS_MARQUEE":"0x0008","PBS_SMOOTHREVERSE":"0x0010"}

	Style := sStyle := Style & 0xffff
	For K, V In oStyles
		If ((Style & V) = V) && (1, Style -= V) 
			Ret .= QStyle(K, V) 
	IF Style
		Ret .= GetStyle_CommonСontrol(Style, Style)
	IF Style
		Ret .= QStyleRest(4, Style)  
	If Ret !=
		Res .= _T1 " id='__Styles_Control'>" QStyleTitle("Styles", "msctls_progress32", 4, sStyle) "</span>" _T2 _PRE1 Ret _PRE2
	
	Return Res
}

GetStyle_SysHeader32(Style, hWnd)  {
	;	https://www.autohotkey.com/boards/viewtopic.php?p=25850#p25850
	;	https://docs.microsoft.com/en-us/windows/desktop/controls/header-control-styles
	Static oStyles
	If !oStyles
		oStyles := {"HDS_BUTTONS":"0x0002","HDS_CHECKBOXES":"0x0400","HDS_DRAGDROP":"0x0040","HDS_FILTERBAR":"0x0100","HDS_FLAT":"0x0200"
		,"HDS_FULLDRAG":"0x0080","HDS_HIDDEN":"0x0008","HDS_HORZ":"0x0000","HDS_HOTTRACK":"0x0004","HDS_NOSIZING":"0x0800","HDS_OVERFLOW":"0x1000"}

	; Style := DllCall("GetWindowLong", "Ptr", hWnd, "int", GWL_STYLE := -16)

	Style := sStyle := Style & 0xffff
	For K, V In oStyles
		If ((Style & V) = V) && (1, Style -= V)
			Ret .= QStyle(K, V)
	IF Style
		Ret .= GetStyle_CommonСontrol(Style, Style)
	IF Style
		Ret .= QStyleRest(4, Style)  
	If Ret !=
		Res .= _T1 " id='__Styles_Control'>" QStyleTitle("Styles", "SysHeader32", 4, sStyle) "</span>" _T2 _PRE1 Ret _PRE2
	
	Return Res
}

GetStyle_SysLink(Style, hWnd) {
	;	https://www.autohotkey.com/boards/viewtopic.php?p=25859#p25859
	;	https://docs.microsoft.com/en-us/windows/desktop/controls/syslink-control-styles
	Static oStyles
	If !oStyles
		oStyles := {"LWS_IGNORERETURN":"0x0002","LWS_NOPREFIX":"0x0004","LWS_RIGHT":"0x0020","LWS_TRANSPARENT":"0x0001","LWS_USECUSTOMTEXT":"0x0010","LWS_USEVISUALSTYLE":"0x0008"}

	Style := sStyle := Style & 0xffff
	For K, V In oStyles
		If ((Style & V) = V) && (1, Style -= V)
			Ret .= QStyle(K, V)
	IF Style
		Ret .= GetStyle_CommonСontrol(Style, Style)
	IF Style
		Ret .= QStyleRest(4, Style) 
	If Ret !=
		Res .= _T1 " id='__Styles_Control'>" QStyleTitle("Styles", "SysLink", 4, sStyle) "</span>" _T2 _PRE1 Ret _PRE2
	
	Return Res
}

GetStyle_ReBarWindow32(Style, hWnd) {
	;	https://www.autohotkey.com/boards/viewtopic.php?p=25865#p25865
	;	https://docs.microsoft.com/en-us/windows/desktop/controls/rebar-control-styles
	Static oStyles
	If !oStyles
		oStyles := {"RBS_AUTOSIZE":"0x2000","RBS_BANDBORDERS":"0x0400","RBS_DBLCLKTOGGLE":"0x8000","RBS_FIXEDORDER":"0x0800"
		,"RBS_REGISTERDROP":"0x1000","RBS_TOOLTIPS":"0x0100","RBS_VARHEIGHT":"0x0200","RBS_VERTICALGRIPPER":"0x4000"}

	Style := sStyle := Style & 0xffff
	For K, V In oStyles
		If ((Style & V) = V) && (1, Style -= V)
			Ret .= QStyle(K, V)
	IF Style
		Ret .= GetStyle_CommonСontrol(Style, Style)
	IF Style
		Ret .= QStyleRest(4, Style)  
	If Ret !=
		Res .= _T1 " id='__Styles_Control'>" QStyleTitle("Styles", "ReBarWindow32", 4, sStyle) "</span>" _T2 _PRE1 Ret _PRE2
	Return Res
}

GetStyle_CommonСontrol(Style, ByRef NewStyle) {   ;	Остаток от стилей контролов
	;	https://www.autohotkey.com/boards/viewtopic.php?p=25846#p25846
	Static oStyles, oEx
	If !oStyles
		oStyles := {"CCS_ADJUSTABLE":"0x0020","CCS_BOTTOM":"0x0003","CCS_NODIVIDER":"0x0040","CCS_NOMOVEY":"0x0002"
		,"CCS_NOPARENTALIGN":"0x0008","CCS_NORESIZE":"0x0004","CCS_TOP":"0x0001","CCS_VERT":"0x0080"}

		,oEx := {"CCS_LEFT":"0x0081","CCS_NOMOVEX":"0x0082","CCS_RIGHT":"0x0083"}

	NewStyle := sStyle := Style & 0xffff
	For K, V In oStyles
		If ((NewStyle & V) = V) && (%K% := 1, NewStyle -= V)
			Ret .= QStyle(K, V)
	IF !CCS_VERT && !CCS_TOP && (NewStyle & oEx.CCS_LEFT) && (1, NewStyle -= oEx.CCS_LEFT)  ;	CCS_LEFT
		Ret .= QStyle("CCS_LEFT", "0x0081", "!(CCS_VERT | CCS_TOP)")
	IF !CCS_VERT && !CCS_NOMOVEY && (NewStyle & oEx.CCS_NOMOVEX) && (1, NewStyle -= oEx.CCS_NOMOVEX)  ;	CCS_NOMOVEX
		Ret .= QStyle("CCS_NOMOVEX", "0x0082", "!(CCS_VERT | CCS_NOMOVEY)") 
	IF !CCS_VERT && !CCS_BOTTOM && (NewStyle & oEx.CCS_RIGHT) && (1, NewStyle -= oEx.CCS_RIGHT)  ;	CCS_RIGHT
		Ret .= QStyle("CCS_RIGHT", "0x0083", "!(CCS_VERT | CCS_BOTTOM)") 
	Return Ret
}




GetStyle_SysListView32(Style, hWnd, byref ResEx)  {
	;	https://www.autohotkey.com/boards/viewtopic.php?p=25857#p25857
	;	https://docs.microsoft.com/en-us/windows/desktop/controls/list-view-window-styles
	;	https://docs.microsoft.com/en-us/windows/desktop/controls/extended-list-view-styles
	Static oStyles, oExStyles, oEx, LVM_GETEXTENDEDLISTVIEWSTYLE := 0x1037
	If !oStyles
		oStyles := {"LVS_AUTOARRANGE":"0x0100","LVS_EDITLABELS":"0x0200"
		,"LVS_NOLABELWRAP":"0x0080","LVS_NOSCROLL":"0x2000"
		,"LVS_OWNERDRAWFIXED":"0x0400","LVS_SHAREIMAGELISTS":"0x0040","LVS_SHOWSELALWAYS":"0x0008","LVS_SINGLESEL":"0x0004","LVS_OWNERDATA":"0x1000"
		,"LVS_SORTASCENDING":"0x0010","LVS_SORTDESCENDING":"0x0020"}

		, oExStyles := {"LVS_EX_AUTOAUTOARRANGE":"0x01000000","LVS_EX_AUTOCHECKSELECT":"0x08000000","LVS_EX_AUTOSIZECOLUMNS":"0x10000000","LVS_EX_BORDERSELECT":"0x00008000"
		,"LVS_EX_CHECKBOXES":"0x00000004","LVS_EX_COLUMNOVERFLOW":"0x80000000","LVS_EX_COLUMNSNAPPOINTS":"0x40000000","LVS_EX_DOUBLEBUFFER":"0x00010000","LVS_EX_FLATSB":"0x00000100"
		,"LVS_EX_FULLROWSELECT":"0x00000020","LVS_EX_GRIDLINES":"0x00000001","LVS_EX_HEADERDRAGDROP":"0x00000010","LVS_EX_HEADERINALLVIEWS":"0x02000000","LVS_EX_HIDELABELS":"0x00020000"
		,"LVS_EX_INFOTIP":"0x00000400","LVS_EX_JUSTIFYCOLUMNS":"0x00200000","LVS_EX_LABELTIP":"0x00004000","LVS_EX_MULTIWORKAREAS":"0x00002000","LVS_EX_ONECLICKACTIVATE":"0x00000040"
		,"LVS_EX_REGIONAL":"0x00000200","LVS_EX_SIMPLESELECT":"0x00100000","LVS_EX_SINGLEROW":"0x00040000","LVS_EX_SNAPTOGRID":"0x00080000","LVS_EX_SUBITEMIMAGES":"0x00000002"
		,"LVS_EX_TRACKSELECT":"0x00000008","LVS_EX_TRANSPARENTBKGND":"0x00400000","LVS_EX_TRANSPARENTSHADOWTEXT":"0x00800000","LVS_EX_TWOCLICKACTIVATE":"0x00000080"
		,"LVS_EX_UNDERLINECOLD":"0x00001000","LVS_EX_UNDERLINEHOT":"0x00000800"}

		,oEx := {"LVS_TYPEMASK":"0x0003","LVS_ICON":"0x0000","LVS_REPORT":"0x0001","LVS_SMALLICON":"0x0002","LVS_LIST":"0x0003"
		,"LVS_ALIGNMASK":"0x0C00","LVS_ALIGNTOP":"0x0000","LVS_ALIGNLEFT":"0x0800"
		,"LVS_TYPESTYLEMASK":"0xFC00","LVS_NOSORTHEADER":"0x8000","LVS_NOCOLUMNHEADER":"0x4000"}

	SendMessage, LVM_GETEXTENDEDLISTVIEWSTYLE, 0, 0,, ahk_id %hWnd%
	ExStyle := sExStyle := ErrorLevel
	Style := sStyle := Style & 0xffff

	For K, V In oStyles
		If ((sStyle & V) = V) && (%K% := 1, Style -= V)
			Ret .= QStyle(K, V) 

	IF ((sStyle & oEx.LVS_TYPEMASK) = oEx.LVS_REPORT) && (LVS_REPORT := 1, Style -= oEx.LVS_REPORT)      ;	LVS_REPORT 
		Ret .= QStyle("LVS_REPORT", "0x0001", "(LVS_TYPEMASK = 0x0001)")
	IF ((sStyle & oEx.LVS_TYPEMASK) = oEx.LVS_SMALLICON) && (LVS_SMALLICON := 1, Style -= oEx.LVS_SMALLICON)      ;	LVS_SMALLICON
		Ret .= QStyle("LVS_SMALLICON", "0x0002", "(LVS_TYPEMASK = 0x0002)")
	IF ((sStyle & oEx.LVS_TYPEMASK) = oEx.LVS_LIST) && (LVS_LIST := 1, Style -= oEx.LVS_LIST)      ;	LVS_LIST
		Ret .= QStyle("LVS_LIST", "0x0003", "(LVS_TYPEMASK = 0x0003)")
	IF ((sStyle & oEx.LVS_TYPEMASK) = oEx.LVS_ICON) && !LVS_REPORT && !LVS_SMALLICON && !LVS_LIST && (LVS_ICON := 1)      ;	LVS_ICON
		Ret .= QStyle("LVS_ICON", "0x0000", "!(LVS_REPORT | LVS_SMALLICON | LVS_LIST)")
	IF ((sStyle & oEx.LVS_ALIGNMASK) = oEx.LVS_ALIGNLEFT) && (LVS_ALIGNLEFT := 1, Style -= oEx.LVS_ALIGNLEFT)      ;	LVS_ALIGNLEFT
		Ret .= QStyle("LVS_ALIGNLEFT", "0x0800", "(LVS_ALIGNMASK = 0x0800)")
	IF ((sStyle & oEx.LVS_ALIGNMASK) = oEx.LVS_ALIGNTOP) && (LVS_SMALLICON || LVS_ICON) && (LVS_ALIGNTOP := 1, Style -= oEx.LVS_ALIGNTOP)      ;	LVS_ALIGNTOP
		Ret .= QStyle("LVS_ALIGNTOP", "0x0000", "(LVS_SMALLICON || LVS_ICON)")
	IF ((sStyle & oEx.LVS_NOSORTHEADER) = oEx.LVS_NOSORTHEADER) && (LVS_NOSORTHEADER := 1, Style -= oEx.LVS_NOSORTHEADER)      ;	LVS_NOSORTHEADER
		Ret .= QStyle("LVS_NOSORTHEADER", "0x8000", "(LVS_TYPEMASK = 0x0003)")
	IF ((sStyle & oEx.LVS_NOCOLUMNHEADER) = oEx.LVS_NOCOLUMNHEADER) && (LVS_NOCOLUMNHEADER := 1, Style -= oEx.LVS_NOCOLUMNHEADER)      ;	LVS_NOCOLUMNHEADER
		Ret .= QStyle("LVS_NOCOLUMNHEADER", "0x4000")

	IF Style
		Ret .= GetStyle_CommonСontrol(Style, Style)
	IF Style
		Ret .= QStyleRest(4, Style)  
	If Ret !=
		Res .= _T1 " id='__Styles_Control'>" QStyleTitle("Styles", "SysListView32", 4, sStyle) "</span>" _T2 _PRE1 Ret _PRE2
	 
	For K, V In oExStyles
		If ((ExStyle & V) = V) && (%K% := 1, ExStyle -= V)
			RetEx .= QStyle(K, V)

	IF ExStyle
		RetEx .= QStyleRest(8, ExStyle)  
	If RetEx !=
		ResEx := _T1 " id='__ExStyles_Control'>" QStyleTitle("ExStyles", "SysListView32", 8, sExStyle) "</span>" _T2 _PRE1 RetEx _PRE2
	 
	 Return Res
}

GetStyle_SysTreeView32(Style, hWnd, byref ResEx)  {
	;	https://www.autohotkey.com/boards/viewtopic.php?p=25876#p25876
	;	https://docs.microsoft.com/en-us/windows/desktop/controls/tree-view-control-window-styles
	;	https://docs.microsoft.com/en-us/windows/desktop/controls/tree-view-control-window-extended-styles
	Static oStyles, oExStyles, TVM_GETEXTENDEDSTYLE := 0x112D
	If !oStyles
		oStyles := {"TVS_CHECKBOXES":"0x0100","TVS_DISABLEDRAGDROP":"0x0010","TVS_EDITLABELS":"0x0008","TVS_FULLROWSELECT":"0x1000","TVS_HASBUTTONS":"0x0001"
		,"TVS_HASLINES":"0x0002","TVS_INFOTIP":"0x0800","TVS_LINESATROOT":"0x0004","TVS_NOHSCROLL":"0x8000","TVS_NONEVENHEIGHT":"0x4000","TVS_NOSCROLL":"0x2000"
		,"TVS_NOTOOLTIPS":"0x0080","TVS_RTLREADING":"0x0040","TVS_SHOWSELALWAYS":"0x0020","TVS_SINGLEEXPAND":"0x0400","TVS_TRACKSELECT":"0x0200"}

		, oExStyles := {"TVS_EX_AUTOHSCROLL":"0x0020","TVS_EX_DIMMEDCHECKBOXES":"0x0200","TVS_EX_DOUBLEBUFFER":"0x0004","TVS_EX_DRAWIMAGEASYNC":"0x0400"
		,"TVS_EX_EXCLUSIONCHECKBOXES":"0x0100","TVS_EX_FADEINOUTEXPANDOS":"0x0040","TVS_EX_MULTISELECT":"0x0002","TVS_EX_NOINDENTSTATE":"0x0008"
		,"TVS_EX_NOSINGLECOLLAPSE":"0x0001","TVS_EX_PARTIALCHECKBOXES":"0x0080","TVS_EX_RICHTOOLTIP":"0x0010"}

	SendMessage, TVM_GETEXTENDEDSTYLE, 0, 0,, ahk_id %hWnd%
	ExStyle := sExStyle := ErrorLevel
	Style := sStyle := Style & 0xffff

	For K, V In oStyles
		If ((sStyle & V) = V) && (1, Style -= V)
			Ret .= QStyle(K, V)

	IF Style
		Ret .= GetStyle_CommonСontrol(Style, Style)
	IF Style
		Ret .= QStyleRest(4, Style)  
	If Ret !=
		Res .= _T1 " id='__Styles_Control'>" QStyleTitle("Styles", "SysTreeView32", 4, sStyle) "</span>" _T2 _PRE1 Ret _PRE2
 
	For K, V In oExStyles
		If ((ExStyle & V) = V) && (1, ExStyle -= V)
			RetEx .= QStyle(K, V)

	IF ExStyle
		RetEx .= QStyleRest(8, ExStyle)  
	If RetEx !=
		ResEx := _T1 " id='__ExStyles_Control'>" QStyleTitle("ExStyles", "SysTreeView32", 8, sExStyle) "</span>" _T2 _PRE1 RetEx _PRE2
	
	Return Res
}

GetStyle_SysTabControl32(Style, hWnd, byref ResEx)  {
	;	https://www.autohotkey.com/boards/viewtopic.php?p=25871#p25871
	;	https://docs.microsoft.com/en-us/windows/desktop/controls/tab-control-styles
	;	https://docs.microsoft.com/en-us/windows/desktop/controls/tab-control-extended-styles
	Static oStyles, TCM_GETEXTENDEDSTYLE := 0x1335
	If !oStyles
		oStyles := {"TCS_SCROLLOPPOSITE":"0x0001","TCS_MULTISELECT":"0x0004","TCS_FLATBUTTONS":"0x0008"
		,"TCS_FORCELABELLEFT":"0x0020","TCS_HOTTRACK":"0x0040","TCS_BUTTONS":"0x0100","TCS_MULTILINE":"0x0200"
		,"TCS_FORCEICONLEFT":"0x0010","TCS_FIXEDWIDTH":"0x0400","TCS_RAGGEDRIGHT":"0x0800","TCS_FOCUSONBUTTONDOWN":"0x1000"
		,"TCS_OWNERDRAWFIXED":"0x2000","TCS_TOOLTIPS":"0x4000","TCS_FOCUSNEVER":"0x8000"}

	SendMessage, TCM_GETEXTENDEDSTYLE, 0, 0,, ahk_id %hWnd%
	ExStyle := sExStyle := ErrorLevel
	Style := sStyle := Style & 0xffff
	For K, V In oStyles
		If ((Style & V) = V) && (%K% := 1, Style -= V)
			Ret .= QStyle(K, V)

	IF !TCS_BUTTONS   ;	TCS_TABS
		Ret .= QStyle("TCS_TABS", "0x0000", "!(TCS_BUTTONS)")
	IF !TCS_MULTILINE   ;	TCS_SINGLELINE
		Ret .= QStyle("TCS_SINGLELINE", "0x0000", "!(TCS_MULTILINE)")
	IF TCS_MULTILINE   ;	TCS_RIGHTJUSTIFY
		Ret .= QStyle("TCS_RIGHTJUSTIFY", "0x0000", "(TCS_MULTILINE)")
	IF TCS_MULTILINE && ((Style & 0x0080) = 0x0080) && (TCS_VERTICAL := 1, Style -= 0x0080)  ;	"TCS_VERTICAL":"0x0080"
		Ret .= QStyle("TCS_VERTICAL", "0x0080", "(TCS_MULTILINE)")
	IF ((Style & 0x0002) = 0x0002) && (1, Style -= 0x0002)   ;	"TCS_BOTTOM":"0x0002","TCS_RIGHT":"0x0002"
	{
		IF TCS_VERTICAL
			Ret .= QStyle("TCS_RIGHT", "0x0002", "(TCS_VERTICAL)")
		Else
			Ret .= QStyle("TCS_BOTTOM", "0x0002", "!(TCS_VERTICAL)")
	}
	IF Style
		Ret .= GetStyle_CommonСontrol(Style, Style)
	IF Style
		Ret .= QStyleRest(4, Style)  
	If Ret !=
		Res .= _T1 " id='__Styles_Control'>" QStyleTitle("Styles", "SysTabControl32", 4, sStyle) "</span>" _T2 _PRE1 Ret _PRE2
 
	If ((ExStyle & 0x00000001) = 0x00000001) && (1, ExStyle -= 0x00000001)  ;	TCS_EX_FLATSEPARATORS
		RetEx .= QStyle("TCS_EX_FLATSEPARATORS", "0x00000001")
	If ((ExStyle & 0x00000002) = 0x00000002) && (1, ExStyle -= 0x00000002)  ;	TCS_EX_REGISTERDROP
		RetEx .= QStyle("TCS_EX_REGISTERDROP", "0x00000002")

	IF ExStyle
		RetEx .= QStyleRest(8, ExStyle)  
	If RetEx !=
		ResEx := _T1 " id='__ExStyles_Control'>" QStyleTitle("ExStyles", "SysTabControl32", 8, sExStyle) "</span>" _T2 _PRE1 RetEx _PRE2
	
	Return Res
}

GetStyle_ComboBox(Style, hWnd, byref ResEx)  {
	;	https://www.autohotkey.com/boards/viewtopic.php?p=25842#p25842
	;	https://docs.microsoft.com/en-us/windows/desktop/controls/combo-box-styles
	Static oStyles, oExStyles, oEx, CBEM_GETEXTENDEDSTYLE := 0x0409
	If !oStyles
		oStyles := {"CBS_SIMPLE":"0x0001","CBS_DROPDOWN":"0x0002","CBS_OWNERDRAWFIXED":"0x0010"
		,"CBS_OWNERDRAWVARIABLE":"0x0020","CBS_AUTOHSCROLL":"0x0040","CBS_OEMCONVERT":"0x0080","CBS_SORT":"0x0100"
		,"CBS_HASSTRINGS":"0x0200","CBS_NOINTEGRALHEIGHT":"0x0400","CBS_DISABLENOSCROLL":"0x0800"
		,"CBS_UPPERCASE":"0x2000","CBS_LOWERCASE":"0x4000"}
		, oEx := {"CBS_DROPDOWNLIST":"0x0003"}
		, oExStyles := {"CBES_EX_CASESENSITIVE":"0x0010","CBES_EX_NOEDITIMAGE":"0x0001","CBES_EX_NOEDITIMAGEINDENT":"0x0002"
		,"CBES_EX_NOSIZELIMIT":"0x0008","CBES_EX_PATHWORDBREAKPROC":"0x0004","CBES_EX_TEXTENDELLIPSIS":"0x0020"}
	
	If (hParent := DllCall("GetParent", "Ptr", hWnd))
	{
		WinGetClass, ParentClass, ahk_id %hParent%
		If ParentClass = ComboBoxEx32
		{
			SendMessage, CBEM_GETEXTENDEDSTYLE, 0, 0, , ahk_id %hParent%
			ExStyle := sExStyle := ErrorLevel
			For K, V In oExStyles
				If ((ExStyle & V) = V) && (1, ExStyle -= V) 
					RetEx .= QStyle(K, V)
			IF ExStyle
				RetEx .= QStyleRest(4, ExStyle) 
		} 
	}
	Style := sStyle := Style & 0xffff
	If ((Style & oEx.CBS_DROPDOWNLIST) = oEx.CBS_DROPDOWNLIST) && (1, Style -= oEx.CBS_DROPDOWNLIST)  ;	CBS_DROPDOWNLIST
		Ret .= QStyle("CBS_DROPDOWNLIST", oEx.CBS_DROPDOWNLIST)
	For K, V In oStyles
		If ((Style & V) = V) && (1, Style -= V)
			Ret .= QStyle(K, V)
	IF Style
		Ret .= GetStyle_CommonСontrol(Style, Style)
	IF Style
		Ret .= QStyleRest(4, Style) 
	If Ret !=
		Res .= _T1 " id='__Styles_Control'>" QStyleTitle("Styles", "ComboBox", 4, sStyle) "</span>" _T2 _PRE1 Ret _PRE2 
	If RetEx !=
		ResEx := _T1 " id='__ExStyles_Control'>" QStyleTitle("ExStyles", "ComboBoxEx32", 4, sExStyle) "</span>" _T2 _PRE1 RetEx _PRE2
	Return Res
}

GetStyle_ToolbarWindow32(Style, hWnd, byref ResEx)  {
	;	https://www.autohotkey.com/boards/viewtopic.php?p=25872#p25872
	;	https://docs.microsoft.com/en-us/windows/desktop/controls/toolbar-control-and-button-styles
	;	https://docs.microsoft.com/en-us/windows/desktop/controls/toolbar-extended-styles
	;	https://docs.microsoft.com/en-us/windows/desktop/api/Commctrl/ns-commctrl-_tbbutton
	Static oStyles, oExStyles, TB_GETSTYLE := 0x0439, TB_GETEXTENDEDSTYLE := 0x0455
	If !oStyles
		oStyles := {"TBSTYLE_ALTDRAG":"0x0400","TBSTYLE_CUSTOMERASE":"0x2000","TBSTYLE_FLAT":"0x0800","TBSTYLE_LIST":"0x1000"
		,"TBSTYLE_REGISTERDROP":"0x4000","TBSTYLE_TOOLTIPS":"0x0100","TBSTYLE_TRANSPARENT":"0x8000","TBSTYLE_WRAPABLE":"0x0200"}

		, oExStyles := {"TBSTYLE_EX_DOUBLEBUFFER":"0x80","TBSTYLE_EX_DRAWDDARROWS":"0x01","TBSTYLE_EX_HIDECLIPPEDBUTTONS":"0x10"
		,"TBSTYLE_EX_MIXEDBUTTONS":"0x08","TBSTYLE_EX_MULTICOLUMN":"0x02","TBSTYLE_EX_VERTICAL":"0x04"}

	SendMessage, TB_GETSTYLE, 0, 0, , ahk_id %hWnd%
	Style := sStyle := ErrorLevel & 0xffff

	SendMessage, TB_GETEXTENDEDSTYLE, 0, 0, , ahk_id %hWnd%
	ExStyle := sExStyle := ErrorLevel 
	
	For K, V In oStyles
		If ((sStyle & V) = V) && (1, Style -= V)
			Ret .= QStyle(K, V)

	IF Style
		Ret .= GetStyle_CommonСontrol(Style, Style)
	IF Style
		Ret .= QStyleRest(8, Style)   
	If Ret !=
		Res .= _T1 " id='__Styles_Control'>" QStyleTitle("Styles", "ToolbarWindow32", 4, sStyle) "</span>" _T2 _PRE1 Ret _PRE2 
	For K, V In oExStyles
		If ((ExStyle & V) = V) && (1, ExStyle -= V)
			RetEx .= QStyle(K, V)

	IF ExStyle
		RetEx .= QStyleRest(4, ExStyle)  
	If RetEx !=
		ResEx := _T1 " id='__ExStyles_Control'>" QStyleTitle("ExStyles", "ToolbarWindow32", 4, sExStyle) "</span>" _T2 _PRE1 RetEx _PRE2 
		
	Return Res
	
/*
		oBTNS := {"BTNS_BUTTON":"0x00","BTNS_SEP":"0x01","BTNS_CHECK":"0x02","BTNS_GROUP":"0x04","BTNS_CHECKGROUP":"0x06","BTNS_DROPDOWN":"0x08"
		,"BTNS_AUTOSIZE":"0x10","BTNS_NOPREFIX":"0x20","BTNS_SHOWTEXT":"0x40","BTNS_WHOLEDROPDOWN":"0x80"}

		VarSetCapacity(TBBUTTON, A_PtrSize == 8 ? 32 : 20, 0)

		iBitmap := NumGet(TBBUTTON, 0, "Int")
		idCommand := NumGet(TBBUTTON, 4, "Int")
		fsState := NumGet(TBBUTTON, 8, "UChar")
		fsStyle := NumGet(TBBUTTON, 9, "UChar")
		bReserved := NumGet(TBBUTTON, 10, "UChar")
		;bReserved := NumGet(TBBUTTON, 10, "UChar")
		dwData := NumGet(TBBUTTON, A_PtrSize == 8 ? 16 : 12, "UPtr")
		iString := NumGet(TBBUTTON, A_PtrSize == 8 ? 24 : 16, "Ptr")
*/
}

	; _________________________________________________ FullScreen _________________________________________________

FullScreenMode() {
	Static Max, hFunc
	hwnd := WinExist("ahk_id" hGui)
	If !FullScreenMode
	{
		FullScreenMode := 1
		Menu, Sys, Check, Full screen
		WinGetNormalPos(hwnd, X, Y, W, H)
		WinGet, Max, MinMax, ahk_id %hwnd%
		If Max = 1
			WinSet, Style, -0x01000000	;	WS_MAXIMIZE
		Gui, 1: -ReSize -Caption
		Gui, 1: Show, x0 y0 w%A_ScreenWidth% h%A_ScreenHeight%
		Gui, 1: Maximize
		WinSetNormalPos(hwnd, X, Y, W, H)
		hFunc := Func("ControlsMove").Bind(A_ScreenWidth, A_ScreenHeight)
	}
	Else
	{
		Gui, 1: +ReSize +Caption
		If Max = 1
		{
			WinGetNormalPos(hwnd, X, Y, W, H)
			Gui, 1: Maximize
			WinSetNormalPos(hwnd, X, Y, W, H)
		}
		Else
			Gui, 1: Restore
		Sleep 20
		GetClientPos(hwnd, _, _, Width, Height)
		hFunc := Func("ControlsMove").Bind(Width, Height)
		FullScreenMode := 0
		Menu, Sys, UnCheck, Full screen
	}
	SetTimer, % hFunc, -10
}

WinGetNormalPos(hwnd, ByRef x, ByRef y, ByRef w, ByRef h) {
	VarSetCapacity(wp, 44), NumPut(44, wp)
	DllCall("GetWindowPlacement", "Ptr", hwnd, "Ptr", &wp)
	x := NumGet(wp, 28, "int"), y := NumGet(wp, 32, "int")
	w := NumGet(wp, 36, "int") - x,  h := NumGet(wp, 40, "int") - y
}

WinSetNormalPos(hwnd, x, y, w, h) {
	VarSetCapacity(wp, 44, 0), NumPut(44, wp, 0, "uint")
	DllCall("GetWindowPlacement", "Ptr", hWnd, "Ptr", &wp)
	NumPut(x, wp, 28, "int"), NumPut(y, wp, 32, "int")
	NumPut(w + x, wp, 36, "int"), NumPut(h + y, wp, 40, "int")
	DllCall("SetWindowPlacement", "Ptr", hWnd, "Ptr", &wp)
}

	; _________________________________________________ Find _________________________________________________

_FindView() {
	If isFindView
		Return FindHide()
	GuiControlGet, p, 1:Pos, %hActiveX%
	GuiControl, 1:Move, %hActiveX%, % "x" pX " y" pY " w" pW " h" pH - 28
	Gui, F: Show, % "NA x" (pW - widthTB) // 2.2 " h26 y" (pY + pH - 27)
	isFindView := 1
	GuiControl, F:Focus, Edit1
	Menu, Sys, Check, Find to page
	FindSearch(1)
}

FindHide() {
	Gui, F: Show, Hide
	GuiControlGet, a, 1:Pos, %hActiveX%
	GuiControl, 1:Move, %hActiveX%, % "x" aX "y" aY "w" aW "h" aH + 28
	isFindView := 0
	GuiControl, Focus, %hActiveX%
	Menu, Sys, UnCheck, Find to page
}

FindOption(Hwnd) {
	GuiControlGet, p, Pos, %Hwnd%
	If pX =
		Return
	ControlGet, Style, Style,, , ahk_id %Hwnd%
	ControlGetText, Text, , ahk_id %Hwnd%
	DllCall("DestroyWindow", "Ptr", Hwnd)
	Gui, %A_Gui%: Add, Text, % "x" pX " y" pY " w" pW " h" pH " g" A_ThisFunc " " (Style & 0x1000 ? "c2F2F2F +0x0201" : "+Border +0x1201"), % Text
	InStr(Text, "sensitive") ? (oFind.Registr := !(Style & 0x1000)) : (oFind.Whole := !(Style & 0x1000))
	FindSearch(1)
	FindAll()
}

FindNew(Hwnd) {
	ControlGetText, Text, , ahk_id %Hwnd%
	oFind.Text := Text
	hFunc := Func("FindSearch").Bind(1)
	SetTimer, FindAll, -150
	SetTimer, % hFunc, -150
}

FindNewText() {
	hFunc := Func("FindSearch").Bind(1)
	SetTimer, % hFunc, -1
	SetTimer, FindAll, -150
}

FindNext(Hwnd) {
	SendMessage, 0x400+114,,,, ahk_id %Hwnd%		;  UDM_GETPOS32
	Back := !ErrorLevel
	FindSearch(0, Back)
}

FindAll() {
	If (oFind.Text = "")
	{
		GuiControl, F:Text, FindMatches
		Return
	}
	R := oBody.createTextRange()
	Matches := 0
	R.collapse(1)
	Option := (oFind.Whole ? 2 : 0) ^ (oFind.Registr ? 4 : 0)
	Loop
	{
		F := R.findText(oFind.Text, 1, Option)
		If (F = 0)
			Break
		El := R.parentElement()
		If (El.TagName = "INPUT" || El.className ~= "^(button|title|param)$") && !R.collapse(0)  ;	https://msdn.microsoft.com/en-us/library/ff976065(v=vs.85).aspx
			Continue
		; R.execCommand("BackColor", 0, "EF0FFF")
		; R.execCommand("ForeColor", 0, "FFEEFF")
		R.collapse(0), ++Matches
	}
	GuiControl, F:Text, FindMatches, % Matches ? Matches : ""
}

FindSearch(New, Back = 0) {
	Global hFindEdit
	R := oDoc.selection.createRange()
	sR := R.duplicate()
	R.collapse(New || Back ? 1 : 0)
	If (oFind.Text = "" && !R.select())
		SetEditColor(hFindEdit, 0xFFFFFF, 0x00)
	Else {
		Option := (Back ? 1 : 0) ^ (oFind.Whole ? 2 : 0) ^ (oFind.Registr ? 4 : 0)
		Loop {
			F := R.findText(oFind.Text, 1, Option)
			If (F = 0) {
				If !A {
					R.moveToElementText(oBody), R.collapse(!Back), A := 1
					Continue
				}
				If New
					sR.collapse(1), sR.select()
				Break
			}
			If (!New && R.isEqual(sR)) {
				If A {
					hFunc := Func("SetEditColor").Bind(hFindEdit, 0xFFFFFF, 0x000000)
					SetTimer, % hFunc, -200
				}
				Break
			}
			El := R.parentElement()

			If (El.TagName = "INPUT" || El.className ~= "^(button|title|param)$") && !R.collapse(Back)
				Continue
			R.select(), F := 1
			Break
		}
		If (F != 1)
			SetEditColor(hFindEdit, 0x6666FF, 0x000000)
		Else
			SetEditColor(hFindEdit, 0xFFFFFF, 0x000000)
	}
}
	; _________________________________________________ Mouse hover selection _________________________________________________

MS_Cancel() {
	If !oMS.ELSel
		Return
	oMS.ELSel.style.color := oMS.TextColor
	oMS.ELSelChild.style.color := ""
	oMS.ELSel.style.backgroundColor := ""
	oMS.ELSel := ""
}

MS_SelectionCheck() {
	Selection := oDoc.selection.createRange().text != ""
	If Selection
		(!oMS.Selection && MS_Cancel())
	Else If oMS.Selection && MS_IsSelect(EL := oDoc.elementFromPoint(oMS.SCX, oMS.SCY))
		MS_Select(EL)
	oMS.Selection := Selection
}

MS_MouseOver() {
	EL := oMS.EL
	If !MS_IsSelect(EL)
		Return
	MS_Select(EL)
}

MS_IsSelect(EL) {
	If InStr(EL.Name, "MS:")
		Return 1
}

MS_IsSelection() {
	Return oMS.ELSel.OuterText != ""
}

MS_Select(EL) { 
	If InStr(EL.Name, ":S")
		oMS.ELSel := EL.ParentElement
	Else If InStr(EL.Name, ":N")
		oMS.ELSel := oDoc.all.item(EL.sourceIndex + 1)
	Else If InStr(EL.Name, ":P")
		oMS.ELSel := oDoc.all.item(EL.sourceIndex - 1).ParentElement
	Else
		oMS.ELSel := EL
	oMS.ELSel.style.backgroundColor := "#3399FF" 
	oMS.TextColor := oMS.ELSel.style.color
	oMS.ELSel.style.color := "#FFFFFF"
	
	oMS.ELSelChild := oMS.ELSel.childNodes[0 + (InStr(EL.Name, ":SP") || InStr(EL.Name, ":Q"))]
	oMS.ELSelChild.style.color := "#FFFFFF"
	
	; ToolTip % oMS.ELSelChild.OuterText "`n" EL.Name
}

	; _________________________________________________ Load JScripts _________________________________________________

ChangeCSS(id, css) {	;  https://webo.in/articles/habrahabr/68-fast-dynamic-css/
	oDoc.getElementById(id).styleSheet.cssText := css
}

LoadJScript() {
	Static onhkinput, ontooltip
	PreOver_ := PreOverflowHide ? _PreOverflowHideCSS : ""
	BodyWrap_ := WordWrap ? _BodyWrapCSS : ""
html =
(
<head>
	<style id='css_ColorBg' type="text/css">.title, .button {background-color: #%ColorBg%;}</style>
	<style id='css_PreOverflowHide' type="text/css">%PreOver_%</style>
	<style id='css_Body' type="text/css">%BodyWrap_%</style>
</head>

<script type="text/javascript">
	var prWidth, WordWrap, MoveTitles, key1, key2, ButtonOver, ButtonOverColor;
	function shift(scroll) {
		var col, Width, clientWidth, scrollLeft, Offset;
		clientWidth = document.documentElement.clientWidth;
		if (clientWidth < 0)
			return
		scrollLeft = document.documentElement.scrollLeft;
		Width = (clientWidth + scrollLeft);
		if (scroll && Width == prWidth)
			return
		if (MoveTitles == 1) {
			Offset = ((clientWidth / 100 * 30) + scrollLeft);
			col = document.querySelectorAll('.con');
			for (var i = 0; i < col.length; i++) {
				col[i].style.left = Offset + "px";
			}
		}
		col = document.querySelectorAll('.box');
		for (var i = 0; i < col.length; i++) {
			col[i].style.width = Width + 'px';
		}
		prWidth = Width;
	}
	function conleft30() {
		col = document.querySelectorAll('.con');
		for (var i = 0; i < col.length; i++) {
			col[i].style.left = "30`%";
		}
	}
	function menuitemdisplay(param) {
		col = document.querySelectorAll('.menuitemid');
		for (var i = 0; i < col.length; i++) {
			col[i].style.display = param;
		}
	}
	function removemenuitem(parent, selector) {
		col = parent.querySelectorAll(selector);
		for (var i = 0; i < col.length; i++) {
			parent.removeChild(col[i])
		}
	}
	onresize = function() {
		shift(0);
	}
	onscroll = function() {
		if (WordWrap == 1)
			return
		shift(1);
	}
	function OnButtonDown (el) {
		if (window.event.button != 1)   //  only left button https://msdn.microsoft.com/en-us/library/aa703876(v=vs.85).aspx
			return
		el.style.backgroundColor = "#%ColorSelButton%";
		el.style.color = "#fff";
		el.style.border = "1px solid black";
	}
	function OnButtonUp (el) {
		el.style.backgroundColor = "";
		// el.style.color = (el.name != "pre" ? "#%ColorFont%" : "#%ColorParam%");
		el.style.color = ButtonOverColor;
		if (window.event.button == 2 && el.parentElement.className == 'BB')
			document.documentElement.focus();
	}
	function OnButtonOver (el) {
		ButtonOverColor = el.style.color;
		el.style.zIndex = "2";
		el.style.border = "1px solid black";
		ButtonOver = el;
	}
	function OnButtonOut (el) {
		el.style.zIndex = "0";
		el.style.backgroundColor = "";
		// el.style.color = (el.name != "pre" ? "#%ColorFont%" : "#%ColorParam%");
		el.style.color = ButtonOverColor;
		el.style.border = "1px dotted black";
		ButtonOver = 0;
	}
	function Assync (param) {
		setTimeout(param, 1);
	}
	function ElementName (param) {
		try {
			el = document.querySelector("[name=" + param + "]");
		} catch (e) {
			return
		}
		return el
	}
	//	alert(value);
	//	tooltip(value);
</script>

<script id='hkinputevent' type="text/javascript">
	function funchkinputevent(el, eventname) {
		key1 = el, key2 = eventname;
		hkinputevent.click();
		if (eventname == 'focus')
			el.style.border = "1px solid #4A8DFF";
		else
			el.style.border = "1px dotted black";
	}
</script>

<script id='tooltipevent' type="text/javascript">
	function tooltip(text) {
		key1 = text;
		tooltipevent.click();
	}
</script>
)
oDoc.Write("<!DOCTYPE html><head><meta http-equiv=""X-UA-Compatible"" content=""IE=8""></head>" html)
oDoc.Close()
ComObjConnect(onhkinput := oDoc.getElementById("hkinputevent"), "onhkinput_")
ComObjConnect(ontooltip := oDoc.getElementById("tooltipevent"), "tooltip_")
}

	; _________________________________________________ Doc Events _________________________________________________

onhkinput_onclick() {  ;	http://forum.script-coding.com/viewtopic.php?id=8206
	If (oJScript.key2 = "focus")
		Sleep(1), Hotkey_Hook(0)
	Else If (WinActive("ahk_id" hGui) && !isPaused && ThisMode = "Hotkey")
		Sleep(1), Hotkey_Hook(1)
}

tooltip_onclick() {
	ToolTip(oJScript.key1, 500)
}

Class Events {  ;	http://forum.script-coding.com/viewtopic.php?pid=82283#p82283
	onclick() {
		oevent := oDoc.parentWindow.event.srcElement
		If (oevent.ClassName = "button" || oevent.tagname = "button")
			Return ButtonClick(oevent)
		If (ThisMode = "Hotkey" && !Hotkey_Arr("Hook") && !isPaused && oevent.tagname ~= "PRE|SPAN")
			Hotkey_Hook(1)
	}
	ondblclick() {
		oevent := oDoc.parentWindow.event.srcElement
		
		If (oevent.ClassName = "button" || oevent.tagname = "button")
			Return ButtonClick(oevent)
			
		If (oevent.tagname != "input" && (rng := oDoc.selection.createRange()).text != "" && oevent.isContentEditable)
		{
			While !t 
				rng.moveEnd("character", 1), (SubStr(rng.text, 0) = "_" ? rng.moveEnd("word", 1)
					: (rng.moveEnd("character", -1), t := 1)) 
			While t
				rng.moveStart("character", -1), (SubStr(rng.text, 1, 1) = "_" ? rng.moveStart("word", -1)
					: (rng.moveStart("character", 1), t := 0))
			sel := rng.text, rng.moveEnd("character", StrLen(RTrim(sel)) - StrLen(sel)), rng.select()  
		}
		Else If ((oevent.ClassName = "title" || oevent.ClassName = "con" || oevent.ClassName = "hr" || oevent.ClassName = "box") && ThisMode != "Hotkey")  ;	anchor
		{
			R := oDoc.selection.createRange(), R.collapse(1), R.select()
			  ;	EL = [class 'hr'], _text = [class 'title'].id
			If oevent.ClassName = "con"
				_text := oevent.firstChild.id, EL := oevent.parentElement.firstChild
			Else If oevent.ClassName = "hr"
				_text := oevent.parentElement.childNodes[1].firstChild.id, EL := oevent
			Else If oevent.ClassName = "box"
				_text := oevent.firstChild.childNodes[1].firstChild.id, EL := oevent.firstChild.firstChild
			Else If oevent.ClassName = "title"
				_text := oevent.id, EL := oevent.parentElement.parentElement.firstChild
			If oOther.anchor[ThisMode]
			{
				pEL := oDoc.getElementById("anchor")
				pEL.style.background := "'none'"
				pEL.Id := ""
				If (_text = oOther.anchor[ThisMode "_text"])
				{
					If MemoryAnchor
						IniWrite("", ThisMode "_Anchor")
					Return oOther.anchor[ThisMode] := 0, oOther.anchor[ThisMode "_text"] := "", HTML_%ThisMode% := oBody.innerHTML
				}
			}
			oOther.anchor[ThisMode] := 1, oOther.anchor[ThisMode "_text"] := _text
			EL.Id := "anchor"
			EL.style.backgroundColor := "#" ColorSelAnchor
			oDocEl.scrollTop := oDocEl.scrollTop + EL.getBoundingClientRect().top - 6
			HTML_%ThisMode% := oBody.innerHTML
			If MemoryAnchor
				IniWrite(oOther.anchor[ThisMode "_text"], ThisMode "_Anchor")
		}
	}
    onmouseover() {
		If oMS.Selection
			Return
		oMS.EL := oDoc.parentWindow.event.srcElement
		SetTimer, MS_MouseOver, -50
    }
	onmouseout() {
		MS_Cancel()
    }
	onselectionchange() {
		e := oDoc.parentWindow.event
		oMS.SCX := e.clientX, oMS.SCY := e.clientY
		SetTimer, MS_SelectionCheck, -70
    }
	onselectstart() {
		SetTimer, MS_Cancel, -8
    }
	SendMode() {
		IniWrite(SendMode := {Send:"SendInput",SendInput:"SendPlay",SendPlay:"SendEvent",SendEvent:"Send"}[SendMode], "SendMode")
		SendModeStr := Format("{:L}", SendMode), oDoc.getElementById("SendMode").innerText := " " SendModeStr " "
	}
	SendCode() {
		IniWrite(SendCode := {vk:"sc",sc:"name",name:"vk"}[SendCode], "SendCode")
		oDoc.getElementById("SendCode").innerText := " " SendCode " "
	}
	LButton_Hotkey() {
		If Hotkey_Arr("Hook")
			Hotkey_Main("LButton")
	}
	num_scroll(thisid) {
		(OnHook := Hotkey_Arr("Hook")) ? Hotkey_Hook(0) : 0
		SendInput, {%thisid%}
		(OnHook ? Hotkey_Hook(1) : 0)
		ToolTip(thisid " " (GetKeyState(thisid, "T") ? "On" : "Off"), 500)
	}
	NextChangeLocal() {
		(OnHook := Hotkey_Arr("Hook")) ? Hotkey_Hook(0) : 0
		ChangeLocal(hActiveX)
		ToolTip(GetLangName(hActiveX), 500)
		(OnHook ? Hotkey_Hook(1) : 0)
	}
}

ButtonClick(oevent) {
	thisid := oevent.id
	If (thisid = "copy_wintext")
		o := oDoc.getElementById("wintextcon")
		, GetKeyState("Shift", "P") ? ClipAdd(o.OuterText, 1) : (Clipboard := o.OuterText), HighLight(o, 500)
	Else If (thisid = "wintext_hidden")
	{
		R := oBody.createTextRange(), R.collapse(1), R.select()
		oDoc.getElementById("wintextcon").disabled := 1
		DetectHiddenText, % DetectHiddenText := (DetectHiddenText = "on" ? "off" : "on")
		IniWrite(DetectHiddenText, "DetectHiddenText")
		If !WinExist("ahk_id" oOther.WinID) && ToolTip("Window not exist", 500)
			Return oDoc.getElementById("wintext_hidden").innerText := " hidden - " DetectHiddenText " "
		WinGetText, WinText, % "ahk_id" oOther.WinID
		oDoc.getElementById("wintextcon").innerHTML := "<pre>" TransformHTML(WinText) "</pre>"
		HTML_Win := oBody.innerHTML
		Sleep 200
		oDoc.getElementById("wintextcon").disabled := 0
		oDoc.getElementById("wintext_hidden").innerText := " hidden - " DetectHiddenText " "
	}
	Else If (thisid = "menu_idview")
	{
		IniWrite(MenuIdView := !MenuIdView, "MenuIdView")
		oJScript.menuitemdisplay(!MenuIdView ? "none" : "inline")
		oDoc.getElementById("menu_idview").innerText :=  " id - " (MenuIdView ? "view" : "hide") " "
	}
	Else If (thisid = "copy_menutext")
	{
		pre_menutext := oDoc.getElementById("pre_menutext")
		preclone := pre_menutext.cloneNode(true)
		oJScript.removemenuitem(preclone, ".menuitemsub")
		If !MenuIdView
			oJScript.removemenuitem(preclone, ".menuitemid")
		GetKeyState("Shift", "P") ? ClipAdd(preclone.OuterText, 1) : (Clipboard := preclone.OuterText)
		HighLight(pre_menutext, 500), preclone := ""
	}
	Else If (thisid = "copy_button")
		o := oDoc.all.item(oevent.sourceIndex + 2)
		, GetKeyState("Shift", "P") ? ClipAdd(o.OuterText, 1) : (Clipboard := o.OuterText), HighLight(o, 500)
	Else If thisid = copy_alltitle
	{
		Text := (t:=oDoc.getElementById("wintitle1").OuterText) . (t = "" ? "" : " ")
		. oDoc.getElementById("wintitle2").OuterText " " oDoc.getElementById("wintitle3").OuterText
		GetKeyState("Shift", "P") ? ClipAdd(Text, 1) : (Clipboard := Text)
		HighLight(oDoc.getElementById("wintitle1"), 500)
		HighLight(oDoc.getElementById("wintitle2"), 500, 0), HighLight(oDoc.getElementById("wintitle2_"), 500, 0)
		HighLight(oDoc.getElementById("wintitle3"), 500, 0), HighLight(oDoc.getElementById("wintitle3_"), 500, 0)
	}
	Else If thisid = copy_sbtext
	{
		Loop % oDoc.getElementById("copy_sbtext").name
			el := oDoc.getElementById("sb_field_" A_Index), HighLight(el, 500, (A_Index = 1)), Text .= el.OuterText "`r`n"
		Text := RTrim(Text, "`r`n"), GetKeyState("Shift", "P") ? ClipAdd(Text, 1) : (Clipboard := Text)
	}
	Else If thisid = keyname
	{ 
		edithotkey := oDoc.getElementById("edithotkey"), editkeyname := oDoc.getElementById("editkeyname")
		value := edithotkey.value 
		
		If (value = "    " || value = A_Tab)
			value := A_Tab
		Else If (value != " ")
			value := RegExReplace(value, "^\s*(.*?)\s*$", "$1")
			
		If RegExMatch(value, "i)^0x([0-9a-f]+)$", M)
			key := (StrLen(M1) > 2 ? "sc" : "vk") . Format("{:U}", M1)
		Else
			key := value 
		oDoc.getElementById("edithotkey").value := key 
		
		name := GetKeyName(key)
		If (name = key)
			editkeyname.value := Format("vk{:X}", GetKeyVK(key)) (!(sc := GetKeySC(key)) ? "" : Format("sc{:X}", sc))
		Else
			editkeyname.value := (StrLen(name) = 1 ? (Format("{:U}", name)) : name)
			
		o := name = "" ? edithotkey : editkeyname
		o.focus(), o.createTextRange().select()
		oDoc.getElementById("vkname").innerHTML := GetVKCodeNameStr := GetVKCodeName(key)
		oDoc.getElementById("scname").innerHTML := GetSCCodeNameStr := GetScanCode(key)
		HTML_Hotkey := oBody.innerHTML 
	}
	Else If thisid = hook_reload
	{
		Suspend On
		Suspend Off
		bool := Hotkey_Arr("Hook"), Hotkey_SetHook(0), Hotkey_SetHook(1), Hotkey_Arr("Hook", bool), ToolTip("Ok", 300)
	}
	Else If thisid = pause_button
		Gosub, PausedScript
	Else If thisid = infolder
	{
		If FileExist(FilePath := oDoc.getElementById("copy_processpath").OuterText)
			SelectFilePath(FilePath), Minimize()
		Else
			ToolTip("Not file exist", 500)
	}
	Else If (thisid = "flash_window" || thisid = "flash_control" || thisid = "flash_ctrl_window")
	{
		hwnd := thisid = "flash_window" ? oOther.WinID : thisid = "flash_ctrl_window" ? oOther.MouseWinID : oOther.ControlID

		If !WinExist("ahk_id" hwnd)
			Return ToolTip("Window not exist", 500)
		WinGetPos, WinX, WinY, WinWidth, WinHeight, % "ahk_id" hwnd
		FlashArea(WinX, WinY, WinWidth, WinHeight)
	}
	Else If (thisid = "flash_acc")
	{
		AccGetLocation(oPubObj.AccObj.AccObj, oPubObj.AccObj.child)
		FlashArea(AccCoord[1], AccCoord[2], AccCoord[3], AccCoord[4])
	}
	Else If (thisid = "flash_IE")
	{
		If !WinExist("ahk_id" oPubObj.IEElement.hwnd)
			Return ToolTip("Parent window not exist", 500)
		FlashArea(oPubObj.IEElement.Pos[1], oPubObj.IEElement.Pos[2], oPubObj.IEElement.Pos[3], oPubObj.IEElement.Pos[4])
	}
	Else If thisid = paste_process_path
		oDoc.getElementById("copy_processpath").innerHTML := TransformHTML(Trim(Trim(Clipboard), """"))
	Else If thisid = w_command_line
		RunRealPath(oDoc.getElementById("c_command_line").OuterText)
	Else If thisid = paste_command_line
		oDoc.getElementById("c_command_line").innerHTML := TransformHTML(Clipboard)
	Else If (thisid = "process_close" && (oOther.WinPID || !ToolTip("Invalid parametrs", 500)) && ConfirmAction("Process close?"))
		Process, Close, % oOther.WinPID
	Else If (thisid = "win_close" && (oOther.WinPID || !ToolTip("Invalid parametrs", 500)) && ConfirmAction("Window close?"))
		WinClose, % "ahk_id" oOther.WinID
	Else If (thisid = "SendCode")
		Events.SendCode()
	Else If (thisid = "SendMode")
		Events.SendMode()
	Else If (thisid = "LButton_Hotkey")
		Events.LButton_Hotkey()
	Else If (thisid = "numlock" || thisid = "scrolllock")
		Events.num_scroll(thisid)
	Else If thisid = locale_change
		Events.NextChangeLocal()
	Else If thisid = paste_keyname
		edithotkey := oDoc.getElementById("edithotkey"), edithotkey.value := "", edithotkey.focus()
		, oDoc.execCommand("Paste"), oDoc.getElementById("keyname").click()
	Else If thisid = get_styles_w
		ViewStylesWin(oevent)
	Else If thisid = get_styles_c
		ViewStylesControl(oevent)
	Else If thisid = run_AccViewer
		RunAhkPath(ExtraFile("AccViewer Source"), oPubObjGUID)
	Else If thisid = run_iWB2Learner
		RunAhkPath(ExtraFile("iWB2 Learner"))
	Else If thisid = run_Window_Detective
	{
		Minimize()
		If WinExist("Window Detective ahk_class Qt5QWindowIcon ahk_exe Window Detective.exe")
			WinActivate
		Else
			Run % Path_User "\Window Detective.lnk"
		TimerFunc(Func("MyWindowDetectiveStart").Bind(ThisMode = "Win" ? oOther.WinID : oOther.ControlID, WinExist() ? 1 : 0), -300)
	}
	Else If thisid = set_button_Transparent
		WinSet, Transparent, % oDoc.getElementById("get_win_Transparent").innerText + 0, % "ahk_id" oOther.WinID
	Else If thisid = set_button_TransColor
		WinSet, TransColor, % oDoc.getElementById("get_win_TransColor").innerText, % "ahk_id" oOther.WinID
	Else If thisid = set_button_pos
	{
		HayStack := oevent.OuterText = "Pos:"
		? oDoc.all.item(oevent.sourceIndex + 1).OuterText " " oDoc.all.item(oevent.sourceIndex + 7).OuterText
		: oDoc.all.item(oevent.sourceIndex - 5).OuterText " " oDoc.all.item(oevent.sourceIndex + 1).OuterText
		RegExMatch(HayStack, "(-*\d+[\.\d+]*).*\s+.*?(-*\d+[\.\d+]*).*\s+.*?(-*\d+[\.\d+]*).*\s+.*?(-*\d+[\.\d+]*)", p)
		If (p1 + 0 = "" || p2 + 0 = "" || p3 + 0 = "" || p4 + 0 = "")
			Return ToolTip("Invalid parametrs", 500)
		If (ThisMode = "Win")
			WinMove, % "ahk_id " oOther.WinID, , p1, p2, p3, p4
		Else
			ControlMove, , p1, p2, p3, p4, % "ahk_id " oOther.ControlID
	}
	Else If thisid = set_button_focus_ctrl
	{
		hWnd := oOther.ControlID
		ControlFocus, , ahk_id %hWnd%
		WinGetPos, X, Y, W, H, ahk_id %hWnd%
		FlashArea(x, y, w, h)
		If GetKeyState("Shift", "P") && (X + Y != "")
			DllCall("SetCursorPos", "Uint", X + W // 2, "Uint", Y + H // 2)
	}
	Else If thisid = set_pos
	{ 
		thisbutton := oevent.OuterText
		
		If thisbutton != Screen:
		{
			hWnd := oOther.MouseWinID
			If !WinExist("ahk_id " hwnd)
				Return ToolTip("Window not exist", 500)
			WinGet, Min, MinMax, % "ahk_id " hwnd
			If Min = -1
				Return ToolTip("Window minimize", 500)
			WinGetPos, X, Y, W, H, ahk_id %hWnd%
		}
		If thisbutton = Relative window:
		{
			RegExMatch(oDoc.all.item(oevent.sourceIndex + 1).OuterText, "(-*\d+[\.\d+]*).*\s+.*?(-*\d+[\.\d+]*)", p)
			If (p1 + 0 = "" || p2 + 0 = "")
				Return ToolTip("Invalid parametrs", 500)
			BlockInput, MouseMove
			DllCall("SetCursorPos", "Uint", X + Round(W * p1), "Uint", Y + Round(H * p2))
		}
		Else If thisbutton = Relative client:
		{
			RegExMatch(oDoc.all.item(oevent.sourceIndex + 1).OuterText, "(-*\d+[\.\d+]*).*\s+.*?(-*\d+[\.\d+]*)", p)
			If (p1 + 0 = "" || p2 + 0 = "")
				Return ToolTip("Invalid parametrs", 500)
			GetClientPos(hWnd, caX, caY, caW, caH)
			DllCall("SetCursorPos", "Uint", X + Round(caW * p1) + caX, "Uint", Y + Round(caH * p2) + caY)
		}
		Else
		{
			RegExMatch(oDoc.all.item(oevent.sourceIndex + 1).OuterText, "(-*\d+[\.\d+]*).*\s+.*?(-*\d+[\.\d+]*)", p)
			If (p1 + 0 = "" || p2 + 0 = "")
				Return ToolTip("Invalid parametrs", 500)
			BlockInput, MouseMove
			If thisbutton = Screen:
				DllCall("SetCursorPos", "Uint", p1, "Uint", p2)
			Else If thisbutton = Window:
				DllCall("SetCursorPos", "Uint", X + p1, "Uint", Y + p2)
			Else If thisbutton = Mouse relative control:
			{
				hWnd := oOther.ControlID
				If !WinExist("ahk_id " hwnd)
					Return ToolTip("Control not exist", 500)
				WinGetPos, X, Y, W, H, ahk_id %hWnd%
				DllCall("SetCursorPos", "Uint", X + p1, "Uint", Y + p2)
			}
			Else If thisbutton = Client:
			{
				GetClientPos(hWnd, caX, caY, caW, caH)
				DllCall("SetCursorPos", "Uint", X + p1 + caX, "Uint", Y + p2 + caY)
			}
		}
		If isPaused
		{
			BlockInput, MouseMoveOff
			Return
		}
		If Shift := GetKeyState("Shift", "P")
			ActivateUnderMouse()
		GoSub, SpotProc2
		BlockInput, MouseMoveOff
		If !Shift
			Sleep(500), HideAllMarkers(), CheckHideMarker()
	}
	Else If thisid = run_zoom
		AhkSpyZoomShow()
	Else If thisid = acc_path
	{
		oDoc.getElementById("acc_path_value").innerText := ""
		oDoc.getElementById("acc_path").innerText := "   Wait...  "
		oDoc.getElementById("acc_path").disabled := 1
		oDoc.getElementById("acc_path_value").innerText := GetAccPath(oPubObj.AccObj.AccObj, oPubObj.AccObj.child)
		oDoc.getElementById("acc_path").disabled := 0
		oDoc.getElementById("acc_path").innerText := " Get path: "
		HTML_Control := oBody.innerHTML
	}
	Else If thisid = control_path
	{
		oDoc.getElementById("control_path").innerText := ""
		oDoc.getElementById("control_path").innerText := "   Wait...  "
		oDoc.getElementById("control_path").disabled := 1
		oDoc.getElementById("control_path_value").innerText := ChildToPath(oOther.ControlID)
		oDoc.getElementById("control_path").disabled := 0
		oDoc.getElementById("control_path").innerText := " Get path: "
		HTML_Control := oBody.innerHTML
	}
	Else If thisid = b_DecimalCode
	{
		oDoc.getElementById("b_DecimalCode").innerText := (DecimalCode := !DecimalCode) ? " dec " : " hex "
		str := oDoc.getElementById("v_SCDHCode").innerText
		oDoc.getElementById("v_SCDHCode").innerText := (DecimalCode) ? Format("{:d}", str) : Format("0x{:X}", str)
		str := oDoc.getElementById("v_VKDHCode").innerText
		oDoc.getElementById("v_VKDHCode").innerText := (DecimalCode) ? Format("{:d}", str) : Format("0x{:X}", str)
	}
}

	; _________________________________________________ SingleInstance _________________________________________________

SingleInstance(Icon = 0) {
	#NoTrayIcon
	#SingleInstance Off
	DetectHiddenWindows, On
	WinGetTitle, MyTitle, ahk_id %A_ScriptHWND%
	WinGet, id, List, %MyTitle% ahk_class AutoHotkey
	Loop, %id%
	{
		this_id := id%A_Index%
		If (this_id != A_ScriptHWND)
			WinClose, ahk_id %this_id%
	}
	Loop, %id%
	{
		this_id := id%A_Index%
		If (this_id != A_ScriptHWND)
		{
			Start := A_TickCount
			While WinExist("ahk_id" this_id)
			{
				If (A_TickCount - Start > 1500)
				{
					MsgBox, 8196, , Could not close the previous instance of this script.  Keep waiting?
					IfMsgBox, Yes
					{
						WinClose, ahk_id %this_id%
						Sleep 200
						WinGet, WinPID, PID, ahk_id %this_id%
						Process, Close, %WinPID%
						Start := A_TickCount + 200
						Continue
					}
					OnExit
					ExitApp
				}
				Sleep 1
			}
		}
	}
	If Icon
		Menu, Tray, Icon
}

	; ________________________________________________________________________________________________________
	; _________________________________________________ Zoom _________________________________________________
	; ________________________________________________________________________________________________________

ShowZoom:
hAhkSpy = %2%
If !WinExist("ahk_id" hAhkSpy)
	ExitApp

ActiveNoPause = %3%
AhkSpyPause = %4%
Suspend = %5%
Hotkey = %6%
OnlyShiftTab = %7%

ListLines Off
SetBatchLines,-1
CoordMode, Mouse, Screen
CoordMode, ToolTip, Screen

Global oZoom := {}, isZoom := 1, hAhkSpy, MsgAhkSpyZoom, ActiveNoPause, SpyActive
If !oZoom.pToken := GdipStartup()
{
	MsgBox, 4112, Gdiplus Error, Gdiplus failed to start. Please ensure you have Gdiplus on your system.
	ExitApp
}
Z_MsgZoom(8, Suspend)
Z_MsgZoom(2, AhkSpyPause)
Z_MsgZoom(6, ActiveNoPause)
Z_MsgZoom(7, !!WinActive("ahk_id" hAhkSpy))
Z_MsgZoom(10, Hotkey)
Z_MsgZoom(12, OnlyShiftTab)

OnMessage(MsgAhkSpyZoom := DllCall("RegisterWindowMessage", "Str", "MsgAhkSpyZoom"), "Z_MsgZoom")
OnMessage(0x0020, "WM_SETCURSOR")
OnExit("ZoomOnClose")
OnMessage(0x201, "LBUTTONDOWN") ; WM_LBUTTONDOWN
OnMessage(0xA1, "LBUTTONDOWN") ; WM_NCLBUTTONDOWN

SetWinEventHook("EVENT_OBJECT_DESTROY", 0x8001)
SetWinEventHook("EVENT_SYSTEM_MINIMIZESTART", 0x0016)
SetWinEventHook("EVENT_SYSTEM_MINIMIZEEND", 0x0017)
SetWinEventHook("EVENT_SYSTEM_MOVESIZESTART", 0x000A)
SetWinEventHook("EVENT_SYSTEM_MOVESIZEEND", 0x000B)

ZoomCreate()
PostMessage, % MsgAhkSpyZoom, 0, % oZoom.hGui, , ahk_id %hAhkSpy%
PostMessage, % MsgAhkSpyZoom, 3, % oZoom.hLW, , ahk_id %hAhkSpy%
WinGet, Min, MinMax, % "ahk_id " hAhkSpy
If Min != -1
	ZoomShow()
Return

#If isZoom && oZoom.Show  ;	&& !oZoom.Work

+#PgUp::
+#PgDn::
+#WheelUp::
+#WheelDown:: ChangeZoom(FastZoom(InStr(A_ThisHotKey, "Up")))

#If

ZoomCreate() {
	oZoom.Zoom := IniRead("MagnifyZoom", 4)
	oZoom.Mark := IniRead("MagnifyMark", "Cross")
	oZoom.MemoryZoomSize := IniRead("MemoryZoomSize", 0)
	oZoom.GuiMinW := 306
	oZoom.GuiMinH := 351
	FontSize := (A_ScreenDPI = 120 ? 10 : 12)
	If oZoom.MemoryZoomSize
		GuiW := IniRead("MemoryZoomSizeW", oZoom.GuiMinW), GuiH := IniRead("MemoryZoomSizeH", oZoom.GuiMinH)
	Else
		GuiW := oZoom.GuiMinW, GuiH := oZoom.GuiMinH
	Gui, Zoom: -Caption -DPIScale +Border +LabelZoomOn +HWNDhGui +AlwaysOnTop +E0x08000000    ;	+Owner%hAhkSpy%
	Gui, Zoom: Color, F5F5F5
	Gui, Zoom: Add, Text, hwndhStatic +Border
	DllCall("SetClassLong", "Ptr", hGui, "int", -26
	, "int", DllCall("GetClassLong", "Ptr", hGui, "int", -26) | 0x20000)

	Gui, LW: -Caption +E0x80000 +AlwaysOnTop +ToolWindow +HWNDhLW +E0x08000000 +Owner%hGui% ;	+E0x08000000 +E0x20

	Gui, ZoomTB: +HWNDhTBGui -Caption -DPIScale +Parent%hGui% +E0x08000000 +0x40000000 -0x80000000
	Gui, ZoomTB: Color, F5F5F5
	Gui, ZoomTB: Font, s%FontSize%
	Gui, ZoomTB: Add, Slider, hwndhSliderZoom gSliderZoom x8 Range1-50 w152 Center AltSubmit NoTicks, % oZoom.Zoom
	Gui, ZoomTB: Add, Text, hwndhTextZoom Center x+10 yp+3 w36, % oZoom.Zoom
	Gui, ZoomTB: Font
	Gui, ZoomTB: Add, Button, hwndhChangeMark gChangeMark x+10 yp w52, % oZoom.Mark
	Gui, ZoomTB: Add, Button, hwndhZoomHideBut gZoomHide x+10 yp, X
	Gui, ZoomTB: Show, NA x0 y0

	Gui, Zoom: Show, % "NA Hide w" GuiW " h" GuiH, AhkSpyZoom
	Gui, Zoom: +MinSize

	oZoom.hdcSrc := DllCall("GetDC", "UPtr", 0, "UPtr")
	oZoom.hDCBuf := CreateCompatibleDC()
	oZoom.hdcMemory := CreateCompatibleDC()

	oZoom.hGui := hGui
	oZoom.hStatic := hStatic
	oZoom.hTBGui := hTBGui
	oZoom.hLW := hLW

	oZoom.vTextZoom := hTextZoom
	oZoom.vChangeMark := hChangeMark
	oZoom.vZoomHideBut := hZoomHideBut
	oZoom.vSliderZoom := hSliderZoom
}

SetSize() {
	Static Top := 45, Left := 0, Right := 6, Bottom := 6

	Width := oZoom.LWWidth := oZoom.GuiWidth - Left - Right
	Height := oZoom.LWHeight := oZoom.GuiHeight - Top - Bottom

	Zoom := oZoom.Zoom
	conW := Mod(Width, Zoom) ? Width - Mod(Width, Zoom) + Zoom : Width
	conW := Mod(conW // Zoom, 2) ? conW : conW + Zoom

	conH := Mod(Height, Zoom) ? Height - Mod(Height, Zoom) + Zoom : Height
	conH := Mod(conH // Zoom, 2) ? conH : conH + Zoom

	oZoom.conX := (((conW - Width) // 2)) * -1
	oZoom.conY :=  (((conH - Height) // 2)) * -1

	hDWP := DllCall("BeginDeferWindowPos", "Int", 2)
	hDWP := DllCall("DeferWindowPos"
	, "Ptr", hDWP, "Ptr", oZoom.hStatic, "UInt", 0
	, "Int", Left - 1, "Int", Top - 1, "Int", Width + 2, "Int", Height + 2
	, "UInt", 0x0010)    ; 0x0010 := SWP_NOACTIVATE
	hDWP := DllCall("DeferWindowPos"
	, "Ptr", hDWP, "Ptr", oZoom.hTBGui, "UInt", 0
	, "Int", (oZoom.GuiWidth - oZoom.GuiMinW) / 2
	, "Int", 0, "Int", 0, "Int", 0
	, "UInt", 0x0011)    ; 0x0010 := SWP_NOACTIVATE | 0x0001 := SWP_NOSIZE
	DllCall("EndDeferWindowPos", "Ptr", hDWP)

	oZoom.nWidthSrc := conW // Zoom
	oZoom.nHeightSrc := conH // Zoom
	oZoom.nXOriginSrcOffset := oZoom.nWidthSrc//2
	oZoom.nYOriginSrcOffset := oZoom.nHeightSrc//2
	oZoom.nWidthDest := conW
	oZoom.nHeightDest := conH
	oZoom.xCenter := Round(Width / 2 - Zoom / 2)
	oZoom.yCenter := Round(Height / 2 - Zoom / 2)

	ChangeMarker()

	If oZoom.MemoryZoomSize
		SetTimer, ZoomCheckSize, -100
}

ChangeMarker() {
	Try GoTo % "Marker" oZoom.Mark

	MarkerCross:
		oZoom.oMarkers["Cross"] := [{x:0,y:oZoom.yCenter - 1,w:oZoom.nWidthDest,h:1}
		, {x:0,y:oZoom.yCenter + oZoom.Zoom,w:oZoom.nWidthDest,h:1}
		, {x:oZoom.xCenter - 1,y:0,w:1,h:oZoom.nHeightDest}
		, {x:oZoom.xCenter + oZoom.Zoom,y:0,w:1,h:oZoom.nHeightDest}]
		Return

	MarkerSquare:
		oZoom.oMarkers["Square"] := [{x:oZoom.xCenter - 1,y:oZoom.yCenter,w:oZoom.Zoom + 2,h:1}
		, {x:oZoom.xCenter - 1,y:oZoom.yCenter + oZoom.Zoom + 1,w:oZoom.Zoom + 2,h:1}
		, {x:oZoom.xCenter - 1,y:oZoom.yCenter + 1,w:1,h:oZoom.Zoom}
		, {x:oZoom.xCenter + oZoom.Zoom,y:oZoom.yCenter + 1,w:1,h:oZoom.Zoom}]
		Return

	MarkerGrid:
		If (oZoom.Zoom = 1) {
			Gosub MarkerSquare
			oZoom.oMarkers["Grid"] := oZoom.oMarkers["Square"]
			Return
		}
		oZoom.oMarkers["Grid"] := [{x:oZoom.xCenter - oZoom.Zoom,y:oZoom.yCenter - oZoom.Zoom,w:oZoom.Zoom * 3,h:1}
		, {x:oZoom.xCenter - oZoom.Zoom,y:oZoom.yCenter,w:oZoom.Zoom * 3,h:1}
		, {x:oZoom.xCenter - oZoom.Zoom,y:oZoom.yCenter + oZoom.Zoom,w:oZoom.Zoom * 3,h:1}
		, {x:oZoom.xCenter - oZoom.Zoom,y:oZoom.yCenter + oZoom.Zoom * 2,w:oZoom.Zoom * 3,h:1}
		, {x:oZoom.xCenter - oZoom.Zoom,y:oZoom.yCenter - oZoom.Zoom,w:1,h:oZoom.Zoom * 3}
		, {x:oZoom.xCenter,y:oZoom.yCenter - oZoom.Zoom,w:1,h:oZoom.Zoom * 3}
		, {x:oZoom.xCenter + oZoom.Zoom,y:oZoom.yCenter - oZoom.Zoom,w:1,h:oZoom.Zoom * 3}
		, {x:oZoom.xCenter + oZoom.Zoom * 2,y:oZoom.yCenter - oZoom.Zoom,w:1,h:oZoom.Zoom * 3}]
		Return
}

ZoomCheckSize() {
	Static PrWidth, PrHeight
	If (PrWidth = oZoom.GuiWidth && PrHeight = oZoom.GuiHeight)
		Return
	PrWidth := oZoom.GuiWidth, PrHeight := oZoom.GuiHeight
	IniWrite(PrWidth, "MemoryZoomSizeW"), IniWrite(PrHeight, "MemoryZoomSizeH")
}

SliderZoom() {
	SetTimer, ChangeZoom, -1
}

ChangeZoom(Val = "")  {
	If Val =
		GuiControlGet, Val, ZoomTB:, % oZoom.vSliderZoom
	If (Val < 1 || Val > 50)
		Return
	GuiControl, ZoomTB:, % oZoom.vSliderZoom, % oZoom.Zoom := Val
	GuiControl, ZoomTB:, % oZoom.vTextZoom, % oZoom.Zoom
	SetSize()
	Redraw()
	SetTimer, MagnifyZoomSave, -200
}

FastZoom(Add) {
 	Z := oZoom.Zoom, R := Mod(Z, 5)
	If Add
		Z := Z >= 10 ? Z + (5 - R) : Z + 1
	Else	
		Z := Z > 10 ? Z - (!R ? 5 : R) : Z - 1
	Return Z
}

MagnifyZoomSave() {
	IniWrite(oZoom.Zoom, "MagnifyZoom")
}

ChangeMark()  {
	Static Mark := {"Cross":"Square","Square":"Grid","Grid":"None","None":"Cross","":"None"}
	oZoom.Mark := Mark[oZoom.Mark], ChangeMarker(), Redraw()
	GuiControl, ZoomTB:, % oZoom.vChangeMark, % oZoom.Mark
	GuiControl, ZoomTB:, -0x0001, % oZoom.vChangeMark
	GuiControl, ZoomTB:, Focus, % oZoom.vTextZoom
	SetTimer, MagnifyMarkSave, -300
}

MagnifyMarkSave() {
	IniWrite(oZoom.Mark, "MagnifyMark")
}

SetWinEventHook(EventProc, eventMin, eventMax = 0)  {
	Return DllCall("SetWinEventHook"
				, "UInt", eventMin, "UInt", eventMax := !eventMax ? eventMin : eventMax
				, "Ptr", hmodWinEventProc := 0, "Ptr", lpfnWinEventProc := RegisterCallback(EventProc, "F")
				, "UInt", idProcess := 0, "UInt", idThread := 0
				, "UInt", dwflags := 0x0|0x2, "Ptr")	;	WINEVENT_OUTOFCONTEXT | WINEVENT_SKIPOWNPROCESS
}

ZoomShow() {
	ShowZoom(1)
	PostMessage, % MsgAhkSpyZoom, 2, 1, , ahk_id %hAhkSpy%
	ZoomRules("ZoomHide", 0)
	GuiControl, ZoomTB:, Focus, % oZoom.vTextZoom
}

ZoomHide() {
	ZoomRules("ZoomHide", 1)
	ShowZoom(0)
	PostMessage, % MsgAhkSpyZoom, 2, 0, , ahk_id %hAhkSpy%
	GuiControl, ZoomTB:, -0x0001, % oZoom.vZoomHideBut
	GuiControl, ZoomTB:, Focus, % oZoom.vTextZoom
}

ShowZoom(Show) {
	oZoom.Show := Show
	If Show {
		WinGetPos, WinX, WinY, WinW, , ahk_id %hAhkSpy%
		oZoom.LWX := WinX + WinW + 1, oZoom.LWY := WinY + 46
		Gui,  Zoom: Show, % "NA Hide x" WinX + WinW " y" WinY
		Gui,  LW: Show, % "NA x" oZoom.LWX " y" oZoom.LWY " w" 0 " h" 0
		Gui,  Zoom: Show, NA
		try Gui, LW: Show, % "NA x" oZoom.LWX " y" oZoom.LWY " w" oZoom.LWWidth " h" oZoom.LWHeight
		Return
	}
	Gui,  LW: Show, % "NA w" 0 " h" 0  ;	нельзя применять Hide, иначе после появления и ресайза остаётся прозрачный след
	Gui,  Zoom: Show, NA Hide
}

	; _________________________________________________ Zoom Events _________________________________________________

ZoomOnSize() {
	Critical
	If A_EventInfo != 0
		Return
	oZoom.GuiWidth := A_GuiWidth
	oZoom.GuiHeight := A_GuiHeight
	SetSize()
	Redraw()
}

ZoomOnClose() {
	ReleaseDC(oZoom.hdcSrc)
	DeleteDC(oZoom.hdcSrc)
	DeleteDC(oZoom.hDCBuf)
	DeleteDC(oZoom.hdcMemory)
	GdipShutdown(oZoom.pToken)
	RestoreCursors()
	ExitApp
}

	; wParam: 0 hide, 1 show, 2 пауза AhkSpy, 3 однократный зум, 4 MemoryZoomSize, 5 MinSize, 6 ActiveNoPause, 7 WinActive AhkSpy, 8 Suspend, 9 Menu, 10 Hotkey, 11 MIN, 12 ShiftTab

Zoom_Msg(wParam, lParam) {
	If wParam = 0  ;	hide
		ZoomHide()
	Else If wParam = 1  ;	show
		ZoomShow()
	If wParam = 2  ;	пауза AhkSpy
		ZoomRules("Pause", lParam)
	Else If wParam = 3  ;	однократный зум  ;	AhkSpy отвечает за контекст вызова
		Magnify(1)
	Else If wParam = 4  ;	MemoryZoomSize
	{
		If (oZoom.MemoryZoomSize := lParam)
			IniWrite(oZoom.GuiWidth, "MemoryZoomSizeW"), IniWrite(oZoom.GuiHeight, "MemoryZoomSizeH")
	}
	Else If (wParam = 5 && DllCall("IsWindowVisible", "Ptr", oZoom.hGui))  ;	MinSize
		Gui, Zoom:Show, % "NA w" oZoom.GuiMinW " h" oZoom.GuiMinH
	Else If wParam = 6  ;	ActiveNoPause
		ActiveNoPause := lParam, ZoomRules("Win", ActiveNoPause ? 0 : SpyActive)
	Else If wParam = 7  ;	WinActive AhkSpy
		SpyActive := lParam, ZoomRules("Win", ActiveNoPause ? 0 : SpyActive)
	Else If wParam = 8  ;	Suspend
		Suspend % lParam ? "On" : "Off"
	Else If wParam = 9  ;	Menu
		ZoomRules("Menu", lParam)
	Else If wParam = 10  ;	Menu
		ZoomRules("Hotkey", lParam)
	Else If wParam = 11  ;	MIN
		ZoomRules("MIN", 1)
	Else If wParam = 12  ;	ShiftTab
		ZoomRules("ShiftTab", lParam)
}

Z_MsgZoom(wParam, lParam) {
	obj := Func("Zoom_Msg").Bind(wParam, lParam)
	SetTimer, % obj, -1
	Return 0
}

ZoomRules(Rule, value) {
	Static IsStart, Rules, Arr, Len
	If !IsStart
	{
		Arr := {"ZoomHide":1, "Pause":2, "Win":3, "Sleep":4, "Menu":5, "MIN":6, "MOVE":7, "SIZE":8, "Hotkey":9, "ShiftTab":10}, Len := Arr.Count()
		Loop % VarSetCapacity(Rules, Len - 1)
			StrPut(0, &Rules + A_Index - 1, 1, "CP0")
		IsStart := 1
	}
	StrPut(!!value, &Rules + Arr[Rule] - 1, 1, "CP0")
	If oZoom.Work := !(StrGet(&Rules, Len, "CP0") + 0)
		SetTimer, Magnify, -1
	; ToolTip % Rule "`n" Arr[Rule] "`n" value "`n`n`n"  (StrGet(&Rules, Len, "CP0")) "`n123456789" "`n" oZoom.Work,4,55,6
}

EVENT_OBJECT_DESTROY(hWinEventHook, event, hwnd) {
	If (hwnd = hAhkSpy)
		ExitApp
}

EVENT_SYSTEM_MINIMIZESTART(hWinEventHook, event, hwnd) {
	If (hwnd != hAhkSpy)
		Return
	ZoomRules("MIN", 1)
	If oZoom.Show
		oZoom.Minimize := 1, ShowZoom(0)
}

EVENT_SYSTEM_MINIMIZEEND(hWinEventHook, event, hwnd) {
	If (hwnd != hAhkSpy)
		Return
	If oZoom.Minimize
	{
		isEnabled := false, DllCall("dwmapi.dll\DwmIsCompositionEnabled", "UInt", &isEnabled)
		Sleep % !!isEnabled ? 300 : 10
		ShowZoom(1)
		oZoom.Minimize := 0
	}
	ZoomRules("MIN", 0)
}

EVENT_SYSTEM_MOVESIZESTART(hWinEventHook, event, hwnd) {
	If (hwnd != hAhkSpy)
		Return
	ZoomRules("MOVE", 1)
}

EVENT_SYSTEM_MOVESIZEEND(hWinEventHook, event, hwnd) {
	If (hwnd != hAhkSpy)
		Return
	ZoomRules("MOVE", 0)
}

	; _________________________________________________ Zoom Sizing _________________________________________________

WM_SETCURSOR(W, L, M, H) {
	Static SIZENWSE := DllCall("User32.dll\LoadCursor", "Ptr", NULL, "Int", 32642, "UPtr")
			, SIZENS := DllCall("User32.dll\LoadCursor", "Ptr", NULL, "Int", 32645, "UPtr")
			, SIZEWE := DllCall("User32.dll\LoadCursor", "Ptr", NULL, "Int", 32644, "UPtr")
	If (oZoom.SIZING = 2)
		Return
	If (W = oZoom.hGui)
	{
		MouseGetPos, mX, mY
		WinGetPos, WinX, WinY, WinW, WinH, % "ahk_id " oZoom.hLW
		If (mX > WinX && mY > WinY)
		{
			If (mX < WinX + WinW - 10)
				DllCall("User32.dll\SetCursor", "Ptr", SIZENS), oZoom.SIZINGType := "NS"
			Else If (mY < WinY + WinH - 10)
				DllCall("User32.dll\SetCursor", "Ptr", SIZEWE), oZoom.SIZINGType := "WE"
			Else
				DllCall("User32.dll\SetCursor", "Ptr", SIZENWSE), oZoom.SIZINGType := "NWSE"
			Return oZoom.SIZING := 1
		}
	}
	Else
		oZoom.SIZING := 0, oZoom.SIZINGType := ""
}

LBUTTONDOWN(W, L, M, H) {
	If oZoom.SIZING
	{
		ZoomRules("SIZE", 1)
		oZoom.SIZING := 2
		SetSystemCursor("SIZE" oZoom.SIZINGType)
		SetTimer, Sizing, -10
		KeyWait LButton
		SetTimer, Sizing, Off
		RestoreCursors()
		ZoomRules("SIZE", 0)
		oZoom.SIZING := 0, oZoom.SIZINGType := ""
	}
}

Sizing() {
	MouseGetPos, mX, mY
	WinGetPos, WinX, WinY, , , % "ahk_id " oZoom.hGui
	If (oZoom.SIZINGType = "NWSE" || oZoom.SIZINGType = "WE")
		Width := " w" (mX - WinX < oZoom.GuiMinW ? oZoom.GuiMinW : mX - WinX)
	If (oZoom.SIZINGType = "NWSE" || oZoom.SIZINGType = "NS")
		Height := " h" (mY - WinY < oZoom.GuiMinH ? oZoom.GuiMinH : mY - WinY)
	Gui, Zoom:Show, % "NA" Width . Height
	SetTimer, Sizing, -1
}

SetSystemCursor(CursorName, cx = 0, cy = 0) {
	Static SystemCursors := {ARROW:32512, IBEAM:32513, WAIT:32514, CROSS:32515, UPARROW:32516, SIZE:32640, ICON:32641, SIZENWSE:32642
					, SIZENESW:32643, SIZEWE:32644 ,SIZENS:32645, SIZEALL:32646, NO:32648, HAND:32649, APPSTARTING:32650, HELP:32651}
	Local CursorHandle, hImage, Name, ID
	If (CursorHandle := DllCall("LoadCursor", Uint, 0, Int, SystemCursors[CursorName]))
		For Name, ID in SystemCursors
			hImage := DllCall("CopyImage", Ptr, CursorHandle, Uint, 0x2, Int, cx, Int, cy, Uint, 0)
			, DllCall("SetSystemCursor", Ptr, hImage, Int, ID)
}

RestoreCursors() {
	DllCall("SystemParametersInfo", UInt, 0x57, UInt, 0, UInt, 0, UInt, 0)  ;	SPI_SETCURSORS := 0x57
}

	; _________________________________________________ Zoom Magnify _________________________________________________

Magnify(one = 0) {
	If (a := oZoom.Work) || one
	{
		MouseGetPos, mX, mY, WinID
		If b := (WinID != oZoom.hLW && WinID != oZoom.hGui && WinID != hAhkSpy)
		{
			oZoom.NewSpot := 1, oZoom.MouseX := mX, oZoom.MouseY := mY
			UpdateWindow(oZoom.hdcSrc, mX - oZoom.nXOriginSrcOffset, mY - oZoom.nYOriginSrcOffset)
		}
	}
	If oZoom.NewSpot && (!a || one && b || a && !b)
		Memory()
	If a
		SetTimer, Magnify, -10
	; ToolTip % A_TickCount "`nMagnify", 4, 4, 4
}

Redraw() {
	UpdateWindow(oZoom.hdcMemory, oZoom.nXOriginSrc - oZoom.nXOriginSrcOffset, oZoom.nYOriginSrc - oZoom.nYOriginSrcOffset)
}

Memory() {
	SysGet, VSX, 76
	SysGet, VSY, 77
	SysGet, VSWidth, 78
	SysGet, VSHeight, 79
	oZoom.nXOriginSrc := oZoom.MouseX - VSX, oZoom.nYOriginSrc := oZoom.MouseY - VSY
	hBM := DllCall("Gdi32.Dll\CreateCompatibleBitmap", "Ptr", oZoom.hdcSrc, "Int", VSWidth, "Int", VSHeight)
	DllCall("Gdi32.Dll\SelectObject", "Ptr", oZoom.hdcMemory, "Ptr", hBM), DllCall("DeleteObject", "Ptr", hBM)
	StretchBlt(oZoom.hdcMemory, 0, 0, VSWidth, VSHeight, oZoom.hdcSrc, VSX, VSY, VSWidth, VSHeight)
	oZoom.NewSpot := 0
}

	; _________________________________________________ Zoom Gdip _________________________________________________

UpdateWindow(Src, X, Y) {
	hbm := CreateDIBSection(oZoom.nWidthDest, oZoom.nHeightDest, oZoom.hDCBuf)
	DllCall("SelectObject", "UPtr", oZoom.hDCBuf, "UPtr", hbm)
	StretchBlt(oZoom.hDCBuf, oZoom.conX, oZoom.conY, oZoom.nWidthDest, oZoom.nHeightDest
	, Src, X, Y, oZoom.nWidthSrc, oZoom.nHeightSrc)
	For k, v In oZoom.oMarkers[oZoom.Mark]
		StretchBlt(oZoom.hDCBuf, v.x, v.y, v.w, v.h, oZoom.hDCBuf, v.x, v.y, v.w, v.h, 0x5A0049)	; PATINVERT
	DllCall("gdiplus\GdipCreateBitmapFromHBITMAP", "UPtr", hbm, "UPtr", 0, "UPtr*", pBitmap)
	; DllCall("SelectObject", "UPtr", oZoom.hDCBuf, "UPtr", hbm)
	DllCall("gdiplus\GdipCreateFromHDC", "UPtr", oZoom.hDCBuf, "UPtr*", G)
	; DllCall("gdiplus\GdipSetInterpolationMode", "UPtr", G, "int", 5)
	DrawImage(G, pBitmap, 0, 0, oZoom.LWWidth, oZoom.LWHeight)
	If oZoom.Show
		UpdateLayeredWindow(oZoom.hLW, oZoom.hDCBuf, oZoom.LWWidth, oZoom.LWHeight)
	DllCall("DeleteObject", "UPtr", hbm)
	DllCall("gdiplus\GdipDeleteGraphics", "UPtr", G)
	DllCall("gdiplus\GdipDisposeImage", "UPtr", pBitmap)
}

GdipStartup() {
	if !DllCall("GetModuleHandle", "str", "gdiplus", UPtr)
		DllCall("LoadLibrary", "str", "gdiplus")
	VarSetCapacity(si, A_PtrSize = 8 ? 24 : 16, 0), si := Chr(1)
	DllCall("gdiplus\GdiplusStartup", A_PtrSize ? "UPtr*" : "uint*", pToken, UPtr, &si, UPtr, 0)
	Return pToken
}

GdipShutdown(pToken) {
	DllCall("gdiplus\GdiplusShutdown", UPtr, pToken)
	if hModule := DllCall("GetModuleHandle", "str", "gdiplus", UPtr)
		DllCall("FreeLibrary", UPtr, hModule)
	Return 0
}

UpdateLayeredWindow(hwnd, hdc, w, h) {
	Return DllCall("UpdateLayeredWindow"
					, UPtr, hwnd
					, UPtr, 0
					, UPtr, 0
					, "int64*", w|h<<32
					, UPtr, hdc
					, "int64*", 0
					, "uint", 0
					, "UInt*", 33488896  ;	(Alpha := 255)<<16|1<<24
					, "uint", 2)
}

StretchBlt(ddc, dx, dy, dw, dh, sdc, sx, sy, sw, sh, Raster=0x40CC0020) {  ;	0x00CC0020|0x40000000
	Return DllCall("gdi32\StretchBlt"
					, UPtr, ddc
					, "int", dx
					, "int", dy
					, "int", dw
					, "int", dh
					, UPtr, sdc
					, "int", sx
					, "int", sy
					, "int", sw
					, "int", sh
					, "uint", Raster)
}

CreateDIBSection(w, h, hdc) {
	Static bi, _ := VarSetCapacity(bi, 40, 0)
	NumPut(w, bi, 4, "uint")
	NumPut(h, bi, 8, "uint")
	NumPut(40, bi, 0, "uint")
	NumPut(1, bi, 12, "ushort")
	NumPut(0, bi, 16, "uInt")
	NumPut(32, bi, 14, "ushort")
	Return DllCall("CreateDIBSection"
					, "UPtr", hdc
					, "UPtr", &bi
					, "uint", 0
					, "UPtr*",
					, "UPtr", 0
					, "uint", 0, "UPtr")
}

DrawImage(pGraphics, pBitmap, dx, dy, dw, dh) {
	Return DllCall("gdiplus\GdipDrawImageRectRect"
				, "UPtr", pGraphics
				, "UPtr", pBitmap
				, "float", dx
				, "float", dy
				, "float", dw
				, "float", dh
				, "float", dx
				, "float", dy
				, "float", dw
				, "float", dh
				, "int", 2
				, "UPtr",
				, "UPtr", 0
				, "UPtr", 0)
}

ReleaseDC(hdc, hwnd=0) {
	Return DllCall("ReleaseDC", "UPtr", hwnd, "UPtr", hdc)
}

DeleteDC(hdc) {
	Return DllCall("DeleteDC", "UPtr", hdc)
}

CreateCompatibleDC(hdc=0) {
	Return DllCall("CreateCompatibleDC", "UPtr", hdc)
}

	; _________________________________________________ UIA _________________________________________________



;~ UI Automation Constants: http://msdn.microsoft.com/en-us/library/windows/desktop/ee671207(v=vs.85).aspx
;~ UI Automation Enumerations: http://msdn.microsoft.com/en-us/library/windows/desktop/ee671210(v=vs.85).aspx
;~ http://www.autohotkey.com/board/topic/94619-ahk-l-screen-reader-a-tool-to-get-text-anywhere/

/* Questions:
	- better way to do __properties?
	- support for Constants?
	- if method returns a SafeArray, should we return a Wrapped SafeArray, Raw SafeArray, or AHK Array
	- on UIA Interface conversion methods, how should the data be returned? wrapped/extracted or raw? should raw data be a ByRef param?
	- do variants need cleared? what about SysAllocString BSTRs?
	- do RECT struts need destroyed?
	- if returning wrapped data & raw is ByRef, will the wrapped data being released destroy the raw data?
	- returning varaint data other than vt=3|8|9|13|0x2000
	- Cached Members?
	- UIA Element existance - dependent on window being visible (non minimized)?
	- function(params, ByRef out="……")
*/

class UIA_Base {
	__New(p="", flag=1) {
		ObjInsert(this,"__Type","IUIAutomation" SubStr(this.__Class,5))
		,ObjInsert(this,"__Value",p)
		,ObjInsert(this,"__Flag",flag)
	}
	__Get(member) {
		if member not in base,__UIA ; base & __UIA should act as normal
		{	if raw:=SubStr(member,0)="*" ; return raw data - user should know what they are doing
				member:=SubStr(member,1,-1)
			if RegExMatch(this.__properties, "im)^" member ",(\d+),(\w+)", m) { ; if the member is in the properties. if not - give error message
				if (m2="VARIANT")	; return VARIANT data - DllCall output param different
					return UIA_Hr(DllCall(this.__Vt(m1), "ptr",this.__Value, "ptr",UIA_Variant(out)))? (raw?out:UIA_VariantData(out)):
				else if (m2="RECT") ; return RECT struct - DllCall output param different
					return UIA_Hr(DllCall(this.__Vt(m1), "ptr",this.__Value, "ptr",&(rect,VarSetCapacity(rect,16))))? (raw?out:UIA_RectToObject(rect)):
				else if UIA_Hr(DllCall(this.__Vt(m1), "ptr",this.__Value, "ptr*",out))
					return raw?out:m2="BSTR"?StrGet(out):RegExMatch(m2,"i)IUIAutomation\K\w+",n)?new UIA_%n%(out):out ; Bool, int, DWORD, HWND, CONTROLTYPEID, OrientationType?
			}
			else throw Exception("Property not supported by the " this.__Class " Class.",-1,member)
		}
	}
	__Set(member) {
		throw Exception("Assigning values not supported by the " this.__Class " Class.",-1,member)
	}
	__Call(member) {
		if !ObjHasKey(UIA_Base,member)&&!ObjHasKey(this,member)
			throw Exception("Method Call not supported by the " this.__Class " Class.",-1,member)
	}
	__Delete() {
		this.__Flag? ObjRelease(this.__Value):
	}
	__Vt(n) {
		return NumGet(NumGet(this.__Value+0,"ptr")+n*A_PtrSize,"ptr")
	}
}

class UIA_Interface extends UIA_Base {
	;~ http://msdn.microsoft.com/en-us/library/windows/desktop/ee671406(v=vs.85).aspx
	static __IID := "{30cbe57d-d9d0-452a-ab13-7ac5ac4825ee}"
		,  __properties := "ControlViewWalker,14,IUIAutomationTreeWalker`r`nContentViewWalker,15,IUIAutomationTreeWalker`r`nRawViewWalker,16,IUIAutomationTreeWalker`r`nRawViewCondition,17,IUIAutomationCondition`r`nControlViewCondition,18,IUIAutomationCondition`r`nContentViewCondition,19,IUIAutomationCondition`r`nProxyFactoryMapping,48,IUIAutomationProxyFactoryMapping`r`nReservedNotSupportedValue,54,IUnknown`r`nReservedMixedAttributeValue,55,IUnknown"

	CompareElements(e1,e2) {
		return UIA_Hr(DllCall(this.__Vt(3), "ptr",this.__Value, "ptr",e1.__Value, "ptr",e2.__Value, "int*",out))? out:
	}
	CompareRuntimeIds(r1,r2) {
		return UIA_Hr(DllCall(this.__Vt(4), "ptr",this.__Value, "ptr",ComObjValue(r1), "ptr",ComObjValue(r2), "int*",out))? out:
	}
	GetRootElement() {
		return UIA_Hr(DllCall(this.__Vt(5), "ptr",this.__Value, "ptr*",out))? new UIA_Element(out):
	}
	ElementFromHandle(hwnd) {
		return UIA_Hr(DllCall(this.__Vt(6), "ptr",this.__Value, "ptr",hwnd, "ptr*",out))? new UIA_Element(out):
	}
	ElementFromPoint(x="", y="") {
		return UIA_Hr(DllCall(this.__Vt(7), "ptr",this.__Value, "int64",x==""||y==""?0*DllCall("GetCursorPos","Int64*",pt)+pt:x&0xFFFFFFFF|y<<32, "ptr*",out))? new UIA_Element(out):
	}
	GetFocusedElement() {
		return UIA_Hr(DllCall(this.__Vt(8), "ptr",this.__Value, "ptr*",out))? new UIA_Element(out):
	}
	;~ GetRootElementBuildCache 	9
	;~ ElementFromHandleBuildCache 	10
	;~ ElementFromPointBuildCache 	11
	;~ GetFocusedElementBuildCache 	12
	CreateTreeWalker(condition) {
		return UIA_Hr(DllCall(this.__Vt(13), "ptr",this.__Value, "ptr",Condition.__Value, "ptr*",out))? new UIA_TreeWalker(out):
	}
	;~ CreateCacheRequest 	20

	CreateTrueCondition() {
		return UIA_Hr(DllCall(this.__Vt(21), "ptr",this.__Value, "ptr*",out))? new UIA_Condition(out):
	}
	CreateFalseCondition() {
		return UIA_Hr(DllCall(this.__Vt(22), "ptr",this.__Value, "ptr*",out))? new UIA_Condition(out):
	}
	CreatePropertyCondition(propertyId, ByRef var, type="Variant") {
		if (type!="Variant")
			UIA_Variant(var,type,var)
		return UIA_Hr(DllCall(this.__Vt(23), "ptr",this.__Value, "int",propertyId, "ptr",&var, "ptr*",out))? new UIA_PropertyCondition(out):
	}
	CreatePropertyConditionEx(propertyId, ByRef var, type="Variant", flags=0x1) { ; NOT TESTED
	; PropertyConditionFlags_IgnoreCase = 0x1
		if (type!="Variant")
			UIA_Variant(var,type,var)
		return UIA_Hr(DllCall(this.__Vt(24), "ptr",this.__Value, "int",propertyId, "ptr",&var, "uint",flags, "ptr*",out))? new UIA_PropertyCondition(out):
	}
	CreateAndCondition(c1,c2) {
		return UIA_Hr(DllCall(this.__Vt(25), "ptr",this.__Value, "ptr",c1.__Value, "ptr",c2.__Value, "ptr*",out))? new UIA_AndCondition(out):
	}
	CreateAndConditionFromArray(array) { ; ComObj(0x2003)??
	;->in: AHK Array or Wrapped SafeArray
		if ComObjValue(array)&0x2000
			SafeArray:=array
		else {
			SafeArray:=ComObj(0x2003,DllCall("oleaut32\SafeArrayCreateVector", "uint",13, "uint",0, "uint",array.MaxIndex()),1)
			for i,c in array
				SafeArray[A_Index-1]:=c.__Value, ObjAddRef(c.__Value) ; AddRef - SafeArrayDestroy will release UIA_Conditions - they also release themselves
		}
		return UIA_Hr(DllCall(this.__Vt(26), "ptr",this.__Value, "ptr",ComObjValue(SafeArray), "ptr*",out))? new UIA_AndCondition(out):
	}
	CreateAndConditionFromNativeArray(p*) { ; Not Implemented
		return UIA_NotImplemented()
	/*	[in]           IUIAutomationCondition **conditions,
		[in]           int conditionCount,
		[out, retval]  IUIAutomationCondition **newCondition
	*/
		;~ return UIA_Hr(DllCall(this.__Vt(27), "ptr",this.__Value,
	}
	CreateOrCondition(c1,c2) {
		return UIA_Hr(DllCall(this.__Vt(28), "ptr",this.__Value, "ptr",c1.__Value, "ptr",c2.__Value, "ptr*",out))? new UIA_OrCondition(out):
	}
	CreateOrConditionFromArray(array) {
	;->in: AHK Array or Wrapped SafeArray
		if ComObjValue(array)&0x2000
			SafeArray:=array
		else {
			SafeArray:=ComObj(0x2003,DllCall("oleaut32\SafeArrayCreateVector", "uint",13, "uint",0, "uint",array.MaxIndex()),1)
			for i,c in array
				SafeArray[A_Index-1]:=c.__Value, ObjAddRef(c.__Value) ; AddRef - SafeArrayDestroy will release UIA_Conditions - they also release themselves
		}
		return UIA_Hr(DllCall(this.__Vt(29), "ptr",this.__Value, "ptr",ComObjValue(SafeArray), "ptr*",out))? new UIA_AndCondition(out):
	}
	CreateOrConditionFromNativeArray(p*) { ; Not Implemented
		return UIA_NotImplemented()
	/*	[in]           IUIAutomationCondition **conditions,
		[in]           int conditionCount,
		[out, retval]  IUIAutomationCondition **newCondition
	*/
		;~ return UIA_Hr(DllCall(this.__Vt(27), "ptr",this.__Value,
	}
	CreateNotCondition(c) {
		return UIA_Hr(DllCall(this.__Vt(31), "ptr",this.__Value, "ptr",c.__Value, "ptr*",out))? new UIA_NotCondition(out):
	}

	;~ AddAutomationEventHandler 	32
	;~ RemoveAutomationEventHandler 	33
	;~ AddPropertyChangedEventHandlerNativeArray 	34
	AddPropertyChangedEventHandler(element,scope=0x1,cacheRequest=0,handler="",propertyArray="") {
		SafeArray:=ComObjArray(0x3,propertyArray.MaxIndex())
		for i,propertyId in propertyArray
			SafeArray[i-1]:=propertyId
		return UIA_Hr(DllCall(this.__Vt(35), "ptr",this.__Value, "ptr",element.__Value, "int",scope, "ptr",cacheRequest,"ptr",handler.__Value,"ptr",ComObjValue(SafeArray)))
	}
	;~ RemovePropertyChangedEventHandler 	36
	;~ AddStructureChangedEventHandler 	37
	;~ RemoveStructureChangedEventHandler 	38
	AddFocusChangedEventHandler(cacheRequest, handler) {
		return UIA_Hr(DllCall(this.__Vt(39), "ptr",this.__Value, "ptr",cacheRequest, "ptr",handler.__Value))
	}
	;~ RemoveFocusChangedEventHandler 	40
	;~ RemoveAllEventHandlers 	41

	IntNativeArrayToSafeArray(ByRef nArr, n="") {
		return UIA_Hr(DllCall(this.__Vt(42), "ptr",this.__Value, "ptr",&nArr, "int",n?n:VarSetCapacity(nArr)/4, "ptr*",out))? ComObj(0x2003,out,1):
	}
/*	IntSafeArrayToNativeArray(sArr, Byref nArr="", Byref arrayCount="") { ; NOT WORKING
		VarSetCapacity(nArr,(sArr.MaxIndex()+1)*4)
		return UIA_Hr(DllCall(this.__Vt(43), "ptr",this.__Value, "ptr",ComObjValue(sArr), "ptr*",nArr, "int*",arrayCount))? arrayCount:
	}
*/
	RectToVariant(ByRef rect, ByRef out="") {	; in:{left,top,right,bottom} ; out:(left,top,width,height)
		; in:	RECT Struct
		; out:	AHK Wrapped SafeArray & ByRef Variant
		return UIA_Hr(DllCall(this.__Vt(44), "ptr",this.__Value, "ptr",&rect, "ptr",UIA_Variant(out)))? UIA_VariantData(out):
	}
/*	VariantToRect(ByRef var, ByRef out="") { ; NOT WORKING
		; in:	VT_VARIANT (SafeArray)
		; out:	AHK Wrapped RECT Struct & ByRef Struct
		return UIA_Hr(DllCall(this.__Vt(45), "ptr",this.__Value, "ptr",var, "ptr",&(out,VarSetCapacity(out,16))))? UIA_RectToObject(out):
	}
*/
	;~ SafeArrayToRectNativeArray 	46
	;~ CreateProxyFactoryEntry 	47
	GetPropertyProgrammaticName(Id) {
		return UIA_Hr(DllCall(this.__Vt(49), "ptr",this.__Value, "int",Id, "ptr*",out))? StrGet(out):
	}
	GetPatternProgrammaticName(Id) {
		return UIA_Hr(DllCall(this.__Vt(50), "ptr",this.__Value, "int",Id, "ptr*",out))? StrGet(out):
	}
	PollForPotentialSupportedPatterns(e, Byref Ids="", Byref Names="") {
		return UIA_Hr(DllCall(this.__Vt(51), "ptr",this.__Value, "ptr",e.__Value, "ptr*",Ids, "ptr*",Names))? UIA_SafeArraysToObject(Names:=ComObj(0x2008,Names,1),Ids:=ComObj(0x2003,Ids,1)):
	}
	PollForPotentialSupportedProperties(e, Byref Ids="", Byref Names="") {
		return UIA_Hr(DllCall(this.__Vt(52), "ptr",this.__Value, "ptr",e.__Value, "ptr*",Ids, "ptr*",Names))? UIA_SafeArraysToObject(Names:=ComObj(0x2008,Names,1),Ids:=ComObj(0x2003,Ids,1)):
	}
	CheckNotSupported(value) { ; Useless in this Framework???
	/*	Checks a provided VARIANT to see if it contains the Not Supported identifier.
		After retrieving a property for a UI Automation element, call this method to determine whether the element supports the
		retrieved property. CheckNotSupported is typically called after calling a property retrieving method such as GetCurrentPropertyValue.
	*/
		return UIA_Hr(DllCall(this.__Vt(53), "ptr",this.__Value, "ptr",value, "int*",out))? out:
	}
	ElementFromIAccessible(IAcc, childId=0) {
	/* The method returns E_INVALIDARG - "One or more arguments are not valid" - if the underlying implementation of the
	Microsoft UI Automation element is not a native Microsoft Active Accessibility server; that is, if a client attempts to retrieve
	the IAccessible interface for an element originally supported by a proxy object from Oleacc.dll, or by the UIA-to-MSAA Bridge.
	*/
		return UIA_Hr(DllCall(this.__Vt(56), "ptr",this.__Value, "ptr",ComObjValue(IAcc), "int",childId, "ptr*",out))? new UIA_Element(out):
	}
	;~ ElementFromIAccessibleBuildCache 	57
}

class UIA_Element extends UIA_Base {
	;~ http://msdn.microsoft.com/en-us/library/windows/desktop/ee671425(v=vs.85).aspx
	static __IID := "{d22108aa-8ac5-49a5-837b-37bbb3d7591e}"
		,  __properties := "CurrentProcessId,20,int`r`nCurrentControlType,21,CONTROLTYPEID`r`nCurrentLocalizedControlType,22,BSTR`r`nCurrentName,23,BSTR`r`nCurrentAcceleratorKey,24,BSTR`r`nCurrentAccessKey,25,BSTR`r`nCurrentHasKeyboardFocus,26,BOOL`r`nCurrentIsKeyboardFocusable,27,BOOL`r`nCurrentIsEnabled,28,BOOL`r`nCurrentAutomationId,29,BSTR`r`nCurrentClassName,30,BSTR`r`nCurrentHelpText,31,BSTR`r`nCurrentCulture,32,int`r`nCurrentIsControlElement,33,BOOL`r`nCurrentIsContentElement,34,BOOL`r`nCurrentIsPassword,35,BOOL`r`nCurrentNativeWindowHandle,36,UIA_HWND`r`nCurrentItemType,37,BSTR`r`nCurrentIsOffscreen,38,BOOL`r`nCurrentOrientation,39,OrientationType`r`nCurrentFrameworkId,40,BSTR`r`nCurrentIsRequiredForForm,41,BOOL`r`nCurrentItemStatus,42,BSTR`r`nCurrentBoundingRectangle,43,RECT`r`nCurrentLabeledBy,44,IUIAutomationElement`r`nCurrentAriaRole,45,BSTR`r`nCurrentAriaProperties,46,BSTR`r`nCurrentIsDataValidForForm,47,BOOL`r`nCurrentControllerFor,48,IUIAutomationElementArray`r`nCurrentDescribedBy,49,IUIAutomationElementArray`r`nCurrentFlowsTo,50,IUIAutomationElementArray`r`nCurrentProviderDescription,51,BSTR`r`nCachedProcessId,52,int`r`nCachedControlType,53,CONTROLTYPEID`r`nCachedLocalizedControlType,54,BSTR`r`nCachedName,55,BSTR`r`nCachedAcceleratorKey,56,BSTR`r`nCachedAccessKey,57,BSTR`r`nCachedHasKeyboardFocus,58,BOOL`r`nCachedIsKeyboardFocusable,59,BOOL`r`nCachedIsEnabled,60,BOOL`r`nCachedAutomationId,61,BSTR`r`nCachedClassName,62,BSTR`r`nCachedHelpText,63,BSTR`r`nCachedCulture,64,int`r`nCachedIsControlElement,65,BOOL`r`nCachedIsContentElement,66,BOOL`r`nCachedIsPassword,67,BOOL`r`nCachedNativeWindowHandle,68,UIA_HWND`r`nCachedItemType,69,BSTR`r`nCachedIsOffscreen,70,BOOL`r`nCachedOrientation,71,OrientationType`r`nCachedFrameworkId,72,BSTR`r`nCachedIsRequiredForForm,73,BOOL`r`nCachedItemStatus,74,BSTR`r`nCachedBoundingRectangle,75,RECT`r`nCachedLabeledBy,76,IUIAutomationElement`r`nCachedAriaRole,77,BSTR`r`nCachedAriaProperties,78,BSTR`r`nCachedIsDataValidForForm,79,BOOL`r`nCachedControllerFor,80,IUIAutomationElementArray`r`nCachedDescribedBy,81,IUIAutomationElementArray`r`nCachedFlowsTo,82,IUIAutomationElementArray`r`nCachedProviderDescription,83,BSTR"

	SetFocus() {
		return UIA_Hr(DllCall(this.__Vt(3), "ptr",this.__Value))
	}
	GetRuntimeId(ByRef stringId="") {
		return UIA_Hr(DllCall(this.__Vt(4), "ptr",this.__Value, "ptr*",sa))? ComObj(0x2003,sa,1):
	}
	FindFirst(c="", scope=0x2) {
		static tc	; TrueCondition
		if !tc
			tc:=this.__uia.CreateTrueCondition()
		return UIA_Hr(DllCall(this.__Vt(5), "ptr",this.__Value, "uint",scope, "ptr",(c=""?tc:c).__Value, "ptr*",out))? new UIA_Element(out):
	}
	FindAll(c="", scope=0x2) {
		static tc	; TrueCondition
		if !tc
			tc:=this.__uia.CreateTrueCondition()
		return UIA_Hr(DllCall(this.__Vt(6), "ptr",this.__Value, "uint",scope, "ptr",(c=""?tc:c).__Value, "ptr*",out))? UIA_ElementArray(out):
	}
	;~ Find (First/All, Element/Children/Descendants/Parent/Ancestors/Subtree, Conditions)
	;~ FindFirstBuildCache 	7	IUIAutomationElement
	;~ FindAllBuildCache 	8	IUIAutomationElementArray
	;~ BuildUpdatedCache 	9	IUIAutomationElement
	GetCurrentPropertyValue(propertyId, ByRef out="") {
		return UIA_Hr(DllCall(this.__Vt(10), "ptr",this.__Value, "uint",propertyId, "ptr",UIA_Variant(out)))? UIA_VariantData(out):
	}
	GetCurrentPropertyValueEx(propertyId, ignoreDefaultValue=1, ByRef out="") {
	; Passing FALSE in the ignoreDefaultValue parameter is equivalent to calling GetCurrentPropertyValue
		return UIA_Hr(DllCall(this.__Vt(11), "ptr",this.__Value, "uint",propertyId, "uint",ignoreDefaultValue, "ptr",UIA_Variant(out)))? UIA_VariantData(out):
	}
	;~ GetCachedPropertyValue 	12	VARIANT
	;~ GetCachedPropertyValueEx 	13	VARIANT
	GetCurrentPatternAs(pattern="") {
		if IsObject(UIA_%pattern%Pattern)&&(iid:=UIA_%pattern%Pattern.__iid)&&(pId:=UIA_%pattern%Pattern.__PatternID)
			return UIA_Hr(DllCall(this.__Vt(14), "ptr",this.__Value, "int",pId, "ptr",UIA_GUID(riid,iid), "ptr*",out))? new UIA_%pattern%Pattern(out):
		else throw Exception("Pattern not implemented.",-1, "UIA_" pattern "Pattern")
	}
	;~ GetCachedPatternAs 	15	void **ppv
	;~ GetCurrentPattern 	16	Iunknown **patternObject
	;~ GetCachedPattern 	17	Iunknown **patternObject
	;~ GetCachedParent 	18	IUIAutomationElement
	GetCachedChildren() { ; Haven't successfully tested
		return UIA_Hr(DllCall(this.__Vt(19), "ptr",this.__Value, "ptr*",out))&&out? UIA_ElementArray(out):
	}
	;~ GetClickablePoint 	84	POINT, BOOL
}

class UIA_ElementArray extends UIA_Base {
	;~ http://msdn.microsoft.com/en-us/library/windows/desktop/ee671426(v=vs.85).aspx
	static __IID := "{14314595-b4bc-4055-95f2-58f2e42c9855}"
		,  __properties := "Length,3,int"

	GetElement(i) {
		return UIA_Hr(DllCall(this.__Vt(4), "ptr",this.__Value, "int",i, "ptr*",out))? new UIA_Element(out):
	}
}

class UIA_TreeWalker extends UIA_Base {
	;~ http://msdn.microsoft.com/en-us/library/windows/desktop/ee671470(v=vs.85).aspx
	static __IID := "{4042c624-389c-4afc-a630-9df854a541fc}"
		,  __properties := "Condition,15,IUIAutomationCondition"

	GetParentElement(e) {
		return UIA_Hr(DllCall(this.__Vt(3), "ptr",this.__Value, "ptr",e.__Value, "ptr*",out))? new UIA_Element(out):
	}
	GetFirstChildElement(e) {
		return UIA_Hr(DllCall(this.__Vt(4), "ptr",this.__Value, "ptr",e.__Value, "ptr*",out))&&out? new UIA_Element(out):
	}
	GetLastChildElement(e) {
		return UIA_Hr(DllCall(this.__Vt(5), "ptr",this.__Value, "ptr",e.__Value, "ptr*",out))&&out? new UIA_Element(out):
	}
	GetNextSiblingElement(e) {
		return UIA_Hr(DllCall(this.__Vt(6), "ptr",this.__Value, "ptr",e.__Value, "ptr*",out))&&out? new UIA_Element(out):
	}
	GetPreviousSiblingElement(e) {
		return UIA_Hr(DllCall(this.__Vt(7), "ptr",this.__Value, "ptr",e.__Value, "ptr*",out))&&out? new UIA_Element(out):
	}
	NormalizeElement(e) {
		return UIA_Hr(DllCall(this.__Vt(8), "ptr",this.__Value, "ptr",e.__Value, "ptr*",out))&&out? new UIA_Element(out):
	}
/*	GetParentElementBuildCache(e, cacheRequest) {
		return UIA_Hr(DllCall(this.__Vt(9), "ptr",this.__Value, "ptr",e.__Value, "ptr",cacheRequest.__Value.__Value, "ptr*",out))? new UIA_Element(out):
	}
	GetFirstChildElementBuildCache(e, cacheRequest) {
		return UIA_Hr(DllCall(this.__Vt(10), "ptr",this.__Value, "ptr",e.__Value, "ptr",cacheRequest.__Value, "ptr*",out))? new UIA_Element(out):
	}
	GetLastChildElementBuildCache(e, cacheRequest) {
		return UIA_Hr(DllCall(this.__Vt(11), "ptr",this.__Value, "ptr",e.__Value, "ptr",cacheRequest.__Value, "ptr*",out))? new UIA_Element(out):
	}
	GetNextSiblingElementBuildCache(e, cacheRequest) {
		return UIA_Hr(DllCall(this.__Vt(12), "ptr",this.__Value, "ptr",e.__Value, "ptr",cacheRequest.__Value, "ptr*",out))? new UIA_Element(out):
	}
	GetPreviousSiblingElementBuildCache(e, cacheRequest) {
		return UIA_Hr(DllCall(this.__Vt(13), "ptr",this.__Value, "ptr",e.__Value, "ptr",cacheRequest.__Value, "ptr*",out))? new UIA_Element(out):
	}
	NormalizeElementBuildCache(e, cacheRequest) {
		return UIA_Hr(DllCall(this.__Vt(14), "ptr",this.__Value, "ptr",e.__Value, "ptr",cacheRequest.__Value, "ptr*",out))? new UIA_Element(out):
	}
*/
}

class UIA_Condition extends UIA_Base {
	;~ http://msdn.microsoft.com/en-us/library/windows/desktop/ee671420(v=vs.85).aspx
	static __IID := "{352ffba8-0973-437c-a61f-f64cafd81df9}"
}

class UIA_PropertyCondition extends UIA_Condition {
	;~ http://msdn.microsoft.com/en-us/library/windows/desktop/ee696121(v=vs.85).aspx
	static __IID := "{99ebf2cb-5578-4267-9ad4-afd6ea77e94b}"
		,  __properties := "PropertyId,3,PROPERTYID`r`nPropertyValue,4,VARIANT`r`nPropertyConditionFlags,5,PropertyConditionFlags"
}
; should returned children have a condition type (property/and/or/bool/not), or be a generic uia_condition object?
class UIA_AndCondition extends UIA_Condition {
	;~ http://msdn.microsoft.com/en-us/library/windows/desktop/ee671407(v=vs.85).aspx
	static __IID := "{a7d0af36-b912-45fe-9855-091ddc174aec}"
		,  __properties := "ChildCount,3,int"

	;~ GetChildrenAsNativeArray	4	IUIAutomationCondition ***childArray
	GetChildren() {
		return UIA_Hr(DllCall(this.__Vt(5), "ptr",this.__Value, "ptr*",out))&&out? ComObj(0x2003,out,1):
	}
}
class UIA_OrCondition extends UIA_Condition {
	;~ http://msdn.microsoft.com/en-us/library/windows/desktop/ee696108(v=vs.85).aspx
	static __IID := "{8753f032-3db1-47b5-a1fc-6e34a266c712}"
		,  __properties := "ChildCount,3,int"

	;~ GetChildrenAsNativeArray	4	IUIAutomationCondition ***childArray
	;~ GetChildren	5	SAFEARRAY
}
class UIA_BoolCondition extends UIA_Condition {
	;~ http://msdn.microsoft.com/en-us/library/windows/desktop/ee671411(v=vs.85).aspx
	static __IID := "{8753f032-3db1-47b5-a1fc-6e34a266c712}"
		,  __properties := "BooleanValue,3,boolVal"
}
class UIA_NotCondition extends UIA_Condition {
	;~ http://msdn.microsoft.com/en-us/library/windows/desktop/ee696106(v=vs.85).aspx
	static __IID := "{f528b657-847b-498c-8896-d52b565407a1}"

	;~ GetChild	3	IUIAutomationCondition
}

class UIA_IUnknown extends UIA_Base {
	;~ http://msdn.microsoft.com/en-us/library/windows/desktop/ms680509(v=vs.85).aspx
	static __IID := "{00000000-0000-0000-C000-000000000046}"
}

class UIA_CacheRequest  extends UIA_Base {
	;~ http://msdn.microsoft.com/en-us/library/windows/desktop/ee671413(v=vs.85).aspx
	static __IID := "{b32a92b5-bc25-4078-9c08-d7ee95c48e03}"
}


class _UIA_EventHandler {
	;~ http://msdn.microsoft.com/en-us/library/windows/desktop/ee696044(v=vs.85).aspx
	static __IID := "{146c3c17-f12e-4e22-8c27-f894b9b79c69}"

/*	HandleAutomationEvent	3
		[in]  IUIAutomationElement *sender,
		[in]  EVENTID eventId
*/
}
class _UIA_FocusChangedEventHandler {
	;~ http://msdn.microsoft.com/en-us/library/windows/desktop/ee696051(v=vs.85).aspx
	static __IID := "{c270f6b5-5c69-4290-9745-7a7f97169468}"

/*	HandleFocusChangedEvent	3
		[in]  IUIAutomationElement *sender
*/
}
class _UIA_PropertyChangedEventHandler {
	;~ http://msdn.microsoft.com/en-us/library/windows/desktop/ee696119(v=vs.85).aspx
	static __IID := "{40cd37d4-c756-4b0c-8c6f-bddfeeb13b50}"

/*	HandlePropertyChangedEvent	3
		[in]  IUIAutomationElement *sender,
		[in]  PROPERTYID propertyId,
		[in]  VARIANT newValue
*/
}
class _UIA_StructureChangedEventHandler {
	;~ http://msdn.microsoft.com/en-us/library/windows/desktop/ee696197(v=vs.85).aspx
	static __IID := "{e81d1b4e-11c5-42f8-9754-e7036c79f054}"

/*	HandleStructureChangedEvent	3
		[in]  IUIAutomationElement *sender,
		[in]  StructureChangeType changeType,
		[in]  SAFEARRAY *runtimeId[int]
*/
}
class _UIA_TextEditTextChangedEventHandler { ; Windows 8.1 Preview [desktop apps only]
	;~ http://msdn.microsoft.com/en-us/library/windows/desktop/dn302202(v=vs.85).aspx
	static __IID := "{92FAA680-E704-4156-931A-E32D5BB38F3F}"

	;~ HandleTextEditTextChangedEvent	3
}


;~ 		UIA_Patterns - http://msdn.microsoft.com/en-us/library/windows/desktop/ee684023
class UIA_DockPattern extends UIA_Base {
	;~ http://msdn.microsoft.com/en-us/library/windows/desktop/ee671421
	static	__IID := "{fde5ef97-1464-48f6-90bf-43d0948e86ec}"
		,	__PatternID := 10011
		,	__Properties := "CurrentDockPosition,4,int`r`nCachedDockPosition,5,int"

	SetDockPosition(Pos) {
		return UIA_Hr(DllCall(this.__Vt(3), "ptr",this.__Value, "uint",pos))
	}
/*	DockPosition_Top	= 0,
	DockPosition_Left	= 1,
	DockPosition_Bottom	= 2,
	DockPosition_Right	= 3,
	DockPosition_Fill	= 4,
	DockPosition_None	= 5
*/
}
class UIA_ExpandCollapsePattern extends UIA_Base {
	;~ http://msdn.microsoft.com/en-us/library/windows/desktop/ee696046
	static	__IID := "{619be086-1f4e-4ee4-bafa-210128738730}"
		,	__PatternID := 10005
		,	__Properties := "CachedExpandCollapseState,6,int`r`nCurrentExpandCollapseState,5,int"

	Expand() {
		return UIA_Hr(DllCall(this.__Vt(3), "ptr",this.__Value))
	}
	Collapse() {
		return UIA_Hr(DllCall(this.__Vt(4), "ptr",this.__Value))
	}
/*	ExpandCollapseState_Collapsed	= 0,
	ExpandCollapseState_Expanded	= 1,
	ExpandCollapseState_PartiallyExpanded	= 2,
	ExpandCollapseState_LeafNode	= 3
*/
}
class UIA_GridItemPattern extends UIA_Base {
	;~ http://msdn.microsoft.com/en-us/library/windows/desktop/ee696053
	static	__IID := "{78f8ef57-66c3-4e09-bd7c-e79b2004894d}"
		,	__PatternID := 10007
		,	__Properties := "CurrentContainingGrid,3,IUIAutomationElement`r`nCurrentRow,4,int`r`nCurrentColumn,5,int`r`nCurrentRowSpan,6,int`r`nCurrentColumnSpan,7,int`r`nCachedContainingGrid,8,IUIAutomationElement`r`nCachedRow,9,int`r`nCachedColumn,10,int`r`nCachedRowSpan,11,int`r`nCachedColumnSpan,12,int"
}
class UIA_GridPattern extends UIA_Base {
	;~ http://msdn.microsoft.com/en-us/library/windows/desktop/ee696064
	static	__IID := "{414c3cdc-856b-4f5b-8538-3131c6302550}"
		,	__PatternID := 10006
		,	__Properties := "CurrentRowCount,4,int`r`nCurrentColumnCount,5,int`r`nCachedRowCount,6,int`r`nCachedColumnCount,7,int"

	GetItem(row,column) { ; Hr!=0 if no result, or blank output?
		return UIA_Hr(DllCall(this.__Vt(3), "ptr",this.__Value, "uint",row, "uint",column, "ptr*",out))? new UIA_Element(out):
	}
}
class UIA_InvokePattern extends UIA_Base {
	;~ http://msdn.microsoft.com/en-us/library/windows/desktop/ee696070
	static	__IID := "{fb377fbe-8ea6-46d5-9c73-6499642d3059}"
		,	__PatternID := 10000

	Invoke() {
		return UIA_Hr(DllCall(this.__Vt(3), "ptr",this.__Value))
	}
}
class UIA_ItemContainerPattern extends UIA_Base {
	;~ http://msdn.microsoft.com/en-us/library/windows/desktop/ee696072
	static	__IID := "{c690fdb2-27a8-423c-812d-429773c9084e}"
		,	__PatternID := 10019

	FindItemByProperty(startAfter, propertyId, ByRef value, type=8) {	; Hr!=0 if no result, or blank output?
		if (type!="Variant")
			UIA_Variant(value,type,value)
		return UIA_Hr(DllCall(this.__Vt(3), "ptr",this.__Value, "ptr",startAfter.__Value, "int",propertyId, "ptr",&value, "ptr*",out))? new UIA_Element(out):
	}
}
class UIA_LegacyIAccessiblePattern extends UIA_Base {
	;~ http://msdn.microsoft.com/en-us/library/windows/desktop/ee696074
	static	__IID := "{828055ad-355b-4435-86d5-3b51c14a9b1b}"
		,	__PatternID := 10018
		,	__Properties := "CurrentChildId,6,int`r`nCurrentName,7,BSTR`r`nCurrentValue,8,BSTR`r`nCurrentDescription,9,BSTR`r`nCurrentRole,10,DWORD`r`nCurrentState,11,DWORD`r`nCurrentHelp,12,BSTR`r`nCurrentKeyboardShortcut,13,BSTR`r`nCurrentDefaultAction,15,BSTR`r`nCachedChildId,16,int`r`nCachedName,17,BSTR`r`nCachedValue,18,BSTR`r`nCachedDescription,19,BSTR`r`nCachedRole,20,DWORD`r`nCachedState,21,DWORD`r`nCachedHelp,22,BSTR`r`nCachedKeyboardShortcut,23,BSTR`r`nCachedDefaultAction,25,BSTR"

	Select(flags=3) {
		return UIA_Hr(DllCall(this.__Vt(3), "ptr",this.__Value, "int",flags))
	}
	DoDefaultAction() {
		return UIA_Hr(DllCall(this.__Vt(4), "ptr",this.__Value))
	}
	SetValue(value) {
		return UIA_Hr(DllCall(this.__Vt(5), "ptr",this.__Value, "ptr",&value))
	}
	GetCurrentSelection() { ; Not correct
		;~ if (hr:=DllCall(this.__Vt(14), "ptr",this.__Value, "ptr*",array))=0
			;~ return new UIA_ElementArray(array)
		;~ else
			;~ MsgBox,, Error, %hr%
	}
	;~ GetCachedSelection	24	IUIAutomationElementArray
	GetIAccessible() {
	/*	This method returns NULL if the underlying implementation of the UI Automation element is not a native
	Microsoft Active Accessibility server; that is, if a client attempts to retrieve the IAccessible interface
	for an element originally supported by a proxy object from OLEACC.dll, or by the UIA-to-MSAA Bridge.
	*/
		return UIA_Hr(DllCall(this.__Vt(26), "ptr",this.__Value, "ptr*",pacc))&&pacc? ComObj(9,pacc,1):
	}
}
class UIA_MultipleViewPattern extends UIA_Base {
	;~ http://msdn.microsoft.com/en-us/library/windows/desktop/ee696099
	static	__IID := "{8d253c91-1dc5-4bb5-b18f-ade16fa495e8}"
		,	__PatternID := 10008
		,	__Properties := "CurrentCurrentView,5,int`r`nCachedCurrentView,7,int"

	GetViewName(view) { ; need to release BSTR?
		return UIA_Hr(DllCall(this.__Vt(3), "ptr",this.__Value, "int",view, "ptr*",name))? StrGet(name):
	}
	SetCurrentView(view) {
		return UIA_Hr(DllCall(this.__Vt(4), "ptr",this.__Value, "int",view))
	}
	GetCurrentSupportedViews() {
		return UIA_Hr(DllCall(this.__Vt(6), "ptr",this.__Value, "ptr*",out))? ComObj(0x2003,out,1):
	}
	GetCachedSupportedViews() {
		return UIA_Hr(DllCall(this.__Vt(8), "ptr",this.__Value, "ptr*",out))? ComObj(0x2003,out,1):
	}
}
class UIA_RangeValuePattern extends UIA_Base {
	;~ http://msdn.microsoft.com/en-us/library/windows/desktop/ee696147
	static	__IID := "{59213f4f-7346-49e5-b120-80555987a148}"
		,	__PatternID := 10003
		,	__Properties := "CurrentValue,4,double`r`nCurrentIsReadOnly,5,BOOL`r`nCurrentMaximum,6,double`r`nCurrentMinimum,7,double`r`nCurrentLargeChange,8,double`r`nCurrentSmallChange,9,double`r`nCachedValue,10,double`r`nCachedIsReadOnly,11,BOOL`r`nCachedMaximum,12,double`r`nCachedMinimum,13,double`r`nCachedLargeChange,14,double`r`nCachedSmallChange,15,double"

	SetValue(val) {
		return UIA_Hr(DllCall(this.__Vt(3), "ptr",this.__Value, "double",val))
	}
}
class UIA_ScrollItemPattern extends UIA_Base {
	;~ http://msdn.microsoft.com/en-us/library/windows/desktop/ee696165
	static	__IID := "{b488300f-d015-4f19-9c29-bb595e3645ef}"
		,	__PatternID := 10017

	ScrollIntoView() {
		return UIA_Hr(DllCall(this.__Vt(3), "ptr",this.__Value))
	}
}
class UIA_ScrollPattern extends UIA_Base {
	;~ http://msdn.microsoft.com/en-us/library/windows/desktop/ee696167
	static	__IID := "{88f4d42a-e881-459d-a77c-73bbbb7e02dc}"
		,	__PatternID := 10004
		,	__Properties := "CurrentHorizontalScrollPercent,5,double`r`nCurrentVerticalScrollPercent,6,double`r`nCurrentHorizontalViewSize,7,double`r`CurrentHorizontallyScrollable,9,BOOL`r`nCurrentVerticallyScrollable,10,BOOL`r`nCachedHorizontalScrollPercent,11,double`r`nCachedVerticalScrollPercent,12,double`r`nCachedHorizontalViewSize,13,double`r`nCachedVerticalViewSize,14,double`r`nCachedHorizontallyScrollable,15,BOOL`r`nCachedVerticallyScrollable,16,BOOL"

	Scroll(horizontal, vertical) {
		return UIA_Hr(DllCall(this.__Vt(3), "ptr",this.__Value, "uint",horizontal, "uint",vertical))
	}
	SetScrollPercent(horizontal, vertical) {
		return UIA_Hr(DllCall(this.__Vt(4), "ptr",this.__Value, "double",horizontal, "double",vertical))
	}
/*	UIA_ScrollPatternNoScroll	=	-1
	ScrollAmount_LargeDecrement	= 0,
	ScrollAmount_SmallDecrement	= 1,
	ScrollAmount_NoAmount	= 2,
	ScrollAmount_LargeIncrement	= 3,
	ScrollAmount_SmallIncrement	= 4
*/
}
;~ class UIA_SelectionItemPattern extends UIA_Base {10010
;~ class UIA_SelectionPattern extends UIA_Base {10001
;~ class UIA_SpreadsheetItemPattern extends UIA_Base {10027
;~ class UIA_SpreadsheetPattern extends UIA_Base {10026
;~ class UIA_StylesPattern extends UIA_Base {10025
;~ class UIA_SynchronizedInputPattern extends UIA_Base {10021
;~ class UIA_TableItemPattern extends UIA_Base {10013
;~ class UIA_TablePattern extends UIA_Base {10012
;~ class UIA_TextChildPattern extends UIA_Base {10029
;~ class UIA_TextEditPattern extends UIA_Base {10032
;~ class UIA_TextPattern extends UIA_Base {10014
;~ class UIA_TextPattern2 extends UIA_Base {10024
;~ class UIA_TogglePattern extends UIA_Base {10015
;~ class UIA_TransformPattern extends UIA_Base {10016
;~ class UIA_TransformPattern2 extends UIA_Base {10028
;~ class UIA_ValuePattern extends UIA_Base {10002
;~ class UIA_VirtualizedItemPattern extends UIA_Base {10020
;~ class UIA_WindowPattern extends UIA_Base {10009
;~ class UIA_AnnotationPattern extends UIA_Base {10023		; Windows 8 [desktop apps only]
;~ class UIA_DragPattern extends UIA_Base {10030			; Windows 8 [desktop apps only]
;~ class UIA_DropTargetPattern extends UIA_Base {10031		; Windows 8 [desktop apps only]
/* class UIA_ObjectModelPattern extends UIA_Base {			; Windows 8 [desktop apps only]
	;~ http://msdn.microsoft.com/en-us/library/windows/desktop/hh437262(v=vs.85).aspx
	static	__IID := "{71c284b3-c14d-4d14-981e-19751b0d756d}"
		,	__PatternID := 10022

	GetUnderlyingObjectModel() {
		return UIA_Hr(DllCall(this.__Vt(3), "ptr",this.__Value))
	}
}
*/

;~ class UIA_PatternHandler extends UIA_Base {
;~ class UIA_PatternInstance extends UIA_Base {
;~ class UIA_TextRange extends UIA_Base {
;~ class UIA_TextRange2 extends UIA_Base {
;~ class UIA_TextRangeArray extends UIA_Base {




{  ;~ UIA Functions
	UIA_Interface() {
		try {
			if uia:=ComObjCreate("{ff48dba4-60ef-4201-aa87-54103eef594e}","{30cbe57d-d9d0-452a-ab13-7ac5ac4825ee}")
				return uia:=new UIA_Interface(uia), uia.base.base.__UIA:=uia
			throw "UIAutomation Interface failed to initialize."
		} catch e
			MsgBox, 262160, UIA Startup Error, % IsObject(e)?"IUIAutomation Interface is not registered.":e.Message
	}
	UIA_Hr(hr) {
		;~ http://blogs.msdn.com/b/eldar/archive/2007/04/03/a-lot-of-hresult-codes.aspx
		static err:={0x8000FFFF:"Catastrophic failure.",0x80004001:"Not implemented.",0x8007000E:"Out of memory.",0x80070057:"One or more arguments are not valid.",0x80004002:"Interface not supported.",0x80004003:"Pointer not valid.",0x80070006:"Handle not valid.",0x80004004:"Operation aborted.",0x80004005:"Unspecified error.",0x80070005:"General access denied.",0x800401E5:"The object identified by this moniker could not be found.",0x80040201:"UIA_E_ELEMENTNOTAVAILABLE",0x80040200:"UIA_E_ELEMENTNOTENABLED",0x80131509:"UIA_E_INVALIDOPERATION",0x80040202:"UIA_E_NOCLICKABLEPOINT",0x80040204:"UIA_E_NOTSUPPORTED",0x80040203:"UIA_E_PROXYASSEMBLYNOTLOADED"} ; //not completed
		if hr&&(hr&=0xFFFFFFFF) {
			RegExMatch(Exception("",-2).what,"(\w+).(\w+)",i)
			throw Exception(UIA_Hex(hr) " - " err[hr], -2, i2 "  (" i1 ")")
		}
		return !hr
	}
	UIA_NotImplemented() {
		RegExMatch(Exception("",-2).What,"(\D+)\.(\D+)",m)
		MsgBox, 262192, UIA Message, Class:`t%m1%`nMember:`t%m2%`n`nMethod has not been implemented yet.
	}
	UIA_ElementArray(p, uia="") { ; should AHK Object be 0 or 1 based?
		a:=new UIA_ElementArray(p),out:=[]
		Loop % a.Length
			out[A_Index]:=a.GetElement(A_Index-1)
		return out, out.base:={UIA_ElementArray:a}
	}
	UIA_RectToObject(ByRef r) { ; rect.__Value work with DllCalls?
		static b:={__Class:"object",__Type:"RECT",Struct:Func("UIA_RectStructure")}
		return {l:NumGet(r,0,"Int"),t:NumGet(r,4,"Int"),r:NumGet(r,8,"Int"),b:NumGet(r,12,"Int"),base:b}
	}
	UIA_RectStructure(this, ByRef r) {
		static sides:="ltrb"
		VarSetCapacity(r,16)
		Loop Parse, sides
			NumPut(this[A_LoopField],r,(A_Index-1)*4,"Int")
	}
	UIA_SafeArraysToObject(keys,values) {
	;~	1 dim safearrays w/ same # of elements
		out:={}
		for key in keys
			out[key]:=values[A_Index-1]
		return out
	}
	UIA_Hex(p) {
		setting:=A_FormatInteger
		SetFormat,IntegerFast,H
		out:=p+0 ""
		SetFormat,IntegerFast,%setting%
		return out
	}
	UIA_GUID(ByRef GUID, sGUID) { ;~ Converts a string to a binary GUID and returns its address.
		VarSetCapacity(GUID,16,0)
		return DllCall("ole32\CLSIDFromString", "wstr",sGUID, "ptr",&GUID)>=0?&GUID:""
	}
	UIA_Variant(ByRef var,type=0,val=0) {
		; Does a variant need to be cleared? If it uses SysAllocString?
		return (VarSetCapacity(var,8+2*A_PtrSize)+NumPut(type,var,0,"short")+NumPut(type=8? DllCall("oleaut32\SysAllocString", "ptr",&val):val,var,8,"ptr"))*0+&var
	}
	UIA_IsVariant(ByRef vt, ByRef type="") {
		size:=VarSetCapacity(vt),type:=NumGet(vt,"UShort")
		return size>=16&&size<=24&&type>=0&&(type<=23||type|0x2000)
	}
	UIA_Type(ByRef item, ByRef info) {
	}
	UIA_VariantData(ByRef p, flag=1) {
		; based on Sean's COM_Enumerate function
		; need to clear varaint? what if you still need it (flag param)?
		return !UIA_IsVariant(p,vt)?"Invalid Variant"
				:vt=3?NumGet(p,8,"int")
				:vt=8?StrGet(NumGet(p,8))
				:vt=9||vt=13||vt&0x2000?ComObj(vt,NumGet(p,8),flag)
				:vt<0x1000&&UIA_VariantChangeType(&p,&p)=0?StrGet(NumGet(p,8)) UIA_VariantClear(&p)
				:NumGet(p,8)
	/*
		VT_EMPTY     =      0  		; No value
		VT_NULL      =      1 		; SQL-style Null
		VT_I2        =      2 		; 16-bit signed int
		VT_I4        =      3 		; 32-bit signed int
		VT_R4        =      4 		; 32-bit floating-point number
		VT_R8        =      5 		; 64-bit floating-point number
		VT_CY        =      6 		; Currency
		VT_DATE      =      7  		; Date
		VT_BSTR      =      8 		; COM string (Unicode string with length prefix)
		VT_DISPATCH  =      9 		; COM object
		VT_ERROR     =    0xA  10	; Error code (32-bit integer)
		VT_BOOL      =    0xB  11	; Boolean True (-1) or False (0)
		VT_VARIANT   =    0xC  12	; VARIANT (must be combined with VT_ARRAY or VT_BYREF)
		VT_UNKNOWN   =    0xD  13	; IUnknown interface pointer
		VT_DECIMAL   =    0xE  14	; (not supported)
		VT_I1        =   0x10  16	; 8-bit signed int
		VT_UI1       =   0x11  17	; 8-bit unsigned int
		VT_UI2       =   0x12  18	; 16-bit unsigned int
		VT_UI4       =   0x13  19	; 32-bit unsigned int
		VT_I8        =   0x14  20	; 64-bit signed int
		VT_UI8       =   0x15  21	; 64-bit unsigned int
		VT_INT       =   0x16  22	; Signed machine int
		VT_UINT      =   0x17  23	; Unsigned machine int
		VT_RECORD    =   0x24  36	; User-defined type
		VT_ARRAY     = 0x2000  		; SAFEARRAY
		VT_BYREF     = 0x4000  		; Pointer to another type of value
					 = 0x1000  4096
		COM_VariantChangeType(pvarDst, pvarSrc, vt=8) {
			return DllCall("oleaut32\VariantChangeTypeEx", "ptr",pvarDst, "ptr",pvarSrc, "Uint",1024, "Ushort",0, "Ushort",vt)
		}
		COM_VariantClear(pvar) {
			DllCall("oleaut32\VariantClear", "ptr",pvar)
		}
		COM_SysAllocString(str) {
			Return	DllCall("oleaut32\SysAllocString", "Uint", &str)
		}
		COM_SysFreeString(pstr) {
				DllCall("oleaut32\SysFreeString", "Uint", pstr)
		}
		COM_SysString(ByRef wString, sString) {
			VarSetCapacity(wString,4+nLen:=2*StrLen(sString))
			Return	DllCall("kernel32\lstrcpyW","Uint",NumPut(nLen,wString),"Uint",&sString)
		}
	*/
	}
	UIA_VariantChangeType(pvarDst, pvarSrc, vt=8) { ; written by Sean
		return DllCall("oleaut32\VariantChangeTypeEx", "ptr",pvarDst, "ptr",pvarSrc, "Uint",1024, "Ushort",0, "Ushort",vt)
	}
	UIA_VariantClear(pvar) { ; Written by Sean
		DllCall("oleaut32\VariantClear", "ptr",pvar)
	}
}
MsgBox(msg) {
	MsgBox %msg%
}

/*
enum TreeScope
    {	TreeScope_Element	= 0x1,
	TreeScope_Children	= 0x2,
	TreeScope_Descendants	= 0x4,
	TreeScope_Parent	= 0x8,
	TreeScope_Ancestors	= 0x10,
	TreeScope_Subtree	= ( ( TreeScope_Element | TreeScope_Children )  | TreeScope_Descendants )
    } ;
DllCall("oleaut32\SafeArrayGetVartype", "ptr*",ComObjValue(SafeArray), "uint*",pvt)
HRESULT SafeArrayGetVartype(
  _In_   SAFEARRAY *psa,
  _Out_  VARTYPE *pvt
);
DllCall("oleaut32\SafeArrayDestroy", "ptr",ComObjValue(SafeArray))
HRESULT SafeArrayDestroy(
  _In_  SAFEARRAY *psa
);
*/


  ;	Added
  
UIA_ControlType(n) {
	Static name:={50000:"Button",50001:"Calendar",50002:"CheckBox",50003:"ComboBox",50004:"Edit",50005:"Hyperlink",50006:"Image",50007:"ListItem",50008:"List",50009:"Menu"
	,50010:"MenuBar",50011:"MenuItem",50012:"ProgressBar",50013:"RadioButton",50014:"ScrollBar",50015:"Slider",50016:"Spinner",50017:"StatusBar",50018:"Tab",50019:"TabItem"
	,50020:"Text",50021:"ToolBar",50022:"ToolTip",50023:"Tree",50024:"TreeItem",50025:"Custom",50026:"Group",50027:"Thumb",50028:"DataGrid",50029:"DataItem",50030:"Document"
	,50031:"SplitButton",50032:"Window",50033:"Pane",50034:"Header",50035:"HeaderItem",50036:"Table",50037:"TitleBar",50038:"Separator"}
	return name[n]
}

	; _________________________________________________ End _________________________________________________

	;)
