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
'*    20200627     JOA  1.0       Initial version
'*    20201001     JOA  2.0       All steps
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


result "Estimating current GG Speed and PT Speed ..."
note "Gather current GG Speed and PT Speed targets"
do_fullset 0

result "     * Estimated GG speed target = " &cv_N_GG &" rpm", REPORT & "Set Point", BLUE
result "     * Estimated GG speed target = " &cv_N_PT &" rpm", REPORT & "Set Point", BLUE

delay 5

set_channel FCS_N_GG_Set_Cmd, cv_N_GG
set_channel FCS_N_PT_Set_Cmd, cv_N_PT

note "Switching GT Engine Controle to proDAS Mode"

set_channel FCS_Mission_Mode_Enable_Cmd, 1
result "Mission Mode set to ON", REPORT & "Set Point", BLACK

wait "N_GG = " &cv_N_GG, 300, 5, TOC, 5, "Timout", SKIP, "GG is out of range"
wait "N_PT = " &cv_N_PT, 300, 5, TOC, 5, "Timout", SKIP, "PT is out of range"

result "proDAS Mode set to ON", REPORT & "Set Point", BLACK



'******************************************************************************
'************************************ TO Warmup ******************************TBD
'******************************************************************************





'******************************************************************************
'************************************ TO GG1 PT1 ******************************done
'******************************************************************************


caution "-- GG1 Curve --"
instruction "*** Go to GG1_PT1", skip


'********** ISO speed targets **********

note "1- Set ISO GG speed and ISO PT speed targets"
result "Setting ISO GG1 speed and ISO PT1 speed targets..."
set_channel GG_PT_Selector, 1
do_fullset 0
result "Going to GG speed ISO target = " &cv_GG_Target_ISO &" rpm and PT speed ISO target = " &cv_PT_Target_ISO &" rpm", REPORT & "Set Point", BLACK
delay 5


'********** Mechanical speed targets **********

note "2- Estimate Mechanical GG Speed and PT Speed targets"
result "Estimating Mechanical GG Speed and PT Speed targets ..."
do_fullset 0
result "     * Estimated GG speed target = " &cv_GG_Target &" rpm", REPORT & "Set Point", BLUE
result "     * Estimated PT speed target = " &cv_PT_Target &" rpm", REPORT & "Set Point", BLUE
delay 5


'********** Send Mechanical speed set points to FCS **********

note "3- Send Mechanical speed set points to FCS"
result "Sending Mechanical speed set points to FCS..."
set_channel FCS_N_GG_Set_Cmd, cv_GG_Target
delay 5
set_channel FCS_N_PT_Set_Cmd, cv_PT_Target
result "Speed set points to FCS sent."


'********** Wait for GT Engine to reach ISO speed targets **********

note "4- Wait GT Engine to reach ISO speed targets"
result "Waiting GT Engine to reach ISO speed targets..."
wait "N_GG_ISO = " &cv_GG_Target_ISO, 300, 5, TOC, 5, "Timout", SKIP, "GG is out of range"
wait "N_PT_ISO = " &cv_PT_Target_ISO, 300, 5, TOC, 5, "Timout", SKIP, "PT is out of range"
result "Speed target monitoring completed."

'********** Buzzer indication **********

note "5- Buzzer"
result "Buzzing..."
set_channel Buzzer_Enable_SW, 1
delay 1
set_channel Buzzer_Enable_SW, 0
result "Buzzer OFF"


'********** Stabilization duration **********

note "6- Stabilization"
result "Stabilizing..."
set_channel Stabilization_Status, 1
result "Stabilizing - Minimum 15 minutes ...", REPORT & "Stabilization", BLACK
delay 600
result "10 minutes completed.", REPORT & "Stabilization", BLACK
result "5 more minutes ...", REPORT & "Stabilization", BLACK
delay 300
result "Stabilization completed", REPORT & "Stabilization", GREEN
set_channel Stabilization_Status, 0
result "Stabilization completed."


'********** Fullset recording **********

note "7- Record Steady-State measurement (fullset)"
result "Recording Steady-State measurement (fullset)..."
set_channel Recording_Status, 1
delay 1
do_fullset 10, "Thermodynamic measurement: N_GG1 N_PT1", "GG1_PT1"
result "A steady-state measurement has been taken automatically", REPORT & "Fullset", BLACK
result "     * GG speed ISO =" &fv_N_GG_ISO &" rpm", REPORT & "Fullset", BLUE
result "         ** GG target offset =" &FormatNumber(fv_N_GG_ISO-fv_GG_Target_ISO,0) & " rpm", REPORT & "Fullset", RED
result "     * GG speed ISO =" &fv_N_PT_ISO &" rpm", REPORT & "Fullset", BLUE
result "         ** GG target offset =" &FormatNumber(fv_N_PT_ISO-fv_PT_Target_ISO,0) & " rpm", REPORT & "Fullset", RED
result "     * Power ISO =" &fv_Pow_ISO &" kW", REPORT & "Fullset", BLUE
result "     * Efficiency ISO =" &fv_Eta_ISO &" %", REPORT & "Fullset", BLUE
result "     * T4 ISO =" &fv_T4_ISO &" degC", REPORT & "Fullset", BLUE
set_channel Recording_Status, 0
result "Fullset recording completed."


'********** Point completed **********

note "8- Point completed"
set_channel PointCompleted_Status, 1
delay 5
result "Thermodynamic measurement GG1_PT1 completed", REPORT & "Fullset", GREEN
set_channel PointCompleted_Status, 0
result " ", REPORT
result " ", REPORT



