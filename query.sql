--Q1---------------------------
declare
v_number number;
avg_stay number;
cost_reim number := 0;
begin
	dbms_output.put_line('----------Q1------------');
	dbms_output.put_line('Name' || '           ' || 'Visits' || '      ' || 'Average Stay' || '        ' || 'Cost reimbursement');
	
	for patients in (select distinct pi.patient_name from patient_input pi where pi.general_ward_admission_date >= to_date('01/01/05','mm/dd/yy') and pi.general_ward_admission_date < to_date('01/01/06','mm/dd/yy')) loop
	    cost_reim := 0;
	    --find visit number
	    select count(pi.general_ward_admission_date) into v_number from patient_input pi where pi.patient_name = patients.patient_name;

	    --find average stay
	    select avg(tt.tot_stay) into avg_stay from (select (ai.discharge - ai.ad_date) tot_stay from all_info ai where ai.pname = patients.patient_name) tt;

	    --find total cost reimbursed
	    for visits in (select * from all_info ai where ai.pname = patients.patient_name) loop
	    	--ward fee
	    	cost_reim := cost_reim + least(visits.gen_stay,3) * 50 *0.8 + greatest(visits.gen_stay - 3, 0)*50*0.7 + least(visits.scr_stay,2) * 70 *0.85 + greatest(visits.scr_stay - 2, 0)*70*0.75;
		-- surgery fee
		if visits.ptype = 'General' then
		   cost_reim := cost_reim + 2500*0.65 + (visits.scount - 1)*2500*0.6;
		elsif visits.ptype = 'Neuro' then
		      cost_reim := cost_reim + 5000*0.85 + (visits.scount - 1)*5000*0.8;
		elsif visits.ptype = 'Cardiac' then
		      cost_reim := cost_reim + 3500*0.75 + (visits.scount - 1)*3500*0.7;
		end if;
	    end loop;

	    dbms_output.put_line(patients.patient_name || '              ' || v_number || '         ' || round(avg_stay,0) || '          ' || cost_reim);
	end loop;	
end;
/

--Q2---------------------------
declare
total_cost number := 0;
visit_num number := 0;
patient_num number;
avg_visit number;
avg_pat number;
begin
	dbms_output.put_line('------------------Q2---------------');
	dbms_output.put_line('Total cost' || '      ' || 'Average cost per patient' || '          ' || 'Average cost per visit');

	for visits in (select * from all_info ai where ai.ad_date >= to_date('01/01/05','mm/dd/yy') and ai.ad_date < to_date('01/01/06','mm/dd/yy')) loop
	    total_cost := total_cost + least(visits.gen_stay,3) * 50 *0.8 + greatest(visits.gen_stay - 3, 0)*50*0.7 + least(visits.scr_stay,2) * 70 *0.85 + greatest(visits.scr_stay - 2, 0)*70*0.75;
	    -- surgery fee
	    if visits.ptype = 'General' then
	       total_cost := total_cost + 2500*0.65 + (visits.scount - 1)*2500*0.6;
	    elsif visits.ptype = 'Neuro' then
	    	  total_cost := total_cost + 5000*0.85 + (visits.scount - 1)*5000*0.8;
	    elsif visits.ptype = 'Cardiac' then
	    	  total_cost := total_cost + 3500*0.75 + (visits.scount - 1)*3500*0.7;
	    end if;
	    visit_num := visit_num + 1;
	end loop;
	
	avg_visit := total_cost / visit_num;
	
	select count(distinct ai.pname) into patient_num from all_info ai where ai.ad_date >= to_date('01/01/05','mm/dd/yy') and ai.ad_date < to_date('01/01/06','mm/dd/yy');
	avg_pat := total_cost / patient_num;

	dbms_output.put_line(total_cost || '               ' || round(avg_pat,3) || '                       ' || round(avg_visit,3));
end;
/

