package main

import (
	"net/http/httptest"
	"testing"

	"github.com/gofiber/fiber/v2"
)

func TestRejectSQLControlQueryValues(t *testing.T) {
	app := fiber.New(fiber.Config{ErrorHandler: ErrorHandlerFunc})
	app.Use("/indexer/v3/", rejectSQLControlQueryValues)
	app.Get("/indexer/v3/items", func(c *fiber.Ctx) error { return c.SendStatus(fiber.StatusOK) })

	for _, tc := range []struct {
		name, query string
		status      int
	}{
		{"valid base64 hash", "hash=J1d5G0ymp9ZAUr2ax2FepIolgmi3IlpZqqeCx%2BRLAf0%3D", 200},
		{"valid address", "address=Uf83bJlae_xvg0eOYB-nL_CJvjUao7A0rRyIlmi-CeVAKtvh", 200},
		{"quote", "index=1%27%20OR%201%3D1--", 422},
		{"semicolon", "index=1%3BDROP%20TABLE%20blocks", 422},
		{"backslash", "index=1%5C%27", 422},
		{"control", "index=1%0A2", 422},
	} {
		t.Run(tc.name, func(t *testing.T) {
			req := httptest.NewRequest("GET", "/indexer/v3/items?"+tc.query, nil)
			resp, err := app.Test(req)
			if err != nil {
				t.Fatal(err)
			}
			if resp.StatusCode != tc.status {
				t.Fatalf("status = %d, want %d", resp.StatusCode, tc.status)
			}
		})
	}
}
