-- Entity tables
DROP TABLE event;

CREATE TABLE event (
id INTEGER PRIMARY KEY,
name TEXT UNIQUE NOT NULL,
description TEXT,
year INTEGER,
month INTEGER,
day INTEGER,
time TEXT,
UNIQUE (name COLLATE NOCASE)
-- location INTEGER location,
-- FOREIGN KEY(location) REFERENCES location(id)
);


CREATE TABLE topic (
id INTEGER PRIMARY KEY,
name TEXT UNIQUE NOT NULL,
description TEXT,
parent_topic INTEGER, -- parent topic
UNIQUE (name COLLATE NOCASE),
FOREIGN KEY(parent_topic) REFERENCES topic(id)
);

CREATE TABLE reference (
id INTEGER PRIMARY KEY,
url TEXT,
description TEXT
);

-- CREATE TABLE subject (
-- id INTEGER PRIMARY KEY,
-- name TEXT UNIQUE NOT NULL,
-- common_name TEXT,
-- description TEXT,
-- birth INTEGER,
-- death INTEGER,
-- -- type TEXT, -- : person, organization, thing, 
-- FOREIGN KEY(birth) REFERENCES event(id),
-- FOREIGN KEY(death) REFERENCES event(id)
-- );

-- relation tables
CREATE TABLE event_topic_reference(
id INTEGER PRIMARY KEY,
event INTEGER NOT NULL,
topic INTEGER NOT NULL,
reference INTEGER,
FOREIGN KEY(event) REFERENCES event(id),
FOREIGN KEY(topic) REFERENCES topic(id),
FOREIGN KEY(reference) REFERENCES reference(id)
);

-- CREATE TABLE event_subject(
-- id INTEGER PRIMARY KEY,
-- event INTEGER NOT NULL,
-- subject INTEGER NOT NULL,
-- reference INTEGER,
-- FOREIGN KEY(event) REFERENCES event(id),
-- FOREIGN KEY(subject) REFERENCES subject(id),
-- FOREIGN KEY(reference) REFERENCES reference(id)
-- );

