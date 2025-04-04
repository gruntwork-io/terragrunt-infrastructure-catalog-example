package main

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"os"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/feature/dynamodb/attributevalue"
	"github.com/aws/aws-sdk-go-v2/service/dynamodb"
	"github.com/aws/aws-sdk-go-v2/service/dynamodb/types"
)

type Item struct {
	ID    string `dynamodbav:"Id"`
	Count int    `dynamodbav:"Count"`
}

type Response struct {
	Count int `json:"count"`
}

var (
	dynamoDBClient *dynamodb.Client
	tableName      string
)

func init() {
	tableName = os.Getenv("DYNAMODB_TABLE")
	if tableName == "" {
		log.Fatalf("DYNAMODB_TABLE is not set")
	}

	cfg, err := config.LoadDefaultConfig(context.TODO())
	if err != nil {
		log.Fatalf("failed to load config: %v", err)
	}

	dynamoDBClient = dynamodb.NewFromConfig(cfg)
}

func handleRequest(ctx context.Context, event events.LambdaFunctionURLRequest) (events.LambdaFunctionURLResponse, error) {
	method := event.RequestContext.HTTP.Method

	switch method {
	case "GET":
		return handleGet(ctx)
	case "POST":
		return handlePost(ctx)
	default:
		return events.LambdaFunctionURLResponse{
			StatusCode: 405,
			Body:       "Method Not Allowed",
		}, nil
	}
}

func handleGet(ctx context.Context) (events.LambdaFunctionURLResponse, error) {
	count, err := getCount(ctx)
	if err != nil {
		return events.LambdaFunctionURLResponse{
			StatusCode: 500,
			Body:       "Error retrieving data from DynamoDB",
		}, fmt.Errorf("failed to get item from DynamoDB: %v", err)
	}

	response := Response{
		Count: count,
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

func handlePost(ctx context.Context) (events.LambdaFunctionURLResponse, error) {
	update := &dynamodb.UpdateItemInput{
		TableName: aws.String(tableName),
		Key: map[string]types.AttributeValue{
			"Id": &types.AttributeValueMemberS{Value: "postCounter"},
		},
		UpdateExpression: aws.String("ADD #count :incr"),
		ExpressionAttributeNames: map[string]string{
			"#count": "count",
		},
		ExpressionAttributeValues: map[string]types.AttributeValue{
			":incr": &types.AttributeValueMemberN{Value: "1"},
		},
		ReturnValues: types.ReturnValueUpdatedNew,
	}

	_, err := dynamoDBClient.UpdateItem(ctx, update)
	if err != nil {
		return events.LambdaFunctionURLResponse{
			StatusCode: 500,
			Body:       "Error updating data in DynamoDB",
		}, fmt.Errorf("failed to update item in DynamoDB: %v", err)
	}

	count, err := getCount(ctx)
	if err != nil {
		return events.LambdaFunctionURLResponse{
			StatusCode: 500,
			Body:       "Error retrieving data from DynamoDB",
		}, fmt.Errorf("failed to get item from DynamoDB: %v", err)
	}

	log.Printf("Updated counter to %d", count)

	response := Response{
		Count: count,
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

func getCount(ctx context.Context) (int, error) {
	input := &dynamodb.GetItemInput{
		TableName: aws.String(tableName),
		Key: map[string]types.AttributeValue{
			"Id": &types.AttributeValueMemberS{Value: "postCounter"},
		},
	}

	result, err := dynamoDBClient.GetItem(ctx, input)
	if err != nil {
		return 0, fmt.Errorf("failed to get item from DynamoDB: %v", err)
	}

	if result.Item == nil {
		return 0, nil
	}

	item := Item{}

	err = attributevalue.UnmarshalMap(result.Item, &item)
	if err != nil {
		return 0, fmt.Errorf("failed to unmarshal item from DynamoDB: %v", err)
	}

	return item.Count, nil
}

func main() {
	lambda.Start(handleRequest)
}
