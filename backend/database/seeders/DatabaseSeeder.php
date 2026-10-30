<?php
namespace Database\Seeders;
use Illuminate\Database\Seeder;
use App\Models\User;
use App\Models\Equipment;
use Illuminate\Support\Facades\Hash;
class DatabaseSeeder extends Seeder {
 public function run():void {
  if(app()->environment('production')) {throw new \RuntimeException('Demo seeder disabled in production');}
  $password=env('DEMO_ADMIN_PASSWORD');
  if(!$password || $password==='CHANGE_ME_LOCALLY' || strlen($password)<12){throw new \RuntimeException('Set a unique DEMO_ADMIN_PASSWORD of at least 12 characters in local .env first.');}
  User::updateOrCreate(['email'=>env('DEMO_ADMIN_EMAIL','admin@example.test')],['name'=>'Local Demo Operator','password'=>Hash::make($password)]);
  Equipment::firstOrCreate(['asset_tag'=>'LAB-LAP-01'],['name'=>'Laptop','category'=>'Computer','quantity_total'=>5,'quantity_available'=>5]);
  Equipment::firstOrCreate(['asset_tag'=>'LAB-PRO-02'],['name'=>'Projector','category'=>'AV Equipment','quantity_total'=>2,'quantity_available'=>2]);
 }
}
