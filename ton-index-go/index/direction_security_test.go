package index

import (
	"errors"
	"strings"
	"testing"
)

func TestMessageDirectionRejectsSQLInjection(t *testing.T) {
	for _, direction := range []string{"in' AND 1=1 --", "both", "", "IN"} {
		t.Run(direction, func(t *testing.T) {
			msg := MessageRequest{Direction: &direction}
			settings := RequestSettings{DefaultLimit: 10, MaxLimit: 100}
			_, messagesErr := buildMessagesQuery(msg, UtimeRequest{}, LtRequest{}, LimitRequest{}, settings)
			_, txErr := buildTransactionsQuery(BlockRequest{}, TransactionRequest{}, msg, UtimeRequest{}, LtRequest{}, LimitRequest{}, settings)
			if messagesErr == nil || txErr == nil {
				t.Fatalf("invalid direction accepted: messages=%v transactions=%v", messagesErr, txErr)
			}
			if direction != "" && (strings.Contains(messagesErr.Error(), direction) || strings.Contains(txErr.Error(), direction)) {
				t.Fatal("rejected input leaked into error")
			}
		})
	}
}

func TestMessageDirectionAllowsDocumentedValues(t *testing.T) {
	for _, direction := range []string{"in", "out"} {
		if err := validateMessageDirection(&direction); err != nil {
			t.Fatalf("direction %q rejected: %v", direction, err)
		}
	}
}

func TestInvalidDirectionPreservesClientError(t *testing.T) {
	direction := "in' OR 1=1 --"
	settings := RequestSettings{DefaultLimit: 10, MaxLimit: 100}
	db := &DbClient{}
	_, _, _, err := db.QueryMessages(MessageRequest{Direction: &direction}, UtimeRequest{}, LtRequest{}, LimitRequest{}, settings)
	var indexErr IndexError
	if !errors.As(err, &indexErr) || indexErr.Code != 422 {
		t.Fatalf("QueryMessages error = %v, want 422", err)
	}
}
