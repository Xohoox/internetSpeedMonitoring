-- JSON Rohdaten importieren
\set import `speedtest-cli --json --secure`
INSERT INTO rawjson(jsondata) VALUES(:'import');



-- Insert and parse JSON Data to country
INSERT INTO countrys (name, cc)
SELECT jsondata->'server'->>'country',
   	    jsondata->'server'->>'cc'
FROM last_speedtest
WHERE NOT EXISTS (
			   	  SELECT 1
			   	  FROM countrys c 
			   	  WHERE c.name = (SELECT ls.jsondata->'server'->>'country' FROM last_speedtest ls)
			   	  AND c.cc     = (SELECT ls.jsondata->'server'->>'cc' FROM last_speedtest ls));



-- Insert and parse JSON Data to server
INSERT INTO servers (id, url, url2, lat, lon, name, country_id, sponsor, host, d)
SELECT (jsondata->'server'->>'id')::int,
	   (jsondata->'server'->>'url')::text,
	   (jsondata->'server'->>'url2')::text,
	   (jsondata->'server'->>'lat')::float,
	   (jsondata->'server'->>'lon')::float,
	   (jsondata->'server'->>'name')::text,
	   (SELECT c.id FROM countrys c WHERE c.name = (jsondata->'server'->>'country')::text),
	   (jsondata->'server'->>'sponsor')::text,
	   (jsondata->'server'->>'host')::text,
	   (jsondata->'server'->>'d')::float
	 
FROM last_speedtest
WHERE NOT EXISTS (
				  	SELECT 1
				  	FROM servers s
				  	WHERE s.id = (SELECT (ls.jsondata->'server'->>'id')::int FROM last_speedtest ls));



-- Insert and parse JSON Data to client
INSERT INTO clients (ip, lat, lon, isp, isprating, rating, ispdlavg, ispulavg, loggedin, country_id)     
SELECT (jsondata->'client'->>'ip')::text,
       (jsondata->'client'->>'lat')::float,
       (jsondata->'client'->>'lon')::float,
       (jsondata->'client'->>'isp')::text,
       (jsondata->'client'->>'isprating')::float,
       (jsondata->'client'->>'rating')::int,
       (jsondata->'client'->>'ispdlavg')::int,
       (jsondata->'client'->>'ispulavg'):: int,
       (jsondata->'client'->>'loggedin'):: int,
	   (SELECT co.id FROM countrys co WHERE co.cc = (jsondata->'client'->>'country')::text)
FROM last_speedtest
WHERE NOT EXISTS (
					SELECT 1
					FROM clients cl
					WHERE cl.ip         = (jsondata->'client'->>'ip')::text
					  AND cl.lat        = (jsondata->'client'->>'lat')::float
				      AND cl.lon        = (jsondata->'client'->>'lon')::float 
					  AND cl.isp 	    = (jsondata->'client'->>'isp')::text
				      AND cl.isprating  = (jsondata->'client'->>'isprating')::float 
					  AND cl.rating     = (jsondata->'client'->>'rating')::int 
					  AND cl.ispdlavg   = (jsondata->'client'->>'ispdlavg')::int 
					  AND cl.ispulavg   = (jsondata->'client'->>'ispulavg')::int 
					  AND cl.loggedin   = (jsondata->'client'->>'loggedin')::int 
				      AND cl.country_id = (SELECT co.id FROM countrys co WHERE co.cc = (jsondata->'client'->>'country')::text));



-- Insert and parse JSON Data to speed_test
INSERT INTO speed_test(timestamp, download_speed, upload_speed, ping, server_id, latency, bytes_sent, bytes_received, client_id)
SELECT (jsondata->>'timestamp')::timestamp,
	   (jsondata->>'download')::float,
	   (jsondata->>'upload')::float,
	   (jsondata->>'ping')::float,
	   (jsondata->'server'->>'id')::int,
	   (jsondata->'server'->>'latency')::float,
	   (jsondata->>'bytes_sent')::int,
	   (jsondata->>'bytes_received')::int,
	   (SELECT cl.id
		  FROM clients cl
     	 WHERE cl.ip         = (jsondata->'client'->>'ip')::text
		   AND cl.lat        = (jsondata->'client'->>'lat')::float
		   AND cl.lon        = (jsondata->'client'->>'lon')::float 
		   AND cl.isp 	    = (jsondata->'client'->>'isp')::text
		   AND cl.isprating  = (jsondata->'client'->>'isprating')::float 
		   AND cl.rating     = (jsondata->'client'->>'rating')::int 
		   AND cl.ispdlavg   = (jsondata->'client'->>'ispdlavg')::int 
		   AND cl.ispulavg   = (jsondata->'client'->>'ispulavg')::int 
		   AND cl.loggedin   = (jsondata->'client'->>'loggedin')::int 
		   AND cl.country_id = (SELECT co.id FROM countrys co WHERE co.cc = (jsondata->'client'->>'country')::text))
FROM last_speedtest;
