--Q1--------------------------------------------------------------------------------------

---How long has Codeflix been operating?---
SELECT MIN(subscription_start) AS 'Begining date', 
       MAX(subscription_end) AS 'End date' 
FROM subscriptions;

---How many total Codeflix Users?---
SELECT COUNT(DISTINCT ID) AS 'Codeflix Users' 
FROM subscriptions;

---How many segments are there?---
Select DISTINCT segment, 
			 COUNT (DISTINCT id) AS 'Count' 
FROM  subscriptions
GROUP BY segment;




--Q2--------------------------------------------------------------------------------------

WITH months AS (
     	    SELECT '2016-12-01' AS First_Day, 
                        '2017-12-31' AS Last_Day 
      	    UNION
    	    SELECT '2017-01-01' AS First_Day,
                       '2017-01-31' AS Last_Day
      	    UNION 
            SELECT '2017-02-01' AS First_Day,
                       '2017-02-28' AS Last_Day
    	    UNION
      	    SELECT '2017-03-01' AS First_Day,
                       '2017-03-31' AS Last_Day), 
        
-----------------------------------------------
 status AS (
         SELECT id,            
                first_day AS month,
                CASE WHEN subscription_start < first_day 
                     AND (subscription_end > First_day 
                     OR subscription_end IS NULL) THEN 1 
                     ELSE 0 END AS is_active,

                CASE WHEN subscription_end BETWEEN First_Day 
                     AND Last_day THEN 1 else 0 END 
                     aS is_canceled  
         FROM subscriptions 
         CROSS JOIN months), 

-----------------------------------------------         
 status_aggregate AS (
          	SELECT month,
                   SUM(is_active) AS sum_active,
                   SUM(is_canceled) AS sum_canceled
           	FROM status
           	GROUP BY month)
                        
-----------------------------------------------         
SELECT  month,
       ((1.0*sum_canceled)/sum_active) AS churn_rate 
FROM status_aggregate
GROUP BY month;





--Q3--------------------------------------------------------------------------------------




WITH months AS 
      (SELECT 
 
        '2017-01-01' AS First_Day,
        '2017-01-31' AS Last_Day
      UNION 
      SELECT
      
        '2017-02-01' AS First_Day,
        '2017-02-28' AS Last_Day
      UNION
      SELECT
     
        '2017-03-01' AS First_Day,
        '2017-03-31' AS Last_Day), 
        
-------------------------------------------------------------
 status AS (
   			SELECT id,           
               first_day AS month,
               CASE WHEN segment = 87
                AND subscription_start < first_day 
                AND (subscription_end > First_day 
                OR subscription_end IS NULL) THEN 1 
                ELSE 0 END AS is_active_87,
   
              CASE WHEN segment = 30 
               AND subscription_start < first_day
               AND (subscription_end > First_day 
               OR subscription_end IS NULL)THEN 1 
               ELSE 0 END AS is_active_30,

              CASE WHEN (segment = 87) 
               AND subscription_end BETWEEN First_Day 
               AND Last_day THEN 1 else 0 END 
               AS is_canceled_87,

              CASE WHEN (segment = 30) 
               AND subscription_end BETWEEN First_Day 
               AND Last_day THEN 1 else 0 END 
               AS is_canceled_30    

         FROM subscriptions 
         CROSS JOIN months),
-------------------------------------------------------------         
     status_aggregate AS (
						SELECT month,
                   SUM(is_active_87) AS sum_active_87,
                   SUM(is_active_30) AS sum_active_30,
                   SUM(is_canceled_87) AS sum_canceled_87,
                   SUM(is_canceled_30) AS sum_canceled_30
                 FROM status
                GROUP BY month)
-------------------------------------------------------------                
 SELECT month, 
	    	((1.0*sum_canceled_30)/sum_active_30) AS churn_rate_30,
	    	((1.0*sum_canceled_87)/sum_active_87) AS churn_rate_87   
 FROM status_aggregate;
  
 




--bonus--------------------------------------------------------------------------------------


WITH months AS 
     (SELECT'2016-12-01' AS First_Day, 
       '2017-12-31' AS Last_Day 
       UNION
       SELECT 
          '2017-01-01' AS First_Day,
          '2017-01-31' AS Last_Day
        UNION 
        SELECT
          '2017-02-01' AS First_Day,
          '2017-02-28' AS Last_Day
        UNION
        SELECT
          '2017-03-01' AS First_Day,
          '2017-03-31' AS Last_Day),      
-----------------------------------------------
 status AS (
   	SELECT id,            
           first_day AS month,
           segment,
           CASE WHEN subscription_start < first_day 
                AND (subscription_end > First_day 
                OR subscription_end IS NULL) THEN 1 
                ELSE 0 END AS is_active,
              
           CASE WHEN subscription_end BETWEEN First_Day 
	            AND Last_day THEN 1 else 0 END 
                AS is_canceled  
       FROM subscriptions 
       CROSS JOIN months), 
-----------------------------------------------         
 status_aggregate AS (
   		  SELECT month, 
   			     segment,
                 SUM(is_active) AS sum_active,
                 SUM(is_canceled) AS sum_canceled
          FROM status 
          GROUP BY month, segment)                      
-----------------------------------------------         
SELECT  month, 
	    segment,
        ((1.0*sum_canceled)/sum_active) churn_rate 
FROM status_aggregate
GROUP BY segment, month;

