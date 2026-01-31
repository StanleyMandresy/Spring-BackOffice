package com.spring.BackOffice.model;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

public class User {

    private Long id;
    private String nom;

    private String password;

    public User() { }

    public User(String nom, String email, String password) {
        this.nom = nom;
        this.password = password;
    }

    // -------------------
    // Méthodes statiques avec JdbcTemplate
    // -------------------
    
    public static List<User> findAll(JdbcTemplate jdbcTemplate) {
        String sql = "SELECT * FROM users";
        return jdbcTemplate.query(sql, new UserRowMapper());
    }


    public void save(JdbcTemplate jdbcTemplate) {
        String sql = "INSERT INTO users (username, password) VALUES (?, ?)";
        jdbcTemplate.update(sql, this.nom,  this.password);
        // Optionnel : récupérer l'id avec KeyHolder si nécessaire
    }

    public static User authenticate(JdbcTemplate jdbcTemplate, String email, String password) {
        String sql = "SELECT * FROM users WHERE username = ? AND password = ?";
        List<User> users = jdbcTemplate.query(sql, new Object[]{email, password}, new UserRowMapper());
        return users.isEmpty() ? null : users.get(0);
    }

    // -------------------
    // RowMapper pour JdbcTemplate
    // -------------------
    private static class UserRowMapper implements RowMapper<User> {
        @Override
        public User mapRow(ResultSet rs, int rowNum) throws SQLException {
            User u = new User();
            u.setId(rs.getLong("id"));
            u.setNom(rs.getString("username"));
          
            u.setPassword(rs.getString("password"));
            return u;
        }
    }

    // -------------------
    // Getters et setters
    // -------------------
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getNom() { return nom; }
    public void setNom(String nom) { this.nom = nom; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    @Override
    public String toString() {
        return "User{id=" + id + ", nom='" + nom + "', password='" + password + "'}";
    }
}
