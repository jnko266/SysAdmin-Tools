#!/usr/bin/env python3
import sqlite3
import subprocess
import time
import uuid
import re

# Database setup
db_name = '/mnt/data/temp_readings.sqlite'

# Deletion settings
days_to_keep = 365 # Change this to specify the number of days to keep data
delete_old_records = 1  # Set to 1 to enable deletion of old records

# Create a connection to the SQLite database
conn = sqlite3.connect(db_name)
cursor = conn.cursor()

# Create table for storing readings
create_table_query = """
CREATE TABLE IF NOT EXISTS temperature_readings (
    id TEXT PRIMARY KEY,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    vcgencmd_temp TEXT,
    pwm_values TEXT,
    cooling_state TEXT
);
"""

# Create an index on the timestamp column for faster deletes
create_index_query = """
CREATE INDEX IF NOT EXISTS idx_timestamp ON temperature_readings(timestamp);
"""

# Execute the queries
cursor.execute(create_table_query)
cursor.execute(create_index_query)

# Commit the changes and close the connection
conn.commit()
conn.close()

def delete_old_data():
    """Function to delete data older than specified number of days."""
    try:
        conn = sqlite3.connect(db_name)
        cursor = conn.cursor()

        delete_query = """
        DELETE FROM temperature_readings 
        WHERE timestamp < datetime('now', '-{} days');
        """.format(days_to_keep)

        cursor.execute(delete_query)
        conn.commit()
    except Exception as e:
        print(f"Error deleting old data: {e}")
    finally:
        if conn:
            conn.close()

def collect_data():
    """Function to collect data from system commands and save to SQLite DB."""
    try:
        # Database connection
        conn = sqlite3.connect(db_name)
        cursor = conn.cursor()

        while True:
            # Delete old data if enabled
            if delete_old_records:
                delete_old_data()
            
            # Generate a new UUID for each record
            record_id = str(uuid.uuid4())
             
            # Collect data from system commands
            vcgencmd_temp = subprocess.getoutput('vcgencmd measure_temp')
            pwm_values = subprocess.getoutput('cat /sys/class/hwmon/hwmon*/*pwm*')
            cooling_state = subprocess.getoutput('cat /sys/class/thermal/cooling_device*/cur_state')
            
			# Extract numeric temperature value using regex
            match = re.search(r"temp=([\d.]+)'C", vcgencmd_temp)
            if match:
                vcgencmd_temp = match.group(1)
            else:
                vcgencmd_temp = ""  # Or handle the error as you prefer

            # Prepare INSERT query
            insert_query = "INSERT INTO temperature_readings (id, vcgencmd_temp, pwm_values, cooling_state) VALUES (?, ?, ?, ?)"

            # Execute the query
            cursor.execute(insert_query, (record_id, vcgencmd_temp, pwm_values, cooling_state))

            # Commit the transaction
            conn.commit()

            # Wait for 10 seconds before next reading
            time.sleep(10)

    except Exception as e:
        print(f"An error occurred: {e}")
    finally:
        # Close the database connection
        if conn:
            conn.close()

# Display the Python function
collect_data()
