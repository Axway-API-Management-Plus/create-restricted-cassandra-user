# Script to create limited Cassandra-Users

The purpose of this small script is to create a Cassandra-User which has limited access to a given number of tables in the same keyspace.  

The reason is the following architectural requirement:
![API-Manager Swagger-Promote overview]( https://github.com/Axway-API-Management-Plus/create-restricted-cassandra-user/doc/architecture_overview.png )

To goal is to separate the OAuth-AuthZ-Server part from the API-Manager runtime to avoid someone who has access to the API-Manager can generate access token.  
But this separation only makes sense, if both API-Gateway-Instances are using a different cassandra-user with restricted access permissions.  
The Authorization-Server will have write permission to modify entries in the OAuth-Tables: oauth_....
The API-Manager will have read permission only to just load access tokens.  

As Cassandra doesn't support it easily to restrict permissions on a per table basis, this script is creating these two kind of users.   

## Usage of the script:
```
Usage: ./create_restricted_user.sh -m <apim|authz> -k <your-keyspace> -u <user_to_be_created> -p <password_to_use> -au cassandra -ap cassandra

-m, --mode		Mode: apim: Read-Only access to OAuth-Tables | authz: Write access to OAuth-Tables
-k, --keyspace		Cassandra keyspace which is used by API-Manager & AuthZ-Server
-u, --username		A new Cassandra user with this username will be created.
-p, --password		A new Cassandra user with this password will be created.
-au, --adminUser  	Username having admin-permissions to create new users.
-ap, --adminPassword	Password of user having admin-permissions to create new users.
-cqlsh			Path to cqlsh - Optional if cqlsh is in the path and executable

Examples: 
./create_restricted_user.sh -m apim -k x65cd4036_751f_433e_acde_a8008b89444c_group_2 -u apim_user -p changeme -au cassandra -ap cassandra
./create_restricted_user.sh -m apim -k x65cd4036_751f_433e_acde_a8008b89444c_group_2 -u apim_user -p changeme -au cassandra -ap cassandra -cqlsh ./bin/cqlsh
```


## Install
Just clone this project or download the Shell-Script.

## Changelog
- 1.0.0 - 29.03.2019
  - Initial version

## Limitations/Caveats

## Contributing

Please read [Contributing.md](https://github.com/Axway-API-Management-Plus/Common/blob/master/Contributing.md) for details on our code of conduct, and the process for submitting pull requests to us.

## Team

![alt text][Axwaylogo] Axway Team

[Axwaylogo]: https://github.com/Axway-API-Management/Common/blob/master/img/AxwayLogoSmall.png  "Axway logo"


## License
[Apache License 2.0](/LICENSE)
