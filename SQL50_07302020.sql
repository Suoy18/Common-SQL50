-- 1.查询课程编号为“01”的课程比“02”的课程成绩高的所有学生的学号。(难点）
SELECT 
    a.s_id
FROM
    score a
        JOIN
    score b ON a.s_id = b.s_id
WHERE
    a.c_id = '01' AND b.c_id = '02'
        AND a.score > b.score;

-- 1.1、查询同时选修“01”课程和“02”课程的情况
select s_id
from score
where score.c_id = '01' and score.s_id in (select s_id from score where c_id = '02');

select * from 
(select s_id, score as score_01 from score where score.c_id='01') as t1,
(select s_id, score as score_02 from score where score.c_id='02') as t2
where t1.s_id=t2.s_id;

-- 1.2、查询选修了01课程但是可能没有选修02课程的情况
select * from 
(select s_id, score as score_01 from score where c_id='01') as t1
left join 
(select s_id, score as score_02 from score where c_id='02') as t2
on t1.s_id=t2.s_id;

-- 2、查询平均成绩大于60分的学生的学号和平均成绩
select s_id, avg(score)
from score
group by s_id
having avg(score)>60;

-- 3、查询所有学生的学号、姓名、选课数、总成绩
select student.s_id, student.s_name, count(score.c_id), sum(score.score)
from student left join score on student.s_id = score.s_id
group by student.s_id;

-- 4、查询姓“张”的老师的个数
select count(t_id)
from teacher
where t_name like '张%';

-- 5、查询没学过“张三”老师课的学生的学号、姓名
select s_id, s_name
from student 
where s_id not in (select score.s_id from score left join course on score.c_id = course.c_id 
left join teacher on course.t_id = teacher.t_id where teacher.t_name = '张三');

-- 7、查询学过编号为“01”的课程并且也学过编号为“02”的课程的学生的学号、姓名
select student.s_id, student.s_name
from student left join score on student.s_id = score.s_id
where score.c_id = '01' and score.s_id in (select s_id from score where c_id = '02');

-- 8、查询课程编号为“02”的总成绩
select sum(score)
from score 
where c_id = '02';

-- 9、查询所有课程成绩小于60分的学生的学号、姓名
select s_id, s_name 
from student where s_id not in (select s_id from score where score>60);

-- 10、查询没有学全所有课的学生的学号、姓名
select student.s_id, student.s_name 
from student left join score on student.s_id = score.s_id
group by student.s_id having count(score.c_id) < (select count(*) from course);

-- 11、查询至少有一门课与学号为“01”的学生所学课程相同的学生的学号和姓名
select student.s_id, student.s_name
from student left join score on student.s_id = score.s_id
where score.c_id in (select c_id from score where s_id= '01' ) and student.s_id!='01' 
group by s_id ;

-- 12、查询和“01”号同学所学课程完全相同的其他同学的学号
-- 14、查询和“02”号的同学学习的课程完全相同的其他同学学号和姓名(同12题，略）
select student.s_id, student.s_nam
from student left join score on student.s_id = score.s_id
where score.c_id in (select c_id from score where s_id= '01' ) and student.s_id!='01' 
group by s_id 
having count(c_id) = (select count(c_id) from score where s_id='01');

-- 13、把“SCORE”表中“张三”老师教的课的成绩都更改为此课程的平均成绩 -- 思路：先找到‘张三’老师所教的课程，然后修改为平均分
update ;

-- 15、删除学习“张三”老师课的score表记录
delete from score where c_id in 
(select c_id from course join teacher on course.t_id=teacher.t_id
where t_name ='张三');

-- 16、查询"01"课程分数小于60，按分数降序排列的学生学号、姓名和考试成绩
select student.s_id, s_name, score from student 
join score on student.s_id=score.s_id 
where student.s_id in (select s_id from score where score<60 and c_id='01')
order by score desc;

-- 17、按平均成绩从高到低显示所有学生的所有课程的成绩以及平均成绩
select a.s_name as 姓名, b.s_id as 学号, 
(select score from score where s_id=b.s_id and c_id='01') as 语文,
(select score from score where s_id=b.s_id and c_id='02') as 数学,
(select score from score where s_id=b.s_id and c_id='03') as 英语,
round(avg(score),2) as 平均分 
from score b join student a on a.s_id=b.s_id 
group by b.s_id 
order by 平均分 desc;

-- 18.查询各科成绩最高分、最低分和平均分：以如下形式显示：课程ID，课程name，最高分，最低分，平均分，及格率，中等率，优良率，优秀率，及格为>=60，中等为：70-80，优良为：80-90，优秀为：>=90 (重难点)
-- 思路：及格率=及格人数/总人数，人数可以用case函数计算，分数小于60算作1，求和即可得到及格人数
select a.c_id as 课程ID,
b.c_name as 课程name, 
max(score) as 最高分, 
min(score) as 最低分, 
round(avg(score),2) as 平均分,
ROUND(100*SUM(case when a.score>=60 then 1 else 0 end)/SUM(case when a.score then 1 else 0 end),2) as 及格率,
ROUND(100*SUM(case when a.score>=70 and a.score<=80 then 1 else 0 end)/SUM(case when a.score then 1 else 0 end),2) as 中等率,
ROUND(100*SUM(case when a.score>=80 and a.score<=90 then 1 else 0 end)/SUM(case when a.score then 1 else 0 end),2) as 优良率,
ROUND(100*SUM(case when a.score>=90 then 1 else 0 end)/SUM(case when a.score then 1 else 0 end),2) as 优秀率
from score a join course b on a.c_id=b.c_id group by a.c_id, b.c_name;

-- 19、按各科成绩进行排序，并显示排名， Score 重复时保留名次空缺（重点）
-- MySQL 的写法，由于mysql中没有rank()函数，所以只能手动排序
SELECT
	a.*,
	COUNT( b.score ) + 1 AS 排名 
FROM
	score a
	LEFT JOIN score b ON a.c_id = b.c_id 
	AND a.score < b.score 
GROUP BY
	a.c_id,
	a.s_id 
ORDER BY
	a.c_id,
	排名 ;

-- 20、查询学生的总成绩并进行排名（重点）
select a.s_id,
@i:=@i+1 as 排名（重复时保留）,
@k:=(case when @score=a.sum_score then @k else @i end) as 排名（重复不保留）,
@score:=a.sum_score as score
from (select s_id,SUM(score) as sum_score from score GROUP BY s_id ORDER BY sum_score DESC) a,
(select @k:=0,@i:=0,@score:=0) s ;

-- 21 、查询不同老师所教不同课程平均分从高到低显示
select a.t_id, t_name, a.c_id, avg(score) from course a 
join score b on a.c_id=b.c_id
join teacher c on c.t_id=a.t_id group by c_id order by avg(score) desc;

-- 22、查询所有课程的成绩第2名到第3名的学生信息及该课程成绩
select d.*,c.排名,c.score,c.c_id from (
select a.s_id,a.score,a.c_id,@i:=@i+1 as 排名 from score a,(select @i:=0)s where a.c_id='01'  
ORDER BY a.score DESC) c
left join student d on c.s_id=d.s_id
where 排名 BETWEEN 2 AND 3 UNION
select d.*,c.排名,c.score,c.c_id from (
select a.s_id,a.score,a.c_id,@j:=@j+1 as 排名 from score a,(select @j:=0)s where a.c_id='02'  
ORDER BY a.score DESC) c left join student d on c.s_id=d.s_id
where 排名 BETWEEN 2 AND 3 UNION select d.*,c.排名,c.score,c.c_id from (
select a.s_id,a.score,a.c_id,@k:=@k+1 as 排名 from score a,(select @k:=0)s where a.c_id='03' 
ORDER BY a.score DESC) c 
left join student d on c.s_id=d.s_id
where 排名 BETWEEN 2 AND 3;

-- 23、使用分段[100-85],[85-70],[70-60],[<60]来统计各科成绩，分别统计各分数段人数：课程ID和课程名称(类似18题)
select b.c_id as 课程ID, c_name as 课程名称, 
sum(case when b.score<60 then 1 else 0 end) as '[<60]',
sum(case when b.score>=60 and b.score<=70 then 1 else 0 end) as '[60-70]',
sum(case when b.score>=70 and b.score<=85 then 1 else 0 end) as '[70-85]',
sum(case when b.score>=85 and b.score<=100 then 1 else 0 end) as '[85-100]'
from course a join score b on a.c_id=b.c_id group by b.c_id;

-- 24、查询学生平均成绩及其名次（类似19题，重点）
select a.s_id, 
@i:=@i+1 as '不保留空缺排名',
@k:=(case when @avg_score=a.avg_s then @k else @i end) as '保留空缺排名',
@avg_score:=avg_s as 平均分
from (select s_id,ROUND(AVG(score),2) as avg_s from score GROUP BY s_id ORDER BY avg_s DESC)a,
(select @avg_score:=0,@i:=0,@k:=0)b;

-- 25、查询各科成绩前三名的记录（不考虑成绩并列情况）（类似22题，重点 ）

-- 26、查询每门课程被选修的学生数
select c_id, count(s_id) 
from score
group by c_id;

-- 27、查询出只有两门课程的全部学生的学号和姓名
select a.s_id, a.s_name from student a
join score b on a.s_id=b.s_id 
group by s_id having count(b.c_id)=2;

-- 28、查询男生、女生人数
select s_sex, count(*) from Student group by s_sex;

-- 29 查询名字中含有"风"字的学生信息
select * 
from Student
where s_name like '%风%';

-- 30 查询同名同性学生名单，并统计同名人数
select a.s_name,a.s_sex,count(*) from student a  
JOIN student b on a.s_id !=b.s_id and a.s_name = b.s_name and a.s_sex = b.s_sex
GROUP BY a.s_name,a.s_sex;

-- 31、查询1990年出生的学生名单
select s_name
from student
where s_birth like '1990%';

-- 32、查询平均成绩大于等于85的所有学生的学号、姓名和平均成绩
select a.s_id as 学号, a.s_name as 姓名, avg(score) as 平均分
from student a join score b on a.s_id=b.s_id
group by a.s_id having avg(score)>85;

-- 33、查询每门课程的平均成绩，结果按平均成绩升序排序，平均成绩相同时，按课程号降序排列
select c_id, avg(score) 
from score
group by c_id
order by avg(score),c_id DESC;

-- 34、查询课程名称为"数学"，且分数低于60的学生姓名和分数
select a.s_name, b.score from student a join score b on a.s_id=b.s_id 
where b.c_id=(select c_id from course where c_name='数学') and b.score<60;

-- 35、查询所有学生的课程及分数情况
select a.s_id as 学号, a.s_name as 姓名, c.c_name as 课程, b.score as 分数 
from student a join score b on a.s_id=b.s_id join course c on b.c_id=c.c_id;

-- 36、查询任何一门课程成绩在70分以上的姓名、课程名称和分数
select s_name, c_name, score 
from student a join score b on a.s_id=b.s_id
join course c on b.c_id=c.c_id
where b.score>70;

-- 37、查询不及格的课程并按课程号从大到小排列
select c_id as 课程号, score as 分数
from score 
where score<60
order by c_id;

-- 38、查询课程编号为03且课程成绩在80分以上的学生的学号和姓名
select a.s_id, s_name from student a 
join score b on a.s_id=b.s_id
where c_id='03' and score>80;

-- 39、求每门课程的学生人数
select c_id, count(distinct(s_id)) from score 
group by c_id;

-- 40、查询选修“张三”老师所授课程的学生中成绩最高的学生姓名及其成绩
select a.s_name, b.score from student a join score b on a.s_id=b.s_id
where c_id=(select c_id from course where t_id=(select t_id from teacher where t_name='张三')) 
order by b.score desc limit 1;

-- 41.查询不同课程成绩相同的学生的学生编号、课程编号、学生成绩
select DISTINCT b.s_id,b.c_id,b.score 
from score a,score b 
where a.c_id != b.c_id and a.score = b.score;

-- 42、查询每门功成绩最好的前两名（重点）
-- 思路1:先查出有多少门课程，然后把每门课程成绩最好的前两名用Union联结起来
(select * from score where c_id = '01' order by score  desc limit 2)
union all
(select * from score where c_id = '02' order by score  desc limit 2)
union all
(select * from score where c_id = '03' order by score  desc limit 2);

-- 思路2: 找到大于某个成绩的只有两人，就是前两名
SELECT * FROM score 
WHERE (SELECT COUNT(*) FROM score AS a WHERE score.c_id = a.c_id AND score.score < a.score) < 2 
ORDER BY c_id ASC, score.score DESC ;

-- 43、统计每门课程的学生选修人数（超过5人的课程才统计）。要求输出课程号和选修人数，查询结果按人数降序排列，若人数相同，按课程号升序排列
select c_id, count(*) as total 
from score 
GROUP BY c_id 
HAVING total>5 
ORDER BY total,c_id ASC;

-- 44、检索至少选修两门课程的学生学号
select s_id, count(*) as sel from score GROUP BY s_id HAVING sel>=2;

-- 45、 查询选修了全部课程的学生信息
select * from student where s_id in 
(select s_id from score group by s_id having count(s_id)=(select count(*) from course));

-- 46、查询各学生的年龄-- 按照出生日期来算，当前月日 < 出生年月的月日则，年龄减一
-- tips: MySQL日期函数date_format(now,'%Y')可以求出当前年份
select s_name, s_birth, 
(DATE_FORMAT(NOW(),'%Y')-DATE_FORMAT(s_birth,'%Y') - 
(case when DATE_FORMAT(NOW(),'%m%d')>DATE_FORMAT(s_birth,'%m%d') then 0 else 1 end)) 
as age from student;

-- 47、查询没学过“张三”老师讲授的任一门课程的学生姓名
select distinct(s_name) from student
where s_id not in 
(select s_id from score join course on score.c_id=course.c_id
join teacher on teacher.t_id=course.t_id
where t_name = '张三'); 

-- 48、查询两门以上不及格课程的同学的学号及其平均成绩
-- 思路1
select a.s_id, avg(score) from score a group by a.s_id 
having (select count(*) from score b where a.s_id=b.s_id and b.score<60)>=2;

-- 思路2
select s_id, avg(score)
from score where score <60
group by s_id having count(c_id)>=2;

-- 49、查询本月过生日的学生
-- tips: month()函数返回日期月份
select * from student where MONTH(DATE_FORMAT(NOW(),'%Y%m%d')) =MONTH(s_birth);

-- 50、查询下月过生日的学生
select * from student where MONTH(DATE_FORMAT(NOW(),'%Y%m%d'))+1 =MONTH(s_birth);


-- 排序 rank
set @currank := 0;
select s_id, c_id, score, @currank := @currank +1 as rank
from score
order by score;

set @currank := 0, @prerank := NULL; 
select s_id, c_id, score, 
if (@prerank = score, @currank, @currank := @currank +1) as rank, @prerank := score
from score
order by score;

set @currank := 0, @prerank := NULL, @incrank := 1; 
select s_id, c_id, score, 
@currank := if (@prerank = score, @currank, @incrank) as rank, @prerank := score, @incrank := @incrank +1 
from score
order by score;