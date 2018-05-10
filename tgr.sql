create table all_info
(
	pname varchar2(30),
	visits number,
	ad_date date,
	gen_stay number,
	scr_stay number,
	pre_stay number,
	post_stay number,
	discharge date,
	scount number,
	ptype varchar2(10),
	constraint all_pri primary key(pname,ad_date)
);

create table surgeon_info
(
	name varchar2(30),
	s_type varchar2(10)
);

create table int_sur
(
	start_date date,
	end_date date,
	surnum number
);

create table scr_bed
(
	calendar date primary key,
	bed1 varchar2(30),
	bed2 varchar2(30),
	bed3 varchar2(30),
	bed4 varchar2(30),
	bed5 varchar2(30)
);

create table pre_bed
(
	calendar date primary key,
	bed1 varchar2(30),
	bed2 varchar2(30),
	bed3 varchar2(30),
	bed4 varchar2(30)
);

create or replace trigger trg_gen
after insert on general_ward
for each row
declare
	stay_int interval day to second := numtodsinterval(3,'day');
	date_exist number;
	ext_flag number := 0;
	--for all_info
	visited number := 0;
begin
	--Update all_info
	select count(ai.ad_date) into visited from all_info ai where ai.pname = :new.patient_name;
	insert into all_info(pname,visits,ad_date,ptype) values(:new.patient_name,visited+1,:new.g_admission_date,:new.patient_type);

	--Real insertion
	while true loop
		select count(scr.calendar) into date_exist from scr_bed scr where trunc(scr.calendar) = trunc(:new.G_Admission_Date) + stay_int;

		if date_exist = 0 then
		   --update all_info
		   update all_info set gen_stay = extract(day from stay_int) where pname = :new.patient_name and discharge is null;
		   insert into screening_ward values(:new.patient_name,:new.g_admission_date + stay_int,1,:new.patient_type);
		   exit;
		else
			for trydate in (select * from scr_bed scr where trunc(scr.calendar) = trunc(:new.G_Admission_Date) + stay_int) loop
			    if trydate.bed1 is null then
			       --update all_info
		   	       update all_info set gen_stay = extract(day from stay_int) where pname = :new.patient_name and discharge is null;
			       insert into screening_ward values(:new.patient_name,:new.g_admission_date + stay_int,1,:new.patient_type);
			       ext_flag := 1;
			    elsif trydate.bed2 is null then
			    	  --update all_info
		   		  update all_info set gen_stay = extract(day from stay_int) where pname = :new.patient_name and discharge is null;
			    	  insert into screening_ward values(:new.patient_name,:new.g_admission_date + stay_int,2,:new.patient_type);
				  ext_flag := 1;
			    elsif trydate.bed3 is null then
			    	  --update all_info
		   		  update all_info set gen_stay = extract(day from stay_int) where pname = :new.patient_name and discharge is null;
			    	  insert into screening_ward values(:new.patient_name,:new.g_admission_date + stay_int,3,:new.patient_type);
				  ext_flag := 1;
			    elsif trydate.bed4 is null then
			    	  --update all_info
		   		  update all_info set gen_stay = extract(day from stay_int) where pname = :new.patient_name and discharge is null;
			    	  insert into screening_ward values(:new.patient_name,:new.g_admission_date + stay_int,4,:new.patient_type);
				  ext_flag := 1;
			    elsif trydate.bed5 is null then
			    	  --update all_info
		   		  update all_info set gen_stay = extract(day from stay_int) where pname = :new.patient_name and discharge is null;
		   	    	  insert into screening_ward values(:new.patient_name,:new.g_admission_date + stay_int,5,:new.patient_type);
				  ext_flag := 1;
			    else
				ext_flag := 0;
			    end if;
			end loop;

			if ext_flag = 0 then
			   stay_int := stay_int + numtodsinterval(1,'day');
			else
				exit;
			end if;
		end if;
	end loop;
end;
/

