package router

import (
	"github.com/gorilla/mux"
	"github.com/prometheus/client_golang/prometheus/promhttp"
	"stock-api/handlers"
	"stock-api/middleware"
)

func Router() *mux.Router {
	router := mux.NewRouter()
	router.Use(middleware.Prometheus)

	router.Path("/metrics").Handler(promhttp.Handler())
	router.HandleFunc("/healthz", handlers.GetHealth).Methods("GET")
	router.HandleFunc("/stock/{id}", handlers.GetProductStock).Methods("GET", "OPTIONS")
	router.HandleFunc("/stock/{id}", handlers.SetProductStock).Methods("PUT", "OPTIONS")

	return router
}
