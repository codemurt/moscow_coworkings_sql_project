SET NAMES utf8mb4;
SET CHARACTER SET utf8mb4;

CREATE DATABASE IF NOT EXISTS moscow_coworkings CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE moscow_coworkings;

CREATE TABLE coworkings (
    coworking_id INT PRIMARY KEY AUTO_INCREMENT,
    full_name VARCHAR(255) NOT NULL,
    short_description TEXT,
    year_created INT,
    contact_phone VARCHAR(50),
    email VARCHAR(100),
    site VARCHAR(255),
    global_id BIGINT,
    avg_rating DECIMAL(3,2) DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE locations (
    location_id INT PRIMARY KEY AUTO_INCREMENT,
    coworking_id INT NOT NULL,
    adm_area VARCHAR(100),
    district VARCHAR(100),
    address TEXT,
    coordinates POINT,
    FOREIGN KEY (coworking_id) REFERENCES coworkings(coworking_id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE tariffs (
    tariff_id INT PRIMARY KEY AUTO_INCREMENT,
    coworking_id INT NOT NULL,
    tariff_type ENUM('hourly', 'daily', 'monthly', 'long_term'),
    price DECIMAL(10,2),
    FOREIGN KEY (coworking_id) REFERENCES coworkings(coworking_id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE facilities (
    facility_id INT PRIMARY KEY AUTO_INCREMENT,
    coworking_id INT NOT NULL,
    facility_name VARCHAR(100),
    FOREIGN KEY (coworking_id) REFERENCES coworkings(coworking_id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE reviews (
    review_id INT PRIMARY KEY AUTO_INCREMENT,
    coworking_id INT NOT NULL,
    rating INT CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (coworking_id) REFERENCES coworkings(coworking_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Индексы
CREATE INDEX idx_locations_adm_area ON locations(adm_area);
CREATE INDEX idx_coworkings_year ON coworkings(year_created);
CREATE INDEX idx_tariffs_type_price ON tariffs(tariff_type, price);

-- Триггер для обновления рейтинга
DELIMITER //
CREATE TRIGGER update_avg_rating AFTER INSERT ON reviews
FOR EACH ROW
BEGIN
    UPDATE coworkings c
    SET avg_rating = (
        SELECT AVG(rating)
        FROM reviews
        WHERE coworking_id = NEW.coworking_id
    )
    WHERE c.coworking_id = NEW.coworking_id;
END; //
DELIMITER ;

-- Процедура по добавлению отзыва
DELIMITER //
CREATE PROCEDURE AddReview(
    IN coworking_id INT,
    IN rating INT,
    IN comment TEXT
)
BEGIN
    INSERT INTO reviews(coworking_id, rating, comment)
    VALUES (coworking_id, rating, comment);
END //
DELIMITER ;

INSERT INTO coworkings (full_name, short_description, year_created, contact_phone) VALUES 
('Бесплатный коворкинг ЦУБ ВАО', 'Рабочие места с Wi-Fi', 2012, '(495) 225-14-14'),
('Коворкинг Свободное плавание', 'Пространство для стартапов', 2012, '(495) 478-70-08'),
('Коворкинг Технопарка Строгино', 'Коворкинг в технопарке Строгино представляет собой площадку для предпринимателей различных форм бизнеса, которая поможет организовать комфортную работу.', 2015, '(495) 248-00-88'),
('Коворкинг - Technounity', 'Коворкинг-Technounity – офисное пространство, Open space, площадью 151,1 кв.м, для предпринимателей и фрилансеров.', 2015, '(499) 214-00-01'),
('Коворкинг Технопарка Слава', 'Коворкинг Технопарка Слава - это организованное рабочее пространство, которое создано специально для активных, молодых и инициативных людей: фрилансеров, предпринимателей, стартаперов.', 2015, '(495) 478-78-00');


INSERT INTO locations (coworking_id, adm_area, district, address, coordinates) VALUES
(1, 'Восточный административный округ', 'Измайлово', 'Средняя Первомайская улица, дом 3', POINT(37.803817592, 55.79572031)),
(2, 'Южный административный округ', 'Нагорный район', 'Варшавское шоссе, дом 28А', POINT(37.617929406, 55.682710352)),
(3, 'Северо-Западный административный округ', 'Строгино', 'улица Твардовского, дом 8, строение 1', POINT(37.392164825, 55.794442094)),
(4, 'Зеленоградский административный округ', 'Савёлки', 'улица Юности, дом 8', POINT(37.223851856, 55.999012478)),
(5, 'Юго-Западный административный округ', 'Черёмушки', 'Научный проезд, дом 20, строение 2', POINT(37.552505792, 55.653755985));

INSERT INTO tariffs (coworking_id, tariff_type, price) VALUES
(1, 'daily', 0.00),
(2, 'hourly', 880.00),
(2, 'monthly', 8690.00),
(3, 'daily', 520.00),
(3, 'monthly', 8200.00),
(4, 'monthly', 5600.00),
(5, 'monthly', 10300.00);

INSERT INTO facilities (coworking_id, facility_name) VALUES
(1, 'Wi-Fi'),
(1, 'Переговорные комнаты'),
(2, 'Парковка'),
(2, 'Кофе'),
(3, 'Парковка'),
(4, 'Wi-Fi'),
(4, 'Магнитно-маркерная доска'),
(4, 'Доступ к переговорным комнатам'),
(4, 'Локеры для хранения личных вещей'),
(4, 'Оборудованная кухня'),
(5, 'Переговорные комнаты'),
(5, 'Просторный конференц-зал');

INSERT INTO reviews (coworking_id, rating, comment) VALUES
(1, 5, 'Отличное место!'),
(1, 4, 'Хороший коворкинг'),
(2, 5, 'Лучший в городе'),
(3, 4, 'Достаточно недорого, но мало розеток'),
(4, 2, 'Обычно очень шумно в здании, поэтому берите с собой наушники'),
(5, 4, 'В целом всё хорошо, понравилось то, что рядом с центром, легко добраться'),
(5, 3, 'Нужно сильно заранее бронировать, иначе всё быстро разбирают, не рекомендую.');

-- Вызов
CALL AddReview(2, 5, 'Отличный сервис, всё понравилось.');