'******************************************************************************
'************************************ TO GG1 PT2 ******************************done
'******************************************************************************


instruction "*** Go to GG1_PT2", skip


'********** ISO speed targets **********

note "1- Set ISO GG speed and ISO PT speed targets"
result "Setting ISO GG1 speed and ISO PT1 speed targets..."
set_channel GG_PT_Selector, 2
do_fullset 0
result "Going to GG speed ISO target = " &cv_GG_Target_ISO &" rpm and PT speed ISO target = " &cv_PT_Target_ISO &" rpm", REPORT & "Set Point", BLACK
delay 5


'********** Mechanical PT speed targets **********

note "2- Estimate Mechanical PT Speed target"
result "Estimating Mechanical PT Speed target ..."
do_fullset 0
result "     * Estimated PT speed target = " &cv_PT_Target &" rpm", REPORT & "Set Point", BLUE
delay 5


'********** Send Mechanical PT speed set point to FCS **********

note "3- Send Mechanical PT speed set point to FCS"
result "Sending Mechanical PT speed set point to FCS..."
set_channel FCS_N_PT_Set_Cmd, cv_PT_Target
result "Speed set point to FCS sent."


'********** Wait for GT Engine to reach ISO PT speed target **********

note "4- Wait GT Engine to reach ISO PT speed target"
result "Waiting GT Engine to reach ISO PT speed target..."
wait "N_PT_ISO = " &cv_PT_Target_ISO, 300, 5, TOC, 5, "Timout", SKIP, "PT is out of range"
result "Speed target monitoring completed."

'********** Buzzer indication **********

note "5- Buzzer"
result "Buzzing..."
set_channel Buzzer_Enable_SW, 1
delay 1
set_channel Buzzer_Enable_SW, 0
result "Buzzer OFF"


'********** Stabilization duration **********

note "6- Stabilization"
result "Stabilizing..."
set_channel Stabilization_Status, 1
result "Stabilizing - Minimum 3 minutes ...", REPORT & "Stabilization", BLACK
delay 240
result "Stabilization completed", REPORT & "Stabilization", GREEN
set_channel Stabilization_Status, 0
result "Stabilization completed."


'********** Fullset recording **********

note "7- Record Steady-State measurement (fullset)"
result "Recording Steady-State measurement (fullset)..."
set_channel Recording_Status, 1
delay 1
do_fullset 10, "Thermodynamic measurement: N_GG1 N_PT2", "GG1_PT2"
result "A steady-state measurement has been taken automatically", REPORT & "Fullset", BLACK
result "     * GG speed ISO =" &fv_N_GG_ISO &" rpm", REPORT & "Fullset", BLUE
result "         ** GG target offset =" &FormatNumber(fv_N_GG_ISO-fv_GG_Target_ISO,0) & " rpm", REPORT & "Fullset", RED
result "     * GG speed ISO =" &fv_N_PT_ISO &" rpm", REPORT & "Fullset", BLUE
result "         ** GG target offset =" &FormatNumber(fv_N_PT_ISO-fv_PT_Target_ISO,0) & " rpm", REPORT & "Fullset", RED
result "     * Power ISO =" &fv_Pow_ISO &" kW", REPORT & "Fullset", BLUE
result "     * Efficiency ISO =" &fv_Eta_ISO &" %", REPORT & "Fullset", BLUE
result "     * T4 ISO =" &fv_T4_ISO &" degC", REPORT & "Fullset", BLUE
set_channel Recording_Status, 0
result "Fullset recording completed."


'********** Point completed **********

note "8- Point completed"
set_channel PointCompleted_Status, 1
delay 5
result "Thermodynamic measurement GG1_PT2 completed", REPORT & "Fullset", GREEN
set_channel PointCompleted_Status, 0
result " ", REPORT
result " ", REPORT



'******************************************************************************
'************************************ TO GG1 PT3 ******************************done
'******************************************************************************


instruction "*** Go to GG1_PT3", skip


'********** ISO speed targets **********

note "1- Set ISO GG speed and ISO PT speed targets"
result "Setting ISO GG1 speed and ISO PT1 speed targets..."
set_channel GG_PT_Selector, 3
do_fullset 0
result "Going to GG speed ISO target = " &cv_GG_Target_ISO &" rpm and PT speed ISO target = " &cv_PT_Target_ISO &" rpm", REPORT & "Set Point", BLACK
delay 5


'********** Mechanical PT speed targets **********

note "2- Estimate Mechanical PT Speed target"
result "Estimating Mechanical PT Speed target ..."
do_fullset 0
result "     * Estimated PT speed target = " &cv_PT_Target &" rpm", REPORT & "Set Point", BLUE
delay 5


'********** Send Mechanical PT speed set point to FCS **********

note "3- Send Mechanical PT speed set point to FCS"
result "Sending Mechanical PT speed set point to FCS..."
set_channel FCS_N_PT_Set_Cmd, cv_PT_Target
result "Speed set point to FCS sent."


'********** Wait for GT Engine to reach ISO PT speed target **********

note "4- Wait GT Engine to reach ISO PT speed target"
result "Waiting GT Engine to reach ISO PT speed target..."
wait "N_PT_ISO = " &cv_PT_Target_ISO, 300, 5, TOC, 5, "Timout", SKIP, "PT is out of range"
result "Speed target monitoring completed."

'********** Buzzer indication **********

note "5- Buzzer"
result "Buzzing..."
set_channel Buzzer_Enable_SW, 1
delay 1
set_channel Buzzer_Enable_SW, 0
result "Buzzer OFF"


