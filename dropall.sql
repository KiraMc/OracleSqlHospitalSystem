--View drop
drop view patient_surgery_view;

--Trigger drop
drop trigger trg_gen;

drop trigger trg_scr;

drop trigger trg_post;

--Function drop

drop function modscrbed;

drop function scr_sur;

drop function post_res;

drop function find_name;

drop function find_surgeon;

drop function gen_sur_duty;

--Procedure drop

drop procedure populate_db;

drop procedure pop_dr_sch;

drop procedure pop_sur_sch;

drop procedure very_dr_sur;

--Table drop

drop table general_ward;

drop table screening_ward;

drop table pre_surgery_ward;

drop table post_surgery_ward;

drop table patient_chart;

drop table dr_schedule;

drop table surgeon_schedule;

drop table patient_input;

drop table scr_bed;

drop table pre_bed;

drop table all_info;

drop table surgeon_info;

drop table int_sur;
