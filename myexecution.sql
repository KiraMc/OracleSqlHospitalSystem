create or replace function find_name(id in number)
return varchar2 is insname varchar2(30);
begin
	case id
	when 0 then insname := 'James';
	when 1 then insname := 'Robert';
	when 2 then insname := 'Mike';
	when 3 then insname := 'Adams';
	when 4 then insname := 'Tracey';
	when 5 then insname := 'Rick';
	end case;

	return insname;
end;
/
 

create or replace procedure pop_dr_sch as
cur_date date := to_date('01/01/2005','mm/dd/yyyy');
day_shift number := 6;
sch_shift number := 0;
begin
	while cur_date != to_date('01/01/2006','mm/dd/yyyy') loop
	      sch_shift := day_shift;
	      insert into dr_schedule values(find_name(mod(sch_shift,6)),'GENERAL_WARD',cur_date);
	      sch_shift := mod(sch_shift+1, 6);
	      insert into dr_schedule values(find_name(mod(sch_shift,6)),'SCREENING_WARD',cur_date);
	      sch_shift := mod(sch_shift+1, 6);
	      insert into dr_schedule values(find_name(mod(sch_shift,6)),'PRE_SURGERY_WARD',cur_date);
	      sch_shift := mod(sch_shift+1, 6);
	      insert into dr_schedule values(find_name(mod(sch_shift,6)),'POST_SURGERY_WARD',cur_date);
	      sch_shift := mod(sch_shift+1, 6);
	      insert into dr_schedule values(find_name(mod(sch_shift,6)),'Surgery',cur_date);

	      if day_shift = 0 then
	      	 insert into dr_schedule values('Rick','Surgery',cur_date);
	      end if;

	      cur_date := cur_date + numtodsinterval(1,'day');
	      day_shift := mod(day_shift + 1,7);
	end loop;
end;
/

create or replace function find_surgeon(wday in number)
return varchar2 is surname varchar2(30);
begin
	case wday
	when 0 then surname := 'Dr.Smith';
	when 1 then surname := 'Dr.Smith';
	when 2 then surname := 'Dr.Richards';
	when 3 then surname := 'Dr.Richards';
	when 4 then surname := 'Dr.Smith';
	when 5 then surname := 'Dr.Richards';
	when 6 then surname := 'Dr.Richards';
	end case;
	return surname;
end;
/

create or replace function gen_sur_duty(cur_date in date,wday in number)
return number is issuc number := 0;
temp_post number := 0;
surname varchar2(30);
begin	

	select count(psw.patient_name) into temp_post from post_surgery_ward psw where psw.post_admission_date = gen_sur_duty.cur_date and psw.patient_type = 'General';

	if temp_post > 0 then
	   insert into surgeon_schedule values(find_surgeon(wday),cur_date);
	   issuc := 1;
	end if;

	return issuc;
end;
/

create or replace procedure pop_sur_sch as
cur_date date := to_date('01/01/2005','mm/dd/yyyy');
day_shift number := 6;
fun_temp number;
begin
	while cur_date != to_date('01/01/2006','mm/dd/yyyy') loop
	      --Neuro and cardiac surgeon duty
	      if day_shift = 2 or day_shift = 3 or day_shift = 5 or day_shift = 6 then
	      	 insert into surgeon_schedule values('Dr.Rutherford',cur_date);
		 insert into surgeon_schedule values('Dr.Gower',cur_date);
	      end if;
	      
	      if day_shift = 0 or day_shift = 1 or day_shift = 4 then
	      	 insert into surgeon_schedule values('Dr.Taylor',cur_date);
		 insert into surgeon_schedule values('Dr.Charles',cur_date);
	      end if;

	      --General surgeon depends on patients
	      fun_temp := gen_sur_duty(cur_date,day_shift);
	      
	      cur_date := cur_date + numtodsinterval(1,'day');
	      day_shift := mod(day_shift + 1, 7);
	end loop;
end;
/

