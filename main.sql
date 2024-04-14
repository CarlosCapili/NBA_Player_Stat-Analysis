-- TRIVIAL STATS

-- Oldest and youngest player of each season from 2000 and up
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


-- PERFORMANCE METRICS

-- Player with the highest ppg per season from 2000 and up
-- WITH ordered_ppg AS (
-- 	SELECT
-- 		player_name,
-- 		country,
-- 		pts,
-- 		season,
-- 		ROW_NUMBER() OVER(PARTITION BY season ORDER BY pts DESC) AS rn
-- 	FROM nba_data
-- 	WHERE season LIKE '2___-__'
-- )

-- SELECT
-- 	player_name,
-- 	country,
-- 	pts,
-- 	season
-- FROM ordered_ppg
-- WHERE rn = 1;

-- Player with the highest rpg per season from 2000 and up
-- WITH ordered_rpg AS (
-- 	SELECT
-- 		player_name,
-- 		country,
-- 		reb,
-- 		season,
-- 		ROW_NUMBER() OVER(PARTITION BY season ORDER BY reb DESC) AS rn
-- 	FROM nba_data
-- 	WHERE season LIKE '2___-__'
-- )

-- SELECT
-- 	player_name,
-- 	country,
-- 	reb,
-- 	season
-- FROM ordered_rpg
-- WHERE rn = 1;

-- Player with the highest apg per season from 2000 and up
-- WITH ordered_apg AS (
-- 	SELECT
-- 		player_name,
-- 		country,
-- 		ast,
-- 		season,
-- 		ROW_NUMBER() OVER(PARTITION BY season ORDER BY ast DESC) AS rn
-- 	FROM nba_data
-- 	WHERE season LIKE '2___-__'
-- )

-- SELECT
-- 	player_name,
-- 	country,
-- 	ast,
-- 	season
-- FROM ordered_apg
-- WHERE rn = 1;

