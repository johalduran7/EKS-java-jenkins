#!/bin/bash

# Create the root project directory
echo "Creating root project directory: john-duran-cicd-demo"
mkdir john-duran-cicd-demo
cd john-duran-cicd-demo

# Create the nested directory structure
echo "Creating nested directory structure..."
mkdir -p src/main/java/com/example/johnduran/cicddemo/model
mkdir -p src/main/java/com/example/johnduran/cicddemo/repository
mkdir -p src/main/java/com/example/johnduran/cicddemo/controller
mkdir -p src/main/resources/static/css
mkdir -p src/main/resources/static/images
mkdir -p src/main/resources/templates
mkdir -p src/test/java/com/example/johnduran/cicddemo

# Create pom.xml
echo "Creating pom.xml..."
cat << 'EOF' > pom.xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>3.2.5</version> <relativePath/> </parent>

    <groupId>com.example.johnduran</groupId>
    <artifactId>john-duran-cicd-demo</artifactId>
    <version>0.0.1-SNAPSHOT</version>
    <name>John Duran's CICD Demo Application</name>
    <description>A simple Java web app for CICD demonstration</description>

    <properties>
        <java.version>17</java.version> </properties>

    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-data-jpa</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-thymeleaf</artifactId>
        </dependency>
        <dependency>
            <groupId>com.h2database</groupId>
            <artifactId>h2</artifactId>
            <scope>runtime</scope>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-devtools</artifactId>
            <scope>runtime</scope>
            <optional>true</optional>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>
    </dependencies>

    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
            </plugin>
        </plugins>
    </build>

</project>
EOF

# Create Java files
echo "Creating Java source files..."
cat << 'EOF' > src/main/java/com/example/johnduran/cicddemo/CicdDemoApplication.java
package com.example.johnduran.cicddemo;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class CicdDemoApplication {

    public static void main(String[] args) {
        SpringApplication.run(CicdDemoApplication.class, args);
    }
}
EOF

cat << 'EOF' > src/main/java/com/example/johnduran/cicddemo/model/Client.java
package com.example.johnduran.cicddemo.model;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;

@Entity
public class Client {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String name;
    private String phone;
    private String email;
    private int age;

    public Client() {
    }

    public Client(String name, String phone, String email, int age) {
        this.name = name;
        this.phone = phone;
        this.email = email;
        this.age = age;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public int getAge() {
        return age;
    }

    public void setAge(int age) {
        this.age = age;
    }

    @Override
    public String toString() {
        return "Client{" +
               "id=" + id +
               ", name='" + name + '\'' +
               ", phone='" + phone + '\'' +
               ", email='" + email + '\'' +
               ", age=" + age +
               '}';
    }
}
EOF

cat << 'EOF' > src/main/java/com/example/johnduran/cicddemo/repository/ClientRepository.java
package com.example.johnduran.cicddemo.repository;

import com.example.johnduran.cicddemo.model.Client;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ClientRepository extends JpaRepository<Client, Long> {
}
EOF

cat << 'EOF' > src/main/java/com/example/johnduran/cicddemo/controller/ClientApiController.java
package com.example.johnduran.cicddemo.controller;

import com.example.johnduran.cicddemo.model.Client;
import com.example.johnduran.cicddemo.repository.ClientRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/clients")
public class ClientApiController {

    private final ClientRepository clientRepository;

    @Autowired
    public ClientApiController(ClientRepository clientRepository) {
        this.clientRepository = clientRepository;
    }

