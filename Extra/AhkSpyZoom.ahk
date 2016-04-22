
	; version = 1.42

#NoEnv
#NoTrayIcon
#SingleInstance Ignore
#KeyHistory 0

hAhkSpy = %1%
If !WinExist("ahk_id" hAhkSpy)
	ExitApp

ListLines Off
SetBatchLines,-1
CoordMode, Mouse, Screen
OnExit("ZoomOnClose")

Global oZoom := {}, hAhkSpy, MsgAhkSpyZoom
OnMessage(0x0020, "WM_SETCURSOR")
OnMessage(0x201, "LBUTTONDOWN") ; WM_LBUTTONDOWN
OnMessage(0xA1, "LBUTTONDOWN") ; WM_NCLBUTTONDOWN
OnMessage(0xF, "WM_Paint")
ZoomCreate()
OnMessage(MsgAhkSpyZoom := DllCall("RegisterWindowMessage", "Str", "AhkSpyZoom"), "MsgZoom")
PostMessage, % MsgAhkSpyZoom, 0, % oZoom.hGui, , ahk_id %hAhkSpy%
SetWinEventHook("EVENT_OBJECT_DESTROY", 0x8001)
SetWinEventHook("EVENT_OBJECT_LOCATIONCHANGE", 0x800B)
SetWinEventHook("EVENT_SYSTEM_MINIMIZESTART", 0x0016, 0x0017)
WinGet, Min, MinMax, % "ahk_id " hAhkSpy
If Min != -1
	ZoomShow()
SetTimer, CheckAhkSpy, 200
Return

#If oZoom.Show

^+#Up::
^+#Down::
+#WheelUp::
+#WheelDown::ChangeZoom(InStr(A_ThisHotKey, "Down") ? oZoom.Zoom + 1 : oZoom.Zoom - 1)

#If (!oZoom.AhkSpyPause && oZoom.Show && !IsMinimize(hAhkSpy))

+#Up::MouseStep(0, -1)
+#Down::MouseStep(0, 1)
+#Left::MouseStep(-1, 0)
+#Right::MouseStep(1, 0)

MouseStep(x, y) {
	MouseMove, x, y, 0, R
	If oZoom.Pause
	{
		SetTimer, Magnify, Off
		oZoom.Pause := 0, Magnify(), oZoom.Pause := 1
		SetTimer, Magnify, -10
	}
	PostMessage, % MsgAhkSpyZoom, 1, 0, , ahk_id %hAhkSpy%
}

#If

ZoomCreate() {
	oZoom.Zoom := IniRead("MagnifyZoom", 8)
	oZoom.Mark := IniRead("MagnifyMark", "Cross")
	oZoom.MemoryZoomSize := IniRead("MemoryZoomSize", 0)
	oZoom.GuiMinW := 308
	oZoom.GuiMinH := 368
	If oZoom.MemoryZoomSize
		GuiW := IniRead("MemoryZoomSizeW", oZoom.GuiMinW), GuiH := IniRead("MemoryZoomSizeH", oZoom.GuiMinH)
	Else
		GuiW := oZoom.GuiMinW, GuiH := oZoom.GuiMinH
	Gui Zoom: +AlwaysOnTop -DPIScale +hwndhGui +LabelZoomOn -Caption +E0x08000000 +Border
	Gui, Zoom: Font, s12
	Gui, Zoom: Color, F0F0F0
	Gui, Zoom: Add, Slider, hwndhSliderZoom gSliderZoom x8 Range1-50 w176 Center AltSubmit NoTicks, % oZoom.Zoom
	Gui, Zoom: Add, Text, hwndhTextZoom Center x+10 yp+3 w36, % oZoom.Zoom
	Gui, Zoom: Font
	Gui, Zoom: Add, Button, hwndhChangeMark gChangeMark x+10 yp w52, % oZoom.Mark
	Gui, Zoom: Show, % "Hide w" GuiW " h" GuiH, AhkSpyZoom
	Gui, Zoom: +MinSize

	Gui, Dev: +HWNDhDev -Caption -DPIScale +Parent%hGui% +Border
	Gui, Dev: Add, Text, hwndhDevCon
	Gui, Dev: Show, NA
	Gui, Dev: Color, F0F0F0

	oZoom.hdcSrc := DllCall("GetDC", Ptr, "")
	oZoom.hdcDest := DllCall("GetDC", Ptr, hDevCon, Ptr)
	oZoom.hdcMemory := DllCall("CreateCompatibleDC", "Ptr", 0)
	DllCall("gdi32.dll\SetStretchBltMode", "Ptr", oZoom.hdcDest, "Int", 4)
	oZoom.hGui := hGui
	oZoom.hDev := hDev
	oZoom.hDevCon := hDevCon

	oZoom.vTextZoom := hTextZoom
	oZoom.vChangeMark := hChangeMark
	oZoom.vSliderZoom := hSliderZoom
}

