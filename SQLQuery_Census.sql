select * from [SQL Project].dbo.Data1;

select * from [SQL Project].dbo.Data2;

-- number of rows

select COUNT(*) from [SQL Project]..Data1;

select COUNT(*) from [SQL Project]..Data2;

-- dataset for BIhar and Jharkand

select * from [SQL Project]..Data2 where State in ('Kerala', 'Bihar');

-- population of India

select SUM(population)  total_population from [SQL Project]..Data2;

--Average  growth

select AVG(growth) from [SQL Project]..Data1;

select state, avg(growth)*100 avg_growth from [SQL Project]..Data1
group by State;

-- avg sex ratio

select AVG(Sex_Ratio) avg_sex_ratio from [SQL Project]..Data1;

select state, AVG(Sex_Ratio) avg_sex_ratio from [SQL Project]..Data1 
group by State 
order by avg_sex_ratio desc;

-- avg literacy rate

select District,  AVG(Sex_Ratio) avg_sex_ratio, round(AVG(Literacy),0) avg_literacy
from [SQL Project]..Data1
group by District
order by avg_literacy desc;

select State, round(AVG(Literacy),0) avg_literacy
from [SQL Project]..Data1
group by State
having round(AVG(Literacy),0) > 90
order by avg_literacy desc;

-- top 3 state showing highest growth ratio

select top 3 State, AVG(Growth)*100 avg_growth from [SQL Project]..Data1
group by State
order by avg_growth desc;

--bottom 3 state showing lowest sex ratio

select top 3 State, round(AVG(Sex_Ratio),0) avg_sex_ratio from [SQL Project]..Data1
group by State
order by avg_sex_ratio asc ;

-- top and bottom 3 states in literacy rate

drop table if exists topstates;
create table topstates
(state nvarchar(255),
literacy_per_state float
)

insert into topstates
select State, round(AVG(Literacy),1) avg_literacy from [SQL Project]..Data1
group by State
--order by avg_literacy desc;

select top 3 * from topstates order by topstates.literacy_per_state desc;

drop table if exists bottomstates;
create table bottomstates
(state nvarchar(255),
literacy_per_state float
)

insert into bottomstates
select State, round(AVG(Literacy),1) avg_literacy from [SQL Project]..Data1
group by State
--order by avg_literacy desc;

select top 3 * from bottomstates order by bottomstates.literacy_per_state;

-- UNION operator

select * from (
select top 3 * from topstates order by topstates.literacy_per_state desc) a

union
select * from (
select top 3 * from bottomstates order by bottomstates.literacy_per_state) b

-- states starting with letter a

select distinct state from [SQL Project]..Data1 where LOWER(state) like 'a%';

select distinct state from [SQL Project]..Data1 where LOWER(state) like 'a%h';

-- joining two tables

select d1.District, d1.State, Sex_Ratio, population
from [SQL Project]..data1 d1 
inner join [SQL Project]..Data2 d2
on d1.District= d2.District

--females/males=sex ratio   females+males=population 
--*on equating males=population/(sex ratio+1)
--females = population - (population/(sex ratio+1))

-- total number of males and females

select State, SUM(males) Male_count, sum(females) Female_count from

(select District, State, round(population/(Sex_Ratio+1),0) as males,
round(population -(population/(sex_ratio+1)),0) as females from

(select d1.District, d1.State, Sex_Ratio/1000 as Sex_Ratio, population
from [SQL Project]..data1 d1 
inner join [SQL Project]..Data2 d2
on d1.District= d2.District) d3) d4
group by state

-- total literate and illiterate people

-- literacy ratio = total literate /population
-- total literate = literacy ration*population
-- literate + illiterate = total population
-- ill = population -( literacy ratio* population)

select  State, sum(total_literate) Literates, sum(total_illiterate) Illiterates from (

select district, State, round(Literacy_ratio*Population,0) as Total_literate,
round(Population-(Literacy_ratio*Population),0) Total_illiterate  from

(select d1.District, d1.State, Literacy/100 as Literacy_ratio, d2.population
from [SQL Project]..data1 d1 
inner join [SQL Project]..Data2 d2 on d1.District= d2.District) d3
) d4
 group by State
 order by Literates Desc

 ---- population in previous census vs current population
 -- previous cencus + (growth% of previous census) = current population
 -- p.census = population/(1+growth)

 select sum(previous_population) Previous_net_population, SUM(current_population) Current_net_population from (

select State, sum(previous_census) Previous_population, sum(population) current_population 
from
(
select District, state, round(Population/(1+Growth),0) Previous_Census, Population from 
 (
 select d1.District, d1.State, Growth, d2.population
from [SQL Project]..data1 d1 
inner join [SQL Project]..Data2 d2 on d1.District= d2.District) d3
) d4 group by State ) d5

-- population vs area

select total_area/Previous_net_population as previous_cencus_vs_area, total_area/Current_net_population as current_census_vs_area from

(select Previous_net_population, Current_net_population, total_area from
(select '1' as keyy, d6.* from

 (select sum(previous_population) Previous_net_population, SUM(current_population) Current_net_population from (

select State, sum(previous_census) Previous_population, sum(population) current_population 
from
(
select District, state, round(Population/(1+Growth),0) Previous_Census, Population from 
 (
 select d1.District, d1.State, Growth, d2.population
from [SQL Project]..data1 d1 
inner join [SQL Project]..Data2 d2 on d1.District= d2.District) d3
) d4 group by State ) d5) d6) d8
inner join

(select '1' as keyy, d7.* from
(
select sum(Area_km2) total_area from [SQL Project]..Data2) d7) d9 on d8.keyy=d9.keyy) d10


----window 
--output top 3 districts from each state with highest literacy rate

select a.* from
(select district,state,literacy,rank() over(partition by state order by literacy desc) rnk from [SQL Project]..data1) a

where a.rnk in (1,2,3) order by state































