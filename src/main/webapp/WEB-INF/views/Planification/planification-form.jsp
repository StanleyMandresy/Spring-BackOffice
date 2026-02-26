<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Planification des Transports</title>
</head>
<body>
<h2>Planification des Transports</h2>

<c:if test="${not empty error}">
    <div style="color:red;">${error}</div>
</c:if>

<form action="${pageContext.request.contextPath}/planification/planifier" method="post">
    <label for="date">Choisir la date :</label>
    <input type="date" id="date" name="date" required>

    <button type="submit">Planifier</button>
</form>

</body>
</html>