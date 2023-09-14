-- Creates Database
CREATE DATABASE System_info;

-- Uses Database
USE System_info;

-- Creates Table
CREATE TABLE Performance(
System_Usage datetime,
Cpu_Usage numeric(5,2),
Memory_Usage numeric(5,2),
Cpu_Interrupts numeric,
Cpu_Calls numeric,
Memory_Used numeric,
Memore_Free numeric,
Bytes_Sent numeric,
Bytes_Recieved numeric,
Disk_Usage numeric(5,2)
);
