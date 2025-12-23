# Node0 - Knowledge system.
TP 2025-12-14.

# Notes
Naming is hard.
Builds on ideas for "benchling replacement".
This can also be "DK portal" basis.
Finding is key.
Tag browsing makes it discoverable.
Automated reports can collect on tages. Eg a diary by collecting all per day.
This is also a social media: chose what you share with whom.
- easy to publish as "debatindlæg" to a national "debat" forum.
Tag and release.
Dynamic data model by tags.

# Basis
Collect all I know and all I do.

All is tagged. Tag hierachy.

Path defines tags:
2025/Spejder/Bestyrelse/Møde3/2025-11-10/dagsorden.odt

is taged with 
- 2025:d1u6
- Spejder:d2u5
- Bestyrelse:d3u4
- Møde3:d4u3
- 2025-11-10:d5u2
- dagsorden.odt:d6u1
as well as all subsets:
- 2025/Spejder
- Spejder/Bestyrelse
- Bestyrelse/Møde3
etc.

The tags are tagged with level (both starting from to and from end)

also tagged as:
- file
- libreoffice (MIME type)
- author:DK/CPR/1109701927 (my tag)

Content of file is indexed with all of these tags.

Content is also indexed with headings and sub-headings in the document.

An agent can pick up all I write in the filesystem and register that.

All tagged with timestamp and author. And language.

Log only things I write, not files I generate.


## Aliases
All words are aliased to their lowercase value.
Search matches aliases by default.

Define aliases.
Define groups of aliases.
Apply set of aliases.

This allows merging of the "data model".

tp@ace7900 is alias of DK/CPR/1109701927 (my tag)

Aliases can be used to translate between languages.

## Tag browsing and serching
- search in content, see by tag
- search in tags, see content

## web pages
- web pages are similarly taged with all parts of the URL as well as headings and subheadings-


# Elements
## Identities
Always identified.
Web portal: log in with oauth2.

## Documents
- Text rendered as html
- embedded tables, images

Easy import .org, .md, .odt, .docx

## Tables
Column names are tags.
Tags can be column names.

Create dynamic table by selecting some tags to define id, and some as variables for "pivot wide".

Input tables as lists:
- tbl name
 - col1
   - val1
   - val2
 - col2
   - val3
   - val4

This will be automatic by adding an implicit item number (even for unordered lists). The pivot on item number.

My orgmode diary automatically goes to "agenda".
Orgmode tags as todo, tag etc.

Only import new content, when file is updated (like 2025.org).


## Events
My time-db: when certain things happened
## Images

## sounds

## Documents
- Collect and annotate documentas like Zotero.

# Filesystem agent
imports and tags all I do.
phone app

# DK portal
- personer (cpr nummer)
- virksomheder (cvr nummer)
- foreninger ()
- kommuner
- regioner
- log in with oath2 (via mitid)

- Sending messages: tag and share with recipient.
- inbox

# Technology
## Genie
Take a look at where Genie is.
Does this have the module functionality of server part + ui part (like shiny modules)?

## api based
All interaction with server is through API.

Web UI uses API as well.

## Oxygen.jl
More barebones?

## Bonito
For some parts?

## Templating like Ruby on Rails
- convention over configuration like django.

## Is searching still elastic search or is there a julia search engine?
Or some rust project?
