<?php
namespace Tests\Feature;

use App\Models\Equipment;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

/** Week 15 IA6 repeatable tests. Run on Windows: php artisan test --filter Week15HardeningTest */
class Week15HardeningTest extends TestCase
{
    use RefreshDatabase;

    private function userWithRole(string $role): User
    {
        $user = User::create([
            'name' => 'Controlled Week15 Tester',
            'email' => strtolower($role).'@example.test',
            'password' => 'test-only-not-a-live-credential',
        ]);
        $user->forceFill(['role' => $role])->save();
        return $user;
    }

    private function item(int $available = 1): Equipment
    {
        return Equipment::create([
            'asset_tag' => 'W15-LAPTOP', 'name' => 'Controlled Laptop',
            'category' => 'Computer', 'quantity_total' => 1,
            'quantity_available' => $available,
        ]);
    }

    private function loanPayload(int $equipmentId, ?string $dueAt = null): array
    {
        return [
            'equipment_id' => $equipmentId,
            'borrower_name' => 'Fictional Borrower',
            'due_at' => $dueAt ?? now()->addDay()->toIso8601String(),
        ];
    }

    public function test_w15_01_health_api_schema_is_json_and_stable(): void
    {
        $this->getJson('/api/health')->assertOk()
            ->assertJsonPath('status', 'ok')
            ->assertJsonPath('delivery', 'simulation-only')
            ->assertHeader('Content-Type', 'application/json');
    }

    public function test_w15_02_unauthenticated_inventory_denied(): void
    {
        $this->getJson('/api/equipment')->assertUnauthorized();
    }

    public function test_w15_03_student_cannot_read_private_borrowings(): void
    {
        $this->actingAs($this->userWithRole('student'), 'sanctum');
        $this->getJson('/api/borrowings')->assertForbidden();
    }

    public function test_w15_04_staff_cannot_run_automation(): void
    {
        $this->actingAs($this->userWithRole('staff'), 'sanctum');
        $this->postJson('/api/automation/run', ['mode' => 'success'])->assertForbidden();
    }

    public function test_w15_05_custodian_inventory_endpoint_minimizes_fields(): void
    {
        $this->actingAs($this->userWithRole('custodian'), 'sanctum');
        $this->item();
        $response = $this->getJson('/api/equipment')->assertOk();
        $record = $response->json('0');
        $this->assertSame('W15-LAPTOP', $record['asset_tag']);
        $this->assertArrayNotHasKey('created_at', $record);
        $this->assertArrayNotHasKey('updated_at', $record);
    }

    public function test_w15_06_zero_equipment_quantity_is_invalid(): void
    {
        $this->actingAs($this->userWithRole('custodian'), 'sanctum');
        $this->postJson('/api/equipment', [
            'asset_tag' => 'W15-EMPTY', 'name' => 'Empty', 'category' => 'Lab',
            'quantity_total' => 0,
        ])->assertUnprocessable();
        $this->assertDatabaseMissing('equipment', ['asset_tag' => 'W15-EMPTY']);
    }

    public function test_w15_07_quantity_above_limit_is_invalid(): void
    {
        $this->actingAs($this->userWithRole('custodian'), 'sanctum');
        $this->postJson('/api/equipment', [
            'asset_tag' => 'W15-OVER', 'name' => 'Too Many', 'category' => 'Lab',
            'quantity_total' => 1001,
        ])->assertUnprocessable();
    }

    public function test_w15_08_duplicate_asset_tag_is_rejected(): void
    {
        $this->actingAs($this->userWithRole('custodian'), 'sanctum');
        $this->item();
        $this->postJson('/api/equipment', [
            'asset_tag' => 'W15-LAPTOP', 'name' => 'Duplicate',
            'category' => 'Lab', 'quantity_total' => 1,
        ])->assertUnprocessable();
    }

    public function test_w15_09_past_due_date_is_rejected_without_stock_change(): void
    {
        $this->actingAs($this->userWithRole('staff'), 'sanctum');
        $item = $this->item();
        $this->postJson('/api/borrowings',
            $this->loanPayload($item->id, now()->subDay()->toIso8601String()))
            ->assertUnprocessable();
        $this->assertSame(1, $item->fresh()->quantity_available);
    }

    public function test_w15_10_control_character_in_name_is_rejected(): void
    {
        $this->actingAs($this->userWithRole('staff'), 'sanctum');
        $item = $this->item();
        $payload = $this->loanPayload($item->id);
        $payload['borrower_name'] = "bad\nname";
        $this->postJson('/api/borrowings', $payload)->assertUnprocessable();
        $this->assertSame(1, $item->fresh()->quantity_available);
    }