ZoomShow() {
	oZoom.Show := 1
	Gui, Zoom: Show, NA
	oZoom.Pause ? 0 : Magnify(), ZoomMove()
}

ZoomHide() {
	oZoom.Show := 0
	oZoom.Pause := 1
	Gui, Zoom: Show, Hide
} 

Magnify() {
	If (oZoom.Show && !oZoom.Pause && oZoom.SIZING != 2)
	{
		MouseGetPos, mX, mY, WinID
		If (WinID != oZoom.hGui && WinID != hAhkSpy)
		{
			SetTimer, Memory, Off
			oZoom.MouseX := mX, oZoom.MouseY := mY
			StretchBlt(oZoom.hdcDest, 0, 0, oZoom.nWidthDest, oZoom.nHeightDest
				, oZoom.hdcSrc, mX - oZoom.nXOriginSrcOffset, mY - oZoom.nYOriginSrcOffset, oZoom.nWidthSrc, oZoom.nHeightSrc)
			For k, v In oZoom.oMarkers[oZoom.Mark]
				StretchBlt(oZoom.hdcDest, v.x, v.y, v.w, v.h, oZoom.hdcDest, v.x, v.y, v.w, v.h, 0x5A0049)	; PATINVERT
			SetTimer, Memory, -30
		}
	}
	SetTimer, Magnify, -10
}

