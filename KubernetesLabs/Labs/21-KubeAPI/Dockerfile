FROM    alpine

# Update and install dependencies
RUN     apk add --update nodejs npm curl

# Copy the endpoint script
COPY    api_query.sh . 

# Set the execution bit
RUN     chmod +x api_query.sh . 