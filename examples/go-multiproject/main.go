package main

import (
	"fmt"
	"log"
	"time"

	"google.golang.org/protobuf/types/known/timestamppb"

	ordersv1 "github.com/example/multiproject/proto/gen/go/orders/v1"
	productsv1 "github.com/example/multiproject/proto/gen/go/products/v1"
	usersv1 "github.com/example/multiproject/proto/gen/go/users/v1"
)

func main() {
	fmt.Println("Multi-project protobuf example")
	fmt.Println("==============================")

	// Create sample user
	user := &usersv1.User{
		Id:        "user-123",
		Email:     "john.doe@example.com",
		Name:      "John Doe",
		CreatedAt: timestamppb.New(time.Now()),
		UpdatedAt: timestamppb.New(time.Now()),
		Status:    usersv1.UserStatus_USER_STATUS_ACTIVE,
	}

	fmt.Printf("Created User:\n")
	fmt.Printf("  ID: %s\n", user.Id)
	fmt.Printf("  Email: %s\n", user.Email)
	fmt.Printf("  Name: %s\n", user.Name)
	fmt.Printf("  Status: %s\n", user.Status.String())
	fmt.Println()

	// Create sample product
	product := &productsv1.Product{
		Id:          "prod-456",
		Name:        "Wireless Headphones",
		Description: "High-quality wireless headphones with noise cancellation",
		Price:       199.99,
		Currency:    "USD",
		Sku:         "WH-001",
		StockQuantity: 100,
		Category: &productsv1.ProductCategory{
			Id:          "cat-electronics",
			Name:        "Electronics",
			Description: "Electronic devices and accessories",
		},
		Tags:      []string{"audio", "wireless", "noise-cancelling"},
		CreatedAt: timestamppb.New(time.Now()),
		UpdatedAt: timestamppb.New(time.Now()),
		Status:    productsv1.ProductStatus_PRODUCT_STATUS_ACTIVE,
	}

	fmt.Printf("Created Product:\n")
	fmt.Printf("  ID: %s\n", product.Id)
	fmt.Printf("  Name: %s\n", product.Name)
	fmt.Printf("  Price: $%.2f %s\n", product.Price, product.Currency)
	fmt.Printf("  SKU: %s\n", product.Sku)
	fmt.Printf("  Stock: %d\n", product.StockQuantity)
	fmt.Printf("  Category: %s\n", product.Category.Name)
	fmt.Printf("  Tags: %v\n", product.Tags)
	fmt.Println()

	// Create sample order
	order := &ordersv1.Order{
		Id:     "order-789",
		UserId: user.Id,
		Items: []*ordersv1.OrderItem{
			{
				ProductId:  product.Id,
				Quantity:   2,
				UnitPrice:  product.Price,
				TotalPrice: product.Price * 2,
			},
		},
		Status:      ordersv1.OrderStatus_ORDER_STATUS_PENDING,
		TotalAmount: product.Price * 2,
		Currency:    "USD",
		CreatedAt:   timestamppb.New(time.Now()),
		UpdatedAt:   timestamppb.New(time.Now()),
		ShippingAddress: &ordersv1.ShippingAddress{
			Street:     "123 Main St",
			City:       "San Francisco",
			State:      "CA",
			PostalCode: "94105",
			Country:    "USA",
		},
	}

	fmt.Printf("Created Order:\n")
	fmt.Printf("  ID: %s\n", order.Id)
	fmt.Printf("  User ID: %s\n", order.UserId)
	fmt.Printf("  Status: %s\n", order.Status.String())
	fmt.Printf("  Total: $%.2f %s\n", order.TotalAmount, order.Currency)
	fmt.Printf("  Items:\n")
	for _, item := range order.Items {
		fmt.Printf("    - Product: %s, Qty: %d, Unit Price: $%.2f, Total: $%.2f\n",
			item.ProductId, item.Quantity, item.UnitPrice, item.TotalPrice)
	}
	fmt.Printf("  Shipping Address: %s, %s, %s %s, %s\n",
		order.ShippingAddress.Street,
		order.ShippingAddress.City,
		order.ShippingAddress.State,
		order.ShippingAddress.PostalCode,
		order.ShippingAddress.Country)
	fmt.Println()

	// Demonstrate service requests
	fmt.Println("Service Request Examples:")
	fmt.Println("========================")

	// User service request
	getUserReq := &usersv1.GetUserRequest{
		Id: user.Id,
	}
	fmt.Printf("GetUser Request: %+v\n", getUserReq)

	// Product service request
	searchProductsReq := &productsv1.SearchProductsRequest{
		Query:    "wireless",
		PageSize: 10,
		Tags:     []string{"audio"},
		MinPrice: 100.0,
		MaxPrice: 300.0,
	}
	fmt.Printf("SearchProducts Request: %+v\n", searchProductsReq)

	// Order service request
	createOrderReq := &ordersv1.CreateOrderRequest{
		UserId: user.Id,
		Items: []*ordersv1.OrderItem{
			{
				ProductId:  product.Id,
				Quantity:   1,
				UnitPrice:  product.Price,
				TotalPrice: product.Price,
			},
		},
		ShippingAddress: order.ShippingAddress,
	}
	fmt.Printf("CreateOrder Request: %+v\n", createOrderReq)

	// Demonstrate cross-package references
	fmt.Println("\nCross-package References:")
	fmt.Println("========================")
	fmt.Printf("Order references User ID: %s\n", order.UserId)
	fmt.Printf("Order item references Product ID: %s\n", order.Items[0].ProductId)
	fmt.Printf("This demonstrates how different proto packages can reference each other\n")

	log.Println("Multi-project protobuf example completed successfully!")
}