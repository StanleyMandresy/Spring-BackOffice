package com.spring.BackOffice.model;

public class User {
    private String nom;
    private String email;
    private int age;
    private boolean actif;


    // Constructeur par défaut (OBLIGATOIRE)
    public User() {
        System.out.println("User() créé");
    }
    
    // Getters et setters
    public String getNom() { return nom; }
    public void setNom(String nom) { this.nom = nom; }
    
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    
    public int getAge() { return age; }
    public void setAge(int age) { this.age = age; }
    
    public boolean isActif() { return actif; }
    public void setActif(boolean actif) { this.actif = actif; }
    
    @Override
    public String toString() {
        return "User[nom=" + nom + ", email=" + email + 
               ", age=" + age + ", actif=" + actif + "]";
    }
}