create or replace function modscrbed(calendar in date, bed in number, pn in varchar2)
return number is fcsuc number := 1;
begin
	case modscrbed.bed
	     when 1 then begin
	     	    	 insert into scr_bed(calendar,bed1) values(modscrbed.calendar,modscrbed.pn);
			 exception
				when dup_val_on_index then
				     update scr_bed set bed1 = modscrbed.pn where calendar = modscrbed.calendar;
			 end;
	     when 2 then begin
	     	    	 insert into scr_bed(calendar,bed2) values(modscrbed.calendar,modscrbed.pn);
			 exception
				when dup_val_on_index then
				     update scr_bed set bed2 = modscrbed.pn where calendar = modscrbed.calendar;
			 end;
	     when 3 then begin
	     	    	 insert into scr_bed(calendar,bed3) values(modscrbed.calendar,modscrbed.pn);
			 exception
				when dup_val_on_index then
				     update scr_bed set bed3 = modscrbed.pn where calendar = modscrbed.calendar;
			 end;
	     when 4 then begin
	     	    	 insert into scr_bed(calendar,bed4) values(modscrbed.calendar,modscrbed.pn);
			 exception
				when dup_val_on_index then
				     update scr_bed set bed4 = modscrbed.pn where calendar = modscrbed.calendar;
			 end;
	     when 5 then begin
	     	    	 insert into scr_bed(calendar,bed5) values(modscrbed.calendar,modscrbed.pn);
			 exception
				when dup_val_on_index then
				     update scr_bed set bed5 = modscrbed.pn where calendar = modscrbed.calendar;
			 end;
	end case;
	return fcsuc;
end;
/

create or replace function scr_sur(start_date in date,time_int in interval day to second,pn in varchar2)
return number is fcsuc number;
counter number := 4;
fc_bp number;
fc_temp number;
ti_temp interval day to second := time_int;
begin
	fcsuc := 0;
	while counter != 0 loop
	      ti_temp := ti_temp - numtodsinterval(1,'day');
	      select pc.bp into fc_bp from patient_chart pc where pc.patient_name = scr_sur.pn and pc.pdate = scr_sur.start_date + ti_temp;
	      select pc.temperature into fc_temp from patient_chart pc where pc.patient_name = scr_sur.pn and pc.pdate = scr_sur.start_date + ti_temp;
	      if fc_bp < 110 or fc_bp > 140 or fc_temp < 97 or fc_temp > 100 then
	      	 exit;
	      end if;
	      counter := counter - 1;
	end loop;
	if counter = 0 then
	   fcsuc := 1;
	end if;

	return fcsuc;
end;
/

create or replace trigger trg_scr
after insert on screening_ward
for each row
declare
	stay_int interval day to second := numtodsinterval(3,'day');
	date_exist number;
	ext_flag number := 0;
	fun_flag number;
	direct_flag number;
