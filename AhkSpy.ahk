	;  AhkSpy
	
	;  Автор - serzh82saratov
	;  E-Mail: serzh82saratov@mail.ru
	
	;  Спасибо wisgest за помощь в создании HTML интерфейса
	;  Также благодарность teadrinker, YMP и Irbis за их решения
	;  Описание - http://forum.script-coding.com/viewtopic.php?pid=72459#p72459
	;  Обсуждение - http://forum.script-coding.com/viewtopic.php?pid=72244#p72244
	;  GitHub - https://github.com/serzh82saratov/AhkSpy/blob/master/AhkSpy.ahk

#NoTrayIcon
#SingleInstance Force
#NoEnv
SetBatchLines, -1
ListLines, Off
DetectHiddenWindows, On
CoordMode, Pixel

Global AhkSpyVersion := 2.25
Gosub, CheckAhkVersion
Menu, Tray, UseErrorLevel
Menu, Tray, Icon, Shell32.dll, % A_OSVersion = "WIN_XP" ? 222 : 278

Global ThisMode := "Mouse"												;  Стартовый режим - Win|Mouse|Hotkey
, MemoryFontSize := IniRead("MemoryFontSize", 0)
, FontSize := MemoryFontSize ? IniRead("FontSize", "15") : 15			;  Размер шрифта
, FontFamily :=  "Arial"												;  Шрифт - Times New Roman | Georgia | Myriad Pro | Arial
, ColorFont := ""														;  Цвет шрифта
, ColorBg := ColorBgOriginal := "F0F0F0"								;  Цвет фона
, ColorBgPaused := "E4E4E4"												;  Цвет фона при паузе
, ColorDelimiter := "E14B30"											;  Цвет шрифта разделителя заголовков и параметров
, ColorTitle := "27419B"												;  Цвет шрифта заголовка
, ColorParam := "189200"												;  Цвет шрифта параметров
, # := "&#9642"															;  Символ разделителя заголовков - &#8226 | &#9642

, DP := "  <span id='delimiter' style='color: " ColorDelimiter "'>" # "</span>  ", D1, D2, DB
, copy_button := "<span contenteditable='false' unselectable='on'><button id='copy_button'> copy </button></span>"
, ThisMode := IniRead("StartMode", "Mouse"), ThisMode := ThisMode = "LastMode" ? IniRead("LastMode", "Mouse") : ThisMode
, ActiveNoPause := IniRead("ActiveNoPause", 0), MemoryPos := IniRead("MemoryPos", 0), MemorySize := IniRead("MemorySize", 0)
, MemoryZoomSize := IniRead("MemoryZoomSize", 0), MemoryStateZoom := IniRead("MemoryStateZoom", 0)
, StateLight := IniRead("StateLight", 1), StateLightAcc := IniRead("StateLightAcc", 1)
, StateLightMarker := IniRead("StateLightMarker", 1), StateUpdate := IniRead("StateUpdate", 1)
, StateAllwaysSpot := IniRead("AllwaysSpot", 0), ScrollPos := {}, AccCoord := [], oOther := {}, oFind := {}, Edits := []
, hGui, hActiveX, hMarkerGui, hMarkerAccGui, hFindGui, oDoc, ShowMarker, isFindView, isIE, isPaused, w_ShowStyles, MsgAhkSpyZoom, Sleep
, HTML_Win, HTML_Mouse, HTML_Hotkey, o_edithotkey, o_editkeyname, rmCtrlX, rmCtrlY, widthTB, HeigtButton, FullScreenMode
, pause_button := "<span contenteditable='false' unselectable='on'><button id='pause_button'> pause </button></span>"
, set_button_pos := "<span contenteditable='false' unselectable='on'><button id='set_button_pos' style='overflow: visible'>"
, set_button_mouse_pos := "<span contenteditable='false' unselectable='on'><button id='set_button_mouse_pos' style='overflow: visible'>"
, set_button_focus_ctrl := "<span contenteditable='false' unselectable='on'><button id='set_button_focus_ctrl' style='overflow: visible'>"

TitleTextP2 := "     ( Shift+Tab - Freeze | RButton - CopySelected | Pause - Pause )     v" AhkSpyVersion
BLGroup := ["Backlight allways","","Backlight hold shift button"]
HeightStart := 550			;  Высота окна при старте
HeigtButton := 32			;  Высота кнопок
wKey := 142					;  Ширина кнопок
wColor := wKey//2			;  Ширина цветного фрагмента
RangeTimer := 100			;  Период опроса данных, увеличьте на слабом ПК
Loop 24
	D1 .= #
Loop 20
	D2 .= D1
D1 := "<span id='Delimiter' style='color: " ColorDelimiter "'>" D1 "</span>"
D2 := "<span id='Delimiter' style='color: " ColorDelimiter "'>" D2 "</span>"
DB := "<span id='Delimiter' style='color: " ColorDelimiter "'>" # # # # # # # # # # # # "</span>"

Global m_run_AccViewer := ExtraFile("AccViewer Source")
	? DB " <span contenteditable='false' unselectable='on'><button id='run_AccViewer'> run accviewer </button></span> " : ""
	, m_run_iWB2Learner := ExtraFile("iWB2 Learner")
	? DB " <span contenteditable='false' unselectable='on'><button id='run_iWB2Learner'> run iwb2 learner </button></span> " : ""
	, m_run_AhkSpyZoom := ExtraFile("AhkSpyZoom")
	? " " DB " <span contenteditable='false' unselectable='on'><button id='run_AhkSpyZoom'> zoom </button></span>" : ""

FixIE(0)

Gui, +AlwaysOnTop +HWNDhGui +ReSize -DPIScale
Gui, Color, %ColorBgPaused%
Gui, Add, ActiveX, Border voDoc HWNDhActiveX x0 y+0, HTMLFile

ComObjError(false), ComObjConnect(oDoc, Events)
OnMessage(0x133, "WM_CTLCOLOREDIT")
OnMessage(0x201, "WM_LBUTTONDOWN")
OnMessage(0xA1, "WM_NCLBUTTONDOWN")
OnMessage(0x7B, "WM_CONTEXTMENU")
OnMessage(0x6, "WM_ACTIVATE")
OnMessage(0x03, "WM_MOVE")
OnExit, Exit
OnMessage(MsgAhkSpyZoom := DllCall("RegisterWindowMessage", "Str", "MsgAhkSpyZoom"), "MsgZoom")
DllCall("RegisterShellHookWindow", "Ptr", A_ScriptHwnd)
OnMessage(DllCall("RegisterWindowMessage", "str", "SHELLHOOK"), "ShellProc")
DllCall("PostMessage", "Ptr", A_ScriptHWND, "UInt", 0x50, "UInt", 0, "UInt", 0x409) ; eng layout

Gui, TB: +HWNDhTBGui -Caption -DPIScale +Parent%hGui% +E0x08000000
Gui, TB: Font, % " s" (A_ScreenDPI = 120 ? 8 : 10), Verdana
Gui, TB: Add, Button, x0 y0 h%HeigtButton% w%wKey% vBut1 gMode_Win, Window
Gui, TB: Add, Button, x+0 yp hp wp vBut2 gMode_Mouse, Mouse && Control
Gui, TB: Add, Progress, x+0 yp hp w%wColor% vColorProgress cWhite, 100
Gui, TB: Add, Button, x+0 yp hp w%wKey% vBut3 gMode_Hotkey, Button
Gui, TB: Show, % "x0 y0 NA h" HeigtButton " w" widthTB := wKey*3+wColor

Gui, F: +HWNDhFindGui -Caption -DPIScale +Parent%hGui%
Gui, F: Color, %ColorBgPaused%
Gui, F: Font, % " s" (A_ScreenDPI = 120 ? 10 : 12)
Gui, F: Add, Edit, x1 y0 w180 h26 gFindNew WantTab HWNDhFindEdit
SendMessage, 0x1501, 1, "Find to page",, ahk_id %hFindEdit%   ; EM_SETCUEBANNER
Gui, F: Add, UpDown, -16 Horz Range0-1 x+0 yp h26 w52 gFindNext vFindUpDown
GuiControl, F: Move, FindUpDown, h26 w52
Gui, F: Font, % (A_ScreenDPI = 120 ? "" : "s10")
Gui, F: Add, Text, x+10 yp+1 h24 c2F2F2F +0x201 gFindOption, % " case sensitive "
Gui, F: Add, Text, x+10 yp hp c2F2F2F +0x201 gFindOption, % " whole word "
Gui, F: Add, Text, x+3 yp hp +0x201 w52 vFindMatches
Gui, F: Add, Button, % "+0x300 +0xC00 y3 h20 w20 gFindHide x" widthTB - 21, X

Gui, M: Margin, 0, 0
Gui, M: -DPIScale +AlwaysOnTop +HWNDhMarkerGui +E0x08000000 +E0x20 -Caption +Owner
Gui, M: Color, E14B30
WinSet, TransParent, 250, ahk_id %hMarkerGui%
Gui, AcM: Margin, 0, 0
Gui, AcM: -DPIScale +AlwaysOnTop +HWNDhMarkerAccGui +E0x08000000 +E0x20 -Caption +Owner
Gui, AcM: Color, 26419F
WinSet, TransParent, 250, ahk_id %hMarkerAccGui%
ShowMarker(0, 0, 0, 0, 0), ShowAccMarker(0, 0, 0, 0, 0), HideMarker(), HideAccMarker()

Menu, Sys, Add, Backlight allways, Sys_Backlight
Menu, Sys, Add, Backlight hold shift button, Sys_Backlight
Menu, Sys, Check, % BLGroup[StateLight]
Menu, Sys, Add
Menu, Sys, Add, Window or control backlight, Sys_WClight
Menu, Sys, % StateLightMarker ? "Check" : "UnCheck", Window or control backlight
Menu, Sys, Add, Acc object backlight, Sys_Acclight
Menu, Sys, % StateLightAcc ? "Check" : "UnCheck", Acc object backlight
Menu, Sys, Add
Menu, Sys, Add, Spot together (low speed), Spot_together
Menu, Sys, % StateAllwaysSpot ? "Check" : "UnCheck", Spot together (low speed)
Menu, Sys, Add, Work with the active window, Active_No_Pause
Menu, Sys, % ActiveNoPause ? "Check" : "UnCheck", Work with the active window
Menu, Sys, Add
If !A_IsCompiled
{
	Menu, Sys, Add, Check updates, CheckUpdate
	Menu, Sys, % StateUpdate ? "Check" : "UnCheck", Check updates
	Menu, Sys, Add
	If StateUpdate
		SetTimer, UpdateAhkSpy, -1000
}
Else
	StateUpdate := IniWrite(0, "StateUpdate")
Menu, Startmode, Add, Window, SelStartMode
Menu, Startmode, Add, Mouse && Control, SelStartMode
Menu, Startmode, Add, Button, SelStartMode
Menu, Startmode, Add
Menu, Startmode, Add, Last Mode, SelStartMode
Menu, Sys, Add, Start mode, :Startmode
Menu, Startmode, Check, % {"Win":"Window","Mouse":"Mouse && Control","Hotkey":"Button","LastMode":"Last Mode"}[IniRead("StartMode", "Mouse")]
Menu, Sys, Add
Menu, Sys, Add, Remember position, MemoryPos
Menu, Sys, % MemoryPos ? "Check" : "UnCheck", Remember position
Menu, Sys, Add, Remember size, MemorySize
Menu, Sys, % MemorySize ? "Check" : "UnCheck", Remember size
Menu, Sys, Add, Remember font size, MemoryFontSize
Menu, Sys, % MemoryFontSize ? "Check" : "UnCheck", Remember font size


