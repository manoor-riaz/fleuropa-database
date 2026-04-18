DROP TABLE IF EXISTS Commande CASCADE;
DROP TABLE IF EXISTS ModeleBouquet CASCADE;
DROP TABLE IF EXISTS CodePostal CASCADE;
DROP TABLE IF EXISTS ModeLivraison CASCADE;
DROP TABLE IF EXISTS Magasin CASCADE;
DROP TABLE IF EXISTS MembreClub CASCADE;



CREATE TABLE MembreClub (
    numcli SERIAL PRIMARY KEY,
    mdp VARCHAR(100) NOT NULL,
    nom VARCHAR(25) NOT NULL,
    prenom VARCHAR(25),
    sexe VARCHAR(25),
    adresse VARCHAR(200) NOT NULL,
    adressemail VARCHAR(200) NOT NULL
);

CREATE TABLE Magasin (
    id_magasin SERIAL PRIMARY KEY,
    adresse VARCHAR(200) NOT NULL UNIQUE
);

CREATE TABLE ModeLivraison (
    id_livreur SERIAL PRIMARY KEY,
    nom VARCHAR(25),
    prenom VARCHAR(25),
    telephone VARCHAR(10) NOT NULL
);

CREATE TABLE CodePostal (
    code VARCHAR(5) PRIMARY KEY,
    adresse_magasin VARCHAR(200) ,
    id_livreur INTEGER,
    FOREIGN KEY (id_livreur) REFERENCES ModeLivraison(id_livreur),
    FOREIGN KEY (adresse_magasin) REFERENCES Magasin(adresse)
);



CREATE TABLE ModeleBouquet (
    modele VARCHAR(50) PRIMARY KEY,
    taille VARCHAR(10),
    prix NUMERIC(10,2),
    photoModele TEXT
);

CREATE TABLE Commande (
    reference_c SERIAL PRIMARY KEY,
    codeConfidentiel INT DEFAULT (floor(random() * 1000000)) NOT NULL UNIQUE,
    dateExpeditionVoulue DATE NOT NULL,
    etat VARCHAR(25),
    photoCommande BYTEA,
    messageDestinaire TEXT,
    adresseDestinataire VARCHAR(200) NOT NULL,
    nomDestinataire VARCHAR(25) NOT NULL,
    prenomDestinataire VARCHAR(25) NOT NULL,
    nomExpediteur VARCHAR(25) NOT NULL,
    prenomExpediteur VARCHAR(25) NOT NULL,
    adressemail VARCHAR(200) NOT NULL,
    numcli INTEGER,
    code_postal VARCHAR(5),
    modele VARCHAR(50),
    prix NUMERIC(10,2),
    taille VARCHAR(10),
    FOREIGN KEY (numcli) REFERENCES MembreClub(numcli),
    FOREIGN KEY (code_postal) REFERENCES CodePostal(code),
    FOREIGN KEY (modele) REFERENCES ModeleBouquet(modele),
    CONSTRAINT etatcommande CHECK ((etat LIKE '%En_preparation%') OR (etat LIKE '%Expedie%') OR (etat LIKE '%%') OR (etat LIKE '%Livre%') OR (etat LIKE '%En_attente%'))
);



-- Remplissage de la table Magasin
INSERT INTO Magasin (adresse) VALUES
('12 Avenue Victor Hugo, Paris'),
('45 Rue de la Liberte, Lyon'),
('78 Boulevard de la Republique, Marseille'),
('23 Rue des Lilas, Toulouse'),
('56 Avenue des Champs-Elysees, Paris'),
('89 Rue de la Paix, Bordeaux'),
('34 Quai des Bateliers, Strasbourg'),
('67 Rue de Bethune, Lille'),
('50 Promenade des Anglais, Nice'),
('17 Rue Foch, Montpellier'),
('Place de la Concorde, Paris'),
('Rue de la Republique, Lyon'),
('Vieux-Port, Marseille'),
('Place du Capitole, Toulouse'),
('Place Royale, Nantes'),
('Quai des Chartrons, Bordeaux'),
('Place Kleber, Strasbourg'),
('Grand-Place, Lille'),
('Place Massena, Nice'),
('Place de la Comedie, Montpellier'),
('Le Marais, Paris'),
('Place Guichard, Lyon'),
('Cours Julien, Marseille'),
('Place Wilson, Toulouse'),
('Place du Commerce, Nantes'),
('Place de la Bourse, Bordeaux'),
('Place de l''Homme de Fer, Strasbourg'),
('Place Rihour, Lille'),
('Place Garibaldi, Nice'),
('Place de la Canourgue, Montpellier'),
('Place de la Legion d''Honneur, Saint-Denis'),
('Rue Fesch, Ajaccio');

