-- courses per specialization
select p.program_assignment, count(p.program_assignment) as courses_count from programs p group by p.program_assignment;


-- semester count per specialization
select p.program_assignment, p.program_course_rev_ref as semester, count(p.program_course_rev_ref) as courses_count from programs p group by p.program_assignment, p.program_course_rev_ref order by p.program_assignment, p.program_course_rev_ref asc;


-- get all session types
select distinct(s.session_type) from sessions s;


-- get all room name
select distinct(s.session_room) from sessions s where s.session_room is not null ;


-- per intake, count of sessions and per year
select s.session_population_period, count(s.*),  from sessions s where s.session_population_year = 2021 group by s.session_population_period;


-- sessions per month [range]
select s.* from sessions s where s.session_date >= '2020-09-01' and s.session_date < '2020-10-01';


-- sessions handled by teachers [not duplicate]
select distinct(s.session_prof_ref) from sessions s;


-- started session count of the particular year intake
select s.session_population_period, count(s.*) from sessions s where s.session_population_year = 2021 group by s.session_population_period;


-- insert population for all specilization
insert into populations (population_code, population_year, population_period) select p.population_code as pcode, max(p.population_year) as pyear, 'FALL' as intake from populations p group by p.population_code;


-- order by teacher's level 
select t.* from teachers t order by t.teacher_study_level asc


-- get all teachers from contacts table
select c.* from contacts c left join teachers t on c.contact_email = t.teacher_contact_ref where t.teacher_contact_ref is not null;


-- get all students from contacts table
select c.* from contacts c left join students s on c.contact_email = s.student_contact_ref where s.student_contact_ref is not null;


-- get all students from contacts table and where newyork students
select c.* from contacts c left join students s on c.contact_email = s.student_contact_ref where s.student_contact_ref is not null and c.contact_city  ilike 'los angeles';


-- get all students from contacts table and where birthday is on november
select c.* from contacts c left join students s on c.contact_email = s.student_contact_ref where s.student_contact_ref is not null and date_part('month', c.contact_birthdate::date) = 11;

-- calculate age from dob 
SELECT contact_first_name, date_part('year',age(contact_birthdate)) as contact_age,* FROM contacts;


-- add age column to contacts
alter table contacts add column contact_age integer NULL;

-- calculate age from dob and insert in col contact_age
update 
  contacts as c1 
set 
  contact_age = (
    SELECT 
      date_part(
        'year', 
        age(contact_birthdate)
      ) as c_age 
    FROM 
      contacts as c2 
    where 
      c1.contact_email = c2.contact_email
  );
 
 
-- avg student age
select 
  avg(c.contact_age) as student_avg_age 
from 
  students as s 
  left join contacts as c on c.contact_email = s.student_contact_ref
 
-- get students population in each year
select student_population_year_ref, count(1) from students group by student_population_year_ref;


-- get students population in each program
select student_population_code_ref, count(1) from students group by student_population_code_ref;
  

-- students count who completed the diploma in particular year according to the specilization
select s.student_population_code_ref, count(*) from students s where s.student_enrollment_status ='completed' and s.student_population_year_ref =2021 group by s.student_population_code_ref;


/* avg grade for SE students*/
select 
  avg(g.grade_score) as avg_grade, 
  pop.population_code as population 
from 
  grades as g 
  inner join programs as p on g.grade_course_code_ref = p.program_course_code_ref 
  inner join populations as pop on pop.population_code = p.program_assignment 
where 
  pop.population_code = 'SE' 
group by 
  pop.population_code


/* All student average grade*/
Select cont.contact_first_name, cont.contact_last_name, stud.student_epita_email, avg(g.grade_score)
from students stud
  inner join contacts cont
  on cont.contact_email = stud.student_contact_ref
  
  inner join grades g
  on stud.student_epita_email = g.grade_student_epita_email_ref

group by cont.contact_first_name, cont.contact_last_name, stud.student_epita_email


/* attendance percentage for a student */
select 
  (sum_atten / total_atten :: float)* 100 attendance_percentage, 
  res.attendance_student_ref, 
  res.attendance_course_ref, 
  res.attendance_population_year_ref 
from 
  (
    select 
      count(1) as total_atten, 
      sum(s.attendance_presence) as sum_atten, 
      s.attendance_student_ref, 
      s.attendance_course_ref, 
      s.attendance_population_year_ref 
    from 
      attendance as s 
    where 
      s.attendance_student_ref = 'albina.glick@epita.fr' 
    group by 
      s.attendance_student_ref, 
      s.attendance_course_ref, 
      s.attendance_population_year_ref
  ) res 
order by 
  attendance_percentage


/* list the course tought by teacher */
select 
  distinct con.contact_first_name, 
  con.contact_last_name, 
  sess.session_course_ref 
from 
  teachers tea 
  inner join contacts con on con.contact_email = tea.teacher_contact_ref 
  inner join sessions sess on tea.teacher_epita_email = sess.session_prof_ref


-- find the teachers who are not giving any courses
select 
  s.student_epita_email 
from 
  students as s 
where 
  s.student_epita_email not in (
    select 
      g.grade_student_epita_email_ref 
    from 
      grades as g
  )

/* 
 * find the SE students details with grades
 */
select 
  con.contact_first_name, 
  con.contact_last_name, 
  stud.student_population_code_ref, 
  grad.grade_course_code_ref as course_name, 
  grad.grade_score 
from 
  grades grad 
  inner join students stud on grad.grade_student_epita_email_ref = stud.student_epita_email 
  inner join contacts con on stud.student_contact_ref = con.contact_email 
where 
  student_population_code_ref = 'SE'

  
/*
 * list of teacher who attend the total session 
 */
select 
  con.contact_first_name, 
  con.contact_last_name, 
  tea.teacher_contact_ref, 
  count(session_prof_ref) 
from 
  teachers tea 
  inner join contacts con on con.contact_email = tea.teacher_contact_ref 
  inner join sessions sess on tea.teacher_epita_email = sess.session_prof_ref 
group by 
  con.contact_first_name, 
  con.contact_last_name, 
  tea.teacher_contact_ref 
order by 
  count



--Note: Need to set foreign keys for session.session_course_ref , session.session_course_rev_ref with course table 


