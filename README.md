# backup-postgresql
A DOS script to run a backup of a PostgreSQL database.

This batch file can be a reference for writing your own backup script. You will have to adapt it 
depending on your needs, for example choosing by using compressed file, more efficient, or plain 
text file, for a wider options of database to use when restoring the data.

The code uses the pg_dump command which is part of the pgAminIII installation, you will have to tell
pgAdmin to remember your password for running this script as it is, otherwise remove the -w option (see code 
for details). 