-- Remplissage de la table ModeLivraison
INSERT INTO ModeLivraison (nom, prenom, telephone) VALUES
('Leroy', 'Alice', '0612345678'),
('Dubois', 'Bernard', '0612345679'),
('Martin', 'Claire', '0612345680'),
('Lefevre', 'David', '0612345681'),
('Morel', 'Eva', '0612345682'),
('Simon', 'Francois', '0612345683'),
('Michel', 'Giselle', '0612345684'),
('Garcia', 'Hugo', '0612345685'),
('Bernard', 'Isabelle', '0612345686'),
('Petit', 'Jacques', '0612345687');

-- Remplissage de la table CodePostal 
INSERT INTO CodePostal (code, adresse_magasin, id_livreur) VALUES
('75001', '12 Avenue Victor Hugo, Paris', 1),
('69001', '45 Rue de la Liberte, Lyon', 2),
('13001', '78 Boulevard de la Republique, Marseille', 3),
('31000', '23 Rue des Lilas, Toulouse', 4),
('44000', '56 Avenue des Champs-Elysees, Paris', 5),
('33000', '89 Rue de la Paix, Bordeaux', 6),
('67000', '34 Quai des Bateliers, Strasbourg', 7),
('59000', '67 Rue de Bethune, Lille', 8),
('06000', '50 Promenade des Anglais, Nice', 9),
('34000', '17 Rue Foch, Montpellier', 10),
('75002', 'Place de la Concorde, Paris', 1),
('69002', 'Rue de la Republique, Lyon', 2),
('13002', 'Vieux-Port, Marseille', 3),
('31001', 'Place du Capitole, Toulouse', 4),
('44001', 'Place Royale, Nantes', 5),
('33001', 'Quai des Chartrons, Bordeaux', 6),
('67001', 'Place Kleber, Strasbourg', 7),
('59001', 'Grand-Place, Lille', 8),
('06001', 'Place Massena, Nice', 9),
('34001', 'Place de la Comedie, Montpellier', 10),
('75003', 'Le Marais, Paris', 1),
('69003', 'Place Guichard, Lyon', 2),
('13003', 'Cours Julien, Marseille', 3),
('31002', 'Place Wilson, Toulouse', 4),
('44002', 'Place du Commerce, Nantes', 5),
('33002', 'Place de la Bourse, Bordeaux', 6),
('67002', 'Place de l''Homme de Fer, Strasbourg', 7), 
('59002', 'Place Rihour, Lille', 8),
('06002', 'Place Garibaldi, Nice', 9),
('34002', 'Place de la Canourgue, Montpellier', 10),
('93200', 'Place de la Legion d''Honneur, Saint-Denis', 1), 
('20000', 'Rue Fesch, Ajaccio', 2);


-- Remplissage de la table MembreClub
INSERT INTO MembreClub (nom, prenom, sexe, mdp, adresse, adressemail) VALUES
('Dupont', 'Jean', 'M', 'password123', '123 Rue de la Paix', 'jean.dupont@example.com'),
('Martin', 'Marie', 'F', 'azerty456', '456 Avenue de la Liberte', 'marie.martin@example.com'),
('Durand', 'Paul', 'M', 'xyz789', '789 Boulevard du General', 'paul.durand@example.com'),
('Leroy', 'Sophie', 'F', 'hello321', '12 Place du Marche', 'sophie.leroy@example.com'),
('Moreau', 'Antoine', 'M', 'qwerty654', '34 Rue des Fleurs', 'antoine.moreau@example.com'),
('Bernard', 'Louise', 'F', 'secure789', '98 Chemin Vert', 'louise.bernard@example.com'),
('Roux', 'Lucas', 'M', 'abc123', '11 Allee des Roses', 'lucas.roux@example.com'),
('Petit', 'Emma', 'F', 'def456', '22 Rue du Soleil', 'emma.petit@example.com'),
('Gauthier', 'Pierre', 'M', 'ghi789', '33 Boulevard du Nord', 'pierre.gauthier@example.com'),
('Girard', 'Julie', 'F', 'jkl012', '55 Rue du Centre', 'julie.girard@example.com');