begin
	while true loop
	      	--try to insert into surgery directly
		if stay_int >= numtodsinterval(4,'day') then
		   direct_flag := scr_sur(:new.s_admission_date,stay_int,:new.patient_name);
		   if direct_flag = 1 then
		      --Update all_info
		      update all_info set scr_stay = extract(day from stay_int) where pname = :new.patient_name and discharge is null;
		      --Real insertion
		      insert into post_surgery_ward(patient_name,post_admission_date,scount,patient_type) values(:new.patient_name,:new.s_admission_date + stay_int,1,:new.patient_type);
		      while stay_int != numtodsinterval(0,'day') loop
		      	    stay_int := stay_int - numtodsinterval(1,'day');
			    fun_flag := modscrbed(:new.s_admission_date + stay_int, :new.bed_no,:new.patient_name);
		      end loop;
		      exit;
		   end if;
		end if;

		--try to insert into pre_surgery_ward
		select count(pre.calendar) into date_exist from pre_bed pre where trunc(pre.calendar) = trunc(:new.S_Admission_Date) + stay_int;
		if date_exist = 0 then
		   --Update all_info
		   update all_info set scr_stay = extract(day from stay_int) where pname = :new.patient_name and discharge is null;
		   insert into pre_surgery_ward values(:new.patient_name,:new.s_admission_date + stay_int,1,:new.patient_type);
		   while stay_int != numtodsinterval(0,'day') loop
		   	 stay_int := stay_int - numtodsinterval(1,'day');
		   	 fun_flag := modscrbed(:new.s_admission_date + stay_int,:new.bed_no,:new.patient_name);
		   end loop;
		   exit;
		else
			for trydate in (select * from pre_bed pre where trunc(pre.calendar) = trunc(:new.S_Admission_Date) + stay_int) loop
			    if trydate.bed1 is null then
			       --Update all_info
		      	       update all_info set scr_stay = extract(day from stay_int) where pname = :new.patient_name and discharge is null;
			       insert into pre_surgery_ward values(:new.patient_name,:new.s_admission_date + stay_int,1,:new.patient_type);
			       while stay_int != numtodsinterval(0,'day') loop
		   	       	     stay_int := stay_int - numtodsinterval(1,'day');
		   	 	     fun_flag := modscrbed(:new.s_admission_date + stay_int,:new.bed_no,:new.patient_name);
		   	       end loop;
			       ext_flag := 1;
			    elsif trydate.bed2 is null then
			    	  --Update all_info
		      	       	  update all_info set scr_stay = extract(day from stay_int) where pname = :new.patient_name and discharge is null;
			    	  insert into pre_surgery_ward values(:new.patient_name,:new.s_admission_date + stay_int,2,:new.patient_type);
			       	  while stay_int != numtodsinterval(0,'day') loop
		   	       	     stay_int := stay_int - numtodsinterval(1,'day');
		   	 	     fun_flag := modscrbed(:new.s_admission_date + stay_int,:new.bed_no,:new.patient_name);
		   	       	  end loop;
				  ext_flag := 1;
			    elsif trydate.bed3 is null then
			    	  --Update all_info
		      	       	  update all_info set scr_stay = extract(day from stay_int) where pname = :new.patient_name and discharge is null;
			    	  insert into pre_surgery_ward values(:new.patient_name,:new.s_admission_date + stay_int,3,:new.patient_type);
			       	  while stay_int != numtodsinterval(0,'day') loop
		   	       	     stay_int := stay_int - numtodsinterval(1,'day');
		   	 	     fun_flag := modscrbed(:new.s_admission_date + stay_int,:new.bed_no,:new.patient_name);
		   	       	  end loop;
				  ext_flag := 1;
			    elsif trydate.bed4 is null then
			    	  --Update all_info
		      	       	  update all_info set scr_stay = extract(day from stay_int) where pname = :new.patient_name and discharge is null;
			    	  insert into pre_surgery_ward values(:new.patient_name,:new.s_admission_date + stay_int,4,:new.patient_type);
			       	  while stay_int != numtodsinterval(0,'day') loop
		   	       	     stay_int := stay_int - numtodsinterval(1,'day');
		   	 	     fun_flag := modscrbed(:new.s_admission_date + stay_int,:new.bed_no,:new.patient_name);
		   	       	  end loop;
				  ext_flag := 1;
			    else
				ext_flag := 0;
			    end if;
			end loop;

			if ext_flag = 0 then
			   stay_int := stay_int + numtodsinterval(1,'day');
			else
				exit;
			end if;
		end if;
	end loop;
end;
/

create or replace trigger trg_pre
after insert on pre_surgery_ward
for each row
declare
	stay_int interval day to second := numtodsinterval(2,'day');
