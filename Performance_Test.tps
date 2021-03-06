Option Explicit

'* <script.tps>
'******************************************************************************
'*  AUTHOR: <Joachim Agou & SimonT aka Zubean>
'*
'*  DESCRIPTION:
'*  <This is a sandbox and a template.>
'*
'*  DATE: 12/24/2019 3:05:59 PM
'*
'*  MODIFICATIONS:
'*    DATE         WHO  VERSION   DESCRIPTION
'*    ----------   ---  --------  --------------------------------------------------
'*    20201021     JOA  1.0       Initial version
'******************************************************************************



'******************************************************************************
'************************* LOCAL VARIABLE DECLARATIONS ************************
'******************************************************************************

dim booSteady, booFullset
channel "Buzzer_Enable_SW, N_GG, N_PT, Stabilization_Status, Recording_Status, PointCompleted_Status, GG_PT_Selector, GG_Target_ISO, PT_Target_ISO, GG_Target, PT_Target, N_GG_ISO, N_PT_ISO, Pow_ISO, T4_ISO, Eta_ISO, FCS_Control_Mode_Cmd, FCS_N_PT_Set_Cmd, FCS_N_GG_Set_Cmd, FCS_Mission_Mode_Enable_Cmd, GG_Target, PT_Target"



'******************************************************************************
'******************************** PREREQUISITES *******************************
'******************************************************************************

note "*** AUTOMATIC MODE - DEMO ***"
note" "


instruction "Before you start:",SKIP
	If skipGV = True Then
	result "Instructions skipped!", REPORT, RED
	End If

caution "> Verify the Speed Target RTD page is loaded."
note "> Verify the engine is around Idle speed."

' Set proDAS Control OFF (in case it was already ON)
set_channel FCS_Mission_Mode_Enable_Cmd, 0


'******************************************************************************
'************************* CHECK IF FCS IS IN POWER MODE ****************************
'******************************************************************************

'if FCS comtrol mode is not power mode, then stop TP


'******************************************************************************
'************************* CHECK IF GG speed is 12900rpm ****************************
'******************************************************************************

'if GG speed  is not 12900rpm, then stop TP


'******************************************************************************
'************************* MISSION MODE ACTIVATION ****************************
'******************************************************************************

note "FCS Control Mode set to Power Mode"
note" "

' Control Mode 0=No mode
' Control Mode 1=Manual Voltage mode
' Control Mode 2=Torque or Power mode
' Control Mode 3=Speed mode
set_channel FCS_Control_Mode_Cmd, 2


result "Control Mode set to Power Mode - 2", REPORT & "Set Point", BLACK

delay 10


'******************************************************************************
'************************************ Transistion FCS to proDAS ***************
'******************************************************************************


warning "-- Bumpless Transition FCS to proDAS --"
instruction "Go to Current Load", skip

set_channel GG_PT_Selector, 0

prompt_boo "Is GT Engine speed(s) and Load at steady state?",booSteady
	If BooSteady = false Then
	result "Wait GT engine speed and Load is steady state.", REPORT, RED
	quit
	End If


note "Determine current Power/Load target."
result "Determining current Power/Load ..."

do_fullset 0

result "     * Estimated Power target = " &cv_Pow &" kW", REPORT & "Set Point", BLUE

delay 5

set_channel FCS_Pow_Set_Cmd, cv_Pow

note "Switching GT Engine Controle to proDAS Mode"

set_channel FCS_Mission_Mode_Enable_Cmd, 1
result "Mission Mode set to ON", REPORT & "Set Point", BLACK

wait "N_GG = " &cv_N_GG, 300, 5, TOC, 5, "Timout", SKIP, "GG is out of range"
wait "Pow = " &cv_Pow, 300, 10, TOC, 5, "Timout", SKIP, "GG is out of range"

result "proDAS Mode set to ON", REPORT & "Set Point", BLACK



'******************************************************************************
'************************************ Transistion FCS to proDAS benjamin  ***************
'******************************************************************************

