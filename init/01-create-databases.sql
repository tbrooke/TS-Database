-- Create databases for each application
CREATE DATABASE mtzionchinagrove_dev;
CREATE DATABASE alfresco_dev;
CREATE DATABASE activiti_dev;

-- Grant permissions
GRANT ALL PRIVILEGES ON DATABASE mtzionchinagrove_dev TO postgres;
GRANT ALL PRIVILEGES ON DATABASE alfresco_dev TO postgres;
GRANT ALL PRIVILEGES ON DATABASE activiti_dev TO postgres;
