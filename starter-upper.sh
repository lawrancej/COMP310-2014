#!/bin/bash

# Configuration
# ---------------------------------------------------------------------

# The repository to clone as upstream (NO SPACES)
readonly REPO=COMP310-2014
# Default domain for school email
readonly SCHOOL=wit.edu
# The instructor's Github username
readonly INSTRUCTOR_GITHUB=lawrancej

# Runtime flags (DO NOT CHANGE)
# ---------------------------------------------------------------------
readonly PROGNAME=$(basename $0)
readonly ARGS="$@"

PIPES=""

finish() {
    rm -f $PIPES 2> /dev/null
}

trap finish EXIT

# Non-interactive Functions
# ---------------------------------------------------------------------

# Utilities
# ---------------------------------------------------------------------

# Print out the size of the file
utility::fileSize() {
    local file="$1"
    local theSize="$(du -b "$file" | cut -f1)"
    if [[ -z "$theSize" ]]; then
        theSize="0"
    fi
    printf "$theSize"
}

# "return" failure
utility::fail() {
    echo -n
    return 1
}

# "return" success
utility::success() {
    printf true
    return 0
}

# Return whether the last command was successful
utility::lastSuccess() {
    if [[ $? -eq 0 ]]; then
        utility::success
    else
        utility::fail
    fi
}

utility::asTrueFalse() {
    local result="$1"
    if [[ "$result" ]]; then
        printf "true"
    else
        printf "false"
    fi
}

# Make a named pipe. It sniffs for mkfifo and mknod first. If we don't get a real pipe, just fake it with a regular file.
pipe::new() {
    local pipe="$1"
    rm -f "$pipe" 2> /dev/null
    # Attempt to make a pipe
    if [[ -n "$(which mkfifo)" ]]; then
        mkfifo "$pipe" 2> /dev/null
    elif [[ -n "$(which mknod)" ]]; then
        mknod "$pipe" p 2> /dev/null
    fi
    # If nothing's there, just fake it with regular files
    if [[ ! -p "$pipe" ]]; then
        touch "$pipe"
    fi
    PIPES="$PIPES $pipe"
}

# Wait until we get the pipe
pipe::await() {
    local pipe="$1"
    until [[ -p "$pipe" ]] || [[ -f "$pipe" ]]; do
        sleep 1
    done
}

# Cross-platform read from named pipe
pipe::write() {
    local pipe="$1"; shift
    local data="$1"
    # We use echo here so we can send multi-line strings on one line
    echo "$data" > "$pipe"
    # If we got a real pipe, the pipe will wait, but if we got a fake pipe, ...
    if [[ ! -p "$pipe" ]]; then
        # We need to wait for the other side to read
        while [[ "0" != "$(utility::fileSize "$pipe")" ]]; do
            sleep 1
        done
    fi
}

# Cross-platform read from named pipe
pipe::read() {
    local pipe="$1"
    local line=""
    # If we got a real pipe, read will block until data comes in
    if [[ -p "$pipe" ]]; then
        # Hooray for blocking reads
        read -r line < "$pipe"
        echo -e "$line"
    # Windows users can't have nice things, as usual...
    elif [[ -f "$pipe" ]]; then
        # Wait for the other side to write
        while [[ "0" == "$(utility::fileSize "$pipe")" ]]; do
            sleep 1
        done
        read -r line < "$pipe"
        # Remove the line that we just read, because we've got to fake it
        sed -i -e "1d" "$pipe"
        echo -e "$line"
    fi
}

# Get the MIME type by the extension
utility::MIMEType() {
    local fileName="$1";
    case $fileName in
        *.html | *.htm ) printf "text/html" ;;
        *.ico ) printf "image/x-icon" ;;
        *.css ) printf "text/css" ;;
        *.js ) printf "text/javascript" ;;
        *.txt ) printf "text/plain" ;;
        *.jpg ) printf "image/jpeg" ;;
        *.png ) printf "image/png" ;;
        *.svg ) printf "image/svg+xml" ;;
        *.pdf ) printf "application/pdf" ;;
        *.json ) printf "application/json" ;;
        * ) printf "application/octet-stream" ;;
    esac
}

# Cross-platform paste to clipboard
# Return success if we pasted to the clipboard, fail otherwise
utility::paste() {
    case $OSTYPE in
        msys | cygwin ) echo "$1" > /dev/clipboard; utility::lastSuccess ;;
        linux* | bsd* ) echo "$1" | xclip -selection clipboard; utility::lastSuccess ;;
        darwin* ) echo "$1" | pbcopy; utility::lastSuccess ;;
        *) utility::fail ;;
    esac
}

# Cross-platform file open
# Return success if we opened the file, fail otherwise
utility::fileOpen() {
    case $OSTYPE in
        msys | cygwin ) start "$1"; utility::lastSuccess ;;
        linux* | bsd* ) xdg-open "$1"; utility::lastSuccess ;;
        darwin* ) open "$1"; utility::lastSuccess ;;
        *) utility::fail ;;
    esac
}

