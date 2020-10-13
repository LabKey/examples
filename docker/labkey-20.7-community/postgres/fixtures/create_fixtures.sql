-- Labkey Database
CREATE USER labkey WITH SUPERUSER PASSWORD 'CHANGE_ME_PLEASE';
CREATE DATABASE labkey OWNER labkey;
revoke all on DATABASE labkey from public;

