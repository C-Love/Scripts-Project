'PLEASE NOTE: this script was designed to run off of the BULK - pull data into Excel script.
'As such, it might not work if ran separately from that.

'STATS GATHERING----------------------------------------------------------------------------------------------------
name_of_script = "BULK - Case Transfer.vbs"
start_time = timer

'LOADING FUNCTIONS LIBRARY FROM GITHUB REPOSITORY===========================================================================
IF IsEmpty(FuncLib_URL) = TRUE THEN	'Shouldn't load FuncLib if it already loaded once
	IF run_locally = FALSE or run_locally = "" THEN		'If the scripts are set to run locally, it skips this and uses an FSO below.
		IF use_master_branch = TRUE THEN			'If the default_directory is C:\DHS-MAXIS-Scripts\Script Files, you're probably a scriptwriter and should use the master branch.
			FuncLib_URL = "https://raw.githubusercontent.com/MN-Script-Team/BZS-FuncLib/master/MASTER%20FUNCTIONS%20LIBRARY.vbs"
		Else																		'Everyone else should use the release branch.
			FuncLib_URL = "https://raw.githubusercontent.com/MN-Script-Team/BZS-FuncLib/RELEASE/MASTER%20FUNCTIONS%20LIBRARY.vbs"
		End if
		SET req = CreateObject("Msxml2.XMLHttp.6.0")				'Creates an object to get a FuncLib_URL
		req.open "GET", FuncLib_URL, FALSE							'Attempts to open the FuncLib_URL
		req.send													'Sends request
		IF req.Status = 200 THEN									'200 means great success
			Set fso = CreateObject("Scripting.FileSystemObject")	'Creates an FSO
			Execute req.responseText								'Executes the script code
		ELSE														'Error message, tells user to try to reach github.com, otherwise instructs to contact Veronica with details (and stops script).
			MsgBox 	"Something has gone wrong. The code stored on GitHub was not able to be reached." & vbCr &_
					vbCr & _
					"Before contacting Veronica Cary, please check to make sure you can load the main page at www.GitHub.com." & vbCr &_
					vbCr & _
					"If you can reach GitHub.com, but this script still does not work, ask an alpha user to contact Veronica Cary and provide the following information:" & vbCr &_
					vbTab & "- The name of the script you are running." & vbCr &_
					vbTab & "- Whether or not the script is ""erroring out"" for any other users." & vbCr &_
					vbTab & "- The name and email for an employee from your IT department," & vbCr & _
					vbTab & vbTab & "responsible for network issues." & vbCr &_
					vbTab & "- The URL indicated below (a screenshot should suffice)." & vbCr &_
					vbCr & _
					"Veronica will work with your IT department to try and solve this issue, if needed." & vbCr &_
					vbCr &_
					"URL: " & FuncLib_URL
					script_end_procedure("Script ended due to error connecting to GitHub.")
		END IF
	ELSE
		FuncLib_URL = "C:\BZS-FuncLib\MASTER FUNCTIONS LIBRARY.vbs"
		Set run_another_script_fso = CreateObject("Scripting.FileSystemObject")
		Set fso_command = run_another_script_fso.OpenTextFile(FuncLib_URL)
		text_from_the_other_script = fso_command.ReadAll
		fso_command.Close
		Execute text_from_the_other_script
	END IF
END IF
'END FUNCTIONS LIBRARY BLOCK================================================================================================

'DIALOGS----------------------------------------------------------------------
BeginDialog select_parameters_data_into_excel, 0, 0, 376, 365, "Select Parameters for Cases to Transfer"
  EditBox 75, 20, 130, 15, worker_number
  CheckBox 5, 80, 170, 10, "Exclude all cases with any Pending Program", exclude_pending_check
  CheckBox 5, 95, 120, 10, "Exclude all cases with IEVS DAILs", exclude_ievs_check
  CheckBox 140, 95, 120, 10, "Exclude all cases with PARIS DAILs", exclude_paris_check
  CheckBox 5, 115, 40, 10, "SNAP", SNAP_check
  CheckBox 90, 115, 90, 10, "Exclude all SNAP cases", exclude_snap_check
  CheckBox 190, 115, 75, 10, "SNAP ONLY cases", SNAP_Only_check
  CheckBox 15, 140, 60, 10, "ABAWD cases", SNAP_ABAWD_check
  CheckBox 90, 140, 90, 10, "Uncle Harry SNAP", SNAP_UH_check
  CheckBox 5, 160, 25, 10, "GA", ga_check
  CheckBox 40, 160, 30, 10, "MSA", msa_check
  CheckBox 90, 160, 100, 10, "Exclude all GA/MSA cases", exclude_ga_msa_check
  CheckBox 5, 175, 25, 10, "RCA", rca_check
  CheckBox 90, 175, 90, 10, "Exclude all RCA cases", exclude_RCA_check
  CheckBox 5, 190, 30, 10, "MFIP", mfip_check
  CheckBox 40, 190, 30, 10, "DWP", DWP_check
  CheckBox 90, 190, 95, 10, "Exclude all MFIP/DWP", exclude_mfip_dwp_check
  CheckBox 190, 190, 70, 10, "MFIP ONLY cases", MFIP_Only_check
  CheckBox 15, 220, 90, 10, "MFIP cases with at least", MFIP_tanf_check
  EditBox 105, 215, 20, 15, tanf_months
  CheckBox 15, 235, 85, 10, "Child Only MFIP cases", child_only_mfip_check
  CheckBox 5, 255, 40, 10, "GRH", GRH_check
  CheckBox 90, 255, 75, 10, "Exclude GRH cases", exclude_grh_check
  CheckBox 190, 255, 75, 10, "GRH ONLY cases", GRH_Only_check
  CheckBox 5, 270, 65, 10, "EA/EGA Pending", EA_check
  CheckBox 90, 270, 95, 10, "Exclude EA/EGA Pending", exclude_ea_check
  CheckBox 5, 285, 40, 10, "HC", HC_check
  CheckBox 90, 285, 75, 10, "Exclude HC cases", exclude_HC_check
  CheckBox 190, 285, 75, 10, "HC ONLY cases", HC_Only_check
  CheckBox 15, 305, 120, 10, "Medicare Savings Program Active", HC_msp_check
  CheckBox 15, 320, 40, 10, "Adult MA", adult_hc_check
  CheckBox 90, 320, 45, 10, "Family MA", family_hc_check
  CheckBox 15, 335, 40, 10, "LTC HC", ltc_HC_check
  CheckBox 90, 335, 50, 10, "Waiver HC", waiver_HC_check
  ButtonGroup ButtonPressed
    OkButton 270, 345, 50, 15
    CancelButton 325, 345, 50, 15
  Text 65, 5, 100, 10, "***Case Parameters to Pull***"
  Text 5, 25, 65, 10, "Worker(s) to check:"
  Text 5, 40, 210, 20, "Enter last 3 digits of your workers' x1 numbers (ex: x100###), separated by a comma."
  Text 5, 65, 150, 10, "What type of cases do you want to transfer?"
  GroupBox 10, 125, 190, 30, "SNAP Details"
  GroupBox 10, 205, 190, 45, "MFIP Details"
  GroupBox 10, 295, 190, 55, "HC Details"
  Text 215, 10, 155, 40, "Select the criteria you want the script to sort by. The script will then generate an Excel Spreadsheet of all the cases in the indicated worker number(s) that meet your selected criteria."
  Text 215, 60, 155, 25, "Another Pop Up will allow you select your transfer options before actually transferring cases."
  Text 130, 220, 65, 10, "TANF Months used."
  GroupBox 275, 95, 95, 240, "Hints"
  Text 280, 110, 85, 25, "Use 'Tab' to move between check boxes without your mouse."
  Text 280, 140, 85, 25, "Use the Spacebar to check and uncheck boxes without your mouse"