create or replace function work_day_check(wday in number, cur_date in date)
return number is error_wd number := 0;
temp_num number := 0;
begin
	if wday = 0 or wday = 1 or wday = 4 then 
	     select count(ss.name) into temp_num from surgeon_schedule ss where ss.surgery_date = work_day_check.cur_date and ss.name != 'Dr.Smith' and ss.name != 'Dr.Charles' and ss.name != 'Dr.Taylor';
	end if;
	if wday = 2 or wday = 3 or wday = 5 or wday = 6 then
	     select count(ss.name) into temp_num from surgeon_schedule ss where ss.surgery_date = work_day_check.cur_date and ss.name != 'Dr.Richards' and ss.name != 'Dr.Gower' and ss.name != 'Dr.Rutherford';
	end if;

	if temp_num != 0 then
	   error_wd := 1;
	end if;

	return error_wd;
end;
/


create or replace procedure very_dr_sur as
cur_date date := to_date('01/01/2005','mm/dd/yyyy');
start_date date := to_date('01/01/2005','mm/dd/yyyy');
--For dr schedule
dr_one number := 0;
dr_six number := 0;
dr_thr number := 0;
--For sur schedule
su_card number := 0;
su_neu number := 0;
su_wd number := 0;
--General use
temp_num number;
day_shift number := 6;
begin
	while cur_date != to_date('01/01/2006','mm/dd/yyyy') loop
	      --check exact one on duty for each ward
	      select count(*) into temp_num from dr_schedule dr where dr.duty_date = cur_date and (dr.Ward = 'GENERAL_WARD' or dr.Ward = 'SCREENING_WARD' or dr.Ward = 'PRE_SURGERY_WARD' or dr.Ward = 'POST_SURGERY_WARD') and dr.name is not null;
	      if temp_num != 4 then
	      	 dr_one := 1;
	      end if;

	      --check 6 days a week
	      if day_shift = 0 and cur_date != to_date('12/31/2005','mm/dd/yyyy') then
	      	 select count(dr.name) into temp_num from dr_schedule dr where dr.duty_date >= cur_date and dr.duty_date <= cur_date + numtodsinterval(6,'day') and dr.name = 'James';
		 if temp_num != 6 then
		    dr_six := 1;
		 end if;

		 select count(dr.name) into temp_num from dr_schedule dr where dr.duty_date >= cur_date and dr.duty_date <= cur_date + numtodsinterval(6,'day') and dr.name = 'Robert';
		 if temp_num != 6 then
		    dr_six := 2;
		 end if;

		 select count(dr.name) into temp_num from dr_schedule dr where dr.duty_date >= cur_date and dr.duty_date <= cur_date + numtodsinterval(6,'day') and dr.name = 'Mike';
		 if temp_num != 6 then
		    dr_six := 3;
		 end if;

		 select count(dr.name) into temp_num from dr_schedule dr where dr.duty_date >= cur_date and dr.duty_date <= cur_date + numtodsinterval(6,'day') and dr.name = 'Adams';
		 if temp_num != 6 then
		    dr_six := 4;
		 end if;

		 select count(dr.name) into temp_num from dr_schedule dr where dr.duty_date >= cur_date and dr.duty_date <= cur_date + numtodsinterval(6,'day') and dr.name = 'Tracey';
		 if temp_num != 6 then
		    dr_six := 5;
		 end if;

		 select count(dr.name) into temp_num from dr_schedule dr where dr.duty_date >= cur_date and dr.duty_date <= cur_date + numtodsinterval(6,'day') and dr.name = 'Rick';
		 if temp_num != 6 then
		    dr_six := 6;
		 end if;

	      end if;
	      
	      --check 3 consecutive days
	      select max(count(*)) into temp_num from dr_schedule dr1 join dr_schedule dr2 on dr1.name = dr2.name and dr1.ward = dr2.ward where dr1.duty_date >= cur_date and dr1.duty_date <= cur_date + numtodsinterval(2,'day') and dr2.duty_date >= cur_date and dr2.duty_date <= cur_date + numtodsinterval(2,'day') and dr1.duty_date != dr2.duty_date and  dr1.ward != 'Surgery' group by dr1.name,dr1.ward having count(dr1.duty_date) >= 3; 
	      
	      if temp_num >= 3 then
	      	 dr_thr := 1;
	      end if;

	      --check each dat at least on cardiac and one neuro surgeon is on duty
	      select count(ss.name) into temp_num from surgeon_schedule ss where (ss.name = 'Dr.Charles' or ss.name = 'Dr.Gower') and ss.surgery_date = cur_date;
	      if temp_num < 1 then
	      	 su_card := 1;
	      end if;

	      select count(ss.name) into temp_num from surgeon_schedule ss where (ss.name = 'Dr.Taylor' or ss.name = 'Dr.Rutherford') and ss.surgery_date = cur_date;
	      if temp_num < 1 then
	      	 su_neu := 1;
	      end if;

	      --check the work day for each doctor or surgeon
	      temp_num := work_day_check(day_shift, cur_date);
	      if temp_num != 0 then
	      	 su_wd := 1;
	      end if;

	      cur_date := cur_date + numtodsinterval(1,'day');
	      day_shift := mod(day_shift + 1,7);
	end loop;

	if dr_one != 0 then
	   dbms_output.put_line('DR_SCHEDULE Error: Each ward has to have exactly one doctor on duty for each day!');
	end if;

	if dr_six != 0 then
	   dbms_output.put_line('DR_SCHEDULE Error: Each doctor needs to work six days per week!');
	end if;

	if dr_thr != 0 then
	   dbms_output.put_line('DR_SCHEDULE Error: No Doctor can work in the same ward for 3 consecutive days!');
	end if;

	if su_card != 0 then
	   dbms_output.put_line('Surgeon_Schedule Error: each day at least on cardiac surgeon is on duty!');
	end if;

	if su_neu != 0 then
	   dbms_output.put_line('Surgeon_Schedule Error: each day at least on neuro surgeon is on duty!');
	end if;

	if su_wd != 0 then
	   dbms_output.put_line('Surgeon_Schedule Error: Every surgeon has his own duty week days!');
	end if;