'********** Stabilization duration **********

note "6- Stabilization"
result "Stabilizing..."
set_channel Stabilization_Status, 1
result "Stabilizing - Minimum 3 minutes ...", REPORT & "Stabilization", BLACK
delay 240
result "Stabilization completed", REPORT & "Stabilization", GREEN
set_channel Stabilization_Status, 0
result "Stabilization completed."


'********** Fullset recording **********

note "7- Record Steady-State measurement (fullset)"
result "Recording Steady-State measurement (fullset)..."
set_channel Recording_Status, 1
delay 1
do_fullset 10, "Thermodynamic measurement: N_GG1 N_PT3", "GG1_PT3"
result "A steady-state measurement has been taken automatically", REPORT & "Fullset", BLACK
result "     * GG speed ISO =" &fv_N_GG_ISO &" rpm", REPORT & "Fullset", BLUE
result "         ** GG target offset =" &FormatNumber(fv_N_GG_ISO-fv_GG_Target_ISO,0) & " rpm", REPORT & "Fullset", RED
result "     * GG speed ISO =" &fv_N_PT_ISO &" rpm", REPORT & "Fullset", BLUE
result "         ** GG target offset =" &FormatNumber(fv_N_PT_ISO-fv_PT_Target_ISO,0) & " rpm", REPORT & "Fullset", RED
result "     * Power ISO =" &fv_Pow_ISO &" kW", REPORT & "Fullset", BLUE
result "     * Efficiency ISO =" &fv_Eta_ISO &" %", REPORT & "Fullset", BLUE
result "     * T4 ISO =" &fv_T4_ISO &" degC", REPORT & "Fullset", BLUE
set_channel Recording_Status, 0
result "Fullset recording completed."


'********** Point completed **********

note "8- Point completed"
set_channel PointCompleted_Status, 1
delay 5
result "Thermodynamic measurement GG1_PT3 completed", REPORT & "Fullset", GREEN
set_channel PointCompleted_Status, 0
result " ", REPORT
result " ", REPORT



'******************************************************************************
'************************************ TO GG1 PT4 ******************************done
'******************************************************************************


instruction "*** Go to GG1_PT4", skip


'********** ISO speed targets **********

note "1- Set ISO GG speed and ISO PT speed targets"
result "Setting ISO GG1 speed and ISO PT1 speed targets..."
set_channel GG_PT_Selector, 4
do_fullset 0
result "Going to GG speed ISO target = " &cv_GG_Target_ISO &" rpm and PT speed ISO target = " &cv_PT_Target_ISO &" rpm", REPORT & "Set Point", BLACK
delay 5


'********** Mechanical PT speed targets **********

note "2- Estimate Mechanical PT Speed target"
result "Estimating Mechanical PT Speed target ..."
do_fullset 0
result "     * Estimated PT speed target = " &cv_PT_Target &" rpm", REPORT & "Set Point", BLUE
delay 5


'********** Send Mechanical PT speed set point to FCS **********

note "3- Send Mechanical PT speed set point to FCS"
result "Sending Mechanical PT speed set point to FCS..."
set_channel FCS_N_PT_Set_Cmd, cv_PT_Target
result "Speed set point to FCS sent."


'********** Wait for GT Engine to reach ISO PT speed target **********

note "4- Wait GT Engine to reach ISO PT speed target"
result "Waiting GT Engine to reach ISO PT speed target..."
wait "N_PT_ISO = " &cv_PT_Target_ISO, 300, 5, TOC, 5, "Timout", SKIP, "PT is out of range"
result "Speed target monitoring completed."

'********** Buzzer indication **********

note "5- Buzzer"
result "Buzzing..."
set_channel Buzzer_Enable_SW, 1
delay 1
set_channel Buzzer_Enable_SW, 0
result "Buzzer OFF"


'********** Stabilization duration **********

note "6- Stabilization"
result "Stabilizing..."
set_channel Stabilization_Status, 1
result "Stabilizing - Minimum 3 minutes ...", REPORT & "Stabilization", BLACK
delay 240
result "Stabilization completed", REPORT & "Stabilization", GREEN
set_channel Stabilization_Status, 0
result "Stabilization completed."


'********** Fullset recording **********

note "7- Record Steady-State measurement (fullset)"
result "Recording Steady-State measurement (fullset)..."
set_channel Recording_Status, 1
delay 1
do_fullset 10, "Thermodynamic measurement: N_GG1 N_PT4", "GG1_PT4"
result "A steady-state measurement has been taken automatically", REPORT & "Fullset", BLACK
result "     * GG speed ISO =" &fv_N_GG_ISO &" rpm", REPORT & "Fullset", BLUE
result "         ** GG target offset =" &FormatNumber(fv_N_GG_ISO-fv_GG_Target_ISO,0) & " rpm", REPORT & "Fullset", RED
result "     * GG speed ISO =" &fv_N_PT_ISO &" rpm", REPORT & "Fullset", BLUE
result "         ** GG target offset =" &FormatNumber(fv_N_PT_ISO-fv_PT_Target_ISO,0) & " rpm", REPORT & "Fullset", RED
result "     * Power ISO =" &fv_Pow_ISO &" kW", REPORT & "Fullset", BLUE
result "     * Efficiency ISO =" &fv_Eta_ISO &" %", REPORT & "Fullset", BLUE
result "     * T4 ISO =" &fv_T4_ISO &" degC", REPORT & "Fullset", BLUE
set_channel Recording_Status, 0
result "Fullset recording completed."


'********** Point completed **********

