.686
.model flat, stdcall
option casemap: none

include Template.inc

.code
start:
	invoke GetModuleHandle, NULL
	mov hInstance, eax
	invoke InitCommonControls
	invoke DialogBoxParam, hInstance, IDD_DLGBOX, NULL, addr DlgProc, NULL
	invoke ExitProcess, NULL
	
DlgProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
LOCAL tkpNewButIgnored :TOKEN_PRIVILEGES 

	.if uMsg == WM_INITDIALOG
		;Setting Dialog Caption
		invoke SetWindowText, hWnd, addr szDialogCaption
		;Load desired icon
		invoke LoadIcon, hInstance, APP_ICON
		mov hIcon, eax
		invoke SendMessage, hWnd, WM_SETICON, 1, eax
		;Load cursor
		invoke LoadCursor, hInstance, Cursor1
		invoke SendMessage, hWnd, WM_SETCURSOR,1,eax
		;Store computername for shutdown
		invoke GetComputerName, addr szComputerName, addr nSize
		;Getting SystemInfo
		invoke GetSystemInfo, addr stSysInfo
		;Setting Timer for Time, Date & TickCount
		invoke SetTimer,hWnd, 0,1000,NULL
	.elseif uMsg == WM_TIMER
		;Time & Date
		invoke GetSystemTime, addr stSystemTime
		invoke GetTimeFormat,LOCALE_USER_DEFAULT,addr stSystemTime, NULL, addr timeFormat, addr time, 60
		invoke GetDateFormat,LOCALE_USER_DEFAULT, 0, NULL, addr dateFormat, addr date, 60
		invoke lstrcat, addr time,addr date			
		invoke SetDlgItemText, hWnd, IDC_DATE, addr time	
		;TickCount
		invoke GetTickCount
		invoke wsprintf, addr tickCount, addr szTickFormat, eax
		invoke SetDlgItemText, hWnd, IDC_TICKCOUNT, addr tickCount	
	.elseif uMsg == WM_COMMAND
		mov eax, wParam
		.if eax == IDC_EXIT
			invoke SendMessage, hWnd, WM_CLOSE,0, 0
		.elseif eax == IDC_SCAN
			;Disabling the Save button
			invoke GetDlgItem,hWnd, IDC_SAVE
			invoke EnableWindow, eax,FALSE
			;Computer Name
			invoke GetComputerName, addr szComputerName, addr nSize
			invoke SendDlgItemMessage,hWnd,IDC_COMPUNAME, EM_SETREADONLY, TRUE,0 ;Make box readonly if its not	
			invoke SetDlgItemText, hWnd, IDC_COMPUNAME , addr szComputerName
			;UserName
			invoke GetUserName,addr szUserName, addr nSize1
			invoke SetDlgItemText, hWnd, IDC_USERNAME , addr szUserName
			;System Directory
			invoke GetSystemDirectory, addr szSystemDir, addr nSize1
			invoke SetDlgItemText, hWnd, IDC_SYSDIR , addr szSystemDir
			;Windows Directory
			invoke GetWindowsDirectory, addr szWindowsDir, addr nSize1
			invoke SetDlgItemText, hWnd, IDC_WINDOWSDIR, addr szWindowsDir
			;Current Directoty
			invoke GetCurrentDirectory, addr nSize, addr szCurrentDir		
			invoke SetDlgItemText, hWnd, IDC_CURRENTDIR, addr szCurrentDir
			;Temporary Folder path
			invoke GetTempPath,addr nSize1, addr szTempPath
			invoke SetDlgItemText, hWnd, IDC_TEMPPATH, addr szTempPath
			;Drive Type
			invoke GetDriveType, addr drive
			;;;;
			
			invoke GetCurrentProcess
			invoke GetModuleFileNameEx,eax, hInstance, addr lpFileName, addr nSize1
			invoke SetDlgItemText, hWnd, 1021, addr lpFileName
		.elseif eax == IDC_CHANGE
			;Enable save button
			invoke GetDlgItem,hWnd, IDC_SAVE
			invoke EnableWindow, eax,TRUE
			;Remove readonly of editbox
			invoke SendDlgItemMessage,hWnd,IDC_COMPUNAME, EM_SETREADONLY, FALSE,0	
		.elseif eax == IDC_SAVE	
			invoke GetDlgItemText, hWnd, IDC_COMPUNAME,addr szNewComName,50
			.if eax<=0 
				invoke MessageBox, hWnd, addr szSaveText, addr szSaveCaption, MB_OK+ MB_ICONERROR
			.else 
				invoke SetComputerName, addr szNewComName
				invoke SendDlgItemMessage,hWnd,IDC_COMPUNAME, EM_SETREADONLY, TRUE,0
				invoke MessageBox, hWnd, addr szRestartText, addr szRestartCap, MB_OK + MB_ICONINFORMATION
			.endif	
		.elseif eax == IDC_ABOUT
			invoke MessageBox, hWnd, addr szAbtText, addr szAbtTitle,MB_OK+MB_ICONINFORMATION
		.elseif eax == IDC_SHUTDOWN
			invoke GetCurrentProcess
			;invoke OpenProcess,PROCESS_ALL_ACCESS,TRUE,hInstance
			invoke OpenProcessToken,eax,TOKEN_ADJUST_PRIVILEGES,  addr TokenHandle
			invoke LookupPrivilegeValue, addr szComputerName,addr szShutPriv,addr tkp.Privileges[0].Luid
			mov tkp.PrivilegeCount, 1
			mov tkp.Privileges[0].Attributes, SE_PRIVILEGE_ENABLED; 
			invoke AdjustTokenPrivileges,addr TokenHandle,FALSE, addr tkp,0, addr tks, 0
			invoke InitiateSystemShutdownEx, addr szComputerName,addr szShutMsg, 100, TRUE, TRUE,1
			invoke ExitWindowsEx,EWX_SHUTDOWN,0	
			
		.elseif eax == IDC_ABORT
			;invoke AbortSystemShutdown, addr szComputerName
			;invoke SetTimer, hWnd, 
		.elseif eax == IDC_MORE
			invoke DialogBoxParam, hInstance, IDD_DLGBOX2, hWnd, addr DlgProc2, NULL	
		.endif
	.elseif uMsg == WM_CLOSE
		invoke EndDialog, hWnd, 0
	.endif
	
	xor eax, eax			
	Ret