--Q3--------------------------------
declare
bob_ad date;
bob_dis date;
avg_stay number;
begin
	dbms_output.put_line('------------------Q3---------------');
	dbms_output.put_line('Name' || '                ' || 'Average Stay');
	select ai.ad_date into bob_ad from all_info ai where ai.pname = 'Bob' and ai.visits = 2;
	select ai.discharge into bob_dis from all_info ai where ai.pname = 'Bob' and ai.visits = 2;


	for patients in (select distinct ai.pname from all_info ai where ai.ad_date = bob_ad and ai.discharge < bob_dis) loop
	    select avg(tt.tot_stay) into avg_stay from (select (ai.discharge - ai.ad_date) tot_stay from all_info ai where ai.pname = patients.pname) tt;
	    dbms_output.put_line(patients.pname || '                   ' || round(avg_stay,0));
	end loop;
end;
/

--Q4-----------------------------
--First insert the interval and surgery number into table
declare
int_start date := to_date('01/01/05','mm/dd/yy');
int_end date := to_date('01/01/05','mm/dd/yy');
cur_date date;
sur_num number := 0;
s_exist1 number := 0;
s_exist2 number := 0;
begin
	dbms_output.put_line('------------Q4--------------------');
	cur_date := int_start;
	while cur_date != to_date('01/01/06','mm/dd/yy') loop
	      select count(psw.patient_name) into s_exist1 from post_surgery_ward psw where psw.post_admission_date = cur_date;
	      if s_exist1 > 0 then
	      	 sur_num := sur_num + s_exist1;
	      end if;

	      select count(psw.patient_name) into s_exist2 from post_surgery_ward psw where psw.post_admission_date = cur_date - numtodsinterval(2,'day') and psw.scount = 2;
	      if s_exist2 > 0 then
	      	 sur_num := sur_num + s_exist2;
	      end if;

	      if s_exist1 = 0 and s_exist2 = 0 then
	      	 int_end := cur_date - numtodsinterval(1,'day');
		 if int_end >= int_start then
		    insert into int_sur values(int_start,int_end,sur_num);
		 end if;
		 sur_num := 0;
		 int_start := cur_date + numtodsinterval(1,'day');
	      end if;

	      cur_date := cur_date + numtodsinterval(1,'day');
	end loop;
end;
/
--Display the int_sur table
select * from int_sur order by surnum desc;


--Q5-----------------------------
declare
start_date date := to_date('04/01/05','mm/dd/yy');
end_date date := to_date('04/01/05','mm/dd/yy');
cur_date date := to_date('04/01/05','mm/dd/yy');
temp_num number;
sc number;
wday number := 5;
begin
	dbms_output.put_line('------------------Q5---------------');
	dbms_output.put_line('Start date' || '                ' || 'End date');
	
	while cur_date != to_date('05/01/05','mm/dd/yy') loop
	      select count(psw.patient_name) into sc from post_surgery_ward psw where psw.post_admission_date + numtodsinterval(2,'day') = cur_date and psw.scount = 2;
	      if sc > 0 then
	      	 if wday = 2 or wday = 3 or wday = 5 or wday = 6 then
		   select count(psw.patient_name) into temp_num from post_surgery_ward psw where psw.post_admission_date + numtodsinterval(2,'day') = cur_date and psw.patient_type = 'Cardiac';
	      	 else		
		   select count(psw.patient_name) into temp_num from post_surgery_ward psw where psw.post_admission_date + numtodsinterval(2,'day') = cur_date and psw.patient_type = 'Neuro';
	      	 end if;

		 if temp_num > 0 then
		   end_date := cur_date - numtodsinterval(1,'day');
		   if end_date >= start_date then
		      dbms_output.put_line(start_date || '             ' || end_date);
		   end if;
		   start_date := cur_date + numtodsinterval(1,'day');
	      	 end if;
	      else
		if wday = 2 or wday = 3 or wday = 5 or wday = 6 then
		   select count(psw.patient_name) into temp_num from post_surgery_ward psw where psw.post_admission_date = cur_date and psw.patient_type = 'Cardiac';
	      	else		
		   select count(psw.patient_name) into temp_num from post_surgery_ward psw where psw.post_admission_date = cur_date and psw.patient_type = 'Neuro';
	      	end if;

	      	if temp_num > 0 then
		   end_date := cur_date - numtodsinterval(1,'day');
		   if end_date >= start_date then
		      dbms_output.put_line(start_date || '             ' || end_date);
		   end if;
		   start_date := cur_date + numtodsinterval(1,'day');
	      	end if;
	     end if;

	     if cur_date = to_date('04/30/05','mm/dd/yy') then
	      	 select count(psw.patient_name) into temp_num from post_surgery_ward psw where psw.post_admission_date = cur_date and psw.patient_type = 'Cardiac';
		 if temp_num = 0 then
		    dbms_output.put_line(start_date || '             ' || cur_date);
		 end if;
	      end if;
	      wday := mod(wday+1,7);
	      cur_date := cur_date + numtodsinterval(1,'day');
	end loop;