If m_run_AhkSpyZoom !=
{
	Menu, Sys, Add
	Menu, Sys, Add, Remember state zoom, MemoryStateZoom
	Menu, Sys, % MemoryStateZoom ? "Check" : "UnCheck", Remember state zoom
	Menu, Sys, Add, Remember zoom size, MemoryZoomSize
	Menu, Sys, % MemoryZoomSize ? "Check" : "UnCheck", Remember zoom size
}
Menu, Sys, Add
Menu, Sys, Add, Full screen, FullScreenMode
Menu, Sys, Add, Default size, DefaultSize
Menu, Sys, Add, Open script dir, Sys_OpenScriptDir
Menu, Sys, Add
Menu, Help, Add, About, Sys_Help
Menu, Help, Add
If FileExist(SubStr(A_AhkPath,1,InStr(A_AhkPath,"\",,0,1)) "AutoHotkey.chm")
	Menu, Help, Add, AutoHotKey help file, LaunchHelp
Menu, Help, Add, AutoHotKey official help online, Sys_Help
Menu, Help, Add, AutoHotKey russian help online, Sys_Help
Menu, Sys, Add, Help, :Help
Menu, Sys, Add
Menu, Sys, Add, Reload, Reload
Menu, Sys, Add, Suspend hotkeys, Suspend
Menu, Sys, Add, Pause, PausedScript
Menu, Sys, Add, Exit, Exit
Menu, Sys, Add
Menu, Sys, Add, Find to page, FindView
Menu, Sys, Color, % ColorBgOriginal
Gui, Show, % "NA" (MemoryPos ? " x" IniRead("MemoryPosX", "Center") " y" IniRead("MemoryPosY", "Center") : "")
. (MemorySize ? " h" IniRead("MemorySizeH", HeightStart) " w" IniRead("MemorySizeW", widthTB) : " h" HeightStart " w" widthTB)
Gui, % "+MinSize" widthTB "x" HeigtButton

Hotkey_Init("Write_Hotkey", "MLRJ")
Gosub, Mode_%ThisMode%

If (m_run_AhkSpyZoom != "" && MemoryStateZoom && IniRead("ZoomShow", 0))
	Events.AhkSpyZoomShow()
#Include *i %A_ScriptDir%\AhkSpyInclude.ahk
Return

	; _________________________________________________ Hotkey`s _________________________________________________

#If ActiveNoPause

+Tab:: Goto PausedScript

#If (Sleep != 1 && !isPaused && ThisMode != "Hotkey")

+Tab::
	(ThisMode = "Mouse" ? (Spot_Mouse() (StateAllwaysSpot ? Spot_Win() : 0) Write_Mouse()) : (Spot_Win() (StateAllwaysSpot ? Spot_Mouse() : 0) Write_Win()))
	If !WinActive("ahk_id" hGui)
	{
		ZoomMsg(1)
		WinActivate ahk_id %hGui%
		GuiControl, 1:Focus, oDoc
	}
	Else
		ZoomMsg(2)
	Return

#If ShowMarker && (StateLight = 3 || WinActive("ahk_id" hGui))

~RShift Up::
~LShift Up:: HideMarker(), HideAccMarker()

#If Sleep != 1

Break::
Pause::
PausedScript:
	isPaused := !isPaused
	oDoc.body.style.background := (ColorBg := isPaused ? ColorBgPaused : ColorBgOriginal)
	Try SetTimer, Loop_%ThisMode%, % isPaused ? "Off" : "On"
	If (ThisMode = "Hotkey" && WinActive("ahk_id" hGui))
		Hotkey_Hook(!isPaused)
	If (isPaused && !WinActive("ahk_id" hGui))
		(ThisMode = "Mouse" ? Spot_Win() : ThisMode = "Win" ? Spot_Mouse() : 0)
	HideMarker(), HideAccMarker()
	Menu, Sys, % isPaused ? "Check" : "UnCheck", Pause
	ZoomMsg(isPaused || (!ActiveNoPause && WinActive("ahk_id" hGui)) ? 1 : 0)
	ZoomMsg(7, isPaused)
	Return

~RShift Up::
~LShift Up:: CheckHideMarker()

#If WinActive("ahk_id" hGui)

^WheelUp::
^WheelDown::
	FontSize := InStr(A_ThisHotkey, "Up") ? ++FontSize : --FontSize
	FontSize := FontSize < 1 ? 1 : FontSize > 32 ? 32 : FontSize
	oDoc.getElementById("pre").style.fontSize := FontSize
	toTitle := "FontSize: " FontSize
	SendMessage, 0xC, 0, &toTitle, , ahk_id %hGui%
	SetTimer, TitleShow, -1000
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

F5:: oDoc.body.innerHTML := HTML_%ThisMode%, oDoc.body.scrollLeft := 0					;  Return original HTML

F6:: AppsKey

F7::Menu, Sys, Show, 5, 5

!Space:: SetTimer, ShowSys, -1

Esc::
	If isFindView
		FindHide()
	Else If FullScreenMode
		FullScreenMode()
	Else
		GoSub, Exit
	Return

F8::
^vk46:: FindView()											;  Ctrl+F

F11::FullScreenMode()

#If WinActive("ahk_id" hGui) && IsIEFocus()

^vk5A:: oDoc.execCommand("Undo")							;  Ctrl+Z

^vk59:: oDoc.execCommand("Redo")							;  Ctrl+Y

^vk43:: Clipboard := oDoc.selection.createRange().text		;  Ctrl+C

+RButton::
^vk56:: oDoc.execCommand("Paste")							;  Ctrl+V

~^vk41:: oDoc.execCommand("SelectAll")						;  Ctrl+A


^vk58:: oDoc.execCommand("Cut")								;  Ctrl+X

Del:: oDoc.execCommand("Delete")							;  Delete

Enter:: oDoc.selection.createRange().text := " `n"			;  &shy

Tab:: oDoc.selection.createRange().text := "    "			;  &emsp

#If WinActive("ahk_id" hGui) && ExistSelectedText(CopyText)

^+RButton::
RButton::
CopyText:
	ToolTip("copy", 300)
	If (A_ThisHotkey = "^+RButton" && CopyText ~= "(x|y|w|h|" chr(178) ")-*\d+")
		CopyText := RegExReplace(CopyText, "i)(x|y|w|h|#|\s|" chr(178) ")+", " ")
		, CopyText := TRim(CopyText, " "), CopyText := RegExReplace(CopyText, "(\s|,)+", ", ")
	Clipboard := CopyText
	StringReplace, toTitle, CopyText, `r`n, , 1
	SendMessage, 0xC, 0, &toTitle, , ahk_id %hGui%
	SetTimer, TitleShow, -1000
	oDoc.selection.createRange().select()
	Return

#If (Sleep != 1 && !DllCall("IsWindowVisible", "Ptr", oOther.hZoom))

+#Up::MouseStep(0, -1)
+#Down::MouseStep(0, 1)
+#Left::MouseStep(-1, 0)
+#Right::MouseStep(1, 0)

#If

	; _________________________________________________ Mode_Win _________________________________________________

Mode_Win:
	If A_GuiControl
		GuiControl, 1:Focus, oDoc
	oDoc.body.createTextRange().execCommand("RemoveFormat")
	GuiControl, TB: -0x0001, But1
	If ThisMode = Win
		oDoc.body.scrollLeft := 0
	If (ThisMode = "Hotkey")
		Hotkey_Hook(0)
	Try SetTimer, Loop_%ThisMode%, Off
	ScrollPos[ThisMode,1] := oDoc.body.scrollLeft, ScrollPos[ThisMode,2] := oDoc.body.scrollTop
	If ThisMode != Win
		HTML_%ThisMode% := oDoc.body.innerHTML
	ThisMode := "Win"
	If (HTML_Win = "")
		Spot_Win(1)
	TitleText := "AhkSpy - Window" TitleTextP2
	SendMessage, 0xC, 0, &TitleText, , ahk_id %hGui%
	Write_Win(), oDoc.body.scrollLeft := ScrollPos[ThisMode,1], oDoc.body.scrollTop := ScrollPos[ThisMode,2]
	IniWrite(ThisMode, "LastMode")
	If isFindView
		FindSearch(1)

Loop_Win:
	If ((WinActive("ahk_id" hGui) && !ActiveNoPause) || Sleep = 1)
		GoTo Repeat_Loop_Win
	If Spot_Win()
		Write_Win(), StateAllwaysSpot ? Spot_Mouse() : 0
Repeat_Loop_Win:
	If !isPaused
		SetTimer, Loop_Win, -%RangeTimer%
	Return

Spot_Win(NotHTML=0)  {
	Static PrWinPID, ComLine
	If NotHTML
		GoTo HTML_Win
	MouseGetPos,,,WinID
	If (WinID = hGui || WinID = oOther.hZoom)
		Return HideMarker(), HideAccMarker()
	WinGetTitle, WinTitle, ahk_id %WinID%
	WinTitle := TransformHTML(WinTitle)
	WinGetPos, WinX, WinY, WinWidth, WinHeight, ahk_id %WinID%
	WinX2 := WinX + WinWidth, WinY2 := WinY + WinHeight
	WinGetClass, WinClass, ahk_id %WinID%
	WinGet, WinProcessPath, ProcessPath, ahk_id %WinID%
	Loop, %WinProcessPath%
		WinProcessPath = %A_LoopFileLongPath%
	SplitPath, WinProcessPath, WinProcessName
	WinGet, WinPID, PID, ahk_id %WinID%
	If (WinPID != PrWinPID)
		ComLine := TransformHTML(GetCommandLineProc(WinPID)), PrWinPID := WinPID
	If (WinClass ~= "(Cabinet|Explore)WClass")
		CLSID := GetCLSIDExplorer(WinID)
	WinGet, WinCountProcess, Count, ahk_pid %WinPID%
	WinGet, WinStyle, Style, ahk_id %WinID%
	WinGet, WinExStyle, ExStyle, ahk_id %WinID%
	WinGet, WinTransparent, Transparent, ahk_id %WinID%
	If WinTransparent !=
		WinTransparent := "`n<span id='param'>Transparent:  </span>" WinTransparent
	WinGet, WinTransColor, TransColor, ahk_id %WinID%
	If WinTransColor !=
		WinTransColor := (WinTransparent = "" ? "`n" : DP) "<span id='param'>TransColor:  </span>" WinTransColor
	WinGet, CountControl, ControlListHwnd, ahk_id %WinID%
	RegExReplace(CountControl, "m`a)$", "", CountControl)
	GetClientPos(WinID, caX, caY, caW, caH)
	caWinRight := WinWidth - caW - caX , caWinBottom := WinHeight - caH - caY
	Loop
	{
		StatusBarGetText, SBFieldText, %A_Index%, ahk_id %WinID%
		If SBFieldText =
			Break
		SBFieldText := TransformHTML(SBFieldText)
		SBText = %SBText%<span id='param'>(%A_Index%):</span> %SBFieldText%`n
	}
	If SBText !=
		SBText := "`n" D1 " <a></a><span id='title'>( StatusBarText )</span> " D2 "`n" RTrim(SBText, "`n")
	WinGetText, WinText, ahk_id %WinID%
	If WinText !=
		WinText := "`n" D1 " <a></a><span id='title'>( Window Text )</span> " DB " " copy_button " " D2 "`n<span>" TransformHTML(WinText) "</span>"
	CoordMode, Mouse
	MouseGetPos, WinXS, WinYS
	PixelGetColor, ColorRGB, %WinXS%, %WinYS%, RGB
	GuiControl, TB: -Redraw, ColorProgress
	GuiControl, % "TB: +c" SubStr(ColorRGB, 3), ColorProgress
	GuiControl, TB: +Redraw, ColorProgress
	If w_ShowStyles
		WinStyles := GetStyles(WinStyle, WinExStyle), ButStyleTip := "hide styles"

HTML_Win:
	ButStyleTip := !w_ShowStyles ? "show styles" : ButStyleTip
	HTML_Win =
	( Ltrim
	<body id='body'><pre id='pre'; contenteditable='true'>
	%D1% <span id='title'>( Title )</span> %DB% %pause_button%%m_run_AhkSpyZoom% %D2%
	<span id='wintitle1'>%WinTitle%</span>
	%D1% <span id='title'>( Class )</span> %D2%
	<span id='wintitle2'><span id='param'>ahk_class</span> %WinClass%</span>
	%D1% <span id='title'>( ProcessName )</span> %DB% <span contenteditable='false' unselectable='on'><button id='copy_alltitle'>copy all</button></span> %D2%
	<span id='wintitle3'><span id='param'>ahk_exe</span> %WinProcessName%</span>
	%D1% <span id='title'>( ProcessPath )</span> %DB% <span contenteditable='false' unselectable='on'> <button id='w_folder'> in folder </button> <button id='paste_process_path'>paste</button> <button id='copy_button_1'> copy </button></span> %D2%
	<span id='param'>ahk_exe</span> <span id='copy_processpath'>%WinProcessPath%</span>
	%D1% <span id='title'>( CommandLine )</span> %DB% <span contenteditable='false' unselectable='on'><button id='w_command_line'>launch</button> <button id='paste_command_line'>paste</button></span> %copy_button% %D2%
	<span id='c_command_line'>%ComLine%</span>
	%D1% <span id='title'>( Position`s )</span> %D2%
	%set_button_pos%Pos:</button></span>  <span>x%WinX% y%WinY%</span>%DP%%set_button_pos%Size:</button></span>  <span>w%WinWidth% h%WinHeight%</span>%DP%<span id='param'>x&sup2;<span style='font-size: 0.7em'></span></span>%WinX2% <span id='param'>y&sup2;<span style='font-size: 0.7em'></span></span>%WinY2%%DP%%WinX%, %WinY%, %WinWidth%, %WinHeight%
	<span id='param'>Client area size:</span>  w%caW% h%caH%%DP%<span id='param'>left</span> %caX% <span id='param'>top</span> %caY% <span id='param'>right</span> %caWinRight% <span id='param'>bottom</span> %caWinBottom%
	<a></a>%D1% <span id='title'>( Other )</span> %D2%
	<span id='param'>PID:</span>  %WinPID%%DP%<span id='param'>Count window this PID:</span> %WinCountProcess%%DP%<span contenteditable='false' unselectable='on'><button id='process_close'>process close</button></span>
	<span id='param'>HWND:</span>  %WinID%%DP%<span contenteditable='false' unselectable='on'><button id='win_close'>win close</button></span>%DP%<span id='param'>Control count:</span>  %CountControl%
	<span id='param'>Style:</span><span id='c_Style'>  %WinStyle%</span>%DP%<span id='param'>ExStyle:</span><span id='c_ExStyle'>  %WinExStyle%</span>%DP%<span contenteditable='false' unselectable='on'><button id='get_styles'>%ButStyleTip%</button></span>%WinTransparent%%WinTransColor%%CLSID%<span id='AllWinStyles'>%WinStyles%</span>%SBText%%WinText%
	<a></a>%D2%</pre></body>

	<style>
	body {background-color: '#%ColorBg%'; color: '%ColorFont%'}
	pre {font-family: '%FontFamily%'; font-size: '%FontSize%'; position: absolute; top: 5px}
	#title {color: '%ColorTitle%'}
	#param {color: '%ColorParam%'}
	#set_button_pos {color: '%ColorParam%';font-size: 1em;}
	button {font-size: 0.9em; border: 1px dashed black}
	</style>
	)
	oOther.WinPID := WinPID
	oOther.WinID := WinID
	If StateLightMarker && (ThisMode = "Win") && (StateLight = 1 || (StateLight = 3 && GetKeyState("Shift", "P")))
		ShowMarker(WinX, WinY, WinWidth, WinHeight, 5)
	Return 1
}

Write_Win()  {
	oDoc.body.innerHTML := HTML_Win, oDoc.getElementById("pre").style.fontSize := FontSize
	Return 1
}

	; _________________________________________________ Mode_Mouse _________________________________________________

Mode_Mouse:
	If A_GuiControl
		GuiControl, 1:Focus, oDoc
	oDoc.body.createTextRange().execCommand("RemoveFormat")
	GuiControl, TB: -0x0001, But2
	If (ThisMode = "Hotkey")
		Hotkey_Hook(0)
	If ThisMode = Mouse
		oDoc.body.scrollLeft := 0
	Try SetTimer, Loop_%ThisMode%, Off
	ScrollPos[ThisMode,1] := oDoc.body.scrollLeft, ScrollPos[ThisMode,2] := oDoc.body.scrollTop
	If ThisMode != Mouse
		HTML_%ThisMode% := oDoc.body.innerHTML
	ThisMode := "Mouse"
	If (HTML_Mouse = "")
		Spot_Mouse(1)
	TitleText := "AhkSpy - Mouse & Control" TitleTextP2
	SendMessage, 0xC, 0, &TitleText, , ahk_id %hGui%
	Write_Mouse(), oDoc.body.scrollLeft := ScrollPos[ThisMode,1], oDoc.body.scrollTop := ScrollPos[ThisMode,2]
	IniWrite(ThisMode, "LastMode")
	If isFindView
		FindSearch(1)

Loop_Mouse:
	If (WinActive("ahk_id" hGui) && !ActiveNoPause) || Sleep = 1
		GoTo Repeat_Loop_Mouse
	If Spot_Mouse()
		Write_Mouse(), StateAllwaysSpot ? Spot_Win() : 0
Repeat_Loop_Mouse:
	If !isPaused
		SetTimer, Loop_Mouse, -%RangeTimer%
	Return

Spot_Mouse(NotHTML=0)  {
	Static
	If NotHTML
		GoTo HTML_Mouse
	WinGet, ProcessName_A, ProcessName, A
	WinGet, HWND_A, ID, A
	WinGetClass, WinClass_A, A
	CoordMode, Mouse
	MouseGetPos, MXS, MYS, WinID, tControlNN
	CoordMode, Mouse, Window
	MouseGetPos, MXWA, MYWA, , tControlID, 2

	If (WinID = hGui || WinID = oOther.hZoom)
		Return HideMarker(), HideAccMarker()

	CtrlInfo := "", isIE := 0
	ControlNN := tControlNN, ControlID := tControlID
	WinGetPos, WinX, WinY, , , ahk_id %WinID%
	RWinX := MXS - WinX, RWinY := MYS - WinY
	GetClientPos(WinID, caX, caY, caW, caH)
	MXC := RWinX - caX, MYC := RWinY - caY
	PixelGetColor, ColorBGR, %MXS%, %MYS%
	ColorRGB := Format("0x{:06X}", (ColorBGR & 0xFF) << 16 | (ColorBGR & 0xFF00) | (ColorBGR >> 16))
	sColorBGR := SubStr(ColorBGR, 3)
	sColorRGB := SubStr(ColorRGB, 3)
	GuiControl, TB: -Redraw, ColorProgress
	GuiControl, % "TB: +c" sColorRGB, ColorProgress
	GuiControl, TB: +Redraw, ColorProgress
	WinGetPos, WinX2, WinY2, WinW, WinH, ahk_id %WinID%
	WithRespectWin := "`n" set_button_mouse_pos "Relative window:</button></span> <span>" Round(RWinX / WinW, 4) ", " Round(RWinY / WinH, 4)
		. "</span>  <span id='param'>for</span>  w" WinW "  h" WinH
	ControlGetPos, CtrlX, CtrlY, CtrlW, CtrlH,, ahk_id %ControlID%
	CtrlCAX := CtrlX - caX, CtrlCAY := CtrlY - caY
	CtrlX2 := CtrlX+CtrlW, CtrlY2 := CtrlY+CtrlH
	CtrlCAX2 := CtrlX2-caX, CtrlCAY2 := CtrlY2-caY
	WithRespectClient := set_button_mouse_pos "Relative client:</button></span> <span>" Round(MXC / caW, 4) ", " Round(MYC / caH, 4)
		. "</span>  <span id='param'>for</span>  w" caW "  h" caH
	WithRespectControl := ControlNN = "" ? "" : DP Round(rmCtrlX / CtrlW, 4) ", " Round(rmCtrlY / CtrlH, 4)
	ControlGetText, CtrlText, , ahk_id %ControlID%
	If CtrlText !=
		CtrlText := "`n" D1 " <a></a><span id='title'>( Control Text )</span> " DB " " copy_button " " D2 "`n<span>" TransformHTML(CtrlText) "</span>"
	AccText := AccInfoUnderMouse(MXS, MYS, WinX, WinY, CtrlX, CtrlY)
	If AccText !=
		AccText = `n%D1% <a></a><span id='title'>( AccInfo )</span> %m_run_AccViewer%%D2%%AccText%
	If ControlNN !=
	{
		rmCtrlX := MXS - WinX - CtrlX, rmCtrlY := MYS - WinY - CtrlY
		ControlNN_Sub := RegExReplace(ControlNN, "S)\d+| ")
		If IsFunc("GetInfo_" ControlNN_Sub)
		{
			CtrlInfo := GetInfo_%ControlNN_Sub%(ControlID, ClassNN), ml_run_iWB2Learner := isIE ? m_run_iWB2Learner : ""
			If CtrlInfo !=
				CtrlInfo = `n%D1% <a></a><span id='title'>( Info - %ClassNN% )</span> %ml_run_iWB2Learner%%D2%%CtrlInfo%
		}
	}
	Else
		rmCtrlX := rmCtrlY := ""
	If (!isIE && ThisMode = "Mouse" && (StateLight = 1 || (StateLight = 3 && GetKeyState("Shift", "P"))))
	{
		StateLightMarker ? ShowMarker(WinX2+CtrlX, WinY2+CtrlY, CtrlW, CtrlH) : 0
		StateLightAcc ? ShowAccMarker(AccCoord[1], AccCoord[2], AccCoord[3], AccCoord[4]) : 0
	}
	ControlGet, CtrlStyle, Style,,, ahk_id %ControlID%
	ControlGet, CtrlExStyle, ExStyle,,, ahk_id %ControlID%
	WinGetClass, CtrlClass, ahk_id %ControlID%
	ControlGetFocus, CtrlFocus, ahk_id %WinID%
	WinGet, ProcessName, ProcessName, ahk_id %WinID%
	WinGetClass, WinClass, ahk_id %WinID%

HTML_Mouse:
	HTML_Mouse =
	( Ltrim
	<body id='body'><pre id='pre' contenteditable='true'>
	%D1% <span id='title'>( Mouse )</span> %DB% %pause_button%%m_run_AhkSpyZoom% %D2%
	%set_button_mouse_pos%Screen:</button></span>  <span>x%MXS% y%MYS%</span>%DP%%set_button_mouse_pos%Window:</button></span>  <span>x%RWinX% y%RWinY%</span>%DP%%set_button_mouse_pos%Client:</button></span>  <span>x%MXC% y%MYC%</span>%WithRespectWin%%DP%%WithRespectClient%
	<span id='param'>Relative active window:</span>  x%MXWA% y%MYWA%%DP%<span id='param'>exe</span> %ProcessName_A% <span id='param'>class</span> %WinClass_A% <span id='param'>hwnd</span> %HWND_A%
	%D1% <span id='title'>( PixelGetColor )</span> %D2%
	<span id='param'>RGB: </span> %ColorRGB%%DP%#%sColorRGB%%DP%<span id='param'>BGR: </span> %ColorBGR%%DP%#%sColorBGR%
	%D1% <span id='title'>( Window: Class & Process & HWND )</span> %D2%
	<span id='param'>ahk_class</span> %WinClass% <span id='param'>ahk_exe</span> %ProcessName% <span id='param'>ahk_id</span> %WinID%
	%D1% <span id='title'>( Control )</span> %D2%<a></a>
	<span id='param'>Class NN:</span>  %ControlNN%%DP%<span id='param'>Win class:</span>  %CtrlClass%
	%set_button_pos%Pos:</button></span>  <span>x%CtrlX% y%CtrlY%</span>%DP%%set_button_pos%Size:</button></span>  <span>w%CtrlW% h%CtrlH%</span>%DP%<span id='param'>x&sup2;<span style='font-size: 0.7em'></span></span>%CtrlX2% <span id='param'>y&sup2;<span style='font-size: 0.7em'></span></span>%CtrlY2%
	<span id='param'>Pos relative client area:</span>  x%CtrlCAX% y%CtrlCAY%%DP%<span id='param'>x&sup2;<span style='font-size: 0.7em'></span></span>%CtrlCAX2% <span id='param'>y&sup2;<span style='font-size: 0.7em'></span></span>%CtrlCAY2%
	%set_button_mouse_pos%Mouse relative control:</button></span>  <span>x%rmCtrlX% y%rmCtrlY%</span>%WithRespectControl%%DP%<span id='param'>Client area:</span>  x%caX% y%caY% w%caW% h%caH%
	<span id='param'>HWND:</span>  %ControlID%%DP%<span id='param'>Style:</span>  %CtrlStyle%%DP%<span id='param'>ExStyle:</span>  %CtrlExStyle%
	<span>%set_button_focus_ctrl%Focus control:</button></span>  %CtrlFocus%%DP%<span id='param'>Cursor type:</span>  %A_Cursor%%DP%<span id='param'>Caret pos:</span>  x%A_CaretX% y%A_CaretY%%CtrlInfo%%CtrlText%%AccText%
	<a></a>%D2%</pre></body>

	<style>
	pre {font-family: '%FontFamily%'; font-size: '%FontSize%'; position: absolute; top: 5px}
	body {background-color: '#%ColorBg%'; color: '%ColorFont%'}
	#title {color: '%ColorTitle%'}
	#param {color: '%ColorParam%'}
	#set_button_pos {color: '%ColorParam%';font-size: 1em;}
	#set_button_mouse_pos, #set_button_focus_ctrl {color: '%ColorParam%';font-size: 1em;}
	Button {font-size: 0.9em; border: 1px dashed black}
	</style>
	)
	oOther.MouseControlID := ControlID
	oOther.MouseWinID := WinID
	Return 1
}

Write_Mouse()  {
	oDoc.body.innerHTML := HTML_Mouse, oDoc.getElementById("pre").style.fontSize := FontSize
	Return 1
}

	; _________________________________________________ Get Info Control _________________________________________________

GetInfo_SysListView(hwnd, ByRef ClassNN)  {
	ClassNN := "SysListView32"
	ControlGet, ListText, List,,, ahk_id %hwnd%
	ControlGet, RowCount, List, Count,, ahk_id %hwnd%
	ControlGet, ColCount, List, Count Col,, ahk_id %hwnd%
	ControlGet, SelectedCount, List, Count Selected,, ahk_id %hwnd%
	ControlGet, FocusedCount, List, Count Focused,, ahk_id %hwnd%
	Return	"`n<span id='param'>Row count:</span> " RowCount DP
			. "<span id='param'>Column count:</span> " ColCount "`n"
			. "<span id='param'>Selected count:</span> " SelectedCount DP
			. "<span id='param'>Focused row:</span> " FocusedCount
			. "`n" D1 " <span id='param'>( Content )</span> " DB
			. " " copy_button " " D2 "`n<span>" TransformHTML(ListText) "</span>"
}

GetInfo_SysTreeView(hwnd, ByRef ClassNN)  {
	ClassNN := "SysTreeView32"
	SendMessage 0x1105, 0, 0, , ahk_id %hwnd%   ; TVM_GETCOUNT
	ItemCount := ErrorLevel
	Return	"`n<span id='param'>Item count:</span> " ItemCount
}

GetInfo_ListBox(hwnd, ByRef ClassNN)  {
	ClassNN = ListBox
	Return GetInfo_ComboBox(hwnd, "")
}
GetInfo_TListBox(hwnd, ByRef ClassNN)  {
	ClassNN = TListBox
	Return GetInfo_ComboBox(hwnd, "")
}
GetInfo_TComboBox(hwnd, ByRef ClassNN)  {
	ClassNN = TComboBox
	Return GetInfo_ComboBox(hwnd, "")
}
GetInfo_ComboBox(hwnd, ByRef ClassNN)  {
	ClassNN = ComboBox
	ControlGet, ListText, List,,, ahk_id %hwnd%
	SendMessage, 0x147, 0, 0, , ahk_id %hwnd%   ; CB_GETCURSEL
	SelPos := ErrorLevel
	SelPos := SelPos = 0xffffffff || SelPos < 0 ? "NoSelect" : SelPos + 1
	RegExReplace(ListText, "m`a)$", "", RowCount)
	Return	"`n<span id='param'>Row count:</span> " RowCount DP "<span id='param'>Row selected:</span> " SelPos
			. "`n" D1 " <a></a><span id='param'>( Content )</span> " DB " "
			. copy_button " " D2 "`n<span>" TransformHTML(ListText) "</span>"
}

GetInfo_CtrlNotifySink(hwnd, ByRef ClassNN)  {
	ClassNN = CtrlNotifySink
	Return GetInfo_Scintilla(hwnd, "")
}
GetInfo_Edit(hwnd, ByRef ClassNN)  {
	ClassNN = Edit
	Return GetInfo_Scintilla(hwnd, "")
}
GetInfo_Scintilla(hwnd, ByRef ClassNN)  {
	ClassNN = Scintilla
	ControlGet, LineCount, LineCount,,, ahk_id %hwnd%
	ControlGet, CurrentCol, CurrentCol,,, ahk_id %hwnd%
	ControlGet, CurrentLine, CurrentLine,,, ahk_id %hwnd%
	ControlGet, Selected, Selected,,, ahk_id %hwnd%
	SendMessage, 0x00B0,,,, ahk_id %hwnd%			;  EM_GETSEL
	EM_GETSEL := ErrorLevel >> 16
	SendMessage, 0x00CE,,,, ahk_id %hwnd%			;  EM_GETFIRSTVISIBLELINE
	EM_GETFIRSTVISIBLELINE := ErrorLevel + 1
	; Control_GetFont(hwnd, FName, FSize)
	Return	"`n<span id='param'>Row count:</span> " LineCount DP
			. "<span id='param'>Selected length:</span> " StrLen(Selected)
			. "`n<span id='param'>Current row:</span> " CurrentLine DP
			. "<span id='param'>Current column:</span> " CurrentCol
			. "`n<span id='param'>Current select:</span> " EM_GETSEL DP
			. "<span id='param'>First visible line:</span> " EM_GETFIRSTVISIBLELINE
			; . "`n<span id='param'>FontSize:</span> " FSize DP "<span id='param'>FontName:</span> " FName
}

Control_GetFont(hwnd, byref FontName, byref FontSize) {
	SendMessage 0x31, 0, 0, , ahk_id %hwnd% ; WM_GETFONT
	IfEqual, ErrorLevel, FAIL, Return
	hFont := Errorlevel, VarSetCapacity(LF, szLF := 60 * (A_IsUnicode ? 2 : 1))
	DllCall("GetObject", UInt, hFont, Int, szLF, UInt, &LF)
	hDC := DllCall("GetDC", UInt,hwnd ), DPI := DllCall("GetDeviceCaps", UInt, hDC, Int, 90)
	DllCall("ReleaseDC", Int, 0, UInt, hDC), S := Round((-NumGet(LF, 0, "Int") * 72) / DPI)
	FontName := DllCall("MulDiv", Int, &LF + 28, Int, 1, Int, 1, Str)
	DllCall("SetLastError", UInt, S), FontSize := A_LastError
}

GetInfo_msctls_progress(hwnd, ByRef ClassNN)  {
	ClassNN := "msctls_progress32"
	SendMessage, 0x0400+7,"TRUE",,, ahk_id %hwnd%	;  PBM_GETRANGE
	PBM_GETRANGEMIN := ErrorLevel
	SendMessage, 0x0400+7,,,, ahk_id %hwnd%			;  PBM_GETRANGE
	PBM_GETRANGEMAX := ErrorLevel
	SendMessage, 0x0400+8,,,, ahk_id %hwnd%			;  PBM_GETPOS
	PBM_GETPOS := ErrorLevel
	Return	"`n<span id='param'>Level:</span> " PBM_GETPOS DP
			. "<span id='param'>Range:   min</span> " PBM_GETRANGEMIN
			. "  <span id='param'>max:</span> " PBM_GETRANGEMAX
}

GetInfo_msctls_trackbar(hwnd, ByRef ClassNN)  {
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
	Return	"`n<span id='param'>Level:</span> " TBM_GETPOS DP
			. "<span id='param'>Invert style:</span> " TBS_REVERSED
			. "`n<span id='param'>Range:   Min:</span> " TBM_GETRANGEMIN DP
			. "<span id='param'>Max:</span> " TBM_GETRANGEMAX
}

GetInfo_msctls_updown(hwnd, ByRef ClassNN)  {
	ClassNN := "msctls_updown32"
	SendMessage, 0x0400+102,,,, ahk_id %hwnd%		;  UDM_GETRANGE
	UDM_GETRANGE := ErrorLevel
	SendMessage, 0x400+114,,,, ahk_id %hwnd%		;  UDM_GETPOS32
	UDM_GETPOS32 := ErrorLevel
	Return	"`n<span id='param'>Level:</span> " UDM_GETPOS32 DP
			. "<span id='param'>Range:  min: </span>" UDM_GETRANGE >> 16
			. "  <span id='param'>max: </span>" UDM_GETRANGE & 0xFFFF
}

GetInfo_SysTabControl(hwnd, ByRef ClassNN)  {
	ClassNN := "SysTabControl32"
	ControlGet, SelTab, Tab,,, ahk_id %hwnd%
	SendMessage, 0x1300+44,,,, ahk_id %hwnd%		;  TCM_GETROWCOUNT
	TCM_GETROWCOUNT := ErrorLevel
	SendMessage, 0x1300+4,,,, ahk_id %hwnd%			;  TCM_GETITEMCOUNT
	TCM_GETITEMCOUNT := ErrorLevel
	Return	"`n<span id='param'>Item count:</span> " TCM_GETITEMCOUNT DP
			. "<span id='param'>Row count:</span> " TCM_GETROWCOUNT DP
			. "<span id='param'>Selected item:</span> " SelTab
}

GetInfo_ToolbarWindow(hwnd, ByRef ClassNN)  {
	ClassNN := "ToolbarWindow32"
	SendMessage, 0x0418,,,, ahk_id %hwnd%		;  TB_BUTTONCOUNT
	BUTTONCOUNT := ErrorLevel
	Return	"`n<span id='param'>Button count:</span> " BUTTONCOUNT
}

	; _________________________________________________ Get Internet Explorer Info _________________________________________________

	;  http://www.autohotkey.com/board/topic/84258-iwb2-learner-iwebbrowser2/

GetInfo_AtlAxWin(hwnd, ByRef ClassNN)  {
	ClassNN = AtlAxWin
	Return GetInfo_InternetExplorer_Server(hwnd, "")
}
GetInfo_InternetExplorer_Server(hwnd, ByRef ClassNN)  {
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
	If (Tag = "IFRAME" || Tag = "FRAME") {
		If pFrame := ComObjQuery(pwin.document.parentWindow.frames[pelt.id], IID_IHTMLWindow2, IID_IHTMLWindow2)
			iFrame := ComObject(9, pFrame, 1)
		Else
			iFrame := ComObj(9, ComObjQuery(pelt.contentWindow, IID_IHTMLWindow2, IID_IHTMLWindow2), 1)

		WB2 := ComObject(9, ComObjQuery(pelt.contentWindow, IID_IWebBrowserApp, IID_IWebBrowserApp), 1)
		If ((Var := WB2.LocationName) != "")
			Frame .= "`n<span id='param'>Title:  </span>" Var
		If ((Var := WB2.LocationURL) != "")
			Frame .= "`n<span id='param'>URL:  </span>" Var
		If (iFrame.length)
			Frame .= "`n<span id='param'>Count frames:  </span>" iFrame.length
		If (Tag != "")
			Frame .= "`n<span id='param'>TagName:  </span>" Tag
		If ((Var := pelt.id) != "")
			Frame .= "`n<span id='param'>ID:  </span>" Var
		If ((Var := pelt.ClassName) != "")
			Frame .= "`n<span id='param'>Class:  </span>" Var
		If ((Var := pelt.sourceIndex) != "")
			Frame .= "`n<span id='param'>Index:  </span>" Var
		If ((Var := pelt.name) != "")
			Frame .= "`n<span id='param'>Name:  </span>" TransformHTML(Var)

		If ((Var := pelt.OuterHtml) != "")  {
			code = `n%D1% <a></a><span id='param'>( Outer HTML )</span> %DB% %copy_button% %D2%`n
			Frame .= code "<span>" TransformHTML(Var) "</span>"
		}
		If ((Var := pelt.OuterText) != "")  {
			code = `n%D1% <a></a><span id='param'>( Outer Text )</span> %DB% %copy_button% %D2%`n
			Frame .= code "<span>" TransformHTML(Var) "</span>"
		}
		If Frame !=
			Frame = `n%D1% <a></a><span id='title'>( FrameInfo )</span> %D2%%Frame%
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
		Location = `n<span id='param'>Title:  </span>%Location%
	If ((URL := WB2.LocationURL) != "")
		URL = `n<span id='param'>URL:  </span>%URL%

	If ((Var := pelt.id) != "")
		Info .= "`n<span id='param'>ID:  </span>" Var
	If ((Var := pelt.ClassName) != "")
		Info .= "`n<span id='param'>Class:  </span>" Var
	If ((Var := pelt.sourceIndex) != "")
		Info .= "`n<span id='param'>Index:  </span>" Var
	If ((Var := pelt.name) != "")
		Info .= "`n<span id='param'>Name:  </span>" TransformHTML(Var)

	If ((Var := pelt.OuterHtml) != "")  {
		code = `n%D1% <a></a><span id='param'>( Outer HTML )</span> %DB% %copy_button% %D2%`n
		Info .= code "<span>" TransformHTML(Var) "</span>"
	}
	If ((Var := pelt.OuterText) != "")  {
		code = `n%D1% <a></a><span id='param'>( Outer Text )</span> %DB% %copy_button% %D2%`n
		Info .= code "<span>" TransformHTML(Var) "</span>"
	}
	If Info !=
		Info := "`n" D1 " <span id='param'>( Tag name: </span>" pelt.TagName "<span id='param'> )" (Frame ? " " # " ( in frame )" : "") "</span> " D2 Info
	If (ThisMode = "Mouse") && (StateLight = 1 || (StateLight = 3 && GetKeyState("Shift", "P")))
	{
		x1 := pbrt.left * ratio, y1 := pbrt.top * ratio
		x2 := pbrt.right * ratio, y2 := pbrt.bottom * ratio
		WinGetPos, sX, sY, , , ahk_id %hwnd%
		StateLightMarker ? ShowMarker(sX + x1, sY + y1, x2 - x1, y2 - y1) : 0
		StateLightAcc ? ShowAccMarker(AccCoord[1], AccCoord[2], AccCoord[3], AccCoord[4]) : 0
	}
	ObjRelease(pwin), ObjRelease(pelt), ObjRelease(WB2), ObjRelease(iFrame), ObjRelease(pbrt)
	Return Location URL Info Frame
}

WBGet(hwnd)  {
	Static Msg := DllCall("RegisterWindowMessage", "Str", "WM_HTML_GETOBJECT")
		, IID_IHTMLWindow2 := "{332C4427-26CB-11D0-B483-00C04FD90119}"
	SendMessage, Msg, , , , ahk_id %hwnd%
	DllCall("oleacc\ObjectFromLresult", "Ptr", ErrorLevel, "Ptr", 0, "Ptr", 0, PtrP, pdoc)
	Return ComObj(9, ComObjQuery(pdoc, IID_IHTMLWindow2, IID_IHTMLWindow2), 1), ObjRelease(pdoc)
}

	; _________________________________________________ Get Acc Info _________________________________________________

	;  http://www.autohotkey.com/board/topic/77888-accessible-info-viewer-alpha-release-2012-09-20/

AccInfoUnderMouse(x, y, wx, wy, cx, cy)  {
	Static h
	If Not h
		h := DllCall("LoadLibrary","Str","oleacc","Ptr")
	If DllCall("oleacc\AccessibleObjectFromPoint"
		, "Int64", x&0xFFFFFFFF|y<<32, "Ptr*", pacc
		, "Ptr", VarSetCapacity(varChild,8+2*A_PtrSize,0)*0+&varChild) = 0
	Acc := ComObjEnwrap(9,pacc,1), child := NumGet(varChild,8,"UInt")
	If !IsObject(Acc)
		Return
	Type := child ? "Child" DP "<span id='param'>Id:  </span>" child
		: "Parent" DP "<span id='param'>ChildCount:  </span>" ((C:=Acc.accChildCount)!=""?C:"N/A")
	code = `n<span id='param'>Type:</span>  %Type%
	code = %code%`n%D1% <a></a><span id='param'>( Position relative )</span> %D2%`n
	code .= "<span id='param'>Screen: </span>" AccGetLocation(Acc, child)
		. "`n<span id='param'>Mouse: </span>x" x - AccCoord[1] " y" y - AccCoord[2]
		. DP "<span id='param'>Window: </span>x" AccCoord[1] - wx " y" AccCoord[2] - wy
		. (cx != "" ? DP "<span id='param'>Control: </span>x" (AccCoord[1] - wx - cx) " y" (AccCoord[2] - wy - cy) : "")

	If ((Name := Acc.accName(child)) != "")  {
		code = %code%`n%D1% <a></a><span id='param'>( Name )</span> %DB% %copy_button% %D2%`n
		code .= "<span>" TransformHTML(Name) "</span>"
	}
	If ((Value := Acc.accValue(child)) != "")  {
		code = %code%`n%D1% <a></a><span id='param'>( Value )</span> %DB% %copy_button% %D2%`n
		code .= "<span>" TransformHTML(Value) "</span>"
	}
	If ((State := AccGetStateText(StateCode := Acc.accState(child))) != "")  {
		code = %code%`n%D1% <a></a><span id='param'>( State )</span> %DB% %copy_button% %D2%`n
		code .= "<span>" TransformHTML(State) "</span>"
			. DP "<span id='param'>code: </span>" StateCode
	}
	If ((Role := AccRole(Acc, child)) != "")  {
		code = %code%`n%D1% <a></a><span id='param'>( Role )</span> %DB% %copy_button% %D2%`n
		code .= "<span>" TransformHTML(Role) "</span>"
			. DP "<span id='param'>code: </span>" Acc.accRole(child)
	}
	If (child &&(ObjRole := AccRole(Acc)) != "")  {
		code = %code%`n%D1% <a></a><span id='param'>( Role - parent )</span> %DB% %copy_button% %D2%`n
		code .= "<span>" TransformHTML(ObjRole) "</span>"
			. DP "<span id='param'>code: </span>" Acc.accRole(0)
	}
	If ((Action := Acc.accDefaultAction(child)) != "")  {
		code = %code%`n%D1% <a></a><span id='param'>( Action )</span> %DB% %copy_button% %D2%`n
		code .= "<span>" TransformHTML(Action) "</span>"
	}
	If ((Selection := Acc.accSelection) > 0)  {
		code = %code%`n%D1% <a></a><span id='param'>( Selection - parent )</span> %D2%`n
		code .= "<span>" TransformHTML(Selection) "</span>"
	}
	If ((Focus := Acc.accFocus) > 0)  {
		code = %code%`n%D1% <a></a><span id='param'>( Focus - parent )</span> %D2%`n
		code .= "<span>" TransformHTML(Focus) "</span>"
	}
	If ((Description := Acc.accDescription(child)) != "")  {
		code = %code%`n%D1% <a></a><span id='param'>( Description )</span> %DB% %copy_button% %D2%`n
		code .= "<span>" TransformHTML(Description) "</span>"
	}
	If ((ShortCut := Acc.accKeyboardShortCut(child)) != "")  {
		code = %code%`n%D1% <a></a><span id='param'>( ShortCut )</span> %DB% %copy_button% %D2%`n
		code .= "<span>" TransformHTML(ShortCut) "</span>"
	}
	If ((Help := Acc.accHelp(child)) != "")  {
		code = %code%`n%D1% <a></a><span id='param'>( Help )</span> %DB% %copy_button% %D2%`n
		code .= "<span>" TransformHTML(Help) "</span>"
	}
	If ((HelpTopic := Acc.AccHelpTopic(child)))  {
		code = %code%`n%D1% <a></a><span id='param'>( HelpTopic )</span> %DB% %copy_button% %D2%`n
		code .= "<span>" TransformHTML(HelpTopic) "</span>"
	}
	Return code
}
AccRole(Acc, ChildId=0)  {
	Return ComObjType(Acc, "Name") = "IAccessible" ? AccGetRoleText(Acc.accRole(ChildId)) : ""
}
AccGetRoleText(nRole)  {
	nSize := DllCall("oleacc\GetRoleText", "UInt", nRole, "Ptr", 0, "UInt", 0)
	VarSetCapacity(sRole, (A_IsUnicode?2:1)*nSize)
	DllCall("oleacc\GetRoleText", "UInt", nRole, "str", sRole, "UInt", nSize+1)
	Return sRole
}
AccGetStateText(nState)  {
	nSize := DllCall("oleacc\GetStateText", "UInt", nState, "Ptr", 0, "UInt", 0)
	VarSetCapacity(sState, (A_IsUnicode?2:1)*nSize)
	DllCall("oleacc\GetStateText", "UInt", nState, "str", sState, "UInt", nSize+1)
	Return sState
}
AccGetLocation(Acc, Child=0) {
	Acc.accLocation(ComObj(0x4003,&x:=0), ComObj(0x4003,&y:=0), ComObj(0x4003,&w:=0), ComObj(0x4003,&h:=0), Child)
	Return "x" (AccCoord[1]:=NumGet(x,0,"int")) " y" (AccCoord[2]:=NumGet(y,0,"int"))
			. DP "<span id='param'>Size: </span>w" (AccCoord[3]:=NumGet(w,0,"int")) " h" (AccCoord[4]:=NumGet(h,0,"int"))
}

	; _________________________________________________ Mode_Hotkey _________________________________________________

Mode_Hotkey:
	Try SetTimer, Loop_%ThisMode%, Off
	If ThisMode = Hotkey
		oDoc.body.scrollLeft := 0
	oDoc.body.createTextRange().execCommand("RemoveFormat")
	ScrollPos[ThisMode,1] := oDoc.body.scrollLeft, ScrollPos[ThisMode,2] := oDoc.body.scrollTop
	If ThisMode != Hotkey
		HTML_%ThisMode% := oDoc.body.innerHTML
	ThisMode := "Hotkey", Hotkey_Hook(!isPaused), TitleText := "AhkSpy - Button" TitleTextP2
	oDoc.body.scrollLeft := ScrollPos[ThisMode,1], oDoc.body.scrollTop := ScrollPos[ThisMode,2]
	ShowMarker ? (HideMarker(), HideAccMarker()) : 0
	(HTML_Hotkey != "") ? Write_HotkeyHTML() : Write_Hotkey({Mods:"Wait press button..."})
	SendMessage, 0xC, 0, &TitleText, , ahk_id %hGui%
	GuiControl, TB: -0x0001, But3
	WinActivate ahk_id %hGui%
	GuiControl, 1:Focus, oDoc
	IniWrite(ThisMode, "LastMode")
	If isFindView
		FindSearch(1)
	Return

Write_Hotkey(K)  {
	Static PrHK1, PrHK2, PrKeys1, PrKeys2, PrKeysComm, KeysComm, Name

	Mods := K.Mods, KeyName := K.Name
	Prefix := K.Pref, Hotkey := K.HK
	LRMods := K.LRMods, LRPref := TransformHTML(K.LRPref)
	ThisKey := K.TK, VKCode := K.VK, SCCode := K.SC

	If (K.NFP && Mods KeyName != "")
		NotPhysical	:= " " DP "<span style='color:" ColorDelimiter "'> Not a physical press </span>"
	IsVk := Hotkey ~= "^vk" ? 1 : 0

	HK1 := IsVk ? Hotkey : ThisKey
	HK2 := HK1 = PrHK1 ? PrHK2 : PrHK1, PrHK1 := HK1, PrHK2 := HK2
	HKComm1 := "    `;  """ (StrLen(Name := GetKeyName(HK2)) = 1 ? Format("{:U}", Name) : Name)
	HKComm2 := (StrLen(Name := GetKeyName(HK1)) = 1 ? Format("{:U}", Name) : Name) """"

	If ((Keys1 := Prefix Hotkey) != "" && Keys1 != PrKeys1)
		Keys2 := PrKeys1, PrKeys1 := Keys1
		, KeysComm := "    `;  """ PrKeysComm " >> " Mods KeyName     """"
		, PrKeysComm := Mods KeyName, PrKeys2 := Keys2
	Else
		Keys1 := PrKeys1, Keys2 := PrKeys2

	Comment := IsVk ? "<span id='param'>    `;  """ KeyName """</span>" : ""
	(Hotkey != "") ? (LRComment := "::<span id='param'>    `;  """ LRMods KeyName """</span>"
		, FComment := "::<span id='param'>    `;  """ Mods KeyName """</span>") : 0
	(LRMods != "") ? (LRMStr := LRMods KeyName, LRPStr := "  " DP "  " LRPref Hotkey LRComment) : 0
	inp_hk := o_edithotkey.value, inp_kn := o_editkeyname.value

	If Prefix !=
		DUMods := (K.MLCtrl ? "{LCtrl Down}" : "") (K.MRCtrl ? "{RCtrl Down}" : "")
			. (K.MLAlt ? "{LAlt Down}" : "") (K.MRAlt ? "{RAlt Down}" : "")
			. (K.MLShift ? "{LShift Down}" : "") (K.MRShift ? "{RShift Down}" : "")
			. (K.MLWin ? "{LWin Down}" : "") (K.MRWin ? "{RWin Down}" : "") . "{" Hotkey "}"
			. (K.MLCtrl ? "{LCtrl Up}" : "") (K.MRCtrl ? "{RCtrl Up}" : "")
			. (K.MLAlt ? "{LAlt Up}" : "") (K.MRAlt ? "{RAlt Up}" : "")
			. (K.MLShift ? "{LShift Up}" : "") (K.MRShift ? "{RShift Up}" : "")
			. (K.MLWin ? "{LWin Up}" : "") (K.MRWin ? "{RWin Up}" : "")

	SendHotkey := Hotkey = "" ? ThisKey : Hotkey
	ControlSend := DUMods = "" ? "{" SendHotkey "}" : DUMods
	LRSend := DUMods = "" ? "" : "  " DP "  SendInput " DUMods Comment

	HTML_Hotkey =
	( Ltrim
	<body id='body'> <pre id='pre'; contenteditable='true'>
	%D1% <span id='title'>( Pressed buttons )</span> %DB% %pause_button% %D2%

	%Mods%%KeyName%%NotPhysical%

	%LRMStr%

	%D1% <span id='title'>( Command syntax )</span> %DB% <span contenteditable='false' unselectable='on'><button id='copy_selected'>copy selected</button></span> %D2%

	%Prefix%%Hotkey%%FComment%%LRPStr%

	Send %Prefix%{%SendHotkey%}%Comment%  %DP%  ControlSend, ahk_parent, %ControlSend%, WinTitle%Comment%

	SendInput %Prefix%{%SendHotkey%}%Comment%%LRSend%

	%HK2% & %HK1%::<span id='param'>%HKComm1% & %HKComm2%</span>   %DP%   GetKeyState("%SendHotkey%", "P")%Comment%   %DP%   KeyWait, %SendHotkey%, D T3%Comment%

	%HK2%::%HK1%<span id='param'>%HKComm1% >> %HKComm2%</span>   %DP%   %Keys2%:: %Keys1%<span id='param'>%KeysComm%</span>

	%D1% <span id='title'>( Last pressed )</span> %DB% <span contenteditable='false' unselectable='on'><button id='numlock'> num </button> <button id='scrolllock'> scroll </button> <button id='rus_eng'> rus/eng </button></span> %D2%

	%ThisKey%   %DP%   %VKCode%%SCCode%   %DP%   %VKCode%   %DP%   %SCCode%

	%D1% <span id='title'>( GetKeyNameOrCode )</span> %DB% <span contenteditable='false' unselectable='on'><button id='paste_keyname'>paste</button></span> %D2%

	<span contenteditable='false' unselectable='on'><input id='edithotkey' value='%inp_hk%'><button id='keyname'> &#8250 &#8250 &#8250 </button><input id='editkeyname' value='%inp_kn%'></input></span>

	%D2%</pre></body>

	<style>
	pre {font-family: '%FontFamily%'; font-size: '%FontSize%'; position: absolute; top: 5px;}
	body {background-color: '#%ColorBg%'; color: '%ColorFont%'}
	#title {color: '%ColorTitle%';}
	#param {color: '%ColorParam%';}
	#edithotkey {font-size: '1.2em'; text-align: center; border: 1px dashed black; height: 1.45em;}
	#keyname {font-size: '1.2em'; border: 1px dashed black;  background-color: '%ColorParam%'; position: relative; top: 0px; left: 2px; height: 1.45em; width: 3em;}
	#editkeyname {font-size: '1.2em'; text-align: center; border: 1px dashed black; position: relative; left: 4px; top: 0px; height: 1.45em;}
	#pause_button, #numlock, #paste_keyname, #scrolllock, #rus_eng, #copy_selected {font-size: 0.9em; border: 1px dashed black;}
	</style>
	)
	Write_HotkeyHTML()
}

Write_HotkeyHTML()  {
	oDoc.body.innerHTML := HTML_Hotkey, oDoc.getElementById("pre").style.fontSize := FontSize
	ComObjConnect(o_edithotkey:=oDoc.getElementById("edithotkey"),Events)
	ComObjConnect(o_editkeyname:=oDoc.getElementById("editkeyname"),Events)
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
	Static Prefix := {"LAlt":"<!","LCtrl":"<^","LShift":"<+","LWin":"<#"
	,"RAlt":">!","RCtrl":">^","RShift":">+","RWin":">#"}, K := {}, ModsOnly
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
		K.MCtrl := K.MAlt := K.MShift := K.MWin := K.Mods := ""
		K.PCtrl := K.PAlt := K.PShift := K.PWin := K.Pref := ""
		K.PRCtrl := K.PRAlt := K.PRShift := K.PRWin := ""
		K.PLCtrl := K.PLAlt := K.PLShift := K.PLWin := K.LRPref := ""
		K.MRCtrl := K.MRAlt := K.MRShift := K.MRWin := ""
		K.MLCtrl := K.MLAlt := K.MLShift := K.MLWin := K.LRMods := ""
		Func(Hotkey_Arr("Func")).Call(K)
		Return ModsOnly := 0
	}
	Else If (In.Opt = "GetMod")
		Return !!(K.PCtrl K.PAlt K.PShift K.PWin)
	K.UP := In.UP, K.IsJM := 0, K.Time := In.Time, K.NFP := In.NFP, K.IsMod := IsMod
	K.VK := In.VK, K.SC := In.SC
	K.Mods := K.MCtrl K.MAlt K.MShift K.MWin
	K.LRMods := K.MLCtrl K.MRCtrl K.MLAlt K.MRAlt K.MLShift K.MRShift K.MLWin K.MRWin
	K.TK := GetKeyName(K.VK K.SC), K.TK := K.TK = "" ? K.VK K.SC : K.TK
	(IsMod) ? (K.HK := K.Pref := K.LRPref := K.Name := "", ModsOnly := K.Mods = "" ? 0 : 1)
	: (K.HK := StrLen(K.TK) = 1 && !Instr("1234567890-=", K.TK) ? K.VK : K.TK
	, K.Name := K.HK = "vkBF" ? "/" : K.TK
	, (StrLen(K.Name) = 1 ? (K.TK := K.Name := Format("{:U}", K.Name)) : 0)
	, K.Pref := K.PCtrl K.PAlt K.PShift K.PWin
	, K.LRPref := K.PLCtrl K.PRCtrl K.PLAlt K.PRAlt K.PLShift K.PRShift K.PLWin K.PRWin
	, ModsOnly := 0)
	Func(Hotkey_Arr("Func")).Call(K)
	Return 1

Hotkey_PressJoy:
Hotkey_PressMouse:
	K.Time := A_TickCount
	K.Mods := K.MCtrl K.MAlt K.MShift K.MWin
	K.LRMods := K.MLCtrl K.MRCtrl K.MLAlt K.MRAlt K.MLShift K.MRShift K.MLWin K.MRWin
	K.Pref := K.PCtrl K.PAlt K.PShift K.PWin
	K.LRPref := K.PLCtrl K.PRCtrl K.PLAlt K.PRAlt K.PLShift K.PRShift K.PLWin K.PRWin
	K.HK := K.Name := K.TK := A_ThisHotkey, ModsOnly := K.NFP := K.UP := 0, K.IsMod := K.SC := ""
	K.IsJM := A_ThisLabel = "Hotkey_PressJoy" ? 1 : 2
	K.VK := A_ThisLabel = "Hotkey_PressJoy" ? "" : Format("vk{:X}", GetKeyVK(A_ThisHotkey))
	Func(Hotkey_Arr("Func")).Call(K)
	Return 1
}

Hotkey_MouseAndJoyInit(Options) {
	Static MouseKey := "MButton|WheelDown|WheelUp|WheelRight|WheelLeft|XButton1|XButton2"
	Local S_FormatInteger, Option
	#If Hotkey_Arr("Hook")
	#If Hotkey_Arr("Hook") && !Hotkey_Main({Opt:"GetMod"})
	#If Hotkey_Arr("Hook") && Hotkey_Main({Opt:"GetMod"})
	#If
	Option := InStr(Options, "M") ? "On" : "Off"
	Hotkey, IF, Hotkey_Arr("Hook")
	Loop, Parse, MouseKey, |
		Hotkey, %A_LoopField%, Hotkey_PressMouse, % Option
	Option := InStr(Options, "L") ? "On" : "Off"
	Hotkey, IF, Hotkey_Arr("Hook") && Hotkey_Main({Opt:"GetMod"})
	Hotkey, LButton, Hotkey_PressMouse, % Option
	Option := InStr(Options, "R") ? "On" : "Off"
	Hotkey, IF, Hotkey_Arr("Hook")
	Hotkey, RButton, Hotkey_PressMouse, % Option
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
	Static Mods := {"vkA4":"LAlt","vkA5":"RAlt","vkA2":"LCtrl","vkA3":"RCtrl"
	,"vkA0":"LShift","vkA1":"RShift","vk5B":"LWin","vk5C":"RWin"}, oMem := []
	, HEAP_ZERO_MEMORY := 0x8, Size := 16, hHeap := DllCall("GetProcessHeap", Ptr)
	Local pHeap, Wp, Lp, Ext, VK, SC, IsMod, Time, NFP
	Critical
	If !Hotkey_Arr("Hook")
		Return DllCall("CallNextHookEx", "Ptr", 0, "Int", nCode, "UInt", wParam, "UInt", lParam)
	pHeap := DllCall("HeapAlloc", Ptr, hHeap, UInt, HEAP_ZERO_MEMORY, Ptr, Size, Ptr)
	DllCall("RtlMoveMemory", Ptr, pHeap, Ptr, lParam, Ptr, Size), oMem.Push([wParam, pHeap])
	SetTimer, Hotkey_HookProcWork, -10
	Return nCode < 0 ? DllCall("CallNextHookEx", "Ptr", 0, "Int", nCode, "UInt", wParam, "UInt", lParam) : 1

	Hotkey_HookProcWork:
		While (oMem[1] != "") {
			If Hotkey_Arr("Hook") {
				Wp := oMem[1][1], Lp := oMem[1][2]
				VK := Format("vk{:X}", NumGet(Lp + 0, "UInt"))
				Ext := NumGet(Lp + 0, 8, "UInt")
				SC := Format("sc{:X}", (Ext & 1) << 8 | NumGet(Lp + 0, 4, "UInt"))
				NFP := (Ext >> 4) & 1 && SC != "sc100"			;  Не физическое нажатие
				Time := NumGet(Lp + 12, "UInt")
				IsMod := Mods[VK]
				If Hotkey_Arr("Hook") && (Wp = 0x100 || Wp = 0x104)		;  WM_KEYDOWN := 0x100, WM_SYSKEYDOWN := 0x104
					IsMod ? Hotkey_Main({VK:VK, SC:SC, Opt:"Down", IsMod:IsMod, NFP:NFP, Time:Time, UP:0})
					: Hotkey_Main({VK:VK, SC:SC, NFP:NFP, Time:Time, UP:0})
				Else If Hotkey_Arr("Hook") && (Wp = 0x101 || Wp = 0x105)		;  WM_KEYUP := 0x101, WM_SYSKEYUP := 0x105
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

	; _________________________________________________ Labels _________________________________________________

GuiSize:
	Sleep := A_EventInfo
	If Sleep != 1
		ControlsMove(A_GuiWidth, A_GuiHeight)
	Else
		ZoomMsg(1), HideMarker(), HideAccMarker()
	Try SetTimer, Loop_%ThisMode%, % Sleep = 1 || isPaused ? "Off" : "On"
	Return

Exit:
GuiClose:
	oDoc := ""
	DllCall("DeregisterShellHookWindow", "Ptr", A_ScriptHwnd)
	ExitApp

TitleShow:
	SendMessage, 0xC, 0, &TitleText, , ahk_id %hGui%
	Return

CheckAhkVersion:
	If A_AhkVersion < 1.1.17.00
	{
		MsgBox Requires AutoHotkey_L version 1.1.17.00+
		RunPath("http://ahkscript.org/download/")
		ExitApp
	}
	Return

LaunchHelp:
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
	ZoomMsg(6)
	If !MemoryFontSize
		oDoc.getElementById("pre").style.fontSize := FontSize := 15
	Return

Reload:
	Reload
	Return

Suspend:
	Suspend
	Menu, Sys, % A_IsSuspended ? "Check" : "UnCheck", % A_ThisMenuItem
	Return

UpdateAhkSpy:
	Update()
	Return

CheckUpdate:
	StateUpdate := IniWrite(!StateUpdate, "StateUpdate")
	Menu, Sys, % StateUpdate ? "Check" : "UnCheck", Check updates
	If StateUpdate
		GoSub, UpdateAhkSpy
	Return

SelStartMode:
	Menu, Startmode, UnCheck, Window
	Menu, Startmode, UnCheck, Mouse && Control
	Menu, Startmode, UnCheck, Button
	Menu, Startmode, UnCheck, Last Mode
	IniWrite({"Window":"Win","Mouse && Control":"Mouse","Button":"Hotkey","Last Mode":"LastMode"}[A_ThisMenuItem], "StartMode")
	Menu, Startmode, Check, % A_ThisMenuItem
	Return

ShowSys:
	Menu, Sys, Show
	Return

Sys_Backlight:
	Menu, Sys, UnCheck, % BLGroup[StateLight]
	Menu, Sys, Check, % A_ThisMenuItem
	IniWrite((StateLight := InArr(A_ThisMenuItem, BLGroup*)), "StateLight")
	Return

Sys_Acclight:
	StateLightAcc := IniWrite(!StateLightAcc, "StateLightAcc"), HideAccMarker()
	Menu, Sys, % StateLightAcc ? "Check" : "UnCheck", Acc object backlight
	Return

Sys_WClight:
	StateLightMarker := IniWrite(!StateLightMarker, "StateLightMarker"), HideMarker()
	Menu, Sys, % StateLightMarker ? "Check" : "UnCheck", Window or control backlight
	Return

Sys_Help:
	If A_ThisMenuItem = AutoHotKey official help online
		RunPath("http://ahkscript.org/docs/AutoHotkey.htm")
	Else If A_ThisMenuItem = AutoHotKey russian help online
		RunPath("http://www.script-coding.com/AutoHotkeyTranslation.html")
	Else If A_ThisMenuItem = About
		RunPath("http://forum.script-coding.com/viewtopic.php?pid=72459#p72459")
	Return

Sys_OpenScriptDir:
	SelectFilePath(A_ScriptFullPath)
	Minimize()
	Return

Spot_together:
	StateAllwaysSpot := IniWrite(!StateAllwaysSpot, "AllwaysSpot")
	Menu, Sys, % StateAllwaysSpot ? "Check" : "UnCheck", Spot together (low speed)
	Return

Active_No_Pause:
	ActiveNoPause := IniWrite(!ActiveNoPause, "ActiveNoPause")
	Menu, Sys, % ActiveNoPause ? "Check" : "UnCheck", Work with the active window
	ZoomMsg(8, ActiveNoPause)
	(ActiveNoPause && Sleep != 1 && !isPaused) && ZoomMsg(0)
	Return

MemoryPos:
	IniWrite(MemoryPos := !MemoryPos, "MemoryPos")
	Menu, Sys, % MemoryPos ? "Check" : "UnCheck", Remember position
	SavePos()
	Return

MemorySize:
	IniWrite(MemorySize := !MemorySize, "MemorySize")
	Menu, Sys, % MemorySize ? "Check" : "UnCheck", Remember size
	SavePos()
	Return

MemoryFontSize:
	IniWrite(MemoryFontSize := !MemoryFontSize, "MemoryFontSize")
	Menu, Sys, % MemoryFontSize ? "Check" : "UnCheck", Remember font size
	If MemoryFontSize
		IniWrite(FontSize, "FontSize")
	Return

MemoryZoomSize:
	IniWrite(MemoryZoomSize := !MemoryZoomSize, "MemoryZoomSize")
	Menu, Sys, % MemoryZoomSize ? "Check" : "UnCheck", Remember zoom size
	ZoomMsg(5, MemoryZoomSize)
	Return

MemoryStateZoom:
	IniWrite(MemoryStateZoom := !MemoryStateZoom, "MemoryStateZoom")
	Menu, Sys, % MemoryStateZoom ? "Check" : "UnCheck", Remember state zoom
	IniWrite(DllCall("IsWindowVisible", "Ptr", oOther.hZoom) ? 1 : 0, "ZoomShow")
	Return

	; _________________________________________________ Functions _________________________________________________

ShellProc(nCode, wParam) {
	If (nCode = 4)
	{
		If (wParam = hGui)
			(ThisMode = "Hotkey" && !isPaused ? Hotkey_Hook(1) : ""), HideMarker(), HideAccMarker(), CheckHideMarker()
		Else If Hotkey_Arr("Hook")
			Hotkey_Hook(0)
		ZoomMsg(!ActiveNoPause && wParam = hGui ? 1 : Sleep != 1 && !isPaused ? 0 : 1)
	}
}

WM_ACTIVATE(wp) {
	Critical
	If (wp & 0xFFFF)
		(ThisMode = "Hotkey" && !isPaused ? Hotkey_Hook(1) : 0), HideMarker(), HideAccMarker(), CheckHideMarker()
	Else If (wp & 0xFFFF = 0 && Hotkey_Arr("Hook"))
		Hotkey_Hook(0)
	ZoomMsg(!ActiveNoPause && (wp & 0xFFFF) ? 1 : Sleep != 1 && !isPaused ? 0 : 1)
}

WM_NCLBUTTONDOWN(wp) {
	Static HTMINBUTTON := 8
	If (wp = HTMINBUTTON)
	{
		SetTimer, Minimize, -10
		Return 0
	}
}

WM_LBUTTONDOWN() {
	If A_GuiControl = ColorProgress
	{
		If ThisMode = Hotkey
			oDoc.execCommand("Paste"), ToolTip("Paste", 300)
		Else
		{
			SendInput {LAlt Down}{Escape}{LAlt Up}
			If (Sleep != 1 && !isPaused)
				ZoomMsg(0)
			ToolTip("Alt+Escape", 300)
		}
	}
}

WM_CONTEXTMENU() {
	MouseGetPos, , , wid, cid, 2
	If (cid != hActiveX && wid = hGui)
	{
		SetTimer, ShowSys, -1
		Return 0
	}
}

WM_MOVE() {
	SetTimer, SavePos, -200
}

ControlsMove(Width, Height) {
	Gui, TB: Show, % "NA y0 x" (Width - widthTB) // 2.2
	If isFindView
		Gui, F: Show, % "NA x" (Width - widthTB) // 2.2 " y" (Height - (Height < HeigtButton * 2 ? -2 : 27))
	WinMove, ahk_id %hActiveX%, , 0, HeigtButton, Width, Height - HeigtButton - (isFindView ? 28 : 0)
}

Minimize() {
	Sleep := 1
	ZoomMsg(1)
	Gui, 1: Minimize
}

ZoomSpot() {
	If (!isPaused && Sleep != 1 && WinActive("ahk_id" hGui))
		(ThisMode = "Mouse" ? (Spot_Mouse() (StateAllwaysSpot ? Spot_Win() : 0) Write_Mouse()) : (Spot_Win() (StateAllwaysSpot ? Spot_Mouse() : 0) Write_Win()))
}

MsgZoom(wParam, lParam) {
	If (wParam = 1)
	{
		SetTimer, ZoomSpot, -10
		Return 1
	}
	oOther.hZoom := lParam
	ZoomMsg(Sleep != 1 && !isPaused && !WinActive("ahk_id" hGui) ? 0 : 1)
}

ZoomMsg(wParam = -1, lParam = -1) {
	If WinExist("AhkSpyZoom ahk_id" oOther.hZoom)
		PostMessage, % MsgAhkSpyZoom, wParam, lParam, , % "ahk_id" oOther.hZoom
}

SavePos() {
	WinGet, Min, MinMax, ahk_id %hGui%
	If (!FullScreenMode && Min = 0)
	{
		If MemoryPos
		{
			WinGetPos, WinX, WinY, , , ahk_id %hGui%
			IniWrite(WinX, "MemoryPosX")
			IniWrite(WinY, "MemoryPosY")
		}
		If MemorySize
			GetClientPos(hGui, _, _, WinWidth, WinHeight)
			, IniWrite(WinWidth, "MemorySizeW")
			, IniWrite(WinHeight, "MemorySizeH")
	}
}

	;  http://forum.script-coding.com/viewtopic.php?pid=87817#p87817
	;  http://www.autohotkey.com/board/topic/93660-embedded-ie-shellexplorer-render-issues-fix-force-it-to-use-a-newer-render-engine/

FixIE(Fix) {
	Static Key := "Software\Microsoft\Internet Explorer\MAIN\FeatureControl\FEATURE_BROWSER_EMULATION"
	If A_IsCompiled
		ExeName := A_ScriptName
	Else
		SplitPath, A_AhkPath, ExeName
	If Fix
		RegWrite, REG_DWORD, HKCU, %Key%, %ExeName%, 0
	Else
		RegDelete, HKCU, %Key%, %ExeName%
}

RunPath(Link, WorkingDir="", Option="") {
	Run %Link%, %WorkingDir%, %Option%
	Minimize()
}

ExtraFile(Name, GetNoCompile = 0) {
	Static Dir := A_ScriptDir
	If GetNoCompile
		Return Dir "\" Name ".ahk"
	If FileExist(Dir "\" Name ".exe")
		Return Dir "\" Name ".exe"
	If FileExist(Dir "\" Name ".ahk")
		Return Dir "\" Name ".ahk"
}

RunRealPath(Path) {
	SplitPath, Path, , Dir
	Dir := LTrim(Dir, """")
	While !InStr(FileExist(Dir), "D")
		Dir := SubStr(Dir, 1, -1)
	Run, %Path%, %Dir%
}

ShowMarker(x, y, w, h, b:=4) {
	w < 8 || h < 8 ? b := 2 : 0
	Try Gui, M: Show, NA x%x% y%y% w%w% h%h%
	Catch
		Return HideMarker(), ShowMarker := 0
	ShowMarker := 1
	WinSet, Region, % "0-0 " w "-0 " w "-" h " 0-" h " 0-0 " b "-" b
		. " " w-b "-" b " " w-b "-" h-b " " b "-" h-b " " b "-" b, ahk_id %hMarkerGui%
}

ShowAccMarker(x, y, w, h, b:=2) {
	Try Gui, AcM: Show, NA x%x% y%y% w%w% h%h%
	Catch
		Return HideAccMarker(), (ShowMarker := ShowMarker ? 1 : 0)
	ShowMarker := 1
	WinSet, Region, % "0-0 " w "-0 " w "-" h " 0-" h " 0-0 " b "-" b
		. " " w-b "-" b " " w-b "-" h-b " " b "-" h-b " " b "-" b, ahk_id %hMarkerAccGui%
}

HideMarker() {
	Gui, M: Show, Hide
}

HideAccMarker() {
	Gui, AcM: Show, Hide
}

CheckHideMarker() {
	Static Try := 0
	SetTimer, CheckHideMarker, -150
	Return

	CheckHideMarker:
		If !(Try := ++Try > 2 ? 0 : Try)
			Return
		WinActive("ahk_id" hGui) ? (HideMarker(), HideAccMarker()) : 0
		SetTimer, CheckHideMarker, -250
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

IniRead(Key, Error := " ") {
	IniRead, Value, %A_AppData%\AhkSpy.ini, AhkSpy, %Key%, %Error%
	Return Value
}
IniWrite(Value, Key) {
	IniWrite, %Value%, %A_AppData%\AhkSpy.ini, AhkSpy, %Key%
	Return Value
}

InArr(Val, Arr*) {
	For k, v in Arr
		If (v == Val)
			Return k
}

TransformHTML(str) {
	Transform, str, HTML, %str%, 3
	StringReplace, str, str,`n,, 1
	Return str
}

ExistSelectedText(byref Copy) {
	MouseGetPos, , , , ControlID, 2
	If (ControlID != hActiveX)
		Return 0
	Copy := oDoc.selection.createRange().text
	If Copy is space
		Return 0
	; html := oDoc.selection.createRange().htmlText
	; While pos := RegExMatch(html, "i)<SPAN id=param>(.)<SPAN style=""FONT-SIZE: 0.7em"">(.)</SPAN></SPAN>(\d+)", m, pos)
		; Copy := StrReplace(Copy, m1 m2 m3, m1 m3, , 1), pos++
	Copy := RegExReplace(Trim(Copy), Chr(0x25aa) Chr(0x25aa) "+", "#!#")
	StringReplace, Copy, Copy, % Chr(0x25aa), #, 1
	StringReplace, Copy, Copy, #!#  copy  #!#, #!#, 1
	StringReplace, Copy, Copy, #!#  pause  #!#, #!#
	Return 1
}

	;  http://forum.script-coding.com/viewtopic.php?pid=53516#p53516

GetCommandLineProc(pid) {
	ComObjGet("winmgmts:").ExecQuery("Select * from Win32_Process WHERE ProcessId = " pid)._NewEnum.next(X)
	Return Trim(X.CommandLine)
}

	;  http://www.autohotkey.com/board/topic/69254-func-api-getwindowinfo-ahk-l/#entry438372

GetClientPos(hwnd, ByRef left, ByRef top, ByRef w, ByRef h) {
	VarSetCapacity(pwi, 60, 0), NumPut(60, pwi, 0, "UInt")
	DllCall("GetWindowInfo", "Ptr", hwnd, "UInt", &pwi)
	top := NumGet(pwi, 24, "Int") - NumGet(pwi, 8, "Int")
	left := NumGet(pwi, 52, "Int")
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
			Return (CLSID := window.Document.Folder.Self.Path) ~= "^::\{" ? "`n<span id='param'>CLSID: </span>" CLSID : ""
}

	;  http://msdn.microsoft.com/en-us/library/windows/desktop/ms632600(v=vs.85).aspx
	;  http://msdn.microsoft.com/en-us/library/windows/desktop/ff700543(v=vs.85).aspx

GetStyles(Style, ExStyle) {
	Static Styles := {"WS_BORDER":"0x00800000", "WS_CAPTION":"0x00C00000", "WS_CHILD":"0x40000000", "WS_CHILDWINDOW":"0x40000000"
		, "WS_CLIPCHILDREN":"0x02000000", "WS_CLIPSIBLINGS":"0x04000000", "WS_DISABLED":"0x08000000", "WS_DLGFRAME":"0x00400000"
		, "WS_GROUP":"0x00020000", "WS_HSCROLL":"0x00100000", "WS_ICONIC":"0x20000000", "WS_MAXIMIZE":"0x01000000"
		, "WS_MAXIMIZEBOX":"0x00010000", "WS_MINIMIZE":"0x20000000", "WS_MINIMIZEBOX":"0x00020000", "WS_OVERLAPPED":"0x00000000"
		, "WS_SIZEBOX":"0x00040000", "WS_SYSMENU":"0x00080000", "WS_TABSTOP":"0x00010000", "WS_THICKFRAME":"0x00040000"
		, "WS_TILED":"0x00000000", "WS_VISIBLE":"0x10000000", "WS_VSCROLL":"0x00200000", "WS_POPUP":"0x80000000"}

		, ExStyles := {"WS_EX_ACCEPTFILES":"0x00000010", "WS_EX_APPWINDOW":"0x00040000", "WS_EX_CLIENTEDGE":"0x00000200"
		, "WS_EX_COMPOSITED":"0x02000000", "WS_EX_CONTEXTHELP":"0x00000400", "WS_EX_CONTROLPARENT":"0x00010000"
		, "WS_EX_DLGMODALFRAME":"0x00000001", "WS_EX_LAYERED":"0x00080000", "WS_EX_LAYOUTRTL":"0x00400000"
		, "WS_EX_LEFT":"0x00000000", "WS_EX_LEFTSCROLLBAR":"0x00004000", "WS_EX_LTRREADING":"0x00000000"
		, "WS_EX_MDICHILD":"0x00000040", "WS_EX_NOACTIVATE":"0x08000000", "WS_EX_NOINHERITLAYOUT":"0x00100000"
		, "WS_EX_NOPARENTNOTIFY":"0x00000004", "WS_EX_NOREDIRECTIONBITMAP":"0x00200000", "WS_EX_RIGHT":"0x00001000"
		, "WS_EX_RIGHTSCROLLBAR":"0x00000000", "WS_EX_RTLREADING":"0x00002000", "WS_EX_STATICEDGE":"0x00020000"
		, "WS_EX_TOOLWINDOW":"0x00000080", "WS_EX_TOPMOST":"0x00000008", "WS_EX_TRANSPARENT":"0x00000020"
		, "WS_EX_WINDOWEDGE":"0x00000100"}

	For K, V In Styles
		Ret .= Style & V ? K "<span id='param'> := " V "</span>`n" : ""
	For K, V In ExStyles
		RetEx .= ExStyle & V ? K "<span id='param'> := " V "</span>`n" : ""
	If Ret !=
		Res .= D1 " <span id='title'>( Styles )</span> " D2 "`n" Ret
	If RetEx !=
		Res .= D1 " <span id='title'>( ExStyles )</span> " D2 "`n" RetEx
	Return (Res = "" ? "" : "`n") . RTrim(Res, "`n")
}

ToggleLocale() {
	LocaleID := DllCall("GetKeyboardLayout", "Int"
	, DllCall("GetWindowThreadProcessId", "Int", WinExist("A"), "Int", "0"))
	ControlGetFocus, CtrlFocus
	PostMessage, 0x50, 0, LocaleID = 0x4090409 ? 0x4190419 : 0x4090409, %CtrlFocus%
	Return LocaleID = 0x4090409 ? "Rus" : "Eng"
}

ToolTip(text, time) {
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

MouseStep(x, y) {
	MouseMove, x, y, 0, R
	If (Sleep != 1 && !isPaused && ThisMode != "Hotkey" && WinActive("ahk_id" hGui))
	{
		(ThisMode = "Mouse" ? (Spot_Mouse() (StateAllwaysSpot ? Spot_Win() : 0) Write_Mouse()) : (Spot_Win() (StateAllwaysSpot ? Spot_Mouse() : 0) Write_Win()))
		ZoomMsg(2)
	}
}

IsIEFocus() {
	ControlGetFocus, Focus
	Return InStr(Focus, "Internet")
}

NextLink(s = "") {
	curpos := oDoc.body.scrollTop, oDoc.body.scrollLeft := 0
	If (!curpos && s = "-")
		Return
	While (pos := oDoc.getElementsByTagName("a").item(A_Index-1).getBoundingClientRect().top) != ""
		(s 1) * pos > 0 && (!res || abs(res) > abs(pos)) ? res := pos : ""       ; http://forum.script-coding.com/viewtopic.php?pid=82360#p82360
	If (res = "" && s = "")
		Return
	st := !res ? -curpos : res, co := abs(st) > 150 ? 80 : 30
	Loop % co
		oDoc.body.scrollTop := curpos + (st*(A_Index/co))
	oDoc.body.scrollTop := curpos + res
}

Update(in=1) {
	Static att, Ver, req
		, url1 := "https://raw.githubusercontent.com/serzh82saratov/AhkSpy/master/Readme.txt"
		, url2 := "https://raw.githubusercontent.com/serzh82saratov/AhkSpy/master/AhkSpy.ahk"
		, urlZoom := "https://raw.githubusercontent.com/serzh82saratov/AhkSpy/master/Extra/AhkSpyZoom.ahk"
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
				Return (Ver := RegExReplace(Text, "i).*?version\s*(.*?)\R.*", "$1")) > AhkSpyVersion ? Update(2) : 0
			If (!InStr(Text, "AhkSpyVersion"))
				Return
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
			If FileExist(ExtraFile("AhkSpyZoom", 1))
			{
				req.open("GET", urlZoom, 0), req.send()
				Text := req.responseText
				File := FileOpen(ExtraFile("AhkSpyZoom", 1), "w", "UTF-8")
				File.Length := 0, File.Write(Text), File.Close()
			}
			Reload
		}
		Error := (++att = 20 || Status != "")
		SetTimer, % Error ? "UpdateAhkSpy" : "Upd_Verifi", % Error ? -60000 : -3000
		Return
}

ViewStyles(elem) {
	elem.innerText := (w_ShowStyles := !w_ShowStyles) ? "hide styles" : "show styles"
	oDoc.getElementById("AllWinStyles").innerHTML := w_ShowStyles
	? RegExReplace(GetStyles(oDoc.getElementById("c_Style").innerText
	, oDoc.getElementById("c_ExStyle").innerText), "\n", "<br>") : ""
	HTML_Win := oDoc.body.innerHTML
}

HighLight(elem, time="", RemoveFormat=1) {
	Try SetTimer, UnHighLight, % "-" time
	R := oDoc.body.createTextRange()
	RemoveFormat ? R.execCommand("RemoveFormat") : 0
	R.moveToElementText(elem)
	R.collapse(1), R.select()
	R.moveToElementText(elem)
	R.execCommand("BackColor", 0, "3399FF")
	R.execCommand("ForeColor", 0, "FFEEFF")
	Return

	UnHighLight:
		oDoc.body.createTextRange().execCommand("RemoveFormat")
		Return
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
	SetTimer, % hFunc, % Max ? -150 : -50
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

FindView() {
	If !isFindView
	{
		GuiControlGet, p, 1:Pos, %hActiveX%
		GuiControl, 1:Move, %hActiveX%, % "x" pX " y" pY " w" pW " h" pH - 28
		Gui, F: Show, % "NA x" (pW - widthTB) // 2.2 " h26 y" (pY + pH - 27)
		isFindView := 1
	}
	GuiControl, F:Focus, Edit1
	FindSearch(1)
}

FindHide() {
	Gui, F: Show, Hide
	GuiControlGet, a, 1:Pos, %hActiveX%
	GuiControl, 1:Move, %hActiveX%, % "x" aX "y" aY "w" aW "h" aH + 28
	isFindView := 0
	GuiControl, Focus, %hActiveX%
}

FindOption(Hwnd) {
	GuiControlGet, p, Pos, %Hwnd%
	If pX =
		Return
	ControlGet, Style, Style,, , ahk_id %Hwnd%
	ControlGetText, Text, , ahk_id %Hwnd%
	DllCall("DestroyWindow", "Ptr", Hwnd)
	Gui, %A_Gui%: Add, Text, % "x" pX " y" pY " w" pW " h" pH " g" A_ThisFunc " " (Style & 0x1000 ? "c2F2F2F +0x201" : "+Border +0x1201"), % Text
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
	R := oDoc.selection.createRange(), Matches := 0
	R.moveToElementText(oDoc.getElementById("pre")), R.collapse(1)
	Option := (oFind.Whole ? 2 : 0) ^ (oFind.Registr ? 4 : 0)
	Loop
	{
		F := R.findText(oFind.Text, 1, Option)
		If (F = 0)
			Break
		El := R.parentElement()
		If (El.TagName ~= "^(BUTTON|INPUT)$" || El.ID ~= "^(delimiter|title|param)$") && !R.collapse(0)
			Continue
		; R.execCommand("BackColor", 0, "EF0FFF")
		; R.execCommand("ForeColor", 0, "FFEEFF")
		R.collapse(0), ++Matches
	}
	GuiControl, F:Text, FindMatches, % Matches ? Matches : ""
}

FindSearch(This, Back = 0) {
	Global hFindEdit
	R := oDoc.selection.createRange(), sR := R.duplicate()
	R.collapse(This || Back ? 1 : 0)
	If (oFind.Text = "" && !R.select())
		SetEditColor(hFindEdit, 0xFFFFFF, 0x000000)
	Else {
		Option := (Back ? 1 : 0) ^ (oFind.Whole ? 2 : 0) ^ (oFind.Registr ? 4 : 0)
		Loop {
			F := R.findText(oFind.Text, 1, Option)
			If (F = 0) {
				If !A {
					R.moveToElementText(oDoc.getElementById("pre")), R.collapse(!Back), A := 1
					Continue
				}
				If This
					sR.collapse(1), sR.select()
				Break
			}
			If (!This && R.isEqual(sR)) {
				If A {
					hFunc := Func("SetEditColor").Bind(hFindEdit, 0xFFFFFF, 0x000000)
					SetTimer, % hFunc, -200
				}
				Break
			}
			El := R.parentElement()
			If (El.TagName ~= "^(BUTTON|INPUT)$" || El.ID ~= "^(delimiter|title|param)$") && !R.collapse(Back)
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

	;  http://forum.script-coding.com/viewtopic.php?pid=82283#p82283

Class Events {
	onclick() {
	Global CopyText
		oevent := oDoc.parentWindow.event.srcElement
		tagname := oevent.tagname
		If (tagname = "BUTTON")
		{
			thisid := oevent.id
			oDoc.body.focus()
			If (thisid = "copy_button" || thisid = "copy_button_1")
				o := oDoc.all.item(oevent.sourceIndex + 2 + (thisid = "copy_button_1"))
				, Clipboard := o.OuterText, HighLight(o, 500)
			Else If thisid = copy_alltitle
			{
				Clipboard := (t:=oDoc.getElementById("wintitle1").OuterText) . (t = "" ? "" : " ")
					. oDoc.getElementById("wintitle2").OuterText " "
					. oDoc.getElementById("wintitle3").OuterText
				HighLight(oDoc.getElementById("wintitle1"), 500)
				HighLight(oDoc.getElementById("wintitle2"), 500, 0)
				HighLight(oDoc.getElementById("wintitle3"), 500, 0)
			}
			Else If thisid = keyname
			{
				v_edit := Format("{:L}", o_edithotkey.value), name := GetKeyName(v_edit)
				If (name = v_edit)
					o_editkeyname.value := Format("vk{:X}", GetKeyVK(v_edit)) (!(sc := GetKeySC(v_edit)) ? "" : Format("sc{:X}", sc))
				Else
					o_editkeyname.value := (StrLen(name) = 1 ? (Format("{:U}", name)) : name)
				o := name = "" ? o_edithotkey : o_editkeyname
				o.focus(), o.createTextRange().select()
			}
			Else If thisid = pause_button
				Gosub, PausedScript
			Else If thisid = w_folder
			{
				If FileExist(FilePath := oDoc.getElementById("copy_processpath").OuterText)
					SelectFilePath(FilePath), Minimize()
				Else
					ToolTip("Not file exist", 500)
			}
			Else If thisid = paste_process_path
				oDoc.getElementById("copy_processpath").innerHTML := TransformHTML(Trim(Trim(Clipboard), """"))
			Else If thisid = w_command_line
				RunRealPath(oDoc.getElementById("c_command_line").OuterText)
			Else If thisid = paste_command_line
				oDoc.getElementById("c_command_line").innerHTML := TransformHTML(Clipboard)
			Else If thisid = process_close
				Process, Close, % oOther.WinPID
			Else If thisid = win_close
				WinClose, % "ahk_id" oOther.WinID
			Else If (thisid = "numlock" || thisid = "scrolllock")
				Events.num_scroll(thisid)
			Else If thisid = rus_eng
				ToolTip(ToggleLocale(), 500)
			Else If thisid = paste_keyname
				o_edithotkey.value := "", o_edithotkey.focus(), oDoc.execCommand("Paste"), oDoc.getElementById("keyname").click()
			Else If (thisid = "copy_selected" && ExistSelectedText(CopyText) && ToolTip("copy", 500))
				GoSub CopyText
			Else If thisid = get_styles
				ViewStyles(oevent)
			Else If thisid = run_AccViewer
				RunPath(ExtraFile("AccViewer Source"))
			Else If thisid = run_iWB2Learner
				RunPath(ExtraFile("iWB2 Learner"))
			Else If thisid = set_button_pos
			{
				HayStack := oevent.OuterText = "Pos:"
				? oDoc.all.item(oevent.sourceIndex + 1).OuterText " " oDoc.all.item(oevent.sourceIndex + 5).OuterText
				: oDoc.all.item(oevent.sourceIndex - 3).OuterText " " oDoc.all.item(oevent.sourceIndex + 1).OuterText
				RegExMatch(HayStack, "(-*\d+[\.\d+]*).*\s+.*?(-*\d+[\.\d+]*).*\s+.*?(-*\d+[\.\d+]*).*\s+.*?(-*\d+[\.\d+]*)", p)
				If (p1 + 0 = "" || p2 + 0 = "" || p3 + 0 = "" || p4 + 0 = "")
					Return ToolTip("Invalid parametrs", 500)
				If (ThisMode = "Win")
					WinMove, % "ahk_id " oOther.WinID, , p1, p2, p3, p4
				Else
					ControlMove, , p1, p2, p3, p4, % "ahk_id " oOther.MouseControlID
			}
			Else If thisid = set_button_focus_ctrl
			{
				hWnd := oOther.MouseControlID
				ControlFocus, , ahk_id %hWnd%
				WinGetPos, X, Y, W, H, ahk_id %hWnd%
				If (X + Y != "")
					DllCall("SetCursorPos", "Uint", X + W // 2, "Uint", Y + H // 2)
			}
			Else If thisid = set_button_mouse_pos
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
						hWnd := oOther.MouseControlID
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
				GoSub, +Tab
				Sleep 350
				HideMarker(), HideAccMarker()
				BlockInput, MouseMoveOff
			}
			Else If thisid = run_AhkSpyZoom
				Events.AhkSpyZoomShow()
		}
		Else If (ThisMode = "Hotkey" && !Hotkey_Arr("Hook") && !isPaused && tagname ~= "PRE|SPAN")
			Hotkey_Hook(1)
	}
	ondblclick()  {
		oevent := oDoc.parentWindow.event.srcElement
		If (oevent.isContentEditable && oevent.tagname != "input" && (rng := oDoc.selection.createRange()).text != "")
		{
			While !t
				rng.moveEnd("character", 1), (SubStr(rng.text, 0) = "_" ? rng.moveEnd("word", 1)
					: (rng.moveEnd("character", -1), t := 1))
			While t
				rng.moveStart("character", -1), (SubStr(rng.text, 1, 1) = "_" ? rng.moveStart("word", -1)
					: (rng.moveStart("character", 1), t := 0))
			sel := rng.text, rng.moveEnd("character", StrLen(RTrim(sel)) - StrLen(sel)), rng.select()
		}
		Else If (oevent.tagname = "BUTTON")
		{
			thisid := oevent.id
			oDoc.body.focus()
			If (thisid = "numlock" || thisid = "scrolllock")
				Events.num_scroll(thisid)
			Else If thisid = pause_button
				Gosub, PausedScript
			Else If thisid = get_styles
				ViewStyles(oevent)
			Else If thisid = run_AhkSpyZoom
				Events.AhkSpyZoomShow()
		}
	}
	onfocus() {
		Sleep 100
		Hotkey_Hook(0)
	}
	onblur() {
		Sleep 100
		If (WinActive("ahk_id" hGui) && !isPaused && ThisMode = "Hotkey")
			Hotkey_Hook(1)
	}

	num_scroll(thisid) {
		(OnHook := Hotkey_Arr("Hook")) ? Hotkey_Hook(0) : 0
		SendInput, {%thisid%}
		(OnHook ? Hotkey_Hook(1) : 0)
		ToolTip(thisid " " (GetKeyState(thisid, "T") ? "On" : "Off"), 500)
	}
	AhkSpyZoomShow() {
		WindowVisible := DllCall("IsWindowVisible", "Ptr", oOther.hZoom)
;		If (!isPaused && !WindowVisible)
;			SendInput {LAlt Down}{Escape}{LAlt Up}
		If !WinExist("AhkSpyZoom ahk_id" oOther.hZoom) && IniWrite(1, "ZoomShow")
			Run % ExtraFile("AhkSpyZoom") " " hGui " " ActiveNoPause
		Else
			ZoomMsg(WindowVisible ? 3 : 4)
			, IniWrite(WindowVisible ? 0 : 1, "ZoomShow")
		ZoomMsg(7, isPaused)
	}
}
	;)
