using SQLite
using DataFrames

#const EVENTDB=SQLite.DB("eventdb.sl3")
#EVENTDB=SQLite.DB("eventdb1.sl3") ## TODO Update to use DBInterface and connection

function eventdb(db=EVENTDB)
    ## Check that tables exist and have expected structure.
    ## If not create them
    create_eventdb(;db)
end

function add_event(name::String, description::String, year::Int, month::Int, day::Int, time::String, topic::String, ref_url::String; db=EVENTDB)
    ## Check if event.name exists
    event_df = events("event_name = '$name'";db)
    if nrow(event_df) > 0
        @warn "$name is already an event"
        event_id = first(event_df.event_id)
    else
        ## Create Event
        event_id = create_event(name, description, year, month, day, time; db)
    end
    ## Check if topic exists
    topic_df = topics("topic_name = '$topic'"; db)
    ### If not call add_topic
    if nrow(topic_df) > 0
        @info "$name is already a topic"
        topic_id = first(topic_df.topic_id)        
    else
        topic_id = add_topic(topic;db)
    end
    ## Check if ref_url exists
    ref_df = references("reference_url = '$ref_url'"; db)
    ### If not call add_reference
    if nrow(ref_df) > 0
        @info "$ref_url is already a reference"
        ref_id = first(ref_df.reference_id)        
    else
        ref_id = create_reference(ref_url,""; db)
    end    
    ## add evet_topic_reference
    connect_event_topic_ref(event_id, topic_id, ref_id; db)
end

function connect_event_topic_ref(event_id, topic_id, ref_id;db = EVENTDB)
    sql = raw"""INSERT INTO event_topic_reference (event_id, topic_id, reference_id) VALUES (?,?,?)"""
    res = DBInterface.execute(db, sql, [event_id, topic_id, ref_id])
    DBInterface.lastrowid(res)
end

function create_reference(url::String, description::String; db = EVENTDB)
    sql = raw"""INSERT INTO reference (reference_url, reference_description) VALUES (?,?)"""
    res = DBInterface.execute(db, sql, [url, description])
    DBInterface.lastrowid(res)
end

function add_topic(name::String, description="", parent_name=""; db=EVENTDB)
    if description == ""
        @info "Description is missing"
        description = get_user_oneliner("description")
        @info "Thank you"
    end
    local ans = "y"
    while (parent_name == "") || (!startswith(ans, r"n"))
        @info "Parent is missing"
        parent_name = get_user_oneliner("parent_name")
        @info "Thank you"
        parent_df = topics("topic_name = '$parent_name'"; db)
        ans = "n"
        if nrow(parent_df) == 0
            @warn """Parent: "$parent_name" not found. Do you want to re-enter it? (y/n)"""
            ans = readline()
        end
    end
    parent_df = topics("topic_name = '$parent_name'"; db)
    if nrow(parent_df) == 0
        @info "Creating parent: $parent_name"
        add_topic(parent_name; db)
    end
    create_topic(name, description, parent_name; db)
end

function create_topic(name::String, description::String, parent_name::String; db=EVENTDB)
    parent_df = topics(""" topic_name = '$parent_name' """; db)
    @assert nrow(parent_df) == 1
    parent_id = first(parent_df.topic_id)
    sql = raw"""INSERT INTO topic (topic_name, topic_description, parent_topic_id) VALUES (?,?, ?)"""
    res = DBInterface.execute(db, sql, [name, description, parent_id])
    DBInterface.lastrowid(res)
end

function get_user_oneliner(input_name::String)
    ans = "n"
    local res=""
    while !startswith(ans, r"y"i)
        println("Enter $input_name:")
        res = readline()
        println("""Accept $input_name: "$res" (Y/n)""")
        ans = readline()
    end
    res
end

function create_event(name::String, description::String, year::Int, month::Int, day::Int, time::String;db = EVENTDB)
    sql = raw"""INSERT INTO event (event_name, event_description, year, month, day, time) VALUES (?,?, ?, ?, ?,?)"""
    res = DBInterface.execute(db, sql, [name, description, year, month, day, time])
    DBInterface.lastrowid(res)
end

function events(where="";db=EVENTDB)
    sql = raw"""select * from event """
    if where != ""
        sql *= " where " * where
    end
    DBInterface.execute(db, sql) |> DataFrame
end
    
function topics(where="";db=EVENTDB)
    sql = raw"select * from topic" * (where == "" ? "" : " where " * where)
    @info sql
    DBInterface.execute(db, sql) |> DataFrame
end
    
function references(where="";db=EVENTDB)
    sql = raw"select * from reference" * (where == "" ? "" : " where " * where)
    @info sql
    DBInterface.execute(db, sql) |> DataFrame
end

function relations(where="";db=EVENTDB)
    sql = raw"select * from event_topic_reference" * (where == "" ? "" : " where " * where)
    @info sql
    DBInterface.execute(db, sql) |> DataFrame
end