-- Remplissage de la table ModeleBouquet
INSERT INTO ModeleBouquet (modele, taille, prix, photoModele) VALUES
('Rose', NULL, NULL, 'rose.jpg'),
('Tulipe', NULL, NULL, 'tulipe.jpg'),
('Lys', NULL, NULL, 'lys.jpg'),
('Marguerite', NULL, NULL, 'marguerite.jpg'),
('Pivoine', NULL, NULL, 'pivoine.jpg'),
('Orchidee', NULL, NULL, 'orchidee.jpg'),
('Tournesol', NULL, NULL, 'tournesol.jpg'),
('Lavande', NULL, NULL, 'lavande.jpg'),
('Camomille', NULL, NULL, 'camomille.jpg'),
('Freesia', NULL, NULL, 'freesia.jpg'),
('Rose_Petit', 'Petit', 19.99, 'rosepetit.jpg'),
('Rose_Moyen', 'Moyen', 29.99, 'rosemoyen.jpg'),
('Rose_Grand', 'Grand', 39.99, 'rosegrand.jpg'),
('Tulipe_Petit', 'Petit', 19.50, 'tulipepetit.jpg'),
('Tulipe_Moyen', 'Moyen', 29.50, 'tulipemoyen.jpg'),
('Tulipe_Grand', 'Grand', 39.50, 'tulipegrand.jpg'),
('Lys_Petit', 'Petit', 35.00, 'lyspetit.jpg'),
('Lys_Moyen', 'Moyen', 40.00, 'lysmoyen.jpg'),
('Lys_Grand', 'Grand', 45.00, 'lysgrand.jpg'),
('Marguerite_Petit', 'Petit', 17.75, 'margueritepetit.jpg'),
('Marguerite_Moyen', 'Moyen', 22.75, 'margueritemoyen.jpg'),
('Marguerite_Grand', 'Grand', 27.75, 'margueritegrand.jpg'),
('Pivoine_Petit', 'Petit', 25.00, 'pivoinepetit.jpg'),
('Pivoine_Moyen', 'Moyen', 30.00, 'pivoinemoyen.jpg'),
('Pivoine_Grand', 'Grand', 35.00, 'pivoinegrand.jpg'),
('Orchidee_Petit', 'Petit', 40.00, 'orchideepetit.jpg'),
('Orchidee_Moyen', 'Moyen', 50.00, 'orchideemoyen.jpg'),
('Orchidee_Grand', 'Grand', 60.00, 'orchideegrand.jpg'),
('Tournesol_Petit', 'Petit', 15.50, 'tournesolpetit.jpg'),
('Tournesol_Moyen', 'Moyen', 20.50, 'tournesolmoyen.jpg'),
('Tournesol_Grand', 'Grand', 25.50, 'tournesolgrand.jpg'),
('Lavande_Petit', 'Petit', 13.00, 'lavandepetit.jpg'),
('Lavande_Moyen', 'Moyen', 18.00, 'lavandemoyen.jpg'),
('Lavande_Grand', 'Grand', 23.00, 'lavandegrand.jpg'),
('Camomille_Petit', 'Petit', 12.50, 'camomillepetit.jpg'),
('Camomille_Moyen', 'Moyen', 17.50, 'camomillemoyen.jpg'),
('Camomille_Grand', 'Grand', 22.50, 'camomillegrand.jpg'),
('Freesia_Petit', 'Petit', 22.00, 'freesiapetit.jpg'),
('Freesia_Moyen', 'Moyen', 27.00, 'freesiamoyen.jpg'),
('Freesia_Grand', 'Grand', 32.00, 'freesiagrand.jpg');

