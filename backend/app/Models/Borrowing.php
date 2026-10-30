<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;
class Borrowing extends Model {
 protected $fillable=['equipment_id','borrower_name','borrowed_at','due_at','returned_at','status','reminder_status','reminder_attempts','next_attempt_at','last_reminded_at','last_error_code'];
 protected $casts=['borrowed_at'=>'datetime','due_at'=>'datetime','returned_at'=>'datetime','next_attempt_at'=>'datetime','last_reminded_at'=>'datetime','reminder_attempts'=>'integer'];
 public function equipment(){return $this->belongsTo(Equipment::class);}
}
