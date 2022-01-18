--Easy qsts (no relations needed)
--1- Get all enrolled students for a specific period,program,year ?
select * from students s 
where s.student_population_period_ref = 'FALL' and s.student_population_year_ref ='2020' and s.student_population_code_ref = 'DSA'

--2- Get number of enrolled students for a specific period,program,year
select count(s.student_epita_email) as EnrolledStudents from students s 
where s.student_population_period_ref = 'FALL' and s.student_population_year_ref ='2020' and s.student_population_code_ref = 'DSA'

--3- Get All defined exams for a course from grades table
select * from  grades g  
inner join exams e on g.grade_course_code_ref = e.exam_course_code
inner join courses c on e.exam_course_code = c.course_code 
where e.exam_course_code ='SE_ADV_JS'


--4-Get all grades for a student
select * from students s 
inner join grades g on s.student_epita_email = g.grade_student_epita_email_ref 
where s.student_epita_email = 'simona.morasca@epita.fr'

--5-Get all grades for a specific Exam
select * from grades g 
inner join exams e on g.grade_course_code_ref = e.exam_course_code 
where grade_course_code_ref = 'AI_DATA_PREP'

--6-Get students Ranks in an Exam for a course
select *, RANK () OVER ( 
		ORDER BY g.grade_score desc 
	) grade_score from grades g 
inner join exams e on g.grade_course_code_ref = e.exam_course_code 
where grade_course_code_ref = 'AI_DATA_PREP'

--7-Get students Ranks in all exams for a course
select *,RANK () OVER ( 
		ORDER BY g.grade_score desc 
	) grade_score from grades g 
inner join exams e on g.grade_course_code_ref = e.exam_course_code 
where g.grade_student_epita_email_ref = 'simona.morasca@epita.fr'

--8-Get students Rank in all exams in all courses
select g.grade_student_epita_email_ref,c.course_code ,e.exam_course_code ,g.grade_score ,RANK () OVER ( 
		ORDER BY g.grade_score desc 
	) grade_score from grades g 
inner join exams e on g.grade_course_code_ref = e.exam_course_code  
inner join courses c on g.grade_course_code_ref = grade_course_code_ref;

--9-Get all courses for one program
select * from courses c
inner join programs p on c.course_code = p.program_course_code_ref 
where p.program_assignment = 'DSA'

--10-Get courses in common between 2 programs
SELECT distinct(program_course_code_ref) as program_assignment FROM programs where program_assignment = 'SE'
intersect
SELECT distinct(program_course_code_ref) as program_assignment FROM programs where program_assignment = 'AIs'

--11-Get all programs following a certain course
select * from programs p 
where p.program_course_code_ref = 'DT_RDBMS'


--12- get course with the biggest duration
select * from courses c 
order by c.duration desc 

--13-get courses with the same duration
select * from courses c 
where c.duration in (select c2.duration from courses c2 group by c2.duration having count(c2.duration) > 1) order by c.duration asc

--14-Get all sessions for a specific course
select * from sessions s 
inner join courses c on s.session_course_rev_ref = c.course_rev 
where c.course_name = 'Python fundamentals'

--15-Get all session for a certain period
select * from sessions s 
where s.session_date  >= '2021-01-04' and s.session_date  <= '2021-01-31';

--16-Get one student attendance sheet
select * from attendance a 
where a.attendance_student_ref = 'jamal.vanausdal@epita.fr'


--17- Get one student summary of attendance
select total_attendance,sum_attendance,(sum_attendance / total_attendance :: float)* 100 as attendance_percentage,res.attendance_student_ref,res.attendance_course_ref,res.attendance_population_year_ref 
from
( select 
	count(1) as total_attendance,
	sum(s.attendance_presence) as sum_attendance,
	s.attendance_student_ref,
	s.attendance_course_ref,
	s.attendance_population_year_ref 
	from attendance as s
	where s.attendance_student_ref = 'jamal.vanausdal@epita.fr'
	group by s.attendance_student_ref,s.attendance_course_ref,s.attendance_population_year_ref 
) res
order by attendance_percentage


--18-Get student with most absences
select a.attendance_student_ref , count(a.attendance_presence) from attendance a 
where a.attendance_presence = 0
group by a.attendance_student_ref 
order by count desc 



