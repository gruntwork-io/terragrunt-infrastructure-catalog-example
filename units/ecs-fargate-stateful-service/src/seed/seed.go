package seed

import (
	"database/sql"
	"fmt"
	"log"
)

// RunSeed populates the database with initial data if it's empty
func RunSeed(db *sql.DB) error {
	// Check if movies table is empty
	var count int
	err := db.QueryRow("SELECT COUNT(*) FROM movies").Scan(&count)
	if err != nil {
		return fmt.Errorf("error checking movies table: %v", err)
	}

	if count > 0 {
		log.Println("Movies table already seeded. Skipping...")
		return nil
	}

	// Insert initial movies
	insertSQL := `
	INSERT INTO movies (id, title, release_year) VALUES
	(1, 'The Matrix', 1999),
	(2, 'The Matrix Reloaded', 2003),
	(3, 'The Matrix Revolutions', 2003)
	ON DUPLICATE KEY UPDATE id = id;`

	_, err = db.Exec(insertSQL)
	if err != nil {
		return fmt.Errorf("error seeding movies table: %v", err)
	}

	log.Println("Successfully seeded movies table")
	return nil
}
