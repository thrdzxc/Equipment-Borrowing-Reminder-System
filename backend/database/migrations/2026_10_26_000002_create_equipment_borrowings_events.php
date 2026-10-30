<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
return new class extends Migration {
 public function up():void {
  Schema::create('equipment',function(Blueprint $t){$t->id();$t->string('asset_tag')->unique();$t->string('name');$t->string('category');$t->unsignedInteger('quantity_total');$t->unsignedInteger('quantity_available');$t->timestamps();});
  Schema::create('borrowings',function(Blueprint $t){$t->id();$t->foreignId('equipment_id')->constrained('equipment');$t->string('borrower_name');$t->timestamp('borrowed_at');$t->timestamp('due_at');$t->timestamp('returned_at')->nullable();$t->string('status')->default('active');$t->string('reminder_status')->default('pending');$t->unsignedTinyInteger('reminder_attempts')->default(0);$t->timestamp('next_attempt_at')->nullable();$t->timestamp('last_reminded_at')->nullable();$t->string('last_error_code')->nullable();$t->timestamps();$t->index(['status','reminder_status','due_at']);});
  Schema::create('automation_events',function(Blueprint $t){$t->id();$t->uuid('run_id');$t->foreignId('borrowing_id')->nullable()->constrained('borrowings')->nullOnDelete();$t->string('event_type');$t->unsignedTinyInteger('attempt')->default(0);$t->string('result_code');$t->string('details')->nullable();$t->timestamp('created_at');$t->index('run_id');});
 }
 public function down():void {Schema::dropIfExists('automation_events');Schema::dropIfExists('borrowings');Schema::dropIfExists('equipment');}
};