DlgProc EndP	

DlgProc2	proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
Local TCItem	:TC_ITEM

	.if uMsg == WM_INITDIALOG
		MOV TCItem.imask,TCIF_TEXT or TCIF_PARAM
		MOV TCItem.cchTextMax,64
		
		Invoke CreateDialogParam,hInstance,IDD_DLGBOX3,hWnd,Offset DlgProc3,0
		MOV TCItem.pszText,Offset szOSInfo
		MOV TCItem.lParam,EAX
		
		Invoke SendDlgItemMessage,hWnd,IDC_TABCONTROL,TCM_INSERTITEM,0,ADDR TCItem
		
		Invoke CreateDialogParam,hInstance,IDD_DLGBOX4,hWnd,Offset DlgProc4,0
		MOV TCItem.pszText,Offset szProcessorInfo
		MOV TCItem.lParam,EAX
	
		;Store handle of the visible child dialog
		Invoke SetWindowLong,hWnd,GWL_USERDATA,TCItem.lParam		
		Invoke SendDlgItemMessage,hWnd,IDC_TABCONTROL,TCM_INSERTITEM,0,ADDR TCItem
		Invoke SendDlgItemMessage,hWnd,IDC_TABCONTROL,TCM_SETCURSEL,0,0
		JMP @F
	.elseif uMsg ==WM_CTLCOLORDLG
		invoke CreateSolidBrush,00111111h
		ret	
	.elseIf uMsg == WM_NOTIFY
		MOV EDX, lParam
		
		.If [EDX].NMHDR.code == TCN_SELCHANGE
			
			Invoke GetWindowLong,hWnd,GWL_USERDATA
			Invoke ShowWindow,EAX,SW_HIDE
			
			Invoke SendDlgItemMessage,hWnd,IDC_TABCONTROL,TCM_GETCURSEL,0,0
			MOV TCItem.imask,TCIF_PARAM
			MOV EDX,EAX
			Invoke SendDlgItemMessage,hWnd,IDC_TABCONTROL,TCM_GETITEM,EDX,ADDR TCItem
			
			Invoke SetWindowLong,hWnd,GWL_USERDATA,TCItem.lParam
			
			;Invoke ShowWindow,TCItem.lParam,SW_SHOW
			@@:
			Invoke SetWindowPos,TCItem.lParam,HWND_TOP,0,0,0,0,SWP_SHOWWINDOW or SWP_NOMOVE or SWP_NOSIZE
			
		.EndIf
	.elseif uMsg == WM_COMMAND
		mov eax, wParam
	.elseif uMsg == WM_CLOSE
		invoke EndDialog, hWnd, NULL 
	.endif	
	xor eax, eax
	Ret
DlgProc2 EndP

