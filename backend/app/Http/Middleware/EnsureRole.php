<?php
namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

/** Server-side role guard. Never trust a role from the request body or client UI. */
class EnsureRole
{
    public function handle(Request $request, Closure $next, string ...$roles): Response
    {
        $user = $request->user();
        if (!$user) {
            return response()->json(['message' => 'Unauthenticated.'], 401);
        }
        if (!in_array($user->role, $roles, true)) {
            return response()->json(['message' => 'Access denied for this account role.'], 403);
        }
        return $next($request);
    }
}