note "8- Point completed"
set_channel PointCompleted_Status, 1
delay 5
result "Thermodynamic measurement GG1_PT4 completed", REPORT & "Fullset", GREEN
set_channel PointCompleted_Status, 0
result " ", REPORT
result " ", REPORT



'******************************************************************************
'************************************ TO GG2 PT1 ******************************done
'******************************************************************************


caution "-- GG2 Curve --"
instruction "*** Go to GG2_PT1", skip


'********** ISO speed targets **********

note "1- Set ISO GG speed and ISO PT speed targets"
result "Setting ISO GG1 speed and ISO PT1 speed targets..."
set_channel GG_PT_Selector, 5
do_fullset 0
result "Going to GG speed ISO target = " &cv_GG_Target_ISO &" rpm and PT speed ISO target = " &cv_PT_Target_ISO &" rpm", REPORT & "Set Point", BLACK
delay 5


'********** Mechanical speed targets **********

note "2- Estimate Mechanical GG Speed and PT Speed targets"
result "Estimating Mechanical GG Speed and PT Speed targets ..."
do_fullset 0
result "     * Estimated GG speed target = " &cv_GG_Target &" rpm", REPORT & "Set Point", BLUE
result "     * Estimated PT speed target = " &cv_PT_Target &" rpm", REPORT & "Set Point", BLUE
delay 5


'********** Send Mechanical speed set points to FCS **********

note "3- Send Mechanical speed set points to FCS"
result "Sending Mechanical speed set points to FCS..."
set_channel FCS_N_GG_Set_Cmd, cv_GG_Target
delay 5
set_channel FCS_N_PT_Set_Cmd, cv_PT_Target
result "Speed set points to FCS sent."


'********** Wait for GT Engine to reach ISO speed targets **********

note "4- Wait GT Engine to reach ISO speed targets"
result "Waiting GT Engine to reach ISO speed targets..."
wait "N_GG_ISO = " &cv_GG_Target_ISO, 300, 5, TOC, 5, "Timout", SKIP, "GG is out of range"
wait "N_PT_ISO = " &cv_PT_Target_ISO, 300, 5, TOC, 5, "Timout", SKIP, "PT is out of range"
result "Speed target monitoring completed."

'********** Buzzer indication **********

note "5- Buzzer"
result "Buzzing..."
set_channel Buzzer_Enable_SW, 1
delay 1
set_channel Buzzer_Enable_SW, 0
result "Buzzer OFF"


'********** Stabilization duration **********

note "6- Stabilization"
result "Stabilizing..."
set_channel Stabilization_Status, 1
result "Stabilizing - Minimum 15 minutes ...", REPORT & "Stabilization", BLACK
delay 600
result "10 minutes completed.", REPORT & "Stabilization", BLACK
result "5 more minutes ...", REPORT & "Stabilization", BLACK
delay 300
result "Stabilization completed", REPORT & "Stabilization", GREEN
set_channel Stabilization_Status, 0
result "Stabilization completed."


'********** Fullset recording **********

note "7- Record Steady-State measurement (fullset)"
result "Recording Steady-State measurement (fullset)..."
set_channel Recording_Status, 1
delay 1
do_fullset 10, "Thermodynamic measurement: N_GG2 N_PT1", "GG2_PT1"
result "A steady-state measurement has been taken automatically", REPORT & "Fullset", BLACK
result "     * GG speed ISO =" &fv_N_GG_ISO &" rpm", REPORT & "Fullset", BLUE
result "         ** GG target offset =" &FormatNumber(fv_N_GG_ISO-fv_GG_Target_ISO,0) & " rpm", REPORT & "Fullset", RED
result "     * GG speed ISO =" &fv_N_PT_ISO &" rpm", REPORT & "Fullset", BLUE
result "         ** GG target offset =" &FormatNumber(fv_N_PT_ISO-fv_PT_Target_ISO,0) & " rpm", REPORT & "Fullset", RED
result "     * Power ISO =" &fv_Pow_ISO &" kW", REPORT & "Fullset", BLUE
result "     * Efficiency ISO =" &fv_Eta_ISO &" %", REPORT & "Fullset", BLUE
result "     * T4 ISO =" &fv_T4_ISO &" degC", REPORT & "Fullset", BLUE
set_channel Recording_Status, 0
result "Fullset recording completed."


'********** Point completed **********

note "8- Point completed"
set_channel PointCompleted_Status, 1
delay 5
result "Thermodynamic measurement GG2_PT1 completed", REPORT & "Fullset", GREEN
set_channel PointCompleted_Status, 0
result " ", REPORT
result " ", REPORT



'******************************************************************************
'************************************ TO GG2 PT2 ******************************done
'******************************************************************************


instruction "*** Go to GG2_PT2", skip


'********** ISO speed targets **********

note "1- Set ISO GG speed and ISO PT speed targets"
result "Setting ISO GG1 speed and ISO PT1 speed targets..."
set_channel GG_PT_Selector, 6
do_fullset 0
result "Going to GG speed ISO target = " &cv_GG_Target_ISO &" rpm and PT speed ISO target = " &cv_PT_Target_ISO &" rpm", REPORT & "Set Point", BLACK
delay 5


'********** Mechanical PT speed targets **********

note "2- Estimate Mechanical PT Speed target"
result "Estimating Mechanical PT Speed target ..."
do_fullset 0
result "     * Estimated PT speed target = " &cv_PT_Target &" rpm", REPORT & "Set Point", BLUE
delay 5


'********** Send Mechanical PT speed set point to FCS **********

