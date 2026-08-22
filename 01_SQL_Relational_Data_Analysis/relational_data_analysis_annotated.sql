-- ============================================================
-- Query 1: Longest Flight by Origin City
-- Purpose: Identify the destination(s) associated with the maximum flight time from each origin city.
-- Approach: Uses a CTE to calculate each origin city's maximum flight time, then joins the result back to the flight table to return the matching destination(s).
-- Original file: hw2-q1.sql
-- ============================================================
WITH MaxFlightTimes AS (
    -- Step 1: Find the maximum air_time for every origin_city
    SELECT 
        origin_city, 
        MAX(air_time) AS longest_time
    FROM flights
    GROUP BY origin_city
)
-- Step 2: Join back to find which destination(s) match that maximum time
SELECT DISTINCT
    f.origin_city, 
    f.dest_city
FROM flights f
JOIN MaxFlightTimes m 
    ON f.origin_city = m.origin_city 
    AND f.air_time = m.longest_time
ORDER BY 
    f.origin_city ASC, 
    f.dest_city ASC;


-- ============================================================
-- Query 2: Cities with Short Maximum Flight Times
-- Purpose: Identify origin cities whose longest available flight is under 180 minutes, including cities with NULL flight-time values where applicable.
-- Approach: Groups flights by origin city and applies HAVING with MAX() and NULL-aware conditions.
-- Original file: hw2-q2.sql
-- ============================================================
SELECT DISTINCT origin_city AS city
FROM flights
GROUP BY origin_city
HAVING MAX(air_time) < 180
   OR MAX(air_time) IS NULL -- Per instructions: NULLs are not 3+ hours
ORDER BY city ASC;


-- ============================================================
-- Query 3: Percentage of Short Flights by Origin City
-- Purpose: Calculate the percentage of flights from each origin city with a flight time under 180 minutes.
-- Approach: Uses conditional aggregation with CASE WHEN to compare qualifying flights with the total number of flights per origin city.
-- Original file: hw2-q3.sql
-- ============================================================
SELECT 
    origin_city,
    (SUM(CASE WHEN air_time < 180 THEN 1 ELSE 0 END) * 100.0) / COUNT(*) AS percentage
FROM flights
GROUP BY origin_city
ORDER BY percentage ASC;


-- ============================================================
-- Query 4: Indirectly Reachable Cities from San Diego
-- Purpose: Find cities reachable from San Diego through one intermediate city but not available as a direct flight from San Diego.
-- Approach: Uses a self-join to construct two-leg routes and excludes destinations already served by a direct San Diego flight.
-- Original file: hw2-q4.sql
-- ============================================================
SELECT DISTINCT f2.dest_city AS city
FROM flights AS f1
JOIN flights AS f2 ON f1.dest_city = f2.origin_city
WHERE f1.origin_city = 'San Diego CA'
  AND f2.dest_city != 'San Diego CA'
  AND f2.dest_city NOT IN (
      SELECT dest_city 
      FROM flights 
      WHERE origin_city = 'San Diego CA'
  )
ORDER BY city ASC;


-- ============================================================
-- Query 5: Carriers Serving San Diego to San Francisco
-- Purpose: Identify carriers operating flights from San Diego to San Francisco.
-- Approach: Uses a subquery to filter carrier records based on qualifying flight records.
-- Original file: hw2-q5.sql
-- ============================================================
SELECT DISTINCT carrier
FROM (
    SELECT carrier
    FROM flights
    WHERE origin_city = 'San Diego CA' 
      AND dest_city = 'San Francisco CA'
) AS subquery
ORDER BY carrier ASC;


-- ============================================================
-- Query 6: Direct Carrier Lookup for San Diego to San Francisco
-- Purpose: Return carriers serving the San Diego-to-San Francisco route using a direct relational query.
-- Approach: Filters and joins the relevant flight/carrier information directly to produce the carrier result.
-- Original file: hw2-q6.sql
-- ============================================================
SELECT DISTINCT carrier
FROM flights
WHERE origin_city = 'San Diego CA' 
  AND dest_city = 'San Francisco CA'
ORDER BY carrier ASC;


-- ============================================================
-- Query 7: Tracks Missing from Invoice Records
-- Purpose: Identify tracks that do not appear in invoice-line transaction records.
-- Approach: Compares track records with invoice-line data to isolate tracks with no corresponding transaction entry.
-- Original file: hw2-q7.sql
-- ============================================================
SELECT DISTINCT name
FROM track
WHERE track_id NOT IN (
    SELECT track_id 
    FROM invoice_line
)
ORDER BY name ASC;


-- ============================================================
-- Query 8: Tracks Outside the '90’s Music' Playlist
-- Purpose: Identify tracks that are not included in the '90’s Music' playlist.
-- Approach: Uses relational filtering across track and playlist data to exclude tracks associated with the specified playlist.
-- Original file: hw2-q8.sql
-- ============================================================
SELECT DISTINCT name
FROM track
WHERE track_id NOT IN (
    SELECT pt.track_id
    FROM playlist_track pt
    JOIN playlist p ON pt.playlist_id = p.playlist_id
    WHERE p.name = '90’s Music'
)
ORDER BY name ASC;


-- ============================================================
-- Query 9: Artists Without Blues Tracks
-- Purpose: Identify artists whose catalogs do not contain tracks in the Blues genre.
-- Approach: Uses joins across artist, album, track, and genre relationships together with EXCEPT to remove artists associated with Blues tracks.
-- Original file: hw2-q9.sql
-- ============================================================
SELECT name
FROM artist
EXCEPT
SELECT art.name
FROM artist art
JOIN album alb ON art.artist_id = alb.artist_id
JOIN track t ON alb.album_id = t.album_id
JOIN genre g ON t.genre_id = g.genre_id
WHERE g.name = 'Blues'
ORDER BY name ASC;


-- ============================================================
-- Query 10: Playlists Without Rock or Blues Tracks
-- Purpose: Identify playlists that contain no tracks categorized as Rock or Blues.
-- Approach: Traverses playlist-track and genre relationships and excludes playlists containing either target genre.
-- Original file: hw2-q10.sql
-- ============================================================
SELECT name
FROM playlist
EXCEPT
SELECT p.name
FROM playlist p
JOIN playlist_track pt ON p.playlist_id = pt.playlist_id
JOIN track t ON pt.track_id = t.track_id
JOIN genre g ON t.genre_id = g.genre_id
WHERE g.name LIKE '%Rock%' OR g.name = 'Blues'
ORDER BY name ASC;


-- ============================================================
-- Query 11: Artists Associated with Three or More Genres
-- Purpose: Identify artists whose tracks span at least three distinct genres.
-- Approach: Joins artist, album, track, and genre data, groups by artist, and applies a distinct-genre count threshold.
-- Original file: hw2-q11.sql
-- ============================================================
SELECT art.name
FROM artist art
JOIN album alb ON art.artist_id = alb.artist_id
JOIN track t ON alb.album_id = t.album_id
JOIN genre g ON t.genre_id = g.genre_id
GROUP BY art.name
HAVING COUNT(DISTINCT g.genre_id) >= 3
ORDER BY art.name ASC;
