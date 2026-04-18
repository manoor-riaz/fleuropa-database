import time
import db
from random import randint
from flask import Flask, render_template, request, redirect, url_for, session  # type: ignore
from datetime import datetime
from passlib.context import CryptContext  # type: ignore
password_ctx = CryptContext(schemes=['bcrypt']) 
app = Flask(__name__)
import random


# Clef secrète utilisée pour chiffrer les cookies
app.secret_key = b'd2b01c987b6f7f0d5896aae06c4f318c9772d6651abff24aec19297cdf5eb199'

@app.route("/accueil")
def accueil():
    return render_template("accueil.html")

@app.route("/bouquets")
def bouquets():
    with db.connect() as conn:
        with conn.cursor() as cur:
            cur.execute("""
                SELECT Commande.modele, ModeleBouquet.photoModele, ModeleBouquet.taille, COUNT(*) AS count
                FROM Commande
                JOIN ModeleBouquet ON Commande.modele = ModeleBouquet.modele
                GROUP BY Commande.modele, ModeleBouquet.photoModele, ModeleBouquet.taille
                ORDER BY count DESC
                LIMIT 3
            """)
            bouquets_plus_achetes = cur.fetchall()
            print("Bouquets les plus achetés:", bouquets_plus_achetes)

            cur.execute("SELECT modele, photoModele FROM ModeleBouquet WHERE taille IS NULL")
            tous_les_bouquets = cur.fetchall()
            print("Tous les bouquets:", tous_les_bouquets)

    return render_template("bouquets.html", bouquets_plus_achetes=bouquets_plus_achetes, tous_les_bouquets=tous_les_bouquets)

@app.route("/choisir_taille/<modele>")
def choisir_taille(modele):
    with db.connect() as conn:
        with conn.cursor() as cur:

            cur.execute("SELECT modele, taille, prix, photoModele FROM ModeleBouquet WHERE modele LIKE %s AND taille IS NOT NULL", (f"{modele}_%",))
            bouquet = cur.fetchall()
            print("Bouquet:", bouquet)
    return render_template("choisir_taille.html", bouquet=bouquet, modele=modele)


@app.route("/bouquet/<modele>")
def bouquet(modele):
    with db.connect() as conn:
        with conn.cursor() as cur:
            cur.execute("SELECT * FROM modelebouquet WHERE modele = %s", (modele,))
            bouquet = cur.fetchone()
    if not bouquet:
        return render_template("bouquets.html")
    return render_template("bouquet.html", bouquet=bouquet)

@app.route('/magasins')
def magasins():
    with db.connect() as conn:
        with conn.cursor() as cur:
            cur.execute("SELECT code, adresse_magasin FROM CodePostal")
            magasins = cur.fetchall()
    return render_template('magasins.html', magasins=magasins)

@app.route("/inscription", methods=["GET", "POST"])
def inscription():
    if request.method == "POST":
        nom = request.form["nom"]
        prenom = request.form["prenom"]
        sexe = request.form["sexe"]
        mdp = request.form["mdp"]
        adresse = request.form["adresse"]
        adressemail = request.form["adressemail"]

        if '@' not in adressemail: 
            erreur = "Adresse email incorrecte. Veuillez entrer une adresse email valide."
            return render_template("inscription.html", erreur=erreur, nom=nom, prenom=prenom, sexe=sexe, adresse=adresse)
        
        if not (nom and prenom and sexe and mdp and adresse and adressemail):
            return render_template("inscription.html", erreur="Tous les champs sont obligatoires.", nom=nom, prenom=prenom, sexe=sexe, adresse=adresse)

        hashed_mdp = password_ctx.hash(mdp)

        with db.connect() as conn:
            with conn.cursor() as cur:
                cur.execute("""
                INSERT INTO MembreClub (mdp, nom, prenom, sexe, adresse, adressemail) 
                VALUES (%s, %s, %s, %s, %s, %s) RETURNING numcli
                """, (hashed_mdp, nom, prenom, sexe, adresse, adressemail))
                numcli = cur.fetchone()[0]

        return redirect(url_for("inscription_reussi", numcli=numcli))

    return render_template("inscription.html")


