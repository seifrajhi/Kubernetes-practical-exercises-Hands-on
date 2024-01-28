package models

type Product struct {
	ID       int64  `json:"id"`
	Stock    int64  `json:"stock"`
}

type CachedProduct struct {
	Product 	Product	`json:"product"`
	ExpiresAt	int64	`json:"expiresAt"`
}