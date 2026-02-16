CREATE TABLE vehicule (
    id SERIAL PRIMARY KEY,
    reference VARCHAR(50) NOT NULL,
    nbrPlace INTEGER NOT NULL,
    type_carburant CHAR(2) NOT NULL CHECK (type_carburant IN ('D', 'ES', 'S', 'E'))
);