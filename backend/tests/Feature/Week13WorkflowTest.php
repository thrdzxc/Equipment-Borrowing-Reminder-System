<?php

namespace Tests\Feature;

use Tests\TestCase;
use App\Models\User;
use App\Models\Equipment;
use Illuminate\Foundation\Testing\RefreshDatabase;

class Week13WorkflowTest extends TestCase
{
    use RefreshDatabase;

    /**
     * Create an authorized custodian for workflow tests.
     */
    private function user(): User
    {
        $user = User::create([
            'name' => 'Tester',
            'email' => 'tester@example.test',
            'password' => 'localtestpassword123',
        ]);

        // Assign the custodian role explicitly.
        // The role is protected from mass assignment.
        $user->forceFill([
            'role' => 'custodian',
        ])->save();

        return $user->fresh();
    }

    /**
     * Create sample equipment for testing.
     */
    private function equipment(): Equipment
    {
        return Equipment::create([
            'asset_tag' => 'LAB-100',
            'name' => 'Projector',
            'category' => 'AV',
            'quantity_total' => 1,
            'quantity_available' => 1,
        ]);
    }

    public function test_unauthorized_requests_are_denied(): void
    {
        $this->getJson('/api/equipment')
            ->assertUnauthorized();
    }

    public function test_validation_rejects_blank_equipment(): void
    {
        $this->actingAs($this->user(), 'sanctum');

        $this->postJson('/api/equipment', [
            'name' => '',
        ])->assertUnprocessable();
    }

    public function test_successful_loan_and_return_restores_stock(): void
    {
        $this->actingAs($this->user(), 'sanctum');

        $item = $this->equipment();

        $id = $this->postJson('/api/borrowings', [
            'equipment_id' => $item->id,
            'borrower_name' => 'Demo Student',
            'due_at' => now()->addDay()->toIso8601String(),
        ])
            ->assertCreated()
            ->json('id');

        $this->assertEquals(
            0,
            $item->fresh()->quantity_available
        );

        $this->postJson("/api/borrowings/{$id}/return")
            ->assertOk();

        $this->assertEquals(
            1,
            $item->fresh()->quantity_available
        );

        $this->postJson("/api/borrowings/{$id}/return")
            ->assertStatus(409);
    }

    public function test_transient_failure_recovers_with_one_retry(): void
    {
        $this->actingAs($this->user(), 'sanctum');

        $item = $this->equipment();

        $this->postJson('/api/borrowings', [
            'equipment_id' => $item->id,
            'borrower_name' => 'Demo Student',
            'due_at' => now()->addDay()->toIso8601String(),
        ])->assertCreated();

        $this->postJson('/api/automation/run', [
            'mode' => 'transient_once',
        ])
            ->assertOk()
            ->assertJsonPath('completed', 1)
            ->assertJsonPath('retries', 1);

        $this->assertDatabaseHas('automation_events', [
            'event_type' => 'retry_scheduled',
        ]);

        $this->assertDatabaseHas('borrowings', [
            'reminder_status' => 'completed',
            'reminder_attempts' => 2,
        ]);
    }

    public function test_permanent_failure_routes_to_review(): void
    {
        $this->actingAs($this->user(), 'sanctum');

        $item = $this->equipment();

        $this->postJson('/api/borrowings', [
            'equipment_id' => $item->id,
            'borrower_name' => 'Demo Student',
            'due_at' => now()->addDay()->toIso8601String(),
        ])->assertCreated();

        $this->postJson('/api/automation/run', [
            'mode' => 'permanent_failure',
        ])
            ->assertOk()
            ->assertJsonPath('needs_review', 1);

        $this->assertDatabaseHas('borrowings', [
            'reminder_status' => 'needs_review',
        ]);

        $this->assertDatabaseHas('automation_events', [
            'event_type' => 'routed_for_review',
            'result_code' => 'PERMANENT_DESTINATION_INVALID',
        ]);
    }

    public function test_duplicate_asset_tag_and_invalid_due_date_fail(): void
    {
        $this->actingAs($this->user(), 'sanctum');

        $item = $this->equipment();

        $this->postJson('/api/equipment', [
            'asset_tag' => 'LAB-100',
            'name' => 'Another',
            'category' => 'AV',
            'quantity_total' => 1,
        ])->assertUnprocessable();

        $this->postJson('/api/borrowings', [
            'equipment_id' => $item->id,
            'borrower_name' => 'Test',
            'due_at' => now()->subDay()->toIso8601String(),
        ])->assertUnprocessable();
    }
}
