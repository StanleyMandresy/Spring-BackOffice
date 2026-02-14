<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Liste des véhicules</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f4f4;
            margin: 0;
            padding: 20px;
        }
        .container {
            max-width: 1000px;
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
        .header-actions {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }
        .btn-add {
            background-color: #4CAF50;
            color: white;
            padding: 10px 20px;
            text-decoration: none;
            border-radius: 4px;
        }
        .btn-add:hover {
            background-color: #45a049;
        }
        .btn-edit {
            background-color: #007bff;
            color: white;
            padding: 5px 10px;
            text-decoration: none;
            border-radius: 3px;
            margin-right: 5px;
            font-size: 12px;
        }
        .btn-edit:hover {
            background-color: #0056b3;
        }
        .btn-delete {
            background-color: #dc3545;
            color: white;
            padding: 5px 10px;
            text-decoration: none;
            border-radius: 3px;
            font-size: 12px;
            border: none;
            cursor: pointer;
        }
        .btn-delete:hover {
            background-color: #c82333;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        th, td {
            padding: 12px;
            text-align: left;
            border-bottom: 1px solid #ddd;
        }
        th {
            background-color: #4CAF50;
            color: white;
        }
        tr:hover {
            background-color: #f5f5f5;
        }
        .type-carburant {
            display: inline-block;
            padding: 3px 8px;
            border-radius: 3px;
            font-size: 12px;
            font-weight: bold;
        }
        .type-d {
            background-color: #ffc107;
            color: #000;
        }
        .type-es {
            background-color: #28a745;
            color: #fff;
        }
        .type-s {
            background-color: #17a2b8;
            color: #fff;
        }
        .type-e {
            background-color: #6f42c1;
            color: #fff;
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
        .no-data {
            text-align: center;
            padding: 20px;
            color: #666;
        }
        .modal {
            display: none;
            position: fixed;
            z-index: 1;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0,0,0,0.4);
        }
        .modal-content {
            background-color: #fefefe;
            margin: 15% auto;
            padding: 20px;
            border: 1px solid #888;
            width: 30%;
            border-radius: 5px;
            text-align: center;
        }
        .modal-buttons {
            margin-top: 20px;
        }
        .modal-btn-yes {
            background-color: #dc3545;
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            margin-right: 10px;
        }
        .modal-btn-no {
            background-color: #6c757d;
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header-actions">
            <h1>Liste des véhicules</h1>
            <a href="${pageContext.request.contextPath}/vehicule/form" class="btn-add">+ Ajouter</a>
        </div>
        
        <c:if test="${not empty error}">
            <div class="error">${error}</div>
        </c:if>
        
        <c:if test="${not empty success}">
            <div class="success">${success}</div>
        </c:if>
        
        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Référence</th>
                    <th>Nombre de places</th>
                    <th>Type de carburant</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <c:choose>
                    <c:when test="${not empty vehicules}">
                        <c:forEach var="vehicule" items="${vehicules}">
                            <tr>
                                <td>${vehicule.id}</td>
                                <td>${vehicule.reference}</td>
                                <td>${vehicule.nbrPlace}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${vehicule.typeCarburant == 'D'}">
                                            <span class="type-carburant type-d">Diesel</span>
                                        </c:when>
                                        <c:when test="${vehicule.typeCarburant == 'ES'}">
                                            <span class="type-carburant type-es">Essence</span>
                                        </c:when>
                                        <c:when test="${vehicule.typeCarburant == 'S'}">
                                            <span class="type-carburant type-s">Super</span>
                                        </c:when>
                                        <c:when test="${vehicule.typeCarburant == 'E'}">
                                            <span class="type-carburant type-e">Électrique</span>
                                        </c:when>
                                        <c:otherwise>
                                            ${vehicule.typeCarburant}
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <a href="${pageContext.request.contextPath}/vehicule/edit?id=${vehicule.id}" class="btn-edit">Modifier</a>
                                    <button onclick="showDeleteModal(${vehicule.id}, '${vehicule.reference}')" class="btn-delete">Supprimer</button>
                                </td>
                            </tr>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <tr>
                            <td colspan="5" class="no-data">Aucun véhicule trouvé</td>
                        </tr>
                    </c:otherwise>
                </c:choose>
            </tbody>
        </table>
        
        <c:if test="${not empty total}">
            <p style="text-align: right; margin-top: 20px;">Total: ${total} véhicule(s)</p>
        </c:if>
    </div>
    
    <!-- Modal de confirmation de suppression -->
    <div id="deleteModal" class="modal">
        <div class="modal-content">
            <h3>Confirmer la suppression</h3>
            <p>Êtes-vous sûr de vouloir supprimer le véhicule <span id="vehiculeRef"></span> ?</p>
            <p style="color: red; font-size: 14px;">Cette action est irréversible.</p>
            <div class="modal-buttons">
                <form id="deleteForm" action="${pageContext.request.contextPath}/vehicule/delete" method="post" style="display: inline;">
                    <input type="hidden" name="id" id="deleteId">
                    <button type="submit" class="modal-btn-yes">Oui, supprimer</button>
                </form>
                <button onclick="hideDeleteModal()" class="modal-btn-no">Annuler</button>
            </div>
        </div>
    </div>
    
    <script>
        function showDeleteModal(id, reference) {
            document.getElementById('deleteId').value = id;
            document.getElementById('vehiculeRef').textContent = reference;
            document.getElementById('deleteModal').style.display = 'block';
        }
        
        function hideDeleteModal() {
            document.getElementById('deleteModal').style.display = 'none';
        }
        
        window.onclick = function(event) {
            var modal = document.getElementById('deleteModal');
            if (event.target == modal) {
                modal.style.display = 'none';
            }
        }
    </script>
</body>
</html>