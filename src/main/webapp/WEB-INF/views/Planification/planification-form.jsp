<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Planification des Transports</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f2f2f2;
            margin: 0;
            padding: 0;
        }

        h2 {
            text-align: center;
            color: #333;
            margin-top: 30px;
        }

        form {
            background-color: #fff;
            width: 300px;
            margin: 40px auto;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.2);
        }

        label {
            display: block;
            margin-bottom: 8px;
            color: #555;
            font-weight: bold;
        }

        input[type="date"] {
            width: 100%;
            padding: 8px;
            margin-bottom: 20px;
            border: 1px solid #ccc;
            border-radius: 4px;
            box-sizing: border-box;
        }

        button {
            width: 100%;
            padding: 10px;
            background-color: #4CAF50;
            border: none;
            border-radius: 4px;
            color: white;
            font-size: 16px;
            cursor: pointer;
        }

        button:hover {
            background-color: #45a049;
        }

        .error {
            color: red;
            text-align: center;
            margin-bottom: 15px;
        }
    </style>
</head>
<body>
<h2>Planification des Transports</h2>

<c:if test="${not empty error}">
    <div class="error">${error}</div>
</c:if>

<form action="${pageContext.request.contextPath}/planification/planifier" method="post">
    <label for="date">Choisir la date :</label>
    <input type="date" id="date" name="date" required>

    <button type="submit">Planifier</button>
</form>

</body>
</html>