SetSize() {
	Static Top := 64, Left := 4, Right := 4, Bottom := 4, PrWidth, PrHeight
	SetTimer, Magnify, Off
	GetClientPos(oZoom.hGui, GuiWidth, GuiHeight)
	Width := GuiWidth - Left - Right
	Height := GuiHeight - Top - Bottom
	Zoom := oZoom.Zoom
	conW := Mod(Width, Zoom) ? Width - Mod(Width, Zoom) + Zoom : Width
	conW := Mod(conW // Zoom, 2) ? conW : conW + Zoom
	conH := Mod(Height, Zoom) ? Height - Mod(Height, Zoom) + Zoom : Height
	conH := Mod(conH // Zoom, 2) ? conH : conH + Zoom
	conX := ((conW - Width) // 2) * -1
	conY :=  ((conH - Height) // 2) * -1

	oZoom.nWidthSrc := conW // Zoom
	oZoom.nHeightSrc := conH // Zoom
	oZoom.nXOriginSrcOffset := oZoom.nWidthSrc//2
	oZoom.nYOriginSrcOffset := oZoom.nHeightSrc//2
	oZoom.nWidthDest := nWidthDest := conW
	oZoom.nHeightDest := nHeightDest := conH
	oZoom.xCenter := xCenter := conW / 2 - Zoom / 2
	oZoom.yCenter := yCenter := conH / 2 - Zoom / 2

	oZoom.oMarkers["Cross"] := [{x:0,y:yCenter - 1,w:nWidthDest,h:1}
		, {x:0,y:yCenter + Zoom,w:nWidthDest,h:1}
		, {x:xCenter - 1,y:0,w:1,h:nHeightDest}
		, {x:xCenter + Zoom,y:0,w:1,h:nHeightDest}]

	oZoom.oMarkers["Square"] := [{x:xCenter - 1,y:yCenter,w:Zoom + 2,h:1}
		, {x:xCenter - 1,y:yCenter + Zoom + 1,w:Zoom + 2,h:1}
		, {x:xCenter - 1,y:yCenter + 1,w:1,h:Zoom}
		, {x:xCenter + Zoom,y:yCenter + 1,w:1,h:Zoom}]

	oZoom.oMarkers["Grid"] := Zoom = 1 ? oZoom.oMarkers["Square"]
		: [{x:xCenter - Zoom,y:yCenter - Zoom,w:Zoom * 3,h:1}
		, {x:xCenter - Zoom,y:yCenter,w:Zoom * 3,h:1}
		, {x:xCenter - Zoom,y:yCenter + Zoom,w:Zoom * 3,h:1}
		, {x:xCenter - Zoom,y:yCenter + Zoom * 2,w:Zoom * 3,h:1}
		, {x:xCenter - Zoom,y:yCenter - Zoom,w:1,h:Zoom * 3}
		, {x:xCenter,y:yCenter - Zoom,w:1,h:Zoom * 3}
		, {x:xCenter + Zoom,y:yCenter - Zoom,w:1,h:Zoom * 3}
		, {x:xCenter + Zoom * 2,y:yCenter - Zoom,w:1,h:Zoom * 3}]

	SetWindowPos(oZoom.hDev, Left, Top, Width, Height)
	SetWindowPos(oZoom.hDevCon, conX, conY, conW, conH)
	Redraw()
	If (PrWidth != Width || PrHeight != Height)
	{
		PrWidth := Width, PrHeight := Height
		If oZoom.MemoryZoomSize
			IniWrite(GuiWidth, "MemoryZoomSizeW"), IniWrite(GuiHeight, "MemoryZoomSizeH")
		SetTimer, RedrawWindow, -100
	}
	SetTimer, Magnify, -10
}

SetWindowPos(hWnd, x, y, w, h) {
	Static SWP_ASYNCWINDOWPOS := 0x4000, SWP_DEFERERASE := 0x2000, SWP_NOACTIVATE := 0x0010, SWP_NOCOPYBITS := 0x0100
		, SWP_NOOWNERZORDER := 0x0200, SWP_NOREDRAW := 0x0008, SWP_NOSENDCHANGING := 0x0400
	DllCall("SetWindowPos"
		, "Ptr", hWnd
		, "Ptr", 0
		, "Int", x
		, "Int", y
		, "Int", w
		, "Int", h
		, "UInt", SWP_ASYNCWINDOWPOS|SWP_DEFERERASE|SWP_NOACTIVATE|SWP_NOCOPYBITS|SWP_NOOWNERZORDER|SWP_NOREDRAW|SWP_NOSENDCHANGING)
}

RedrawWindow() {
	DllCall("RedrawWindow", "Ptr", oZoom.hGui, "Uint", 0, "Uint", 0, "Uint", 0x1|0x4) 
}

ZoomMove() {
	If !oZoom.Show
		Return
	WinGetPos, WinX, WinY, WinWidth, WinHeight, ahk_id %hAhkSpy%
	Gui, Zoom:Show, % "x" WinX + WinWidth " y" WinY " NA" 
}

SliderZoom()  {
	GuiControlGet, SliderZoom, Zoom:, % oZoom.vSliderZoom
	ChangeZoom(SliderZoom)
}

ChangeZoom(Val)  {
	If (Val < 1 || Val > 50)
		Return
	SetTimer, Magnify, Off
	GuiControl, Zoom:, % oZoom.vTextZoom, % oZoom.Zoom := Val
	GuiControl, Zoom:, % oZoom.vSliderZoom, % oZoom.Zoom
	IniWrite(oZoom.Zoom, "MagnifyZoom")
	SetTimer, SetSize, -10
}

ChangeMark()  {
	oZoom.Mark := ["Cross","Square","Grid","None"][{"Cross":2,"Square":3,"Grid":4,"None":1}[oZoom.Mark]]
	GuiControl, Zoom:, % oZoom.vChangeMark, % oZoom.Mark
	IniWrite(oZoom.Mark, "MagnifyMark")
	Redraw()
}

WM_Paint() {
	SetTimer, Redraw, -10
}

Memory() {
	SysGet, VirtualScreenX, 76
	SysGet, VirtualScreenY, 77
	SysGet, VirtualScreenWidth, 78
	SysGet, VirtualScreenHeight, 79 
	oZoom.nXOriginSrc := oZoom.MouseX - VirtualScreenX, oZoom.nYOriginSrc := oZoom.MouseY - VirtualScreenY
	hBM := DllCall("Gdi32.Dll\CreateCompatibleBitmap", "Ptr", oZoom.hdcSrc, "Int", VirtualScreenWidth, "Int", VirtualScreenHeight)
	DllCall("Gdi32.Dll\SelectObject", "Ptr", oZoom.hdcMemory, "Ptr", hBM), DllCall("DeleteObject", "Ptr", hBM)
	BitBlt(oZoom.hdcMemory, 0, 0, VirtualScreenWidth, VirtualScreenHeight, oZoom.hdcSrc, VirtualScreenX, VirtualScreenY)
}

Redraw() {
	StretchBlt(oZoom.hdcDest, 0, 0, oZoom.nWidthDest, oZoom.nHeightDest
		, oZoom.hdcMemory, oZoom.nXOriginSrc - oZoom.nXOriginSrcOffset, oZoom.nYOriginSrc - oZoom.nYOriginSrcOffset, oZoom.nWidthSrc, oZoom.nHeightSrc)
	For k, v In oZoom.oMarkers[oZoom.Mark]
		StretchBlt(oZoom.hdcDest, v.x, v.y, v.w, v.h, oZoom.hdcDest, v.x, v.y, v.w, v.h, 0x5A0049)	; PATINVERT
} 

CheckAhkSpy() {
	WinGet, Min, MinMax, % "ahk_id " hAhkSpy
	If Min =
		ExitApp
	If (Min = -1 || WinActive("ahk_id" hAhkSpy))
		oZoom.Pause := 1
}

GetClientPos(hwnd, ByRef W, ByRef H)  {
	VarSetCapacity(pwi, 60, 0), NumPut(60, pwi, 0, "UInt")
	DllCall("GetWindowInfo", "Ptr", hwnd, "UInt", &pwi)
	W := NumGet(pwi, 28, "int") - NumGet(pwi, 20, "int")
	H := NumGet(pwi, 32, "int") - NumGet(pwi, 24, "int")
}

IniRead(Key, Error := " ")  {
	IniRead, Value, %A_AppData%\AhkSpy.ini, AhkSpy, %Key%, %Error%
	Return Value = "" ? Error : Value
}

IniWrite(Value, Key) {
	IniWrite, %Value%, %A_AppData%\AhkSpy.ini, AhkSpy, %Key%
	Return Value
}

IsMinimize(hwnd) {
	WinGet, Min, MinMax, % "ahk_id " hwnd
	If Min = -1
		Return 1
}

SetWinEventHook(EventProc, eventMin, eventMax = 0)  {
	Return DllCall("SetWinEventHook"
				, "UInt", eventMin, "UInt", eventMax := !eventMax ? eventMin : eventMax
				, "Ptr", hmodWinEventProc := 0, "Ptr", lpfnWinEventProc := RegisterCallback(EventProc, "F")
				, "UInt", idProcess := 0, "UInt", idThread := 0
				, "UInt", dwflags := 0x0|0x2, "Ptr")	;	WINEVENT_OUTOFCONTEXT | WINEVENT_SKIPOWNPROCESS
}

BitBlt(ddc, dx, dy, dw, dh, sdc, sx, sy, Raster = 0xC000CA) {
	Return DllCall("Gdi32.Dll\BitBlt"
					, "Ptr", dDC
					, "Int", dx
					, "Int", dy
					, "Int", dw
					, "Int", dh
					, "Ptr", sDC
					, "Int", sx
					, "Int", sy
					, "Uint", Raster)
}

StretchBlt(ddc, dx, dy, dw, dh, sdc, sx, sy, sw, sh, Raster = 0xC000CA) {
	Return DllCall("Gdi32.Dll\StretchBlt"
					, "Ptr", dDC
					, "Int", dx
					, "Int", dy
					, "Int", dw
					, "Int", dh
					, "Ptr", sDC
					, "Int", sx
					, "Int", sy
					, "Int", sw
					, "Int", sh
					, "Uint", Raster)
}

	; _________________________________________________ Events _________________________________________________

ZoomOnSize() {
	If A_EventInfo != 0
		Return
	SetTimer, SetSize, -10
	ZoomMove()
}

ZoomOnClose() {
	DllCall("gdi32.dll\DeleteDC", "Ptr", oZoom.hdcDest)
	DllCall("gdi32.dll\DeleteDC", "Ptr", oZoom.hdcSrc)
	DllCall("Gdi32.Dll\DeleteDC", "Ptr", oZoom.hdcMemory)
	RestoreCursors()
	ExitApp
}

	; wParam: 0 снять паузу, 1 пауза, 2 однократный зум, 3 hide, 4 show, 5 MemoryZoomSize, 6 MinSize, 7 пауза AhkSpy

MsgZoom(wParam, lParam) {
	If wParam = 0
		oZoom.Pause := 0, Magnify()
	Else If wParam = 1
		oZoom.Pause := 1
	Else If wParam = 2
	{
		SetTimer, Magnify, Off
		S_Pause := oZoom.Pause, oZoom.Pause := 0, Magnify(), oZoom.Pause := S_Pause
		SetTimer, Magnify, -10
	}
	Else If wParam = 3
		ZoomHide()
	Else If wParam = 4
		ZoomShow()
	Else If wParam = 5
	{
		oZoom.MemoryZoomSize := lParam
		If lParam
			GetClientPos(oZoom.hGui, GuiWidth, GuiHeight)
			, IniWrite(GuiWidth, "MemoryZoomSizeW")
			, IniWrite(GuiHeight, "MemoryZoomSizeH")
	}
	Else If (wParam = 6 && oZoom.Show)
		Gui, Zoom:Show, % "NA w" oZoom.GuiMinW " h" oZoom.GuiMinH
	Else If wParam = 7
		oZoom.AhkSpyPause := lParam
}

EVENT_OBJECT_DESTROY(hWinEventHook, event, hwnd) {
	If (idObject || idChild || hwnd != hAhkSpy)
		Return
	ExitApp
}

EVENT_OBJECT_LOCATIONCHANGE(hWinEventHook, event, hwnd) {
	If (idObject || idChild || hwnd != hAhkSpy)
		Return
	ZoomMove()
}

EVENT_SYSTEM_MINIMIZESTART(hWinEventHook, event, hwnd) {
	If (idObject || idChild || hwnd != hAhkSpy)
		Return
	oZoom.Pause := 1
}

	; _________________________________________________ Sizing _________________________________________________

WM_SETCURSOR(W, L, M, H) {
	Static SIZENWSE := DllCall("User32.dll\LoadCursor", "Ptr", NULL, "Int", 32642, "UPtr")
			, SIZENS := DllCall("User32.dll\LoadCursor", "Ptr", NULL, "Int", 32645, "UPtr")
			, SIZEWE := DllCall("User32.dll\LoadCursor", "Ptr", NULL, "Int", 32644, "UPtr")
	If (oZoom.SIZING = 2)
		Return
	If (W = oZoom.hGui)
	{
		MouseGetPos, mX, mY
		WinGetPos, WinX, WinY, WinW, WinH, % "ahk_id " oZoom.hDev
		If (mX > WinX && mY > WinY)
		{
			If (mX < WinX + WinW - 10)
				DllCall("User32.dll\SetCursor", "Ptr", SIZENS), oZoom.SIZINGType := "NS"
			Else If (mY < WinY + WinH)
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
		oZoom.SIZING := 2
		SetSystemCursor("SIZE" oZoom.SIZINGType)
		SetTimer, Sizing, -10
		KeyWait LButton
		SetTimer, Sizing, Off
		RestoreCursors()
		SetSize()
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
	Static SPI_SETCURSORS := 0x57
	DllCall("SystemParametersInfo", UInt, SPI_SETCURSORS, UInt, 0, UInt, 0, UInt, 0)
}
