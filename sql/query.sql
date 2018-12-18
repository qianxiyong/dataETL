-- gulivideo_orc
+------------+----------------+----------+--+
|  col_name  |   data_type    | comment  |
+------------+----------------+----------+--+
| videoid    | string         |          |
| uploader   | string         |          |
| age        | int            |          |
| category   | array<string>  |          |
| length     | int            |          |
| views      | int            |          |
| rate       | float          |          |
| ratings    | int            |          |
| comments   | int            |          |
| relatedid  | array<string>  |          |
+------------+----------------+----------+--+
+---------------------+--+
|      tab_name       |
+---------------------+--+
| gulivideo_orc       |
| gulivideo_ori       |
| gulivideo_user_orc  |
| gulivideo_user_ori  |
+---------------------+--+
-- gulivideo_user_orc
+-----------+------------+----------+--+
| col_name  | data_type  | comment  |
+-----------+------------+----------+--+
| uploader  | string     |          |
| videos    | int        |          |
| friends   | int        |          |
+-----------+------------+----------+--+

/*
统计视频观看数 Top10
*/
select
videoid,uploader,category,views
from gulivideo_orc
order by views desc
limit 10;
+--------------+------------------+---------------------+-----------+--+
|   videoid    |     uploader     |      category       |   views   |
+--------------+------------------+---------------------+-----------+--+
| dMH0bHeiRNg  | judsonlaipply    | ["Comedy"]          | 42513417  |
| 0XxI-hvPRRA  | smosh            | ["Comedy"]          | 20282464  |
| 1dmVU08zVpA  | NBC              | ["Entertainment"]   | 16087899  |
| RB-wUgnyGv0  | ChrisInScotland  | ["Entertainment"]   | 15712924  |
| QjA5faZF1A8  | guitar90         | ["Music"]           | 15256922  |
| -_CSo1gOd48  | tasha            | ["People","Blogs"]  | 13199833  |
| 49IDp76kjPw  | TexMachina       | ["Comedy"]          | 11970018  |
| tYnn51C3X_w  | CowSayingMoo     | ["Music"]           | 11823701  |
| pv5zWaTEVkI  | OkGo             | ["Music"]           | 11672017  |
| D2kJZOfq7zk  | mrWoot           | ["People","Blogs"]  | 11184051  |
+--------------+------------------+---------------------+-----------+--+



/*
    统计最热的10个 视频类别
*/
-- 先将类别拆开 行转列得到临时表
create table gulivideo_orc_category_item
stored as orc 
as select gulivideo_orc.*,category_item
from gulivideo_orc lateral view explode(category) tmp as category_item

select category_item,sum(views) total_views
from gulivideo_orc_category_item
group by category_item
order by total_views desc limit 10;
+----------------+--------------+--+
| category_item  | total_views  |
+----------------+--------------+--+
| Music          | 2426199511   |
| Entertainment  | 1644510629   |
| Comedy         | 1603337065   |
| Film           | 659449540    |
| Animation      | 659449540    |
| Sports         | 647412772    |
| Games          | 505658305    |
| Gadgets        | 505658305    |
| Blogs          | 425607955    |
| People         | 425607955    |
+----------------+--------------+--+

/*
11.4.3 统计最热 Top20 视频的 类别中每个类别 包含 Top20 的视频的个数
*/
select videoid,views,category
from gulivideo_orc
order by views desc
limit 20;

select t1.videoid,t1.views,category_item 
from (
    select videoid,views,category
    from gulivideo_orc
    order by views desc
    limit 20
) t1 lateral view explode(category) tmp as category_item;
+--------------+-----------+----------------+--+
|  t1.videoid  | t1.views  | category_item  |
+--------------+-----------+----------------+--+
| dMH0bHeiRNg  | 42513417  | Comedy         |
| 0XxI-hvPRRA  | 20282464  | Comedy         |
| 1dmVU08zVpA  | 16087899  | Entertainment  |
| RB-wUgnyGv0  | 15712924  | Entertainment  |
| QjA5faZF1A8  | 15256922  | Music          |
| -_CSo1gOd48  | 13199833  | People         |
| -_CSo1gOd48  | 13199833  | Blogs          |
| 49IDp76kjPw  | 11970018  | Comedy         |
| tYnn51C3X_w  | 11823701  | Music          |
| pv5zWaTEVkI  | 11672017  | Music          |
| D2kJZOfq7zk  | 11184051  | People         |
| D2kJZOfq7zk  | 11184051  | Blogs          |
| vr3x_RRJdd4  | 10786529  | Entertainment  |
| lsO6D1rwrKc  | 10334975  | Entertainment  |
| 5P6UU6m3cqk  | 10107491  | Comedy         |
| 8bbTtPL1jRs  | 9579911   | Music          |
| _BuRwH59oAo  | 9566609   | Comedy         |
| aRNzWyD7C9o  | 8825788   |  UNA           |
| UMf40daefsI  | 7533070   | Music          |
| ixsZy2425eY  | 7456875   | Entertainment  |
| MNxwAU_xAMk  | 7066676   | Comedy         |
| RUCZJVJ_M8o  | 6952767   | Entertainment  |
+--------------+-----------+----------------+--+
select category_item , sum(1) total
from (
    select t1.videoid,t1.views,category_item 
        from (
            select videoid,views,category
            from gulivideo_orc
            order by views desc
            limit 20
        ) t1 lateral view explode(category) tmp as category_item
) t3 group by category_item;
--最好再按照total排序 order by total desc
+----------------+--------+--+
| category_item  | total  |
+----------------+--------+--+
|  UNA           | 1      |
| Blogs          | 2      |
| Comedy         | 6      |
| Entertainment  | 6      |
| Music          | 5      |
| People         | 2      |
+----------------+--------+--+
/*
11.4.4 统计视频观看数Top50所关联视频的所属类别Rank
*/
select relatedid,views
from gulivideo_orc
order by views desc
limit 50;


