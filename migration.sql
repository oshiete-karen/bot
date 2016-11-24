CREATE DATABASE oshiete_karen DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;

CREATE TABLE user (
  id MEDIUMINT unsigned NOT NULL AUTO_INCREMENT,
  mid VARCHAR(36) NOT NULL,
  name VARCHAR(36) NOT NULL, -- LINEの名前って何バイトまでだっけ
  google_credentials_json TEXT,
  PRIMARY KEY (`id`)
);