end;
/

--Q6---------------------------------
declare
bob_date date;
cost_reim number := 0;
begin
	dbms_output.put_line('-------------------Q6-----------------');
	dbms_output.put_line('Nmae' || '               ' || 'Cost Reimbursed');
	
	begin
		select (ai.discharge - numtodsinterval(2,'day')) into bob_date from all_info ai where ai.pname = 'Bob' and ai.visits = 3 and ai.scount = 2;
	exception
		when no_data_found then
		     raise_application_error(-20000,'Can not find information for Bobs 3rd visits');
	end;

	for visits in (select * from all_info ai where ai.discharge >= bob_date - numtodsinterval(3,'day') and ai.discharge <= bob_date + numtodsinterval(3,'day') and ai.pname != 'Bob') loop
	    cost_reim := 0;

	    cost_reim := cost_reim + least(visits.gen_stay,3) * 50 *0.8 + greatest(visits.gen_stay - 3, 0)*50*0.7 + least(visits.scr_stay,2) * 70 *0.85 + greatest(visits.scr_stay - 2, 0)*70*0.75;

	    if visits.ptype = 'General' then
		   cost_reim := cost_reim + 2500*0.65 + (visits.scount - 1)*2500*0.6;
	    elsif visits.ptype = 'Neuro' then
		   cost_reim := cost_reim + 5000*0.85 + (visits.scount - 1)*5000*0.8;
	    elsif visits.ptype = 'Cardiac' then
		   cost_reim := cost_reim + 3500*0.75 + (visits.scount - 1)*3500*0.7;
	    end if;

	    dbms_output.put_line(visits.pname || '                  ' || cost_reim);

	end loop;
end;
/

--Q7---------------------------------
declare
start_date date := to_date('04/10/05','mm/dd/yy');
cur_date date;
wday number := 6;
scn number;
pname varchar2(30);
sname varchar2(30);
apname varchar2(30);
temp_num number := 0;
begin
	dbms_output.put_line('-------------------Q7-----------------');
	dbms_output.put_line('Patient Name' || '               ' || 'Surgeon Name' || '                ' || 'Assisting Physician Name');

	cur_date := start_date;

	while cur_date != start_date + numtodsinterval(7,'day') loop
	      begin
		select psw.patient_name into pname from post_surgery_ward psw where psw.post_admission_date + numtodsinterval(2,'day') = cur_date and psw.scount = 2 and psw.patient_type = 'Cardiac';
		select ss.name into sname from surgeon_schedule ss where ss.surgery_date = cur_date and (name = 'Dr.Charles' or name = 'Dr.Gower');
		select count(ds.name) into temp_num from dr_schedule ds where ds.duty_date = cur_date and ward = 'Surgery';
		if temp_num > 0 then
		   select ds.name into apname from dr_schedule ds where ds.duty_date = cur_date and ward = 'Surgery'; 
		end if;

		dbms_output.put_line(pname || '                ' || sname || '              ' || apname);
	      exception
		when no_data_found then
		     scn := 0;
	      end;

	      begin
		select psw.patient_name into pname from post_surgery_ward psw where psw.post_admission_date = cur_date and psw.patient_type = 'Cardiac';
		select ss.name into sname from surgeon_schedule ss where ss.surgery_date = cur_date and (name = 'Dr.Charles' or name = 'Dr.Gower');
		select count(ds.name) into temp_num from dr_schedule ds where ds.duty_date = cur_date and ward = 'Surgery';
		if temp_num > 0 then
		   select ds.name into apname from dr_schedule ds where ds.duty_date = cur_date and ward = 'Surgery'; 
		end if;

		dbms_output.put_line(pname || '                ' || sname || '              ' || apname);
	      exception
		when no_data_found then
		     scn := 0;
	      end;
	      cur_date := cur_date + numtodsinterval(1,'day');
	end loop;
