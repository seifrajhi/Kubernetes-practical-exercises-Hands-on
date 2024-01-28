package middleware

import (
	"net/http"
  
	"github.com/gorilla/mux"
	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promauto"
  )

  var (
	activeRequests = promauto.NewGauge(prometheus.GaugeOpts{
		Name: "http_requests_in_progress",
		Help: "Active HTTP requests",
	})
  )
  
  var (
	httpDuration = promauto.NewHistogramVec(prometheus.HistogramOpts{
	  Name: "http_request_duration_seconds",
	  Help: "Duration of HTTP requests",
	}, []string{"path"})
  )
  
  func Prometheus(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
	  activeRequests.Inc()
	  route := mux.CurrentRoute(r)
	  path, _ := route.GetPathTemplate()
	  timer := prometheus.NewTimer(httpDuration.WithLabelValues(path))
	  next.ServeHTTP(w, r)
	  timer.ObserveDuration()
	  activeRequests.Dec()
	})
  }