# Validate nonempty value matches a regex
# Return success if the value is not empty and matches regex, fail otherwise
utility::nonEmptyValueMatchesRegex() {
    local value="$1"; shift
    local regex="$1"
    
    # First, check if value is empty
    if [[ -z "$value" ]]; then
        utility::fail
    # Then, check whether value matches regex
    elif [[ -z "$(echo "$value" | grep -E "$regex" )" ]]; then
        utility::fail
    else
        utility::success
    fi
}

# SSH
# ---------------------------------------------------------------------

# Get the user's public key
ssh::getPublicKey() {
    # If the public/private keypair doesn't exist, make it.
    if ! [[ -f ~/.ssh/id_rsa.pub ]]; then
        # Use default location, set no phassphrase, no questions asked
        printf "\n" | ssh-keygen -t rsa -N '' 2> /dev/null > /dev/null
    fi
    cat ~/.ssh/id_rsa.pub | sed s/==.*$/==/ # Ignore the trailing comment
}

ssh::getPublicKeyForSed() {
    ssh::getPublicKey | sed -e 's/[/]/\\\//g'
}

# Test connection
ssh::connected() {
    local hostDomain="$1"; shift
    local sshTest=$(ssh -oStrictHostKeyChecking=no git@$hostDomain 2>&1)
    if [[ 255 -eq $? ]]; then
        utility::fail
    else
        utility::success
    fi
}

# User functions
# ---------------------------------------------------------------------

# Get the user's username
user::getUsername() {
    local username="$USERNAME"
    if [[ -z "$username" ]]; then
        username="$(id -nu 2> /dev/null)"
    fi
    if [[ -z "$username" ]]; then
        username="$(whoami 2> /dev/null)"
    fi
    printf "$username"
}

# A full name needs a first and last name
valid::fullName() {
    local fullName="$1"
    utility::nonEmptyValueMatchesRegex "$fullName" "\w+ \w+"
}

# Set the full name, and return the name that was set
user::setFullName() {
    local fullName="$1"
    if [[ $(valid::fullName "$fullName") ]]; then
        git config --global user.name "$fullName"
    fi
    git config --global user.name
}

# Get the user's full name (Firstname Lastname); defaults to OS-supplied full name
# Side effect: set ~/.gitconfig user.name if unset and full name from OS validates.
user::getFullName() {
    # First, look in the git configuration
    local fullName="$(git config --global user.name)"
    
    # Ask the OS for the user's full name, if it's not valid
    if [[ ! $(valid::fullName "$fullName") ]]; then
        local username="$(user::getUsername)"
        case $OSTYPE in
            msys | cygwin )
                cat << 'EOF' > getfullname.ps1
$MethodDefinition = @'
[DllImport("secur32.dll", CharSet=CharSet.Auto, SetLastError=true)]
public static extern int GetUserNameEx (int nameFormat, System.Text.StringBuilder userName, ref uint userNameSize);
'@
$windows = Add-Type -MemberDefinition $MethodDefinition -Name 'Secur32' -Namespace 'Win32' -PassThru
$sb = New-Object System.Text.StringBuilder
$num=[uint32]256
$windows::GetUserNameEx(3, $sb, [ref]$num) | out-null
$sb.ToString()
EOF
                fullName=$(powershell -executionpolicy remotesigned -File getfullname.ps1 | sed -e 's/\(.*\), \(.*\)/\2 \1/')
                rm getfullname.ps1 > /dev/null
                ;;
            linux* )
                fullName=$(getent passwd "$username" | cut -d ':' -f 5 | cut -d ',' -f 1)
                ;;
            darwin* )
                fullName=$(dscl . read /Users/`whoami` RealName | grep -v RealName | cut -c 2-)
                ;;
            *) fullName="" ;;
        esac
        
        # If we got a legit full name from the OS, update the git configuration to reflect it.
        user::setFullName "$fullName" > /dev/null
    fi
    printf "$fullName"
}

# We're assuming that students have a .edu email address
valid::email() {
    local email="$(printf "$1" | tr '[:upper:]' '[:lower:]' | tr -d ' ')"
    utility::nonEmptyValueMatchesRegex "$email" "edu$"
}

# Get the user's email; defaults to username@school
# Side effect: set ~/.gitconfig user.email if unset
user::getEmail() {
    # Try to see if the user already stored the email address
    local email="$(git config --global user.email | tr '[:upper:]' '[:lower:]' | tr -d ' ')"
    # If the stored email is bogus, ...
    if [[ ! $(valid::email "$email") ]]; then
        # Guess an email address and save it
        email="$(user::getUsername)@$SCHOOL"
    fi
    # Resave, just in case of goofups
    git config --global user.email "$email"
    printf "$email"
}

# Set email for the user and return email stored in git
user::setEmail() {
    local email="$1"
    if [[ $(valid::email "$email") ]]; then
        git config --global user.email "$email"
    fi
    git config --global user.email
}

# Get the domain name out of the user's email address
user::getEmailDomain() {
    printf "$(user::getEmail)" | sed 's/.*[@]//'
}

# Is the school valid?
valid::school() {
    local school="$1"
    utility::nonEmptyValueMatchesRegex "$school" "\w+"
}