note "3- Send Mechanical PT speed set point to FCS"
result "Sending Mechanical PT speed set point to FCS..."
set_channel FCS_N_PT_Set_Cmd, cv_PT_Target
result "Speed set point to FCS sent."


'********** Wait for GT Engine to reach ISO PT speed target **********

note "4- Wait GT Engine to reach ISO PT speed target"
result "Waiting GT Engine to reach ISO PT speed target..."
wait "N_PT_ISO = " &cv_PT_Target_ISO, 300, 5, TOC, 5, "Timout", SKIP, "PT is out of range"
result "Speed target monitoring completed."

'********** Buzzer indication **********

note "5- Buzzer"
result "Buzzing..."
set_channel Buzzer_Enable_SW, 1
delay 1
set_channel Buzzer_Enable_SW, 0
result "Buzzer OFF"


'********** Stabilization duration **********

note "6- Stabilization"
result "Stabilizing..."
set_channel Stabilization_Status, 1
result "Stabilizing - Minimum 3 minutes ...", REPORT & "Stabilization", BLACK
delay 240
result "Stabilization completed", REPORT & "Stabilization", GREEN
set_channel Stabilization_Status, 0
result "Stabilization completed."


'********** Fullset recording **********

note "7- Record Steady-State measurement (fullset)"
result "Recording Steady-State measurement (fullset)..."
set_channel Recording_Status, 1
delay 1
do_fullset 10, "Thermodynamic measurement: N_GG2 N_PT2", "GG2_PT2"
result "A steady-state measurement has been taken automatically", REPORT & "Fullset", BLACK
result "     * GG speed ISO =" &fv_N_GG_ISO &" rpm", REPORT & "Fullset", BLUE
result "         ** GG target offset =" &FormatNumber(fv_N_GG_ISO-fv_GG_Target_ISO,0) & " rpm", REPORT & "Fullset", RED
result "     * GG speed ISO =" &fv_N_PT_ISO &" rpm", REPORT & "Fullset", BLUE
result "         ** GG target offset =" &FormatNumber(fv_N_PT_ISO-fv_PT_Target_ISO,0) & " rpm", REPORT & "Fullset", RED
result "     * Power ISO =" &fv_Pow_ISO &" kW", REPORT & "Fullset", BLUE
result "     * Efficiency ISO =" &fv_Eta_ISO &" %", REPORT & "Fullset", BLUE
result "     * T4 ISO =" &fv_T4_ISO &" degC", REPORT & "Fullset", BLUE
set_channel Recording_Status, 0
result "Fullset recording completed."


'********** Point completed **********

note "8- Point completed"
set_channel PointCompleted_Status, 1
delay 5
result "Thermodynamic measurement GG1_PT4 completed", REPORT & "Fullset", GREEN
set_channel PointCompleted_Status, 0
result " ", REPORT
result " ", REPORT



'******************************************************************************
'************************************ TO GG2 PT3 ******************************done
'******************************************************************************


instruction "*** Go to GG2_PT3", skip


'********** ISO speed targets **********

note "1- Set ISO GG speed and ISO PT speed targets"
result "Setting ISO GG1 speed and ISO PT1 speed targets..."
set_channel GG_PT_Selector, 7
do_fullset 0
result "Going to GG speed ISO target = " &cv_GG_Target_ISO &" rpm and PT speed ISO target = " &cv_PT_Target_ISO &" rpm", REPORT & "Set Point", BLACK
delay 5


'********** Mechanical PT speed targets **********

note "2- Estimate Mechanical PT Speed target"
result "Estimating Mechanical PT Speed target ..."
do_fullset 0
result "     * Estimated PT speed target = " &cv_PT_Target &" rpm", REPORT & "Set Point", BLUE
delay 5


'********** Send Mechanical PT speed set point to FCS **********

note "3- Send Mechanical PT speed set point to FCS"
result "Sending Mechanical PT speed set point to FCS..."
set_channel FCS_N_PT_Set_Cmd, cv_PT_Target
result "Speed set point to FCS sent."


'********** Wait for GT Engine to reach ISO PT speed target **********

note "4- Wait GT Engine to reach ISO PT speed target"
result "Waiting GT Engine to reach ISO PT speed target..."
wait "N_PT_ISO = " &cv_PT_Target_ISO, 300, 5, TOC, 5, "Timout", SKIP, "PT is out of range"
result "Speed target monitoring completed."

'********** Buzzer indication **********

note "5- Buzzer"
result "Buzzing..."
set_channel Buzzer_Enable_SW, 1
delay 1
set_channel Buzzer_Enable_SW, 0
result "Buzzer OFF"


'********** Stabilization duration **********

note "6- Stabilization"
result "Stabilizing..."
set_channel Stabilization_Status, 1
result "Stabilizing - Minimum 3 minutes ...", REPORT & "Stabilization", BLACK
delay 240
result "Stabilization completed", REPORT & "Stabilization", GREEN
set_channel Stabilization_Status, 0
result "Stabilization completed."


'********** Fullset recording **********

