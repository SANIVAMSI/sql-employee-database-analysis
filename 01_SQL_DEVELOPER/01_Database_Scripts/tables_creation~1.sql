-- dept_info ---- Meta data  

create table dept_Info 
(
 dept_Id number(3)primary key,
 dept_name varchar2(30),
 location  varchar2(30)
 );
select * from dept_info;

--EMP_INFO — Metadata

create table emp_info (
 emp_id number (3)primary key,
 emp_name varchar2(30),
 job varchar2( 30),
 manager_id number(5),
 hire_date date,
 salary number (10),
 dept_Id number(3),
  CONSTRAINT FK_EMP_DEPT
  FOREIGN KEY (DEPT_ID)
        REFERENCES DEPT_INFO(DEPT_ID));

select * from emp_info;
 
