import pyodbc
import pandas as pd

# Define the connection parameters
server = 'VHACDWA01.VHA.MED.VA.GOV'
database = 'VHA104_Finance'

# Connect to the SQL Server database using Windows Authentication
conn = pyodbc.connect(
    f'DRIVER={{SQL Server}};'
    f'SERVER={server};'
    f'DATABASE={database};'
    'Trusted_Connection=Yes;'
)

# Define the SQL query
query = "SELECT * FROM Dflt.tblFLR_Allocation"

# Use pandas to read the SQL query into a DataFrame
df = pd.read_sql(query, conn)

# Close the connection
conn.close()

# Display the DataFrame in a tabular format
print(df)