# Get the user's school from their email address
user::getSchool() {
    local school="$(git config --global user.school)"
    Acquire_software
    if [[ ! "$(utility::nonEmptyValueMatchesRegex "$school" "\w+")" ]]; then
        school="$(echo -e "$(user::getEmailDomain)\r\n" | nc whois.educause.edu 43 | sed -n -e '/Registrant:/,/   .*/p' | sed -n -e '2,2p' | sed 's/^[ ]*//')"
    fi
    printf "$school"
}

# Generic project host configuration functions
# ---------------------------------------------------------------------

# Get the project host username; defaults to machine username
Host_getUsername() {
    local host="$1"
    local username="$(git config --global $host.login)"
    if [[ -z "$username" ]]; then
        username="$(user::getUsername)"
    fi
    printf "$username"
}

# Git
# ---------------------------------------------------------------------

# Clone/fetch upstream
git::clone_upstream() {
    local host="$1"; shift
    local upstream="$1"
    # It'll go into the user's home directory
    cd ~
    if [ ! -d $REPO ]; then
        git clone "https://$host/$upstream/$REPO.git" > /dev/null
    else
        cd $REPO
        git fetch --all > /dev/null
    fi
    utility::lastSuccess
}

# Configure remotes
git::configure_remotes() {
    local hostDomain="$1"; shift
    local originLogin="$1"; shift
    local upstreamLogin="$1";
    local origin="git@$hostDomain:$originLogin/$REPO.git"
    local upstream="https://$hostDomain/$upstreamLogin/$REPO.git"
    
    # Configure remotes
    cd ~/$REPO
    git remote rm origin 2> /dev/null
    git remote rm upstream 2> /dev/null
    git remote add origin "$origin"
    git remote add upstream "$upstream"
    git config branch.master.remote origin
    git config branch.master.merge refs/heads/master
    git remote | tr '\n' ' '
}

# Show the local and remote repositories
git::showRepositories() {
    local remote="$(git remote -v | grep origin | sed -e 's/.*git@\(.*\):\(.*\)\/\(.*\)\.git.*/https:\/\/\1\/\2\/\3/' | head -n 1)"
    cd ~
    # Open local repository in file browser
    utility::fileOpen $REPO
    # Open remote repository in web browser
    utility::fileOpen "$remote"
}

# Push repository, and show the user local/remote repositories
# Preconditions:
# 1. SSH public/private keypair was generated
# 2. The project host username was properly set
# 3. SSH public key was shared with host
# 4. SSH is working
# 5. The private repo exists
git::push() {
    cd ~/$REPO
    git push -u origin master 2> /dev/null > /dev/null
    utility::lastSuccess
}


readonly PIPE=.httpipe

# http://mywiki.wooledge.org/NamedPipes
# Also, simultaneous connections

json::unpack() {
    local json="$1"
    echo "$json" | tr -d '"{}' | tr ',' '\n'
}

# Given a header key, return the value
json::lookup() {
    local json="$1"; shift
    local key="$1"
    echo -e "$json" | grep "$key" | sed -e "s/^$key:\(.*\)$/\1/"
}

# Is this a request line?
request::line() {
    local line="$1"
    if [[ -z "$(echo "$line" | grep -E "^GET|^HEAD|^POST|^PUT|^DELETE|^CONNECT|^OPTIONS|^TRACE")" ]]; then
        utility::fail
    fi
    utility::success
}

# Get the method (e.g., GET, POST) of the request
request::method() {
    local request="$1"
    echo "$request" | sed -e "s/\(^[^ ]*\).*/\1/" | head -n 1
}

# Get the target (URL) of the request
request::target() {
    local request="$1"
    echo "$request" | sed -e 's/^[^ ]* \(.*\) HTTP\/.*/\1/' | head -n 1
}

# Get the file from the request target URL
request::file() {
    local request="$1"
    local target="$(request::target "$request")"
    # Leave the root request alone
    if [[ "$target" == "/" ]]; then
        printf "/"
    # Remove attempts to look outside the current folder, strip off the leading slash and the query
    else
        printf "$target" | sed -e 's/[.][.]//g' -e 's/^[/]*//g' -e 's/[?].*$//'
    fi
}

# Get the query portion of the request target URL, and return the results line by line
request::query() {
    request::target "$1" | sed -e 's/.*[?]\(.*\)$/\1/' | tr '&' '\n'
}

# Parse the request payload as form-urlencoded data
request::post_form_data() {
    local request="$1"
    local payload="$(request::payload "$request")"
    echo -e "REQUEST $request" >&2
    if [[ "$(request::lookup "$request" "Content-Type")" == "application/x-www-form-urlencoded" ]]; then
        echo "$payload" | tr '&' '\n'
    fi
}

# Given a query key, return the URL decoded value
query::lookup() {
    local query="$1"; shift
    local key="$1"
    echo -e "$(printf "$query" | grep "$key" | sed -e "s/^$key=\(.*\)/\1/" -e 'y/+/ /; s/%/\\x/g')"
}

