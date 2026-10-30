<?php
namespace App\Services;
/** Pure policy layer used by the Laravel service and the offline smoke tests. */
final class ReminderPolicy {
 public const MAX_ITEMS=10;
 public const MAX_ATTEMPTS=3;
 public const LOOKAHEAD_HOURS=48;
 public const OVERDUE_DAYS=7;
 public static function simulationResult(string $mode,int $attempt):string {
  if($mode==='permanent_failure')return 'PERMANENT_DESTINATION_INVALID';
  if($mode==='transient_always')return 'TRANSIENT_NETWORK_SIMULATED';
  if($mode==='transient_once' && $attempt===1)return 'TRANSIENT_NETWORK_SIMULATED';
  if($mode==='success' || $mode==='transient_once')return 'SIMULATED_DELIVERY_OK';
  throw new \InvalidArgumentException('Invalid simulation mode');
 }
 public static function shouldRetry(string $result,int $attempt):bool {
  return $result==='TRANSIENT_NETWORK_SIMULATED' && $attempt<self::MAX_ATTEMPTS;
 }
 public static function eligible(\DateTimeImmutable $due,\DateTimeImmutable $now):bool {
  $min=$now->modify('-'.self::OVERDUE_DAYS.' days');
  $max=$now->modify('+'.self::LOOKAHEAD_HOURS.' hours');
  return $due >= $min && $due <= $max;
 }
}