end;
/


--Q8----------------------------------------------------------
declare
start_date date;
end_date date;
cur_date date;
int_start date;
int_end date;
drward varchar2(30);
bobward varchar2(30);
bobgen number;
bobscr number;
bobpre number;
bobpost number;
exit_temp number := 1;
p_flag number := 0;
begin
	dbms_output.put_line('-------------Q8--------------------------');
	dbms_output.put_line('Start date' ||'             '||'End date');
	
	select ai.ad_date into start_date from all_info ai where ai.pname = 'Bob' and ai.visits = 3;
	select ai.discharge into end_date from all_info ai where ai.pname = 'Bob' and ai.visits = 3;

	select ai.gen_stay into bobgen from all_info ai where ai.pname = 'Bob' and ai.visits = 3;
	select ai.scr_stay into bobscr from all_info ai where ai.pname = 'Bob' and ai.visits = 3;
	select ai.pre_stay into bobpre from all_info ai where ai.pname = 'Bob' and ai.visits = 3;
	select ai.post_stay into bobpost from all_info ai where ai.pname = 'Bob' and ai.visits = 3;


	cur_date := start_date;
	int_start := start_date;
	int_end := start_date;
	while cur_date != end_date loop
	      exit_temp := 1;
	      p_flag := 0;
	      begin
		select ds.ward into drward from dr_schedule ds where ds.name = 'Adams' and ds.duty_date = cur_date;
	      exception
		when no_data_found then
		     exit_temp := 0;
	      end;
	      if exit_temp = 1 then
	      	 case drward
		 when 'GENERAL_WARD' then 
		      if cur_date >= start_date and cur_date < start_date + numtodsinterval(bobgen,'day') then
		      	 p_flag := 1;
		      end if;
		 when 'SCREENING_WARD' then
		      if cur_date >= start_date + numtodsinterval(bobgen,'day') and cur_date < start_date + numtodsinterval(bobgen,'day') + numtodsinterval(bobscr,'day') then
		      	 p_flag := 1;
		      end if;
		 WHEN 'PRE_SURGERY_WARD' then
		      if cur_date >= start_date + numtodsinterval(bobgen,'day') +  numtodsinterval(bobscr,'day') and cur_date < start_date + numtodsinterval(bobgen,'day') + numtodsinterval(bobscr,'day') + numtodsinterval(bobpre,'day')then
		      	 p_flag := 1;
		      end if;
		 when 'POST_SURGERY_WARD' then
		      if cur_date >= start_date + numtodsinterval(bobgen,'day') +  numtodsinterval(bobscr,'day') + numtodsinterval(bobpre,'day') and cur_date < start_date + numtodsinterval(bobgen,'day') + numtodsinterval(bobscr,'day') + numtodsinterval(bobpre,'day') + numtodsinterval(bobpost,'day') then
		      	 p_flag := 1;
		      end if;
		 else
			p_flag := 0;
		 end case;
	      end if;

	      if p_flag = 1 then
	      	 int_end := cur_date - numtodsinterval(1,'day');
		 if int_end >= int_start then
		    dbms_output.put_line(int_start||'              '||int_end);
		 end if;
		 int_start := cur_date + numtodsinterval(1,'day');
	      end if;

	      if p_flag = 0 and cur_date = end_date - numtodsinterval(1,'day') and cur_date >= int_start then
	      	 dbms_output.put_line(int_start || '              '||cur_date);
	      end if;	      

	      cur_date := cur_date + numtodsinterval(1,'day');
	end loop;
