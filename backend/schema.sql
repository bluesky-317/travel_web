-- ============================================================
-- Travel Web - simplified MariaDB schema
-- Core CRUD tables: users, categories, cities, attractions, itineraries, itinerary_items.
-- Removed: user_roles, towns, tags, attraction_tags,
-- attraction_descriptions, user_favorites, user_visited.
-- ============================================================

CREATE DATABASE IF NOT EXISTS travel_web
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE travel_web;

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS user_visited;
DROP TABLE IF EXISTS user_favorites;
DROP TABLE IF EXISTS attraction_tags;
DROP TABLE IF EXISTS attraction_descriptions;
DROP TABLE IF EXISTS itinerary_items;
DROP TABLE IF EXISTS itineraries;
DROP TABLE IF EXISTS attractions;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS cities;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS tags;
DROP TABLE IF EXISTS towns;
DROP TABLE IF EXISTS user_roles;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE users (
    user_id       INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    email         VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    name          VARCHAR(100) NOT NULL,
    role          VARCHAR(30) NOT NULL DEFAULT 'user',
    create_time   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    login_time    DATETIME NULL,
    INDEX idx_users_role (role)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE categories (
    category_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(100) NOT NULL UNIQUE,
    INDEX idx_categories_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE cities (
    city_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name    VARCHAR(50) NOT NULL UNIQUE,
    INDEX idx_cities_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE attractions (
    attraction_id     VARCHAR(80) PRIMARY KEY,
    name              VARCHAR(255) NOT NULL,
    category_id       INT UNSIGNED NULL,
    city_id           INT UNSIGNED NULL,
    address           VARCHAR(255) NULL,
    lat               DECIMAL(10, 7) NULL,
    lon               DECIMAL(11, 7) NULL,
    image_url         TEXT NULL,
    description       TEXT NULL,
    opening_hours     TEXT NULL,
    ticket_info       TEXT NULL,
    website_url       TEXT NULL,
    rating            DECIMAL(3, 1) NULL,
    phone             VARCHAR(100) NULL,
    source_updated_at DATETIME NULL,
    is_deleted        BOOLEAN NOT NULL DEFAULT FALSE,
    created_at        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
                      ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_attractions_category
        FOREIGN KEY (category_id) REFERENCES categories(category_id)
        ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT fk_attractions_city
        FOREIGN KEY (city_id) REFERENCES cities(city_id)
        ON DELETE SET NULL ON UPDATE CASCADE,
    INDEX idx_attractions_name (name),
    INDEX idx_attractions_category (category_id),
    INDEX idx_attractions_city (city_id),
    INDEX idx_attractions_rating (rating),
    INDEX idx_attractions_updated (source_updated_at),
    INDEX idx_attractions_deleted (is_deleted)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE itineraries (
    itinerary_id VARCHAR(36) PRIMARY KEY,
    user_id      INT UNSIGNED NOT NULL,
    title        VARCHAR(255) NOT NULL DEFAULT '我的旅程',
    start_date   DATE NULL,
    num_days     TINYINT UNSIGNED NOT NULL DEFAULT 1,
    is_deleted   BOOLEAN NOT NULL DEFAULT FALSE,
    created_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
                 ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_itineraries_user
        FOREIGN KEY (user_id) REFERENCES users(user_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    INDEX idx_itineraries_user_deleted_updated (user_id, is_deleted, updated_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE itinerary_items (
    item_id       VARCHAR(36) PRIMARY KEY,
    itinerary_id  VARCHAR(36) NOT NULL,
    attraction_id VARCHAR(80) NOT NULL,
    day_index     TINYINT UNSIGNED NOT NULL DEFAULT 0,
    start_time    TIME NULL,
    end_time      TIME NULL,
    note          TEXT NULL,
    order_index   INT UNSIGNED NOT NULL DEFAULT 0,
    created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
                  ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_itinerary_items_itinerary
        FOREIGN KEY (itinerary_id) REFERENCES itineraries(itinerary_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_itinerary_items_attraction
        FOREIGN KEY (attraction_id) REFERENCES attractions(attraction_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    INDEX idx_itinerary_items_itinerary_day_order (itinerary_id, day_index, order_index)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
