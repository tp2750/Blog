# EventDB
TP 2023-11-04

# Purpose

Database for storing and retieving events.

## Use cases

* What were the great mathematicians at the time of Christian IV?
* How do releases of R, python, numpy, pandas, julia lign up?
* Which Redhat and Fedora version was current when the first Ubuntu came out.

# Schema

I currently think it as a relational database backend. 
Eg SQLite.

## Event

The central table collecting events.
Events are recorded as precisely as known split in year, month, day, time as we may only knwon parts of it. 
Dates are relative to the Gregorian calendar (https://en.wikipedia.org/wiki/ISO_8601, https://en.wikipedia.org/wiki/Gregorian_calendar)
Record references as URLs.
TODO: save a copy of the reference at entry time.
An event can have multiple actors and multiple topics.

CREATE TABLE event (
id INT PRIMARY KEY,
name TEXT UNIQUE NOT NULL,
description TEXT,
year INT,
month INT,
day INT,
time TEXT
-- location INT location,
-- FOREIGN KEY(location) REFERENCES location(id)
);

- subjects: list(subject)
- topics: list(topic)
- references


## Subject
These are the subjects or actors affected by the events.
Ecamples: me, Ubuntu linux distribution, Rundetårn

CREATE TABLE subject (
id INT PRIMARY KEY,
name TEXT UNIQUE NOT NULL,
common_name TEXT,
description TEXT,
birth INT,
death INT,
-- type TEXT, -- : person, organization, thing, 
FOREIGN KEY(birth) REFERENCES event(id),
FOREIGN KEY(death) REFERENCES event(id)
);

- references

## Topic
Ontology of topics. 
Store only the most specific ones. Generic onces can be queried.
Examples: 

mathematics, science
physics, science
science,
music, art
painting, art
regent, nation
nation, politics
linux distribution, software
software, computer

CREATE TABLE topic (
id INTEGER PRIMARY KEY,
name TEXT UNIQUE NOT NULL,
description TEXT,
parent_topic INT, -- parent topic
FOREIGN KEY(parent_topic) REFERENCES topic(id)
);

## Reference

Store references as URL.
TODO: also store a copy

CREATE TABLE reference (
id INT PRIMARY KEY,
url TEXT,
description TEXT
);

## Location

- name
- common name
- description
- GPS
- references


## Period
The period between 2 events

- name
- star tevent
- end event
- description
- references

## Connections

### event_subject

Connect subjects to events noting references

CREATE TABLE event_subject(
id INT PRIMARY KEY,
event INT NOT NULL,
subject INT NOT NULL,
reference INT,
FOREIGN KEY(event) REFERENCES event(id),
FOREIGN KEY(subject) REFERENCES subject(id),
FOREIGN KEY(reference) REFERENCES reference(id)
);

### event_topic
Connect subjects to topics noting references

CREATE TABLE event_topic(
id INT PRIMARY KEY,
event INT NOT NULL,
topic INT NOT NULL,
reference INT,
FOREIGN KEY(event) REFERENCES event(id),
FOREIGN KEY(topic) REFERENCES topic(id),
FOREIGN KEY(reference) REFERENCES reference(id)
);


### event_location



# Functions

## add_event

Ask for 
- name
- description
- time
- subjects
- topics

If these are not defined:
- define subject
- define topic

Link Event, Subjects, Topics

## add_subject

## add_topic

# Queries

.headers on;
select * from topics;

# SQLite lessons

## Show column names:

.headers on;

## List tables

.tables

## Primary key

SQLite has implicit rowid primary key.
By defining 

id INTEGER PRIMARY KEY

this gets aliased to id.

See https://www.sqlite.org/rowidtable.html

To see the rowid do: select rowid, * from topic;