-- Remplissage de la table Commande 
INSERT INTO Commande (dateExpeditionVoulue, etat, messageDestinaire, adresseDestinataire, nomDestinataire, prenomDestinataire, nomExpediteur, prenomExpediteur, adressemail, code_postal, modele, prix, taille)
VALUES
('2024-12-23', 'En_preparation', 'Félicitations!', '123 Rue de la Paix', 'Alice', 'Martin', 'Jean', 'Martin', 'jean.martin@example.com', '75001', 'Tulipe_Petit', 19.50, 'Petit'),
('2024-12-24', 'En_preparation', 'Joyeux Noël!', '456 Avenue de la Liberté', 'Bob', 'Durand', 'Paul', 'Durand', 'paul.durand@example.com', '69001', 'Tulipe_Petit', 19.50, 'Petit'),
('2024-12-25', 'En_preparation', 'Bonne année!', '789 Boulevard du Général', 'Charlie', 'Leroy', 'Sophie', 'Leroy', 'sophie.leroy@example.com', '31000', 'Tulipe_Petit', 19.50, 'Petit'),
('2024-12-20', 'Expedie', 'Avec amour!', '34 Rue des Fleurs', 'Lucas', 'Bernard', 'Louise', 'Bernard', 'louise.bernard@example.com', '33000', 'Orchidee_Grand', 50.00, 'Grand'),
('2024-12-26', 'En_preparation', 'Félicitations!', '123 Rue de la Paix', 'Alice', 'Martin', 'Jean', 'Martin', 'jean.martin@example.com', '75001', 'Orchidee_Grand', 50.00, 'Grand'),
('2024-12-27', 'En_preparation', 'Joyeux Noël!', '456 Avenue de la Liberté', 'Bob', 'Durand', 'Paul', 'Durand', 'paul.durand@example.com', '69001', 'Orchidee_Grand', 50.00, 'Grand'),
('2024-12-28', 'En_preparation', 'Bonne année!', '789 Boulevard du Général', 'Charlie', 'Leroy', 'Sophie', 'Leroy', 'sophie.leroy@example.com', '31000', 'Orchidee_Grand', 50.00, 'Grand'),
('2024-12-22', 'Expedie', 'Bienvenue au monde!', '33 Boulevard du Nord', 'Julie', 'Girard', 'Julie', 'Girard', 'julie.girard@example.com', '34000', 'Rose_Moyen', 40.00, 'Moyen'),
('2024-12-29', 'En_preparation', 'Félicitations!', '123 Rue de la Paix', 'Alice', 'Martin', 'Jean', 'Martin', 'jean.martin@example.com', '75001', 'Rose_Moyen', 40.00, 'Moyen'),
('2024-12-30', 'En_preparation', 'Bonne année!', '456 Avenue de la Liberté', 'Bob', 'Durand', 'Paul', 'Durand', 'paul.durand@example.com', '69001', 'Rose_Moyen', 40.00, 'Moyen'),
('2024-12-01', 'En_preparation', 'Joyeux anniversaire!', '123 Rue de la Paix', 'Marie', 'Dupont', 'Jean', 'Dupont', 'jean.dupont@example.com', '75001', 'Rose_Petit', 20.50, 'Petit'),
('2024-12-10', 'En_preparation', 'Meilleurs voeux!', '456 Avenue de la Liberte', 'Claire', 'Durand', 'Paul', 'Durand', 'paul.durand@example.com', '69001', 'Lys_Grand', 45.00, 'Grand'),
('2024-11-25', 'Livre', 'Je pense a toi!', '789 Boulevard du General', 'Antoine', 'Leroy', 'Sophie', 'Leroy', 'sophie.leroy@example.com', '31000', 'Marguerite_Grand', 35.00, 'Grand'),
('2024-12-15', 'En_preparation', 'Bon retablissement!', '12 Place du Marche', 'Sophie', 'Moreau', 'Antoine', 'Moreau', 'antoine.moreau@example.com', '44000', 'Pivoine_Moyen', 25.00, 'Moyen'),
('2024-11-30', 'En_preparation', 'Merci beaucoup!', '98 Chemin Vert', 'Louise', 'Petit', 'Emma', 'Petit', 'emma.petit@example.com', '67000', 'Tournesol_Petit', 15.00, 'Petit'),
('2024-12-02', 'Livre', 'Toutes mes pensees.', '11 Allee des Roses', 'Emma', 'Roux', 'Lucas', 'Roux', 'lucas.roux@example.com', '59000', 'Lavande_Moyen', 30.00, 'Moyen'),
('2024-12-08', 'En_attente', 'Avec mes condoleances.', '22 Rue du Soleil', 'Pierre', 'Gauthier', 'Julie', 'Gauthier', 'pierre.gauthier@example.com', '06000', 'Camomille_Grand', 60.00, 'Grand');