# Return the key corresponding to the field
parameter::key() {
    local parameter="$1"
    echo "$parameter" | cut -d '=' -f 1
}

# Return the URL decoded value corresponding to the field
parameter::value() {
    local parameter="$1"
    echo -e "$(echo "$parameter" | cut -d '=' -f 2 | sed 'y/+/ /; s/%/\\x/g')"
}

# Given a header key, return the value
request::lookup() {
    local request="$1"; shift
    local key="$1"
    echo -e "$request" | grep "$key" | sed -e "s/^$key: \(.*\)/\1/"
}

# Return the payload of the request, if any (e.g., for POST requests)
request::payload() {
    local request="$1"; shift
    echo -e "$request" | sed -n -e '/^$/,${p}'
}

# Pipe HTTP request into a string
request::new() {
    local line="$1"
    # If we got a request, ...
    if [[ $(request::line "$line") ]]; then
        local request="$line"
        # Read all headers
        while read -r header; do
            request="$request\n$header"
            if [[ -z "$header" ]]; then
                break
            fi
        done
        # Sometimes, we have a payload in the request, so handle that, too...
        local length="$(request::lookup "$request" "Content-Length")"
        local payload=""
        if [[ -n "$length" ]] && [[ "$length" != "0" ]]; then
            read -r -n "$length" payload
            request="$request\n$payload"
        fi
    fi
    # Return single line string
    echo "$request"
}

# Build a new response
response::new() {
    local status="$1"
    echo "HTTP/1.1 $status\r\nDate: $(date '+%a, %d %b %Y %T %Z')\r\nServer: Starter Upper"
}

# Add a header to the response
response::add_header() {
    local response="$1"; shift
    local header="$1";
    echo "$response\r\n$header"
}

# Add headers to response assuming file is payload
response::add_file_headers() {
    local response="$1"; shift
    local file="$1"
    response="$response\r\nContent-Length: $(utility::fileSize "$file")"
    response="$response\r\nContent-Encoding: binary"
    response="$response\r\nContent-Type: $(utility::MIMEType $file)"
    echo "$response"
}

# Add headers to response assuming string is payload
response::add_string_headers() {
    local response="$1"; shift
    local str="$1"; shift
    local type="$1"
    response="$response\r\nContent-Length: ${#str}"
    response="$response\r\nContent-Type: $type"
    echo "$response"
}

# "Send" the response headers
response::send() {
    echo -ne "$1\r\n\r\n"
}

# Send file with HTTP response headers
server::send_file() {
    local file="$1";
    if [[ -z "$file" ]]; then
        return 0
    fi
    local response="$(response::new "200 OK")"
    if [[ ! -f "$file" ]]; then
        response="$(response::new "404 Not Found")"
        file="404.html"
    fi
    response="$(response::add_file_headers "$response" "$file")"
    response::send "$response"
    cat "$file"
    echo "SENT $file" >&2
}

# Send string with HTTP response headers
server::send_string() {
    local str="$1"; shift
    local type="$1"; shift
    local response="$(response::new "200 OK")"
    response="$(response::add_string_headers "$response" "$str" "$(utility::MIMEType $type)")"
    response="$response\r\nAccess-Control-Allow-Origin: *"
    response::send "$response"
    echo "$str"
}

# Listen for requests
server::listen() {
    local request=""
    while read -r line; do
        request=$(request::new "$line")
        # Send the request through 
        pipe::write "$PIPE" "$request\n"
    done
}

# Respond to requests, using supplied route function
# The route function is a command that takes a request argument: it should send a response
server::respond() {
    local routeFunction="$1"
    local request=""
    pipe::await "$PIPE"
    while true; do
        request="$(pipe::read "$PIPE")"
        # Pass the request to the route function
        "$routeFunction" "$request"
    done
}

Acquire_netcat() {
    local netcat=""
    # Look for netcat
    for program in "nc" "ncat" "netcat"; do
        if [[ -n "$(which $program)" ]]; then
            netcat=$program
            break
        fi
    done
    # Get netcat, if it's not already installed
    if [[ -z "$netcat" ]]; then
        curl http://nmap.org/dist/ncat-portable-5.59BETA1.zip 2> /dev/null > ncat.zip
        unzip -p ncat.zip ncat-portable-5.59BETA1/ncat.exe > nc.exe
        netcat="nc"
        rm ncat.zip
    fi
    printf $netcat
}

server::works() {
    local nc=$(Acquire_netcat)
    "$nc" -l 8080 &
    sleep 10
    echo "works" > /dev/tcp/localhost/8080
}

# Start the web server, using the supplied routing function
server::start() {
    local routes="$1"
    pipe::new "$PIPE"
    local nc=$(Acquire_netcat)
    
    server::respond "$routes" | "$nc" -k -l 8080 | server::listen
}


# Github non-interactive functions
# ---------------------------------------------------------------------

# Set github login and print it back out
github::set_login() {
    local login="$1"
    if [[ $(github::validUsername "$login") ]]; then
        git config --global github.login "$login"
    fi
    git config --global github.login
}

# Helpers

