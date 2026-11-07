<?php
namespace Tests\Feature;

use App\Models\Equipment;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

/** Execute with: php .\vendor\phpunit\phpunit\phpunit --testdox */
class Week14SecurityTest extends TestCase
{
    use RefreshDatabase;

    private function account(string $role, string $email): User
    {
        $user = User::create([
            'name' => 'Controlled Test Account',
            'email' => $email,
            'password' => 'a-valid-test-password-123',
        ]);
        $user->forceFill(['role' => $role])->save();
        return $user;
    }

    private function item(): Equipment
    {
        return Equipment::create([
            'asset_tag' => 'SEC-100', 'name' => 'Controlled Laptop',
            'category' => 'Computer', 'quantity_total' => 2,
            'quantity_available' => 2,
        ]);
    }

    public function test_unauthenticated_inventory_and_automation_are_denied(): void
    {
        $this->getJson('/api/equipment')->assertUnauthorized();
        $this->postJson('/api/automation/run', ['mode' => 'success'])->assertUnauthorized();
    }

    public function test_student_cannot_read_borrower_records_or_change_inventory(): void
    {
        $this->actingAs($this->account('student', 'student@example.test'), 'sanctum');
        $this->getJson('/api/equipment')->assertOk();
        $this->getJson('/api/borrowings')->assertForbidden();
        $this->postJson('/api/equipment', [
            'asset_tag' => 'SEC-102', 'name' => 'Laptop', 'category' => 'Computer',
            'quantity_total' => 1, 'role' => 'custodian',
        ])->assertForbidden();
        $this->getJson('/api/automation/events')->assertForbidden();
    }

    public function test_staff_can_issue_and_return_loans_but_cannot_override_automation(): void
    {
        $this->actingAs($this->account('staff', 'staff@example.test'), 'sanctum');
        $item = $this->item();
        $loanId = $this->postJson('/api/borrowings', [
            'equipment_id' => $item->id,
            'borrower_name' => 'Fictional Borrower',
            'due_at' => now()->addDay()->toIso8601String(),
        ])->assertCreated()->json('id');
        $this->postJson('/api/borrowings/'.$loanId.'/return')->assertOk();
        $this->postJson('/api/automation/run', ['mode' => 'permanent_failure'])->assertForbidden();
        $this->postJson('/api/borrowings/'.$loanId.'/reset-reminder')->assertForbidden();
        $this->postJson('/api/equipment', [])->assertForbidden();
    }

    public function test_custodian_can_use_integration_and_event_endpoints(): void
    {
        $this->actingAs($this->account('custodian', 'custodian@example.test'), 'sanctum');
        $this->postJson('/api/equipment', [
            'asset_tag' => 'SEC-200', 'name' => 'Projector',
            'category' => 'AV', 'quantity_total' => 1,
        ])->assertCreated();
        $this->getJson('/api/automation/events')->assertOk();
        $this->postJson('/api/automation/run', ['mode' => 'success'])->assertOk();
    }

    public function test_login_issues_an_expiring_token_and_minimal_user_profile(): void
    {
        $this->account('custodian', 'custodian@example.test');
        $response = $this->postJson('/api/auth/login', [
            'email' => 'custodian@example.test',
            'password' => 'a-valid-test-password-123',
        ])->assertOk()->assertJsonPath('user.role', 'custodian');
        $this->assertNotEmpty($response->json('token'));
        $this->assertGreaterThan(0, (int) $response->json('expires_in_minutes'));
        $this->assertArrayNotHasKey('password', $response->json('user'));
        $this->assertArrayNotHasKey('email', $response->json('user'));
    }

    public function test_wrong_password_and_unknown_account_use_same_error(): void
    {
        $this->account('staff', 'staff@example.test');
        foreach (['staff@example.test', 'missing@example.test'] as $email) {
            $this->postJson('/api/auth/login', [
                'email' => $email, 'password' => 'wrong-password',
            ])->assertUnauthorized()->assertJsonPath('message', 'Invalid credentials');
        }
    }

    public function test_expired_token_is_rejected(): void
    {
        $user = $this->account('custodian', 'custodian@example.test');
        $token = $user->createToken('security-test', ['*'], now()->addMinute());
        $token->accessToken->forceFill(['expires_at' => now()->subMinute()])->save();
        $this->withToken($token->plainTextToken)
            ->getJson('/api/equipment')->assertUnauthorized();
    }

    public function test_invalid_and_altered_bearer_token_is_rejected(): void
    {
        $user = $this->account('staff', 'staff@example.test');
        $token = $user->createToken('security-test');
        $altered = $token->accessToken->id.'|'.str_repeat('f', 40);
        $this->withToken($altered)->getJson('/api/equipment')->assertUnauthorized();
    }

    public function test_invalid_input_never_changes_equipment_stock(): void
    {
        $this->actingAs($this->account('staff', 'staff@example.test'), 'sanctum');
        $item = $this->item();
        $this->postJson('/api/borrowings', [
            'equipment_id' => $item->id,
            'borrower_name' => "bad\nname",
            'due_at' => now()->addDay()->toIso8601String(),
        ])->assertUnprocessable();
        $this->assertEquals(2, $item->fresh()->quantity_available);
    }

    public function test_https_requirement_rejects_plaintext_when_enabled(): void
    {
        config()->set('secure_exchange.require_https', true);
        $this->getJson('/api/health')->assertStatus(403)->assertJsonPath('code', 'HTTPS_REQUIRED');
        config()->set('secure_exchange.require_https', false);
    }

    public function test_logout_revokes_the_bearer_token(): void
    {
        $this->account('staff', 'staff@example.test');
        $login = $this->postJson('/api/auth/login', [
            'email' => 'staff@example.test',
            'password' => 'a-valid-test-password-123',
        ])->assertOk();
        $bearer = $login->json('token');
        $this->withToken($bearer)->postJson('/api/auth/logout')->assertOk();

        // Verify that the bearer credential is actually removed from storage.
        $this->assertNull(\Laravel\Sanctum\PersonalAccessToken::findToken($bearer));

        // In a real browser, each request has a fresh authentication guard. PHPUnit
        // reuses the application container, so clear the cached guard user first.
        app('auth')->forgetGuards();
        $this->withToken($bearer)->getJson('/api/equipment')->assertUnauthorized();
    }

    public function test_hashed_password_not_returned_by_public_api(): void
    {
        $user = $this->account('student', 'student@example.test');
        $this->assertNotSame('a-valid-test-password-123', $user->password);
        $this->actingAs($user, 'sanctum')
            ->getJson('/api/equipment')->assertOk()
            ->assertDontSee('a-valid-test-password-123');
    }

    public function test_default_user_role_is_not_custodian(): void
    {
        $user = User::create([
            'name' => 'Default Account', 'email' => 'default@example.test',
            'password' => 'a-valid-test-password-123',
        ]);
        $this->assertSame('staff', $user->fresh()->role);
    }
}
