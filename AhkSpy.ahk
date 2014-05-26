	;  AhkSpy
	;  Автор - serzh82saratov
	;  Спасибо wisgest за помощь в создании HTML интерфейса этой версии скрипта
	;  Тема - http://forum.script-coding.com/viewtopic.php?pid=72244#p72244
	;  Коллекция - http://forum.script-coding.com/viewtopic.php?pid=72459#p72459
	;  GitHub - https://github.com/serzh82saratov/AhkSpy/blob/master/AhkSpy.ahk

#NoTrayIcon
#SingleInstance Force
#NoEnv
SetBatchLines, -1
ListLines, Off
DetectHiddenWindows, On

Global AhkSpyVersion := 1.153
Gosub, RevAhkVersion
Menu, Tray, Icon, Shell32.dll, % A_OSVersion = "WIN_7" ? 278 : 222

# := "&#9642"									;  Символ разделителя заголовков - &#8226 | &#9642
Color# := "E14B30"								;  Цвет шрифта разделителя заголовков и параметров
Global ThisMode := "Mouse"						;  Стартовый режим - Win|Mouse|Hotkey
, HeightStart := 550							;  Высота окна при старте
, FontSize := 15								;  Размер шрифта
, FontFamily :=  "Arial"						;  Шрифт - Times New Roman | Georgia | Myriad Pro | Arial
, ColorFont := ""								;  Цвет шрифта
, ColorBg := ColorBgOriginal := "F0F0F0"		;  Цвет фона
, ColorBgPaused := "E4E4E4"						;  Цвет фона при паузе
, ColorTitle := "27419B"						;  Цвет шрифта заголовка
, ColorParam := "189200"						;  Цвет шрифта параметров

, DP := "  <span style='color: " Color# "'>" # "</span>  ", D1, D2, DB
, StateLight:=((t:=IniRead("StateLight"))=""||t>3?3:t), StateLightAcc:=IniRead("StateLightAcc"), StateUpdate:=IniRead("StateUpdate")
, hGui, hActiveX, hMarkerGui, hMarkerAccGui, oDoc, ShowMarker, isIE, isPaused, ScrollPos:={}, AccCoord:=[]
, HWND_3, WinCloseID, WinProcessPath, CtrlStyle, HTML_Win, HTML_Mouse, HTML_Hotkey, o_edithotkey, o_editkeyname, rmCtrlX, rmCtrlY
, copy_button := "<span contenteditable='false' unselectable='on'><button id='copy_button'> copy </button></span>"
, pause_button := "<span contenteditable='false' unselectable='on'><button id='pause_button'> pause </button></span>"
TitleTextP2 := "     ( Shift+Tab - Freeze | RButton - CopySelected | Shift - Backlight object | Break - Pause )     v" AhkSpyVersion
BLGroup := ["Backlight allways","Backlight disable","Backlight hold shift button"]
wKey := 140					;  Ширина кнопок
wColor := wKey//2			;  Ширина цветного фрагмента
HeigtButton := 32			;  Высота кнопок
RangeTimer := 100			;  Период опроса данных, увеличьте на слабом ПК
Loop 24
	D1 .= #
Loop 20
	D2 .= D1
D1 := "<span style='color: " Color# "'>" D1 "</span>"
D2 := "<span style='color: " Color# "'>" D2 "</span>"
DB := "<span style='color: " Color# "'>" # # # # # # # # # # # # "</span>"

Gui, +AlwaysOnTop +HWNDhGui +ReSize -DPIScale
Gui, Color, %ColorBgPaused%
Gui, Add, ActiveX, Border voDoc HWNDhActiveX x0 y+0, HTMLFile

Gui, TB: +HWNDhTBGui -Caption -DPIScale +Parent%hGui% +E0x08000000
Gui, TB: Font, % " s" (A_ScreenDPI = 120 ? 8 : 10), Verdana
Gui, TB: Add, Button, x0 y0 h%HeigtButton% w%wKey% vBut1 gMode_Win, Window
Gui, TB: Add, Button, x+0 yp hp wp vBut2 gMode_Mouse, Mouse && Control
Gui, TB: Add, Progress, x+0 yp hp w%wColor% vColorProgress cWhite, 100
Gui, TB: Add, Button, x+0 yp hp w%wKey% vBut3 gMode_Hotkey, Button
Gui, TB: Show, % "x0 y0 NA h" HeigtButton " w" widthTB := wKey*3+wColor

OnExit, Exit
OnMessage(0x201, "WM_LBUTTONDOWN")
OnMessage(0x6, "WM_ACTIVATE")
ComObjError(false), ComObjConnect(oDoc, Events)
DllCall("RegisterShellHookWindow", "UInt", A_ScriptHwnd)
OnMessage(DllCall("RegisterWindowMessage", "str", "SHELLHOOK"), "ShellProc")

Gui, M: Margin, 0, 0
Gui, M: -DPIScale +AlwaysOnTop +HWNDhMarkerGui +E0x08000000 +E0x20 -Caption
Gui, M: Color, E14B30
WinSet, TransParent, 250, ahk_id %hMarkerGui%
Gui, AcM: Margin, 0, 0
Gui, AcM: -DPIScale +AlwaysOnTop +HWNDhMarkerAccGui +E0x08000000 +E0x20 -Caption
Gui, AcM: Color, 26419F
WinSet, TransParent, 250, ahk_id %hMarkerAccGui%
ShowMarker(0, 0, 0, 0, 0), ShowAccMarker(0, 0, 0, 0, 0), HideMarker()