' read load set point  (kw)
' results


'******************************************************************************
'****************************** TO GG1_Load1***********************************
'******************************************************************************



caution "-- N_GG 12900rpm --"
instruction "*** Go to GG1_Load1", skip


'********** Determine Speed & Load targets **********

note "1- Set Load target"
result "Setting Load targets..."
set_channel GG_Load_Selector, 1
do_fullset 0
result "Going to Load = 0 percent", REPORT & "Set Point", BLACK
delay 5


'********** Send Load set point to FCS **********

note "2- Send Load 0 percent set point to FCS"
result "Sending Load 0 percent set point to FCS..."
set_channel FCS_Pow_Set_Cmd, cv_Pow_Target
result "GG Speed " & cv_N_GG_Target &" rpm and Load " & cv_Load_Target & " percent (" & cv_Pow_Target &" kW) sent to FCS."


'********** Wait for GT Engine to reach Load target **********

note "3- Wait GT Engine to reach Load target"
result "Waiting GT Engine to reach Load target..."
wait "N_GG = " &cv_N_GG_Target, 300, 5, TOC, 5, "Timout", SKIP, "GG Speed is out of range"
wait "Load = " &cv_Load_Target, 300, 3, TOC, 5, "Timout", SKIP, "Load is out of range"
result "GG Speed & Load targets monitoring completed."


'********** Buzzer indication **********

note "4- Buzzer"
result "Buzzing..."
set_channel Buzzer_Enable_SW, 1
delay 1
set_channel Buzzer_Enable_SW, 0
result "Buzzer OFF"


'********** Stabilization duration **********

note "5- Stabilization"
result "Stabilizing..."
set_channel Stabilization_Status, 1
result "Stabilizing - Minimum 20 minutes ...", REPORT & "Stabilization", BLACK
delay 1200
result "20 minutes completed.", REPORT & "Stabilization", BLACK
result "Stabilization completed", REPORT & "Stabilization", GREEN
set_channel Stabilization_Status, 0
result "Stabilization completed."


'********** Fullset recording **********

note "6- Record Steady-State measurement (fullset)"
result "Recording Steady-State measurement (fullset)..."
set_channel Recording_Status, 1
delay 1
do_fullset 10, "Performance measurement: GG1 Load1", "GG1_Load1"
result "A steady-state measurement has been taken automatically", REPORT & "Fullset", BLACK
result "     * GG Speed =" &fv_N_GG &" rpm", REPORT & "Fullset", BLUE
result "         ** GG Speed target offset =" &FormatNumber(fv_N_GG-fv_N_GG_Target,0) & " rpm", REPORT & "Fullset", RED
result "     * Load =" &fv_Load &" percent", REPORT & "Fullset", BLUE
result "         ** Load target offset =" &FormatNumber(fv_Load-fv_Load_Target,0) & " percent", REPORT & "Fullset", RED
result "     >> Power =" &fv_Pow &" kW", REPORT & "Fullset", BLUE
result "         ** Power target offset =" &FormatNumber(fv_Pow-fv_Pow_Target,0) & " percent", REPORT & "Fullset", RED
set_channel Recording_Status, 0
result "Fullset recording completed."


'********** Point completed **********

note "7- Point completed"
set_channel PointCompleted_Status, 1
delay 5
result "Thermodynamic measurement GG1_Load1 completed", REPORT & "Fullset", GREEN
set_channel PointCompleted_Status, 0
result " ", REPORT
result " ", REPORT



'******************************************************************************
'****************************** TO GG1_Load2***********************************
'******************************************************************************



caution "-- N_GG 12900rpm --"
instruction "*** Go to GG1_Load2", skip


'********** Determine Speed & Load targets **********

note "1- Set Load target"
result "Setting Load targets..."
set_channel GG_Load_Selector, 2
do_fullset 0
result "Going to Load = 30 percent", REPORT & "Set Point", BLACK
delay 5