EndDialog

BeginDialog case_transfer_dialog, 0, 0, 306, 105, "Select Transfer Options"
  CheckBox 5, 30, 130, 10, "Check here to have the script transfer", transfer_check
  EditBox 140, 25, 20, 15, number_of_cases_to_transfer
  EditBox 225, 25, 80, 15, worker_receiving_cases
  CheckBox 5, 50, 185, 10, "Check here to have a case note entered for each case", Check2
  CheckBox 5, 65, 185, 10, "Check here to have a MEMO sent for each case", Check3
  ButtonGroup ButtonPressed
    OkButton 195, 85, 50, 15
    CancelButton 250, 85, 50, 15
  Text 5, 10, 55, 10, "The script found"
  Text 65, 10, 20, 10, cases_found 
  Text 90, 10, 130, 10, "cases that meet your selected criteria"
  Text 165, 30, 60, 10, "of these cases to:"
  Text 220, 40, 85, 20, "Enter the last 3 digits of a worker's X1***** number"
EndDialog


'THE SCRIPT-------------------------------------------------------------------------

'Determining specific county for multicounty agencies...
CALL worker_county_code_determination(worker_county_code, two_digit_county_code)

'Connects to BlueZone
EMConnect ""

'Shows dialogDialog pull_rept_data_into_Excel_dialog
Do	
	Do 
		Dialog select_parameters_data_into_excel
		cancel_confirmation
		err_msg = ""
		IF worker_number = "" then err_msg = err_msg & vbCr & "You must Select an X-Number to pull cases from."
		IF snap_check = unchecked AND mfip_check = unchecked AND DWP_check = unchecked AND EA_check = unchecked AND HC_check = unchecked AND ga_check = unchecked AND msa_check = unchecked AND GRH_check = unchecked Then err_msg = err_msg & vbCr & "You must select a type of program for the cases you want to transfer, please pick one - SNAP, MFIP, DWP, EA, HC, GA, MSA, or GRH"
		IF err_msg <> "" THEN MsgBox "*** NOTICE!!! ***" & vbCr & err_msg & vbCr & vbCr & "Please resolve for the script to continue."
	Loop until snap_check = checked OR mfip_check = checked OR DWP_check = checked OR EA_check = checked OR HC_check = checked OR ga_check = checked OR msa_check = checked OR GRH_check = checked AND worker_number <> ""
	err_msg = ""
	If SNAP_check = unchecked then 
		IF SNAP_Only_check = checked OR SNAP_ABAWD_check = checked OR SNAP_UH_check = checked then err_msg = err_msg & vbCr & "If you select SNAP details, you must filter FOR SNAP cases - Check the SNAP box"
	End If 
	IF mfip_check = unchecked then 
		IF MFIP_Only_check = checked OR MFIP_tanf_check = checked OR child_only_mfip_check = checked then err_msg = err_msg & vbCr & " If you select MFIP details, you must filter FOR MFIP cases - check the MFIP box"
	End If 
	If MFIP_tanf_check = checked AND tanf_months = "" then err_msg = err_msg & vbCr & "If you want to filter for a certain number of TANF months, you must indicate how many months you want"
	IF HC_check = unchecked then 
		If HC_msp_check = checked OR adult_hc_check = checked OR family_hc_check = checked OR ltc_HC_check = checked OR waiver_HC_check = checked then err_msg = err_msg & vbCr & "If you select HC details, you must filter FOR HC cases - check the HC Box"
	End If 
	IF snap_check = checked AND exclude_snap_check = checked then err_msg = err_msg & vbCr & "You cannot filter for SNAP and Exclude SNAP cases - please pick one"
	IF mfip_check = checked AND exclude_mfip_dwp_check = checked then err_msg = err_msg & vbCr & "You cannot filter for MFIP and Exclude MFIP cases - please pick one"
	IF EA_check = checked AND exclude_ea_check = checked then err_msg = err_msg & vbCr & "You cannot filter for EA/EGA and Excluded EA/EGA cases - please pick one"
	IF HC_check = checked AND exclude_HC_check = checked then err_msg = err_msg & vbCr & "You cannot filter for HC and exclude HC cases - please pick one"
	If exclude_ga_msa_check = checked then 
		IF ga_check = checked OR msa_check = checked then err_msg = err_msg & vbCr & "You cannot filter for GA and/or MSA and exclude GA/MSA cases - please pick one"
	End If 
	If GRH_check = checked AND exclude_grh_check = checked then err_msg = err_msg & vbCr & "You cannot filter for GRH and exclude GRH cases - please pick one"
	IF err_msg <> "" THEN MsgBox "*** NOTICE!!! ***" & vbCr & err_msg & vbCr & vbCr & "Please resolve for the script to continue."
Loop until err_msg = ""

'Starting the query start time (for the query runtime at the end)
query_start_time = timer

