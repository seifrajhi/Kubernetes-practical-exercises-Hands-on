openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout tls-key.key -out tls-cert.crt
curl https://ssl-config.mozilla.org/ffdhe2048.txt > dhparam.pem
