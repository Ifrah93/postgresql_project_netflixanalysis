--Netflix dataset Data Analysis
drop table if exists netflix;
create table netflix (
   show_id  varchar(6),
   type_of_content varchar(10),
   title varchar(150),
   director varchar(208),
   casts varchar(1000),
   country varchar(150),
   date_added varchar(50),
   release_year int,
   rating varchar(10),
   duration varchar(15),
   listed_in varchar(100),
   description varchar (250)
);

select * from netflix;

select count(*) as total_rows from netflix;

--count total number of movie and tv shows

select type_of_content, count(type_of_content) as total 
from netflix group by type_of_content;

--most common rating for movies and tv shows

select type_of_content, rating from
(select type_of_content, rating, count(rating) as counts,
rank() over(partition by type_of_content order by count(rating) desc) as ranking
from netflix group by type_of_content, rating)
where ranking = 1;

--all the movies released in the year 2020
select title from netflix
where type_of_content = 'Movie' and
 release_year = 2020;

--top 5 countries with the most content on netflix

select trim(unnest(string_to_array(country, ','))) as countries, 
count(type_of_content) as counts from netflix
where country is not null
group by countries
order by counts desc limit 5;

--movies with the longest watch minutes

select * from 
 (select title as movie,
  split_part(duration,' ',1):: numeric as duration 
  from netflix
  where type_of_content ='Movie')
where duration = (select max(split_part(duration,' ',1):: numeric ) from netflix);

--content added in the last 5 years

select * from netflix
where to_date(date_added, 'Month DD, YYYY')>= current_date - interval '5 years' ;

--movies directed by Dennis or Denis

select director from netflix where director like '%Dennis%' ;

--tv shows with more than 5 seasons
 
 select title, 
  split_part(duration,' ',1):: int as seasons 
  from netflix
  where type_of_content = 'TV Show' and split_part(duration,' ',1):: int > 5
  order by seasons asc;

--total number of content items in each genre
 
select trim(unnest(string_to_array(listed_in, ','))) as genre, count(title)
from netflix group by genre order by genre asc;

--all movies that are documentaries

select type_of_content, title from netflix where type_of_content = 'Movie' and
listed_in like '%Documentaries%';

--content without director

select * from netflix where director is null;

--top 10 actors who appeared in the most number of movies in the United States

select trim(unnest(string_to_array(casts, ','))) as actors, 
count(type_of_content) as total_movies
from netflix where country ilike '%united states%'
group by actors order by total_movies desc limit 10;

--