'********** Send Load set point to FCS **********

note "2- Send Load 30 percent set point to FCS with gradient 3 percent per min"
result "Sending Load 30 percent set point to FCS with gradient 3 percent per min..."
'set_channel FCS_Pow_ROC_Set_Cmd, a value in 180kw/min
delay 5
set_channel FCS_Pow_Set_Cmd, cv_Pow_Target 1800kw
result "GG Speed " & cv_N_GG_Target &" rpm and Load " & cv_Load_Target & " percent (" & cv_Pow_Target &" kW) sent to FCS."


'********** Wait for GT Engine to reach Load target **********

note "3- Wait GT Engine to reach Load target"
result "Waiting GT Engine to reach Load target..."
wait "N_GG = " &cv_N_GG_Target, 300, 5, TOC, 5, "Timout", SKIP, "GG Speed is out of range"
wait "Load = " &cv_Load_Target, 660, 1, TOC, 5, "Timout", SKIP, "Load is out of range"
result "GG Speed & Load targets monitoring completed."


'********** Load target fine adjustments **********


set_channel FCS_Pow_Set_Cmd, cv_Pow_Target
wait "Load = " &cv_Load_Target, 30, 1, TOC, 5, "Timout", SKIP, "Load is out of range"


'********** Buzzer indication **********

note "4- Buzzer"
result "Buzzing..."
set_channel Buzzer_Enable_SW, 1
delay 1
set_channel Buzzer_Enable_SW, 0
result "Buzzer OFF"


'********** Stabilization duration **********

note "5- Stabilization"
result "Stabilizing..."
set_channel Stabilization_Status, 1
result "Stabilizing - Minimum 18 minutes ...", REPORT & "Stabilization", BLACK
delay 1080
result "18 minutes completed.", REPORT & "Stabilization", BLACK
result "Stabilization completed", REPORT & "Stabilization", GREEN
set_channel Stabilization_Status, 0
result "Stabilization completed."


'********** Fullset recording **********

note "6- Record Steady-State measurement (fullset)"
result "Recording Steady-State measurement (fullset)..."
set_channel Recording_Status, 1
delay 1
do_fullset 10, "Performance measurement: GG1 Load2", "GG1_Load2"
result "A steady-state measurement has been taken automatically", REPORT & "Fullset", BLACK
result "     * GG Speed =" &fv_N_GG &" rpm", REPORT & "Fullset", BLUE
result "         ** GG Speed target offset =" &FormatNumber(fv_N_GG-fv_N_GG_Target,0) & " rpm", REPORT & "Fullset", RED
result "     * Load =" &fv_Load &" percent", REPORT & "Fullset", BLUE
result "         ** Load target offset =" &FormatNumber(fv_Load-fv_Load_Target,0) & " percent", REPORT & "Fullset", RED
result "     >> Power =" &fv_Pow &" kW", REPORT & "Fullset", BLUE
result "         ** Power target offset =" &FormatNumber(fv_Pow-fv_Pow_Target,0) & " percent", REPORT & "Fullset", RED
set_channel Recording_Status, 0
result "Fullset recording completed."


'********** Point completed **********

note "7- Point completed"
set_channel PointCompleted_Status, 1
delay 5
result "Thermodynamic measurement GG1_Load1 completed", REPORT & "Fullset", GREEN
set_channel PointCompleted_Status, 0
result " ", REPORT
result " ", REPORT




'******************************************************************************
'************************* GG MAX POWER > GG4+100rpm ****************************
'******************************************************************************




'******************************************************************************
'************************* MISSION MODE DESACTIVATION ****************************
'******************************************************************************


note "FCS Mission Mode set to OFF"
note" "

set_channel FCS_Mission_Mode_Enable_Cmd, 0

result "Mission Mode set to OFF", REPORT & "Set Point", BLACK

delay 10



result RTE_Date
result RTE_Time
result "beep - beep - beep - beep - beep", REPORT, BLACK
beep 5

