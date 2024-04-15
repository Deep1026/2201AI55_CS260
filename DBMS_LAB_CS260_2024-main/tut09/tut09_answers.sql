-- General Instructions
-- 1.	The .sql files are run automatically, so please ensure that there are no syntax errors in the file. If we are unable to run your file, you get an automatic reduction to 0 marks.
-- Comment in MYSQL 
-- 1. List the names of all left-handed batsmen from England. Order the results alphabetically. (<player name>)
SELECT player_name
FROM players
WHERE batting_hand = 'Left' AND country_name = 'England'
ORDER BY player_name;

-- 2. List the names and age (in years, should be integer) as on 2018-12-02 (12th Feb, 2018) of all bowlers with skill “Legbreak googly” who are 28 or more in age. Order the result in decreasing order of their ages. Resolve ties alphabetically. (<player name, player age>)
SELECT player_name, FLOOR(DATE_PART('year', '2018-12-02') - DATE_PART('year', dob)) AS player_age
FROM player
WHERE bowling_skill LIKE '%Legbreak%' 
  AND DATE_PART('year', '2018-12-02') - DATE_PART('year', dob) >= 28
ORDER BY player_age DESC, player_name ASC;

-- 3. List the match ids and toss winning team IDs where the toss winner of a match decided to bat first. Order result in increasing order of match ids. (<match id, toss winner>)
SELECT match_id, toss_winner
FROM matches
WHERE toss_decision = 'bat'
ORDER BY match_id;

-- 4. In the match with match id 335987, list the over ids and runs scored where at most 7 runs were scored. Order the over ids in decreasing order of runs scored. Resolve ties by listing the over ids in increasing order. (<over id, runs scored>)
SELECT over_id, runs_scored
FROM ball_by_ball
WHERE match_id = 335987 AND runs_scored <= 7
ORDER BY runs_scored DESC, over_id;

-- 5. List the names of those batsmen who were bowled at least once in alphabetical order of their names. (<player name>)
SELECT DISTINCT players.player_name
FROM players
INNER JOIN player_out ON players.player_id = player_out.player_id
WHERE player_out.kind_out = 'bowled'
ORDER BY players.player_name;

-- 6. List all the match ids along with the names of teams participating (team 1, team 2), name of the wining team, and win margin where the win margin is at least 60 runs, in increasing order of win margin. Resolve ties by listing the match ids in increasing order. (<match id, team 1, team 2, winning team name, win margin>)
SELECT matches.match_id, teams1.name AS team_1, teams2.name AS team_2, matches.match_winner, matches.win_margin
FROM matches
INNER JOIN teams AS teams1 ON matches.team1_id = teams1.team_id
INNER JOIN teams AS teams2 ON matches.team2_id = teams2.team_id
WHERE matches.win_type = 'runs'
AND matches.win_margin >= 60
ORDER BY matches.win_margin, matches.match_id;

-- 7. List the names of all left handed batsmen below 30 years of age as on 2018-12-02 (12th Feb, 2018) alphabetically. (<player name>)
SELECT player_name
FROM player
WHERE batting_hand = 'Left-hand bat'
  AND DATE_PART('year', '2018-12-02') - DATE_PART('year', dob) < 30
ORDER BY player_name ASC;

-- 8. List the match wise total for the entire series. The output should be match id, total runs. Return the results in increasing order of match ids. (<match id, total runs>)
SELECT match_id, SUM(runs_scored) AS total_runs
FROM ball_by_ball
GROUP BY match_id
ORDER BY match_id;

-- 9. For each match id, list the maximum runs scored in any over and the bowler bowling in that over. If there is more than one over having maximum runs, return all of them and order them in increasing order of over id. Order results in increasing order of match ids. (<match id, maximum runs, player name>)
SELECT b.match_id, b.over_id, MAX(b.runs_scored) AS maximum_runs, p.player_name
FROM ball_by_ball AS b
JOIN players AS p ON b.bowler = p.player_id
WHERE b.match_id IN (SELECT DISTINCT match_id FROM ball_by_ball)
GROUP BY b.match_id, b.over_id
ORDER BY b.match_id, b.over_id;

-- 10. List the names of batsmen and the number of times they have been “run out” in decreasing order of being “run out”. Resolve ties alphabetically. (<player name, number>)
SELECT players.player_name, COUNT(player_out.player_out_id) AS number_of_times
FROM players
JOIN player_out ON players.player_id = player_out.player_id
WHERE player_out.kind_out = 'run out'
GROUP BY players.player_name
ORDER BY number_of_times DESC, players.player_name;