    @GetMapping
    public List<Client> getAllClients() {
        return clientRepository.findAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<Client> getClientById(@PathVariable Long id) {
        Optional<Client> client = clientRepository.findById(id);
        return client.map(ResponseEntity::ok)
                     .orElseGet(() -> ResponseEntity.notFound().build());
    }

    @PostMapping
    public ResponseEntity<Client> createClient(@RequestBody Client client) {
        Client savedClient = clientRepository.save(client);
        return new ResponseEntity<>(savedClient, HttpStatus.CREATED);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Client> updateClient(@PathVariable Long id, @RequestBody Client clientDetails) {
        Optional<Client> clientOptional = clientRepository.findById(id);
        if (clientOptional.isPresent()) {
            Client existingClient = clientOptional.get();
            existingClient.setName(clientDetails.getName());
            existingClient.setPhone(clientDetails.getPhone());
            existingClient.setEmail(clientDetails.getEmail());
            existingClient.setAge(clientDetails.getAge());
            Client updatedClient = clientRepository.save(existingClient);
            return ResponseEntity.ok(updatedClient);
        } else {
            return ResponseEntity.notFound().build();
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteClient(@PathVariable Long id) {
        if (clientRepository.existsById(id)) {
            clientRepository.deleteById(id);
            return ResponseEntity.noContent().build();
        } else {
            return ResponseEntity.notFound().build();
        }
    }
}
EOF

cat << 'EOF' > src/main/java/com/example/johnduran/cicddemo/controller/WebController.java
package com.example.johnduran.cicddemo.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class WebController {

    @GetMapping("/")
    public String home() {
        return "index";
    }
}
EOF

# Create resources files
echo "Creating resource files..."
cat << 'EOF' > src/main/resources/application.properties
# Server port
server.port=8080

# H2 Database configuration (in-memory)
spring.datasource.url=jdbc:h2:mem:john_duran_db;DB_CLOSE_DELAY=-1;DB_CLOSE_ON_EXIT=FALSE
spring.datasource.driverClassName=org.h2.Driver
spring.datasource.username=sa
spring.datasource.password=
spring.jpa.database-platform=org.hibernate.dialect.H2Dialect

# JPA/Hibernate properties
spring.jpa.hibernate.ddl-auto=update # 'update' creates/updates schema based on entities
spring.jpa.show-sql=true # Log SQL queries to console

# Thymeleaf caching (disable for development)
spring.thymeleaf.cache=false
EOF

cat << 'EOF' > src/main/resources/static/css/style.css
body {
    font-family: Arial, sans-serif;
    margin: 0;
    padding: 0;
    color: #333;
    background-image: url('../images/background.jpg'); /* Path to your background image */
    background-size: cover; /* Cover the entire area */
    background-position: center; /* Center the image */
    background-attachment: fixed; /* Keep image fixed when scrolling */
    min-height: 100vh; /* Ensure body takes full viewport height */
    display: flex; /* Use flexbox for centering content */
    flex-direction: column;
    align-items: center;
    justify-content;
}

.container {
    background-color: rgba(255, 255, 255, 0.9); /* Semi-transparent white background */
    padding: 30px;
    border-radius: 10px;
    box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
    width: 90%;
    max-width: 900px;
    margin: 40px auto; /* Center the container with margin */
    box-sizing: border-box; /* Include padding in width */
}

h1 {
    color: #0056b3;
    text-align: center;
    margin-bottom: 30px;
}

h2 {
    color: #007bff;
    margin-top: 30px;
    margin-bottom: 15px;
}

form {
    margin-bottom: 30px;
    padding: 20px;
    border: 1px solid #ddd;
    border-radius: 8px;
    background-color: #f9f9f9;
}

form label {
    display: block;
    margin-bottom: 8px;
    font-weight: bold;
}

form input[type="text"],
form input[type="email"],
form input[type="number"] {
    width: calc(100% - 20px); /* Adjust for padding */
    padding: 10px;
    margin-bottom: 15px;
    border: 1px solid #ccc;
    border-radius: 4px;
}

form button {
    background-color: #28a745;
    color: white;
    padding: 12px 20px;
    border: none;
    border-radius: 4px;
    cursor: pointer;
    font-size: 16px;
}

form button:hover {
    background-color: #218838;
}

table {
    width: 100%;
    border-collapse: collapse;
    margin-top: 20px;
    background-color: #fff;
    border-radius: 8px;
    overflow: hidden; /* For rounded corners on table */
}

table th, table td {
    padding: 12px 15px;
    text-align: left;
    border-bottom: 1px solid #ddd;
}

table th {
    background-color: #007bff;
    color: white;
    text-transform: uppercase;
    font-size: 0.9em;
}

table tr:nth-child(even) {
    background-color: #f2f2f2;
}

table tr:hover {
    background-color: #e9e9e9;
}

.action-buttons button {
    background-color: #dc3545; /* Red for Delete */
    color: white;
    border: none;
    padding: 8px 12px;
    border-radius: 4px;
    cursor: pointer;
    margin-right: 5px;
}

.action-buttons button:hover {
    opacity: 0.9;
}

/* Optional: Add some initial data or messages */
#message {
    color: green;
    font-weight: bold;
    margin-top: 10px;
}
#error {
    color: red;
    font-weight: bold;
    margin-top: 10px;
}
EOF

cat << 'EOF' > src/main/resources/templates/index.html
<!DOCTYPE html>
<html lang="en" xmlns:th="http://www.thymeleaf.org">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>John Duran's Java CICD demo</title>
    <link rel="stylesheet" th:href="@{/css/style.css}">
</head>
<body>
    <div class="container">
        <h1>John Duran's Java CICD demo</h1>

        <h2>Add New Client</h2>
        <form id="clientForm">
            <label for="name">Name:</label>
            <input type="text" id="name" name="name" required><br>

            <label for="phone">Phone:</label>
            <input type="text" id="phone" name="phone" required><br>

            <label for="email">Email:</label>
            <input type="email" id="email" name="email" required><br>

            <label for="age">Age:</label>
            <input type="number" id="age" name="age" required><br>

            <button type="submit">Add Client</button>
            <p id="message"></p>
            <p id="error"></p>
        </form>

        <h2>Client List</h2>
        <table id="clientTable">
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Name</th>
                    <th>Phone</th>
                    <th>Email</th>
                    <th>Age</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                </tbody>
        </table>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', () => {
            const clientForm = document.getElementById('clientForm');
            const clientTableBody = document.querySelector('#clientTable tbody');
            const messageDiv = document.getElementById('message');
            const errorDiv = document.getElementById('error');

            const API_BASE_URL = '/api/clients'; // Our backend API endpoint

            // Function to fetch and display clients
            const fetchClients = async () => {
                try {
                    const response = await fetch(API_BASE_URL);
                    if (!response.ok) {
                        throw new Error(`HTTP error! status: ${response.status}`);
                    }
                    const clients = await response.json();
                    clientTableBody.innerHTML = ''; // Clear existing rows
                    clients.forEach(client => {
                        const row = clientTableBody.insertRow();
                        row.insertCell(0).textContent = client.id;
                        row.insertCell(1).textContent = client.name;
                        row.insertCell(2).textContent = client.phone;
                        row.insertCell(3).textContent = client.email;
                        row.insertCell(4).textContent = client.age;

                        const actionsCell = row.insertCell(5);
                        actionsCell.classList.add('action-buttons');
                        const deleteButton = document.createElement('button');
                        deleteButton.textContent = 'Delete';
                        deleteButton.onclick = () => deleteClient(client.id);
                        actionsCell.appendChild(deleteButton);
                    });
                } catch (error) {
                    console.error('Error fetching clients:', error);
                    errorDiv.textContent = 'Failed to load clients: ' + error.message;
                    messageDiv.textContent = '';
                }
            };

            // Function to add a new client
            clientForm.addEventListener('submit', async (event) => {
                event.preventDefault(); // Prevent default form submission

                const newClient = {
                    name: document.getElementById('name').value,
                    phone: document.getElementById('phone').value,
                    email: document.getElementById('email').value,
                    age: parseInt(document.getElementById('age').value, 10)
                };

                // Basic validation
                if (!newClient.name || !newClient.phone || !newClient.email || isNaN(newClient.age)) {
                    errorDiv.textContent = 'Please fill in all fields correctly.';
                    messageDiv.textContent = '';
                    return;
                }

                try {
                    const response = await fetch(API_BASE_URL, {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/json'
                        },
                        body: JSON.stringify(newClient)
                    });

                    if (!response.ok) {
                        throw new Error(`HTTP error! status: ${response.status}`);
                    }

                    messageDiv.textContent = 'Client added successfully!';
                    errorDiv.textContent = '';
                    clientForm.reset(); // Clear the form
                    await fetchClients(); // Refresh the table
                } catch (error) {
                    console.error('Error adding client:', error);
                    errorDiv.textContent = 'Failed to add client: ' + error.message;
                    messageDiv.textContent = '';
                }
            });

