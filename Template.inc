
include windows.inc
include kernel32.inc
include user32.inc
include advapi32.inc
include shell32.inc
include comctl32.inc
include masm32.inc
include psapi.inc
include gdi32.inc

includelib kernel32.lib
includelib user32.lib
includelib advapi32.lib
includelib shell32.lib
includelib comctl32.lib
includelib masm32.lib
includelib psapi.lib
includelib gdi32.lib

DlgProc		proto	:HWND, :UINT, :WPARAM, :LPARAM
DlgProc2	proto	:HWND, :UINT, :WPARAM, :LPARAM
DlgProc3	proto	:HWND, :UINT, :WPARAM, :LPARAM
DlgProc4	proto	:HWND, :UINT, :WPARAM, :LPARAM


RGB MACRO red,green,blue
  xor eax,eax
  mov ah,blue
  shl eax,8
  mov ah,green
  mov al,red
endm 

.data
szDialogCaption	db	"SysInfo 0.1",0
nSize		dd	100
nSize1		dd	100
drive		db	"F:\",0
szShutMsg	DB	"The system will shutdown in 30 seconds. If you want to stop press Abort now!",0
szShutPriv	db	"SeSecurityPrivilege",0   ; "SE_SHUTDOWN_NAME",0
privilege	db	"SE_PRIVILEGE_ENABLED",0
dateFormat	db	"ddddddddd, d MMMMMMMMM yyy",0
timeFormat	db	"hh':'mm':'ss tt  ",0
szTickFormat	db	"%d",0
;Tab Names
szProcessorInfo	db	"Processor",0
szOSInfo		db	"OS Info",0

;About Info
szAbtTitle	db	"SysInfo 0.1",0
szAbtText	db	"Created by : Lahar",13,10
			db	"Special thanks to samael, Antonis for their codes ",13,10
			db	"and to all winasm.net members",0
			
;Save Message Info
szSaveCaption	db	"Error",0
szSaveText		db	"Nothing Entered!",0	
	
;RestartInfo
szRestartCap	db	"Info",0
szRestartText	db	"Restart computer to see changes",0	

szForma 		db "%li",0

szNTfamily		db	"NT Family",0
NT				db	"NT",0

.data?
hInstance		HINSTANCE ?
hIcon			dd	?
szComputerName	db	60 	dup(?)
szUserName		db	60 	dup(?)
szSystemDir		db	100 dup(?)
szWindowsDir	db	100 dup(?)
szCurrentDir	db	100 dup(?)
szNewComName	db	50 	dup(?)
szTempPath		db	80	dup(?)
shutHandle		dd	?
lpName 			db	80	dup(?)
lpDisplayName 	db	80	dup(?)
cbDisplayName	dd ?
lpLanguageID	db	80	dup(?)
currentProcess	dd	?
TokenHandle		HANDLE ?
lBuffer			dd	?
date			db	 60 dup(?)
time			db	 60 dup(?)
tickCount		dd	?
stSystemTime	 SYSTEMTIME <?>
buffer1 		db 50 dup(?)
stOsVerInfo	OSVERSIONINFOEX <?>
stSysInfo	SYSTEM_INFO <?>
tkp TOKEN_PRIVILEGES <>
tks TOKEN_PRIVILEGES <>
lpFileName		db	50 dup (?)

 
.const
;Dialog Boxes
IDD_DLGBOX		equ	1001
IDD_DLGBOX2		equ	1033
IDD_DLGBOX3		equ	1036
IDD_DLGBOX4		equ	1039
;Buttons
IDC_EXIT		equ	1002
IDC_SCAN		equ	1006
IDC_CHANGE		equ	1026
IDC_SAVE		equ	1027
IDC_ABOUT		equ	1017
IDC_SHUTDOWN	equ	1023
IDC_ABORT		equ	1024
IDC_MORE		equ	1034
;Editboxes
IDC_COMPUNAME	equ	1004
IDC_USERNAME	equ	1007
IDC_SYSDIR		equ	1009
IDC_WINDOWSDIR	equ	1011
IDC_CURRENTDIR	equ	1013
IDC_TEMPPATH	equ	1018
IDC_TICKCOUNT	equ	1020
IDC_DATE		equ 1029
;TAB EditBoxes
IDC_OSBUILD		equ	1038
;TAB
IDC_TABCONTROL	equ	1035
;Icon & Cursor
APP_ICON		equ	2000
Cursor1			equ	2001


