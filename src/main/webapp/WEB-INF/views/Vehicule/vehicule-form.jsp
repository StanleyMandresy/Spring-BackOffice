<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>${empty vehicule ? 'Ajouter' : 'Modifier'} un véhicule</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f4f4;
            margin: 0;
            padding: 20px;
        }
        .container {
            max-width: 600px;
            margin: auto;
            background: white;
            padding: 20px;
            border-radius: 5px;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
        }
        h1 {
            color: #333;
            text-align: center;
        }
        .form-group {
            margin-bottom: 15px;
        }
        label {
            display: block;
            margin-bottom: 5px;
            font-weight: bold;
        }
        input[type="text"],
        input[type="number"],
        select {
            width: 100%;
            padding: 8px;
            border: 1px solid #ddd;
            border-radius: 4px;
            box-sizing: border-box;
        }
        .btn-submit {
            background-color: ${empty vehicule ? '#4CAF50' : '#007bff'};
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 16px;
        }
        .btn-submit:hover {
            background-color: ${empty vehicule ? '#45a049' : '#0056b3'};
        }
        .btn-cancel {
            background-color: #6c757d;
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 16px;
            text-decoration: none;
            display: inline-block;
        }
        .btn-cancel:hover {
            background-color: #5a6268;
        }
        .error {
            color: red;
            margin-bottom: 10px;
            padding: 10px;
            background-color: #f8d7da;
            border-radius: 4px;
        }
        .success {
            color: green;
            margin-bottom: 10px;
            padding: 10px;
            background-color: #d4edda;
            border-radius: 4px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>${empty vehicule ? 'Ajouter' : 'Modifier'} un véhicule</h1>
        
        <c:if test="${not empty error}">
            <div class="error">${error}</div>
        </c:if>
        
        <c:if test="${not empty success}">
            <div class="success">${success}</div>
        </c:if>
        
        <form action="${pageContext.request.contextPath}/vehicule/save" method="post">
            <c:if test="${not empty vehicule}">
                <input type="hidden" name="id" value="${vehicule.id}">
            </c:if>
            
            <div class="form-group">
                <label for="reference">Référence:</label>
                <input type="text" id="reference" name="reference" value="${vehicule.reference}" required>
            </div>
            
            <div class="form-group">
                <label for="nbrPlace">Nombre de places:</label>
                <input type="number" id="nbrPlace" name="nbrPlace" min="1" value="${vehicule.nbrPlace}" required>
            </div>
            
            <div class="form-group">
                <label for="typeCarburant">Type de carburant:</label>
                <select id="typeCarburant" name="typeCarburant" required>
                    <option value="">Sélectionnez</option>
                    <option value="D" ${vehicule.typeCarburant == 'D' ? 'selected' : ''}>Diesel</option>
                    <option value="ES" ${vehicule.typeCarburant == 'ES' ? 'selected' : ''}>Essence</option>
                    <option value="S" ${vehicule.typeCarburant == 'S' ? 'selected' : ''}>Super</option>
                    <option value="E" ${vehicule.typeCarburant == 'E' ? 'selected' : ''}>Électrique</option>
                </select>
            </div>
            
            <div class="form-group" style="text-align: center;">
                <button type="submit" class="btn-submit">
                    ${empty vehicule ? 'Ajouter' : 'Mettre à jour'}
                </button>
                <a href="${pageContext.request.contextPath}/vehicule/list-view" class="btn-cancel">Annuler</a>
            </div>
        </form>
    </div>
</body>
</html>