-- 创建数据库
create table gulivideo_ori(
    videoId string, 
    uploader string, 
    age int, 
    category array<string>, 
    length int, 
    views int, 
    rate float, 
    ratings int, 
    comments int,
    relatedId array<string>)
row format delimited 
fields terminated by "\t"
collection items terminated by "&"
stored as textfile;

create table gulivideo_user_ori(
    uploader string,
    videos int,
    friends int
)
row format delimited
fields terminated by '\t'
stored as textfile;

create table gulivideo_orc
stored as orc
as select * from gulivideo_ori;

create table gulivideo_user_orc
stored as orc
as select * from gulivideo_user_ori;


