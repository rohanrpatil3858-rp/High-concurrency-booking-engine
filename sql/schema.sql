DROP DATABASE IF EXISTS bookmyshow_db;
CREATE DATABASE bookmyshow_db;
USE bookmyshow_db;

CREATE TABLE users (
 user_id BIGINT PRIMARY KEY AUTO_INCREMENT,
 full_name VARCHAR(100) NOT NULL,
 email VARCHAR(255) NOT NULL UNIQUE,
 phone VARCHAR(20),
 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE theatres (
 theatre_id BIGINT PRIMARY KEY AUTO_INCREMENT,
 theatre_name VARCHAR(150) NOT NULL,
 city VARCHAR(100) NOT NULL,
 address VARCHAR(255) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE screens (
 screen_id BIGINT PRIMARY KEY AUTO_INCREMENT,
 theatre_id BIGINT NOT NULL,
 screen_name VARCHAR(100) NOT NULL,
 capacity INT NOT NULL CHECK (capacity > 0),
 FOREIGN KEY (theatre_id) REFERENCES theatres(theatre_id),
 UNIQUE (theatre_id, screen_name)
) ENGINE=InnoDB;

CREATE TABLE seats (
 seat_id BIGINT PRIMARY KEY AUTO_INCREMENT,
 screen_id BIGINT NOT NULL,
 row_label VARCHAR(10) NOT NULL,
 seat_number INT NOT NULL CHECK (seat_number > 0),
 seat_type VARCHAR(30) NOT NULL DEFAULT 'REGULAR',
 FOREIGN KEY (screen_id) REFERENCES screens(screen_id),
 UNIQUE (screen_id, row_label, seat_number)
) ENGINE=InnoDB;

CREATE TABLE movies (
 movie_id BIGINT PRIMARY KEY AUTO_INCREMENT,
 title VARCHAR(200) NOT NULL,
 duration_minutes INT NOT NULL CHECK (duration_minutes > 0),
 language VARCHAR(50) NOT NULL,
 certificate VARCHAR(20)
) ENGINE=InnoDB;

CREATE TABLE shows (
 show_id BIGINT PRIMARY KEY AUTO_INCREMENT,
 screen_id BIGINT NOT NULL,
 movie_id BIGINT NOT NULL,
 show_date DATE NOT NULL,
 start_time TIME NOT NULL,
 end_time TIME NOT NULL,
 FOREIGN KEY (screen_id) REFERENCES screens(screen_id),
 FOREIGN KEY (movie_id) REFERENCES movies(movie_id),
 UNIQUE (screen_id, show_date, start_time),
 CHECK (end_time > start_time)
) ENGINE=InnoDB;

CREATE INDEX idx_shows_screen_date ON shows(screen_id, show_date, start_time);

CREATE TABLE show_seats (
 show_seat_id BIGINT PRIMARY KEY AUTO_INCREMENT,
 show_id BIGINT NOT NULL,
 seat_id BIGINT NOT NULL,
 status ENUM('AVAILABLE','HELD','BOOKED') NOT NULL DEFAULT 'AVAILABLE',
 hold_expires_at DATETIME NULL,
 version INT NOT NULL DEFAULT 0,
 FOREIGN KEY (show_id) REFERENCES shows(show_id),
 FOREIGN KEY (seat_id) REFERENCES seats(seat_id),
 UNIQUE (show_id, seat_id)
) ENGINE=InnoDB;

CREATE INDEX idx_show_seats_status ON show_seats(show_id, status);
CREATE INDEX idx_show_seats_expiry ON show_seats(hold_expires_at);

CREATE TABLE bookings (
 booking_id BIGINT PRIMARY KEY AUTO_INCREMENT,
 user_id BIGINT NOT NULL,
 show_id BIGINT NOT NULL,
 status ENUM('PENDING','CONFIRMED','CANCELLED','EXPIRED') NOT NULL DEFAULT 'PENDING',
 total_amount DECIMAL(10,2) NOT NULL CHECK (total_amount >= 0),
 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 expires_at DATETIME NULL,
 FOREIGN KEY (user_id) REFERENCES users(user_id),
 FOREIGN KEY (show_id) REFERENCES shows(show_id)
) ENGINE=InnoDB;

CREATE INDEX idx_bookings_user ON bookings(user_id, created_at);
CREATE INDEX idx_bookings_show_status ON bookings(show_id, status);

CREATE TABLE booking_items (
 booking_item_id BIGINT PRIMARY KEY AUTO_INCREMENT,
 booking_id BIGINT NOT NULL,
 show_seat_id BIGINT NOT NULL,
 price DECIMAL(10,2) NOT NULL CHECK (price >= 0),
 FOREIGN KEY (booking_id) REFERENCES bookings(booking_id),
 FOREIGN KEY (show_seat_id) REFERENCES show_seats(show_seat_id),
 UNIQUE (booking_id, show_seat_id)
) ENGINE=InnoDB;

CREATE INDEX idx_booking_items_seat ON booking_items(show_seat_id);

CREATE TABLE payments (
 payment_id BIGINT PRIMARY KEY AUTO_INCREMENT,
 booking_id BIGINT NOT NULL,
 provider_payment_id VARCHAR(100) NOT NULL UNIQUE,
 amount DECIMAL(10,2) NOT NULL CHECK (amount >= 0),
 status ENUM('PENDING','SUCCESS','FAILED','REFUNDED') NOT NULL DEFAULT 'PENDING',
 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 FOREIGN KEY (booking_id) REFERENCES bookings(booking_id)
) ENGINE=InnoDB;

CREATE TABLE payment_webhook_events (
 webhook_event_id BIGINT PRIMARY KEY AUTO_INCREMENT,
 provider_event_id VARCHAR(150) NOT NULL UNIQUE,
 provider_payment_id VARCHAR(100) NOT NULL,
 event_type VARCHAR(50) NOT NULL,
 received_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 processed_at TIMESTAMP NULL
) ENGINE=InnoDB;

CREATE INDEX idx_webhook_payment ON payment_webhook_events(provider_payment_id);

INSERT INTO users (full_name,email,phone) VALUES
('Rohan Patil','rohan@example.com','9000000001'),
('Amit Sharma','amit@example.com','9000000002');

INSERT INTO theatres (theatre_name,city,address) VALUES
('City Mall Cinemas','Pune','MG Road, Pune');

INSERT INTO screens (theatre_id,screen_name,capacity) VALUES
(1,'Screen 1',6),(1,'Screen 2',4);

INSERT INTO seats (screen_id,row_label,seat_number,seat_type) VALUES
(1,'A',1,'REGULAR'),(1,'A',2,'REGULAR'),(1,'A',3,'REGULAR'),
(1,'B',1,'PREMIUM'),(1,'B',2,'PREMIUM'),(1,'B',3,'PREMIUM'),
(2,'A',1,'REGULAR'),(2,'A',2,'REGULAR'),(2,'A',3,'REGULAR'),(2,'A',4,'REGULAR');

INSERT INTO movies (title,duration_minutes,language,certificate) VALUES
('The Last Journey',145,'English','U/A'),
('Mumbai Nights',130,'Hindi','U/A');

INSERT INTO shows (screen_id,movie_id,show_date,start_time,end_time) VALUES
(1,1,'2026-10-01','18:00:00','20:25:00'),
(1,1,'2026-10-01','21:00:00','23:25:00'),
(2,2,'2026-10-01','19:30:00','21:40:00');

INSERT INTO show_seats (show_id,seat_id) SELECT 1,seat_id FROM seats WHERE screen_id=1;
INSERT INTO show_seats (show_id,seat_id) SELECT 2,seat_id FROM seats WHERE screen_id=1;
INSERT INTO show_seats (show_id,seat_id) SELECT 3,seat_id FROM seats WHERE screen_id=2;

INSERT INTO bookings (user_id,show_id,status,total_amount)
VALUES (1,1,'CONFIRMED',500.00);

INSERT INTO booking_items (booking_id,show_seat_id,price)
VALUES (1,1,250.00),(1,2,250.00);

UPDATE show_seats SET status='BOOKED',version=version+1 WHERE show_seat_id IN (1,2);

INSERT INTO payments (booking_id,provider_payment_id,amount,status)
VALUES (1,'PAY_10001',500.00,'SUCCESS');

-- P2: shows on a given date at a given theatre
SELECT t.theatre_name,m.title AS movie_title,s.show_date,
       s.start_time,s.end_time,sc.screen_name
FROM shows s
JOIN screens sc ON sc.screen_id=s.screen_id
JOIN theatres t ON t.theatre_id=sc.theatre_id
JOIN movies m ON m.movie_id=s.movie_id
WHERE t.theatre_id=1 AND s.show_date='2026-10-01'
ORDER BY s.start_time;

-- Pessimistic locking example:
-- START TRANSACTION;
-- SELECT show_seat_id,status,hold_expires_at
-- FROM show_seats
-- WHERE show_seat_id IN (1,2)
-- FOR UPDATE;
-- UPDATE show_seats
-- SET status='HELD',hold_expires_at=DATE_ADD(NOW(),INTERVAL 5 MINUTE),
--     version=version+1
-- WHERE show_seat_id IN (1,2) AND status='AVAILABLE';
-- COMMIT;

-- Release expired holds:
UPDATE show_seats
SET status='AVAILABLE',hold_expires_at=NULL,version=version+1
WHERE status='HELD' AND hold_expires_at<=NOW();