function create_event_table(; db=EVENTDB, drop_existing=true)
    if drop_existing
        tables = SQLite.tables(db) |> DataFrame
        if nrow(subset(tables, :name => ByRow(==("event")))) > 0
            DBInterface.execute(db, "drop table event")
        end        
    end
    sql =
        raw"""
        CREATE TABLE event (
        event_id INTEGER PRIMARY KEY,
        event_name TEXT UNIQUE NOT NULL,
        event_description TEXT,
        year INTEGER,
        month INTEGER,
        day INTEGER,
        time TEXT,
        UNIQUE (event_name COLLATE NOCASE)
        );
    """
    DBInterface.execute(db, sql)
end

function create_topic_table(; db=EVENTDB, drop_existing=true)
    if drop_existing
        tables = SQLite.tables(db) |> DataFrame
        if nrow(subset(tables, :name => ByRow(==("topic")))) > 0
            DBInterface.execute(db, "drop table topic")
        end        
    end
    sql =
        raw"""
CREATE TABLE topic (
topic_id INTEGER PRIMARY KEY,
topic_name TEXT UNIQUE NOT NULL,
topic_description TEXT,
parent_topic_id INTEGER, -- parent topic
UNIQUE (topic_name COLLATE NOCASE),
FOREIGN KEY(parent_topic_id) REFERENCES topic(topic_id)
);
    """
    DBInterface.execute(db, sql)
end

function create_reference_table(; db=EVENTDB, drop_existing=true)
    if drop_existing
        tables = SQLite.tables(db) |> DataFrame
        if nrow(subset(tables, :name => ByRow(==("reference")))) > 0
            DBInterface.execute(db, "drop table reference")
        end        
    end
    sql =
        raw"""
CREATE TABLE reference (
reference_id INTEGER PRIMARY KEY,
reference_url TEXT,
reference_description TEXT
);
    """
    DBInterface.execute(db, sql)
end

function create_event_topic_reference_table(; db=EVENTDB, drop_existing=true)
    if drop_existing
        tables = SQLite.tables(db) |> DataFrame
        if nrow(subset(tables, :name => ByRow(==("event_topic_reference")))) > 0
            DBInterface.execute(db, "drop table event_topic_reference")
        end        
    end
    sql =
        raw"""
CREATE TABLE event_topic_reference(
etr_id INTEGER PRIMARY KEY,
event_id INTEGER NOT NULL,
topic_id INTEGER NOT NULL,
reference_id INTEGER,
FOREIGN KEY(event_id) REFERENCES event(event_id),
FOREIGN KEY(topic_id) REFERENCES topic(topic_id),
FOREIGN KEY(reference_id) REFERENCES reference(reference_id),
UNIQUE (event_id, topic_id,reference_id)
);
    """
    DBInterface.execute(db, sql)
end


function create_eventdb(; db=EVENTDB)
    ## Define tables
    create_event_table(;db)
    create_topic_table(;db)
    create_reference_table(;db)
    create_event_topic_reference_table(;db)
    ## Set root topic
    sql = raw"""INSERT INTO topic (topic_name, topic_description) VALUES (?,?)"""
    res = DBInterface.execute(db, sql, ["topic", "root"])
    DBInterface.lastrowid(res)
end

function tables(;db=EVENTDB)
    SQLite.tables(db)|>DataFrame
end

function drop_eventdb(;db=EVENTDB)
    for table in ["event", "topic", "reference", "event_topic_reference"]
        sql = "drop table $table"
        @info sql
        try
            DBInterface.execute(db, sql)
        catch e
            @error "Error dropping table $table: $e"
        end
    end
end

function get_topic_id(topic; db=EVENTDB)
    local topic_id
    if !(typeof(topic) <: Union{T,Vector{T}} where T <: Number)
        topic_df = topics("topic_name in $(v2sql(topic))")
        topic_id = topic_df.topic_id
    else
        topic_id = topic
    end
    topic_id
end

function topic_events(topic;db=EVENTDB)
    topic_id = get_topic_id(topic;db)
    sql = """select * from event_topic_reference etr
    join event USING(event_id)
    join topic USING(topic_id)
    join reference USING(reference_id)
    where topic_id in $(v2sql(topic_id))
    order by year, month, day, time"""
    relation_df = query(sql;db)
    relation_df
end


function subtopics(topic;db=EVENTDB, include_topic=true)
    ## Recursively find all sub topics
    ## topic_df = topics("topic_name = '$topic'")
    topic_id = get_topic_id(topic;db)
    sql = """
    with recursive tc( i )
      as ( select topic_id from topic where parent_topic_id in $(v2sql(topic_id))
            union select topic_id from topic, tc
                   where topic.parent_topic_id = tc.i
             )
    select * from tc;
    """
    subtopic_ids = query(sql;db).i
    if include_topic
        subtopic_ids = [subtopic_ids; topic_id]
    end
    topics("topic_id in $(v2sql(subtopic_ids))")
end

function subtopic_events(topic; db=EVENTDB) ## also get events on sub topics
    Subtopics = subtopics(topic; db)
    sort!(topic_events(Subtopics.topic_name;db), [:year, :month, :day, :time])
end



function v2sql(c::Vector{T}) where T
    if T <: String
        c = map(x-> "'$x'", c)
    end
    "(" * join(c, ", ") * ")"
end
function v2sql(c::T) where T
    if T <: String
        c = "'$c'"
    end
    "(" * string(c) * ")"
end


function query(sql;db=EVENTDB)
    DBInterface.execute(db, sql) |> DataFrame
end
