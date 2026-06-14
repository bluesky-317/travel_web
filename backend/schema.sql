-- ============================================================
-- Travel Web - simplified MariaDB schema
-- Core CRUD tables: Users, Categories, Cities, Attractions, Itineraries, ItineraryItems.
-- Removed: user_roles, towns, tags, attraction_tags,
-- attraction_descriptions, user_favorites, user_visited.
-- Both table and column names are PascalCase.
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
DROP TABLE IF EXISTS tags;
DROP TABLE IF EXISTS towns;
DROP TABLE IF EXISTS user_roles;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE Users (
    UserId        INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    Email         VARCHAR(255) NOT NULL UNIQUE,
    PasswordHash  VARCHAR(255) NOT NULL,
    Name          VARCHAR(100) NOT NULL,
    Role          VARCHAR(30) NOT NULL DEFAULT 'user',
    CreateTime    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    LoginTime     DATETIME NULL,
    INDEX idx_users_role (Role)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE Categories (
    CategoryId INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    Name       VARCHAR(100) NOT NULL UNIQUE,
    INDEX idx_categories_name (Name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE Cities (
    CityId INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    Name   VARCHAR(50) NOT NULL UNIQUE,
    INDEX idx_cities_name (Name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE Attractions (
    AttractionId      VARCHAR(80) PRIMARY KEY,
    Name              VARCHAR(255) NOT NULL,
    CategoryId        INT UNSIGNED NULL,
    CityId            INT UNSIGNED NULL,
    Address           VARCHAR(255) NULL,
    Lat               DECIMAL(10, 7) NULL,
    Lon               DECIMAL(11, 7) NULL,
    ImageUrl          TEXT NULL,
    Description       TEXT NULL,
    OpeningHours      TEXT NULL,
    TicketInfo        TEXT NULL,
    WebsiteUrl        TEXT NULL,
    Rating            DECIMAL(3, 1) NULL,
    Phone             VARCHAR(100) NULL,
    SourceUpdatedAt   DATETIME NULL,
    IsDeleted         BOOLEAN NOT NULL DEFAULT FALSE,
    CreatedAt         DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt         DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
                      ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_attractions_category
        FOREIGN KEY (CategoryId) REFERENCES Categories(CategoryId)
        ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT fk_attractions_city
        FOREIGN KEY (CityId) REFERENCES Cities(CityId)
        ON DELETE SET NULL ON UPDATE CASCADE,
    INDEX idx_attractions_name (Name),
    INDEX idx_attractions_category (CategoryId),
    INDEX idx_attractions_city (CityId),
    INDEX idx_attractions_rating (Rating),
    INDEX idx_attractions_updated (SourceUpdatedAt),
    INDEX idx_attractions_deleted (IsDeleted)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE Itineraries (
    ItineraryId  VARCHAR(36) PRIMARY KEY,
    UserId       INT UNSIGNED NOT NULL,
    Title        VARCHAR(255) NOT NULL DEFAULT '我的旅程',
    StartDate    DATE NULL,
    NumDays      TINYINT UNSIGNED NOT NULL DEFAULT 1,
    IsDeleted    BOOLEAN NOT NULL DEFAULT FALSE,
    CreatedAt    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
                 ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_itineraries_user
        FOREIGN KEY (UserId) REFERENCES Users(UserId)
        ON DELETE CASCADE ON UPDATE CASCADE,
    INDEX idx_itineraries_user_deleted_updated (UserId, IsDeleted, UpdatedAt)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE ItineraryItems (
    ItemId        VARCHAR(36) PRIMARY KEY,
    ItineraryId   VARCHAR(36) NOT NULL,
    AttractionId  VARCHAR(80) NOT NULL,
    DayIndex      TINYINT UNSIGNED NOT NULL DEFAULT 0,
    StartTime     TIME NULL,
    EndTime       TIME NULL,
    Note          TEXT NULL,
    OrderIndex    INT UNSIGNED NOT NULL DEFAULT 0,
    CreatedAt     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
                  ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_itinerary_items_itinerary
        FOREIGN KEY (ItineraryId) REFERENCES Itineraries(ItineraryId)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_itinerary_items_attraction
        FOREIGN KEY (AttractionId) REFERENCES Attractions(AttractionId)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    INDEX idx_itinerary_items_itinerary_day_order (ItineraryId, DayIndex, OrderIndex)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
