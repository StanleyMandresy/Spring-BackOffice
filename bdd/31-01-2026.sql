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

CREATE TABLE IF NOT EXISTS voitures (
    id SERIAL PRIMARY KEY,
    marque VARCHAR(50) NOT NULL,
    modele VARCHAR(50) NOT NULL,
    annee INT CHECK (annee >= 1900),
    prix NUMERIC(10,2),
    user_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE SET NULL
);


INSERT INTO voitures (marque, modele, annee, prix, user_id) VALUES
('Toyota', 'Corolla', 2020, 18000, 1),
('BMW', 'Serie 3', 2019, 32000, 1),
('Mercedes', 'C200', 2021, 35000, 1),
('Hyundai', 'Elantra', 2018, 15000, 2),
('Peugeot', '208', 2022, 17000, 2),
('Volkswagen', 'Golf', 2020, 21000, NULL);
