# Base Image 
FROM        node

# exposed port - same port is defined in the server.js
EXPOSE      5000

# The "configuration" which we pass in runtime
ENV         LANGUAGE    Hebrew
ENV         TOKEN       Hard-To-Guess

# Copy the server to the container
COPY        server.js .

# start the server
ENTRYPOINT  node server.js