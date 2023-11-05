# EventDB Continued
TP 2023-11-05

# Conclusions

``` julia
julia> subtopic_events("programming language")
[ Info: select * from topic where topic_name in ('programming language')
[ Info: select * from topic where topic_id in (6, 7, 10, 8, 9, 5)
[ Info: select * from topic where topic_name in ('programming language', 'R', 'python', 'numpy', 'pandas', 'julia')
12×15 DataFrame
 Row │ etr_id  event_id  topic_id  reference_id  event_name            event_description    year   month  day    time    topic_name  topic_description             parent_to ⋯
     │ Int64   Int64     Int64     Int64         String                String               Int64  Int64  Int64  String  String      String                        Int64     ⋯
─────┼────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
   1 │      6         6         7             2  python 1.0            python 1.0 release    1994      1     26          python      python Programming languages            ⋯
   2 │      1         1         6             1  R 1.0.0               R 1.0.0 realease      2000      2     29          R           R Programming languages
   3 │      7         7         7             2  python 2.0            python 2.0 release    2000     10     16          python      python Programming languages
   4 │      2         2         6             1  R 2.0.0               R 2.0.0 realease      2004     10      4          R           R Programming languages
   5 │      8         8         7             2  python 3.0            python 3.0 release    2008     12      3          python      python Programming languages            ⋯
   6 │     12        12        10             4  Why We Created Julia  Julia vision          2012      2     14          julia       julia Programming languages
   7 │      3         3         6             1  R 3.0.0               R 3.0.0 realease      2013      4      3          R           R Programming languages
   8 │     10        10        10             3  julia 1.0.0           julia 1.0.0 release   2018      8      9          julia       julia Programming languages
   9 │      4         4         6             1  R 4.0.0               R 4.0.0 realease      2020      4     24          R           R Programming languages                 ⋯
  10 │      5         5         6             1  R 4.3.0               R 4.3.0 realease      2023      4     21          R           R Programming languages
  11 │     11        11        10             3  julia 1.9.0           julia 1.9.0 release   2023      5      8          julia       julia Programming languages
  12 │      9         9         7             2  python 3.12           python 3.12 release   2023     10      2          python      python Programming languages
```

* Interface using both names or ids subtopic_events(5) == subtopic_events("programming language")
* Database as default keyword argument, default file-name: "eventdb.sl3"
* Initialize: 03_populate.jl
* query: 04_query.jl



# Purpose

Days two revisions.

# Simpler Schema

I think I actually only need 3 schemas: 
* Event
* Topic

A person, place, orgaization etc is just an other topic, and the graph structure of topic gives a natural ontology.
Location might turn out to be separate, but let's start simple.


# Translation

Make language explicit by rooting the topic tree as this: (topic_name, parent_name, parent_name, ...)

1. topic,
2. language:english, topic
3. language:danish, topic
4. computer, language:english
5. software, computer
6. architecture, language:english
7. builing, architecture
8. København, language:danish, city
9. Rundetårn, language:danish, builing, København

# Stay simple

It looks like the Topic tree is becoming the most complex part of this.

# Ontology Concenpts

Perhaps split in 2 tables: is_a and has_a?


# Interface

* add_event(;name="",description="",date="", topics, reference)
* add_topic(;name, description, parent)
* add_reference()

If topic does not exits: ask to created it.
If reference (url) does not exit: ask to create it

Populate:

* event
* topic
* reference
* event_topic_reference

# SQLite

## Connect

``` julia
`SQLite.DB()` => in-memory SQLite database
`SQLite.DB(file)` => file-based SQLite database
```

## Create

``` julia
SQLite.createtable!(db::SQLite.DB, table_name, schema::Tables.Schema; temp=false, ifnotexists=true)
```
Indexing:

``` julia
SQLite.createindex!(db, table, index, cols; unique=true, ifnotexists=false)
```



## Quick load

``` julia
source |> SQLite.load!(db::SQLite.DB, tablename::String; temp::Bool=false, ifnotexists::Bool=false, replace::Bool=false, on_conflict::Union{String, Nothing} = nothing, analyze::Bool=false)
```

## Query

The result is a Table.jl object, so we can convert to DataFrame

``` julia
DBInterface.execute(db::SQLite.DB, sql::String, [params])
DBInterface.execute(stmt::SQLite.Stmt, [params])
```
The `params` binds any positional (params as Vector or Tuple) or named (params as NamedTuple or Dict) parameters to an SQL statement.

### Prepared Statements

``` julia
SQLite.Stmt(db, sql; register = true) => SQL.Stmt
```
### Escaping

``` julia
raw"..."
```

### Transactions

``` julia
SQLite.transaction(db, mode="DEFERRED")
SQLite.transaction(func, db)
```
If mode is one of "", "DEFERRED", "IMMEDIATE" or "EXCLUSIVE" then a transaction of that (or the default) mutable struct is started. Otherwise a savepoint is created whose name is mode converted to AbstractString.

In the second method, func is executed within a transaction (the transaction being committed upon successful execution)

``` julia
SQLite.commit(db)
SQLite.commit(db, name)
```

``` julia
SQLite.rollback(db)
SQLite.rollback(db, name)
```

### Regex

Regular expressions are supported: https://juliadatabases.org/SQLite.jl/latest/#regex

## Inspect

SQLite.tables(db, sink=columntable)
SQLite.columns(db, table, sink=columntable)
SQLite.indices(db, sink=columntable)


# ORM

A simple ORM would create and populate tables based on struct definitions.
See eventdb.jl (or eventdb_struct.jl).

SQLite.load! does this for a DataFrame

* https://github.com/JuliaData/Strapping.jl stands for STruct Relational MAPPING, and provides ORM-like functionality 
* https://github.com/GenieFramework/SearchLight.jl
* https://github.com/iskyd/Wasabi.jl a simple yet powerful ORM
* https://github.com/JuliaPostgresORM/PostgresORM.jl
* https://github.com/AlgebraicJulia/AlgebraicRelations.jl an intuitive and elegant method for generating and querying a scientific database
* https://github.com/asjir/FunnyORM.jl allows you to build better queries than, say SQLAlchemy, but it doesn't provide an Object-Relational Mapping.

