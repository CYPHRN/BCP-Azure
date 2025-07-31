# BCP-Azure

PowerShell scripts for high-performance SQL Server data export and import using the BCP (Bulk Copy Program) utility.
Designed for efficient bulk data operations with Azure SQL Database and SQL Server instances.

## Features

- **High-performance bulk operations** with configurable packet and batch sizes
- **Flexible authentication** - Windows Authentication or SQL Server Authentication
- **Progress monitoring** with file size reporting and duration tracking
- **Error handling** with detailed logging and exit codes
- **Customizable delimiters** for CSV and other text formats
- **Conditional exports** with WHERE clause support
- **Auto-directory creation** for output files

## Scripts

### 104-export.ps1

Exports data from SQL Server tables to text files using BCP.

**Key Parameters:**

- `-Server`: SQL Server instance name
- `-Database`: Source database name
- `-SourceTable`: Table to export (format: `[SCHEMA].[TABLE]`)
- `-OutputFile`: Destination file path
- `-WhereClause`: Optional filter conditions
- `-UseWindowsAuth`: Switch between Windows Auth (default: false) and SQL Auth
- `-FieldTerminator`: Field separator (default: comma)
- `-PacketSize`: Network packet size for performance tuning (default: 65536)

### 105-import.ps1

Imports data from text files into SQL Server tables using BCP.

**Key Parameters:**

- `-Server`: SQL Server instance name
- `-Database`: Target database name
- `-DestinationTable`: Target table (format: `[SCHEMA].[TABLE]`)
- `-InputFile`: Source file path
- `-UseWindowsAuth`: Switch between Windows Auth (default: true) and SQL Auth
- `-FieldTerminator`: Field separator (default: comma)
- `-BatchSize`: Rows per batch for transaction control (default: 50,000)
- `-PacketSize`: Network packet size for performance tuning (default: 65536)

## Usage Examples

### Export Data

```powershell
# Export with Windows Authentication
.\104-export.ps1 -Server "myserver.database.windows.net" -Database "MyDB" -SourceTable "[dbo].[Users]" -OutputFile "C:\exports\users.csv" -UseWindowsAuth

# Export with SQL Authentication and WHERE clause
.\104-export.ps1 -Server "myserver.database.windows.net" -Database "MyDB" -SourceTable "[dbo].[Orders]" -OutputFile "C:\exports\recent_orders.csv" -Username "dbuser" -Password "mypassword" -WhereClause "OrderDate >= '2024-01-01'"
```

### Import Data

```powershell
# Import with Windows Authentication
.\105-import.ps1 -Server "localhost" -Database "MyDB" -DestinationTable "[dbo].[ImportedData]" -InputFile "C:\data\import.csv"

# Import with custom batch size and SQL Authentication
.\105-import.ps1 -Server "myserver.database.windows.net" -Database "MyDB" -DestinationTable "[staging].[BulkData]" -InputFile "C:\data\large_file.csv" -UseWindowsAuth:$false -Username "dbuser" -Password "mypassword" -BatchSize 100000
```

## Performance Tuning

- **PacketSize**: Increase for faster network transfers (default: 65536)
- **BatchSize** (import only): Larger batches = fewer transactions but more memory usage
- **Network**: Use high-bandwidth connections for large files
- **File Format**: Character format (`-c`) is used for maximum compatibility
