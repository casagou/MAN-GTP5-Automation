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

set_channel FCS_Mission_Mode_Enable_Cmd, 0

'******************************************************************************
'************************* MISSION MODE ACTIVATION ****************************
'******************************************************************************

note "FCS Control Mode set to Speed Mode"
note" "

' Control Mode 3=Speed mode
set_channel FCS_Control_Mode_Cmd, 3


'********** Set proDAS Control OFF (in case it was already ON) **********

result "Control Mode set to Speed Mode - 3", REPORT & "Set Point", BLACK

delay 10


'******************************************************************************
'************************************ Transistion FCS to proDAS ***************
'******************************************************************************


warning "-- Bumpless Transition FCS to proDAS --"
instruction "Go to Current GT Engine Speed", skip

set_channel GG_PT_Selector, 0

prompt_boo "Is GT Engine speed(s) at steady state?",booSteady
	If BooSteady = false Then
	result "Wait GT engine speed is steady state.", REPORT, RED
	quit
	End If


result "Estimating current GG Speed ..."
note "Gather current GG Speed target"
do_fullset 0

result "     * Estimated GG speed target = " &cv_N_GG &" rpm", REPORT & "Set Point", BLUE

delay 5

set_channel FCS_N_GG_Set_Cmd, cv_N_GG

note "Switching GT Engine Controle to proDAS Mode"

set_channel FCS_Mission_Mode_Enable_Cmd, 1
result "Mission Mode set to ON", REPORT & "Set Point", BLACK

wait "N_GG = " &cv_N_GG, 300, 5, TOC, 5, "Timout", SKIP, "GG is out of range"

result "proDAS Mode set to ON", REPORT & "Set Point", BLACK



'******************************************************************************
'****************************** TO GG1_Load1***********************************
'******************************************************************************



caution "-- N_GG 12900rpm --"
instruction "*** Go to GG1_Load1", skip


'********** Determine Speed & Load targets **********

note "1- Set GG Speed and Load targets"
result "Setting GG speed and Load targets..."
set_channel GG_Load_Selector, 1
do_fullset 0
result "Going to GG speed target = 12900 rpm and Load = 0 percent", REPORT & "Set Point", BLACK
delay 5


'********** Send Mechanical GG Speed & Load set points to FCS **********

note "2- Send Mechanical GG Speed 12900 rpm & Load 0 percent set points to FCS"
result "Sending Mechanical GG Speed 12900 rpm & Load 0 percent set points to FCS..."
set_channel FCS_N_GG_Set_Cmd, 12900
delay 5
set_channel FCS_Load_Set_Cmd, 0
result "GG Speed 12900 rpm and Load 0 percent sent to FCS."


'********** Wait for GT Engine to reach Speed & Load targets **********

note "3- Wait GT Engine to reach speed & load targets"
result "Waiting GT Engine to reach speed and load targets..."
wait "N_GG = " &12900, 300, 5, TOC, 5, "Timout", SKIP, "GG speed is out of range"
wait "Load = " &0, 300, 5, TOC, 5, "Timout", SKIP, "Load is out of range"
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
result "         ** GG Speed target offset =" &FormatNumber(fv_N_GG-12900,0) & " rpm", REPORT & "Fullset", RED
result "     * Load =" &fv_Load &" percent", REPORT & "Fullset", BLUE
result "         ** Load target offset =" &FormatNumber(fv_Load-0,0) & " percent", REPORT & "Fullset", RED
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



caution "-- N_GG stays at 12900rpm --"
instruction "*** Go to GG1_Load2", skip


'********** Determine Speed & Load targets **********

note "1- Set GG Speed and Load targets"
result "Setting GG speed and Load targets..."
set_channel GG_Load_Selector, 2
do_fullset 0
result "Going to GG speed target = 12900 rpm and Load = 30 percent", REPORT & "Set Point", BLACK
delay 5


'********** Send Mechanical GG Speed & Load set points to FCS **********

note "2- Send Mechanical GG Speed 12900 rpm & Load 30 percent set points to FCS"
result "Sending Mechanical GG Speed 12900 rpm & Load 30 percent set points to FCS..."
set_channel FCS_N_GG_Set_Cmd, 12900
delay 5
set_channel FCS_Load_Set_Cmd, 30
result "GG Speed 12900 rpm and Load 30 percent sent to FCS."


'********** Wait for GT Engine to reach Speed & Load targets **********

note "3- Wait GT Engine to reach speed & load targets"
result "Waiting GT Engine to reach speed and load targets..."
wait "N_GG = " &12900, 300, 5, TOC, 5, "Timout", SKIP, "GG speed is out of range"
wait "Load = " &0, 300, 5, TOC, 5, "Timout", SKIP, "Load is out of range"
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
result "         ** GG Speed target offset =" &FormatNumber(fv_N_GG-12900,0) & " rpm", REPORT & "Fullset", RED
result "     * Load =" &fv_Load &" percent", REPORT & "Fullset", BLUE
result "         ** Load target offset =" &FormatNumber(fv_Load-0,0) & " percent", REPORT & "Fullset", RED
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

