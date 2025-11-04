select *
from layoffs;

create table layoffs_staging
like layoffs;

select *
from layoffs_staging;

insert layoffs_staging
select *
from layoffs;
 
 
select *,
row_number() over (partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_staging;

with duplicate_cte as 
(
select *,
row_number() over (partition by company,location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_staging
)
select *
from duplicate_cte
where row_num>1;


select *
from layoffs_staging;

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;



delete 
from layoffs_staging2
where row_num>1;

insert into layoffs_staging2
select *,
row_number() over (partition by company,location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_staging;

SET SQL_SAFE_UPDATES = 0;
DELETE FROM layoffs_staging2 WHERE row_num > 1;
SET SQL_SAFE_UPDATES = 1;

select *
from layoffs_staging2;

update layoffs_staging2
set company= trim(company);
update layoffs_staging2
set location = trim(location);
update layoffs_staging2
set industry= trim(industry);
update layoffs_staging2
set total_laid_off= trim(total_laid_off);
update layoffs_staging2
set percentage_laid_off= trim(percentage_laid_off);
update layoffs_staging2
set `date`= trim(`date`);
update layoffs_staging2
set stage= trim(stage);
update layoffs_staging2
set country= trim(country);
update layoffs_staging2
set Funds_raised_millions = trim(funds_raised_millions);


select distinct company
from layoffs_staging2
order by 1;

select distinct country
from layoffs_staging2
order by 1
;

update layoffs_staging2
set industry = 'Crypto'
where industry like 'crypto%';

update layoffs_staging2
set country = 'United States'
where country like 'United States%';

select * 
from layoffs_staging2
where country like 'united states';

update layoffs_staging
set date = str_to_date(`date`,'%m/%d/%Y');


alter table layoffs_staging
modify column `date` Date;



select date
from layoffs_staging
where industry ='' or industry is null ;


select *
from layoffs_staging2
where location = 'Providence' ;

update layoffs_staging2
set industry ='Travel' where company ='airbnb';

update layoffs_staging2
set industry ='Transportation' where company ='Carvana';

update layoffs_staging2
set industry ='Consumer' where company ='Juul';

with total_laidoff as 
(
select country, sum(total_laid_off) as 'sum'
from layoffs_staging2
group by country
order by 2 desc
)
select sum(sum)
from total_laidoff
;

with rolling_layoff as 
(
select trim(substring(`date`,1,7)) as 'Month', sum(total_laid_off) as 'Laid_off'
from layoffs_staging2
where trim(substring(`date`,1,7)) is not null
group by trim(substring(`date`,1,7))
order by trim(substring(`date`,1,7))
)
select `Month`, trim(Laid_off) as 'Laid off', sum(laid_off) over(order by `month`) as 'Rolling Laid off'
from rolling_layoff 
;

with rolling_layoff2 as 
(
select trim(substring(`date`,1,4)) as 'Year', sum(total_laid_off) as 'Laid_off'
from layoffs_staging2
where trim(substring(`date`,1,4)) is not null
group by trim(substring(`date`,1,4))
order by trim(substring(`date`,1,4))
)
select `Year`, trim(Laid_off) as 'Laid off', sum(laid_off) over(order by `Year`) as 'Rolling Laid off'
from rolling_layoff2 
;


select trim(substring(`date`,1,7)) as 'Month', trim(sum(total_laid_off)) as 'Laid off'
from layoffs_staging2
where trim(substring(`date`,1,7)) is not null
group by trim(substring(`date`,1,7))
order by trim(substring(`date`,1,7))
;
 
 
select trim(total_)
from layoffs_staging2
;

alter table layoffs_staging2
drop column row_num;



with chart_1 as (
select Company, trim(substring(`date`,1,7)) as 'Month', sum(total_laid_off) as 'Laid_off'
from layoffs_staging2
where trim(substring(`date`,1,7)) is not null
group by trim(substring(`date`,1,7)), Company
order by trim(substring(`date`,1,7))
), 
chart_2 as 
(
select *, dense_rank () 
over (partition by `Month` order by laid_off desc) as 'Rank'
from chart_1
order by laid_off
)
select *
from chart_2
where `rank` <=5 and laid_off is not null
order by `Month`, `Rank`
;



select *
from layoffs_staging2
;