@app.route("/inscription_reussi/<int:numcli>")
def inscription_reussi(numcli):
    return render_template("inscription_reussi.html", numcli=numcli)

@app.route("/connexion", methods=["GET", "POST"])
def connexion():
    if request.method == "POST":
        numcli = request.form["numcli"]
        mdp = request.form["mdp"]

        utilisateur = None
        with db.connect() as conn:
            with conn.cursor() as cur:
                cur.execute("SELECT * FROM MembreClub WHERE numcli = %s", (numcli,))
                utilisateur = cur.fetchone()

        if utilisateur and password_ctx.verify(mdp, utilisateur[1]):
            session["numcli"] = utilisateur[0]
            session["nom"] = utilisateur[2]
            session["prenom"] = utilisateur[3]
            session["sexe"] = utilisateur[4]
            session["adresse"] = utilisateur[5]
            session["adressemail"] = utilisateur[6]

            next_page = session.pop('next', url_for('accueil'))
            return redirect(next_page)
        else:
            return render_template("connexion.html", erreur="Numéro de client ou mot de passe incorrect")

    session['next'] = request.args.get('next', url_for('accueil'))
    return render_template("connexion.html")

@app.route('/commande/<modele>/<taille>/<prix>/<photomodele>', methods=["GET", "POST"])
def commande(modele, taille, prix, photomodele):
    bouquet = {
        'modele': modele,
        'taille': taille,
        'prix': prix,
        'photomodele': photomodele
    }

    magasins = []
    with db.connect() as conn:
        with conn.cursor() as cur:
            cur.execute("SELECT code, adresse_magasin FROM CodePostal")
            magasins = cur.fetchall()

    if request.method == "POST":
        nom_destinataire = request.form["nom"]
        prenom_destinataire = request.form["prenom"]
        nom_expediteur = request.form["nom_expediteur"]
        prenom_expediteur = request.form["prenom_expediteur"]
        adressemail = request.form["adressemail"]
        adresse = request.form["adresse"]
        code_postal = request.form['code_postal']
        date_expedition_voulue = request.form['date_expedition']
        message = request.form.get("message", "")

        if '@' not in adressemail:
            erreur = "Adresse email incorrecte. Veuillez saisir une adresse email valide."
            membre = None
            if "numcli" in session:
                membre = {
                    'nom': session.get("nom"),
                    'prenom': session.get("prenom"),
                    'adressemail': session.get("adressemail")
                }
            return render_template('commande.html', bouquet=bouquet, membre=membre, magasins=magasins, 
                                   nom_destinataire=nom_destinataire, prenom_destinataire=prenom_destinataire, 
                                   nom_expediteur=nom_expediteur, prenom_expediteur=prenom_expediteur, 
                                   adressemail=adressemail, adresse=adresse, code_postal=code_postal, 
                                   date_expedition_voulue=date_expedition_voulue, message=message, erreur=erreur)

        with db.connect() as conn:
            with conn.cursor() as cur:
                cur.execute("SELECT code FROM CodePostal WHERE code = %s", (code_postal,))
                existing_code = cur.fetchone()
                if not existing_code:
                    return redirect(url_for("no_magasin", code_postal=code_postal))

                cur.execute("""
                    INSERT INTO Commande (dateExpeditionVoulue, etat, messageDestinaire, 
                    adresseDestinataire, nomDestinataire, adressemail, prenomDestinataire, code_postal, 
                    nomExpediteur, prenomExpediteur, modele, prix, taille)
                    VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                    RETURNING reference_c, codeConfidentiel
                """, (
                    date_expedition_voulue,
                    'En_attente',
                    message,
                    adresse,
                    nom_destinataire,
                    adressemail,
                    prenom_destinataire,
                    code_postal,
                    nom_expediteur,
                    prenom_expediteur,
                    modele,
                    prix,
                    taille,
                ))
                resultat = cur.fetchone()
                if resultat:
                    reference_c = resultat[0]

        return redirect(url_for("paiement", num_commande=reference_c))

    membre = None
    if "numcli" in session:
        membre = {
            'nom': session.get("nom"),
            'prenom': session.get("prenom"),
            'adressemail': session.get("adressemail")
        }

    return render_template('commande.html', bouquet=bouquet, membre=membre, magasins=magasins)


