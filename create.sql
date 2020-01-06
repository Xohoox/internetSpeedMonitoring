CREATE TABLE countrys (
	id SERIAL PRIMARY KEY,
	name TEXT UNIQUE,
	cc TEXT UNIQUE
);


CREATE TABLE servers (
	id INT PRIMARY KEY,		-- ID aus json
	url TEXT,
	url2 TEXT,
	lat FLOAT,
	lon FLOAT,
	name TEXT,
	country_id INT,
	sponsor TEXT,
	host TEXT,
	d FLOAT,

	FOREIGN KEY(country_id) REFERENCES countrys(id)
); 


CREATE TABLE clients (
	id SERIAL PRIMARY KEY,
	ip TEXT,
	lat FLOAT,
	lon FLOAT,
	isp TEXT,
	isprating FLOAT,
	rating INT,
	ispdlavg INT,
	ispulavg INT,
	loggedin INT,
	country_id INT,
	
	FOREIGN KEY(country_id) REFERENCES countrys(id)
);


CREATE TABLE speed_test (
	id SERIAL PRIMARY KEY,
	timestamp TIMESTAMP,
	download_speed FLOAT,
	upload_speed FLOAT,
	ping FLOAT,
	server_id INT,
	latency FLOAT,
	bytes_sent INT,
	bytes_received INT,
	client_id INT,

	FOREIGN KEY(server_id) REFERENCES servers(id),
	FOREIGN KEY(client_id) REFERENCES clients(id)
);
	


-- Tabelle mit Rohdaten
CREATE TABLE rawjson (
	id SERIAL PRIMARY KEY,
	jsondata json
);

CREATE VIEW last_speedtest AS (
SELECT *
FROM rawjson
WHERE (jsondata->>'timestamp')::timestamp = (SELECT MAX(rd.jsondata->>'timestamp')::timestamp FROM rawjson rd));
