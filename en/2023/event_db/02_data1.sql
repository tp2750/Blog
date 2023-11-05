-- Topics
INSERT INTO topic (name, description, parent_topic) VALUES ("topic","",NULL);
INSERT INTO topic (name, description, parent_topic) VALUES ("language:english","",1);
INSERT INTO topic (name, description, parent_topic) VALUES ("computer","",2);
INSERT INTO topic (name, description, parent_topic) VALUES ("software","",3);
INSERT INTO topic (name, description, parent_topic) VALUES ("programming language","",4);
INSERT INTO topic (name, description, parent_topic) VALUES ("R","R language",5);
INSERT INTO topic (name, description, parent_topic) VALUES ("Python","Python language",5);
INSERT INTO topic (name, description, parent_topic) VALUES ("Numpy","Python package",6);
INSERT INTO topic (name, description, parent_topic) VALUES ("Pandas","Python package",6);
INSERT INTO topic (name, description, parent_topic) VALUES ("julia","julia language",5);

-- .headers on
-- select * from topic;

-- Events
INSERT INTO event (name, description, year, month, day) VALUES ("R 1.0.0","R 1.0.0 realease", 2000, 2, 29);
INSERT INTO event (name, description, year, month, day) VALUES ("R 2.0.0","R 2.0.0 realease", 2004, 10, 4);
INSERT INTO event (name, description, year, month, day) VALUES ("R 3.0.0","R 3.0.0 realease", 2013, 4, 3);
INSERT INTO event (name, description, year, month, day) VALUES ("R 4.0.0","R 4.0.0 realease", 2020, 4, 24);
INSERT INTO event (name, description, year, month, day) VALUES ("R 4.3.0","R 4.3.0 realease", 2023, 4, 21);
INSERT INTO event (name, description, year, month, day) VALUES ("python 1.0","python 1.0 release", 1994, 1, 26);
INSERT INTO event (name, description, year, month, day) VALUES ("python 2.0","python 2.0 release", 2000, 10, 16);
INSERT INTO event (name, description, year, month, day) VALUES ("python 3.0","python 3.0 release", 2008, 12, 3);
INSERT INTO event (name, description, year, month, day) VALUES ("python 3.12","python 3.12 release", 2023, 10, 2);
INSERT INTO event (name, description, year, month, day) VALUES ("Why We Created Julia","Julia vision", 2012, 2, 14);
INSERT INTO event (name, description, year, month, day) VALUES ("julia 1.0.0","julia 1.0.0 release", 2018, 8, 9);
INSERT INTO event (name, description, year, month, day) VALUES ("julia 1.9.0","julia 1.9.0 release", 2023, 5, 8);

-- 
