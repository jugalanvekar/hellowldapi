CREATE DATABASE simpleapi;

CREATE TABLE 'users' (
  'name' varchar(64) NOT NULL, 'birthday_epoch' int  NOT NULL);

ALTER TABLE users  ADD PRIMARY KEY (name);

COMMIT;
