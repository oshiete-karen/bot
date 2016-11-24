CREATE DATABASE karen DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;

CREATE TABLE user (
  id MEDIUMINT unsigned NOT NULL AUTO_INCREMENT,
  name VARCHAR(30) NOT NULL, -- LINEの名前って何バイトまでだっけ
  access_token VARCHAR(64),
  refresh_token VARCHAR(64),
  PRIMARY KEY (`id`)
);