'Checking for MAXIS
Call check_for_MAXIS(True)


'Opening the Excel file
Set objExcel = CreateObject("Excel.Application")
objExcel.Visible = True
Set objWorkbook = objExcel.Workbooks.Add() 
objExcel.DisplayAlerts = True

'Setting the first 4 col as worker, case number, name, and APPL date
ObjExcel.Cells(1, 1).Value = "WORKER"
objExcel.Cells(1, 1).Font.Bold = TRUE
ObjExcel.Cells(1, 2).Value = "CASE NUMBER"
objExcel.Cells(1, 2).Font.Bold = TRUE
ObjExcel.Cells(1, 3).Value = "NAME"
objExcel.Cells(1, 3).Font.Bold = TRUE
ObjExcel.Cells(1, 4).Value = "NEXT REVW DATE"
objExcel.Cells(1, 4).Font.Bold = TRUE

'Figuring out what to put in each Excel col. To add future variables to this, add the checkbox variables below and copy/paste the same code!
'	Below, use the "[blank]_col" variable to recall which col you set for which option.
col_to_use = 5 'Starting with 5 because cols 1-4 are already used

'Setting the Program specific Excel col - the program headings will always populate but the more specific options will only populate if requested
ObjExcel.Cells(1, col_to_use).Value = "SNAP"
objExcel.Cells(1, col_to_use).Font.Bold = TRUE
snap_actv_col = col_to_use
col_to_use = col_to_use + 1
SNAP_letter_col = convert_digit_to_excel_column(snap_actv_col)

IF SNAP_ABAWD_check = checked then 
	ObjExcel.Cells(1, col_to_use).Value = "ABAWD?"
	objExcel.Cells(1, col_to_use).Font.Bold = TRUE
	ABAWD_actv_col = col_to_use
	col_to_use = col_to_use + 1
	ABAWD_letter_col = convert_digit_to_excel_column(ABAWD_actv_col)
End if

IF SNAP_UH_check = checked then
	ObjExcel.Cells(1, col_to_use).Value = "Unc Har?"
	objExcel.Cells(1, col_to_use).Font.Bold = TRUE
	UH_actv_col = col_to_use
	col_to_use = col_to_use + 1
	UH_letter_col = convert_digit_to_excel_column(UH_actv_col)
End if

ObjExcel.Cells(1, col_to_use).Value = "Cash 1"
objExcel.Cells(1, col_to_use).Font.Bold = TRUE
cash_one_prog_col = col_to_use
col_to_use = col_to_use + 1
cash_one_prog_letter_col = convert_digit_to_excel_column(cash_one_prog_col)

ObjExcel.Cells(1, col_to_use).Value = "Status"
objExcel.Cells(1, col_to_use).Font.Bold = TRUE
cash_one_actv_col = col_to_use
col_to_use = col_to_use + 1
cash_one_letter_col = convert_digit_to_excel_column(cash_one_actv_col)

ObjExcel.Cells(1, col_to_use).Value = "Cash 2"
objExcel.Cells(1, col_to_use).Font.Bold = TRUE
cash_two_prog_col = col_to_use
col_to_use = col_to_use + 1
cash_two_prog_letter_col = convert_digit_to_excel_column(cash_two_prog_col)

ObjExcel.Cells(1, col_to_use).Value = "Status"
objExcel.Cells(1, col_to_use).Font.Bold = TRUE
cash_two_actv_col = col_to_use
col_to_use = col_to_use + 1
cash_two_letter_col = convert_digit_to_excel_column(cash_two_actv_col)

If MFIP_tanf_check = checked then
	ObjExcel.Cells(1, col_to_use).Value = "TANF"
	objExcel.Cells(1, col_to_use).Font.Bold = TRUE
	TANF_mo_col = col_to_use
	col_to_use = col_to_use + 1
	TANF_letter_col = convert_digit_to_excel_column(TANF_mo_col)
End if

If child_only_mfip_check = checked then
	ObjExcel.Cells(1, col_to_use).Value = "Child Only?"
	objExcel.Cells(1, col_to_use).Font.Bold = TRUE
	child_only_col = col_to_use
	col_to_use = col_to_use + 1
	Child_letter_col = convert_digit_to_excel_column(child_only_col)
End if

ObjExcel.Cells(1, col_to_use).Value = "HC"
objExcel.Cells(1, col_to_use).Font.Bold = TRUE
hc_actv_col = col_to_use
col_to_use = col_to_use + 1
hc_letter_col = convert_digit_to_excel_column(hc_actv_col)

If HC_msp_check = checked then
	ObjExcel.Cells(1, col_to_use).Value = "MSP"
	objExcel.Cells(1, col_to_use).Font.Bold = TRUE
	MSP_actv_col = col_to_use
	col_to_use = col_to_use + 1
	MSP_letter_col = convert_digit_to_excel_column(MSP_actv_col)
End if

If adult_hc_check = checked OR family_hc_check = checked then
	ObjExcel.Cells(1, col_to_use).Value = "HC Type"
	objExcel.Cells(1, col_to_use).Font.Bold = TRUE
	HC_type_col = col_to_use
	col_to_use = col_to_use + 1
	HC_type_letter_col = convert_digit_to_excel_column(HC_type_col)
End if

If ltc_HC_check = checked then
	ObjExcel.Cells(1, col_to_use).Value = "LTC?"
	objExcel.Cells(1, col_to_use).Font.Bold = TRUE
	LTC_col = col_to_use
	col_to_use = col_to_use + 1
	LTC_letter_col = convert_digit_to_excel_column(LTC_col)
End if

If waiver_HC_check = checked then
	ObjExcel.Cells(1, col_to_use).Value = "Waiver?"
	objExcel.Cells(1, col_to_use).Font.Bold = TRUE
	Waiver_col = col_to_use
	col_to_use = col_to_use + 1
	Waiver_letter_col = convert_digit_to_excel_column(Waiver_col)
End if

ObjExcel.Cells(1, col_to_use).Value = "EA/EGA"
objExcel.Cells(1, col_to_use).Font.Bold = TRUE
EA_actv_col = col_to_use
col_to_use = col_to_use + 1
EA_letter_col = convert_digit_to_excel_column(EA_actv_col)

ObjExcel.Cells(1, col_to_use).Value = "GRH"
objExcel.Cells(1, col_to_use).Font.Bold = TRUE
GRH_actv_col = col_to_use
col_to_use = col_to_use + 1
GRH_letter_col = convert_digit_to_excel_column(GRH_actv_col)

