/* Welcome to the SQL mini project. For this project, you will use
Springboard' online SQL platform, which you can log into through the
following link:

https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

Note that, if you need to, you can also download these tables locally.

In the mini project, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */



/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. */
SELECT name AS facility_name
  FROM  Facilities 
  WHERE membercost !=0


/* Q2: How many facilities do not charge a fee to members? */
SELECT COUNT( name ) AS free_fac_cnt
  FROM Facilities
  WHERE membercost =0

/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */
SELECT  facid, name, membercost, monthlymaintenance
  FROM Facilities 
  WHERE membercost < 0.2*monthlymaintenance
  ORDER BY monthlymaintenance 

/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */
SELECT * 
  FROM Facilities
  WHERE facid =1
UNION 
SELECT * 
  FROM Facilities
  WHERE facid =5

/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */

SELECT name, monthlymaintenance, 
  CASE WHEN monthlymaintenance >100 THEN  'expensive' ELSE  'cheap' END AS facility_label
  FROM  Facilities 
  ORDER BY 2 

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */
SELECT m1.surname, m1.firstname
  FROM Members m1
  JOIN(
    SELECT MAX(joindate) as last_joindate
    FROM Members)m2
  ON m2.last_joindate = m1.joindate

/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

select bf.name as court_name, concat(m.surname,' ',m.firstname) as guest_name
  from Members m
join (select b.facid as fid, b.memid,f.name
      from Bookings b
      Join (select facid, name
            from Facilities 
            where name LIKE 'Tennis%') f
      on f.facid = b.facid) bf
on m.memid = bf.memid
group by 1,2
order by 2

/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */
SELECT f.name as facility_name
  CONCAT(m.firstname, ' ', m.surname) AS member_name,
  CASE WHEN b.memid = 0 THEN f.guestcost*b.slots ELSE f.membercost*b.slots END AS cost
  FROM Facilities f
  JOIN Bookings b
  ON f.facid = b.facid
  JOIN Members m
  ON m.memid = b.memid
  WHERE b.starttime like '2012-09-14%' 
  HAVING cost > 30
  ORDER BY COST DESC

/* Q9: This time, produce the same result as in Q8, but using a subquery. */
SELECT bf.name AS facility_name,
  CONCAT(m.firstname,' ',m.surname) AS member_name,
  bf.cost
  FROM Members m
  JOIN(
    SELECT b.memid,f.name,
      CASE WHEN b.memid = 0 THEN b.slots*f.guestcost ELSE b.slots*f.membercost END AS cost
      FROM Facilities f
    JOIN(
      SELECT facid, memid, slots
	  FROM Bookings
        WHERE starttime like '2012-09-14%'
        )b
    ON f.facid = b.facid
      )bf
  ON bf.memid = m.memid
  WHERE bf.cost > 30
  ORDER BY bf.cost DESC

/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */
SELECT k.name, SUM(k.revenue) AS total_revenue
  FROM(
    SELECT b.facid,b.memid,b.slots,f.name,f.membercost,f.guestcost,
      CASE WHEN b.memid = 0 THEN b.slots*f.guestcost ELSE b.slots*f.membercost END AS revenue
      FROM Facilities f
      JOIN Bookings b
      ON b.facid = f.facid
    )k
  GROUP BY 1
  HAVING total_revenue < 1000
  ORDER BY total_revenue