end;
/

--Display schedule for each patients
declare
scr_ad date;
pre_ad date;
post_ad date;
begin
	dbms_output.put_line('-------Display Schedule for each patient for each visit---------------');
	dbms_output.put_line('Name' || '           ' || 'General Admission' || '         ' || 'Screen Admission' || '    ' || 'Pre Admission' || '      ' || 'Post Admission' || '      ' || 'Discharge');
	for visits in (select * from all_info ai order by ai.pname,ai.ad_date) loop
	    scr_ad := visits.ad_date + numtodsinterval(visits.gen_stay,'day');
	    pre_ad := scr_ad + numtodsinterval(visits.scr_stay,'day');
	    post_ad := pre_ad + numtodsinterval(visits.pre_stay,'day');
	    dbms_output.put_line(visits.pname || '      ' || visits.ad_date || '        ' || scr_ad || '                ' || pre_ad || '               ' || post_ad || '         ' || visits.discharge);
	end loop;
end;
/


--Pop Dr_schedule table
execute pop_dr_sch;

--Pop Sur_schedule table
execute pop_sur_sch;

--Display dr_schedule table
execute dbms_output.put_line('--------------DR_Schedule Table---------------');
select * from dr_schedule ds order by ds.duty_date;

--Display Sur_schedule table
execute dbms_output.put_line('------------Surgeon_Schedule Table-------------');
select * from surgeon_schedule ss order by ss.surgery_date;


--Create View
--Populate surgeon information
begin
	insert into surgeon_info values('Dr.Rutherford','Neuro');
	insert into surgeon_info values('Dr.Taylor','Neuro');
	insert into surgeon_info values('Dr.Smith','General');
	insert into surgeon_info values('Dr.Richards','General');
	insert into surgeon_info values('Dr.Charles','Cardiac');
	insert into surgeon_info values('Dr.Gower','Cardiac');
end;
/

--create view patient_surgery_view as
create view patient_surgery_view as
select pss.patient_name,pss.surgery_date,pss.name Doctor from 
(select psw.patient_name,ss.surgery_date,ss.name,psw.patient_type from post_surgery_ward psw join surgeon_schedule ss on psw.post_admission_date = ss.surgery_date) pss join
surgeon_info si on pss.name = si.name where pss.patient_type = si.s_type
union
select pss.patient_name,pss.surgery_date,pss.name Doctor from 
(select psw.patient_name,ss.surgery_date,ss.name,psw.patient_type from post_surgery_ward psw join surgeon_schedule ss on psw.post_admission_date + numtodsinterval(2,'day') = ss.surgery_date where psw.scount = 2) pss join
surgeon_info si on pss.name = si.name where pss.patient_type = si.s_type order by surgery_date;


--Display view
execute dbms_output.put_line('---------Patient_Surgery_View-----------');
select * from patient_surgery_view;
