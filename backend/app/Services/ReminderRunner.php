<?php
namespace App\Services;
use App\Models\Borrowing;
use App\Models\AutomationEvent;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Str;

/**
 * Local, simulated reminder processor. NO actual email/SMS is sent.
 * Limits: 10 loans per run, 3 attempts per loan, two sleeps <= 500ms,
 * lookahead 48h, overdue window 7 days, one concurrent run.
 */
class ReminderRunner {
 public const LIMIT=ReminderPolicy::MAX_ITEMS;
 public const MAX_ATTEMPTS=ReminderPolicy::MAX_ATTEMPTS;
 public function run(string $mode='success'):array {
  if(!app()->environment('local','testing')){$mode='success';}
  if(!in_array($mode,['success','transient_once','transient_always','permanent_failure'],true)){
   throw new \InvalidArgumentException('Unknown local simulation mode');
  }
  $lock=Cache::lock('equipment-reminder-automation',30);
  if(!$lock->get()){return ['error'=>'Another automation is running','status'=>'busy'];}
  $runId=(string)Str::uuid();
  $summary=['run_id'=>$runId,'mode'=>$mode,'delivery'=>'simulated_only', 'processed'=>0,'completed'=>0,'needs_review'=>0,'retries'=>0,'bounded_limit'=>self::LIMIT];
  try {
   $loans=Borrowing::where('status','active')->where('reminder_status','pending')
    ->where('due_at','>=',now()->subDays(7))->where('due_at','<=',now()->addHours(48))
    ->where(fn($q)=>$q->whereNull('next_attempt_at')->orWhere('next_attempt_at','<=',now()))
    ->orderBy('due_at')->limit(self::LIMIT)->get();
   foreach($loans as $loan){
    $summary['processed']++;
    $attempt=0;
    while($attempt<self::MAX_ATTEMPTS){
     $attempt++;
     $loan->increment('reminder_attempts');
     $result=ReminderPolicy::simulationResult($mode,$attempt);
     $this->event($runId,$loan->id,'delivery_attempt',$attempt,$result);
     if($result==='SIMULATED_DELIVERY_OK'){
      $loan->update(['reminder_status'=>'completed','last_reminded_at'=>now(),'next_attempt_at'=>null,'last_error_code'=>null]);
      $summary['completed']++;
      $this->event($runId,$loan->id,'reminder_completed',$attempt,'SIMULATED_ONLY');
      break;
     }
     if(!ReminderPolicy::shouldRetry($result,$attempt)){
      $loan->update(['reminder_status'=>'needs_review','last_error_code'=>$result,'next_attempt_at'=>null]);
      $summary['needs_review']++;
      $this->event($runId,$loan->id,'routed_for_review',$attempt,$result);
      break;
     }
     $summary['retries']++;
     $this->event($runId,$loan->id,'retry_scheduled',$attempt,'TRANSIENT_RETRY');
     usleep($attempt===1 ? 250000 : 500000);
    }
   }
   $this->event($runId,null,'run_complete',0,'RUN_FINISHED');
   return $summary;
  } finally {$lock->release();}
 }
 private function event(string $runId,?int $loanId,string $type,int $attempt,string $code):void {
  $data=['run_id'=>$runId,'borrowing_id'=>$loanId,'event_type'=>$type,'attempt'=>$attempt,'result_code'=>$code];
  AutomationEvent::create($data+['created_at'=>now()]);
  Log::info('equipment_reminder_automation',$data);
 }
}