select ids
from (
    select relatedid,views
    from gulivideo_orc
    order by views desc
    limit 50
)
t1 lateral view explode(relatedid) tmp as ids;

select t3.category_item,sum(1) num
from (
    select ids
        from (
            select relatedid,views
            from gulivideo_orc
            order by views desc
            limit 50
        )
    t1 lateral view explode(relatedid) tmp as ids
) t2 join gulivideo_orc_category_item t3 
on t2.ids = t3.videoid
group by t3.category_item;

select category_item,num,rank() over(order by num) --应该写为over(order by num desc) rank_no
from (select t3.category_item,sum(1) num
from (
        select ids
            from (
                select relatedid,views
                from gulivideo_orc
                order by views desc
                limit 50
            )
        t1 lateral view explode(relatedid) tmp as ids
    ) t2 join gulivideo_orc_category_item t3 
    on t2.ids = t3.videoid group by t3.category_item) t4;
+----------------+------+----------------+--+
| category_item  | num  | rank_window_0  |
+----------------+------+----------------+--+
| Vehicles       | 4    | 1              |
| Autos          | 4    | 1              |
| Animals        | 11   | 3              |
| Pets           | 11   | 3              |
| Travel         | 12   | 5              |
| Places         | 12   | 5              |
|  UNA           | 13   | 7              |
| DIY            | 14   | 8              |
| Howto          | 14   | 8              |
| Sports         | 19   | 10             |
| Games          | 22   | 11             |
| Gadgets        | 22   | 11             |
| Politics       | 24   | 13             |
| News           | 24   | 13             |
| Film           | 47   | 15             |
| Animation      | 47   | 15             |
| People         | 51   | 17             |
| Blogs          | 51   | 17             |
| Music          | 195  | 19             |
| Entertainment  | 216  | 20             |
| Comedy         | 237  | 21             |
+----------------+------+----------------+--+
/*
11.4.5 统计每个类别中的视频热度 Top10(tips:开窗加子查询 行转列 列转行加子查询)
*/

select videoid,views,dense_rank() over(partition by category_item order by views desc) dense_rank_no 
from gulivideo_orc_category_item;

select videoid,views,dense_rank_no from 
(
   select videoid,views,dense_rank() over(partition by category_item order by views desc) dense_rank_no 
   from gulivideo_orc_category_item 
) t1
where dense_rank_no <= 10;
 +--------------+-----------+----------------+--+
