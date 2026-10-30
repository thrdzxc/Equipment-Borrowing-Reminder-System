<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;
class AutomationEvent extends Model {
  public $timestamps=false;
  protected $fillable=['run_id','borrowing_id','event_type','attempt','result_code','details','created_at'];
  protected $casts=['created_at'=>'datetime','attempt'=>'integer'];
}
