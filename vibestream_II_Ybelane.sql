/*
Question #1: 
Vibestream is designed for users to share brief updates about how they are feeling, as such the 
platform enforces a character limit of 25. How many posts are exactly 25 characters long?

Expected column names: char_limit_posts

-- q1 solution:

SELECT COUNT(*) AS char_limit_posts
FROM posts
WHERE LENGTH(content) = 25;


/*

Question #2: 
Users JamesTiger8285 and RobertMermaid7605 are Vibestream’s most active posters.

Find the difference in the number of posts these two users made on each day that at least one 
of them made a post. Return dates where the absolute value of the difference between posts made is 
greater than 2 (i.e dates where JamesTiger8285 made at least 3 more posts than RobertMermaid7605 or
 vice versa).


Expected column names: post_date
*/

-- q2 solution:

SELECT post_date
FROM (
    SELECT 
        post_date,
        ABS(SUM(CASE WHEN user_id = (SELECT user_id FROM users WHERE user_name = 'JamesTiger8285') THEN 1 ELSE 0 END) -
            SUM(CASE WHEN user_id = (SELECT user_id FROM users WHERE user_name = 'RobertMermaid7605') THEN 1 ELSE 0 END)) AS post_difference
    FROM posts
    WHERE user_id IN ((SELECT user_id FROM users WHERE user_name = 'JamesTiger8285'), (SELECT user_id FROM users WHERE user_name = 'RobertMermaid7605'))
    GROUP BY post_date
) AS post_diff
WHERE post_difference > 2;

/*
Question #3: 
Most users have relatively low engagement and few connections. User WilliamEagle6815, for example, 
has only 2 followers. 

Network Analysts would say this user has two 1-step path relationships. Having 2 followers doesn’t 
mean WilliamEagle6815 is isolated, however. Through his followers, he is indirectly connected to 
the larger Vibestream network.  


Consider all users up to 3 steps away from this user:


1-step path (X → WilliamEagle6815)
2-step path (Y → X → WilliamEagle6815)
3-step path (Z → Y → X → WilliamEagle6815)

Write a query to find follower_id of all users within 4 steps of WilliamEagle6815. 
Order by follower_id and return the top 10 records.


Expected column names: follower_id


*/

-- q3 solution:

WITH RECURSIVE UserNetwork AS (
  SELECT followee_id AS follower_id, 1 AS steps
  FROM follows
  WHERE follower_id = (SELECT user_id FROM users WHERE user_name = 'WilliamEagle6815')

  UNION
  
  SELECT f.follower_id, un.steps + 1
  FROM UserNetwork un
  JOIN follows f ON f.followee_id = un.follower_id
  WHERE un.steps < 3
)

SELECT DISTINCT follower_id
FROM UserNetwork
ORDER BY follower_id
LIMIT 10;


/*
Question #4: 
Return top posters for 2023-11-30 and 2023-12-01. A top poster is a user who has the most OR 
second most number of posts in a given day. Include the number of posts in the result and order 
the result by post_date and user_id.

Expected column names: post_date, user_id, posts
*/

-- q4 solution:

WITH RkedPosters AS (
  SELECT
    post_date,
    user_id,
    RANK() OVER (PARTITION BY post_date ORDER BY COUNT(*) DESC) AS ranking,
    COUNT(*) AS posts
  FROM posts
  WHERE post_date BETWEEN '2023-11-30' AND '2023-12-01'
  GROUP BY post_date, user_id
)

SELECT post_date, user_id, posts
FROM RkedPosters
WHERE ranking <= 2
ORDER BY post_date, user_id;

