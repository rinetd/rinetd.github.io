---
title: 通用SQL命令行工具 usql
date: 2016-10-04T04:15:26+08:00
update: 2016-10-04 04:15:26
categories: [golang]
tags: [golang]
---
通用SQL命令行工具 usql
More coming soon!
Build/Install from Source

You can build or install usql from source in the usual Go fashion:

# install usql (includes support for PosgreSQL, MySQL, SQLite3, and MS SQL)
$ go get -u github.com/knq/usql


# install all drivers
$ go get -u -tags all github.com/knq/usql

# install with "most" drivers (same as "all" but excludes oracle/odbc)
$ go get -u -tags most github.com/knq/usql

# install with base drivers and oracle / odbc support
$ go get -u -tags 'oracle odbc' github.com/knq/usql

# install all drivers but exclude avatica, and couchbase drivers
$ go get -u -tags 'all no_avatica no_couchbase'



# connect to a postgres database
$ usql pg://user:pass@localhost/dbname
$ usql pgsql://user:pass@localhost/dbname
$ usql postgres://user:pass@localhost:port/dbname

# connect to a mysql database
$ usql my://user:pass@localhost/dbname
$ usql mysql://user:pass@localhost:port/dbname
$ usql /var/run/mysqld/mysqld.sock

# connect to a mssql (Microsoft SQL) database
$ usql ms://user:pass@localhost/dbname
$ usql mssql://user:pass@localhost:port/dbname

# connect using Windows domain authentication to a mssql (Microsoft SQL)
# database
$ runas /user:ACME\wiley /netonly "usql mssql://host/dbname/"

# connect to a oracle database
$ usql or://user:pass@localhost/dbname
$ usql oracle://user:pass@localhost:port/dbname

# connect to a pre-existing sqlite database
$ usql dbname.sqlite3

# note: when not using a "<scheme>://" or "<scheme>:" prefix, the file must already
# exist; if it doesn't, please prefix with file:, sq:, sqlite3: or any other
# scheme alias recognized by the dburl package for sqlite databases, and sqlite
# will create a new database, like the following:
$ usql sq://path/to/dbname.sqlite3
$ usql sqlite3://path/to/dbname.sqlite3
$ usql file:/path/to/dbname.sqlite3

# connect to a adodb ole resource (windows only)
$ usql adodb://Microsoft.Jet.OLEDB.4.0/myfile.mdb
$ usql "adodb://Microsoft.ACE.OLEDB.12.0/?Extended+Properties=\"Text;HDR=NO;FMT=Delimited\""

Backslash (\) Commands

The following are the currently supported backslash (\) meta commands available to interactive usql sessions or to included (ie, \i) scripts:

General
  \q                    quit usql
  \copyright            show usql usage and distribution terms
  \drivers              display information about available database drivers
  \g [FILE] or ;        execute query (and send results to file or |pipe)
  \gexec                execute query and execute each value of the result
  \gset [PREFIX]        execute query and store results in usql variables

Help
  \? [commands]         show help on backslash commands
  \? options            show help on usql command-line options
  \? variables          show help on special variables

Query Buffer
  \e [FILE] [LINE]      edit the query buffer (or file) with external editor
  \p                    show the contents of the query buffer
  \r                    reset (clear) the query buffer
  \w FILE               write query buffer to file

Input/Output
  \echo [STRING]        write string to standard output
  \i FILE               execute commands from file
  \ir FILE              as \i, but relative to location of current script

Transaction
  \begin                begin a transaction
  \commit               commit current transaction
  \rollback             rollback (abort) current transaction

Connection
  \c URL                connect to database with url
  \c DRIVER PARAMS...   connect to database with SQL driver and parameters
  \Z                    close database connection
  \password [USERNAME]  change the password for a user
  \conninfo             display information about the current database connection

Operating System
  \cd [DIR]             change the current working directory
  \setenv NAME [VALUE]  set or unset environment variable
  \! [COMMAND]          execute command in shell or start interactive shell

Variables
  \prompt [TEXT] NAME   prompt user to set internal variable
  \set [NAME [VALUE]]   set internal variable, or list all if no parameters
  \unset NAME           unset (delete) internal variable