# Invoke a Github API method requiring authorization using curl
github::invoke() {
    local method=$1; shift
    local url=$1; shift
    local data=$1;
    local header="Authorization: token $(git config --global github.token)"
    curl -i --request "$method" -H "$header" -d "$data" "https://api.github.com$url" 2> /dev/null
}

# Queries

# Is the name available on Github?
github::nameAvailable() {
    local username="$1"
    local result="$(curl -i https://api.github.com/users/$username 2> /dev/null)"
    if [[ -z $(echo $result | grep "HTTP/1.1 200 OK") ]]; then
        utility::success
    else
        utility::fail
    fi
}

# A valid Github username is not available, by definition
github::validUsername() {
    local username="$1"
    # If the name is legit, ...
    if [[ $(utility::nonEmptyValueMatchesRegex "$username" "^[0-9a-zA-Z][0-9a-zA-Z-]*$") ]]; then
        # And unavailable, ...
        if [[ ! $(github::nameAvailable $username) ]]; then
            # It's valid
            utility::success
        else
            utility::fail
        fi
    else
        # Otherwise, it's not valid
        utility::fail
    fi
}

# Are we logged into Github?
github::loggedIn() {
    if [[ -n "$(git config --global github.token)" ]]; then
        utility::success
    else
        utility::fail
    fi    
}

# Did the user add their email to the Github account?
github::emailAdded() {
    local email="$1"
    local emails="$(github::invoke GET "/user/emails" "" | tr '\n}[]{' ' \n   ')"
    if [[ -z $(echo "$emails" | grep "$email") ]]; then
        utility::fail
    else
        utility::success
    fi
}

# Did the user verify their email with Github?
github::emailVerified() {
    local email="$1"
    local emails="$(github::invoke GET "/user/emails" "" | tr '\n}[]{' ' \n   ')"
    if [[ -z $(echo "$emails" | grep "$email" | grep "verified...true") ]]; then
        utility::fail
    else
        utility::success
    fi
}

# What plan does the user have?
github::plan() {
    github::invoke GET /user '' \
        | sed -n -e '/[\"]plan[\"]/,${p}' \
        | grep -E "[\"]name[\"]" \
        | sed -e 's/ *[\"]name[\"]: [\"]\(.*\)[\"].*/\1/' \
        | tr 'ABCDEFGHIJKLMNOPQRSTUVWXYZ' 'abcdefghijklmnopqrstuvwxyz'
}

# Is the user's plan upgraded?
github::upgradedPlan() {
    local plan="$(github::plan)"
    # If we got nothing back, we're not authenticated
    if [[ -z "$plan" ]]; then
        utility::fail
    # If we got something back, and it's not the free plan, we're good
    elif [[ "$plan" != "free" ]]; then
        utility::success
    # The free plan won't cut it
    else
        utility::fail
    fi
}

# start -> logged_in -> added email -> verified email -> upgraded account
github::accountStatus() {
    local email="$(user::getEmail)"
    if [[ ! $(github::loggedIn) ]]; then
        printf "start"
    elif [[ ! $(github::emailAdded "$email") ]]; then
        printf "logged_in"
    elif [[ ! $(github::emailVerified "$email") ]]; then
        printf "added_email"
    elif [[ ! $(github::upgradedPlan) ]]; then
        printf "verified_email"
    else
        printf "upgraded"
    fi
}

# Commands

# Log out of Github
github::logout() {
    git config --global --unset github.login
    git config --global --unset github.token
}

# Add email to Github account, if not already added
# Even though this adds email programmatically, Github will not send a verification email.
github::addEmail() {
    local email="$1"
    if [[ ! $(github::emailAdded "$email") ]]; then
        github::invoke POST "/user/emails" "[\"$email\"]" > /dev/null
    fi
}

# Github CLI-interactive functions
# ---------------------------------------------------------------------

github::hasAccount() {
    local hasAccount="n"
    # If we don't have their github login, ...
    if [[ -z "$(git config --global github.login)" ]]; then
        # Ask if they're on github yet
        read -p "Do you have a Github account (yes or No [default])? " hasAccount < /dev/tty
        # Let's assume that they don't by default
        if [[ $hasAccount != [Yy]* ]]; then
            utility::fail
        else
            utility::success
        fi
    else
        utility::success
    fi
}

# Ask the user if they have an account yet, and guide them through onboarding
github::join() {
    local hasAccount="n"
    
    # If we don't have their github login, ...
    if [[ -z "$(git config --global github.login)" ]]; then
        # Ask if they're on github yet
        read -p "Do you have a Github account (yes or No [default])? " hasAccount < /dev/tty

        echo -e "\e[1;37;41mIMPORTANT\e[0m: Before we proceed, you need to complete ALL of these steps:"

        # Let's assume that they don't by default
        if [[ $hasAccount != [Yy]* ]]; then
            echo "1. Join Github, using $(user::getEmail) as your email address."
            echo "2. Open your email inbox and verify your school email address."
            echo "3. Request an individual student educational discount."
            echo ""
            
            echo "Press enter to join Github."
            Interactive_fileOpen "https://github.com/join"
        else
            echo "1. Share and verify your school email address with Github."
            echo "2. Request an individual student educational discount."
            echo ""
        fi
        
        github::verifyEmail
        github::getDiscount

    fi
}