note "7- Record Steady-State measurement (fullset)"
result "Recording Steady-State measurement (fullset)..."
set_channel Recording_Status, 1
delay 1
do_fullset 10, "Thermodynamic measurement: N_GG2 N_PT3", "GG2_PT3"
result "A steady-state measurement has been taken automatically", REPORT & "Fullset", BLACK
result "     * GG speed ISO =" &fv_N_GG_ISO &" rpm", REPORT & "Fullset", BLUE
result "         ** GG target offset =" &FormatNumber(fv_N_GG_ISO-fv_GG_Target_ISO,0) & " rpm", REPORT & "Fullset", RED
result "     * GG speed ISO =" &fv_N_PT_ISO &" rpm", REPORT & "Fullset", BLUE
result "         ** GG target offset =" &FormatNumber(fv_N_PT_ISO-fv_PT_Target_ISO,0) & " rpm", REPORT & "Fullset", RED
result "     * Power ISO =" &fv_Pow_ISO &" kW", REPORT & "Fullset", BLUE
result "     * Efficiency ISO =" &fv_Eta_ISO &" %", REPORT & "Fullset", BLUE
result "     * T4 ISO =" &fv_T4_ISO &" degC", REPORT & "Fullset", BLUE
set_channel Recording_Status, 0
result "Fullset recording completed."


'********** Point completed **********

note "8- Point completed"
set_channel PointCompleted_Status, 1
delay 5
result "Thermodynamic measurement GG2_PT3 completed", REPORT & "Fullset", GREEN
set_channel PointCompleted_Status, 0
result " ", REPORT
result " ", REPORT



'******************************************************************************
'************************************ TO GG3 PT1 ******************************done
'******************************************************************************


caution "-- GG3 Curve --"
instruction "*** Go to GG3_PT1", skip


'********** ISO speed targets **********

note "1- Set ISO GG speed and ISO PT speed targets"
result "Setting ISO GG1 speed and ISO PT1 speed targets..."
set_channel GG_PT_Selector, 8
do_fullset 0
result "Going to GG speed ISO target = " &cv_GG_Target_ISO &" rpm and PT speed ISO target = " &cv_PT_Target_ISO &" rpm", REPORT & "Set Point", BLACK
delay 5


'********** Mechanical speed targets **********

note "2- Estimate Mechanical GG Speed and PT Speed targets"
result "Estimating Mechanical GG Speed and PT Speed targets ..."
do_fullset 0
result "     * Estimated GG speed target = " &cv_GG_Target &" rpm", REPORT & "Set Point", BLUE
result "     * Estimated PT speed target = " &cv_PT_Target &" rpm", REPORT & "Set Point", BLUE
delay 5


'********** Send Mechanical speed set points to FCS **********

note "3- Send Mechanical speed set points to FCS"
result "Sending Mechanical speed set points to FCS..."
set_channel FCS_N_GG_Set_Cmd, cv_GG_Target
delay 5
set_channel FCS_N_PT_Set_Cmd, cv_PT_Target
result "Speed set points to FCS sent."


'********** Wait for GT Engine to reach ISO speed targets **********

note "4- Wait GT Engine to reach ISO speed targets"
result "Waiting GT Engine to reach ISO speed targets..."
wait "N_GG_ISO = " &cv_GG_Target_ISO, 300, 5, TOC, 5, "Timout", SKIP, "GG is out of range"
wait "N_PT_ISO = " &cv_PT_Target_ISO, 300, 5, TOC, 5, "Timout", SKIP, "PT is out of range"
result "Speed target monitoring completed."

'********** Buzzer indication **********

note "5- Buzzer"
result "Buzzing..."
set_channel Buzzer_Enable_SW, 1
delay 1
set_channel Buzzer_Enable_SW, 0
result "Buzzer OFF"


'********** Stabilization duration **********

note "6- Stabilization"
result "Stabilizing..."
set_channel Stabilization_Status, 1
result "Stabilizing - Minimum 15 minutes ...", REPORT & "Stabilization", BLACK
delay 600
result "10 minutes completed.", REPORT & "Stabilization", BLACK
result "5 more minutes ...", REPORT & "Stabilization", BLACK
delay 300
result "Stabilization completed", REPORT & "Stabilization", GREEN
set_channel Stabilization_Status, 0
result "Stabilization completed."


'********** Fullset recording **********

note "7- Record Steady-State measurement (fullset)"
result "Recording Steady-State measurement (fullset)..."
set_channel Recording_Status, 1
delay 1
do_fullset 10, "Thermodynamic measurement: N_GG3 N_PT1", "GG1_PT1"
result "A steady-state measurement has been taken automatically", REPORT & "Fullset", BLACK
result "     * GG speed ISO =" &fv_N_GG_ISO &" rpm", REPORT & "Fullset", BLUE
result "         ** GG target offset =" &FormatNumber(fv_N_GG_ISO-fv_GG_Target_ISO,0) & " rpm", REPORT & "Fullset", RED
result "     * GG speed ISO =" &fv_N_PT_ISO &" rpm", REPORT & "Fullset", BLUE
result "         ** GG target offset =" &FormatNumber(fv_N_PT_ISO-fv_PT_Target_ISO,0) & " rpm", REPORT & "Fullset", RED
result "     * Power ISO =" &fv_Pow_ISO &" kW", REPORT & "Fullset", BLUE
result "     * Efficiency ISO =" &fv_Eta_ISO &" %", REPORT & "Fullset", BLUE
result "     * T4 ISO =" &fv_T4_ISO &" degC", REPORT & "Fullset", BLUE
set_channel Recording_Status, 0
result "Fullset recording completed."


'********** Point completed **********

note "8- Point completed"
set_channel PointCompleted_Status, 1
delay 5
result "Thermodynamic measurement GG3_PT1 completed", REPORT & "Fullset", GREEN
set_channel PointCompleted_Status, 0
result " ", REPORT
result " ", REPORT



'******************************************************************************
'************************************ TO GG3 PT2 ******************************xxx
'******************************************************************************


instruction "*** Go to GG3_PT2", skip


'********** ISO speed targets **********

