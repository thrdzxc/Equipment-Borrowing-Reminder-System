<?php
namespace Database\Seeders;
use Illuminate\Database\Seeder;
use App\Models\User;
use App\Models\Equipment;
use Illuminate\Support\Facades\Hash;
class DatabaseSeeder extends Seeder {
 public function run():void {
  if(!app()->environment('local', 'testing')) {throw new \RuntimeException('Demo seeder disabled in production');}
  $password=env('DEMO_ADMIN_PASSWORD');
  if(!$password || $password==='CHANGE_ME_LOCALLY' || strlen($password)<12){throw new \RuntimeException('Set a unique DEMO_ADMIN_PASSWORD of at least 12 characters in local .env first.');}
  $operator = User::updateOrCreate(
   ['email'=>env('DEMO_ADMIN_EMAIL','admin@example.test')],
   ['name'=>'Local Demo Operator','password'=>Hash::make($password)]
  );
  // Explicit custodian promotion; never accept a role supplied by client input.
  $operator->forceFill(['role'=>'custodian'])->save();
  // Optional controlled-data accounts for role-based testing. Never seed weak or
  // hard-coded credentials, and never enable this seeder in production.
  foreach (['STAFF' => 'staff', 'STUDENT' => 'student'] as $suffix => $role) {
   $email = env('DEMO_'.$suffix.'_EMAIL');
   $secret = env('DEMO_'.$suffix.'_PASSWORD');
   if ($email && $secret && $secret !== 'CHANGE_ME_LOCALLY' && strlen($secret) >= 12) {
    $account = User::updateOrCreate(
     ['email' => $email],
     ['name' => 'Local '.$role.' demo', 'password' => Hash::make($secret)]
    );
    $account->forceFill(['role' => $role])->save();
   }
  }
  Equipment::firstOrCreate(['asset_tag'=>'LAB-LAP-01'],['name'=>'Laptop','category'=>'Computer','quantity_total'=>5,'quantity_available'=>5]);
  Equipment::firstOrCreate(['asset_tag'=>'LAB-PRO-02'],['name'=>'Projector','category'=>'AV Equipment','quantity_total'=>2,'quantity_available'=>2]);
 }
}