# Set the Github username, if not already set
github::setUsername() {
    github::join
    if [[ -z "$(git config --global github.token)" ]]; then
        Interactive_setValue "github.login" "$(Host_getUsername "github")" "github::validUsername" "Github username" "\nNOTE: Usernames are case-sensitive. See: https://github.com"
    fi
}

# Attempt to login to Github
github::authorize() {
    local password="$1"; shift
    local code="$1"
    read -r -d '' json <<-EOF
            {
                "scopes": ["repo", "public_repo", "user", "write:public_key", "user:email"],
                "note": "starterupper $(date --iso-8601=seconds)"
            }
EOF
    curl -i -u $(user::getEmail):$password -H "X-GitHub-OTP: $code" -d "$json" https://api.github.com/authorizations 2> /dev/null
}

# Idea: refactor to use interactive_setValue instead.
# Acquire authentication token and store in github.token
github::authenticate() {
    # Don't bother if we already got the authentication token
    if [[ -n "$(git config --global github.token)" ]]; then
        return 0
    fi
    local token="HTTP/1.1 401 Unauthorized"
    local code=''
    local password=''
    # As long as we're unauthorized, ...
    while [[ ! -z "$(echo $token | grep "HTTP/1.1 401 Unauthorized" )" ]]; do
        # Ask for a password
        if [[ -z "$password" ]]; then
            read -s -p "Enter Github password (not shown or saved): " password < /dev/tty
            echo # We need this, otherwise it'll look bad
        fi
        # Generate authentication token request
        token=$(github::authorize "$password" "$code")
        # If we got a bad credential, we need to reset the password and try again
        if [[ ! -z $(echo $token | grep "Bad credential") ]]; then
            echo -e "\e[1;37;41mERROR\e[0m: Incorrect password for user $(Host_getUsername "github"). Please wait."
            password=''
            sleep 1
        fi
        # If the user has two-factor authentication, ask for it.
        if [[ ! -z $(echo $token | grep "two-factor" ) ]]; then
            read -p "Enter Github two-factor authentication code: " code < /dev/tty
        fi
    done
    # By now, we're authenticated, ...
    if [[ ! -z $(echo $token | grep "HTTP/... 20." ) ]]; then
        # So, extract the token and store it in github.token
        token=$(echo $token | tr '"' '\n' | grep -E '[0-9a-f]{40}')
        git config --global github.token "$token"
        echo "Authenticated!"
    # Or something really bad happened, in which case, github.token will remain unset...
    else
        # When bad things happen, degrade gracefully.
        echo -n -e "\e[1;37;41mERROR\e[0m: "
        echo "$token" | grep "HTTP/..."
        echo
        echo "I encountered a problem and need your help to finish these setup steps:"
        echo
        echo "1. Update your Github profile to include your full name."
        echo "2. Create private repository $REPO on Github."
        echo "3. Add $INSTRUCTOR_GITHUB as a collaborator."
        echo "4. Share your public SSH key with Github."
        echo "5. Push to your private repository."
        echo
    fi
}

# Share full name with Github
github::setFullName() {
    local fullName="$(user::getFullName)"
    # If authentication failed, degrade gracefully
    if [[ -z $(git config --global github.token) ]]; then
        echo "Press enter to open https://github.com/settings/profile to update your Github profile."
        echo "On that page, enter your full name. $(Interactive_paste "$fullName" "your full name")"
        echo "Then, click Update profile."
        Interactive_fileOpen "https://github.com/settings/profile"
    # Otherwise, use the API
    else
        echo "Updating Github profile information..."
        github::invoke PATCH "/user" "{\"name\": \"$fullName\"}" > /dev/null
    fi
}

