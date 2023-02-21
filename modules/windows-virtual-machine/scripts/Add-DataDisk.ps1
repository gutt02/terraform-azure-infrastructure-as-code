Initialize-Disk -Number 2 -PartitionStyle GPT
New-Partition -DiskNumber 2 -DriveLetter F -UseMaximumSize
Format-Volume -DriveLetter F -FileSystem NTFS -NewFileSystemLabel DataDisk1 -Confirm:$false -Force
