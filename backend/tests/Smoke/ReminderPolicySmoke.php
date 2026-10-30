<?php
/** This smoke test runs WITHOUT Laravel or Composer. It does NOT test the HTTP API. */
require_once dirname(__DIR__,2).'/app/Services/ReminderPolicy.php';
use App\Services\ReminderPolicy as P;
function check(bool $condition,string $name):void {if(!$condition){fwrite(STDERR,"FAIL $name\n");exit(1);}echo "PASS $name\n";}
check(P::MAX_ITEMS===10,'Bounded maximum of 10 loans per run');
check(P::MAX_ATTEMPTS===3,'Maximum three reminder attempts');
check(P::simulationResult('success',1)==='SIMULATED_DELIVERY_OK','Success outcome');
check(P::simulationResult('transient_once',1)==='TRANSIENT_NETWORK_SIMULATED','Transient attempt 1 fails');
check(P::shouldRetry(P::simulationResult('transient_once',1),1),'Transient outcome eligible for retry');
check(P::simulationResult('transient_once',2)==='SIMULATED_DELIVERY_OK','Transient attempt 2 recovers');
check(!P::shouldRetry(P::simulationResult('permanent_failure',1),1),'Permanent failure never automatically retries');
check(!P::shouldRetry(P::simulationResult('transient_always',3),3),'Transient retry stops after maximum attempts');
$now=new DateTimeImmutable('2026-10-30T09:00:00+08:00');
check(P::eligible($now->modify('+1 day'),$now),'Borrowing due tomorrow is eligible');
check(!P::eligible($now->modify('+3 days'),$now),'Borrowing more than 48h away is not eligible');
check(!P::eligible($now->modify('-8 days'),$now),'Old overdue borrowing is outside bounded window');
echo "All isolated policy checks passed. Full Laravel/Flutter integration remains untested here.\n";
