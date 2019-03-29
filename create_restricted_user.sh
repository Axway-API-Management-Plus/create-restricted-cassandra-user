#!/bin/sh

apiManagerTables="\
api_portal_apiorgpolicybindings \
api_portal_portalexports \
api_portal_portalapiaccessstore \
api_portal_portalactionqueue \
api_portal_portalidentitystore \
oauthconfig_serverconfig \
api_portal_portalapiquotadetailsstore \
api_server_portaloauthresourcesstore \
api_server_portaloauthstore \
api_portal_portaluserstore \
api_portal_portalapimethod \
api_portal_portaltimestamp \
api_portal_portalapiquotastore \
api_server_portalapikeystore \
api_portal_portaluserstoreldap \
api_server_portalexternalclientstore \
api_portal_portalorganizationstoreldap \
api_portal_portalvirtualizedapimethod \
api_portal_portalapi \
backendurls_urls \
api_portal_portalvirtualizedapi \
api_portal_portalregistrationtoken \
api_portal_portalorganizationstore \
api_portal_apiapppolicybindings \
kps_schema \
oauth_clientrefreshtokens \
api_portal_portalconfigstore \
api_portal_portalremotehost \
api_portal_portalapplicationpermissionstore \
api_portal_apipolicyparameters \
api_portal_portalapiquotaconstraintstore \
counter_table \
counter_snapshot \
oauth_clientaccesstokens \
api_server_portalapplicationstore \
";

oauthTables="\
oauth_authzcodes \
oauth_refreshtokens \
oauth_accesstokens \
oauth_authorizations \
";

usage() 
{
	echo "Usage: $0 -m <apim|authz> -k <your-keyspace> -u <user_to_be_created> -p <password_to_use> -au cassandra -ap cassandra"
	echo ""
	echo "-m, --mode		Mode: apim: Read-Only access to OAuth-Tables | authz: Write access to OAuth-Tables"
	echo "-k, --keyspace		Cassandra keyspace which is used by API-Manager & AuthZ-Server"
	echo "-u, --username		A new Cassandra user with this username will be created."
	echo "-p, --password		A new Cassandra user with this password will be created."
	echo "-au, --adminUser  	Username having admin-permissions to create new users."
	echo "-ap, --adminPassword	Password of user having admin-permissions to create new users."
	echo "-cqlsh			Path to cqlsh - Optional if cqlsh is in the path and executable"
	echo ""
	echo "Examples: "
	echo "$0 -m apim -k x65cd4036_751f_433e_acde_a8008b89444c_group_2 -u apim_user -p changeme -au cassandra -ap cassandra"
	echo "$0 -m apim -k x65cd4036_751f_433e_acde_a8008b89444c_group_2 -u apim_user -p changeme -au cassandra -ap cassandra -cqlsh ./bin/cqlsh"
}

if [ "$1" == "" ]; then
	usage
	exit
fi

while [ "$1" != "" ]; do
    case $1 in
        -m | --mode )           shift
                                mode=$1
                                ;;
        -k | --keyspace )       shift
				keyspace=$1
                                ;;
        -u | --username )       shift
				username=$1
                                ;;
        -p | --password )       shift
				password=$1
                                ;;
        -au | --adminUser )     shift
				adminUser=$1
                                ;;
        -ap | --adminPassword ) shift
				adminPassword=$1
                                ;;
        -cqlsh ) 		shift
				cqlsh=$1
                                ;;
        -h | --help )           usage
                                exit
                                ;;
        * )                     usage
                                exit 1
    esac
    shift
done


if [ "$mode" == "" -o "$username" == "" -o "$password" == "" -o "$adminUser" == "" -o "$adminPassword" == "" ];then
	echo ""
	echo "Missing parameter. Please check."
	echo ""
	usage
	exit
fi


if [[ -x "cqlsh" ]]
then
	cqlsh=cqlsh
else 
	if [[ -x "$cqlsh" ]];then
		cqlsh=$cqlsh
	else 
		echo "Cant execute cqlsh."
		exit
	fi
fi

cqlCommandFile="cqlCommands.$$"

echo -e "CREATE ROLE $username WITH password = '$password' AND LOGIN = true;\n" > $cqlCommandFile
echo "Creating User/Role: $username using command file: $cqlCommandFile" 
$cqlsh -u $adminUser -p $adminPassword -f $cqlCommandFile
rc=$?
if [[ "$rc" == "0" ]]; then
	echo "User: $username successfully created"
else
	echo "Error creating user."
	exit $rc
fi

echo ""

if [[ "$mode" == "apim" ]]; then
	echo "Setting up restricted access permissions for user type: API-Manager user"
	grantModifyTables=$apiManagerTables
	grantReadOnlyTables=$oauthTables
else 
	echo "Setting up restricted access permissions for user type: AuthZ-Server user"
	grantModifyTables=$oauthTables
	grantReadOnlyTables=$apiManagerTables
fi

echo -e "\n" > $cqlCommandFile

for table in $grantModifyTables
do
	echo -e "GRANT ALL PERMISSIONS ON $keyspace.$table TO $username;\n" >> $cqlCommandFile
done


for table in $grantReadOnlyTables
do
	echo -e "GRANT SELECT ON $keyspace.$table TO $username;\n" >> $cqlCommandFile
done

echo "Setup user-permissions for created user using command-file: $cqlCommandFile"
$cqlsh -u $adminUser -p $adminPassword -f $cqlCommandFile
rc=$?
if [[ "$rc" == "0" ]]; then
	echo "Permissions for user: $username successfully configured."
else
	echo "Error setting up user permissions for user: $username"
	exit $rc
fi
