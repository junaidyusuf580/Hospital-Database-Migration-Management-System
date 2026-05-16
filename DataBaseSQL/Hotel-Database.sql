-- Create Database name JKgroups
create database jkgroups;
use jkgroups;

-- 1 Create Table Departments
create table departments
(
Department_id int auto_increment primary key,
name varchar(50) not null
);

-- 2 Doctor table
create table doctors
(
 Doctor_id int auto_increment primary key,
 name varchar(50) not null,
 specialization varchar(100),
 role varchar(100),
 Department_id int,
 foreign key(Department_id) references departments(Department_id)
 );
 
 -- 3 Pateint Table
 create table Patients
 (
  patient_id int auto_increment primary key,
  name varchar(100),
  DateOfBirth date,
  gender varchar(1),
  phone int,
  check (gender in('m', 'f', 'o'))
  );
  
  -- 4 Appointments table
create table Appointments
(
 appointment_id int auto_increment primary key,
 patient_id int,
 Doctor_id int,
 AppointmentTime datetime,
 status varchar(100),
 foreign key(patient_id) references Patients(patient_id),
 foreign key(Doctor_id) references doctors(Doctor_id),
 check (status in('cancelled', 'completed', 'scheduled'))
 );
 
 -- 5 Prescription table
create table Prescriptions
(
 PrescriptionID int auto_increment primary key,
 appointment_id int,
 Medication varchar(100),
 dosage varchar(100),
 foreign key(appointment_id) references Appointments(appointment_id)
 );
 
 -- 6 Bills Table
 create table Bills
 (
  Bill_id int auto_increment primary key,
  appointment_id int,
  amount decimal(10,2),
  paid tinyint,
  billdate datetime default current_timestamp,
  foreign key(appointment_id) references Appointments(appointment_id)
  );
  
-- 7 Lab Reports table
create table Labs
(
 report_id int auto_increment primary key,
 appointment_id int,
 reportdata text,
 Createdat datetime default current_timestamp,
 foreign key(appointment_id) references Appointments(appointment_id)
  );
 ----------------------------------------------------------------------------------------------------------- 
  -- Insert data into table
  
-- 1. Inserting data into Department Table
select * from hospital_data;

select concat('Select', group_concat(concat('`',column_name,'`')),' from hospital_data') from Information_Schema.columns
where Table_Schema = 'jkgroups' 
and Table_name= 'hospital_data'
and column_name like 'departments.%';



Insert into departments	(Department_id, name)
Select`Departments.DepartmentID`,`Departments.Name` from hospital_data
where `Departments.DepartmentID` <> '';


-- 2. Inserting data into Doctors Table
select concat('select',group_concat(concat('`',column_name,'`')),'from hospital_data') from Information_Schema.columns
where table_schema = 'jkgroups'
and table_name= 'hospital_data'
and column_name like 'doctors.%';
insert into doctors(doctor_id, name, specialization, role, Department_id)
select`Doctors.DoctorID`,`Doctors.Name`,`Doctors.Specialization`,`Doctors.Role`,`Doctors.DepartmentID`from hospital_data
where `Doctors.DepartmentID`<>'';

-- 3. Inserting data into Patient Table
select concat('select',group_concat(concat('`',column_name,'`')),'from hospital_data') from Information_Schema.columns
where table_schema = 'jkgroups'
and table_name= 'hospital_data'
and column_name like 'patients.%';

insert into patients(patient_id, name, DateOfBirth, gender, phone)
select`Patients.PatientID`,
`Patients.Name`,
str_to_date(`Patients.DateOfBirth`, '%d-%m-%Y'),
`Patients.Gender`,`Patients.Phone`from hospital_data
where `Patients.PatientID`<>'';

-- Alter columns dtypes
Alter table patients
modify phone varchar(20);

-- 4 Inserting Data into Appointment table
select concat('select',group_concat(concat('`',column_name,'`')),'from hospital_data') from Information_Schema.columns
where table_schema = 'jkgroups'
and table_name= 'hospital_data'
and column_name like 'appointments.%';

insert into appointments(appointment_id, patient_id, Doctor_id, AppointmentTime, status)
select`Appointments.AppointmentID`,`Appointments.PatientID`,`Appointments.DoctorID`, 
str_to_date(`Appointments.AppointmentTime`, '%d-%m-%Y %H:%i'),
`Appointments.Status`from hospital_data;
Select * from appointments;

-- 5 Inserting Data into Prescriptions table

select concat('select',group_concat(concat('`',column_name,'`')),'from hospital_data') from Information_Schema.columns
where table_schema = 'jkgroups'
and table_name= 'hospital_data'
and column_name like 'prescriptions.%';

