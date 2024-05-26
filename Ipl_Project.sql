-- IPL Mini Project
use ipl;
show tables;

-- Checking table data
select * from ipl_user;
select * from IPL_Stadium;
select * from IPL_Team;
select * from IPL_Player;
select * from IPL_Team_players;
select * from IPL_Tournament;
select * from IPL_Match;
select * from IPL_Match_Schedule;
select * from IPL_Bidder_Details;
select * from IPL_Bidding_Details;
select * from IPL_Bidder_Points;
select * from IPL_Team_Standings;

/*
1.	Show the percentage of wins of each bidder in the order of highest to lowest percentage.
*/

select t1.bidder_id, t1.wins, t1.total_bids, round((t1.wins/t1.total_bids *100),2) as '%ge_Wins'
from
(
select ibd.bidder_id, count(ibd.bid_status) as 'wins', sum(ibp.NO_OF_BIDS) as 'total_bids'
from IPL_Bidding_Details ibd, IPL_Bidder_Points ibp
where bid_status ='Won' and ibd.bidder_id=ibp.bidder_id
group by ibd.bidder_id
) as t1
 order by (t1.wins/t1.total_bids *100) desc;
 
 /*
 2.	Which teams have got the highest and the lowest no. of bids?
 */
 
 (select ibd.bid_team, count(ibd.bid_team) as 'No_of_bids', 'Highest bidded team' as Comments
 from IPL_Bidding_Details ibd, IPL_Bidder_Points bp
 where ibd.bidder_id=bp.bidder_id
 group by ibd.BID_TEAM
 order by count(ibd.bid_team) desc limit 1)
 union
 (select ibd.bid_team, count(ibd.bid_team) , 'Lowest bidded team'
 from IPL_Bidding_Details ibd, IPL_Bidder_Points bp
 where ibd.bidder_id=bp.bidder_id
 group by ibd.BID_TEAM
 order by count(ibd.bid_team) limit 1)
 ;
 
 /*
 3.	In a given stadium, what is the percentage of wins by a team which had won the toss?
 */
 
(select s.STADIUM_NAME, im.team_id1 as 'Winner_team_id',it.TEAM_NAME  ,count(im.TOSS_WINNER), count(im.MATCH_WINNER), ( count(im.MATCH_WINNER) /count(im.TOSS_WINNER) * 100) as '% toss(win) is match(win)'
from ipl_match im , IPL_MATCH_SCHEDULE ms, IPL_STADIUM s, IPL_TEAM it
where im.match_id=ms.match_id and s.stadium_id=ms.stadium_id and it.team_id=im.team_id1 and toss_winner=1
group by ms.stadium_id,im.team_id1)
union
(select s.STADIUM_NAME, im.team_id2, it.TEAM_NAME ,count(im.TOSS_WINNER), count(im.MATCH_WINNER), ( count(im.MATCH_WINNER) /count(im.TOSS_WINNER) * 100) as '% toss(win) is match(win)'
from ipl_match im , IPL_MATCH_SCHEDULE ms, IPL_STADIUM s, IPL_TEAM it
where im.match_id=ms.match_id and s.stadium_id=ms.stadium_id and it.team_id=im.team_id2 and toss_winner=2
 group by ms.stadium_id,im.team_id1);
 
 /*
 4.	What is the total no. of bids placed on the team that has won highest no. of matches?
 */
 
 select its.TEAM_ID, it.TEAM_NAME, its.MATCHES_WON, count(ibd.BID_TEAM) as 'Total no. of bids'
 from IPL_Team_Standings its, IPL_TEAM it, IPL_Bidder_Points ibp, IPL_Bidding_Details ibd
 where its.team_id=it.team_id and ibp.TOURNMT_ID=its.TOURNMT_ID and ibd.bidder_id=ibp.bidder_id
 order by its.MATCHES_WON desc, count(ibd.BID_TEAM) desc;
 
 /*
 5.	From the current team standings, if a bidder places a bid on which of the teams, there is a possibility of (s)he winning the highest no. of points – in simple words, identify the team which has the highest jump in its total points (in terms of percentage) from the previous year to current year.
 */
 
 select  q1.team_id, q1.team_name, q1.TOURNMT_ID, ((q1.total_points - q2.total_points)/q2.total_points)*100 as '% change in points'
 from
 (select its.team_id, it.team_name, its.TOURNMT_ID, its.total_points
 from IPL_Team_Standings its, IPL_TEAM it
 where its.team_id=it.team_id and its.TOURNMT_ID =2018
 group by it.team_name
 order by it.team_name) as q1,
 (select its.team_id, it.team_name, its.TOURNMT_ID, its.total_points
 from IPL_Team_Standings its, IPL_TEAM it
 where its.team_id=it.team_id and its.TOURNMT_ID =2017
 group by it.team_name
 order by it.team_name) as q2
 where q1.team_name=q2.team_name
order by 4 desc limit 1;