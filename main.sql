-- TRIVIAL STATS

-- Oldest and youngest player of per season
WITH ordered_age AS (
	SELECT
		player_name,
		player_age,
		season,
		ROW_NUMBER() OVER(PARTITION BY season ORDER BY player_age, player_name) AS rn_asc,
		ROW_NUMBER() OVER(PARTITION BY season ORDER BY player_age DESC, player_name) AS rn_desc
	FROM nba_data
	WHERE season LIKE '2___-__'
)

SELECT 
	season,
	MAX(CASE WHEN rn_asc = 1 THEN player_name END) AS youngest_player,
	MAX(CASE WHEN rn_asc = 1 THEN player_age END) AS youngest_player_age,
	MAX(CASE WHEN rn_desc = 1 THEN player_name END) AS oldest_player,
	MAX(CASE WHEN rn_desc = 1 THEN player_age END) AS oldest_player_age
FROM ordered_age
GROUP BY season;

-- What is the average number of games played by an NBA player per season? (What are the percentage increase/decline between season)
WITH season_gp AS (
	SELECT 
		season,
		ROUND(AVG(gp), 1) AS avg_gp,
		LAG(ROUND(AVG(gp), 1)) OVER(ORDER BY season) AS previous_avg_gp,
		ROUND(AVG(gp), 1) - (LAG(ROUND(AVG(gp), 1)) OVER(ORDER BY season)) AS inc_dec
	FROM nba_data
	WHERE season LIKE '2___-__'
	GROUP BY season
)
	
SELECT
	season,
	avg_gp,
	inc_dec,
	CASE
		-- Formula: (current_gp - prev_gp) / prev_gp * 100 = % increase/decrease
		WHEN inc_dec < 0 
			THEN CONCAT(ROUND(ABS(inc_dec) / previous_avg_gp * 100.0, 2), '% decrease')
		WHEN inc_dec > 0 
			THEN CONCAT(ROUND(ABS(inc_dec) / previous_avg_gp * 100.0, 2), '% increase')
	END AS pct_inc_dec
FROM season_gp;


-- What is the average height of an NBA player per season?
SELECT 
	season,
	ROUND(AVG(player_height)::numeric, 2) AS avg_player_height
FROM nba_data
WHERE season LIKE '2___-__'
GROUP BY season
ORDER BY season;

-- PERFORMANCE METRICS

-- Player with the highest ppg per season
WITH ordered_ppg AS (
	SELECT
		player_name,
		country,
		pts,
		season,
		ROW_NUMBER() OVER(PARTITION BY season ORDER BY pts DESC) AS rn
	FROM nba_data
	WHERE season LIKE '2___-__'
)

SELECT
	season,
	player_name,
	country,
	pts
FROM ordered_ppg
WHERE rn = 1;

-- Player with the highest rpg per season
WITH ordered_rpg AS (
	SELECT
		player_name,
		country,
		reb,
		season,
		ROW_NUMBER() OVER(PARTITION BY season ORDER BY reb DESC) AS rn
	FROM nba_data
	WHERE season LIKE '2___-__'
)

SELECT
	season,
	player_name,
	country,
	reb
FROM ordered_rpg
WHERE rn = 1;

-- Player with the highest apg per season
WITH ordered_apg AS (
	SELECT
		player_name,
		country,
		ast,
		season,
		ROW_NUMBER() OVER(PARTITION BY season ORDER BY ast DESC) AS rn
	FROM nba_data
	WHERE season LIKE '2___-__'
)

SELECT
	season,
	player_name,
	country,
	ast
FROM ordered_apg
WHERE rn = 1;

-- Top scorers in 2022-23 season
SELECT
	player_name,
	team_abbrev,
	pts
FROM nba_data
WHERE season = '2022-23'
ORDER BY pts DESC
LIMIT 10;

-- Top rebounders in 2022-23 season
SELECT
	player_name,
	team_abbrev,
	reb
FROM nba_data
WHERE season = '2022-23'
ORDER BY reb DESC
LIMIT 10;

-- Top assists in 2022-23 season
SELECT
	player_name,
	team_abbrev,
	ast
FROM nba_data
WHERE season = '2022-23'
ORDER BY ast DESC
LIMIT 10;

-- Top 10 most efficient scorers in 2022-23 season (Who has the best true shooting percentage?)
SELECT
	player_name,
	team_abbrev,
	country,
	(ts_pct * 100.0) AS true_shooting_pct
FROM nba_data
WHERE season = '2022-23'
ORDER BY ts_pct DESC
LIMIT 10;
	
-- Top 10 players who average a double-double in 2022-23 season (pts, rebs, ast, no steals or blocks are in dataset)
SELECT
	player_name,
	team_abbrev,
	pts,
	reb,
	ast
FROM nba_data
WHERE 
	season = '2022-23'
	AND ((pts >= 10 AND reb >= 10) OR (pts >= 10 AND ast >= 10) OR (reb >= 10 AND ast >= 10))
ORDER BY pts, reb, ast
LIMIT 10;

-- Calculate the total points, reb, ast for each player per season (Formula: pts|reb|ast / gp = ppg|rpg|apg)
SELECT
	season,
	team_abbrev,
	player_name,
	player_age,
	gp,
	ROUND((pts*gp)::numeric, 0) AS points,
	ROUND((reb*gp)::numeric, 0) AS rebounds,
	ROUND((ast*gp)::numeric, 0) AS assists
FROM nba_data
WHERE season LIKE '2___-__'
ORDER BY season, team_abbrev, player_name


-- How many points, rebounds, assists has each team scored per season?
WITH nba_trad_stats AS (
	SELECT
		season,
		team_abbrev,
		player_name,
		player_age,
		gp,
		ROUND((pts*gp)::numeric, 0) AS points,
		ROUND((reb*gp)::numeric, 0) AS rebounds,
		ROUND((ast*gp)::numeric, 0) AS assists
	FROM nba_data
	WHERE season LIKE '2___-__'
	ORDER BY season, team_abbrev, player_name
)

SELECT DISTINCT
	season,
	team_abbrev,
	SUM(points) OVER(PARTITION BY season, team_abbrev) AS total_pts,
	SUM(rebounds) OVER(PARTITION BY season, team_abbrev) AS total_reb,
	SUM(assists) OVER(PARTITION BY season, team_abbrev) AS total_ast
FROM nba_trad_stats
ORDER BY season;

-- Which player scored the most points on each team per season?
WITH nba_trad_stats AS (
	SELECT
		season,
		team_abbrev,
		player_name,
		player_age,
		gp,
		ROUND((pts*gp)::numeric, 0) AS points,
		ROUND((reb*gp)::numeric, 0) AS rebounds,
		ROUND((ast*gp)::numeric, 0) AS assists
	FROM nba_data
	WHERE season LIKE '2___-__'
	ORDER BY season, team_abbrev, player_name
)

SELECT 
	season,
	team_abbrev,
	player_name,
	player_age,
	points
FROM (
	SELECT
		season,
		team_abbrev,
		player_name,
		player_age,
		points,
		ROW_NUMBER() OVER(PARTITION BY season, team_abbrev ORDER BY points DESC, player_name) AS rn
	FROM nba_trad_stats
) numbered_points
WHERE rn = 1
ORDER BY team_abbrev, season;