end;
/

--Q9--------------------------------------------------------
declare
cur_date date := to_date('01/01/05','mm/dd/yy');
end_date date := to_date('01/01/06','mm/dd/yy');
int_start date;
int_end date;
oleng number := 0;
exit_temp1 number;
exit_temp2 number;
exit_temp3 number;
bobbp number;
bobbp2 number;
bobbp3 number;
begin
	dbms_output.put_line('-----------------Q9-------------------');
	dbms_output.put_line('Overall Length');
	int_start := cur_date;
	int_end := cur_date;
	while cur_date != end_date loop
	      select count(pc.bp) into exit_temp1 from patient_chart pc where pc.patient_name = 'Bob' and pc.pdate = cur_date;

	      if exit_temp1 = 0 then
	      	 int_end := cur_date - numtodsinterval(1,'day');
		 if int_end >= int_start then
		    oleng := oleng + (int_end - int_start) + 1;
		    --dbms_output.put_line(int_start||'     '||int_end);
		 end if;
		 int_start := cur_date + numtodsinterval(1,'day');
	      else
		 select pc.bp into bobbp from patient_chart pc where pc.patient_name = 'Bob' and pc.pdate = cur_date;
		 if bobbp < 110 or bobbp > 140 then
		    select count(pc.bp) into exit_temp2 from patient_chart pc where pc.patient_name = 'Bob' and pc.pdate = cur_date - numtodsinterval(1,'day');
		    if exit_temp2 != 0 then
		       select pc.bp into bobbp2 from patient_chart pc where pc.patient_name = 'Bob' and pc.pdate = cur_date - numtodsinterval(1,'day');
		       if bobbp2 < 110 or bobbp2 > 140 then
		       	  select count(pc.bp) into exit_temp3 from patient_chart pc where pc.patient_name = 'Bob' and pc.pdate = cur_date - numtodsinterval(2,'day');
			  if exit_temp3 != 0 then
			     select pc.bp into bobbp3 from patient_chart pc where pc.patient_name = 'Bob' and pc.pdate = cur_date - numtodsinterval(2,'day');
			     if bobbp3 < 110 or bobbp3 > 140 then
			     	int_end := cur_date - numtodsinterval(1,'day');
				if int_end >= int_start then
				   oleng := oleng + (int_end - int_start) + 1;
				   --dbms_output.put_line(int_start || '     '||int_end);
				end if;
				int_start := cur_date + numtodsinterval(1,'day');
			     end if;
			  end if;
		       end if;
		    end if;
		 elsif cur_date = end_date - numtodsinterval(1,'day') then
		       int_end := cur_date;
		       if int_end >= int_start then
		       	  oleng := oleng + (int_end - int_start) + 1;
		       	  --dbms_output.put_line(int_start || '     '||int_end);
		       end if;
		 end if;
	      end if; 
	      cur_date := cur_date + numtodsinterval(1,'day');
	end loop;
	dbms_output.put_line(oleng);
end;
/

