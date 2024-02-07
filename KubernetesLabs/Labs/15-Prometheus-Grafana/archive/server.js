'use strict';

const
    // Express server
    express = require('express'),
    app = express(),
    // Prometheus client for node.js
    client = require('prom-client'),

    // Prometheus metric (Counter)- count number of requests
    counter = new client.Counter({
        name: 'node_request_operations_total',
        help: 'The total number of processed requests'
    }),
    // Prometheus metric (Histogram)- duration of requests in seconds
    histogram = new client.Histogram({
        name: 'node_request_duration_seconds',
        help: 'Histogram for the duration in seconds.',
        buckets: [1, 2, 5, 6, 10]
    }),

    PORT = 5000,
    HOST = '127.0.0.1';


// Probe every 5th second.
client.collectDefaultMetrics({ timeout: 5000 });

app.get('/', (req, res) => {

    //  Simulate a sleep
    let start = new Date(),
        simulateTime = 1000;

    setTimeout(function (argument) {
        // execution time simulated with setTimeout function
        var end = new Date() - start
        histogram.observe(end / 1000); //convert to seconds
    }, simulateTime)

    // Increment the counter on every new request
    counter.inc();

    // Send reply to the user
    res.send('Hello world\n');
});


// Metrics endpoint for the collector
app.get('/metrics', (req, res) => {
    res.set('Content-Type', client.register.contentType)
    res.end(client.register.metrics())
})

// Start the server
app.listen(PORT, HOST, () => {
    console.log(`Server is running on http://${HOST}:${PORT}`);
});
