	;  AhkSpy
	;  Автор - serzh82saratov
	;  Спасибо wisgest за помощь в создании HTML интерфейса этой версии скрипта
	;  Тема - http://forum.script-coding.com/viewtopic.php?pid=72244#p72244
	;  Коллекция - http://forum.script-coding.com/viewtopic.php?pid=72459#p72459

AhkSpyVersion = 1.111
#NoTrayIcon
#SingleInstance Force
#NoEnv
DetectHiddenWindows, On
SetBatchLines -1
ListLines Off
Gosub RevAhkVersion
Menu, Tray, Icon, Shell32.dll, % A_OSVersion = "WIN_7" ? 278 : 222

# := "&#9642"									;  Символ разделителя заголовков
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
, StateLight:=((t:=IniRead("StateLight"))=""||t>3?3:t), StateLightAcc:=IniRead("StateLightAcc")
, hGui, hActiveX, hMarkerGui, hMarkerAccGui, oDoc, ShowMarker, isIE, isPaused, ScrollPos:={}, AccCoord:=[]
, HWND_3, WinCloseID, WinProcessPath, CtrlStyle, HTML_Win, HTML_Mouse, HTML_Hotkey, o_edithotkey, o_editkeyname, rmCtrlX, rmCtrlY
, copy_button := "<span contenteditable='false' unselectable='on'><button id='copy_button'> copy </button></span>"
, pause_button := "<span contenteditable='false' unselectable='on'><button id='pause_button'> pause </button></span>"
TitleTextP2 := "     ( Shift+Tab - Freeze | RButton - CopySelected | Shift - Backlight object | Break - Pause )     v" AhkSpyVersion

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
Gui, Font, % "s" A_ScreenDPI = 120 ? 7 : 9, Verdana
Gui, Color, %ColorBgPaused%
Gui, Add, ActiveX, Border voDoc HWNDhActiveX x0 y+0, HTMLFile

Gui, TB: +HWNDhTBGui -Caption -DPIScale +Parent%hGui% +E0x08000000
Gui, TB: Font, % "s" A_ScreenDPI = 120 ? 7 : 9, Verdana
Gui, TB: Add, Button, x0 y0 h%HeigtButton% w%wKey% vBut1 gMode_Win, Window
Gui, TB: Add, Button, x+0 yp hp wp vBut2 gMode_Mouse, Mouse && Control
Gui, TB: Add, Progress, x+0 yp hp w%wColor% vColorProgress cWhite, 100
Gui, TB: Add, Button, x+0 yp hp w%wKey% vBut3 gMode_Hotkey, Button
Gui, TB: Show, % "x0 y0 NA h" HeigtButton " w" widthTB := wKey*3+wColor

OnExit, Exit
OnMessage(0x201, "WM_LBUTTONDOWN")
ComObjConnect(oDoc, eventshtml)
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
Menu, Sys, Check, % ["Backlight allways","Backlight disable","Backlight hold shift button"][StateLight]
Menu, Sys, Add
Menu, Sys, Add, Acc object backlight, Sys_Acclight
Menu, Sys, % StateLightAcc ? "Check" : "UnCheck", Acc object backlight
Menu, Sys, Add
Menu, Sys, Add, Pause AhkSpy, PausedScript
Menu, Sys, Add, Default size, DefaultSize
Menu, Sys, Add, Reload AhkSpy, Reload
Menu, Sys, Add
Menu, Help, Add, About AhkSpy, Sys_Help
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
	If ThisMode = Hotkey
		Hotkey_Hook := isPaused ? 0 : 1
	Menu, Sys, % isPaused ? "Check" : "UnCheck", Pause AhkSpy
	HideMarker()
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

