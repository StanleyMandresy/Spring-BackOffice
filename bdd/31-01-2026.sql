CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(100) NOT NULL,
    role VARCHAR(20) DEFAULT 'USER',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

--test
insert into users (username, password, role) values 
('admin', 'adminpass', 'ADMIN');
insert into users (username, password, role) values 
('user', 'userpass', 'USER');