    public function test_w15_11_successful_loan_and_return_restore_stock(): void
    {
        $this->actingAs($this->userWithRole('staff'), 'sanctum');
        $item = $this->item();
        $id = $this->postJson('/api/borrowings', $this->loanPayload($item->id))
            ->assertCreated()->json('id');
        $this->assertSame(0, $item->fresh()->quantity_available);
        $this->postJson('/api/borrowings/'.$id.'/return')->assertOk();
        $this->assertSame(1, $item->fresh()->quantity_available);
    }

    public function test_w15_12_second_loan_cannot_overdraw_stock(): void
    {
        $this->actingAs($this->userWithRole('staff'), 'sanctum');
        $item = $this->item();
        $this->postJson('/api/borrowings', $this->loanPayload($item->id))->assertCreated();
        $this->postJson('/api/borrowings', $this->loanPayload($item->id))->assertUnprocessable();
        $this->assertSame(0, $item->fresh()->quantity_available);
    }

    public function test_w15_13_double_return_conflict_does_not_inflate_stock(): void
    {
        $this->actingAs($this->userWithRole('staff'), 'sanctum');
        $item = $this->item();
        $id = $this->postJson('/api/borrowings', $this->loanPayload($item->id))
            ->assertCreated()->json('id');
        $this->postJson('/api/borrowings/'.$id.'/return')->assertOk();
        $this->postJson('/api/borrowings/'.$id.'/return')->assertStatus(409);
        $this->assertSame(1, $item->fresh()->quantity_available);
    }

    public function test_w15_14_automation_permanent_failure_routes_to_review(): void
    {
        $this->actingAs($this->userWithRole('custodian'), 'sanctum');
        $item = $this->item();
        $this->postJson('/api/borrowings', $this->loanPayload($item->id))->assertCreated();
        $this->postJson('/api/automation/run', ['mode' => 'permanent_failure'])
            ->assertOk()->assertJsonPath('needs_review', 1);
        $this->assertDatabaseHas('borrowings', ['reminder_status' => 'needs_review']);
        $this->assertDatabaseHas('automation_events', ['event_type' => 'routed_for_review']);
    }

    public function test_w15_15_transient_failure_recovers_with_bounded_retry(): void
    {
        $this->actingAs($this->userWithRole('custodian'), 'sanctum');
        $item = $this->item();
        $this->postJson('/api/borrowings', $this->loanPayload($item->id))->assertCreated();
        $this->postJson('/api/automation/run', ['mode' => 'transient_once'])
            ->assertOk()->assertJsonPath('completed', 1)->assertJsonPath('retries', 1);
    }

    public function test_w15_16_invalid_automation_mode_is_rejected(): void
    {
        $this->actingAs($this->userWithRole('custodian'), 'sanctum');
        $this->postJson('/api/automation/run', ['mode' => 'unlimited_retries'])
            ->assertUnprocessable();
    }

    public function test_w15_17_https_required_rejects_plaintext_with_safe_headers(): void
    {
        config()->set('secure_exchange.require_https', true);
        $this->getJson('/api/health')->assertStatus(403)
            ->assertJsonPath('code', 'HTTPS_REQUIRED')
            ->assertHeader('Cache-Control', 'no-store, private')
            ->assertHeader('X-Frame-Options', 'DENY')
            ->assertHeader('Referrer-Policy', 'no-referrer');
    }

    public function test_w15_18_successful_api_responses_have_safe_headers(): void
    {
        $this->getJson('/api/health')->assertOk()
            ->assertHeader('X-Content-Type-Options', 'nosniff')
            ->assertHeader('X-Frame-Options', 'DENY')
            ->assertHeader('Referrer-Policy', 'no-referrer');
    }

    public function test_w15_19_student_equipment_can_read_public_inventory_fields(): void
    {
        $this->actingAs($this->userWithRole('student'), 'sanctum');
        $this->item();
        $response = $this->getJson('/api/equipment')->assertOk();
        $this->assertSame('W15-LAPTOP', $response->json('0.asset_tag'));
    }

    public function test_w15_20_safe_no_work_automation_returns_zero_processed(): void
    {
        $this->actingAs($this->userWithRole('custodian'), 'sanctum');
        $this->postJson('/api/automation/run', ['mode' => 'success'])
            ->assertOk()->assertJsonPath('processed', 0)->assertJsonPath('completed', 0);
    }
}