|   videoid    |   views   | dense_rank_no  |
+--------------+-----------+----------------+--+
| aRNzWyD7C9o  | 8825788   | 1              |
| jtExxsiLgPM  | 5320895   | 2              |
| PxNNR4symuE  | 4033376   | 3              |
| 8cjTSvvoddc  | 3486368   | 4              |
| LIhbap3FlGc  | 2849832   | 5              |
| lCSTULqmmYE  | 2179562   | 6              |
| UyTxWvp8upM  | 2106933   | 7              |
| y6oXEWowirI  | 1666084   | 8              |
| _x2-AmY8FI8  | 1403113   | 9              |
| ICoDFooBXpU  | 1376215   | 10             |
| 2GWPOPSXGYI  | 3660009   | 1              |
| xmsV9R8FsDA  | 3164582   | 2              |
| 12PsUW-8ge4  | 3133523   | 3              |
| OeNggIGSKH8  | 2457750   | 4              |
| WofFb_eOxxA  | 2075728   | 5              |
| AgEmZ39EtFk  | 1999469   | 6              |
| a-gW3RbJd8U  | 1836870   | 7              |
| 8CL2hetqpfg  | 1646808   | 8              |
| QmroaYVD_so  | 1645984   | 9              |
| Sg9x5mUjbH8  | 1527238   | 10             |
| sdUUx5FdySs  | 5840839   | 1              |
| 6B26asyGKDo  | 5147533   | 2              |
| H20dhY01Xjk  | 3772116   | 3              |
| 55YYaJIrmzo  | 3356163   | 4              |
| JzqumbhfxRo  | 3230774   | 5              |
| eAhfZUZiwSE  | 3114215   | 6              |
| h7svw0m-wO0  | 2866490   | 7              |
| tAq3hWBlalU  | 2830024   | 8              |
| AJzU3NjDikY  | 2569611   | 9              |
| ElrldD02if0  | 2337238   | 10             |
| RjrEQaG5jPM  | 2803140   | 1              |
| cv157ZIInUk  | 2773979   | 2              |
| Gyg9U1YaVk8  | 1832224   | 3              |
| 6GNB7xT3rNE  | 1412497   | 4              |
| tth9krDtxII  | 1347317   | 5              |
| 46LQd9dXFRU  | 1262173   | 6              |
| pdiuDXwgrjQ  | 1013697   | 7              |
| kY_cDpENQLE  | 956665    | 8              |
| YtxfbxGz1u4  | 942604    | 9              |
| aCamHfJwSGU  | 847442    | 10             |
| -_CSo1gOd48  | 13199833  | 1              |
| D2kJZOfq7zk  | 11184051  | 2              |
| pa_7P5AbUww  | 5705136   | 3              |
| f4B-r8KJhlE  | 4937616   | 4              |
| LB84A3zcmVo  | 4866739   | 5              |
| tXNquTYnyg0  | 3613323   | 6              |
| EYppbbbSxjc  | 2896562   | 7              |
| LH7vrLlDZ6U  | 2615359   | 8              |
| bTV85fQhj0E  | 2192656   | 9              |
| eVFF98kNg8Q  | 1813803   | 10             |
| dMH0bHeiRNg  | 42513417  | 1              |
| 0XxI-hvPRRA  | 20282464  | 2              |
| 49IDp76kjPw  | 11970018  | 3              |
| 5P6UU6m3cqk  | 10107491  | 4              |
| _BuRwH59oAo  | 9566609   | 5              |
| MNxwAU_xAMk  | 7066676   | 6              |
| pYak2F1hUYA  | 6322117   | 7              |
| h0zAlXr1UOs  | 5826923   | 8              |
| C8rjr4jmWd0  | 5587299   | 9              |
| R4cQ3BoHFas  | 5508079   | 10             |
| hut3VRL5XRE  | 2684989   | 1              |
| YYTpb-QXV0k  | 2492153   | 2              |
| Pf3z935R37E  | 2096661   | 3              |
| Yd99gyE4jCk  | 1918946   | 4              |
| koQFjKwVFB0  | 1757071   | 5              |
| f5Fg6KFcOsU  | 1751817   | 6              |
| STQ3nhXuuEM  | 1713974   | 7              |
| FtKuBKIaVvs  | 1520774   | 8              |
| M0ODskdEPnQ  | 1503351   | 9              |
| uFwCk4UPtlM  | 1500110   | 10             |
| 1dmVU08zVpA  | 16087899  | 1              |
| RB-wUgnyGv0  | 15712924  | 2              |
| vr3x_RRJdd4  | 10786529  | 3              |
| lsO6D1rwrKc  | 10334975  | 4              |
| ixsZy2425eY  | 7456875   | 5              |
| RUCZJVJ_M8o  | 6952767   | 6              |
| tFXLbXyXy6M  | 5810013   | 7              |
| 7uwCEnDgd5o  | 5280504   | 8              |
| 2KrdBUFeFtY  | 4676195   | 9              |
| vD4OnHCRd_4  | 4230610   | 10             |
| sdUUx5FdySs  | 5840839   | 1              |
| 6B26asyGKDo  | 5147533   | 2              |
| H20dhY01Xjk  | 3772116   | 3              |
| 55YYaJIrmzo  | 3356163   | 4              |
| JzqumbhfxRo  | 3230774   | 5              |
| eAhfZUZiwSE  | 3114215   | 6              |
| h7svw0m-wO0  | 2866490   | 7              |
| tAq3hWBlalU  | 2830024   | 8              |
| AJzU3NjDikY  | 2569611   | 9              |
| ElrldD02if0  | 2337238   | 10             |
| pFlcqWQVVuU  | 3651600   | 1              |
| bcu8ZdJ2dQo  | 2617568   | 2              |
| -G7h626wJwM  | 2565170   | 3              |
| oMaTZFCLbq0  | 2554620   | 4              |
| GxSdKF5Fd38  | 2468395   | 5              |
| z1lj87UyvfY  | 2373875   | 6              |
| KhCmfX_PQ7E  | 1967929   | 7              |
| 2SVMFCZgvNM  | 1813794   | 8              |
| gPutYwiiE0o  | 1633482   | 9              |
| 7wt5FiZQrgM  | 1399531   | 10             |
+--------------+-----------+----------------+--+
|   videoid    |   views   | dense_rank_no  |
+--------------+-----------+----------------+--+
| pFlcqWQVVuU  | 3651600   | 1              |
| bcu8ZdJ2dQo  | 2617568   | 2              |
| -G7h626wJwM  | 2565170   | 3              |
| oMaTZFCLbq0  | 2554620   | 4              |
| GxSdKF5Fd38  | 2468395   | 5              |
| z1lj87UyvfY  | 2373875   | 6              |
| KhCmfX_PQ7E  | 1967929   | 7              |
| 2SVMFCZgvNM  | 1813794   | 8              |
| gPutYwiiE0o  | 1633482   | 9              |
| 7wt5FiZQrgM  | 1399531   | 10             |
| hut3VRL5XRE  | 2684989   | 1              |
| YYTpb-QXV0k  | 2492153   | 2              |
| Pf3z935R37E  | 2096661   | 3              |
| Yd99gyE4jCk  | 1918946   | 4              |
| koQFjKwVFB0  | 1757071   | 5              |
| f5Fg6KFcOsU  | 1751817   | 6              |
| STQ3nhXuuEM  | 1713974   | 7              |
| FtKuBKIaVvs  | 1520774   | 8              |
| M0ODskdEPnQ  | 1503351   | 9              |
| uFwCk4UPtlM  | 1500110   | 10             |
| QjA5faZF1A8  | 15256922  | 1              |
| tYnn51C3X_w  | 11823701  | 2              |
| pv5zWaTEVkI  | 11672017  | 3              |
| 8bbTtPL1jRs  | 9579911   | 4              |
| UMf40daefsI  | 7533070   | 5              |
| -xEzGIuY7kw  | 6946033   | 6              |
| d6C0bNDqf3Y  | 6935578   | 7              |
| HSoVKUVOnfQ  | 6193057   | 8              |
| 3URfWTEPmtE  | 5581171   | 9              |
| thtmaZnxk_0  | 5142238   | 10             |
| hr23tpWX8lM  | 4706030   | 1              |
| YgW7or1TuFk  | 2899397   | 2              |
| nda_OSWeyn8  | 2817078   | 3              |
| 7SV2sfoPAY8  | 2803520   | 4              |
| HBa9wdOANHw  | 2348709   | 5              |
| xDh_pvv1tUM  | 2335060   | 6              |
| p_YMigZmUuk  | 2326680   | 7              |
| QCVxQ_3Ejkg  | 2318782   | 8              |
| a9WB_PXjTBo  | 2310583   | 9              |
| qSM_3fyiaxM  | 2291369   | 10             |
| -_CSo1gOd48  | 13199833  | 1              |
| D2kJZOfq7zk  | 11184051  | 2              |
| pa_7P5AbUww  | 5705136   | 3              |
| f4B-r8KJhlE  | 4937616   | 4              |
| LB84A3zcmVo  | 4866739   | 5              |
| tXNquTYnyg0  | 3613323   | 6              |
| EYppbbbSxjc  | 2896562   | 7              |
| LH7vrLlDZ6U  | 2615359   | 8              |
| bTV85fQhj0E  | 2192656   | 9              |
| eVFF98kNg8Q  | 1813803   | 10             |
| 2GWPOPSXGYI  | 3660009   | 1              |
| xmsV9R8FsDA  | 3164582   | 2              |
| 12PsUW-8ge4  | 3133523   | 3              |
| OeNggIGSKH8  | 2457750   | 4              |
| WofFb_eOxxA  | 2075728   | 5              |
| AgEmZ39EtFk  | 1999469   | 6              |
| a-gW3RbJd8U  | 1836870   | 7              |
| 8CL2hetqpfg  | 1646808   | 8              |
| QmroaYVD_so  | 1645984   | 9              |
| Sg9x5mUjbH8  | 1527238   | 10             |
| bNF_P281Uu4  | 5231539   | 1              |
| s5ipz_0uC_U  | 1198840   | 2              |
| 6jJW7aSNCzU  | 1143287   | 3              |
| dVRUBIyRAYk  | 1000309   | 4              |
| lqbt6X4ZgEI  | 921593    | 5              |
| RIH1I1doUI4  | 879577    | 6              |
| AlPqL7IUT6M  | 845180    | 7              |
| _5QUdvUhCZc  | 819974    | 8              |
| m9A_vxIOB-I  | 677876    | 9              |
| CL6f3Cyh85w  | 611786    | 10             |
| hr23tpWX8lM  | 4706030   | 1              |
| YgW7or1TuFk  | 2899397   | 2              |
| nda_OSWeyn8  | 2817078   | 3              |
| 7SV2sfoPAY8  | 2803520   | 4              |
| HBa9wdOANHw  | 2348709   | 5              |
| xDh_pvv1tUM  | 2335060   | 6              |
| p_YMigZmUuk  | 2326680   | 7              |
| QCVxQ_3Ejkg  | 2318782   | 8              |
| a9WB_PXjTBo  | 2310583   | 9              |
| qSM_3fyiaxM  | 2291369   | 10             |
| Ugrlzm7fySE  | 2867888   | 1              |
| q8t7iSGAKik  | 2735003   | 2              |
| 7vL19q8yL54  | 2527713   | 3              |
| g3dXfFZ6SH0  | 2295871   | 4              |
| P-bWsOK-h98  | 2268107   | 5              |
| HD8f_Qgwc50  | 2165475   | 6              |
| qjWQNwv-GJ4  | 2132591   | 7              |
| eN0V-rJQSHE  | 2124653   | 8              |
| fM38G1450Ew  | 2052778   | 9              |
| 3PGzrfE8rJg  | 2013466   | 10             |
| bNF_P281Uu4  | 5231539   | 1              |
| s5ipz_0uC_U  | 1198840   | 2              |
| 6jJW7aSNCzU  | 1143287   | 3              |
| dVRUBIyRAYk  | 1000309   | 4              |
| lqbt6X4ZgEI  | 921593    | 5              |
| RIH1I1doUI4  | 879577    | 6              |
| AlPqL7IUT6M  | 845180    | 7              |
| _5QUdvUhCZc  | 819974    | 8              |
| m9A_vxIOB-I  | 677876    | 9              |
| CL6f3Cyh85w  | 611786    | 10             |
+--------------+-----------+----------------+--+
|   videoid    |   views   | dense_rank_no  |
+--------------+-----------+----------------+--+
| RjrEQaG5jPM  | 2803140   | 1              |
| cv157ZIInUk  | 2773979   | 2              |
| Gyg9U1YaVk8  | 1832224   | 3              |
| 6GNB7xT3rNE  | 1412497   | 4              |
| tth9krDtxII  | 1347317   | 5              |
| 46LQd9dXFRU  | 1262173   | 6              |
| pdiuDXwgrjQ  | 1013697   | 7              |
| kY_cDpENQLE  | 956665    | 8              |
| YtxfbxGz1u4  | 942604    | 9              |
| aCamHfJwSGU  | 847442    | 10             |
+--------------+-----------+----------------+--+
/*
11.4.6 统计每个类别中视频流量Top10
*/
select category_item,videoid,ratings,dense_rank_no from 
(
   select category_item,videoid,ratings,dense_rank() over(partition by category_item order by ratings desc) dense_rank_no 
   from gulivideo_orc_category_item 
) t1
where dense_rank_no <= 10;
+----------------+--------------+----------+----------------+--+
| category_item  |   videoid    | ratings  | dense_rank_no  |
+----------------+--------------+----------+----------------+--+
|  UNA           | R0049_tDAU8  | 70972    | 1              |
|  UNA           | Ggg0bsUfLBk  | 42168    | 2              |
|  UNA           | aRNzWyD7C9o  | 36815    | 3              |
|  UNA           | IH2MSl81yXA  | 21057    | 4              |
|  UNA           | ICoDFooBXpU  | 7456     | 5              |
|  UNA           | 0m3SXpZK2Xw  | 6119     | 6              |
|  UNA           | t68M9mRX0qY  | 5646     | 7              |
|  UNA           | 3jLRNiK6oWY  | 3128     | 8              |
|  UNA           | EErOwBLC28M  | 3018     | 9              |
|  UNA           | _x2-AmY8FI8  | 2844     | 10             |
| Animals        | 2GWPOPSXGYI  | 12086    | 1              |
| Animals        | xmsV9R8FsDA  | 11918    | 2              |
| Animals        | AgEmZ39EtFk  | 9509     | 3              |
| Animals        | 12PsUW-8ge4  | 7856     | 4              |
| Animals        | Sg9x5mUjbH8  | 7720     | 5              |
| Animals        | a-gW3RbJd8U  | 6888     | 6              |
| Animals        | d9QwK5EHSmg  | 6598     | 7              |
| Animals        | QmroaYVD_so  | 6554     | 8              |
| Animals        | OeNggIGSKH8  | 5921     | 9              |
| Animals        | l9l19D2sIHI  | 5808     | 10             |
| Animation      | sdUUx5FdySs  | 42417    | 1              |
| Animation      | 6B26asyGKDo  | 31792    | 2              |
| Animation      | JzqumbhfxRo  | 27545    | 3              |
| Animation      | h7svw0m-wO0  | 27372    | 4              |
| Animation      | AJzU3NjDikY  | 22973    | 5              |
| Animation      | PnCVZozHTG8  | 14309    | 6              |
| Animation      | hquCf-sS2sU  | 13377    | 7              |
| Animation      | o9698TqtY4A  | 12457    | 8              |
| Animation      | EBcoo8i33L0  | 12376    | 9              |
| Animation      | 55YYaJIrmzo  | 10859    | 10             |
| Autos          | RjrEQaG5jPM  | 5034     | 1              |
| Autos          | 46LQd9dXFRU  | 3852     | 2              |
| Autos          | cv157ZIInUk  | 2850     | 3              |
| Autos          | 8c1GGgXLepY  | 2487     | 4              |
| Autos          | aCamHfJwSGU  | 2108     | 5              |
| Autos          | 3Xo5GY4kDXg  | 1770     | 6              |
| Autos          | SlTvSUCCqPo  | 1730     | 7              |
| Autos          | Gyg9U1YaVk8  | 1705     | 8              |
| Autos          | Z2LUz2WVcek  | 1590     | 9              |
| Autos          | pdiuDXwgrjQ  | 1536     | 10             |
| Blogs          | D2kJZOfq7zk  | 42162    | 1              |
| Blogs          | -_CSo1gOd48  | 38045    | 2              |
| Blogs          | p78oOk7dylQ  | 36271    | 3              |
| Blogs          | uWEOnBKPhEA  | 20647    | 4              |
| Blogs          | ZtH7DTu-DgI  | 17553    | 5              |
| Blogs          | Ckh39MWsx80  | 16470    | 6              |
| Blogs          | DRvaxPXyhVw  | 13729    | 7              |
| Blogs          | TweU77cDrgE  | 12403    | 8              |
| Blogs          | urIZ0bqo7dU  | 12189    | 9              |
| Blogs          | eVFF98kNg8Q  | 10938    | 10             |
| Comedy         | dMH0bHeiRNg  | 87520    | 1              |
| Comedy         | 0XxI-hvPRRA  | 80710    | 2              |
| Comedy         | nojWJ6-XmeQ  | 62265    | 3              |
| Comedy         | CQO3K8BcyGM  | 36460    | 4              |
| Comedy         | 5P6UU6m3cqk  | 34972    | 5              |
| Comedy         | _R8prS1jsvI  | 29453    | 6              |
| Comedy         | 49IDp76kjPw  | 22579    | 7              |
| Comedy         | N6j475XI1Xg  | 20593    | 8              |
| Comedy         | PKnloiM-0Ns  | 19728    | 9              |
| Comedy         | 6D9p-wmtIJc  | 19043    | 10             |
| DIY            | 6gmP4nk0EOE  | 10757    | 1              |
| DIY            | a15KgyXBX24  | 8108     | 2              |
| DIY            | qIXs6Sh0DKs  | 7897     | 3              |
| DIY            | hut3VRL5XRE  | 7097     | 4              |
| DIY            | YYTpb-QXV0k  | 6479     | 5              |
| DIY            | ZDepABf9JOg  | 6388     | 6              |
| DIY            | Pf3z935R37E  | 5276     | 7              |
| DIY            | yISqCAnROh8  | 4780     | 8              |
| DIY            | aZws98jw67g  | 4676     | 9              |
| DIY            | VuoljANz4EA  | 4625     | 10             |
| Entertainment  | JahdnOQ9XCA  | 59008    | 1              |
| Entertainment  | VcQIwbvGRKU  | 46472    | 2              |
| Entertainment  | vr3x_RRJdd4  | 39079    | 3              |
| Entertainment  | 3gg5LOd_Zus  | 35964    | 4              |
| Entertainment  | 1dmVU08zVpA  | 30085    | 5              |
| Entertainment  | 9VKlskwm378  | 16772    | 6              |
| Entertainment  | LVCb52iQrfo  | 16253    | 7              |
| Entertainment  | AX3aSeHwf7A  | 15595    | 8              |
| Entertainment  | RUCZJVJ_M8o  | 13932    | 9              |
| Entertainment  | 2KrdBUFeFtY  | 12231    | 10             |
| Film           | sdUUx5FdySs  | 42417    | 1              |
| Film           | 6B26asyGKDo  | 31792    | 2              |
| Film           | JzqumbhfxRo  | 27545    | 3              |
| Film           | h7svw0m-wO0  | 27372    | 4              |
| Film           | AJzU3NjDikY  | 22973    | 5              |
| Film           | PnCVZozHTG8  | 14309    | 6              |
| Film           | hquCf-sS2sU  | 13377    | 7              |
| Film           | o9698TqtY4A  | 12457    | 8              |
| Film           | EBcoo8i33L0  | 12376    | 9              |
| Film           | 55YYaJIrmzo  | 10859    | 10             |
| Gadgets        | KhCmfX_PQ7E  | 14100    | 1              |
| Gadgets        | gPutYwiiE0o  | 11132    | 2              |
| Gadgets        | QKXWAE8YYxY  | 10799    | 3              |
| Gadgets        | 1kA8h3Wmk8U  | 10050    | 4              |
| Gadgets        | pFlcqWQVVuU  | 8784     | 5              |
| Gadgets        | zQoAUI84amI  | 8343     | 6              |
| Gadgets        | Hfmx4sZNhXU  | 7882     | 7              |
| Gadgets        | GxSdKF5Fd38  | 6982     | 8              |
| Gadgets        | wwLrgxtALWs  | 6429     | 9              |
| Gadgets        | D8ATpkCv74E  | 5570     | 10             |
+----------------+--------------+----------+----------------+--+
| category_item  |   videoid    | ratings  | dense_rank_no  |
+----------------+--------------+----------+----------------+--+
| Games          | KhCmfX_PQ7E  | 14100    | 1              |
| Games          | gPutYwiiE0o  | 11132    | 2              |
| Games          | QKXWAE8YYxY  | 10799    | 3              |
| Games          | 1kA8h3Wmk8U  | 10050    | 4              |
| Games          | pFlcqWQVVuU  | 8784     | 5              |
| Games          | zQoAUI84amI  | 8343     | 6              |
| Games          | Hfmx4sZNhXU  | 7882     | 7              |
| Games          | GxSdKF5Fd38  | 6982     | 8              |
| Games          | wwLrgxtALWs  | 6429     | 9              |
| Games          | D8ATpkCv74E  | 5570     | 10             |
| Howto          | 6gmP4nk0EOE  | 10757    | 1              |
| Howto          | a15KgyXBX24  | 8108     | 2              |
| Howto          | qIXs6Sh0DKs  | 7897     | 3              |
| Howto          | hut3VRL5XRE  | 7097     | 4              |
| Howto          | YYTpb-QXV0k  | 6479     | 5              |
| Howto          | ZDepABf9JOg  | 6388     | 6              |
| Howto          | Pf3z935R37E  | 5276     | 7              |
| Howto          | yISqCAnROh8  | 4780     | 8              |
| Howto          | aZws98jw67g  | 4676     | 9              |
| Howto          | VuoljANz4EA  | 4625     | 10             |
| Music          | QjA5faZF1A8  | 120506   | 1              |
| Music          | pv5zWaTEVkI  | 42386    | 2              |
| Music          | UMf40daefsI  | 31886    | 3              |
| Music          | tYnn51C3X_w  | 29479    | 4              |
| Music          | 59ZX5qdIEB0  | 21481    | 5              |
| Music          | FLn45-7Pn2Y  | 21249    | 6              |
| Music          | -xEzGIuY7kw  | 20828    | 7              |
| Music          | HSoVKUVOnfQ  | 19803    | 8              |
| Music          | ARHyRI9_NB4  | 19243    | 9              |
| Music          | gg5_mlQOsUQ  | 19190    | 10             |
| News           | rU8iYeAzL1U  | 19241    | 1              |
| News           | p_YMigZmUuk  | 17639    | 2              |
| News           | k8x14cLGh5o  | 12377    | 3              |
| News           | c2fnvYH-fUU  | 11750    | 4              |
| News           | VXwarrIYLJ4  | 11024    | 5              |
| News           | AVESRceJL5k  | 10587    | 6              |
| News           | 0DoibU5njEM  | 9722     | 7              |
| News           | xDh_pvv1tUM  | 9543     | 8              |
| News           | QCVxQ_3Ejkg  | 8120     | 9              |
| News           | qdS5lkeN8_8  | 6798     | 10             |
| People         | D2kJZOfq7zk  | 42162    | 1              |
| People         | -_CSo1gOd48  | 38045    | 2              |
| People         | p78oOk7dylQ  | 36271    | 3              |
| People         | uWEOnBKPhEA  | 20647    | 4              |
| People         | ZtH7DTu-DgI  | 17553    | 5              |
| People         | Ckh39MWsx80  | 16470    | 6              |
| People         | DRvaxPXyhVw  | 13729    | 7              |
| People         | TweU77cDrgE  | 12403    | 8              |
| People         | urIZ0bqo7dU  | 12189    | 9              |
| People         | eVFF98kNg8Q  | 10938    | 10             |
| Pets           | 2GWPOPSXGYI  | 12086    | 1              |
| Pets           | xmsV9R8FsDA  | 11918    | 2              |
| Pets           | AgEmZ39EtFk  | 9509     | 3              |
| Pets           | 12PsUW-8ge4  | 7856     | 4              |
| Pets           | Sg9x5mUjbH8  | 7720     | 5              |
| Pets           | a-gW3RbJd8U  | 6888     | 6              |
| Pets           | d9QwK5EHSmg  | 6598     | 7              |
| Pets           | QmroaYVD_so  | 6554     | 8              |
| Pets           | OeNggIGSKH8  | 5921     | 9              |
| Pets           | l9l19D2sIHI  | 5808     | 10             |
| Places         | bNF_P281Uu4  | 29152    | 1              |
| Places         | RIH1I1doUI4  | 4077     | 2              |
| Places         | _5QUdvUhCZc  | 4007     | 3              |
| Places         | WXL-CTMku1o  | 3260     | 4              |
| Places         | lqbt6X4ZgEI  | 2966     | 5              |
| Places         | 8L7SxcBiDOY  | 2615     | 6              |
| Places         | JFeSH655mas  | 2463     | 7              |
| Places         | tIzycq8252Q  | 2223     | 8              |
| Places         | bGkZSiENKIA  | 2159     | 9              |
| Places         | m9A_vxIOB-I  | 1966     | 10             |
| Politics       | rU8iYeAzL1U  | 19241    | 1              |
| Politics       | p_YMigZmUuk  | 17639    | 2              |
| Politics       | k8x14cLGh5o  | 12377    | 3              |
| Politics       | c2fnvYH-fUU  | 11750    | 4              |
| Politics       | VXwarrIYLJ4  | 11024    | 5              |
| Politics       | AVESRceJL5k  | 10587    | 6              |
| Politics       | 0DoibU5njEM  | 9722     | 7              |
| Politics       | xDh_pvv1tUM  | 9543     | 8              |
| Politics       | QCVxQ_3Ejkg  | 8120     | 9              |
| Politics       | qdS5lkeN8_8  | 6798     | 10             |
| Sports         | sMEnn0xJ0l0  | 11478    | 1              |
| Sports         | Ugrlzm7fySE  | 8541     | 2              |
| Sports         | 8X2_zsnPkq8  | 7359     | 3              |
| Sports         | qjWQNwv-GJ4  | 6377     | 4              |
| Sports         | KtdYsd_QRmc  | 5819     | 5              |
| Sports         | 7vL19q8yL54  | 5712     | 6              |
| Sports         | RosbR3tISM0  | 5478     | 7              |
| Sports         | l7wDsaMsypk  | 3414     | 8              |
| Sports         | Jm9yDKizlpA  | 3389     | 9              |
| Sports         | P-bWsOK-h98  | 3322     | 10             |
| Travel         | bNF_P281Uu4  | 29152    | 1              |
| Travel         | RIH1I1doUI4  | 4077     | 2              |
| Travel         | _5QUdvUhCZc  | 4007     | 3              |
| Travel         | WXL-CTMku1o  | 3260     | 4              |
| Travel         | lqbt6X4ZgEI  | 2966     | 5              |
| Travel         | 8L7SxcBiDOY  | 2615     | 6              |
| Travel         | JFeSH655mas  | 2463     | 7              |
| Travel         | tIzycq8252Q  | 2223     | 8              |
| Travel         | bGkZSiENKIA  | 2159     | 9              |
| Travel         | m9A_vxIOB-I  | 1966     | 10             |
+----------------+--------------+----------+----------------+--+
| category_item  |   videoid    | ratings  | dense_rank_no  |
+----------------+--------------+----------+----------------+--+
| Vehicles       | RjrEQaG5jPM  | 5034     | 1              |
| Vehicles       | 46LQd9dXFRU  | 3852     | 2              |
| Vehicles       | cv157ZIInUk  | 2850     | 3              |
| Vehicles       | 8c1GGgXLepY  | 2487     | 4              |
| Vehicles       | aCamHfJwSGU  | 2108     | 5              |
| Vehicles       | 3Xo5GY4kDXg  | 1770     | 6              |
| Vehicles       | SlTvSUCCqPo  | 1730     | 7              |
| Vehicles       | Gyg9U1YaVk8  | 1705     | 8              |
| Vehicles       | Z2LUz2WVcek  | 1590     | 9              |
| Vehicles       | pdiuDXwgrjQ  | 1536     | 10             |
+----------------+--------------+----------+----------------+--+

