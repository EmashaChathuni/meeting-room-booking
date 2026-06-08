package main

import (
	"github.com/gin-gonic/gin"
)

func main() {
	// Set Gin to Release Mode for speed
	gin.SetMode(gin.ReleaseMode)

	router := gin.New()
	router.Use(gin.Recovery())

	// This is the absolute simplest route
	router.GET("/health", func(c *gin.Context) {
		c.JSON(200, gin.H{"status": "ok"})
	})

	// This handles the root URL
	router.GET("/", func(c *gin.Context) {
		c.JSON(200, gin.H{"status": "ok", "message": "Root is working"})
	})

	// Force start on 8080
	router.Run(":8080")
}