insert into prescriptions(PrescriptionID, appointment_id, Medication, dosage) 
select`Prescriptions.PrescriptionID`,`Prescriptions.AppointmentID`,
`Prescriptions.Medication`,`Prescriptions.Dosage`from hospital_data
where `Prescriptions.PrescriptionID` <> '';
select * from prescriptions;

-- 6 Inserting Data into labs
select concat('select',group_concat(concat('`',column_name,'`')),'from hospital_data') from Information_Schema.columns
where table_schema = 'jkgroups'
and table_name= 'hospital_data'
and column_name like 'LabReports.%';

insert into labs(report_id, appointment_id, reportdata, Createdat)
select`LabReports.ReportID`,`LabReports.AppointmentID`,`LabReports.ReportData`,`LabReports.CreatedAt`
from hospital_data
where trim(`LabReports.ReportID`) <> '' ;
select  * from labs;

-- 7 Inserting Data into labs

select concat('select',group_concat(concat('`',column_name,'`')),'from hospital_data') from Information_Schema.columns
where table_schema = 'jkgroups'
and table_name= 'hospital_data'
and column_name like 'Bills.%';

insert into bills(Bill_id, appointment_id, amount, paid, billdate)

select`Bills.BillID`,`Bills.AppointmentID`,
`Bills.Amount`,`Bills.Paid`,`Bills.BillDate`from hospital_data
where trim(`Bills.BillID`) <> '';

select * from bills;
-----------------------------------------------------------------------------------------------------
-- Check Double Appointments
Delimiter $$ 
Create Trigger Check_new_appointment
before insert on appointments
for each row
begin
	if new.AppointmentTime<now() then
		signal sqlstate '45000'
		set message_text= 'Error: Appointment should not be of past';
	end if;

	if exists
	(
		select * from doctors 
		where Doctor_id = new.Doctor_id 
		and AppointmentTime= new.AppointmentTime
		and status in ('scheduled')
	)
		then
		signal sqlstate '45000'
		set message_text ='Error: Doctors has already an appointment at this time';
		end if;
End $$
Delimiter;

Select * from doctors;
Select * from patients;
----------------------------------------------------------------------------------------------------------------------
-- Create Procedure (Get pateint detail by using credentials) 

Delimiter $$

Create procedure view_doctors_details(in input_username varchar(50), in input_password varchar(100))
Begin
	
    Declare Doc_id int;
    Declare Doc_role varchar(50);
    Declare Doc_department int;
    
    -- Get Doctor_id through doctor_credentials
    select doctor_id into Doc_id from doctor_credentials
	where user_name= input_username
	and password= input_password;
    
    -- Get Doctor_role and department from doctor table
    select role, Department_id 
    into Doc_role, Doc_department from doctors
    where Doctor_id= Doc_id;
    
    -- Show appropriate Patients detail 
    if Doc_role = 'Senior' then
		select d.Doctor_id, p.patient_id, p.name, p.gender, 
		a.appointmenttime, pr.Medication, b.reportdata 
        from patients p 
		inner join appointments a on p.patient_id=a.patient_id
		join doctors d on d.Doctor_id=a.Doctor_id
		left join prescriptions pr on pr.appointment_id=a.appointment_id
		left join labs b on b.appointment_id=a.appointment_id
		where d.Department_id= Doc_department;
    else 
		select a.Doctor_id, p.patient_id, p.name, p.gender, 
		a.appointmenttime, pr.MEDICATION, b.reportdara from patients p 
		inner join appointments a on p.patient_id=a.patient_id
		left join prescriptions pr on pr.appointment_id=a.appointment_id
		left join labs b on b.appointment_id=a.appointment_id
		where a.Doctor_id = doc_id;
        end if;
End $$


CALL view_doctors_details('doctor4','ic0pFSn0')

-- Create monthly revenue report
DELIMITER //
create procedure SP_MONTHLYREVENUE(IN P_YEAR INT , IN P_MONTH INT)
BEGIN
 select D1.name as DEPARTMENT,
	SUM(B.AMOUNT) AS TOTAL_REVENUE 
	FROM BILLS AS B 
	INNER JOIN APPOINTMENTS AS A ON A.APPOINTMENTID=B.APPOINTMENTID
	INNER JOIN DOCTORS AS D ON A.DOCTORID=D.DOCTORID
	INNER JOIN DEPARTMENTS AS D1 ON D1.DEPARTMENTID=D.DOCTORID
	WHERE  MONTH(B.BILLDATE)=P_MONTH AND YEAR(B.BILLDATE)=P_YEAR
group by D1.NAME;
end//

-- end --
	
	




    
    














  
  
  
  
  
  
  
  
  
 
 
 
 
  
 