If exclude_ievs_check = checked then 
	ObjExcel.Cells(1, col_to_use).Value = "IEVS?"
	ObjExcel.Cells(1, col_to_use).Font.Bold = True 
	ievs_col = col_to_use
	col_to_use = col_to_use + 1 
	ievs_letter_col = convert_digit_to_excel_column(ievs_col)
End If 

If exclude_paris_check = checked then 
	ObjExcel.Cells(1, col_to_use).Value = "PARIS?"
	ObjExcel.Cells(1, col_to_use).Font.Bold = True 
	paris_col = col_to_use
	col_to_use = col_to_use + 1 
	paris_letter_col = convert_digit_to_excel_column(paris_col)
End If 

ObjExcel.Cells(1, col_to_use).Value = "Transferred?"
ObjExcel.Cells(1, col_to_use).Font.Bold = TRUE
xfered_col = col_to_use
col_to_use = col_to_use + 1
xfered_letter_col = convert_digit_to_excel_column(xfered_col)

'create a single-object "array" just for simplicity of code.

x1s_from_dialog = split(worker_number, ",")	'Splits the worker array based on commas

'Need to add the worker_county_code to each one
For each x1_number in x1s_from_dialog
	If worker_array = "" then
		worker_array = worker_county_code & trim(replace(ucase(x1_number), worker_county_code, ""))		'replaces worker_county_code if found in the typed x1 number
	Else
		worker_array = worker_array & ", " & worker_county_code & trim(replace(ucase(x1_number), worker_county_code, "")) 'replaces worker_county_code if found in the typed x1 number
	End if
Next

'Split worker_array
worker_array = split(worker_array, ", ")

Dim All_case_information_array ()
Dim Full_case_list_array()
ReDim All_case_information_array (22, 0)
ReDim Full_case_list_array(11,0)
Dim eligible_members_array ()
Dim non_mfip_members_array ()
Dim SNAP_HH_Array () 

'Setting the variable for what's to come
excel_row = 2
m = 0 

For each worker in worker_array
	back_to_self	'Does this to prevent "ghosting" where the old info shows up on the new screen for some reason
	Call navigate_to_MAXIS_screen("rept", "actv")
	EMWriteScreen worker, 21, 13
	transmit
	EMReadScreen user_worker, 7, 21, 71		'
	EMReadScreen p_worker, 7, 21, 13
	IF user_worker = p_worker THEN PF7		'If the user is checking their own REPT/ACTV, the script will back up to page 1 of the REPT/ACTV

	'Skips workers with no info
	EMReadScreen has_content_check, 1, 7, 8
	If has_content_check <> " " then
		'Grabbing each case number on screen
		Do
			'Set variable for next do...loop
			MAXIS_row = 7

			'Checking for the last page of cases.
			EMReadScreen last_page_check, 21, 24, 2	'because on REPT/ACTV it displays right away, instead of when the second F8 is sent
			
			Do	
				cash_one_type = ""
				cash_two_type = "" 
				
				EMReadScreen case_number, 8, MAXIS_row, 12		'Reading case number
				EMReadScreen client_name, 21, MAXIS_row, 21		'Reading client name
				EMReadScreen next_revw_date, 8, MAXIS_row, 42		'Reading application date
				EMReadScreen cash_one_status, 1, MAXIS_row, 54		'Reading cash status
					IF cash_one_status = "A" or cash_one_status = "P" then EMReadScreen cash_one_type, 2, MAXIS_row, 51	
				EMReadScreen cash_two_status, 1, MAXIS_row, 59
					IF cash_two_status = "A" or cash_two_status = "P" then EMReadScreen cash_two_type, 2, MAXIS_row, 56
				EMReadScreen SNAP_status, 1, MAXIS_row, 61		'Reading SNAP status
				EMReadScreen HC_status, 1, MAXIS_row, 64			'Reading HC status
				EMReadScreen EA_status, 1, MAXIS_row, 67			'Reading EA status
				EMReadScreen GRH_status, 1, MAXIS_row, 70			'Reading GRH status
				
				If case_number = "        " then exit do			'Exits do if we reach the end
				
				Full_case_list_array(0,m) = case_number
				Full_case_list_array(1,m) = client_name
				Full_case_list_array(2,m) = replace(next_revw_date, " ", "/")
				Full_case_list_array(3,m) = cash_one_type
				Full_case_list_array(4,m) = cash_one_status
				Full_case_list_array(5,m) = cash_two_type 
				Full_case_list_array(6,m) = cash_two_status
				Full_case_list_array(7,m) = SNAP_status
				Full_case_list_array(8,m) = HC_status
				Full_case_list_array(9,m) = EA_status
				Full_case_list_array(10,m) = GRH_status
				Full_case_list_array(11,m) = worker 
				
				Redim Preserve Full_case_list_array (Ubound(Full_case_list_array,1), Ubound(Full_case_list_array,2)+1)
				
				'Doing this because sometimes BlueZone registers a "ghost" of previous data when the script runs. This checks against an array and stops if we've seen this one before.
				If trim(case_number) <> "" and instr(all_case_numbers_array, case_number) <> 0 then exit do
				all_case_numbers_array = trim(all_case_numbers_array & " " & case_number)
				

				MAXIS_row = MAXIS_row + 1
				case_number = ""			'Blanking out variable 
				'MsgBox m & " " & Full_case_list_array(0,m)
				m = m + 1
			Loop until MAXIS_row = 19 
			PF8
		Loop until last_page_check = "THIS IS THE LAST PAGE"
	End if
next