DlgProc3 proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM

	.if uMsg == WM_INITDIALOG
		mov stOsVerInfo.OSVERSIONINFOEX.dwOSVersionInfoSize, SIZEOF(OSVERSIONINFOEX)		
		invoke GetVersionEx, addr stOsVerInfo
		invoke SetDlgItemText,hWnd, IDC_OSBUILD, addr stOsVerInfo.OSVERSIONINFOEX.szCSDVersion
		invoke wsprintf, addr buffer1, addr szForma,stOsVerInfo.OSVERSIONINFOEX.wServicePackMajor
		invoke SetDlgItemText,hWnd, 1042, addr buffer1
		invoke wsprintf, addr buffer1, addr szForma, stOsVerInfo.OSVERSIONINFOEX.wServicePackMinor
		invoke SetDlgItemText,hWnd, 1043, addr buffer1
		invoke wsprintf, addr buffer1, addr szForma, stOsVerInfo.OSVERSIONINFOEX.dwMajorVersion
		invoke SetDlgItemText,hWnd, 1044, addr buffer1
		invoke wsprintf, addr buffer1, addr szForma, stOsVerInfo.OSVERSIONINFOEX.dwMinorVersion
		invoke SetDlgItemText,hWnd, 1045, addr buffer1
		invoke wsprintf, addr buffer1, addr szForma, stOsVerInfo.OSVERSIONINFOEX.dwBuildNumber
		invoke SetDlgItemText,hWnd, 1046, addr buffer1
		invoke wsprintf, addr buffer1, addr szForma, stOsVerInfo.OSVERSIONINFOEX.dwPlatformId
		invoke SetDlgItemText,hWnd, 1047, addr buffer1
	.elseif uMsg ==WM_CTLCOLORDLG
		        invoke CreateSolidBrush,00FFFFFFh
				ret	
	.elseif uMsg == WM_CTLCOLORSTATIC
		     mov eax, lParam
       		RGB 50,50,50
       		invoke SetTextColor,wParam,eax
       		;RGB 100,100,100
       		;invoke SetBkColor,wParam,eax
       		RGB 255,255,255
       		Invoke CreateSolidBrush, eax
     		ret	
     .elseif uMsg == WM_CTLCOLOREDIT
     	mov eax, lParam
     		;RGB 200,200,200
       		;Invoke CreateSolidBrush, eax
       		ret
		comment ~
		mov eax, stOsVerInfo.dwPlatformId
		.if eax == 2 ; NT Family
			.if ((stOsVerInfo.dwMajorVersion == 6) && (stOsVerInfo.dwMinorVersion == 0))
					.if(stOsVerInfo.wProductType == VER_NT_WORKSTATION)
						;Windows Vista
					.else
						;WIndows Server Longhorn
					.endif
			.elseif	(stOsVerInfo.dwMajorVersion == 5 && stOsVerInfo.dwMinorVersion == 2)
				invoke GetSystemMetrics, SM_SERVERR2
				.if eax
						;Microsoft Windows Server 2003 \"R2\" 
         		.elseif(stOsVerInfo.OSVERSIONINFOEX.wProductType == VER_NT_WORKSTATION && stSysInfo.wProcessorArchitecture == PROCESSOR_ARCHITECTURE_AMD64)
          				;Microsoft Windows XP Professional x64 Edition "
         		.else 
         				;"Microsoft Windows Server 2003, "
    			.endif
      		.elseif (stOsVerInfo.dwMajorVersion == 5 &&  stOsVerInfo.dwMinorVersion == 1 )
         		;Microsoft Windows XP 

      		.elseif (stOsVerInfo.dwMajorVersion == 5 &&  stOsVerInfo.dwMinorVersion == 0 )
         		;Microsoft Windows 2000 

      		.elseif ( stOsVerInfo.dwMajorVersion <= 4 )
         		;Microsoft Windows NT 

      		.endif	
			invoke MessageBox, hWnd, addr szNTfamily, addr NT, MB_OK			
		.endif	
		~
	.elseif uMsg == WM_CLOSE
		invoke EndDialog, hWnd, 0
	.else
		MOV EAX,FALSE
		RET
	
	MOV EAX,TRUE	
	.endif	
	xor eax, eax
	Ret
DlgProc3 EndP

DlgProc4 proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM

	.if uMsg == WM_INITDIALOG

	.elseif uMsg == WM_COMMAND
	.elseif uMsg == WM_CLOSE
		invoke EndDialog, hWnd, 0
	.else
		MOV EAX,FALSE
		RET
	
	MOV EAX,TRUE	
	.endif	
	xor eax, eax
	Ret
DlgProc4 EndP

end start
