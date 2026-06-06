package main

import (
	"encoding/json"
	"log"
	"net/http"
	"os"
	"time"
)

// ResponseMessage defines the structural layout for standard API responses
type ResponseMessage struct {
	Status    string    `json:"status"`
	Message   string    `json:"message"`
	Timestamp time.Time `json:"timestamp"`
}

// HealthStatus defines the health response for the ALB probe target
type HealthStatus struct {
	Alive       bool      `json:"alive"`
	Environment string    `json:"environment"`
	Uptime      time.Duration `json:"uptime"`
}

var startTime time.Time

func init() {
	startTime = time.Now()
}

func main() {
	// Fallback to port 8080 if the environment variable isn't specified
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	env := os.Getenv("ENV")
	if env == "" {
		env = "production"
	}

	// Route Handlers
	http.HandleFunc("/", handleRoot)
	http.HandleFunc("/health", handleHealth(env))

	log.Printf("[STARTTECH] Core API Engine initializing on port %s under %s lifecycle configuration...", port, env)
	if err := http.ListenAndServe(":"+port, nil); err != nil {
		log.Fatalf("[FATAL] Core API Engine failed to bind or execute: %v", err)
	}
}

func handleRoot(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)

	response := ResponseMessage{
		Status:    "Success",
		Message:   "Welcome to the StartTech Core Engine Application Backend API Layer.",
		Timestamp: time.Now(),
	}

	json.NewEncoder(w).Encode(response)
}

func handleHealth(env string) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusOK)

		status := HealthStatus{
			Alive:       true,
			Environment: env,
			Uptime:      time.Since(startTime),
		}

		json.NewEncoder(w).Encode(status)
	}
}