begin
	--Update all_info
	update all_info set pre_stay = extract(day from stay_int) where pname = :new.patient_name and discharge is null;
	insert into post_surgery_ward(patient_name,post_admission_date,scount,patient_type) values(:new.patient_name,trunc(:new.pre_admission_date) + stay_int,1,:new.patient_type);
	while stay_int != numtodsinterval(0,'day') loop
	      stay_int := stay_int - numtodsinterval(1,'day');
	      case :new.bed_no
	      when 1 then begin
	      	   insert into pre_bed(calendar,bed1) values(:new.pre_admission_date + stay_int,:new.patient_name);
	      	   exception
		   when dup_val_on_index then
		     	update pre_bed set bed1 = :new.patient_name where calendar = :new.pre_admission_date;
	      	   end;
	     when 2 then begin
	      	   insert into pre_bed(calendar,bed2) values(:new.pre_admission_date + stay_int,:new.patient_name);
	      	   exception
		   when dup_val_on_index then
		     	update pre_bed set bed2 = :new.patient_name where calendar = :new.pre_admission_date;
	      	   end;
	     when 3 then begin
	      	   insert into pre_bed(calendar,bed3) values(:new.pre_admission_date + stay_int,:new.patient_name);
	      	   exception
		   when dup_val_on_index then
		     	update pre_bed set bed3 = :new.patient_name where calendar = :new.pre_admission_date;
	      	   end;
	     when 4 then begin
	      	   insert into pre_bed(calendar,bed4) values(:new.pre_admission_date + stay_int,:new.patient_name);
	      	   exception
		   when dup_val_on_index then
		     	update pre_bed set bed4 = :new.patient_name where calendar = :new.pre_admission_date;
	      	   end;
	     end case;
	end loop;
end;
/

create or replace function post_res(pn in varchar2,start_date in date,stay_int in interval day to second, ptype in varchar2)
return number is sur_num number := 1;
pa_bp number;
pa_temp number;
stay_temp interval day to second := post_res.stay_int;
begin
	while stay_temp != numtodsinterval(0,'day') loop
	      stay_temp := stay_temp - numtodsinterval(1,'day');
	      select pc.bp into post_res.pa_bp from patient_chart pc where pc.patient_name = post_res.pn and pc.pdate = post_res.start_date + stay_temp;
	      select pc.temperature into post_res.pa_temp from patient_chart pc where pc.patient_name = post_res.pn and pc.pdate = post_res.start_date + stay_temp;
	      if post_res.ptype = 'Cardiac' and (pa_bp < 110 or pa_bp > 140) then
	      	 sur_num := 2;
		 exit;
	      end if;
	      if post_res.ptype = 'Neuro' and (pa_bp < 110 or pa_bp > 140 or pa_temp <97 or pa_temp > 100) then
	      	 sur_num := 2;
		 exit;
	      end if;
	end loop;

	return sur_num;
end;
/

create or replace trigger trg_post
before insert on post_surgery_ward
for each row
declare
	stay_int2 interval day to second := numtodsinterval(2,'day');
	stay_int4 interval day to second := numtodsinterval(4,'day');
	sur_num number := 1;
begin
	if :new.patient_type = 'General' then
	     --update all_info
	     update all_info set post_stay = extract(day from stay_int2),scount = 1,discharge = :new.post_admission_date + stay_int2  where pname = :new.patient_name and discharge is null;
	     :new.discharge_date := :new.post_admission_date + stay_int2;
	else
	     sur_num := post_res(:new.patient_name,:new.post_admission_date,stay_int2,:new.patient_type);
	     if sur_num = 2 then
	     	--update all_info
	     	update all_info set post_stay = extract(day from stay_int4),scount = 2,discharge = :new.post_admission_date + stay_int4  where pname = :new.patient_name and discharge is null;
		:new.discharge_date := :new.post_admission_date + stay_int4;
		:new.scount := 2;
	     else
		--update all_info
	     	update all_info set post_stay = extract(day from stay_int2),scount = 1,discharge = :new.post_admission_date + stay_int2  where pname = :new.patient_name and discharge is null;
		:new.discharge_date := :new.post_admission_date + stay_int2;
	     end if;
	end if;
end;
/
