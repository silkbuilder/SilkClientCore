# SilkClient Core Installation Guide

This guide provides step-by-step instructions for installing, configuring, and starting SilkBuilder Core, a web application that runs on Apache Tomcat.

Learn more about SilkBuilder [here](https://silkbuilder.com).

## System Requirements

To ensure compatibility and smooth operation, verify that your environment meets the following prerequisites:

- **Apache Tomcat**: Version 10 or higher
- **Java**: Version 17 or higher
- **Database**: One of the following supported relational databases:
  - MySQL
  - PostgreSQL
  - Microsoft SQL Server
  - Oracle

**Note 1**: The /WEB-INF/lib folder contains Java drivers for the supported databases. You can remove or replace these drivers with the ones of your preference.

- MySQL: mysql-connector-j-9.1.0.jar
- MS SQL Server: mssql-jdbc-12.8.1.jre11.jar
- PostgreSQL: postgresql-42.7.5.jar
- Oracle: ojdbc11.jar

**Note 2**: Ensure your database is installed correctly, accessible, and configured with the necessary permissions for the application user.

## Installation Steps

1. **Download the Repository**:
   - Navigate to the repository main page and click the "code" button.
   - Download the repository as a ZIP file.

2. **Unzip the Contents**:
   - Extract the ZIP file to a temporary directory on your server.

3. **Initialize the Database Structure**:
   - Use the provided SQL scripts. 

4. **Deploy to Tomcat**:
   - Copy the extracted contents into the application folder in your Tomcat webapps directory, which hosts SilkBuilder Core.
   - Tomcat will automatically deploy the application upon startup or restart.

**Tip**: If you're deploying to a production environment, consider configuring an SSL connection.

## Database Structure

The folder ```/WEB-INF/sql``` contains the SQL scripts to initialize the SilkBuiderCore database. A file exists for every supported database:

* MySQL: SilkClient-core-mysql.sql
* MS SQL Server: SilkClient-core-mssql.sql
* PostgreSQL: SilkClient-core-pgsql.sql
* Oracle: SilkClient-core-oracle.sql

It is recommended to initialize the database before configuring the Tomcat application.

## Application Configuration

All configuration is done in the `/WEB-INF/applicationContext.xml` file within your deployed webapp directory. This Spring configuration file sets up encryption and database connections.

### Step 1: Configure CryptLoader

The CryptLoader handles encryption for sensitive data. Provide a strong password and salt to secure the encryption process.

Edit the bean as follows:

```xml
<bean id="CryptLoader" class="com.oopsclick.silk.security.CryptLoader">
    <constructor-arg name="secure1" value="[your-strong-password]" />
    <constructor-arg name="secure2" value="[your-salt-string]" />
		<constructor-arg name="secure3" value="core" />
</bean>
```

- Replace `[your-strong-password]` with a secure, complex password.
- Replace `[your-salt-string]` with a unique salt value (e.g., a random string of at least 16 characters).

**Security Note**: Use a password manager to generate and store these values. Never commit them to version control.

### Step 2: Configure Database Source and Controller

Set up the data source for your chosen database and link it to the SilkSqlController.

First, define the data source bean:

```xml
<bean id="[data-source-id]" class="org.springframework.jdbc.datasource.DriverManagerDataSource">
    <property name="driverClassName" value="[database-driver-class]" />
    <property name="url" value="[database-jdbc-url]" />
    <property name="username" value="[database-username]" />
    <property name="password" value="[database-password]" />
</bean>
```

- Replace `[data-source-id]` with a unique ID (e.g., `silkDataSource`).
- `[database-driver-class]`: Use the appropriate JDBC driver class. The Examples below are pre-installed:
  - MySQL: `com.mysql.cj.jdbc.Driver`
  - PostgreSQL: `org.postgresql.Driver`
  - MS SQL Server: `com.microsoft.sqlserver.jdbc.SQLServerDriver`
  - Oracle: `oracle.jdbc.OracleDriver`
- `[database-jdbc-url]`: The JDBC connection URL, e.g.:
  - MySQL: `jdbc:mysql://[dbhost]:3306/[database]?useSSL=false`
  - MS SQL Server: `jdbc:sqlserver://[dbhost]:1433;databaseName=[database];encrypt=false;`
  - PostgreSQL: `jdbc:postgresql://[dbhost]:5432/[database]`
  - Oracle: `jdbc:oracle:thin:@[dbhost]:1521/[service_name]`
- `[database-username]` and `[database-password]`: Credentials for a database user with read/write access. The user should have access to create functions.

Next, configure the SilkSqlController bean and reference the data source:

```xml
<bean id="SilkSqlController" class="com.oopsclick.silk.dbo.SqlController">
    <property name="dataSource" ref="[data-source-id]" />
    <property name="translatorIn" value="writeLanguage" />
    <property name="translatorOut" value="readLanguage" />
    <property name="silkDatabaseID" value="[database-engine-id]" />
</bean>
```

- Replace `[data-source-id]` with the ID you defined earlier.
- `[database-engine-id]`: Select the numeric ID matching your target database:
  - 1 - MS SQL Server
  - 2 - MySQL
  - 3 - PostgreSQL
  - 4 - Oracle


## Starting the Application

1. **Restart Tomcat**:
   - Restart your Tomcat server to apply the changes and deploy the application.
   - On Linux/Mac: Use commands like `sudo systemctl restart tomcat` or `./catalina.sh restart` in the Tomcat bin directory.
   - On Windows: Use the Tomcat service manager or restart via the command line.
2. **Access the Application**:
   - Open a web browser and navigate to the application's URL, e.g., `http://your-server:8080/` if using the ROOT folder, or `http://your-server:8080/your-application/` (adjust for your Tomcat port and context path).
   - You should see the SilkClient welcome page with the message "Expecting code synchronization."

### Setting Up Synchronization Token

This section guides you through configuring a synchronization token for SilkClient Core. The token enables secure synchronization of application code between SilkBuilder and SilkClient. It acts as a shared secret to authenticate and link your environments.

#### Prerequisites
- SilkBuilder Core must be installed and running (as per the main installation guide).
- Access to the deployed webapp directory on your Tomcat server.
- A secure method to generate a unique token (e.g., a UUID generator tool).

**Security Note**: Treat the synchronization token like a password. Use a strong, randomly generated string (at least 32 characters) to prevent unauthorized access. Never share it publicly or commit it to version control.

#### Configuration Steps

1. **Navigate to the WEB-INF Directory**:
   - Locate the `/WEB-INF/` folder within your deployed SilkBuilder webapp (e.g., `tomcat/webapps/silkclient/WEB-INF/`).

2. **Create the sync.token File**:
   - Create a new plain text file named `sync.token` in this directory.
   - Open the file in a text editor (e.g., Notepad, Vim, or Nano).

3. **Add the Synchronization Token**:
   - Insert a single line of text containing your secure token string.
     - Example: Use a UUID like `123e4567-e89b-12d3-a456-426614174000` (generate your own using tools like `uuidgen` on Linux/Mac or online generators).
     - Ensure there are **no spaces, carriage returns, or extra lines**. The file should contain only the token string.
   - Save and close the file.

4. **Configure the Target Host in SilkBuilder**:
   - Log in to your SilkBuilder environment (via the web interface).
   - Open the System's setup option where you can define a "Target Host."
   - When configuring the target host, enter the same token string as the value for the Target Host synchronization setting.
   - Save the changes.

5. **Verify and Enable Synchronization**:
   - Test synchronization: In SilkBuilder, initiate a sync with SilkClient. The token will authenticate the connection, allowing code updates to flow securely.
   - Monitor logs for any errors related to token mismatch or authentication failures.

#### Troubleshooting
- **File Not Found or Permission Issues**: Ensure the `sync.token` file is readable by the Tomcat user. Check file permissions (e.g., `chmod 644 sync.token` on Unix-like systems).
- **Synchronization Fails**: Verify the token matches exactly between the file and the SilkBuilder settings (case-sensitive). Regenerate and reapply if needed.
- **Token Security**: If compromised, immediately generate a new token, update the file and settings, and restart the application.

## Troubleshooting

- **Tomcat Deployment Issues**: Check Tomcat logs (e.g., `catalina.out`) for errors during startup.
- **Database Connection Errors**: Verify JDBC details, firewall rules, and database availability.

If you encounter issues, consult the Tomcat documentation or your database vendor's guides for further assistance. For application-specific support, refer to the [SilkBuilder](https:docs.silkbuilder.com) documentation.

