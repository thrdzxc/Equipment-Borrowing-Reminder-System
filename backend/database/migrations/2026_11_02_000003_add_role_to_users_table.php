<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void {
        Schema::table('users', function (Blueprint $table) {
            // Least privilege for existing staff accounts. Seeder explicitly promotes only
            // the configured lab custodian; there is no public role-assignment endpoint.
            $table->string('role', 20)->default('staff');
        });
    }
    public function down(): void {
        Schema::table('users', fn (Blueprint $table) => $table->dropColumn('role'));
    }
};
