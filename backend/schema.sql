-- ============================================================
-- Travel Web - simplified MariaDB schema
-- Core CRUD tables: User, Category, City, Attraction, Itinerary, ItineraryItem.
-- Removed: user_roles, towns, tags, attraction_tags,
-- attraction_descriptions, user_favorites, user_visited.
-- Naming: tables use UpperCamelCase singular nouns; columns use snake_case.
-- Primary keys follow the [table_name]_id pattern.
-- ============================================================

CREATE DATABASE IF NOT EXISTS TravelDB
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE TravelDB;

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS user_visited;
DROP TABLE IF EXISTS user_favorites;
DROP TABLE IF EXISTS attraction_tags;
DROP TABLE IF EXISTS attraction_descriptions;
DROP TABLE IF EXISTS ItineraryItems;
DROP TABLE IF EXISTS Itineraries;
DROP TABLE IF EXISTS Attractions;
DROP TABLE IF EXISTS Categories;
DROP TABLE IF EXISTS Cities;
DROP TABLE IF EXISTS Users;
DROP TABLE IF EXISTS ItineraryItem;
DROP TABLE IF EXISTS Itinerary;
DROP TABLE IF EXISTS Attraction;
DROP TABLE IF EXISTS Category;
DROP TABLE IF EXISTS City;
DROP TABLE IF EXISTS `User`;
DROP TABLE IF EXISTS tags;
DROP TABLE IF EXISTS towns;
DROP TABLE IF EXISTS user_roles;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE `User` (
    user_id       INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    email         VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    name          VARCHAR(100) NOT NULL,
    role          VARCHAR(30) NOT NULL DEFAULT 'user',
    create_time   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    login_time    DATETIME NULL,
    INDEX idx_user_role (role)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE Category (
    category_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(100) NOT NULL UNIQUE,
    INDEX idx_category_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE City (
    city_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name    VARCHAR(50) NOT NULL UNIQUE,
    INDEX idx_city_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE Attraction (
    attraction_id      VARCHAR(80) PRIMARY KEY,
    name               VARCHAR(255) NOT NULL,
    category_id        INT UNSIGNED NULL,
    city_id            INT UNSIGNED NULL,
    address            VARCHAR(255) NULL,
    lat                DECIMAL(10, 7) NULL,
    lon                DECIMAL(11, 7) NULL,
    image_url          TEXT NULL,
    description        TEXT NULL,
    opening_hours      TEXT NULL,
    ticket_info        TEXT NULL,
    website_url        TEXT NULL,
    rating             DECIMAL(3, 1) NULL,
    phone              VARCHAR(100) NULL,
    source_updated_at  DATETIME NULL,
    is_deleted         BOOLEAN NOT NULL DEFAULT FALSE,
    created_at         DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at         DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
                       ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_attraction_category
        FOREIGN KEY (category_id) REFERENCES Category(category_id)
        ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT fk_attraction_city
        FOREIGN KEY (city_id) REFERENCES City(city_id)
        ON DELETE SET NULL ON UPDATE CASCADE,
    INDEX idx_attraction_name (name),
    INDEX idx_attraction_category (category_id),
    INDEX idx_attraction_city (city_id),
    INDEX idx_attraction_rating (rating),
    INDEX idx_attraction_updated (source_updated_at),
    INDEX idx_attraction_deleted (is_deleted)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE Itinerary (
    itinerary_id VARCHAR(36) PRIMARY KEY,
    user_id      INT UNSIGNED NOT NULL,
    title        VARCHAR(255) NOT NULL DEFAULT '我的旅程',
    start_date   DATE NULL,
    num_days     TINYINT UNSIGNED NOT NULL DEFAULT 1,
    is_deleted   BOOLEAN NOT NULL DEFAULT FALSE,
    created_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
                 ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_itinerary_user
        FOREIGN KEY (user_id) REFERENCES `User`(user_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    INDEX idx_itinerary_user_deleted_updated (user_id, is_deleted, updated_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE ItineraryItem (
    itinerary_item_id VARCHAR(36) PRIMARY KEY,
    itinerary_id      VARCHAR(36) NOT NULL,
    attraction_id     VARCHAR(80) NOT NULL,
    day_index         TINYINT UNSIGNED NOT NULL DEFAULT 0,
    start_time        TIME NULL,
    end_time          TIME NULL,
    note              TEXT NULL,
    order_index       INT UNSIGNED NOT NULL DEFAULT 0,
    created_at        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
                      ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_itinerary_item_itinerary
        FOREIGN KEY (itinerary_id) REFERENCES Itinerary(itinerary_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_itinerary_item_attraction
        FOREIGN KEY (attraction_id) REFERENCES Attraction(attraction_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    INDEX idx_itinerary_item_day_order (itinerary_id, day_index, order_index)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