note "1- Set ISO GG speed and ISO PT speed targets"
result "Setting ISO GG1 speed and ISO PT1 speed targets..."
set_channel GG_PT_Selector, 9
do_fullset 0
result "Going to GG speed ISO target = " &cv_GG_Target_ISO &" rpm and PT speed ISO target = " &cv_PT_Target_ISO &" rpm", REPORT & "Set Point", BLACK
delay 5


'********** Mechanical PT speed targets **********

note "2- Estimate Mechanical PT Speed target"
result "Estimating Mechanical PT Speed target ..."
do_fullset 0
result "     * Estimated PT speed target = " &cv_PT_Target &" rpm", REPORT & "Set Point", BLUE
delay 5


'********** Send Mechanical PT speed set point to FCS **********

note "3- Send Mechanical PT speed set point to FCS"
result "Sending Mechanical PT speed set point to FCS..."
set_channel FCS_N_PT_Set_Cmd, cv_PT_Target
result "Speed set point to FCS sent."


'********** Wait for GT Engine to reach ISO PT speed target **********

note "4- Wait GT Engine to reach ISO PT speed target"
result "Waiting GT Engine to reach ISO PT speed target..."
wait "N_PT_ISO = " &cv_PT_Target_ISO, 300, 5, TOC, 5, "Timout", SKIP, "PT is out of range"
result "Speed target monitoring completed."

'********** Buzzer indication **********

note "5- Buzzer"
result "Buzzing..."
set_channel Buzzer_Enable_SW, 1
delay 1
set_channel Buzzer_Enable_SW, 0
result "Buzzer OFF"


'********** Stabilization duration **********

note "6- Stabilization"
result "Stabilizing..."
set_channel Stabilization_Status, 1
result "Stabilizing - Minimum 3 minutes ...", REPORT & "Stabilization", BLACK
delay 240
result "Stabilization completed", REPORT & "Stabilization", GREEN
set_channel Stabilization_Status, 0
result "Stabilization completed."


'********** Fullset recording **********

note "7- Record Steady-State measurement (fullset)"
result "Recording Steady-State measurement (fullset)..."
set_channel Recording_Status, 1
delay 1
do_fullset 10, "Thermodynamic measurement: N_GG3 N_PT2", "GG3_PT2"
result "A steady-state measurement has been taken automatically", REPORT & "Fullset", BLACK
result "     * GG speed ISO =" &fv_N_GG_ISO &" rpm", REPORT & "Fullset", BLUE
result "         ** GG target offset =" &FormatNumber(fv_N_GG_ISO-fv_GG_Target_ISO,0) & " rpm", REPORT & "Fullset", RED
result "     * GG speed ISO =" &fv_N_PT_ISO &" rpm", REPORT & "Fullset", BLUE
result "         ** GG target offset =" &FormatNumber(fv_N_PT_ISO-fv_PT_Target_ISO,0) & " rpm", REPORT & "Fullset", RED
result "     * Power ISO =" &fv_Pow_ISO &" kW", REPORT & "Fullset", BLUE
result "     * Efficiency ISO =" &fv_Eta_ISO &" %", REPORT & "Fullset", BLUE
result "     * T4 ISO =" &fv_T4_ISO &" degC", REPORT & "Fullset", BLUE
set_channel Recording_Status, 0
result "Fullset recording completed."


'********** Point completed **********

note "8- Point completed"
set_channel PointCompleted_Status, 1
delay 5
result "Thermodynamic measurement GG3_PT2 completed", REPORT & "Fullset", GREEN
set_channel PointCompleted_Status, 0
result " ", REPORT
result " ", REPORT



'******************************************************************************
'************************************ TO GG3 PT3 ******************************xxx
'******************************************************************************


instruction "*** Go to GG3_PT3", skip


'********** ISO speed targets **********

note "1- Set ISO GG speed and ISO PT speed targets"
result "Setting ISO GG1 speed and ISO PT1 speed targets..."
set_channel GG_PT_Selector, 10
do_fullset 0
result "Going to GG speed ISO target = " &cv_GG_Target_ISO &" rpm and PT speed ISO target = " &cv_PT_Target_ISO &" rpm", REPORT & "Set Point", BLACK
delay 5


'********** Mechanical PT speed targets **********

note "2- Estimate Mechanical PT Speed target"
result "Estimating Mechanical PT Speed target ..."
do_fullset 0
result "     * Estimated PT speed target = " &cv_PT_Target &" rpm", REPORT & "Set Point", BLUE
delay 5


'********** Send Mechanical PT speed set point to FCS **********

note "3- Send Mechanical PT speed set point to FCS"
result "Sending Mechanical PT speed set point to FCS..."
set_channel FCS_N_PT_Set_Cmd, cv_PT_Target
result "Speed set point to FCS sent."


'********** Wait for GT Engine to reach ISO PT speed target **********

note "4- Wait GT Engine to reach ISO PT speed target"
result "Waiting GT Engine to reach ISO PT speed target..."
wait "N_PT_ISO = " &cv_PT_Target_ISO, 300, 5, TOC, 5, "Timout", SKIP, "PT is out of range"
result "Speed target monitoring completed."

'********** Buzzer indication **********

note "5- Buzzer"
result "Buzzing..."
set_channel Buzzer_Enable_SW, 1
delay 1
set_channel Buzzer_Enable_SW, 0
result "Buzzer OFF"


'********** Stabilization duration **********

