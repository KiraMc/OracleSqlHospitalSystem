--populate patient_chart
insert into patient_chart values('Bob',to_date('03/09/05','mm/dd/yy'),99,120);
insert into patient_chart values('Bob',to_date('03/10/05','mm/dd/yy'),99,120);

insert into patient_chart values('mmm',to_date('04/09/05','mm/dd/yy'),99,120);
insert into patient_chart values('mmm',to_date('04/10/05','mm/dd/yy'),99,120);

insert into patient_chart values('nnn',to_date('04/11/05','mm/dd/yy'),99,120);
insert into patient_chart values('nnn',to_date('04/12/05','mm/dd/yy'),99,120);

insert into patient_chart values('aaa',to_date('05/09/05','mm/dd/yy'),99,120);
insert into patient_chart values('aaa',to_date('05/10/05','mm/dd/yy'),99,120);
insert into patient_chart values('bbb',to_date('05/09/05','mm/dd/yy'),99,70);
insert into patient_chart values('bbb',to_date('05/10/05','mm/dd/yy'),99,120);
insert into patient_chart values('ccc',to_date('05/09/05','mm/dd/yy'),70,120);
insert into patient_chart values('ccc',to_date('05/10/05','mm/dd/yy'),99,120);
insert into patient_chart values('ddd',to_date('05/09/05','mm/dd/yy'),10,10);
insert into patient_chart values('ddd',to_date('05/10/05','mm/dd/yy'),10,10);

insert into patient_chart values('eee',to_date('05/04/05','mm/dd/yy'),99,120);
insert into patient_chart values('eee',to_date('05/05/05','mm/dd/yy'),99,120);
insert into patient_chart values('eee',to_date('05/06/05','mm/dd/yy'),99,120);
insert into patient_chart values('eee',to_date('05/07/05','mm/dd/yy'),99,120);
insert into patient_chart values('eee',to_date('05/08/05','mm/dd/yy'),10,10);
insert into patient_chart values('eee',to_date('05/09/05','mm/dd/yy'),10,10);

insert into patient_chart values('fff',to_date('05/13/05','mm/dd/yy'),10,120);
insert into patient_chart values('fff',to_date('05/14/05','mm/dd/yy'),10,120);

insert into patient_chart values('aaa',to_date('06/09/05','mm/dd/yy'),10,120);
insert into patient_chart values('aaa',to_date('06/10/05','mm/dd/yy'),10,120);

insert into patient_chart values('Bob',to_date('06/09/05','mm/dd/yy'),10,12);
insert into patient_chart values('Bob',to_date('06/10/05','mm/dd/yy'),10,12);
insert into patient_chart values('kkk',to_date('06/09/05','mm/dd/yy'),10,12);
insert into patient_chart values('kkk',to_date('06/10/05','mm/dd/yy'),10,12);

insert into patient_chart values('Bob',to_date('07/09/05','mm/dd/yy'),10,12);
insert into patient_chart values('Bob',to_date('07/10/05','mm/dd/yy'),10,12);

--populate patient input
create or replace procedure populate_db
as
begin
	for pats in (select * from patient_input pti order by pti.general_ward_admission_date,pti.patient_name) loop
	    insert into general_ward values(pats.patient_name,pats.general_ward_admission_date,pats.patient_type);
	end loop;
end;
/
