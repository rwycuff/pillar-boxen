#!/bin/sh

read -p "Enter user name: [jenkins]" USERNAME
USERNAME=${USERNAME:-jenkins}

read -p "Enter a full name for this user: [jenkins]" FULLNAME
FULLNAME=${FULLNAME:-jenkins}

read -p "Enter a password for this user: [password]" PASSWORD
PASSWORD=${PASSWORD:-password}

read -p "Is this an administrative user?: (y/n) [Y]" GROUP_ADD
GROUP_ADD=${GROUP_ADD:-y}

if [ "$GROUP_ADD" = n ]
then
    SECONDARY_GROUPS="staff"  # for a non-admin user
elif [ "$GROUP_ADD" = y ] ; then
    SECONDARY_GROUPS="admin _lpadmin _appserveradm _appserverusr" # for an admin user
else
    echo "You did not make a valid selection!"
fi

echo "Creating an unused UID for new user..."
# Find out the next available user ID
MAXID=$(dscl . -list /Users UniqueID | awk '{print $2}' | sort -ug | tail -1)
USERID=$((MAXID+1))

echo "Creating necessary files..."
. /etc/rc.common
dscl . -create /Users/$USERNAME
dscl . -create /Users/$USERNAME UserShell /bin/bash
dscl . -create /Users/$USERNAME RealName "$FULLNAME"
dscl . -create /Users/$USERNAME UniqueID "$USERID"
dscl . -create /Users/$USERNAME PrimaryGroupID 80
dscl . -create /Users/$USERNAME NFSHomeDirectory /Users/$USERNAME
dscl . -passwd /Users/$USERNAME $PASSWORD

# Add user to any specified groups
echo "Adding user to specified groups..."

for GROUP in $SECONDARY_GROUPS ; do
    dseditgroup -o edit -t user -a $USERNAME $GROUP
done

# Create the home directory
echo "Creating home directory..."
createhomedir -c 2>&1 | grep -v "shell-init"

cp -R /System/Library/User\ Template/English.lproj /Users/$USERNAME
chown -R $USERNAME:staff /Users/$USERNAME

echo "Created user #$USERID: $USERNAME ($FULLNAME)"
