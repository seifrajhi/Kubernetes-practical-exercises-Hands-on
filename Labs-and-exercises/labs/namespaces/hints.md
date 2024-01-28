# Lab Hints

This is about making sure your new objects are created in the right namespace, and the Nginx configuration uses the right URL to find the Pi web app.

The current Nginx config uses a local DNS name: 

```
proxy_pass  http://pi-web-internal;
```

That's the wrong Service name, and a local DNS name won't do when the Nginx is in a different namespace from the app it's proxying. And don't forget the port...

> Need more? Here's the [solution](solution.md).