For n = 0 to Ubound(Full_case_list_array,2)
	IF SNAP_ABAWD_check = checked OR SNAP_UH_check = checked OR MFIP_tanf_check = checked OR child_only_mfip_check = checked OR HC_msp_check = checked OR adult_hc_check = checked OR family_hc_check = checked OR ltc_HC_check = checked OR waiver_HC_check = checked OR exclude_ievs_check = checked OR exclude_paris_check = checked then
		'////// Checking number of TANF months if requested
		case_number = Full_case_list_array(0,n)
		IF MFIP_tanf_check = checked then 
			IF Full_case_list_array(3,n) = "MF" OR Full_case_list_array(5,n) = "MF" then 
				navigate_to_MAXIS_screen "STAT", "TIME"
				EMReadScreen reg_mo, 2, 17, 69
				EMReadScreen ext_mo, 2, 19, 31 
				If ext_mo = "__" then ext_mo = 0 
				reg_mo = reg_mo * 1
				ext_mo = ext_mo * 1 
				TANF_used = abs(reg_mo) + abs(ext_mo)
				PF3
			End If
		End If
		'////// Checking for adults on the MFIP grant if requested
		IF  child_only_mfip_check = checked then
			IF Full_case_list_array(3,n) = "MF" OR Full_case_list_array(5,n) = "MF" then
				adult_on_mfip = False  
				navigate_to_MAXIS_screen "ELIG", "MFIP"
				EMReadScreen approval_check, 8, 3, 3 
				IF approval_check <> "APPROVED" then 
					EMReadScreen version_number, 1, 2, 12 
					prev_version = abs(version_number)-1
					EMWriteScreen 0 & prev_version, 20, 79 
					transmit 
				End If
				ReDim eligible_members_array (0)
				ReDim non_mfip_members_array (0)
				a = 0 
				b = 0 
				For row_to_check = 7 to 19 
					EMReadScreen pers_status, 10, row_to_check, 53
					EMReadScreen memb_number, 2, row_to_check, 6
					If pers_status = "INELIGIBLE" then
						non_mfip_members_array(a) = memb_number
						a = a + 1 
						ReDim Preserve non_mfip_members_array(a)
					ElseIF pers_status = "ELIGIBLE  " then 
						eligible_members_array(b) = memb_number
						b = b + 1 
						ReDim Preserve eligible_members_array(b) 
					Else 
						Exit For
					End If
				Next
				navigate_to_MAXIS_screen "STAT", "MEMB"
				For i = 0 to b 
					EMWriteScreen eligible_members_array(i), 20, 76
					transmit
					EMReadScreen member_age, 2, 8, 76
					If member_age = "  " then member_age = 0
					If abs(member_age) > 18 then
						adult_on_mfip = TRUE 
					ElseIF abs(member_age) = 18 AND eligible_members_array(i) = "01" THEN
						adult_on_mfip = TRUE 
					End IF
					If adult_on_mfip = TRUE then 
						Exit For
					Else 
						adult_on_mfip = FALSE
					End If
				Next
			End If 
			'MsgBox "Adult on MFIP?" & adult_on_mfip
		End If 
		'//////Checking for ABAWD Status 
		IF SNAP_ABAWD_check = checked then
			IF Full_case_list_array(7,n) = "P" OR Full_case_list_array(7,n) = "A" then
				SNAP_with_ABAWD = False 
				navigate_to_MAXIS_screen "ELIG", "FS"
				ReDim SNAP_HH_Array(0) 
				c = 0 
				For row_to_check = 7 to 19 
					EMReadScreen pers_status, 10, row_to_check, 57
					EMReadScreen memb_number, 2, row_to_check, 10
					IF pers_status = "ELIGIBLE  " then 
						SNAP_HH_Array(c) = memb_number
						c = c + 1 
						ReDim Preserve SNAP_HH_Array(c) 
					End If
				Next
				navigate_to_MAXIS_screen "STAT", "WREG"
				For j = 0 to c
					EMWriteScreen SNAP_HH_Array(j), 20, 76 
					transmit						
					EMReadScreen ABAWD_status, 2, 13, 50
					IF ABAWD_status = "10" OR ABAWD_status = "11" then 
						SNAP_with_ABAWD = TRUE 
						Exit For 
					Else 
						SNAP_with_ABAWD = FALSE 
					End If
				Next 
			End If
		End If 
		'///// Determining if Case is Uncle Harry SNAP
		IF SNAP_UH_check = checked then
			IF Full_case_list_array(7,n) = "P" OR Full_case_list_array(7,n) = "A" then 
				navigate_to_MAXIS_screen "ELIG", "FS"
				EMReadScreen type_of_SNAP, 13, 4, 3 
				IF type_of_SNAP = "'UNCLE HARRY'" then 
					UH_SNAP = TRUE 
				Else
					UH_SNAP = FALSE 
				End If
			End If
		End If 
		'///// Finding if HC cases have Medicare Savings Programs active or pending
		IF HC_msp_check = checked then
			IF Full_case_list_array(8,n) = "A" OR Full_case_list_array(8,n) = "P" then 
				navigate_to_MAXIS_screen "CASE", "CURR"
				'Determines if QMB is active
				Pending_MSP = False 
				row = 1 
				col = 1 
				EMSearch "QMB:", row, col 
				If row = 0 then 
					QMB_active = FALSE 
				Else 
					EMReadScreen prog_status, 6, row, col + 5 
					IF prog_status = "ACTIVE" OR prog_status = "APP OP" then 
						QMB_active = TRUE
					ElseIf prog_status = "PENDIN" then 
						Pending_MSP = TRUE 
					End If
				End If
				'Determines if SLMB is active
				row = 1 
				col = 1 
				EMSearch "SLMB:", row, col 
				If row = 0 then 
					SLMB_active = FALSE 
				Else 
					EMReadScreen prog_status, 6, row, col + 6 
					IF prog_status = "ACTIVE" OR prog_status = "APP OP" then 
						SLMB_active = TRUE
					ElseIf prog_status = "PENDIN" then 
						Pending_MSP = TRUE 
					End If 
				End If
				'Determines if QI1 is active
				row = 1 
				col = 1 
				EMSearch "Q1:", row, col 
				If row = 0 then 
					QI_active = FALSE 
				Else 
					EMReadScreen prog_status, 6, row, col + 4 
					IF prog_status = "ACTIVE" OR prog_status = "APP OP" then 
						QI_active = TRUE
					ElseIf prog_status = "PENDIN" then 
						Pending_MSP = TRUE
					End If 
				End If
				IF QMB_active = TRUE then
					MSP_actv = "QMB"
				ElseIf SLMB_active = TRUE then
					MSP_actv = "SLMB"
				ElseIF QI_active = TRUE then
					MSP_actv = "QI1"
				ElseIF Pending_MSP = TRUE then 
					MSP_actv = "PEND"
				Else 
					MSP_actv = "None"
				End If
			End If
		End If 
		'////// Determining Family or Adult HC Cases 
		If adult_hc_check = checked OR family_hc_check = checked then 
			IF Full_case_list_array(8,n) = "A" or Full_case_list_array(8,n) = "P" then
				navigate_to_MAXIS_screen "ELIG", "HC"
				For row = 8 to 19 
					EMReadScreen prog_status, 6, row, 50 
					If prog_status = "ACTIVE" or prog_status = "PENDIN" then 
						EMWriteScreen "x", 8, 26 
						transmit
						EMReadScreen Elig_type, 2, 12, 72 
						If Elig_type = "BT" OR Elig_type = "DT" then 
							Specialty_HC = "TEFRA"
						ElseIF Elig_type = "09" OR Elig_type = "10" OR Elig_type = "25" then 
							Specialty_HC = "Foster/IV-E"
						ElseIF Elig_type = "BC" then
							Specialty_HC = "SAGE/BC"
						ElseIf Elig_type = "11" OR Elig_type = "PX" OR Elig_type = "PC" OR Elig_type = "CB" OR Elig_type = "CK" OR Elig_type = "CX" OR Elig_type = "AA" then
							Family_HC = TRUE
						ElseIf Elig_type = "AX" OR Elig_type = "15" OR Elig_type = "16" OR Elig_type = "EX" OR Elig_type = "BX" OR Elig_type = "DX" OR Elig_type = "DP" OR Elig_type = "RM" then
							Adult_HC = TRUE 
							Family_HC = FALSE 
						End If 
						If Specialty_HC <> "" OR Family_HC = TRUE then 
							Adult_HC = FALSE 
							Exit For 
						End If
					End If 
				Next 
			End If
		End If 
		'////// Determining LTC cases
		If ltc_HC_check = checked then 
			IF Full_case_list_array(8,n) = "A" or Full_case_list_array(8,n) = "P" then
				navigate_to_MAXIS_screen "ELIG", "HC"
				EMWriteScreen "x", 8, 26 
				transmit
				EMReadScreen hc_method, 1, 13, 76 
				If hc_method = "L" then 
					LTC_MA = TRUE
				Else
					LTC_MA = FALSE
				End If 
			End If
		End If 
		'////// Determining Waiver Cases 
		If waiver_HC_check = checked then 
			IF Full_case_list_array(8,n) = "A" or Full_case_list_array(8,n) = "P" then
				navigate_to_MAXIS_screen "ELIG", "HC"
				EMWriteScreen "x", 8, 26 
				transmit
				EMReadScreen waiver_type, 1, 14, 76 
				If waiver_type = "F" OR waiver_type = "G" OR waiver_type = "H" OR waiver_type = "I" OR waiver_type = "J" OR waiver_type = "K" OR waiver_type = "L" OR waiver_type = "M" OR waiver_type = "P" OR waiver_type = "Q" OR waiver_type = "R" OR waiver_type = "S" OR waiver_type = "Y" then 
					Waiver_MA = TRUE
				Else
					Waiver_MA = FALSE
				End If 
			End If
		End If 
		'///// Determining if IEVS DAILs exist for this case 
		IF exclude_ievs_check = checked then 
			back_to_self
			EMWriteScreen Full_case_list_array(0,n), 18, 43 
			navigate_to_MAXIS_screen "DAIL", "DAIL" 
			EMWriteScreen "x", 4, 12 
			transmit 
			EMWriteScreen " ", 7, 39 
			EMWriteScreen "x", 12, 39 
			transmit 
			Do 
				ievs_dail_row = 1 
				ievs_dail_col = 1 
				EMSearch Full_case_list_array(0,n), ievs_dail_row, ievs_dail_col 
				If ievs_dail_row = 0 then 
					IEVS_DAIL = "N"
				Else 
					IEVS_DAIL = "Y" 
					Exit Do 
				End If 
				PF8 
				EMReadScreen end_of_dail_check, 9, 24, 14 
			Loop until end_of_dail_check = "LAST PAGE"
		End If 
		'///// Determining if PARIS DAILs exist for this case 
		IF exclude_paris_check = checked then 
			back_to_self
			EMWriteScreen Full_case_list_array(0,n), 18, 43 
			navigate_to_MAXIS_screen "DAIL", "DAIL" 
			EMWriteScreen "x", 4, 12 
			transmit 
			EMWriteScreen " ", 7, 39 
			EMWriteScreen "x", 17, 39 
			transmit 
			Do 
				paris_dail_row = 1 
				paris_dail_col = 1 
				EMSearch Full_case_list_array(0,n), paris_dail_row, paris_dail_col 
				If paris_dail_row = 0 then 
					PARIS_DAIL = "N"
				Else 
					PARIS_DAIL = "Y"
					Exit Do 
				End If 
				PF8 
				EMReadScreen end_of_dail_check, 9, 24, 14 
			Loop until end_of_dail_check = "LAST PAGE"
		End If  
	End If	

	Do
		IF SNAP_check = checked then 
			IF Full_case_list_array(7,n) = "P" OR Full_case_list_array(7,n) = "A" then Save_case_for_transfer = TRUE
		End If
		If mfip_check = checked then 
			IF Full_case_list_array(3,n) = "MF" OR Full_case_list_array(5,n) = "MF" then Save_case_for_transfer = TRUE
		End If
		If DWP_check = checked then 
			IF Full_case_list_array(3,n) = "DW" OR Full_case_list_array(5,n) = "DW" then Save_case_for_transfer = TRUE
		End If
		If ga_check = checked then 
			IF Full_case_list_array(3,n) = "GA" OR Full_case_list_array(5,n) = "GA" then Save_case_for_transfer = TRUE
		End If
		If msa_check = checked then 
			IF Full_case_list_array(3,n) = "MS" OR Full_case_list_array(5,n) = "MS" then Save_case_for_transfer = TRUE
		End If 
		If rca_check = checked then 
			IF Full_case_list_array(3,n) = "RC" OR Full_case_list_array(5,n) = "RC" then Save_case_for_transfer = TRUE
		End If
		IF Full_case_list_array(9,n) = "P" AND EA_check = checked then Save_case_for_transfer = TRUE
		IF HC_check = checked then 
			IF Full_case_list_array(8,n) = "A" OR Full_case_list_array(8,n) = "P" then Save_case_for_transfer = TRUE
		End If
		If GRH_check = checked then
			IF Full_case_list_array(10,n) = "A" OR Full_case_list_array(10,n) = "P" then Save_case_for_transfer = TRUE
		End If
		
		IF exclude_snap_check = checked then 
			IF Full_case_list_array(7,n) = "A" OR Full_case_list_array(7,n) = "P" then Save_case_for_transfer = FALSE 
		End if 
		IF exclude_mfip_dwp_check = checked then 
			IF Full_case_list_array(3,n) = "MF" OR Full_case_list_array(5,n) = "MF" OR Full_case_list_array(3,n) = "DW" OR Full_case_list_array(5,n) = "DW" then Save_case_for_transfer = FALSE 
		End if 
		IF Full_case_list_array(9,n) = "P" AND exclude_ea_check = checked then Save_case_for_transfer = FALSE 
		IF exclude_HC_check = checked then
			IF Full_case_list_array(8,n) = "A" OR Full_case_list_array(8,n) = "P" then Save_case_for_transfer = FALSE 
		End If 
		IF exclude_ga_msa_check = checked then
			IF Full_case_list_array(3,n) = "GA" OR Full_case_list_array(5,n) = "GA" OR Full_case_list_array(3,n) = "MS" OR Full_case_list_array(5,n) = "MS" then Save_case_for_transfer = FALSE 
		End If 
		IF exclude_grh_check = checked then 
			IF Full_case_list_array(10,n) = "A" OR Full_case_list_array(10,n) = "P" then Save_case_for_transfer = FALSE 
		End If
		IF exclude_RCA_check = checked then 
			IF Full_case_list_array(3,n) = "RC" OR Full_case_list_array(5,n) = "RC" then Save_case_for_transfer = FALSE 
		End If
		IF exclude_pending_check = checked then
			IF Full_case_list_array(7,n) = "P" OR Full_case_list_array(4,n) = "P" OR Full_case_list_array(6,n) = "P" OR Full_case_list_array(9,n) = "P" OR Full_case_list_array(8,n) = "P" OR Full_case_list_array(10,n) = "P" then Save_case_for_transfer = FALSE 
		End If 
		IF SNAP_Only_check = checked then
			IF Full_case_list_array(4,n) = "A" OR Full_case_list_array(4,n) = "P" OR Full_case_list_array(6,n) = "A" OR Full_case_list_array(6,n) = "P" OR Full_case_list_array(9,n) = "A" OR Full_case_list_array(9,n) = "P" OR Full_case_list_array(8,n) = "A" OR Full_case_list_array(8,n) = "P" OR Full_case_list_array(10,n) = "A" OR Full_case_list_array(10,n) = "P" then Save_case_for_transfer = FALSE 
		End If 
		IF HC_Only_check = checked then  
			IF Full_case_list_array(4,n) = "A" OR Full_case_list_array(4,n) = "P" OR Full_case_list_array(6,n) = "A" OR Full_case_list_array(6,n) = "P" OR Full_case_list_array(9,n) = "A" OR Full_case_list_array(9,n) = "P" OR Full_case_list_array(7,n) = "A" OR Full_case_list_array(7,n) = "P" OR Full_case_list_array(10,n) = "A" OR Full_case_list_array(10,n) = "P" then Save_case_for_transfer = FALSE 
		End If 
		IF GRH_Only_check = checked then 
			IF Full_case_list_array(4,n) = "A" OR Full_case_list_array(4,n) = "P" OR Full_case_list_array(6,n) = "A" OR Full_case_list_array(6,n) = "P" OR Full_case_list_array(9,n) = "A" OR Full_case_list_array(9,n) = "P" OR Full_case_list_array(8,n) = "A" OR Full_case_list_array(8,n) = "P" OR Full_case_list_array(7,n) = "A" OR Full_case_list_array(7,n) = "P" then Save_case_for_transfer = FALSE 
		End If 
		IF MFIP_Only_check = checked then 
			IF Full_case_list_array(3,n) = "DW" OR Full_case_list_array(3,n) = "GA" OR Full_case_list_array(3,n) = "MS" OR Full_case_list_array(3,n) = "RC" OR Full_case_list_array(5,n) = "DW" OR Full_case_list_array(5,n) = "GA" OR Full_case_list_array(5,n) = "MS" OR Full_case_list_array(5,n) = "RC" OR Full_case_list_array(7,n) = "A" OR Full_case_list_array(7,n) = "P" OR Full_case_list_array(8,n) = "A" OR Full_case_list_array(8,n) = "P" OR Full_case_list_array(10,n) = "A" OR Full_case_list_array(10,n) = "P" OR Full_case_list_array(9,n) = "A" OR Full_case_list_array(9,n) = "P" then Save_case_for_transfer = FALSE 
		End If 
		IF SNAP_ABAWD_check = checked then
			IF SNAP_with_ABAWD = FALSE then Save_case_for_transfer = FALSE
		End If 
		IF SNAP_UH_check = checked then 
			IF UH_SNAP = FALSE then Save_case_for_transfer = FALSE 
		End If 
		IF MFIP_tanf_check = checked then 
			IF abs(TANF_used) < abs(tanf_months) then Save_case_for_transfer = FALSE 
		End If
		IF child_only_mfip_check = checked AND adult_on_mfip = TRUE then Save_case_for_transfer = FALSE 
		IF HC_msp_check = checked AND MSP_actv = "None" then Save_case_for_transfer = FALSE 
		IF adult_hc_check = checked AND Adult_HC = FALSE then Save_case_for_transfer = FALSE  
		IF family_hc_check = checked AND Family_HC = FALSE then Save_case_for_transfer = FALSE  
		IF ltc_HC_check = checked AND LTC_MA = FALSE then Save_case_for_transfer = FALSE 
		IF waiver_HC_check = checked AND Waiver_MA = FALSE then Save_case_for_transfer = FALSE 
		'IF exclude_ievs_check = checked AND IEVS_DAIL = "Y" then Save_case_for_transfer = FALSE 
		'If exclude_paris_check = checked AND PARIS_DAIL = "Y" then Save_case_for_transfer = FALSE 
		'MsgBox Save_case_for_transfer
		If Save_case_for_transfer <> TRUE THEN Save_case_for_transfer = FALSE 
	Loop until Save_case_for_transfer <> ""
	
	IF Save_case_for_transfer = TRUE then
		'////// Add all information for qualifying cases into the Array
		k = 0 
		All_case_information_array(0,k) = Full_case_list_array(0,n)
		All_case_information_array(1,k) = Full_case_list_array(1,n)
		All_case_information_array(2,k) = Full_case_list_array(2,n)
		All_case_information_array(3,k) = Full_case_list_array(3,n)
		All_case_information_array(4,k) = Full_case_list_array(4,n)
		All_case_information_array(5,k) = Full_case_list_array(5,n) 
		All_case_information_array(6,k) = Full_case_list_array(6,n)
		All_case_information_array(7,k) = TANF_used
		IF adult_on_mfip = FALSE then child_only = "Yes"
		IF adult_on_mfip = TRUE then child_only = "No"
		All_case_information_array(8,k) = child_only
		All_case_information_array(9,k) = Full_case_list_array(7,n)
		All_case_information_array(10,k) = SNAP_with_ABAWD
		All_case_information_array(11,k) = UH_SNAP
		All_case_information_array(12,k) = Full_case_list_array(8,n)
		IF Specialty_HC <> "" then 
			All_case_information_array(13,k) = Specialty_HC
		ElseIf Family_HC = TRUE then
			All_case_information_array(13,k) = "Family"
		ElseIf Adult_HC = TRUE then
			All_case_information_array(13,k) = "Adult"
		End IF
		All_case_information_array(14,k) = MSP_actv
		All_case_information_array(15,k) = LTC_MA
		All_case_information_array(16,k) = Waiver_MA
		All_case_information_array(17,k) = Full_case_list_array(9,n)
		All_case_information_array(18,k) = Full_case_list_array(10,n)
		All_case_information_array(19,k) = excel_row 
		All_case_information_array(20,k) = IEVS_DAIL
		All_case_information_array(21,k) = PARIS_DAIL
		
		'///// Resizing the storage array for the next loop
		Redim Preserve All_case_information_array (UBound(All_case_information_array,1), UBound(All_case_information_array,2)+1)
		
		'ADD THE INFORMATION TO XCEL HERE 
		ObjExcel.Cells(excel_row, 1).Value = Full_case_list_array(11,n) 
		ObjExcel.Cells(excel_row, 2).Value = All_case_information_array(0,k)
		ObjExcel.Cells(excel_row, 3).Value = All_case_information_array(1,k)
		ObjExcel.Cells(excel_row, 4).Value = All_case_information_array(2,k)
		'ObjExcel.Cells(excel_row, 5).Value = abs(days_pending)
		ObjExcel.Cells(excel_row, snap_actv_col).Value = All_case_information_array(9,k)
		IF SNAP_ABAWD_check = checked THEN ObjExcel.Cells(excel_row, ABAWD_actv_col). Value = All_case_information_array(10,k)
		IF SNAP_UH_check = checked THEN ObjExcel.Cells(excel_row, UH_actv_col).Value = All_case_information_array(11,k)
		ObjExcel.Cells(excel_row, cash_one_prog_col).Value = All_case_information_array(3,k)
		ObjExcel.Cells(excel_row, cash_one_actv_col).Value = All_case_information_array(4,k)
		ObjExcel.Cells(excel_row, cash_two_prog_col).Value = All_case_information_array(5,k)
		ObjExcel.Cells(excel_row, cash_two_actv_col).Value = All_case_information_array(6,k)
		IF MFIP_tanf_check = checked THEN ObjExcel.Cells(excel_row, TANF_mo_col).Value = All_case_information_array(7,k)
		IF child_only_mfip_check =checked THEN ObjExcel.Cells(excel_row, child_only_col).Value = All_case_information_array(8,k)
		ObjExcel.Cells(excel_row, hc_actv_col).Value = All_case_information_array(12,k)
		IF adult_hc_check = checked OR family_hc_check =checked THEN ObjExcel.Cells(excel_row, hc_type_col).Value = All_case_information_array(13,k)
		IF HC_msp_check = checked THEN ObjExcel.Cells(excel_row, MSP_actv_col).Value = All_case_information_array(14,k)
		IF ltc_HC_check = checked THEN ObjExcel.Cells(excel_row, LTC_col).Value = All_case_information_array(15,k)
		IF waiver_HC_check = checked THEN ObjExcel.Cells(excel_row, Waiver_col).Value = All_case_information_array(16,k)
		ObjExcel.Cells(excel_row, EA_actv_col).Value = All_case_information_array(17,k)
		ObjExcel.Cells(excel_row, GRH_actv_col).Value = All_case_information_array(18,k)
		IF exclude_ievs_check = checked THEN ObjExcel.Cells(excel_row, ievs_col).Value = All_case_information_array(20,k)
		IF exclude_paris_check = checked THEN ObjExcel.Cells(excel_row, paris_col).Value = All_case_information_array(21,k)
		excel_row = excel_row + 1
		k = k + 1 'Goes to the next entry for the All_case_information_array
		case_number = "" 
	End if
	Save_case_for_transfer = ""	'Blanking out variable
