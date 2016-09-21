SNAPWEBCAM(@ScriptDir & "\Resources\snapshot.bmp")
Func SNAPWEBCAM($snapfile)
    Run(@ScriptDir & "\Resources\viewer.exe","",@SW_HIDE)
	Sleep(2000)
    Local Const $WS_CHILD = 0x40000000
    Local Const $WM_CAP_START = 0x400
    Local $WM_CAP_DRIVER_DISCONNECT = $WM_CAP_START + 11
    Local $WM_CAP_DRIVER_CONNECT = $WM_CAP_START + 10
    Local $WM_CAP_UNICODE_START = $WM_CAP_START + 100
    Local $avi = DllOpen("avicap32.dll")
    Local $user = DllOpen("user32.dll")
    Local $cap = DllCall($avi, "int", "capCreateCaptureWindow", "str", "cap", "int", $WS_CHILD, "int", 15, "int", 15, "int", 320, "int", 240, "hwnd", GUICreate("", 0, 0), "int", 1)
    DllCall($user, "int", "SendMessage", "hWnd", $cap[0], "int", $WM_CAP_DRIVER_CONNECT, "int", 0, "int", 0)
    GUISetState(@SW_DISABLE)
    SNAP($user, $cap[0], "")
    SNAP($user, $cap[0], "")
    SNAP($user, $cap[0], "")
    SNAP($user, $cap[0], $snapfile)
    DllCall($user, "int", "SendMessage", "hWnd", $cap[0], "int", $WM_CAP_UNICODE_START, "int", 0, "int", 0)
    DllCall($user, "int", "SendMessage", "hWnd", $cap[0], "int", $WM_CAP_DRIVER_DISCONNECT, "int", 0, "int", 0)
    ;DllClose($avi)
    ;DllClose($user)
	Sleep(2000)
	ProcessClose("viewer.exe")
	Exit
EndFunc   ;==>SNAPWEBCAM
Func SNAP($DLL, $cap, $savto)
    Local Const $WM_CAP_START = 0x400
    Local $WM_CAP_FILE_SAVEDIBA = $WM_CAP_START + 25
    Local $WM_CAP_GRAB_FRAME_NOSTOP = $WM_CAP_START + 61
    FileDelete($savto)
    DllCall($DLL, "int", "SendMessage", "hWnd", $cap, "int", $WM_CAP_GRAB_FRAME_NOSTOP, "int", 0, "int", 0)
    DllCall($DLL, "int", "SendMessage", "hWnd", $cap, "int", $WM_CAP_FILE_SAVEDIBA, "int", 0, "str", $savto)
EndFunc   ;==>SNAP