--
--
--
--Hard questions (build the relations requiered)
--1- Get all exams for a specific Course
select  c.course_code ,c.course_name,e.exam_type  from courses c
inner join exams e on c.course_code = e.exam_course_code 
where c.course_code = 'DT_RDBMS'


--2- Get all Grades for a specific Student

select g.grade_student_epita_email_ref, g.grade_course_code_ref , g.grade_exam_type_ref, g.grade_score  from grades g 
where g.grade_student_epita_email_ref ='carmelina.lindall@epita.fr'
order by g.grade_score desc


--3- Get the final grades for a student on a specifique course or all courses

--for specific course
select g.grade_student_epita_email_ref, g.grade_course_code_ref , g.grade_exam_type_ref, g.grade_score  from grades g 
where g.grade_student_epita_email_ref = 'ammie.corrio@epita.fr' and grade_course_code_ref ='PG_PYTHON'

---for all course
select g.grade_student_epita_email_ref, g.grade_course_code_ref , g.grade_exam_type_ref, g.grade_score  from grades g 
where g.grade_student_epita_email_ref = 'ammie.corrio@epita.fr' 




--4-Get the students with the top 5 scores for specific course
select g.grade_student_epita_email_ref, g.grade_course_code_ref , g.grade_exam_type_ref, g.grade_score  from grades g 
where grade_course_code_ref ='SE_ADV_JS'
order by g.grade_score desc
limit 5


--5-Get the students with the top 5 scores for specific course
--per rank
select g.grade_student_epita_email_ref, g.grade_course_code_ref , g.grade_exam_type_ref, g.grade_score,  RANK () OVER (  ORDER BY g.grade_score desc ) grade_score from grades g 
where grade_course_code_ref ='SE_ADV_JS'
order by g.grade_score desc
limit 5



--6-Get the Class average for a course
select avg(g.grade_score) as AvgGrade  from grades g 
where grade_course_code_ref ='SE_ADV_JS'
group by g.grade_course_code_ref


--
--
--
----bonuses:
--1-Get a student full report of grades and attendances
--2- -- Get a student full report of grades ,ranks per course and attendances
--Those questions are from easy to super hard

--
--simple query : get all the contacts from Anchorage, display the columns contact email, firstname and city ordered by contact_firstname
select * from contacts c 
where c.contact_city = 'Anchorage'
order by c.contact_first_name 

--intermediate query : find all the teachers who haven't taught at all, return the teacher email addresses, in ascending order
--	
select  t.teacher_epita_email from teachers t
where t.teacher_epita_email not in  (select distinct(s2.session_prof_ref) from sessions s2)
order by t.teacher_epita_email asc

--harder query : compute the absence rate per student and per course, ordered by student epita_email ascending, course name ascending and absence rate descending


select total_attendance , sum_attendance  ,(absent_attendance / total_attendance :: float)* 100,  student_email ,courses
from 
(select 
count(1) as total_attendance , sum(a.attendance_presence),(total_attendance - sum_attendance) as absent_attendance, as sum_attendance, a.attendance_student_ref as student_email ,a.attendance_course_ref as courses 
from attendance a
group by a.attendance_student_ref , a.attendance_course_ref 
)res
order by student_email asc


---------
select attendance_student_ref,attendance_course_ref,cast(round(cast(absent as decimal)*100/ totalAttendance,2) as varchar)|| '%' as absence_ratio From (
select attendance_student_ref,attendance_population_year_ref,attendance_course_ref,attendance_course_rev, sum(case when status='Present' then 1 else 0 end) as present,
 sum(case when status='Absent' then 1 else 0 end) as absent,count(*) as totalAttendance from (
SELECT attendance_student_ref, attendance_population_year_ref, attendance_course_ref, attendance_course_rev, 
        attendance_session_date_ref, attendance_session_start_time, attendance_session_end_time, case when attendance_presence=1 then 'Present' else 'Absent' end status
FROM public.attendance) as t
group by attendance_student_ref,attendance_population_year_ref,attendance_course_ref,attendance_course_rev
order by attendance_student_ref,attendance_population_year_ref,attendance_course_ref) as R