-- 11. List the number of times any batsman has got out for any out type. Return results in decreasing order of the numbers. Resolve ties alphabetically (on the out type name). (<out type, number>)
SELECT kind_out AS out_type, COUNT(player_out_id) AS number
FROM player_out
GROUP BY kind_out
ORDER BY number DESC, out_type;

-- 12. List the team name and the number of times any player from the team has received man of the match award. Order results alphabetically on the name of the team. (<name, number>)
SELECT teams.name, COUNT(matches.man_of_the_match) AS number
FROM teams
JOIN matches ON teams.team_id = matches.man_of_the_match
GROUP BY teams.name
ORDER BY teams.name;

-- 13. Find the venue where the maximum number of wides have been given. In case of ties, return the one that comes before in alphabetical ordering. Output should contain only 1 row. (<venue>)
SELECT venue
FROM ball_by_ball
WHERE extra_type = 'wides'
GROUP BY venue
ORDER BY COUNT(*) DESC, venue
LIMIT 1;

-- 14. Find the venue(s) where the team bowling first has won the match. If there are more than 1 venues, list all of them in order of the number of wins (by the bowling team). Resolve ties alphabetically. (<venue>)
SELECT venue
FROM matches
WHERE win_type = 'runs'
AND toss_decision = 'field'
GROUP BY venue
ORDER BY COUNT(*) ASC, venue;

-- 15. Find the bowler who has the best average overall. Bowling average is calculated using the following formula: bowling average = Number of runs given / Number of wickets taken Calculate the average up to 3 decimal places and return the bowler with the lowest average runs per wicket. In case of tie, return the results in alphabetical order. (<player name>)
SELECT players.player_name
FROM players
JOIN ball_by_ball AS b ON players.player_id = b.bowler
WHERE b.innings_no <= 2
GROUP BY players.player_name
HAVING COUNT(b.runs_scored) > 0
ORDER BY (CAST(SUM(b.runs_scored) AS REAL) / COUNT(b.kind_out)) ASC, players.player_name
LIMIT 1;

-- 16. List the players and the corresponding teams where the player played as “CaptainKeeper” and won the match. Order results alphabetically on the player’s name. (<player name, name>)
SELECT players.player_name, teams.name
FROM players
JOIN player_match ON players.player_id = player_match.player_id
JOIN teams ON player_match.team_id = teams.team_id
WHERE players.role = 'CaptainKeeper'
AND player_match.match_id IN (
    SELECT match_id
    FROM matches
    WHERE match_winner = teams.team_id
)
ORDER BY players.player_name;

-- 17. List the names of all players and their runs scored (who have scored at least 50 runs in any match). Order result in decreasing order of runs scored. Resolve ties alphabetically. (<player name, runs scored>)
SELECT players.player_name, SUM(runs_scored) AS runs_scored
FROM players
JOIN ball_by_ball ON players.player_id = ball_by_ball.striker
GROUP BY players.player_name
HAVING SUM(runs_scored) >= 50
ORDER BY runs_scored DESC, players.player_name;

-- 18. List the player names who scored a century but their teams lost the match. Order results alphabetically. (<player name>)
SELECT players.player_name
FROM players
JOIN ball_by_ball ON players.player_id = ball_by_ball.striker
JOIN matches ON ball_by_ball.match_id = matches.match_id
WHERE runs_scored >= 100
AND win_type = 'runs'
ORDER BY players.player_name;

-- 19. List match ids and venues where KKR has lost the game. Order result in increasing order of match ids. (<match id, venue>)
SELECT matches.match_id, matches.venue
FROM matches
JOIN teams AS t1 ON matches.team1_id = t1.team_id
JOIN teams AS t2 ON matches.team2_id = t2.team_id
WHERE t1.name = 'KKR' OR t2.name = 'KKR'
AND matches.win_type != 'runs'
ORDER BY matches.match_id;

-- 20. List the names of top 10 players who have the best batting average in season 5. Batting average can be calculated according to the following formula: Number of runs scored by player / Number of matches player has batted in
-- The output should contain exactly 10 rows. Report results up to 3 decimal places. Resolve ties alphabetically. (<player name>)

SELECT players.player_name
FROM players
JOIN player_match ON players.player_id = player_match.player_id
JOIN matches ON player_match.match_id = matches.match_id
WHERE player_match.innings_no <= 2
AND matches.season_id = 5
GROUP BY players.player_name
HAVING COUNT(player_match.match_id) > 0
ORDER BY (SUM(ball_by_ball.runs_scored) / COUNT(DISTINCT player_match.match_id)) DESC, players.player_name
LIMIT 10;