            // Function to delete a client
            const deleteClient = async (id) => {
                if (!confirm(`Are you sure you want to delete client ID: ${id}?`)) {
                    return; // User cancelled
                }
                try {
                    const response = await fetch(`${API_BASE_URL}/${id}`, {
                        method: 'DELETE'
                    });

                    if (!response.ok) {
                        throw new Error(`HTTP error! status: ${response.status}`);
                    }

                    messageDiv.textContent = `Client ID ${id} deleted successfully!`;
                    errorDiv.textContent = '';
                    await fetchClients(); // Refresh the table
                } catch (error) {
                    console.error('Error deleting client:', error);
                    errorDiv.textContent = `Failed to delete client ID ${id}: ` + error.message;
                    messageDiv.textContent = '';
                }
            };

            // Initial fetch of clients when the page loads
            fetchClients();
        });
    </script>
</body>
</html>
EOF

# Create a dummy test file (optional, but good practice for Maven)
echo "Creating dummy test file..."
touch src/test/java/com/example/johnduran/cicddemo/CicdDemoApplicationTests.java

echo ""
echo "==================================================="
echo "Project structure and files created successfully!"
echo "==================================================="
echo "REMEMBER TO PLACE YOUR 'background.jpg' FILE IN:"
echo "  john-duran-cicd-demo/src/main/resources/static/images/"
echo ""
echo "NEXT STEPS:"
echo "1. Change into the project directory: cd john-duran-cicd-demo"
echo "2. Build the project: mvn clean install"
echo "3. Run the application: java -jar target/john-duran-cicd-demo-0.0.1-SNAPSHOT.jar"
echo "4. Access it in your browser at: http://localhost:8080/"
echo "==================================================="