!Space:: SetTimer ShowSys, -1

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
		Hotkey_Hook := 0, Hotkey_IsOnlyMods()
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
		SBText = `n%D1% <a></a><span id="title">( StatusBarText )</span> %D2%`n%SBText%
	WinGetText, WinText, ahk_id %WinID%
	If WinText !=
	{
		WinText := TransformHTML( WinClass = "Notepad++" ? SubStr(WinText, 1, 5000) : WinText)
		WinText = `n%D1% <a></a><span id="title">( Visible Window Text )</span> %DB% %copy_button% %D2%`n<span>%WinText%</span>
	}
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
		Hotkey_Hook := 0, Hotkey_IsOnlyMods()
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
	GetClientPos(WinID, caX, caY, "", "")
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
		IsGetUTF8 := InStr(ControlNN, "Scintilla")
		ControlGetText, CtrlText, , ahk_id %ControlID%
		If CtrlText !=
		{
			CtrlText := TransformHTML(IsGetUTF8 ? StrGet(&CtrlText, "utf-8") : CtrlText)
			CtrlText = `n%D1% <a></a><span id="title">( Control text )</span> %DB% %copy_button% %D2%`n<span>%CtrlText%</span>
		}
		AccText := AccInfoUnderMouse(MXS, MYS)
		If AccText !=
			AccText = `n%D1% <a></a><span id="title">( AccInfo )</span> %D2%%AccText%
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
					CtrlInfo = `n%D1% <a></a><span id="title">( Info - %ClassNN% )</span> %D2%%CtrlInfo%
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
	<span id='param'>Pos:</span>  x%CtrlX% y%CtrlY%%DP%<span id='param'>Size:</span>  w%CtrlW% h%CtrlH%%DP%%CtrlX%, %CtrlY%, %CtrlW%, %CtrlH%
	<span id='param'>Pos relative client area:</span>  x%CtrlCAX% y%CtrlCAY%%DP%<span id='param'>Client area pos:</span>  x%caX% y%caY%
	<span id='param'>Mouse relative control:</span>  x%rmCtrlX% y%rmCtrlY%
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
	Return	"`n<span id='param'>Row count:</span> " RowCount DP
			. "<span id='param'>Column count:</span> " ColCount
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
	Try pelt := pwin.document.elementFromPoint(rmCtrlX, rmCtrlY)
	Catch
		Return ObjRelease(pwin)
	Try If ((elHTML := pelt.outerHTML) != "")  {
		elHTML := TransformHTML(elHTML)
		code = `n%D1% <a></a><span id='param'>( Outer HTML )</span> %DB% %copy_button% %D2%`n
		elHTML = %code%<span>%elHTML%</span>
	}
	Try If ((elText := pelt.outerText) != "")  {
		elText := TransformHTML(elText)
		code = `n%D1% <a></a><span id='param'>( Outer Text )</span> %DB% %copy_button% %D2%`n
		elText = %code%<span>%elText%</span>
	}
	Try WB2 := ComObject(9,ComObjQuery(pwin,IID_IWebBrowserApp,IID_IWebBrowserApp),1)
	Try If ((Location := WB2.LocationName) != "")
		Location = `n<span id='param'>Title:  </span>%Location%
	Try If ((URL := WB2.LocationURL) != "")
		URL = `n<span id='param'>URL:  </span>%URL%
	Try If ((TagName := pelt.TagName) != "")
		TagName = `n%D1% <span id='param'>( Tag name: </span>%TagName%<span id='param'> )</span> %D2%
	Try If ((id := pelt.id) != "")
		id = `n<span id='param'>ID:  </span>%id%
	Try If ((Class := pelt.ClassName) != "")
		Class = `n<span id='param'>Class:  </span>%Class%
	Try If ((name := pelt.name) != "")
		name = `n<span id='param'>Name:  </span>%name%
	Try If ((Index := pelt.sourceIndex) != "")
		Index = `n<span id='param'>Index:  </span>%Index%
	If (ThisMode = "Mouse") && (StateLight = 1 || (StateLight = 3 && GetKeyState("Shift", "P")))
	{
		Try pbrt := pelt.getBoundingClientRect(), x1 := pbrt.left, y1 := pbrt.top
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
		, IID := "{332C4427-26CB-11D0-B483-00C04FD90119}"		;  IID_IHTMLWindow2
	SendMessage, msg,,,, ahk_id %hwnd%
	DllCall("oleacc\ObjectFromLresult", "Ptr", ErrorLevel, "Ptr", 0, "Ptr", 0, PtrP, pdoc)
	Try Return ComObj(9,ComObjQuery(pdoc,IID,IID),1), ObjRelease(pdoc)
}
	; _________________________________________________ Mode_Hotkey _________________________________________________

Mode_Hotkey:
	Try SetTimer, Loop_%ThisMode%, Off
	ScrollPos[ThisMode,1] := oDoc.body.scrollLeft, ScrollPos[ThisMode,2] := oDoc.body.scrollTop
	If ThisMode != Hotkey
		HTML_%ThisMode% := oDoc.body.innerHTML
	ThisMode := "Hotkey", Hotkey_Hook := (!isPaused ? 1 : 0), TitleText := "AhkSpy - Button" TitleTextP2
	oDoc.body.scrollLeft := ScrollPos[ThisMode,1], oDoc.body.scrollTop := ScrollPos[ThisMode,2]
	ShowMarker ? HideMarker() : ""
	(HTML_Hotkey != "") ? Write_HotkeyHTML() : Write_Hotkey("Wait press button...", "", "", "", "", "", "")
	SendMessage, 0xC, 0, &TitleText, , ahk_id %hGui%
	GuiControl, TB: -0x0001, But3
	WinActivate ahk_id %hGui%
	GuiControl, 1:Focus, oDoc
	Return

Write_Hotkey(Mods, KeyName, Prefix, Hotkey, VkCode, SCCode, ThisKey)   {
	Static PrHK1, PrHK2
	IsVk := Hotkey ~= "^vk" ? 1 : 0
	HK1 := IsVk ? Hotkey : ThisKey
	HK2 := HK1 = PrHK1 ? PrHK2 : PrHK1, PrHK1 := HK1, PrHK2 := HK2
	HKComment := "    `;  """ GetKeyName(HK2) " & " GetKeyName(HK1) """"
	Comment := IsVk ? "    `;  """ KeyName """" : ""
	inp_hk := o_edithotkey.value, inp_kn := o_editkeyname.value

	HTML_Hotkey =
	( Ltrim
	<body id='body'> <pre id='pre'; contenteditable='true'>
	%D1% <span id='title'>( Pressed buttons )</span> %DB% %pause_button% %D2%

	%Mods%%KeyName%

	%D1% <span id='title'>( Command syntax )</span> %D2%

	%Prefix%%Hotkey%::<span id='param'>%Comment%</span>

	%Prefix%{%Hotkey%}  %DP%  %Prefix%%Hotkey%<span id='param'>%Comment%</span>

	%HK2% & %HK1%::<span id='param'>%HKComment%</span>

	Send %Prefix%{%Hotkey%}<span id='param'>%Comment%</span>  %DP%  SendInput %Prefix%{%Hotkey%}<span id='param'>%Comment%</span>

	ControlSend, ahk_parent, %Prefix%{%Hotkey%}, WinTitle<span id='param'>%Comment%</span>

	%D1% <span id='title'>( Last pressed )</span> %D2%

	%ThisKey%

	%VkCode%  %DP%  %SCCode%

	%VkCode%%SCCode%

	%D1% <span id='title'>( GetKeyName )</span> %D2%

	<span contenteditable='false' unselectable='on'><input id='edithotkey' value='%inp_hk%'><button id='keyname'> &#8250 &#8250 &#8250 </button><input id='editkeyname' value='%inp_kn%'></input></span>

	%D1% <span id='title'>( Not detect buttons )</span> %D2%

	<span id='param'>LButton - vk1  %DP%  RButton - vk2</span>

	%D2%</pre></body>

	<style>
	pre {font-family: '%FontFamily%'; font-size: '%FontSize%'; position: absolute; top: 5px}
	body {background-color: '#%ColorBg%'; color: '%ColorFont%'}
	#title {color: '%ColorTitle%'}
	#param {color: '%ColorParam%'}
	#edithotkey {font-size: '1.18em'; text-align: center; border: 1px dashed black}
	#keyname {font-size: '1.18em';   background-color: '%ColorParam%'; width: 65px; height: 90`%}
	#pause_button {font-size: 0.9em; border: 1px dashed black}
	#editkeyname {font-size: '1.18em'; text-align: center; border: 1px dashed black}
	</style>
	)
	Write_HotkeyHTML()
}

Write_HotkeyHTML() {
	oDoc.body.innerHTML := HTML_Hotkey
	Try ComObjConnect(o_edithotkey:=oDoc.getElementById("edithotkey"),eventshtml)
	Try ComObjConnect(o_editkeyname:=oDoc.getElementById("editkeyname"),eventshtml)
}

	; _________________________________________________ Hotkey Rules _________________________________________________

HotkeyRules:
	Hotkey_Control(1)
	Global Hotkey_TargetFunc := "Write_Hotkey", Hotkey_Hook := (ThisMode = "Hotkey" ? 1 : 0 )
	Return

	; _________________________________________________ Hotkey Func _________________________________________________

Hotkey_Control(State)  {
	Static IsStart
	If (!IsStart)
		Hotkey_ExtKeyInit(), IsStart := 1
	Hotkey_WindowsHookEx(State)
	Return State
}

Hotkey_Main(VkCode, SCCode, StateMod = 0, IsMod = 0, OnlyMods = 0)  {
	Static Hotkey, ModsOnly, _KeyName, _Hotkey, _VkCode, _SCCode, _ThisKey
		, MCtrl, MAlt, MShift, MWin, PCtrl, PAlt, PShift, PWin
		, VkMouse := {"MButton":"vk4","WheelDown":"vk9E","WheelUp":"vk9F","WheelRight":"vk9D"
		,"WheelLeft":"vk9C","XButton1":"vk5","XButton2":"vk6"}
		, Pref := {"Alt":"!","Ctrl":"^","Shift":"+","Win":"#"}
		, Symbols := "|vkBA|vkBB|vkBC|vkBD|vkBE|vkBF|vkC0|vkDB|vkDC|vkDD|vkDE|vk41|vk42|"
			. "vk43|vk44|vk45|vk46|vk47|vk48|vk49|vk4A|vk4B|vk4C|vk4D|vk4E|"
			. "vk4F|vk50|vk51|vk52|vk53|vk54|vk55|vk56|vk57|vk58|vk59|vk5A|"
	If (OnlyMods)
	{
		If !ModsOnly
			Return 0
		MCtrl:=MAlt:=MShift:=MWin:=PCtrl:=PAlt:=PShift:=PWin:="", ModsOnly := 0
		%Hotkey_TargetFunc%("", _KeyName, "", _Hotkey, _VkCode, _SCCode, _ThisKey)
		Return 1
	}
	If (StateMod = "Down")
	{
		If (M%IsMod% != "")
			Return 1
		M%IsMod% := IsMod "+", P%IsMod% := Pref[IsMod]
	}
	Else If (StateMod = "Up")
	{
		M%IsMod% := P%IsMod% := ""
		If (Hotkey != "")
			Return 1
	}
	ThisKey := GetKeyName(VkCode SCCode), ThisKey := ThisKey = "" ? VkCode SCCode : ThisKey
	(IsMod) ? (Hotkey := "", ModsOnly := MCtrl MAlt MShift MWin = "" ? 0 : 1)
	: (Hotkey := InStr(Symbols, "|" VkCode "|") ? VkCode : ThisKey
	, KeyName := Hotkey = "vkBF" ? "/" : ThisKey
	, Prefix := PCtrl PAlt PShift PWin, ModsOnly := 0)
	_KeyName:=KeyName, _Hotkey:=Hotkey, _VkCode:=VkCode, _SCCode:=SCCode, _ThisKey:=ThisKey
	%Hotkey_TargetFunc%(MCtrl MAlt MShift MWin, KeyName, Prefix, Hotkey, VkCode, SCCode, ThisKey)
	Return 1

Hotkey_PressName:
	KeyName := Hotkey := ThisKey := _KeyName := _Hotkey := _ThisKey := A_ThisHotkey
	ModsOnly := 0
	VkCode := _VkCode := !InStr(A_ThisHotkey, "Joy") ? VkMouse[A_ThisHotkey] : ""
	%Hotkey_TargetFunc%(MCtrl MAlt MShift MWin, KeyName, PCtrl PAlt PShift PWin, Hotkey, VkCode, SCCode, ThisKey)
	Return
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

Hotkey_IsOnlyMods()  {
	Return Hotkey_Main("", "", "", "", 1)
}

	;  http://forum.script-coding.com/viewtopic.php?id=6350

Hotkey_LowLevelKeyboardProc(nCode, wParam, lParam)   {
	Static Mods := {"vkA4":"Alt","vkA5":"Alt","vkA2":"Ctrl","vkA3":"Ctrl"
		,"vkA0":"Shift","vkA1":"Shift","vk5B":"Win","vk5C":"Win"}, SaveFormat

	If !Hotkey_Hook
		Return DllCall("CallNextHookEx", "Ptr", 0, "Int", nCode, "UInt", wParam, "UInt", lParam)
	SaveFormat := A_FormatInteger
	SetFormat, IntegerFast, H
	VkCode := "vk" SubStr(NumGet(lParam+0, 0, "UInt"), 3)
	sc := NumGet(lParam+0, 8, "UInt") & 1, sc := sc << 8 | NumGet(lParam+0, 4, "UInt")
	SCCode := "sc" SubStr(sc, 3), IsMod := Mods[VkCode]
	SetFormat, IntegerFast, %SaveFormat%
	If (wParam = 0x100 || wParam = 0x104)		;  WM_KEYDOWN := 0x100, WM_SYSKEYDOWN := 0x104
		IsMod ? Hotkey_Main(VkCode, SCCode, "Down", IsMod) : Hotkey_Main(VkCode, SCCode)
	Else If ((wParam = 0x101 || wParam = 0x105) && VkCode != "vk5D")	;  WM_KEYUP := 0x101, WM_SYSKEYUP := 0x105, AppsKey = "vk5D"
		nCode := -1, IsMod ? Hotkey_Main(VkCode, SCCode, "Up", IsMod) : ""
	Return nCode < 0 ? DllCall("CallNextHookEx", "Ptr", 0, "Int", nCode, "UInt", wParam, "UInt", lParam) : 1
}

Hotkey_WindowsHookEx(State)   {
	Static Hook
	DllCall("UnhookWindowsHookEx" , "Ptr", Hook)
	If State
		Hook := DllCall("SetWindowsHookEx" . (A_IsUnicode ? "W" : "A")
				, "Int", 13	;  WH_KEYBOARD_LL := 13
				, "Ptr", RegisterCallback("Hotkey_LowLevelKeyboardProc", "Fast")
				, "Ptr", DllCall("GetModuleHandle", "UInt", 0, "Ptr")
				, "UInt", 0, "Ptr")
	Else
		Hook := "", Hotkey_Hook := 0
}

	; _________________________________________________ Labels _________________________________________________

GuiSize:
	Sleep := A_EventInfo
	If Sleep != 1
	{
		Gui, TB: Show, % "NA y0 x" (A_GuiWidth - widthTB) // 2.5
		WinMove, ahk_id %hActiveX%, , 0, HeigtButton, A_GuiWidth, A_GuiHeight - HeigtButton
	}
	Else If Sleep = 1
		HideMarker()
	Try SetTimer, Loop_%ThisMode%, % Sleep = 1 || isPaused ? "Off" : "On"
	Return

Exit:
GuiClose:
GuiEscape:
	Hotkey_Control(0), oDoc := ""
	DllCall("DeregisterShellHookWindow", "UInt", A_ScriptHwnd)
	ExitApp

TitleShow:
	SendMessage, 0xC, 0, &TitleText, , ahk_id %hGui%
	Return

RevAhkVersion:
	If A_AhkVersion < 1.1.12.00
	{
		MsgBox Requires AutoHotkey_L version 1.1.12.00+
		LaunchLink("http://ahkscript.org/download/")
		ExitApp
	}
	Return

ShowSys:
	Menu, Sys, Show
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

Sys_Backlight:
	Menu, Sys, Check, % A_ThisMenuItem
	Menu, Sys, UnCheck, % ["Backlight allways","Backlight disable","Backlight hold shift button"][StateLight]
	IniWrite((StateLight:=A_ThisMenuItemPos), "StateLight")
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


WM_LBUTTONDOWN()   {
	If (A_GuiControl = "ColorProgress" && ThisMode != "Hotkey")
		SendInput !{Esc}
}

WM_CONTEXTMENU() {
	MouseGetPos, , , , id, 2
	If (id != hActiveX)   {
		SetTimer ShowSys, -1
		Return 0
	}
}

LaunchLink(Link)   {
	Run %Link%
	Gui, 1: Minimize
}

ShowMarker(x, y, w, h, b:=4)   {
	ShowMarker := 1
	Try Gui, M: Show, NA x%x% y%y% w%w% h%h%
	Catch
		Return HideMarker()
	WinSet, Region, % "0-0 " w "-0 " w "-" h " 0-" h " 0-0 " b "-" b
		. " " w-b "-" b " " w-b "-" h-b " " b "-" h-b " " b "-" b, ahk_id %hMarkerGui%
}
HideMarker()   {
	Gui, M: Show, Hide
	ShowMarker := 0, HideAccMarker()
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

TransformHTML(str)   {
	Transform, str, HTML, %str%, 3
	StringReplace, str, str,`n,, 1
	Return str
}

ExistSelectedText(byref Copy)   {
	MouseGetPos, , , , ControlID, 2
	If (ControlID != hActiveX)
		Return 0
	Try Copy := oDoc.selection.createRange().text
	If Copy is space
		Return 0
	Copy := RTrim(Trim(Copy), Chr(0x25aa))
	Copy := RegExReplace(Copy, Chr(0x25aa) Chr(0x25aa) "+", "#!#")
	StringReplace, Copy, Copy, % Chr(0x25aa), #, 1
	StringReplace, Copy, Copy, #!#  copy  #!#, #!#, 1
	StringReplace, Copy, Copy, #!#  pause  #!#, #!#
	Return 1
}

ShellProc(nCode, wParam)   {
	If (nCode = 4)
	{
		If (wParam = hGui)
			(ThisMode = "Hotkey" && !isPaused ? Hotkey_Hook := 1 : ""), HideMarker()
		Else If Hotkey_Hook
			Hotkey_Hook := 0, Hotkey_IsOnlyMods()
	}
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

	;  http://www.autohotkey.com/board/topic/77888-accessible-info-viewer-alpha-release-2012-09-20/

AccInfoUnderMouse(x, y)   {
	Static h
	If Not h
		h := DllCall("LoadLibrary","Str","oleacc","Ptr")
	If DllCall("oleacc\AccessibleObjectFromPoint"
		, "Int64", x&0xFFFFFFFF|y<<32, "Ptr*", pacc
		, "Ptr", VarSetCapacity(varChild,8+2*A_PtrSize,0)*0+&varChild) = 0
	Try Acc:=ComObjEnwrap(9,pacc,1), child:=NumGet(varChild,8,"UInt")
	If !IsObject(Acc)
		Return
	Type := child ? "Child" DP "<span id='param'>Id:  </span>" child
		: "Parent" DP "<span id='param'>ChildCount:  </span>" ((C:=Acc.accChildCount)!=""?C:"N/A")
	code = `n<span id='param'>Type:</span>  %Type%
	code .= DP "<span id='param'>Pos:  </span>" GetAccLocation(Acc, child)

	Try If ((Role := AccRole(Acc, child)) != "")  {
		code = %code%`n%D1% <a></a><span id='param'>( Role )</span> %DB% %copy_button% %D2%`n
		code .= "<span>" TransformHTML(Role) "</span>"
	}
	Try If (child &&(ObjRole := AccRole(Acc)) != "")  {
		code = %code%`n%D1% <a></a><span id='param'>( Role - parent )</span> %DB% %copy_button% %D2%`n
		code .= "<span>" TransformHTML(ObjRole) "</span>"
	}
	Try If ((Value := Acc.accValue(child)) != "")  {
		code = %code%`n%D1% <a></a><span id='param'>( Value )</span> %DB% %copy_button% %D2%`n
		code .= "<span>" TransformHTML(Value) "</span>"
	}
	Try If ((Name := Acc.accName(child)) != "")  {
		code = %code%`n%D1% <a></a><span id='param'>( Name )</span> %DB% %copy_button% %D2%`n
		code .= "<span>" TransformHTML(Name) "</span>"
	}
	Try If ((State := AccGetStateText(Acc.accState(child))) != "")  {
		code = %code%`n%D1% <a></a><span id='param'>( State )</span> %DB% %copy_button% %D2%`n
		code .= "<span>" TransformHTML(State) "</span>"
	}
	Try If ((Action := Acc.accDefaultAction(child)) != "")  {
		code = %code%`n%D1% <a></a><span id='param'>( Action )</span> %DB% %copy_button% %D2%`n
		code .= "<span>" TransformHTML(Action) "</span>"
	}
	Try If ((Selection := Acc.accSelection) > 0)  {
		code = %code%`n%D1% <a></a><span id='param'>( Selection - parent )</span> %D2%`n
		code .= "<span>" TransformHTML(Selection) "</span>"
	}
	Try If ((Focus := Acc.accFocus) > 0)  {
		code = %code%`n%D1% <a></a><span id='param'>( Focus - parent )</span> %D2%`n
		code .= "<span>" TransformHTML(Focus) "</span>"
	}
	Try If ((Description := Acc.accDescription(child)) != "")  {
		code = %code%`n%D1% <a></a><span id='param'>( Description )</span> %DB% %copy_button% %D2%`n
		code .= "<span>" TransformHTML(Description) "</span>"
	}
	Try If ((ShortCut := Acc.accKeyboardShortCut(child)) != "")  {
		code = %code%`n%D1% <a></a><span id='param'>( ShortCut )</span> %DB% %copy_button% %D2%`n
		code .= "<span>" TransformHTML(ShortCut) "</span>"
	}
	Try If ((Help := Acc.accHelp(child)) != "")  {
		code = %code%`n%D1% <a></a><span id='param'>( Help )</span> %DB% %copy_button% %D2%`n
		code .= "<span>" TransformHTML(Help) "</span>"
	}
	Try If ((HelpTopic := Acc.AccHelpTopic(child)))  {
		code = %code%`n%D1% <a></a><span id='param'>( HelpTopic )</span> %DB% %copy_button% %D2%`n
		code .= "<span>" TransformHTML(HelpTopic) "</span>"
	}
	Return code
}
AccRole(Acc, ChildId=0)   {
	Try Return ComObjType(Acc,"Name")="IAccessible"?AccGetRoleText(Acc.accRole(ChildId)):""
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
	Try Acc.accLocation(ComObj(0x4003,&x:=0), ComObj(0x4003,&y:=0), ComObj(0x4003,&w:=0), ComObj(0x4003,&h:=0), Child)
	Return "x" (AccCoord[1]:=NumGet(x,0,"int")) " y" (AccCoord[2]:=NumGet(y,0,"int"))
			. " w" (AccCoord[3]:=NumGet(w,0,"int")) " h" (AccCoord[4]:=NumGet(h,0,"int"))
}

	;  http://forum.script-coding.com/viewtopic.php?pid=81833#p81833

SelectFilePath(FilePath)   {
	SplitPath, FilePath, , FolderPath
	For Window in ComObjCreate("Shell.Application").Windows
	{
		Try If (Window.Document.Folder.Self.Path = FolderPath)
		{
			Try For item in Window.Document.Folder.Items
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

	;  http://forum.script-coding.com/viewtopic.php?pid=82283#p82283

class eventshtml  {
	onclick()   {
		oevent := oDoc.parentWindow.event.srcElement
		If (oevent.TagName = "BUTTON")
		{
			oDoc.body.focus()
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
			Else If thisid = pause_button
				Gosub PausedScript
			Else
			{
				If (thisid = "folder" && FileExist(WinProcessPath))
					SelectFilePath(WinProcessPath)
				Else If thisid = keyname
				{
					KeyName := GetKeyName(o_edithotkey.value), o_editkeyname.value := KeyName
					o := KeyName = "" ? o_edithotkey : o_editkeyname
					o.focus(), o2 := o.createTextRange(), o2.collapse(false), o2.select()
				}
			}
		}
	}
	ondblclick()   {
		thisid := oDoc.parentWindow.event.srcElement.id
		If (thisid = "winclose")
		{
			WinGet, WinPID, PID, ahk_id %WinCloseID%
			WinKill, ahk_id %WinCloseID%,, 0.4 
			IfWinExist, ahk_id %WinCloseID%
				Process, Close, %WinPID%
		}
		Else If (thisid = "pause_button")
			Gosub PausedScript
	}
	onfocus()   {
		Hotkey_Hook := 0
	}
	onblur()   {
		(!isPaused ? (Hotkey_Hook := 1) : 0)
	}
}
	;
