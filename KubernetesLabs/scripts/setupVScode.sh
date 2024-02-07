# Download latest VS code
curl -fsSL https://code-server.dev/install.sh | sh 

# Start the VScode in your browser
code-server &

# Print out the password so we can use it
cat ~/.config/code-server/config.yaml | grep password:











