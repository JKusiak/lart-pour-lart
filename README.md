### How to start:

1. Open command line

2. **sqlplus / as sysdba;**

   2.5 If command is not recognized, move to Oracle_Database\bin folder and repeat

3. Create a pluggable database from default seed and set up an admin user

   **CREATE PLUGGABLE DATABASE gallery**
   **ADMIN USER gallery_admin IDENTIFIED BY [x]**
   **STORAGE (MAXSIZE 2G)**
   **DEFAULT TABLESPACE gallerytab**
   **DATAFILE 'oracle\oradata\orcl\gallery\gallery01.dbf' SIZE 250M AUTOEXTEND ON**
   **PATH_PREFIX = 'oracle\oradata\orcl\gallery\'**
   **FILE_NAME_CONVERT = ('oracle\oradata\orcl\pdbseed\', 'oracle\oradata\orcl\gallery\');**

4. **alter session set container = gallery;**
   **GRANT DBA TO gallery_admin;**

5. Connect in SqlDeveloper using credentials created in previous steps

   Username: gallery_admin 
   Password: [x]
   hostname: localhost
   port: 1521
   service_name: gallery

   5.5 If database is closed:

   **alter session set container = gallery;**
   **alter pluggable database open;**

   

You are done <3