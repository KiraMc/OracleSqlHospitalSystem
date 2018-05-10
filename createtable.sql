create table GENERAL_WARD
(
	Patient_Name varchar2(30),
	G_Admission_Date date,
	Patient_Type varchar2(10),
	constraint gwtype check (Patient_Type = 'Cardiac' or Patient_Type = 'Neuro' or Patient_Type = 'General')
);

create table SCREENING_WARD
(
	Patient_Name varchar2(30),
	S_Admission_Date date,
	Bed_No number,
	Patient_Type varchar2(10),
	constraint scr_pri primary key (patient_name,s_admission_date,patient_type)
);

create table PRE_SURGERY_WARD
(
	Patient_Name varchar2(30),
	Pre_Admission_Date date,
	Bed_No number,
	Patient_Type varchar2(10),
	constraint pre_pri primary key (patient_name,pre_admission_date,patient_type)
);

create table POST_SURGERY_WARD
(
	Patient_Name varchar2(30),
	Post_Admission_Date date,
	Discharge_Date date,
	Scount number,
	Patient_Type varchar2(10),
	constraint pos_pri primary key (patient_name,post_admission_date,patient_type)
);

create table Patient_Chart
(
	Patient_Name varchar2(30),
	Pdate date,
	Temperature number,
	BP number
);

create table DR_Schedule
(
	Name varchar2(30),
	Ward varchar2(20),
	Duty_Date date,
	constraint drtype check (Ward = 'GENERAL_WARD' or Ward = 'SCREENING_WARD' or Ward = 'PRE_SURGERY_WARD' or Ward = 'POST_SURGERY_WARD' or Ward = 'Surgery')
);

create table Surgeon_Schedule
(
	Name varchar2(30),
	Surgery_Date date
);

create table PATIENT_INPUT
(
	Patient_Name varchar2(30),
	General_ward_admission_date date,
	Patient_Type varchar2(10)
);
