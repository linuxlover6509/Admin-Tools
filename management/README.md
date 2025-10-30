# User List

The script allows you to display a list of users with and without sudo that exist in the system.

You can also manage these users using script:
1. Delete (with 3 options)
2. Block

## Usage

Make the script executable 

`chmod +x userList.sh`

Display information about users (you can run without sudo)

`./userList.sh`

Delete or block users (run with sudo)

`sudo ./userList.sh -rm`

### Example

`./userList`

Output:

```
----------------------------------------------
Users: 5
----------------------------------------------
Sudo users: 4

debian
obama
anna_petrova
admin
----------------------------------------------
```
