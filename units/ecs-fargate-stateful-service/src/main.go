package main

import (
	"database/sql"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"

	"app/migrate"
	"app/seed"

	_ "github.com/go-sql-driver/mysql"
)

type Movie struct {
	ID          int    `json:"id"`
	Title       string `json:"title"`
	ReleaseYear int    `json:"releaseYear"`
}

var db *sql.DB

func initDB() error {
	var err error
	dbHost := os.Getenv("DB_HOST")
	dbUser := os.Getenv("DB_USER")
	dbPass := os.Getenv("DB_PASSWORD")
	dbName := os.Getenv("DB_NAME")
	dbPort := os.Getenv("DB_PORT")

	dsn := fmt.Sprintf("%s:%s@tcp(%s:%s)/%s?parseTime=true", dbUser, dbPass, dbHost, dbPort, dbName)

	db, err = sql.Open("mysql", dsn)
	if err != nil {
		return fmt.Errorf("error opening database: %w", err)
	}

	if err = db.Ping(); err != nil {
		return fmt.Errorf("error connecting to the database: %w", err)
	}

	// Run migrations
	if err := migrate.RunMigrations(db); err != nil {
		return fmt.Errorf("error running migrations: %w", err)
	}

	// Run seeding
	if err := seed.RunSeed(db); err != nil {
		return fmt.Errorf("error running seed: %w", err)
	}

	return nil
}

func getMovies(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	rows, err := db.Query("SELECT id, title, release_year FROM movies")
	if err != nil {
		http.Error(w, "Error querying database", http.StatusInternalServerError)
		log.Printf("Error querying movies: %w", err)
		return
	}
	defer rows.Close()

	var movies []Movie
	for rows.Next() {
		var m Movie
		if err := rows.Scan(&m.ID, &m.Title, &m.ReleaseYear); err != nil {
			http.Error(w, "Error scanning results", http.StatusInternalServerError)
			log.Printf("Error scanning movie: %w", err)
			return
		}
		movies = append(movies, m)
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(movies)
}

func getMovie(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	id := r.PathValue("id")
	if id == "" {
		http.Error(w, "Missing id parameter", http.StatusBadRequest)
		return
	}

	var movie Movie
	err := db.QueryRow("SELECT id, title, release_year FROM movies WHERE id = ?", id).Scan(&movie.ID, &movie.Title, &movie.ReleaseYear)
	if err == sql.ErrNoRows {
		http.Error(w, "Movie not found", http.StatusNotFound)
		return
	} else if err != nil {
		http.Error(w, "Error querying database", http.StatusInternalServerError)
		log.Printf("Error querying movie: %w", err)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(movie)
}

func healthCheck(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(http.StatusOK)
	w.Write([]byte("OK"))
}

func main() {
	if err := initDB(); err != nil {
		log.Fatalf("Failed to initialize database: %w", err)
	}
	defer db.Close()

	http.HandleFunc("/", healthCheck)
	http.HandleFunc("/movies", getMovies)
	http.HandleFunc("/movies/{id}", getMovie)

	port := ":5000"
	fmt.Printf("Server started on port %s\n", port)
	if err := http.ListenAndServe(port, nil); err != nil {
		log.Fatalf("Server failed to start: %w", err)
	}
}
