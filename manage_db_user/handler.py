import os
import psycopg2
import boto3

def lambda_handler(event, context):
    # Retrieve database connection details from environment variables
    host = os.environ['DB_HOST']
    port = os.environ['DB_PORT']
    user = os.environ['DB_USER']
    password = os.environ['DB_PASSWORD']
    
    # Name of the new database to create
    new_db_name = 'ItemDB'
    
    try:
        # Connect to the default 'postgres' database
        conn = psycopg2.connect(
            host=host,
            port=port,
            user=user,
            password=password,
            database='postgres'
        )
        conn.autocommit = True
        
        # Create a cursor
        cur = conn.cursor()
        
        # Check if the database already exists
        cur.execute(f"SELECT 1 FROM pg_database WHERE datname = '{new_db_name}'")
        exists = cur.fetchone()
        
        if not exists:
            # Create the new database
            cur.execute(f'CREATE DATABASE "{new_db_name}"')
            print(f"Database '{new_db_name}' created successfully")
        else:
            print(f"Database '{new_db_name}' already exists")
        
        # Close the cursor and connection
        cur.close()
        conn.close()
        
        return {
            'statusCode': 200,
            'body': f"Database operation for '{new_db_name}' completed successfully"
        }
    
    except Exception as e:
        print(f"Error: {str(e)}")
        return {
            'statusCode': 500,
            'body': f"An error occurred: {str(e)}"
        }
