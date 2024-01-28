package handlers

import (
	"database/sql"
	"encoding/json"
	"fmt"
	"log"
	"net/http" 
	"os"
	"strconv"
	"time"
	"github.com/gorilla/mux" 
	_ "github.com/lib/pq"
	"stock-api/models"
	"io/ioutil"
)

type response struct {
	ID      int64  `json:"id,omitempty"`
	Message string `json:"message,omitempty"`
}

func createConnection() *sql.DB {
	db, err := sql.Open("postgres", os.Getenv("POSTGRES_CONNECTION_STRING"))
	if err != nil {
		panic(err)
	}

	err = db.Ping()
	if err != nil {
		panic(err)
	}

	return db
}

func GetHealth(w http.ResponseWriter, r *http.Request) {
	w.Write([]byte("OK"))
}

func GetProductStock(w http.ResponseWriter, r *http.Request) {
	params := mux.Vars(r)
	id,_ := strconv.Atoi(params["id"])
	var cachedProduct models.CachedProduct
	var cacheIsValid bool

	cacheFile := fmt.Sprintf("/cache/product-%v.json", id);
	if _, err := os.Stat(cacheFile); err == nil {
		content,_ := ioutil.ReadFile(cacheFile) 		
		_ = json.Unmarshal(content, &cachedProduct)
		cacheIsValid = time.Now().Unix() < cachedProduct.ExpiresAt
		if cacheIsValid {
			log.Printf("Loaded stock from cache for product ID: %v", id)
		} else {
			log.Printf("Cache expired for product ID: %v", id)
			os.Remove(cacheFile)
		}
	} 
	
	if !cacheIsValid {
		product,_ := getProductStock(int64(id))	
		log.Printf("Fetched stock from DB for product ID: %v", id)
		cacheExpiry,_ := strconv.Atoi(os.Getenv("CACHE_EXPIRY_SECONDS"))
		cachedProduct = models.CachedProduct{
			Product: product,
			ExpiresAt: time.Now().Unix() + int64(cacheExpiry),
		}
		data, _ := json.MarshalIndent(cachedProduct, "", " ")
		err := ioutil.WriteFile(cacheFile, data, 0644) 
		if err != nil {
			log.Printf("ERR 1046 - failed to write to cache file: %v", cacheFile)
		}
	}	

	w.Header().Add("Content-Type", "application/json")
	json.NewEncoder(w).Encode(cachedProduct.Product)
}

func SetProductStock(w http.ResponseWriter, r *http.Request) {
	params := mux.Vars(r)
	id,_ := strconv.Atoi(params["id"])

	var product models.Product
	err := json.NewDecoder(r.Body).Decode(&product)
	if err != nil {
        http.Error(w, err.Error(), http.StatusBadRequest)
        return
    }

	log.Printf("Setting stock to : %v, for product ID: %v", product.Stock, id)
	setProductStock(int64(id), product.Stock)
	log.Printf("Updated stock for product ID: %v", id)

	res := response{
		ID:      int64(id),
		Message: "Stock updated",
	}

	w.Header().Add("Content-Type", "application/json")
	json.NewEncoder(w).Encode(res)
}

func getProductStock(id int64) (models.Product, error) {
	db := createConnection()
	defer db.Close()
	
	sql := `SELECT id, stock FROM "public"."products" WHERE id=$1`
	row := db.QueryRow(sql, id)

	var product models.Product
	err := row.Scan(&product.ID, &product.Stock)

	if err != nil {
		log.Fatalf("Error fetching product. %v", err)
	}

	return product, err
}

func setProductStock(id int64, stock int64) {
	db := createConnection()
	defer db.Close()

	sql := `UPDATE "public"."products" SET stock = $2 WHERE id=$1`
	_, err := db.Exec(sql, id, stock)

	if err != nil {
		log.Fatalf("Error updating product. %v", err)
	}
}