# Share the public key
github::sharePublicKey() {
    local githubLogin="$(Host_getUsername "github")"
    # If authentication failed, degrade gracefully
    if [[ -z "$(git config --global github.token)" ]]; then
        echo "Press enter to open https://github.com/settings/ssh to share your public SSH key with Github."
        echo "On that page, click Add SSH Key, then enter these details:"
        echo "Title: $(hostname)"
        echo "Key: $(Interactive_paste "$(ssh::getPublicKey)" "your public SSH key")"
        Interactive_fileOpen "https://github.com/settings/ssh"
    # Otherwise, use the API
    else
        # Check if public key is shared
        local publickeyShared=$(curl -i https://api.github.com/users/$githubLogin/keys 2> /dev/null)
        # If not shared, share it
        if [[ -z $(echo "$publickeyShared" | grep $(ssh::getPublicKey | sed -e 's/ssh-rsa \(.*\)=.*/\1/')) ]]; then
            echo "Sharing public key..."
            github::invoke POST "/user/keys" "{\"title\": \"$(hostname)\", \"key\": \"$(ssh::getPublicKey)\"}" > /dev/null
        fi
    fi
    # Test SSH connection on default port (22)
    if [[ ! $(ssh::connected "github.com") ]]; then
        echo "Your network has blocked port 22; trying port 443..."
        printf "Host github.com\n  Hostname ssh.github.com\n  Port 443\n" >> ~/.ssh/config
        # Test SSH connection on port 443
        if [[ ! $(ssh::connected "github.com") ]]; then
            echo "WARNING: Your network has blocked SSH."
            ssh_works=false
        fi
    fi
}

# Create a private repository on Github
github::createPrivateRepo() {
    # If authentication failed, degrade gracefully
    if [[ -z "$(git config --global github.token)" ]]; then
        github::manualCreatePrivateRepo
        return 0
    fi
    
    local githubLogin="$(Host_getUsername "github")"
    # Don't create a private repo if it already exists
    if [[ -z $(github::invoke GET "/repos/$githubLogin/$REPO" "" | grep "Not Found") ]]; then
        return 0
    fi
    
    echo "Creating private repository $githubLogin/$REPO on Github..."
    local result="$(github::invoke POST "/user/repos" "{\"name\": \"$REPO\", \"private\": true}")"
    if [[ ! -z $(echo $result | grep "HTTP/... 4.." ) ]]; then
        echo -n -e "\e[1;37;41mERROR\e[0m: "
        echo "Unable to create private repository."
        echo
        echo "Troubleshooting:"
        echo "* Make sure you have verified your school email address."
        echo "* Apply for the individual student educational discount if you haven't already done so."
        echo "* If you were already a Github user, free up some private repositories."
        echo
        
        github::verifyEmail
        github::getDiscount
        github::manualCreatePrivateRepo
    fi
}

# Add a collaborator
github::addCollaborator() {
    local githubLogin="$(Host_getUsername "github")"
    # If authentication failed, degrade gracefully
    if [[ -z "$(git config --global github.token)" ]]; then
        echo "Press enter to open https://github.com/$githubLogin/$REPO/settings/collaboration to add $1 as a collaborator."
        echo "$(Interactive_paste "$1" "$1")"
        echo "Click Add collaborator."
        Interactive_fileOpen "https://github.com/$githubLogin/$REPO/settings/collaboration"
    # Otherwise, use the API
    else
        echo "Adding $1 as a collaborator..."
        github::invoke PUT "/repos/$githubLogin/$REPO/collaborators/$1" "" > /dev/null
    fi
}

# Clean up everything but the repo (BEWARE!)
github::clean() {
    echo "Delete starterupper-script under Personal access tokens"
    Interactive_fileOpen "https://github.com/settings/applications"
    sed -i s/.*github.com.*// ~/.ssh/known_hosts
    git config --global --unset user.name
    git config --global --unset user.email
    git config --global --unset github.login
    git config --global --unset github.token
    rm -f ~/.ssh/id_rsa*
}

# Add collaborators
github::addCollaborators() {
    cd ~/$REPO
    for repository in $(github::invoke GET "/user/repos?type=member\&sort=created\&page=1\&per_page=100" "" | grep "full_name.*$REPO" | sed s/.*full_name....// | sed s/..$//); do
        git remote add ${repository%/*} git@github.com:$repository.git 2> /dev/null
    done
    git fetch --all
}

# Deprecate these

# Create a private repository manually
github::manualCreatePrivateRepo() {
    echo "Press enter to open https://github.com/new to create private repository $REPO on Github."
    echo "On that page, for Repository name, enter: $REPO. $(Interactive_paste "$REPO" "the repository name")"
    echo "Then, select Private and click Create Repository (DON'T tinker with other settings)."
    Interactive_fileOpen "https://github.com/new"
}

# Ask user to verify email
github::verifyEmail() {
    echo "Press enter to open https://github.com/settings/emails to add your school email address."
    echo "Open your email inbox and wait a minute for an email from Github."
    echo "Follow its instructions: click the link in the email and click Confirm."
    echo "$(Interactive_paste $(user::getEmail) "your school email")"
    Interactive_fileOpen "https://github.com/settings/emails"
}

# Ask the user to get the discount
github::getDiscount() {
    echo "Press enter to open https://education.github.com/discount_requests/new to request an individual student educational discount from Github."
    Interactive_fileOpen "https://education.github.com/discount_requests/new"
}

# github::plan

# Hmm, deep screen sandboxing mode will run a command twice. This is bad.
# Possible workaround: submit bogus password?
# github::authenticate
# github::addEmail "q2w3e4r5@mailinator.com"
# echo $(github::emailAdded "lawrancej@wit.edu")
# echo $(github::emailVerified "lawrancej@wit.edu")

# Make the index page
app::make_index() {
    local githubLoggedIn=$(utility::asTrueFalse $(github::loggedIn))
    local githubEmailVerified=$(utility::asTrueFalse $(github::emailVerified "$email"))
    local githubUpgradedPlan=$(utility::asTrueFalse $(github::upgradedPlan))
    local githubEmailAdded=$(utility::asTrueFalse $(github::emailAdded "$email"))
    
    curl http://lawrancej.github.io/starterupper/index.html 2> /dev/null > $REPO-index.html 

    sed -e "s/REPOSITORY/$REPO/g" \
    -e "s/USER_EMAIL/$(user::getEmail)/g" \
    -e "s/FULL_NAME/$(user::getFullName)/g" \
    -e "s/GITHUB_LOGIN/$(Host_getUsername github)/g" \
    -e "s/INSTRUCTOR_GITHUB/$INSTRUCTOR_GITHUB/g" \
    -e "s/PUBLIC_KEY/$(ssh::getPublicKeyForSed)/g" \
    -e "s/HOSTNAME/$(hostname)/g" \
    -e "s/GITHUB_LOGGED_IN/$githubLoggedIn/g" \
    -e "s/GITHUB_UPGRADED_PLAN/$githubUpgradedPlan/g" \
    -e "s/GITHUB_EMAIL_ADDED/$githubEmailAdded/g" \
    -e "s/GITHUB_EMAIL_VERIFIED/$githubEmailVerified/g" \
    $REPO-index.html > temp.html
}

app::index() {
    local request="$1"
    
    echo "$(request::payload "$request")" >&2
#    printf "$(request::query "$request")" >&2
    local email
    
    request::post_form_data "$request" | while read parameter; do
        local key="$(parameter::key "$parameter")"
        local value="$(parameter::value "$parameter")"
        case "$key" in
            "user.name" )
                user::setFullName "$value"
                ;;
            "user.email" )
                email="$value"
                user::setEmail "$value"
                github::addEmail "$value"
                ;;
#            "github.login" )
#                Github
        esac
    done
    
    app::make_index
    server::send_file "temp.html"
    rm temp.html
}

# Return the browser to the browser for disabled JavaScript troubleshooting
app::browser() {
    local request="$1"
    local agent="$(request::lookup "$request" "User-Agent")"
    case "$agent" in
        *MSIE* | *Trident* )
            server::send_string ".firefox, .chrome {display: none;}" "browser.css" ;;
        *Firefox* )
            server::send_string ".chrome, .msie {display: none;}" "browser.css" ;;
        *Chrome* )
            server::send_string ".firefox, .msie {display: none;}" "browser.css" ;;
    esac
}

# Setup local repositories
app::setup() {
    local request="$1"
    local response=""
    case "$(request::method "$request")" in
        # Respond to preflight request
        "OPTIONS" )
            response="$(response::new "204 No Content")"
            response="$(response::add_header "$response" "Access-Control-Allow-Origin: *")"
            response="$(response::add_header "$response" "Access-Control-Allow-Methods: GET, POST")"
            response="$(response::add_header "$response" "Access-Control-Allow-Headers: $(request::lookup "$request" "Access-Control-Request-Headers")")"
            response::send "$response"
            echo "SENT RESPONSE" >&2
            ;;
        # Get that glorious data from the user and do what we set out to accomplish
        "POST" )
            local data="$(json::unpack "$(request::payload "$request")")"
            local github_login="$(json::lookup "$data" "github.login")"
            local user_name="$(json::lookup "$data" "user.name")"
            local user_email="$(json::lookup "$data" "user.email")"
            # Git configuration
            
            read -r -d '' response <<-EOF
{
    "name": "$(user::setFullName "$user_name")",
    "email": "$(user::setEmail "$user_email")",
    "github": "$(github::set_login "$github_login")",
    "clone": $(utility::asTrueFalse $(git::clone_upstream "github.com" "$INSTRUCTOR_GITHUB")),
    "remotes": "$(git::configure_remotes "github.com" "$(git config --global github.login)" "$INSTRUCTOR_GITHUB")",
    "push": $(utility::asTrueFalse $(git::push))
}
EOF
            # The response needs to set variables: name, email, git-clone, git-push
            server::send_string "$response" "response.json"
            ;;
        # If we get here, something terribly wrong has happened...
        * )
            echo "the request was '$request'" >&2
            echo "$(request::method "$request")" >&2
            ;;
    esac
}

# Dummy response to verify server works
app::test() {
    local request="$1"
    server::send_string "true" "application/json"
}

# Handle requests from the browser
app::router() {
    local request="$1"
    local target="$(request::file "$request")"
    case "$target" in
        "/" )           app::index "$request" ;;
        "test" )        app::test "$request" ;;
        "browser.css" ) app::browser "$request" ;;
        "setup" )       app::setup "$request" ;;
        * )             server::send_file "$target"
    esac
}

printf "Please wait, gathering information..." >&2
app::make_index
utility::fileOpen temp.html > /dev/null
echo -e "                                      [\e[1;32mOK\e[0m]" >&2
echo -e "Starting local web server at http://localhost:8080...                      [\e[1;32mOK\e[0m]" >&2
server::start "app::router"

# if [[ "$(utility::fileOpen http://localhost:8080)" ]]; then
    # echo -e "Opened web browser to http://localhost:8080                                [\e[1;32mOK\e[0m]" >&2
# else
    # echo -e "Please open web browser to http://localhost:8080              [\e[1;32mACTION REQUIRED\e[0m]" >&2
# fi

