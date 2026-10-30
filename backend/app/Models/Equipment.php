<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;
class Equipment extends Model {
  protected $fillable=['asset_tag','name','category','quantity_total','quantity_available'];
  protected $casts=['quantity_total'=>'integer','quantity_available'=>'integer'];
  public function borrowings(){ return $this->hasMany(Borrowing::class); }
}