Menu, Sys, Add, Backlight allways, Sys_Backlight
Menu, Sys, Add, Backlight disable, Sys_Backlight
Menu, Sys, Add, Backlight hold shift button, Sys_Backlight
Menu, Sys, Check, % BLGroup[StateLight]
Menu, Sys, Add
Menu, Sys, Add, Acc object backlight, Sys_Acclight
Menu, Sys, % StateLightAcc ? "Check" : "UnCheck", Acc object backlight
Menu, Sys, Add
Menu, Sys, Add, Pause AhkSpy, PausedScript
Menu, Sys, Add, Default size, DefaultSize
Menu, Sys, Add, Reload AhkSpy, Reload
Menu, Sys, Add, Suspend Hotkeys, Suspend
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
Menu, Help, Add, About AhkSpy, Sys_Help
Menu, Help, Add
If FileExist(SubStr(A_AhkPath,1,InStr(A_AhkPath,"\",,0,1)) "AutoHotkey.chm")
	Menu, Help, Add, AutoHotKey help file, LaunchHelp
Menu, Help, Add, AutoHotKey official help online, Sys_Help
Menu, Help, Add, AutoHotKey russian help online, Sys_Help
Menu, Sys, Add, Help, :Help
Menu, Sys, Color, % ColorBgOriginal
OnMessage(0x7B, "WM_CONTEXTMENU")

Gui, Show, NA h%HeightStart% w%widthTB%
Gui, +MinSize%widthTB%x%HeigtButton%

Gosub, HotkeyRules
Gosub, Mode_%ThisMode%
Return

	; _________________________________________________ Hotkey`s _________________________________________________

#If (Sleep != 1 && !isPaused && ThisMode != "Hotkey")

+Tab::
	(ThisMode = "Mouse" ? Spot_Mouse() Spot_Win() Write_Mouse() : Spot_Win() Spot_Mouse() Write_Win())
	If !WinActive("ahk_id" hGui)
	{
		WinActivate ahk_id %hGui%
		GuiControl, 1:Focus, oDoc
	}
	Return

#If Sleep != 1

Break::
Pause::
PausedScript:
	isPaused := !isPaused
	oDoc.body.style.background := (ColorBg := isPaused ? ColorBgPaused : ColorBgOriginal)
	Try SetTimer, Loop_%ThisMode%, % isPaused ? "Off" : "On"
	If (ThisMode = "Hotkey" && WinActive("ahk_id" hGui))
		Hotkey_Hook := isPaused ? Hotkey_Reset() : 1
	If !WinActive("ahk_id" hGui)
		(ThisMode = "Mouse" ? Spot_Win() : ThisMode = "Win" ? Spot_Mouse() : 0)
	HideMarker()
	Menu, Sys, % isPaused ? "Check" : "UnCheck", Pause AhkSpy
	Return

#If WinActive("ahk_id" hGui)

~^WheelUp::
~^WheelDown:: SetTimer, ScrollLeft, -300
ScrollLeft:
	oDoc.body.ScrollLeft := 1
	Return

^vk5A:: oDoc.execCommand("Undo")							;  Ctrl+Z

Volume_Up::
^vk43:: Clipboard := oDoc.selection.createRange().text		;  Ctrl+C

Volume_Down::
^vk56:: oDoc.execCommand("Paste")							;  Ctrl+V

^vk41:: oDoc.execCommand("SelectAll")						;  Ctrl+A

^vk58:: oDoc.execCommand("Cut")								;  Ctrl+X

Del:: oDoc.execCommand("Delete")							;  Delete

Enter:: oDoc.selection.createRange().text := " `n"			;  &shy

Tab:: oDoc.selection.createRange().text := "    "			;  &emsp

F1::
+WheelUp:: NextLink("-")

F2::
+WheelDown:: NextLink()

F3::
~!WheelUp:: WheelLeft

F4::
~!WheelDown:: WheelRight

F5:: oDoc.body.innerHTML := HTML_%ThisMode%					;  Return HTML

F6:: AppsKey

!Space:: SetTimer, ShowSys, -1

#If WinActive("ahk_id" hGui) && ExistSelectedText(CopyText)

RButton::
	Clipboard := CopyText
	StringReplace, toTitle, CopyText, `r`n, , 1
	SendMessage, 0xC, 0, &toTitle, , ahk_id %hGui%
	SetTimer, TitleShow, -1000
	Return

#If ShowMarker

~Shift Up:: HideMarker()

#If

	; _________________________________________________ Mode_Win _________________________________________________

Mode_Win:
	If A_GuiControl
		GuiControl, 1:Focus, oDoc
	GuiControl, TB: -0x0001, But1
	If (ThisMode = "Hotkey")
		Hotkey_Reset()
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

Loop_Win:
	If (WinActive("ahk_id" hGui) || Sleep = 1)
		GoTo Repeat_Loop_Win
	If Spot_Win()
		Write_Win()
Repeat_Loop_Win:
	If !isPaused
		SetTimer, Loop_Win, -%RangeTimer%
	Return

Spot_Win(NotHTML=0)   {
	Static PrWinPID, CommandLine
	If NotHTML
		GoTo HTML_Win
	MouseGetPos,,,WinID
	If (WinID = hGui && HideMarker())
		Return 0
	WinGetTitle, WinTitle, ahk_id %WinID%
	WinCloseID:=WinID, WinTitle:=TransformHTML(WinTitle)
	WinGetPos, WinX, WinY, WinWidth, WinHeight, ahk_id %WinID%
	WinGetClass, WinClass, ahk_id %WinID%
	WinGet, WinProcessPath, ProcessPath, ahk_id %WinID%
	Loop, %WinProcessPath%
		WinProcessPath = %A_LoopFileLongPath%
	SplitPath, WinProcessPath, WinProcessName
	WinGet, WinPID, PID, ahk_id %WinID%
	If (PrWinPID != WinPID && PrWinPID := WinPID)
		CommandLine := TransformHTML(GetCommandLineProc(WinPID))
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
		WinText := TransformHTML( WinClass = "Notepad++" ? SubStr(WinText, 1, 5000) : WinText)
		, WinText := "`n" D1 " <a></a><span id='title'>( Window Text )</span> " DB " " copy_button " " D2 "`n<span>" WinText "</span>"
	CoordMode, Mouse
	CoordMode, Pixel
	MouseGetPos, WinXS, WinYS
	PixelGetColor, ColorRGB, %WinXS%, %WinYS%, RGB
	GuiControl, TB: -Redraw, ColorProgress
	GuiControl, % "TB: +c" SubStr(ColorRGB, 3), ColorProgress
	GuiControl, TB: +Redraw, ColorProgress

HTML_Win:
	HTML_Win =
( Ltrim
	<body id='body'><pre id='pre'; contenteditable='true'>
	%D1% <span id='title'>( Title )</span> %DB% %pause_button% %D2%
	%WinTitle%
	%D1% <span id='title'>( Class )</span> %D2%
	<span id='param'>ahk_class</span> %WinClass%
	%D1% <span id='title'>( ProcessName )</span> %D2%
	<span id='param'>ahk_exe</span> %WinProcessName%
	%D1% <span id='title'>( ProcessPath )</span> %D2%
	%WinProcessPath%%DP%<span contenteditable='false' unselectable='on'><button id='folder'>folder view</button></span>
	%D1% <span id='title'>( CommandLine )</span> %D2%
	%CommandLine%
	%D1% <span id='title'>( Position`s )</span> %D2%
	<span id='param'>Pos:</span>  x%WinX% y%WinY%%DP%<span id='param'>Size:</span>  w%WinWidth% h%WinHeight%%DP%%WinX%, %WinY%, %WinWidth%, %WinHeight%
	<span id='param'>Client area size:</span>  w%caW% h%caH%%DP%<span id='param'>top</span> %caY% <span id='param'>left</span> %caX% <span id='param'>bottom</span> %caWinBottom% <span id='param'>right</span> %caWinRight%
	%D1% <span id='title'>( Other )</span> %D2%
	<span id='param'>PID:</span>  %WinPID%%DP%<span id='param'>Count window this PID:</span> %WinCountProcess%%DP%<span id='param'>Control count:</span> %CountControl%
	<span id='param'>HWND:</span>  %WinID%%DP%<span contenteditable='false' unselectable='on'><button id='winclose'>win kill</button></span>%DP%<span id='param'>Style:</span>  %WinStyle%%DP%<span id='param'>ExStyle:</span>  %WinExStyle%%WinTransparent%%WinTransColor%%SBText%%WinText%
	<a></a>%D2%</pre></body>

	<style>
	body {background-color: '#%ColorBg%'; color: '%ColorFont%'}
	pre {font-family: '%FontFamily%'; font-size: '%FontSize%'; position: absolute; top: 5px}
	#title {color: '%ColorTitle%'}
	#param {color: '%ColorParam%'}
	button {font-size: 0.9em; border: 1px dashed black}
	</style>
	)
	If (ThisMode = "Win") && (StateLight = 1 || (StateLight = 3 && GetKeyState("Shift", "P")))
		ShowMarker(WinX, WinY, WinWidth, WinHeight, 5)
	Return 1
}

Write_Win()   {
	oDoc.body.innerHTML := HTML_Win
	Return 1
}

	; _________________________________________________ Mode_Mouse _________________________________________________

Mode_Mouse:
	If A_GuiControl
		GuiControl, 1:Focus, oDoc
	GuiControl, TB: -0x0001, But2
	If (ThisMode = "Hotkey")
		Hotkey_Reset()
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

Loop_Mouse:
	If WinActive("ahk_id" hGui) || Sleep = 1
		GoTo Repeat_Loop_Mouse
	If Spot_Mouse()
		Write_Mouse()
Repeat_Loop_Mouse:
	If !isPaused
		SetTimer, Loop_Mouse, -%RangeTimer%
	Return

Spot_Mouse(NotHTML=0)   {
	Static
	rmCtrlX := rmCtrlY := "", isIE:=0
	If NotHTML
		GoTo HTML_Mouse
	WinGet, ProcessName_A, ProcessName, A
	CoordMode, Mouse
	MouseGetPos, , , , HWND_3, 3
	MouseGetPos, MXS, MYS,, tControlNN
	CoordMode, Mouse, Window
	MouseGetPos, MXWA, MYWA, tWinID, tControlID, 2
	WinGetPos, WinX, WinY, , , ahk_id %WinID%
	RWinX := MXS - WinX, RWinY := MYS - WinY
	GetClientPos(WinID, caX, caY, caW, caH)
	MXC := RWinX - caX, MYC := RWinY - caY
	If (tWinID != hGui)
	{
		WinID := tWinID, CtrlInfo := ""
		ControlNN := tControlNN, ControlID := tControlID
		CoordMode, Pixel
		PixelGetColor, ColorRGB, %MXS%, %MYS%, RGB
		PixelGetColor, ColorBGR, %MXS%, %MYS%
		sColorBGR := SubStr(ColorBGR, 3)
		GuiControl, TB: -Redraw, ColorProgress
		GuiControl, % "TB:+c" sColorRGB := SubStr(ColorRGB, 3), ColorProgress
		GuiControl, TB: +Redraw, ColorProgress
		ControlGetPos, CtrlX, CtrlY, CtrlW, CtrlH,, ahk_id %ControlID%
		CtrlCAX := CtrlX - caX, CtrlCAY := CtrlY - caY
		CtrlX2 := CtrlX+CtrlW, CtrlY2 := CtrlY+CtrlH
		CtrlCAX2 := CtrlX2-caX, CtrlCAY2 := CtrlY2-caY
		IsGetUTF8 := InStr(ControlNN, "Scintilla")
		ControlGetText, CtrlText, , ahk_id %ControlID%
		If CtrlText !=
		{
			CtrlText := TransformHTML(IsGetUTF8 ? StrGet(&CtrlText, "utf-8") : CtrlText)
			CtrlText = `n%D1% <a></a><span id='title'>( Control text )</span> %DB% %copy_button% %D2%`n<span>%CtrlText%</span>
		}
		AccText := AccInfoUnderMouse(MXS, MYS)
		If AccText !=
			AccText = `n%D1% <a></a><span id='title'>( AccInfo )</span> %D2%%AccText%
		ControlGet, CtrlStyle, Style,,, ahk_id %ControlID%
		ControlGet, CtrlExStyle, ExStyle,,, ahk_id %ControlID%
		ControlGetFocus, CtrlFocus, ahk_id %WinID%
		WinGetClass, CtrlClass, ahk_id %ControlID%
		If ControlNN !=
		{
			rmCtrlX := MXS - WinX - CtrlX, rmCtrlY := MYS - WinY - CtrlY
			ControlNN_Sub := RegExReplace(ControlNN, "S)\d+| ")
			If IsFunc("GetInfo_" ControlNN_Sub)
			{
				CtrlInfo := GetInfo_%ControlNN_Sub%(ControlID, ClassNN)
				If CtrlInfo !=
					CtrlInfo = `n%D1% <a></a><span id='title'>( Info - %ClassNN% )</span> %D2%%CtrlInfo%
			}
		}
		WinGetClass, WinClass, ahk_id %WinID%
		WinGet, ProcessName, ProcessName, ahk_id %WinID%
		If (!isIE && ThisMode = "Mouse" && (StateLight = 1 || (StateLight = 3 && GetKeyState("Shift", "P"))))
		{
			WinGetPos, X, Y, , , ahk_id %WinID%
			ShowMarker(X+CtrlX, Y+CtrlY, CtrlW, CtrlH)
			StateLightAcc ? ShowAccMarker(AccCoord[1], AccCoord[2], AccCoord[3], AccCoord[4]) : 0
		}
	}
	Else If ShowMarker
		HideMarker()

HTML_Mouse:
	HTML_Mouse =
	( Ltrim
	<body id='body'><pre id='pre' contenteditable='true'>
	%D1% <span id='title'>( Mouse pos )</span> %DB% %pause_button% %D2%
	<span id='param'>Screen:</span>  x%MXS% y%MYS%%DP%<span id='param'>Window:</span>  x%RWinX% y%RWinY%%DP%<span id='param'>Client:</span>  x%MXC% y%MYC%
	<span id='param'>Relative active window:</span>  x%MXWA% y%MYWA%%DP%%ProcessName_A%
	%D1% <span id='title'>( Class & ProcessName & HWND )</span> %D2%
	<span id='param'>ahk_class</span> %WinClass% <span id='param'>ahk_exe</span> %ProcessName% <span id='param'>ahk_id</span> %WinID%
	%D1% <span id='title'>( PixelGetColor )</span> %D2%
	<span id='param'>RGB: </span> %ColorRGB%%DP%%sColorRGB%%DP%<span id='param'>BGR: </span> %ColorBGR%%DP%%sColorBGR%
	%D1% <span id='title'>( Control )</span> %D2%<a></a>
	<span id='param'>Class NN:</span>  %ControlNN%%DP%<span id='param'>Win class:</span>  %CtrlClass%
	<span id='param'>Pos:</span>  x%CtrlX% y%CtrlY%%DP%<span id='param'>Size:</span>  w%CtrlW% h%CtrlH%%DP%<span id='param'>x<span style='font-size: 0.7em'>2</span></span>%CtrlX2% <span id='param'>y<span style='font-size: 0.7em'>2</span></span>%CtrlY2%
	<span id='param'>Pos relative client area:</span>  x%CtrlCAX% y%CtrlCAY%%DP%<span id='param'>x<span style='font-size: 0.7em'>2</span></span>%CtrlCAX2% <span id='param'>y<span style='font-size: 0.7em'>2</span></span>%CtrlCAY2%
	<span id='param'>Mouse relative control:</span>  x%rmCtrlX% y%rmCtrlY%%DP%<span id='param'>Client area:</span>  x%caX% y%caY% w%caW% h%caH%
	<span id='param'>HWND:</span>  %ControlID%%DP%<span id='param'>Style:</span>  %CtrlStyle%%DP%<span id='param'>ExStyle:</span>  %CtrlExStyle%
	<span id='param'>Focus control:</span>  %CtrlFocus%%DP%<span id='param'>Cursor type:</span>  %A_Cursor%%DP%<span id='param'>Caret pos:</span>  x%A_CaretX% y%A_CaretY%%CtrlInfo%%CtrlText%%AccText%
	<a></a>%D2%</pre></body>

	<style>
	pre {font-family: '%FontFamily%'; font-size: '%FontSize%'; position: absolute; top: 5px}
	body {background-color: '#%ColorBg%'; color: '%ColorFont%'}
	#title {color: '%ColorTitle%'}
	#param {color: '%ColorParam%'}
	Button {font-size: 0.9em; border: 1px dashed black}
	</style>
	)
	Return 1
}

Write_Mouse()   {
	oDoc.body.innerHTML := HTML_Mouse
	Return 1
}

	; _________________________________________________ Get Info Control _________________________________________________

GetInfo_SysListView(hwnd, ByRef ClassNN)   {
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

GetInfo_ListBox(hwnd, ByRef ClassNN)   {
	ClassNN = ListBox
	Return GetInfo_ComboBox(hwnd, "")
}
GetInfo_TListBox(hwnd, ByRef ClassNN)   {
	ClassNN = TListBox
	Return GetInfo_ComboBox(hwnd, "")
}
GetInfo_TComboBox(hwnd, ByRef ClassNN)   {
	ClassNN = TComboBox
	Return GetInfo_ComboBox(hwnd, "")
}
GetInfo_ComboBox(hwnd, ByRef ClassNN)   {
	ClassNN = ComboBox
	ControlGet, ListText, List,,, ahk_id %hwnd%
	RegExReplace(ListText, "m`a)$", "", RowCount)
	Return	"`n<span id='param'>Row count:</span> " RowCount
			. "`n" D1 " <a></a><span id='param'>( Content )</span> " DB " "
			. copy_button " " D2 "`n<span>" TransformHTML(ListText) "</span>"
}

GetInfo_CtrlNotifySink(hwnd, ByRef ClassNN)   {
	ClassNN = CtrlNotifySink
	Return GetInfo_Scintilla(hwnd, "")
}
GetInfo_Edit(hwnd, ByRef ClassNN)   {
	ClassNN = Edit
	Return GetInfo_Scintilla(hwnd, "")
}
GetInfo_Scintilla(hwnd, ByRef ClassNN)   {
	ClassNN = Scintilla
	ControlGet, LineCount, LineCount,,, ahk_id %hwnd%
	ControlGet, CurrentCol, CurrentCol,,, ahk_id %hwnd%
	ControlGet, CurrentLine, CurrentLine,,, ahk_id %hwnd%
	ControlGet, Selected, Selected,,, ahk_id %hwnd%
	SendMessage, 0x00B0,,,, ahk_id %hwnd%			;  EM_GETSEL
	EM_GETSEL := ErrorLevel >> 16
	SendMessage, 0x00CE,,,, ahk_id %hwnd%			;  EM_GETFIRSTVISIBLELINE
	EM_GETFIRSTVISIBLELINE := ErrorLevel + 1
	Return	"`n<span id='param'>Row count:</span> " LineCount DP
			. "<span id='param'>Selected length:</span> " StrLen(Selected)
			. "`n<span id='param'>Current row:</span> " CurrentLine DP
			. "<span id='param'>Current column:</span> " CurrentCol
			. "`n<span id='param'>Current select:</span> " EM_GETSEL DP
			. "<span id='param'>First visible line:</span> " EM_GETFIRSTVISIBLELINE
}

GetInfo_msctls_progress(hwnd, ByRef ClassNN)   {
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

GetInfo_msctls_trackbar(hwnd, ByRef ClassNN)   {
	ClassNN := "msctls_trackbar32"
	SendMessage, 0x0400+1,,,, ahk_id %hwnd%			;  TBM_GETRANGEMIN
	TBM_GETRANGEMIN := ErrorLevel
	SendMessage, 0x0400+2,,,, ahk_id %hwnd%			;  TBM_GETRANGEMAX
	TBM_GETRANGEMAX := ErrorLevel
	SendMessage, 0x0400,,,, ahk_id %hwnd%			;  TBM_GETPOS
	(!(CtrlStyle & 0x0200)) ? (TBM_GETPOS := ErrorLevel, TBS_REVERSED := "No")
	: (TBM_GETPOS := TBM_GETRANGEMAX - (ErrorLevel - TBM_GETRANGEMIN), TBS_REVERSED := "Yes")
	Return	"`n<span id='param'>Level:</span> " TBM_GETPOS DP
			. "<span id='param'>Invert style:</span> " TBS_REVERSED
			. "`n<span id='param'>Range:   Min:</span> " TBM_GETRANGEMIN DP
			. "<span id='param'>Max:</span> " TBM_GETRANGEMAX
}

GetInfo_msctls_updown(hwnd, ByRef ClassNN)   {
	ClassNN := "msctls_updown32"
	SendMessage, 0x0400+102,,,, ahk_id %hwnd%		;  UDM_GETRANGE
	UDM_GETRANGE := ErrorLevel
	SendMessage, 0x400+114,,,, ahk_id %hwnd%		;  UDM_GETPOS32
	UDM_GETPOS32 := ErrorLevel
	Return	"`n<span id='param'>Level:</span> " UDM_GETPOS32 DP
			. "<span id='param'>Range:  min: </span>" UDM_GETRANGE >> 16
			. "  <span id='param'>max: </span>" UDM_GETRANGE & 0xFFFF
}

GetInfo_SysTabControl(hwnd, ByRef ClassNN)   {
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

	; _________________________________________________ Get Internet Explorer Info _________________________________________________

	;  http://www.autohotkey.com/board/topic/84258-iwb2-learner-iwebbrowser2/

GetInfo_AtlAxWin(hwnd, ByRef ClassNN)   {
	ClassNN = AtlAxWin
	Return GetInfo_InternetExplorer_Server(hwnd, "")
}
GetInfo_InternetExplorer_Server(hwnd, ByRef ClassNN)   {
	Static IID_IWebBrowserApp := "{0002DF05-0000-0000-C000-000000000046}"
	isIE := 1, ClassNN := "Internet Explorer_Server", hwnd := HWND_3
	If !(pwin := WBGet(hwnd))
		Return
	pelt := pwin.document.elementFromPoint(rmCtrlX, rmCtrlY)
	If ((elHTML := pelt.outerHTML) != "")  {
		elHTML := TransformHTML(elHTML)
		code = `n%D1% <a></a><span id='param'>( Outer HTML )</span> %DB% %copy_button% %D2%`n
		elHTML = %code%<span>%elHTML%</span>
	}
	If ((elText := pelt.outerText) != "")  {
		elText := TransformHTML(elText)
		code = `n%D1% <a></a><span id='param'>( Outer Text )</span> %DB% %copy_button% %D2%`n
		elText = %code%<span>%elText%</span>
	}
	WB2 := ComObject(9,ComObjQuery(pwin,IID_IWebBrowserApp,IID_IWebBrowserApp),1)
	If ((Location := WB2.LocationName) != "")
		Location = `n<span id='param'>Title:  </span>%Location%
	If ((URL := WB2.LocationURL) != "")
		URL = `n<span id='param'>URL:  </span>%URL%
	If ((TagName := pelt.TagName) != "")
		TagName = `n%D1% <span id='param'>( Tag name: </span>%TagName%<span id='param'> )</span> %D2%
	If ((id := pelt.id) != "")
		id = `n<span id='param'>ID:  </span>%id%
	If ((Class := pelt.ClassName) != "")
		Class = `n<span id='param'>Class:  </span>%Class%
	If ((name := pelt.name) != "")
		name = `n<span id='param'>Name:  </span>%name%
	If ((Index := pelt.sourceIndex) != "")
		Index = `n<span id='param'>Index:  </span>%Index%
	If (ThisMode = "Mouse") && (StateLight = 1 || (StateLight = 3 && GetKeyState("Shift", "P")))
	{
		pbrt := pelt.getBoundingClientRect(), x1 := pbrt.left, y1 := pbrt.top
		WinGetPos, sX, sY, , , ahk_id %hwnd%
		ShowMarker(sX+x1, sY+y1, pbrt.right-x1, pbrt.bottom-y1)
		StateLightAcc ? ShowAccMarker(AccCoord[1], AccCoord[2], AccCoord[3], AccCoord[4]) : 0
		ObjRelease(pbrt)
	}
	ObjRelease(pwin), ObjRelease(pelt), ObjRelease(WB2)
	Return Location URL TagName id Class name Index elHTML elText
}

WBGet(hwnd)   {
	static msg := DllCall("RegisterWindowMessage", "str", "WM_HTML_GETOBJECT")
		, IID_IHTMLWindow2 := "{332C4427-26CB-11D0-B483-00C04FD90119}"
	SendMessage, msg,,,, ahk_id %hwnd%
	DllCall("oleacc\ObjectFromLresult", "Ptr", ErrorLevel, "Ptr", 0, "Ptr", 0, PtrP, pdoc)
	Return ComObj(9,ComObjQuery(pdoc,IID_IHTMLWindow2,IID_IHTMLWindow2),1), ObjRelease(pdoc)
}

	; _________________________________________________ Get Acc Info _________________________________________________

	;  http://www.autohotkey.com/board/topic/77888-accessible-info-viewer-alpha-release-2012-09-20/

AccInfoUnderMouse(x, y)   {
	Static h
	If Not h
		h := DllCall("LoadLibrary","Str","oleacc","Ptr")
	If DllCall("oleacc\AccessibleObjectFromPoint"
		, "Int64", x&0xFFFFFFFF|y<<32, "Ptr*", pacc
		, "Ptr", VarSetCapacity(varChild,8+2*A_PtrSize,0)*0+&varChild) = 0
	Acc:=ComObjEnwrap(9,pacc,1), child:=NumGet(varChild,8,"UInt")
	If !IsObject(Acc)
		Return
	Type := child ? "Child" DP "<span id='param'>Id:  </span>" child
		: "Parent" DP "<span id='param'>ChildCount:  </span>" ((C:=Acc.accChildCount)!=""?C:"N/A")
	code = `n<span id='param'>Type:</span>  %Type%
	code .= DP "<span id='param'>Pos:  </span>" GetAccLocation(Acc, child)

	If ((Role := AccRole(Acc, child)) != "")  {
		code = %code%`n%D1% <a></a><span id='param'>( Role )</span> %DB% %copy_button% %D2%`n
		code .= "<span>" TransformHTML(Role) "</span>"
	}
	If (child &&(ObjRole := AccRole(Acc)) != "")  {
		code = %code%`n%D1% <a></a><span id='param'>( Role - parent )</span> %DB% %copy_button% %D2%`n
		code .= "<span>" TransformHTML(ObjRole) "</span>"
	}
	If ((Value := Acc.accValue(child)) != "")  {
		code = %code%`n%D1% <a></a><span id='param'>( Value )</span> %DB% %copy_button% %D2%`n
		code .= "<span>" TransformHTML(Value) "</span>"
	}
	If ((Name := Acc.accName(child)) != "")  {
		code = %code%`n%D1% <a></a><span id='param'>( Name )</span> %DB% %copy_button% %D2%`n
		code .= "<span>" TransformHTML(Name) "</span>"
	}
	If ((State := AccGetStateText(Acc.accState(child))) != "")  {
		code = %code%`n%D1% <a></a><span id='param'>( State )</span> %DB% %copy_button% %D2%`n
		code .= "<span>" TransformHTML(State) "</span>"
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
AccRole(Acc, ChildId=0)   {
	Return ComObjType(Acc,"Name")="IAccessible"?AccGetRoleText(Acc.accRole(ChildId)):""
}
AccGetRoleText(nRole)   {
	nSize := DllCall("oleacc\GetRoleText", "UInt", nRole, "Ptr", 0, "UInt", 0)
	VarSetCapacity(sRole, (A_IsUnicode?2:1)*nSize)
	DllCall("oleacc\GetRoleText", "UInt", nRole, "str", sRole, "UInt", nSize+1)
	Return sRole
}
AccGetStateText(nState)   {
	nSize := DllCall("oleacc\GetStateText", "UInt", nState, "Ptr", 0, "UInt", 0)
	VarSetCapacity(sState, (A_IsUnicode?2:1)*nSize)
	DllCall("oleacc\GetStateText", "UInt", nState, "str", sState, "UInt", nSize+1)
	Return sState
}
GetAccLocation(Acc, Child=0) {
	Acc.accLocation(ComObj(0x4003,&x:=0), ComObj(0x4003,&y:=0), ComObj(0x4003,&w:=0), ComObj(0x4003,&h:=0), Child)
	Return "x" (AccCoord[1]:=NumGet(x,0,"int")) " y" (AccCoord[2]:=NumGet(y,0,"int"))
			. " w" (AccCoord[3]:=NumGet(w,0,"int")) " h" (AccCoord[4]:=NumGet(h,0,"int"))
}

	; _________________________________________________ Mode_Hotkey _________________________________________________

Mode_Hotkey:
	Try SetTimer, Loop_%ThisMode%, Off
	ScrollPos[ThisMode,1] := oDoc.body.scrollLeft, ScrollPos[ThisMode,2] := oDoc.body.scrollTop
	If ThisMode != Hotkey
		HTML_%ThisMode% := oDoc.body.innerHTML
	ThisMode := "Hotkey", Hotkey_Hook := (!isPaused ? 1 : Hotkey_Reset()), TitleText := "AhkSpy - Button" TitleTextP2
	oDoc.body.scrollLeft := ScrollPos[ThisMode,1], oDoc.body.scrollTop := ScrollPos[ThisMode,2]
	ShowMarker ? HideMarker() : ""
	(HTML_Hotkey != "") ? Write_HotkeyHTML() : Write_Hotkey({"Mods":"Wait press button..."}*)
	SendMessage, 0xC, 0, &TitleText, , ahk_id %hGui%
	GuiControl, TB: -0x0001, But3
	WinActivate ahk_id %hGui%
	GuiControl, 1:Focus, oDoc
	Return

Write_Hotkey(K*)   {
	Static PrHK1, PrHK2

	Mods := K.Mods, KeyName := K.Name
	Prefix := K.Pref, Hotkey := K.HK
	LRMods := K.LRMods, LRPref := TransformHTML(K.LRPref)
	ThisKey := K.TK, VKCode := K.VK, SCCode := K.SC

	IsVk := Hotkey ~= "^vk" ? 1 : 0
	HK1 := IsVk ? Hotkey : ThisKey
	HK2 := HK1 = PrHK1 ? PrHK2 : PrHK1, PrHK1 := HK1, PrHK2 := HK2
	HKComment := "    `;  """ GetKeyName(HK2) " & " GetKeyName(HK1) """"
	Comment := IsVk ? "    `;  """ KeyName """" : ""
	(Hotkey != "") ? (LRComment := "::<span id='param'>    `;  """ LRMods KeyName """</span>"
		, FComment := "::<span id='param'>    `;  """ Mods KeyName """</span>") : 0
	(LRMods != "") ? (LRMStr := LRMods KeyName, LRPStr := LRPref Hotkey LRComment) : 0
	inp_hk := o_edithotkey.value, inp_kn := o_editkeyname.value

	HTML_Hotkey =
	( Ltrim
	<body id='body'> <pre id='pre'; contenteditable='true'>
	%D1% <span id='title'>( Pressed buttons )</span> %DB% %pause_button% %D2%

	%Mods%%KeyName%

	%LRMStr%

	%D1% <span id='title'>( Command syntax )</span> %D2%

	%Prefix%%Hotkey%%FComment%

	%LRPStr%

	%HK2% & %HK1%::<span id='param'>%HKComment%</span>

	Send, %Prefix%{%Hotkey%}<span id='param'>%Comment%</span>  %DP%  SendInput, %Prefix%{%Hotkey%}<span id='param'>%Comment%</span>

	ControlSend, ahk_parent, %Prefix%{%Hotkey%}, WinTitle<span id='param'>%Comment%</span>

	%D1% <span id='title'>( Last pressed )</span> %DB% <span contenteditable='false' unselectable='on'><button id='numlock'> numlock </button></span> %D2%

	%ThisKey%   %DP%   %VKCode%%SCCode%   %DP%   %VKCode%   %DP%   %SCCode%

	%D1% <span id='title'>( GetKeyName )</span> %D2%

	<span contenteditable='false' unselectable='on'><input id='edithotkey' value='%inp_hk%'><button id='keyname'> &#8250 &#8250 &#8250 </button><input id='editkeyname' value='%inp_kn%'></input></span>

	%D1% <span id='title'>( Not detect buttons )</span> %D2%

	<span id='param'>LButton - vk1   %DP%   RButton - vk2</span>

	%D2%</pre></body>

	<style>
	pre {font-family: '%FontFamily%'; font-size: '%FontSize%'; position: absolute; top: 5px}
	body {background-color: '#%ColorBg%'; color: '%ColorFont%'}
	#title {color: '%ColorTitle%'}
	#param {color: '%ColorParam%'}
	#edithotkey {font-size: '1.18em'; text-align: center; border: 1px dashed black}
	#keyname {font-size: '1.18em';   background-color: '%ColorParam%'; width: 65px; height: 90`%}
	#pause_button, #numlock {font-size: 0.9em; border: 1px dashed black}
	#editkeyname {font-size: '1.18em'; text-align: center; border: 1px dashed black}
	</style>
	)
	Write_HotkeyHTML()
}

Write_HotkeyHTML() {
	oDoc.body.innerHTML := HTML_Hotkey
	ComObjConnect(o_edithotkey:=oDoc.getElementById("edithotkey"),Events)
	ComObjConnect(o_editkeyname:=oDoc.getElementById("editkeyname"),Events)
}

	; _________________________________________________ Hotkey Rules _________________________________________________

HotkeyRules:
	Hotkey_Control(1)
	Global Hotkey_TargetFunc := "Write_Hotkey", Hotkey_Hook := (ThisMode = "Hotkey" ? 1 : Hotkey_Reset())
	Return

	; _________________________________________________ Hotkey Func _________________________________________________

Hotkey_Control(State)  {
	Static IsStart
	If (!IsStart)
		Hotkey_ExtKeyInit(), IsStart := 1
	Hotkey_WindowsHookEx(State)
}

Hotkey_Main(VKCode, SCCode, StateMod = 0, IsMod = 0, OnlyMods = 0)  {
	Static K:={}, ModsOnly, Prefix := {"Alt":"!","Ctrl":"^","Shift":"+","Win":"#"}
		, LRPrefix := {"LAlt":"<!","LCtrl":"<^","LShift":"<+","LWin":"<#"
				,"RAlt":">!","RCtrl":">^","RShift":">+","RWin":">#"}
		, VkMouse := {"MButton":"vk4","WheelDown":"vk9E","WheelUp":"vk9F","WheelRight":"vk9D"
				,"WheelLeft":"vk9C","XButton1":"vk5","XButton2":"vk6"}
		, Symbols := "|vkBA|vkBB|vkBC|vkBD|vkBE|vkBF|vkC0|vkDB|vkDC|vkDD|vkDE|vk41|vk42|"
				. "vk43|vk44|vk45|vk46|vk47|vk48|vk49|vk4A|vk4B|vk4C|vk4D|vk4E|"
				. "vk4F|vk50|vk51|vk52|vk53|vk54|vk55|vk56|vk57|vk58|vk59|vk5A|"

	If (OnlyMods)
	{
		If !ModsOnly
			Return 0
		ModsOnly := 0, K.MCtrl := K.MAlt := K.MShift := K.MWin := K.Mods := ""
		K.PCtrl := K.PAlt := K.PShift := K.PWin := K.Pref := ""
		K.PLCtrl := K.PLAlt := K.PLShift := K.PLWin := K.LRPref := ""
		K.PRCtrl := K.PRAlt := K.PRShift := K.PRWin := ""
		K.MLCtrl := K.MLAlt := K.MLShift := K.MLWin := K.LRMods := ""
		K.MRCtrl := K.MRAlt := K.MRShift := K.MRWin := ""
		%Hotkey_TargetFunc%(K*)
		Return 0
	}
	If (StateMod = "Down")
	{
		If (K["M" IsMod] != "")
			Return 1
		sIsMod := SubStr(IsMod, 2)
		K["M" sIsMod] := sIsMod "+", K["P" sIsMod] := Prefix[sIsMod]
		K["M" IsMod] := IsMod "+", K["P" IsMod] := LRPrefix[IsMod]
	}
	Else If (StateMod = "Up")
	{
		sIsMod := SubStr(IsMod, 2)
		K["M" IsMod] := K["P" IsMod] := ""
		If (K["ML" sIsMod] = "" && K["MR" sIsMod] = "")
			K["M" sIsMod] := K["P" sIsMod] := ""
		If (K.HK != "")
			return 1
	}
	K.VK := VKCode, K.SC := SCCode
	K.Mods := K.MCtrl K.MAlt K.MShift K.MWin
	K.LRMods := K.MLCtrl K.MRCtrl K.MLAlt K.MRAlt K.MLShift K.MRShift K.MLWin K.MRWin
	K.TK := GetKeyName(VKCode SCCode), K.TK := K.TK = "" ? VKCode SCCode : K.TK
	(IsMod) ? (K.HK := K.Pref := K.LRPref := K.Name := "", ModsOnly := K.Mods = "" ? 0 : 1)
	: (K.HK := InStr(Symbols, "|" VKCode "|") ? VKCode : K.TK
	, K.Name := K.HK = "vkBF" ? "/" : K.TK
	, K.Pref := K.PCtrl K.PAlt K.PShift K.PWin
	, K.LRPref := K.PLCtrl K.PRCtrl K.PLAlt K.PRAlt K.PLShift K.PRShift K.PLWin K.PRWin
	, ModsOnly := 0)
	%Hotkey_TargetFunc%(K*)
	Return 1

Hotkey_PressName:
	K.Mods := K.MCtrl K.MAlt K.MShift K.MWin
	K.LRMods := K.MLCtrl K.MRCtrl K.MLAlt K.MRAlt K.MLShift K.MRShift K.MLWin K.MRWin
	K.Pref := K.PCtrl K.PAlt K.PShift K.PWin
	K.LRPref := K.PLCtrl K.PRCtrl K.PLAlt K.PRAlt K.PLShift K.PRShift K.PLWin K.PRWin
	K.HK := K.Name := K.TK := A_ThisHotkey, ModsOnly := 0, K.SC := ""
	K.VK := !InStr(A_ThisHotkey, "Joy") ? VkMouse[A_ThisHotkey] : ""
	%Hotkey_TargetFunc%(K*)
	Return 1
}

Hotkey_ExtKeyInit()   {
	MouseKey := "MButton|WheelDown|WheelUp|WheelRight|WheelLeft|XButton1|XButton2"
	#If Hotkey_Hook
	#If
	Hotkey, If, Hotkey_Hook
	Loop, Parse, MouseKey, |
		Hotkey, %A_LoopField%, Hotkey_PressName, P3 UseErrorLevel
	Loop 128
		Hotkey % Ceil(A_Index/32) "Joy" Mod(A_Index-1,32)+1, Hotkey_PressName, P3 UseErrorLevel
	Hotkey, If
}

Hotkey_Reset()   {
	Return Hotkey_Hook := 0, Hotkey_Main("", "", "", "", 1)
}

	;  http://forum.script-coding.com/viewtopic.php?id=6350

Hotkey_LowLevelKeyboardProc(nCode, wParam, lParam)   {
	Static Mods := {"vkA4":"LAlt","vkA5":"RAlt","vkA2":"LCtrl","vkA3":"RCtrl"
		,"vkA0":"LShift","vkA1":"RShift","vk5B":"LWin","vk5C":"RWin"}, SaveFormat

	If !Hotkey_Hook
		Return DllCall("CallNextHookEx", "Ptr", 0, "Int", nCode, "UInt", wParam, "UInt", lParam)
	SaveFormat := A_FormatInteger
	SetFormat, IntegerFast, H
	VKCode := "vk" SubStr(NumGet(lParam+0, 0, "UInt"), 3)
	sc := NumGet(lParam+0, 8, "UInt") & 1, sc := sc << 8 | NumGet(lParam+0, 4, "UInt")
	SCCode := "sc" SubStr(sc, 3), IsMod := Mods[VKCode]
	SetFormat, IntegerFast, %SaveFormat%
	If (wParam = 0x100 || wParam = 0x104)   ;  WM_KEYDOWN := 0x100, WM_SYSKEYDOWN := 0x104
		IsMod ? Hotkey_Main(VKCode, SCCode, "Down", IsMod) : Hotkey_Main(VKCode, SCCode)
	Else If ((wParam = 0x101 || wParam = 0x105) && VKCode != "vk5D")   ;  WM_KEYUP := 0x101, WM_SYSKEYUP := 0x105, AppsKey = "vk5D"
		nCode := -1, IsMod ? Hotkey_Main(VKCode, SCCode, "Up", IsMod) : ""
	Return nCode < 0 ? DllCall("CallNextHookEx", "Ptr", 0, "Int", nCode, "UInt", wParam, "UInt", lParam) : 1
}

Hotkey_WindowsHookEx(State)   {
	Static Hook
	If State
		Hook := DllCall("SetWindowsHookEx" . (A_IsUnicode ? "W" : "A")
				, "Int", 13   ;  WH_KEYBOARD_LL
				, "Ptr", RegisterCallback("Hotkey_LowLevelKeyboardProc", "Fast")
				, "Ptr", DllCall("GetModuleHandle", "UInt", 0, "Ptr")
				, "UInt", 0, "Ptr")
	Else
		DllCall("UnhookWindowsHookEx" , "Ptr", Hook), Hook := "", Hotkey_Reset()
}

	; _________________________________________________ Labels _________________________________________________

GuiSize:
	Sleep := A_EventInfo
	If Sleep != 1
	{
		Gui, TB: Show, % "NA y0 x" (A_GuiWidth - widthTB) // 2.2
		WinMove, ahk_id %hActiveX%, , 0, HeigtButton, A_GuiWidth, A_GuiHeight - HeigtButton
	}
	Else
		HideMarker()
	Try SetTimer, Loop_%ThisMode%, % Sleep = 1 || isPaused ? "Off" : "On"
	Return

Exit:
GuiClose:
GuiEscape:
	Hotkey_Control(0), oDoc := ""
	DllCall("DeregisterShellHookWindow", "UInt", A_ScriptHwnd)
	ExitApp

HideMarker:
	HideMarker(0)
	Return

TitleShow:
	SendMessage, 0xC, 0, &TitleText, , ahk_id %hGui%
	Return

RevAhkVersion:
	If A_AhkVersion < 1.1.11.00
	{
		MsgBox Requires AutoHotkey_L version 1.1.12.00+
		LaunchLink("http://ahkscript.org/download/")
		ExitApp
	}
	Return

LaunchHelp:
	IfWinNotExist AutoHotkey Help ahk_class HH Parent ahk_exe hh.exe
		Run % SubStr(A_AhkPath,1,InStr(A_AhkPath,"\",,0,1)) "AutoHotkey.chm"
	WinActivate
	Gui, 1: Minimize
	Return

DefaultSize:
	Gui, 1: Show, % "NA Center w" widthTB "h" HeightStart
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

Sys_Help:
	If A_ThisMenuItem = AutoHotKey official help online
		LaunchLink("http://ahkscript.org/docs/AutoHotkey.htm")
	Else If A_ThisMenuItem = AutoHotKey russian help online
		LaunchLink("http://www.script-coding.com/AutoHotkeyTranslation.html")
	Else If A_ThisMenuItem = About AhkSpy
		LaunchLink("http://forum.script-coding.com/viewtopic.php?pid=72459#p72459")
	Return

	; _________________________________________________ Functions _________________________________________________


ShellProc(nCode, wParam)   {
	If (nCode = 4)
	{
		If (wParam = hGui)
			(ThisMode = "Hotkey" && !isPaused ? Hotkey_Hook := 1 : ""), HideMarker()
		Else If Hotkey_Hook
			Hotkey_Reset()
	}
}

WM_ACTIVATE(wp)   {
	If (wp & 0xFFFF)
		(ThisMode = "Hotkey" && !isPaused ? Hotkey_Hook := 1 : ""), HideMarker()
	Else If (wp & 0xFFFF = 0 && Hotkey_Hook)
		Hotkey_Reset()
}

WM_LBUTTONDOWN()   {
	If (A_GuiControl = "ColorProgress" && ThisMode != "Hotkey")
		SendInput !{Esc}
}

WM_CONTEXTMENU() {
	MouseGetPos, , , wid, cid, 2
	If (cid != hActiveX && wid = hGui)
	{
		SetTimer, ShowSys, -1
		Return 0
	}
}

LaunchLink(Link)   {
	Run %Link%
	Gui, 1: Minimize
}

ShowMarker(x, y, w, h, b:=4)   {
	ShowMarker := 1
	w < 8 || h < 8 ? b := 2 : 0
	Try Gui, M: Show, NA x%x% y%y% w%w% h%h%
	Catch
		Return HideMarker()
	WinSet, Region, % "0-0 " w "-0 " w "-" h " 0-" h " 0-0 " b "-" b
		. " " w-b "-" b " " w-b "-" h-b " " b "-" h-b " " b "-" b, ahk_id %hMarkerGui%
}

HideMarker(test=1)   {
	Gui, M: Show, Hide
	ShowMarker := 0, HideAccMarker()
	If test
		SetTimer, HideMarker, -250
	Return 1
}

ShowAccMarker(x, y, w, h, b:=2)   {
	ShowMarker := 1
	Try Gui, AcM: Show, NA x%x% y%y% w%w% h%h%
	Catch
		Return HideAccMarker()
	WinSet, Region, % "0-0 " w "-0 " w "-" h " 0-" h " 0-0 " b "-" b
		. " " w-b "-" b " " w-b "-" h-b " " b "-" h-b " " b "-" b, ahk_id %hMarkerAccGui%
}
HideAccMarker()   {
	Gui, AcM: Show, Hide
	Return 1
}

IniRead(Key)   {
	IniRead, Value, %A_AppData%\AhkSpy.ini, AhkSpy, %Key%, %A_Space%
	Return Value
}
IniWrite(Value, Key) {
	IniWrite, %Value%, %A_AppData%\AhkSpy.ini, AhkSpy, %Key%
	Return Value
}

InArr(Val, Arr*)   {
	For k, v in Arr
		If (v == Val)
			Return k
}

TransformHTML(str)   {
	Transform, str, HTML, %str%, 3
	StringReplace, str, str,`n,, 1
	Return str
}

ExistSelectedText(byref Copy)   {
	MouseGetPos, , , , ControlID, 2
	If (ControlID != hActiveX)
		Return 0
	Copy := oDoc.selection.createRange().text
	If Copy is space
		Return 0
	Copy := Trim(Copy)
	Copy := RegExReplace(Copy, Chr(0x25aa) Chr(0x25aa) "+", "#!#")
	StringReplace, Copy, Copy, % Chr(0x25aa), #, 1
	StringReplace, Copy, Copy, #!#  copy  #!#, #!#, 1
	StringReplace, Copy, Copy, #!#  pause  #!#, #!#
	Return 1
}

	;  http://forum.script-coding.com/viewtopic.php?pid=53516#p53516

GetCommandLineProc(pid)   {
	ComObjGet("winmgmts:").ExecQuery("Select * from Win32_Process WHERE ProcessId = " pid)._NewEnum.next(X)
	Return X.CommandLine
}

	;  http://www.autohotkey.com/board/topic/69254-func-api-getwindowinfo-ahk-l/#entry438372

GetClientPos(hwnd, ByRef left, ByRef top, ByRef w, ByRef h)   {
	VarSetCapacity(pwi, 60, 0), NumPut(60, pwi, 0, "UInt")
	DllCall("GetWindowInfo", "Ptr", hwnd, "UInt", &pwi)
	top:=NumGet(pwi,24,"int")-NumGet(pwi,8,"int")
	left:=NumGet(pwi,52,"int")
	w:=NumGet(pwi,28,"int")-NumGet(pwi,20,"int")
	h:=NumGet(pwi,32,"int")-NumGet(pwi,24,"int")
}

	;  http://forum.script-coding.com/viewtopic.php?pid=81833#p81833

SelectFilePath(FilePath)   {
	SplitPath, FilePath, , FolderPath
	For Window in ComObjCreate("Shell.Application").Windows
	{
		If (Window.Document.Folder.Self.Path = FolderPath)
		{
			For item in Window.Document.Folder.Items
			{
				If (item.path = FilePath)
				{
					Window.Document.SelectItem(item, 1|4|8|16)
					WinActivate, % "ahk_id" Window.hwnd
					Return
				}
			}
		}
	}
	Run, explorer /select`, "%FilePath%"
}

NextLink(s = "")   {
	curpos := oDoc.body.scrollTop, oDoc.body.scrollLeft := 0
	If (!curpos && s = "-")
		Return
	While (pos := oDoc.getElementsByTagName("a").item(A_Index-1).getBoundingClientRect().top) != ""
		(s 1) * pos > 0 && (!res || abs(res) > abs(pos)) ? res := pos : ""
	If (res = "" && s = "")
		Return
	st := !res ? -curpos : res, co := abs(st) > 150 ? 80 : 30
	Loop % co
		oDoc.body.scrollTop := curpos + (st*(A_Index/co))
	oDoc.body.scrollTop := curpos + res
}

Update(in=1)   {
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
				Return (Ver := RegExReplace(Text, "i).*?version\s*(.*?)\R.*", "$1")) > AhkSpyVersion ? Update(2) : 0
			If (!InStr(Text, "AhkSpyVersion"))
				Return
			If InStr(FileExist(A_ScriptFullPath), "R")
			{
				MsgBox, % 16+262144, AhkSpy, Exist new version %Ver%!`n`nBut the file has an attribute "READONLY".`nUpdate imposible.
				Return
			}
			MsgBox, % 4+32+262144, AhkSpy, Exist new version!`nUpdate v%AhkSpyVersion% to v%Ver%?
			IfMsgBox, No
				Return
			File := FileOpen(A_ScriptFullPath, "w", "UTF-8")
			File.Length := 0, File.Write(Text), File.Close()
			Reload
		}
		Error := (++att = 20 || Status != "")
		SetTimer,  % Error ? "UpdateAhkSpy" : "Upd_Verifi", % Error ? -60000 : -3000
		Return
}

	;  http://forum.script-coding.com/viewtopic.php?pid=82283#p82283

Class Events  {
	onclick()   {
		oevent := oDoc.parentWindow.event.srcElement
		If (oevent.TagName = "BUTTON")
		{
			thisid := oevent.id
			If thisid = copy_button
			{
				o := oDoc.all.item(oevent.sourceIndex+2)
				Clipboard := o.OuterText
				oDoc.selection.createRange().execCommand("Unselect")
				o.style.backgroundColor := "A3C5E9"
				Sleep 400
				o.style.backgroundColor := ColorBg
			}
			Else If thisid = keyname
			{
				KeyName := GetKeyName(o_edithotkey.value), o_editkeyname.value := KeyName
				o := KeyName = "" ? o_edithotkey : o_editkeyname
				o.focus(), o2 := o.createTextRange(), o2.collapse(false), o2.select()
				Return
			}
			Else If thisid = pause_button
				Gosub, PausedScript
			Else If (thisid = "folder" && FileExist(WinProcessPath))
				SelectFilePath(WinProcessPath)
			Else If thisid = numlock
			{
				(OnHook := Hotkey_Hook) ? (Hotkey_Hook := 0) : 0
				SendInput, {Numlock}
				(OnHook ? Hotkey_Hook := 1 : 0)
			}
			oDoc.body.focus()
		}
	}
	ondblclick()   {
		thisid := oDoc.parentWindow.event.srcElement.id
		If thisid = winclose
		{
			WinGet, WinPID, PID, ahk_id %WinCloseID%
			WinKill, ahk_id %WinCloseID%,, 0.5
			IfWinExist, ahk_id %WinCloseID%
				Process, Close, %WinPID%
		}
		Else If thisid = numlock
		{
			(OnHook := Hotkey_Hook) ? (Hotkey_Hook := 0) : 0
			SendInput, {Numlock}
			(OnHook ? Hotkey_Hook := 1 : 0)
		}
		Else If thisid = pause_button
			Gosub, PausedScript
		If (oDoc.parentWindow.event.srcElement.TagName = "BUTTON")
			oDoc.body.focus()
	}
	onfocus()   {
		Sleep 100
		Hotkey_Reset()
	}
	onblur()   {
		Sleep 100
		If WinActive("ahk_id" hGui)
			(!isPaused ? (Hotkey_Hook := 1) : 0)
	}
}
	;)
