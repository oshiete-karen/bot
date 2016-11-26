CREATE DATABASE oshiete_karen DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;

CREATE TABLE user (
  id MEDIUMINT unsigned NOT NULL AUTO_INCREMENT,
  mid VARCHAR(36) NOT NULL,
  name VARCHAR(36) NOT NULL, -- LINEの名前って何バイトまでだっけ
  google_credentials_json TEXT,
  PRIMARY KEY (`id`)
);

ALTER TABLE user
  MODIFY COLUMN name VARCHAR(36) DEFAULT NULL,
  MODIFY COLUMN mid VARCHAR(36) NOT NULL UNIQUE;

CREATE TABLE credential (
  user_id MEDIUMINT unsigned PRIMARY KEY,
  client_id TEXT NOT NULL,
  access_token TEXT NOT NULL,
  refresh_token TEXT NOT NULL,
  expiration_time_millis BIGINT UNSIGNED,
  scope TEXT NOT NULL,
  FOREIGN KEY (`user_id`) REFERENCES user (`id`),
  UNIQUE (client_id(255), access_token(255), refresh_token(255))
);

ALTER TABLE user
  DROP google_credentials_json;

CREATE TABLE events (
  id VARCHAR(36) PRIMARY KEY,
  user_id MEDIUMINT unsigned NOT NULL,
  summary TEXT NOT NULL,
  start DATETIME,
  end DATETIME,
  FOREIGN KEY (`user_id`) REFERENCES user (`id`)
);
