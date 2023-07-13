#!/bin/bash

#INSTALL POSTGRESQL
echo "========================= INSTALLING POSTGRESQL ============================"

# 1. Refresh local package index:
apt update

# 2. Install the Postgres package along with a -contrib package:
echo -e "8\n6\n" | DEBIAN_FRONTEND=noninteractive apt install postgresql postgresql-contrib -y

# 3. Ensure that the service is started:
service postgresql start



#CONFIGURE POSTGRESQL
echo "========================= CONFIGURING POSTGRESQL ==========================="

# 1. Create a new Postgresql role
su - postgres -c "createuser --superuser djordje"

# 2. Create a new db
su - postgres -c "createdb djordje"

# 3. Create a new user
useradd -m -s /bin/bash djordje

# 4. Swap to the new user and output connection info
su - djordje -c "psql -c '\\conninfo'"