/*
*11.4.7 统计上传视频最多的用户 Top10 以及他们上传的观看次数在前 20 的视频(tip:运用连接查询)
*/

select uploader,videos
from gulivideo_user_orc
order by videos desc limit 10;

select t2.uploader,t2.videoid,t2.views
from (
    select uploader,videos
    from gulivideo_user_orc
    order by videos desc limit 10
) t1 join gulivideo_orc t2 on t1.uploader=t2.uploader;

select uploader,videoid,views,dense_rank() over(partition by uploader order by views desc) dense_rank_no
from (

    select t2.uploader,t2.videoid,t2.views
from (
    select uploader,videos
    from gulivideo_user_orc
    order by videos desc limit 10
) t1 join gulivideo_orc t2 on t1.uploader=t2.uploader
) t3;

select uploader,videoid,views,dense_rank_no
from (
   select uploader,videoid,views,dense_rank() over(partition by uploader order by views desc) dense_rank_no
from (

    select t2.uploader,t2.videoid,t2.views
from (
    select uploader,videos
    from gulivideo_user_orc
    order by videos desc limit 10
) t1 join gulivideo_orc t2 on t1.uploader=t2.uploader
) t3 
) t4
where dense_rank_no <= 20;

select * from gulivideo_user_orc;

+----------------+--------------+--------+----------------+--+
|    uploader    |   videoid    | views  | dense_rank_no  |
+----------------+--------------+--------+----------------+--+
| Ruchaneewan    | 5_T5Inddsuo  | 3132   | 1              |
| Ruchaneewan    | wje4lUtbYNU  | 1086   | 2              |
| Ruchaneewan    | i8rLbOUhAlM  | 549    | 3              |
| Ruchaneewan    | OwnEtde9_Co  | 453    | 4              |
| Ruchaneewan    | 5Zf0lbAdJP0  | 441    | 5              |
| Ruchaneewan    | wenI5MrYT20  | 426    | 6              |
| Ruchaneewan    | Iq4e3SopjxQ  | 420    | 7              |
| Ruchaneewan    | 3hzOiFP-5so  | 420    | 7              |
| Ruchaneewan    | JgyOlXjjuw0  | 418    | 8              |
| Ruchaneewan    | fGBVShTsuyo  | 395    | 9              |
| Ruchaneewan    | O3aoL70DlVc  | 389    | 10             |
| Ruchaneewan    | q4y2ZS5OQ88  | 344    | 11             |
| Ruchaneewan    | lyUJB2eMVVg  | 271    | 12             |
| Ruchaneewan    | _RF_3VhaQpw  | 242    | 13             |
| Ruchaneewan    | DDl2cjI-aJs  | 231    | 14             |
| Ruchaneewan    | xbYyjUdhtJw  | 227    | 15             |
| Ruchaneewan    | 4dkKeIUkN7E  | 226    | 16             |
| Ruchaneewan    | qCfuQA6N4K0  | 213    | 17             |
| Ruchaneewan    | TmYbGQaRcNM  | 209    | 18             |
| Ruchaneewan    | dOlfPsFSjw0  | 206    | 19             |
| Ruchaneewan    | lw9tbm7es6Y  | 200    | 20             |
| expertvillage  | -IxHBW0YpZw  | 39059  | 1              |
| expertvillage  | BU-fT5XI_8I  | 29975  | 2              |
| expertvillage  | ADOcaBYbMl0  | 26270  | 3              |
| expertvillage  | yAqsULIDJFE  | 25511  | 4              |
| expertvillage  | vcm-t0TJXNg  | 25366  | 5              |
| expertvillage  | 0KYGFawp14c  | 24659  | 6              |
| expertvillage  | j4DpuPvMLF4  | 22593  | 7              |
| expertvillage  | Msu4lZb2oeQ  | 18822  | 8              |
| expertvillage  | ZHZVj44rpjE  | 16304  | 9              |
| expertvillage  | foATQY3wovI  | 13576  | 10             |
| expertvillage  | -UnQ8rcBOQs  | 13450  | 11             |
| expertvillage  | crtNd46CDks  | 11639  | 12             |
| expertvillage  | D1leA0JKHhE  | 11553  | 13             |
| expertvillage  | NJu2oG1Wm98  | 11452  | 14             |
| expertvillage  | CapbXdyv4j4  | 10915  | 15             |
| expertvillage  | epr5erraEp4  | 10817  | 16             |
| expertvillage  | IyQoDgaLM7U  | 10597  | 17             |
| expertvillage  | tbZibBnusLQ  | 10402  | 18             |
| expertvillage  | _GnCHodc7mk  | 9422   | 19             |
| expertvillage  | hvEYlSlRitU  | 7123   | 20             |
+----------------+--------------+--------+----------------+--+