--10------------------------------------------------
declare
pre_v_dis date := null;
pre_sur varchar2(30) := null;
reim_mul number := 0;
current_reim number := 0;
sur1_name varchar2(30);
sur2_name varchar2(30);
v_num number :=0;
suc_v number :=0;
print_flag number := 0;
begin
	dbms_output.put_line('------------------Q10--------------------');
	dbms_output.put_line('Name'||'                             ' || 'Cost Reimbursed for Acceptable Visists');
	for patients in (select distinct ai.pname from all_info ai where ai.ad_date >= to_date('01/01/05','mm/dd/yy') and ai.ad_date < to_date('01/01/06','mm/dd/yy') and ai.visits > 1) loop
	    reim_mul := 0;
	    current_reim := 0;
	    pre_v_dis := null;
	    v_num := 0;
	    print_flag := 0;
	    for visits in (select * from all_info ai where ai.pname = patients.pname order by ai.visits) loop
	    	suc_v := 1;
	    	if visits.scount != 2 then
		   suc_v := 0;
		else
			if visits.ptype = 'General' then
			   select ss.name into sur1_name from surgeon_schedule ss where ss.surgery_date = visits.discharge - numtodsinterval(4,'day') and (ss.name = 'Dr.Smith' or ss.name = 'Dr.Richards');
			   select ss.name into sur2_name from surgeon_schedule ss where ss.surgery_date = visits.discharge - numtodsinterval(2,'day') and (ss.name = 'Dr.Smith' or ss.name = 'Dr.Richards');
			elsif visits.ptype = 'Neuro' then
			      select ss.name into sur1_name from surgeon_schedule ss where ss.surgery_date = visits.discharge - numtodsinterval(4,'day') and (ss.name = 'Dr.Taylor' or ss.name = 'Dr.Rutherford');
			      select ss.name into sur2_name from surgeon_schedule ss where ss.surgery_date = visits.discharge - numtodsinterval(2,'day') and (ss.name = 'Dr.Taylor' or ss.name = 'Dr.Rutherford');
			else
				select ss.name into sur1_name from surgeon_schedule ss where ss.surgery_date = visits.discharge - numtodsinterval(4,'day') and (ss.name = 'Dr.Charles' or ss.name = 'Dr.Gower');
			   	select ss.name into sur2_name from surgeon_schedule ss where ss.surgery_date = visits.discharge - numtodsinterval(2,'day') and (ss.name = 'Dr.Charles' or ss.name = 'Dr.Gower');
			end if;

			if sur1_name != sur2_name then
			   suc_v := 0;
			end if;
		end if;

		if pre_sur is not null and suc_v = 1 then
		   if pre_sur != sur1_name then
		      suc_v := 0;
		   end if;
		end if;

		if pre_v_dis is not null and suc_v = 1 then
		   if visits.ad_date - pre_v_dis <= 5 or visits.ad_date - pre_v_dis >= 14 then
		      suc_v := 0;
		   end if;
		end if;

		if suc_v = 0 then
		   if v_num >= 2 then
		      print_flag := 1;
		      reim_mul := reim_mul + current_reim;
		      v_num := 0;
		   end if;
		   current_reim := 0;
		   pre_v_dis := null;
		   pre_sur := null;
		else
			v_num := v_num + 1;
			current_reim := current_reim + least(visits.gen_stay,3) * 50 *0.8 + greatest(visits.gen_stay - 3, 0)*50*0.7 + least(visits.scr_stay,2) * 70 *0.85 + greatest(visits.scr_stay - 2, 0)*70*0.75;
			if visits.ptype = 'General' then
		   	   current_reim := current_reim + 2500*0.65 + (visits.scount - 1)*2500*0.6;
			elsif visits.ptype = 'Neuro' then
		      	      current_reim := current_reim + 5000*0.85 + (visits.scount - 1)*5000*0.8;
			elsif visits.ptype = 'Cardiac' then
		      	      current_reim := current_reim + 3500*0.75 + (visits.scount - 1)*3500*0.7;
			end if;

			pre_v_dis := visits.discharge;
			pre_sur := sur1_name;
		end if;
	    end loop;

	    if print_flag = 1 then
	    dbms_output.put_line(patients.pname||'                  '||reim_mul);
	    end if;
	end loop;
	
end;
/
