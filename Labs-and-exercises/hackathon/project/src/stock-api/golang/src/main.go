package main

import (
	"log"
	"net/http"
	"os"
	"stock-api/router"
	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promauto"	
)

var (
	appInfo = promauto.NewGaugeVec(prometheus.GaugeOpts{
	  Name: "app_info",
	  Help: "Application info",
	}, []string{"version", "goversion", "osversion"})
)

func main() {
	appInfo.WithLabelValues(os.Getenv("APP_VERSION"), os.Getenv("GOLANG_VERSION"), os.Getenv("ALPINE_VERSION")).Set(1)
	
	r := router.Router()
	log.Println("Starting server on port 8080...")
	log.Fatal(http.ListenAndServe(":8080", r))
}