@app.route('/paiement/<int:num_commande>', methods=["GET", "POST"])
def paiement(num_commande):
    if request.method == "POST":
        numero_carte = request.form["numero_carte"]
        date_expiration = request.form["date_expiration"]
        cryptogramme = request.form["cryptogramme"]

        if not (numero_carte and date_expiration and cryptogramme):
            return render_template('paiement.html', erreur="Tous les champs sont obligatoires.", num_commande=num_commande)

        return redirect(url_for('confirmation', num_commande=num_commande))

    return render_template('paiement.html', num_commande=num_commande)


  
@app.route('/confirmation/<int:num_commande>', methods=["GET"])
def confirmation(num_commande):
    with db.connect() as conn:
        with conn.cursor() as cur:
            cur.execute("SELECT codeConfidentiel, modele, taille, prix, nomDestinataire, prenomDestinataire, adresseDestinataire, dateExpeditionVoulue FROM Commande WHERE reference_c = %s", (num_commande,))
            commande = cur.fetchone()
            if commande:
                code_confidentiel, modele, taille, prix, nom_destinataire, prenom_destinataire, adresse_destinataire, date_expedition = commande
            else:
                code_confidentiel = modele = taille = prix = nom_destinataire = prenom_destinataire = adresse_destinataire = date_expedition = None

    return render_template('confirmation.html', num_commande=num_commande, code_confidentiel=code_confidentiel, modele=modele, taille=taille, prix=prix, nom_destinataire=nom_destinataire, prenom_destinataire=prenom_destinataire, adresse_destinataire=adresse_destinataire, date_expedition=date_expedition)

@app.route("/consulter_commande", methods=["GET", "POST"])
def consulter_commande():
    if request.method == "POST":
        reference_c = request.form["reference_c"]
        return redirect(url_for("details_commande", reference_c=reference_c))
    return render_template("consulter_commande.html")


@app.route("/details_commande", methods=["GET", "POST"])
def details_commande():
    if request.method == "POST":
        reference_c = request.form["reference_c"]
        code_confidentiel = request.form["code_confidentiel"]
        with db.connect() as conn:
            with conn.cursor() as cur:
                cur.execute("""
                    SELECT Commande.*, Magasin.adresse AS magasin_adresse, 
                           ModeLivraison.nom AS livreur_nom, 
                           ModeLivraison.prenom AS livreur_prenom, 
                           ModeLivraison.telephone AS livreur_telephone
                    FROM Commande
                    LEFT JOIN CodePostal ON Commande.code_postal = CodePostal.code
                    LEFT JOIN Magasin ON CodePostal.adresse_magasin = Magasin.adresse
                    LEFT JOIN ModeLivraison ON CodePostal.id_livreur = ModeLivraison.id_livreur
                    WHERE Commande.reference_c = %s AND Commande.codeConfidentiel = %s
                """, (reference_c, code_confidentiel))
                commande = cur.fetchone()

        if not commande:
            return render_template("erreur_commande.html")

        livreur = {
            'nom': commande[18], 
            'prenom': commande[19],  
            'telephone': commande[20] 
        } if commande[20] else None  

        return render_template("details_commande.html", commande=commande, livreur=livreur)
    return render_template("consulter_commande.html")


@app.route('/deconnexion')
def deconnexion():
    session.clear()  
    return redirect(url_for('accueil'))


if __name__ == '__main__':
    app.run()  

