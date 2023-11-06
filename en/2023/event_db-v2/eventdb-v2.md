# EventDB v2
TP 2023-11-06

# Conclusion

* Use markdown as datastructure.
* Headings are topics and define the topics hierachy
* Events are the lowest level section:
  - H1 topic name
	Description
  - H2 sub topic name
	Description
  - H3 sub sub topic name
	Description
  - Hn Event name. Timestamp
	Description
	List of references.
* This covers everything I had in the SQLite database!

The event_topic_ref table is generated dynamically by a script!

# Background

After first version using SQLite, I think this is a better design.

# Extensions

Later we may want to cover:

* Topics in multiple files
  - describe parent of document in front matter
* Multiple topics on events
  - list of sub topics. This was not possible in SQLite.
* Language
  - currently in top level header
  
# Example

topic-1.md
