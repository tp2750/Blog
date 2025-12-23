function subtopics(topic;db=EVENTDB)
    ## Recursively find all sub topics
    
    sql = """
    with recursive tc( i )
      as ( select topic_id from topic where parent_topic_id = 5
            union select topic_id from topic, tc
                   where topic.parent_topic_id = tc.i
             )
    select * from tc;
    """
    ## from https://dba.stackexchange.com/a/312726
    sql2="""
    WITH RECURSIVE 
    descendants(topic_id, parent_topic_id, most_parent_topic_id) AS (
      SELECT t.topic_id, t.parent_topic_id, t.parent_topic_id
      FROM topic t 
      WHERE t.parent_topic_id = 1      -- given base topic_id value
      UNION ALL
      SELECT t.topic_id, t.parent_topic_id, descendants.most_parent_topic_id
      FROM descendants
      JOIN t ON descendants.topic_id = t.parent_topic_id
    )
    SELECT topic_id, parent_topic_id 
    FROM descendants
    WHERE parent_id <> most_parent_topic_id;
    """

    sql1="""
    WITH RECURSIVE descendants as
        (
      SELECT t.topic_id, t.parent_topic_id, CAST(t.topic_id AS varchar) as Level
      FROM topic t
      WHERE t.parent_topic_id is null
    
      UNION ALL
    
      SELECT i1.topic_id, i1.parent_topic_id, CAST(i1.topic_id AS varchar) || ', ' || d.Level
      FROM topic i1  
      INNER JOIN descendants d ON d.topic_id = i1.parent_topic_id
     )
    SELECT * 
    From descendants
    where parent_topic_id in (5);
    """
end