note "6- Stabilization"
result "Stabilizing..."
set_channel Stabilization_Status, 1
result "Stabilizing - Minimum 3 minutes ...", REPORT & "Stabilization", BLACK
delay 240
result "Stabilization completed", REPORT & "Stabilization", GREEN
set_channel Stabilization_Status, 0
result "Stabilization completed."


'********** Fullset recording **********

note "7- Record Steady-State measurement (fullset)"
result "Recording Steady-State measurement (fullset)..."
set_channel Recording_Status, 1
delay 1
do_fullset 10, "Thermodynamic measurement: N_GG3 N_PT3", "GG3_PT3"
result "A steady-state measurement has been taken automatically", REPORT & "Fullset", BLACK
result "     * GG speed ISO =" &fv_N_GG_ISO &" rpm", REPORT & "Fullset", BLUE
result "         ** GG target offset =" &FormatNumber(fv_N_GG_ISO-fv_GG_Target_ISO,0) & " rpm", REPORT & "Fullset", RED
result "     * GG speed ISO =" &fv_N_PT_ISO &" rpm", REPORT & "Fullset", BLUE
result "         ** GG target offset =" &FormatNumber(fv_N_PT_ISO-fv_PT_Target_ISO,0) & " rpm", REPORT & "Fullset", RED
result "     * Power ISO =" &fv_Pow_ISO &" kW", REPORT & "Fullset", BLUE
result "     * Efficiency ISO =" &fv_Eta_ISO &" %", REPORT & "Fullset", BLUE
result "     * T4 ISO =" &fv_T4_ISO &" degC", REPORT & "Fullset", BLUE
set_channel Recording_Status, 0
result "Fullset recording completed."


'********** Point completed **********

note "8- Point completed"
set_channel PointCompleted_Status, 1
delay 5
result "Thermodynamic measurement GG3_PT3 completed", REPORT & "Fullset", GREEN
set_channel PointCompleted_Status, 0
result " ", REPORT
result " ", REPORT



'******************************************************************************
'************************************ TO GG3 PT4 ******************************xxx
'******************************************************************************


instruction "*** Go to GG3_PT4", skip


'********** ISO speed targets **********

note "1- Set ISO GG speed and ISO PT speed targets"
result "Setting ISO GG1 speed and ISO PT1 speed targets..."
set_channel GG_PT_Selector, 11
do_fullset 0
result "Going to GG speed ISO target = " &cv_GG_Target_ISO &" rpm and PT speed ISO target = " &cv_PT_Target_ISO &" rpm", REPORT & "Set Point", BLACK
delay 5


'********** Mechanical PT speed targets **********

note "2- Estimate Mechanical PT Speed target"
result "Estimating Mechanical PT Speed target ..."
do_fullset 0
result "     * Estimated PT speed target = " &cv_PT_Target &" rpm", REPORT & "Set Point", BLUE
delay 5


'********** Send Mechanical PT speed set point to FCS **********

note "3- Send Mechanical PT speed set point to FCS"
result "Sending Mechanical PT speed set point to FCS..."
set_channel FCS_N_PT_Set_Cmd, cv_PT_Target
result "Speed set point to FCS sent."


'********** Wait for GT Engine to reach ISO PT speed target **********

note "4- Wait GT Engine to reach ISO PT speed target"
result "Waiting GT Engine to reach ISO PT speed target..."
wait "N_PT_ISO = " &cv_PT_Target_ISO, 300, 5, TOC, 5, "Timout", SKIP, "PT is out of range"
result "Speed target monitoring completed."

'********** Buzzer indication **********

note "5- Buzzer"
result "Buzzing..."
set_channel Buzzer_Enable_SW, 1
delay 1
set_channel Buzzer_Enable_SW, 0
result "Buzzer OFF"


'********** Stabilization duration **********

note "6- Stabilization"
result "Stabilizing..."
set_channel Stabilization_Status, 1
result "Stabilizing - Minimum 3 minutes ...", REPORT & "Stabilization", BLACK
delay 240
result "Stabilization completed", REPORT & "Stabilization", GREEN
set_channel Stabilization_Status, 0
result "Stabilization completed."


'********** Fullset recording **********

note "7- Record Steady-State measurement (fullset)"
result "Recording Steady-State measurement (fullset)..."
set_channel Recording_Status, 1
delay 1
do_fullset 10, "Thermodynamic measurement: N_GG3 N_PT4", "GG3_PT4"
result "A steady-state measurement has been taken automatically", REPORT & "Fullset", BLACK
result "     * GG speed ISO =" &fv_N_GG_ISO &" rpm", REPORT & "Fullset", BLUE
result "         ** GG target offset =" &FormatNumber(fv_N_GG_ISO-fv_GG_Target_ISO,0) & " rpm", REPORT & "Fullset", RED
result "     * GG speed ISO =" &fv_N_PT_ISO &" rpm", REPORT & "Fullset", BLUE
result "         ** GG target offset =" &FormatNumber(fv_N_PT_ISO-fv_PT_Target_ISO,0) & " rpm", REPORT & "Fullset", RED
result "     * Power ISO =" &fv_Pow_ISO &" kW", REPORT & "Fullset", BLUE
result "     * Efficiency ISO =" &fv_Eta_ISO &" %", REPORT & "Fullset", BLUE
result "     * T4 ISO =" &fv_T4_ISO &" degC", REPORT & "Fullset", BLUE
set_channel Recording_Status, 0
result "Fullset recording completed."


'********** Point completed **********

note "8- Point completed"
set_channel PointCompleted_Status, 1
delay 5
result "Thermodynamic measurement GG3_PT4 completed", REPORT & "Fullset", GREEN
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

