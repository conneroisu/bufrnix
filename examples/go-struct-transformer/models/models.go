package models

import (
	"time"
)

// ProductModel represents the business logic model for a product
// This separates transport concerns (protobuf) from domain logic
type ProductModel struct {
	ID          int32     `json:"id"`
	Name        string    `json:"name"`
	Description string    `json:"description"`
	Price       float64   `json:"price"`
	Stock       int32     `json:"stock_quantity"`
	Tags        []string  `json:"tags"`
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`
}

// ProductListModel represents a collection of products with metadata
type ProductListModel struct {
	Products      []ProductModel `json:"products"`
	TotalCount    int32          `json:"total_count"`
	NextPageToken string         `json:"next_page_token"`
	PageSize      int32          `json:"page_size"`
}

// Business logic methods can be added here
func (p *ProductModel) IsInStock() bool {
	return p.Stock > 0
}

func (p *ProductModel) IsExpensive() bool {
	return p.Price > 100.0
}

func (pl *ProductListModel) HasNextPage() bool {
	return pl.NextPageToken != ""
}

func (pl *ProductListModel) GetInStockProducts() []ProductModel {
	var inStock []ProductModel
	for _, product := range pl.Products {
		if product.IsInStock() {
			inStock = append(inStock, product)
		}
	}
	return inStock
}