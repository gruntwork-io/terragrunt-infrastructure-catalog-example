package main

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"os"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
)

type Response struct {
	Version string `json:"version"`
}

func handleRequest(ctx context.Context, event events.LambdaFunctionURLRequest) (events.LambdaFunctionURLResponse, error) {
	version := os.Getenv("VERSION")
	if version == "" {
		log.Printf("WARNING: VERSION environment variable is not set")
		version = "unknown"
	}

	response := Response{
		Version: version,
	}

	responseBody, err := json.Marshal(response)
	if err != nil {
		return events.LambdaFunctionURLResponse{
			StatusCode: 500,
			Body:       "Error marshalling response to JSON",
		}, fmt.Errorf("failed to marshal response to JSON: %v", err)
	}

	return events.LambdaFunctionURLResponse{
		StatusCode: 200,
		Headers: map[string]string{
			"Content-Type": "application/json",
		},
		Body: string(responseBody),
	}, nil
}

func main() {
	lambda.Start(handleRequest)
}
