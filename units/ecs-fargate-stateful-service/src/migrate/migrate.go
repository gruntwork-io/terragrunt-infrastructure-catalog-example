package migrate

import (
	"database/sql"
	"fmt"
	"log"
)

// RunMigrations creates the necessary database tables
func RunMigrations(db *sql.DB) error {
	// Create movies table
	createTableSQL := `
	CREATE TABLE IF NOT EXISTS movies (
		id INT AUTO_INCREMENT PRIMARY KEY,
		title VARCHAR(255) NOT NULL,
		release_year INT NOT NULL
	);`

	_, err := db.Exec(createTableSQL)
	if err != nil {
		return fmt.Errorf("error creating movies table: %v", err)
	}

	log.Println("Successfully created movies table")
	return nil
}
