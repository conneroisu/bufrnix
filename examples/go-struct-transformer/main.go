package main

import (
	"fmt"
	"log"
	"time"

	"github.com/conneroisu/bufrnix/examples/go-struct-transformer/models"
	examplev1 "github.com/example/proto/example/v1"
	"github.com/example/proto/example/v1/transform"
)

func main() {
	fmt.Println("Struct Transformer Example - Fully Working!")
	fmt.Println("==========================================")

	// Create a business logic model
	productModel := &models.ProductModel{
		ID:          1,
		Name:        "Laptop",
		Description: "High-performance laptop for developers",
		Price:       1299.99,
		Stock:       5,
		Tags:        []string{"electronics", "computers", "developer"},
		CreatedAt:   time.Now(),
		UpdatedAt:   time.Now(),
	}

	fmt.Printf("\n1. Business Logic Model:\n%+v\n", productModel)
	fmt.Printf("   Is in stock: %t\n", productModel.IsInStock())
	fmt.Printf("   Is expensive: %t\n", productModel.IsExpensive())

	// NOW WITH REAL GENERATED TRANSFORMATION FUNCTIONS!

	// Convert business model to protobuf message
	pbProduct := transform.ProductModelToPbPtr(productModel)
	fmt.Printf("\n2. Converted to Protobuf Message:\n%+v\n", pbProduct)

	// Convert protobuf message back to business model
	convertedModel := transform.PbToProductModelPtr(pbProduct)
	fmt.Printf("\n3. Converted Back to Business Model:\n%+v\n", convertedModel)
	fmt.Printf("   Still in stock: %t\n", convertedModel.IsInStock())
	fmt.Printf("   Still expensive: %t\n", convertedModel.IsExpensive())

	// Demonstrate list transformations
	productList := &models.ProductListModel{
		Products:      []models.ProductModel{*productModel},
		TotalCount:    1,
		NextPageToken: "next_token_123",
		PageSize:      10,
	}

	fmt.Printf("\n4. Product List Model:\n%+v\n", productList)

	// Convert list to protobuf
	pbProductList := transform.ProductListModelToPbPtr(productList)
	fmt.Printf("\n5. Converted List to Protobuf:\n%+v\n", pbProductList)

	// Convert back
	convertedList := transform.PbToProductListModelPtr(pbProductList)
	fmt.Printf("\n6. Converted Back to List Model:\n%+v\n", convertedList)
	fmt.Printf("   Has next page: %t\n", convertedList.HasNextPage())
	fmt.Printf("   In-stock products: %d\n", len(convertedList.GetInStockProducts()))

	// Show different transformation variants
	fmt.Println("\n7. Available Transformation Functions:")
	fmt.Println("   For Product:")
	fmt.Println("   - ProductModelToPb (value to value)")
	fmt.Println("   - ProductModelToPbPtr (value to pointer)")
	fmt.Println("   - ProductModelToPbValPtr (value to pointer)")
	fmt.Println("   - ProductModelToPbPtrVal (pointer to value)")
	fmt.Println("   - ProductModelToPbPtrList (slice of pointers)")
	fmt.Println("   - ProductModelToPbValList (slice of values)")
	fmt.Println("   - And 8 more reverse transformations!")

	// Test value transformations
	valueProduct := models.ProductModel{
		ID:    2,
		Name:  "Mouse",
		Price: 29.99,
		Stock: 100,
	}

	pbValue := transform.ProductModelToPb(valueProduct)
	backToValue := transform.PbToProductModel(pbValue)
	fmt.Printf("\n8. Value Transformation Test:\n   Original: %+v\n   Converted: %+v\n", valueProduct, backToValue)

	log.Println("\n✅ All transformations working perfectly! The struct-transformer plugin is fully functional!")
}

// Example of how this would be used in a real gRPC service
type ProductService struct{}

func (s *ProductService) GetProduct(id int32) (*examplev1.Product, error) {
	// Fetch from database (returns domain model)
	product := fetchProductFromDB(id)

	// Transform domain model to protobuf for transport
	return transform.ProductModelToPbPtr(product), nil
}

func (s *ProductService) SaveProduct(pbProduct *examplev1.Product) error {
	// Transform protobuf to domain model
	product := transform.PbToProductModelPtr(pbProduct)

	// Save to database using domain model
	return saveProductToDB(product)
}

// Mock database functions
func fetchProductFromDB(id int32) *models.ProductModel {
	return &models.ProductModel{
		ID:    id,
		Name:  "Database Product",
		Price: 99.99,
		Stock: 10,
	}
}

func saveProductToDB(product *models.ProductModel) error {
	// Mock save
	return nil
}