Next 

col_to_use = col_to_use + 2	'Doing two because the wrap-up is two columns

'Query date/time/runtime info
objExcel.Cells(1, col_to_use - 1).Font.Bold = TRUE
objExcel.Cells(2, col_to_use - 1).Font.Bold = TRUE
ObjExcel.Cells(1, col_to_use - 1).Value = "Query date and time:"	'Goes back one, as this is on the next row
ObjExcel.Cells(1, col_to_use).Value = now
ObjExcel.Cells(2, col_to_use - 1).Value = "Query runtime (in seconds):"	'Goes back one, as this is on the next row
ObjExcel.Cells(2, col_to_use).Value = timer - query_start_time


'Autofitting columns
For col_to_autofit = 1 to col_to_use
	ObjExcel.columns(col_to_autofit).AutoFit()
Next

cases_found = UBound(All_case_information_array,2) + 1 
number_of_cases_to_transfer = cases_found

'HERE IS WHERE THE TRANSFER PART WILL GO
'Do 
'	Dialog case_transfer_dialog
'	cancel_confirmation
'	err_msg = ""
'	IF worker_receiving_cases = "" then err_msg = err_msg & vbCR & "You must enter a worker number to transfer cases to"
'	IF number_of_cases_to_transfer > cases_found then err_msg = err_msg & vbCr & "You cannot transfer more cases than were found to transfer"
'Loop until err_msg = ""

'Logging usage stats
script_end_procedure("Your Excel Sheet is ready")
