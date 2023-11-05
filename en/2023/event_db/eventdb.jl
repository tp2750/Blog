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
    event_df = events("name = '$name'";db)
    if nrow(event_df) > 0
        @warn "$name is already an event"
        event_id = first(event_df.id)
    else
        ## Create Event
        event_id = create_event(name, description, year, month, day, time; db)
    end
    ## Check if topic exists
    topic_df = topics("name = '$topic'"; db)
    ### If not call add_topic
    if nrow(topic_df) > 0
        @info "$name is already a topic"
        topic_id = first(topic_df.id)        
    else
        topic_id = add_topic(topic;db)
    end
    ## Check if ref_url exists
    ref_df = references("url = '$ref_url'"; db)
    ### If not call add_reference
    if nrow(ref_df) > 0
        @info "$ref_url is already a reference"
        ref_id = first(ref_df.id)        
    else
        ref_id = create_reference(ref_url,""; db)
    end    
    ## add evet_topic_reference
    connect_event_topic_ref(event_id, topic_id, ref_id; db)
end

function connect_event_topic_ref(event_id, topic_id, ref_id;db = EVENTDB)
    sql = raw"""INSERT INTO event_topic_reference (event, topic, reference) VALUES (?,?,?)"""
    res = DBInterface.execute(db, sql, [event_id, topic_id, ref_id])
    DBInterface.lastrowid(res)
end

function create_reference(url::String, description::String; db = EVENTDB)
    sql = raw"""INSERT INTO reference (url, description) VALUES (?,?)"""
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
        parent_df = topics("name = '$parent_name'"; db)
        ans = "n"
        if nrow(parent_df) == 0
            @warn """Parent: "$parent_name" not found. Do you want to re-enter it? (y/n)"""
            ans = readline()
        end
    end
    parent_df = topics("name = '$parent_name'"; db)
    if nrow(parent_df) == 0
        @info "Creating parent: $parent_name"
        add_topic(parent_name; db)
    end
    create_topic(name, description, parent_name; db)
end

function create_topic(name::String, description::String, parent_name::String; db=EVENTDB)
    parent_df = topics(""" name = '$parent_name' """; db)
    @assert nrow(parent_df) == 1
    parent_id = first(parent_df.id)
    sql = raw"""INSERT INTO topic (name, description, parent_topic) VALUES (?,?, ?)"""
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
    sql = raw"""INSERT INTO event (name, description, year, month, day, time) VALUES (?,?, ?, ?, ?,?)"""
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
    id INTEGER PRIMARY KEY,
    name TEXT UNIQUE NOT NULL,
    description TEXT,
    year INTEGER,
    month INTEGER,
    day INTEGER,
    time TEXT,
    UNIQUE (name COLLATE NOCASE)
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
id INTEGER PRIMARY KEY,
name TEXT UNIQUE NOT NULL,
description TEXT,
parent_topic INTEGER, -- parent topic
UNIQUE (name COLLATE NOCASE),
FOREIGN KEY(parent_topic) REFERENCES topic(id)
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
id INTEGER PRIMARY KEY,
url TEXT,
description TEXT
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
id INTEGER PRIMARY KEY,
event INTEGER NOT NULL,
topic INTEGER NOT NULL,
reference INTEGER,
FOREIGN KEY(event) REFERENCES event(id),
FOREIGN KEY(topic) REFERENCES topic(id),
FOREIGN KEY(reference) REFERENCES reference(id),
UNIQUE (event, topic,reference)
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
    sql = raw"""INSERT INTO topic (name, description) VALUES (?,?)"""
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
    
function topic_events(topic;db=EVENTDB)
    topic_df = topics("name = '$topic'")
    topic_id = first(topic_df.id)
    sql = """select * from event_topic_reference etr
    join event on event.id = etr.event
    join topic on topic.id = etr.topic
where topic = $topic_id"""
    relation_df = query(sql;db)
    relation_df
end

function query(sql;db=EVENTDB)
    DBInterface.execute(db, sql) |> DataFrame
end

function subtopic_events(topic; db=EVENTDB) ## also get events on sub topics
end
