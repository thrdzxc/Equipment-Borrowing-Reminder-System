<?php
namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

/** Enforce HTTPS when configured; consistently apply defensive API headers. */
class SecureApiTransport
{
    public function handle(Request $request, Closure $next): Response
    {
        $required = app()->environment('production', 'staging')
            || (bool) config('secure_exchange.require_https', false);
        if ($required && !$request->isSecure()) {
            return $this->protect(response()->json([
                'message' => 'HTTPS is required for this API.',
                'code' => 'HTTPS_REQUIRED',
            ], 403));
        }
        return $this->protect($next($request));
    }

    private function protect(Response $response): Response
    {
        // W15-H03: apply the same safe headers on successful and rejected calls.
        $response->headers->set('Cache-Control', 'no-store, private');
        $response->headers->set('X-Content-Type-Options', 'nosniff');
        $response->headers->set('Referrer-Policy', 'no-referrer');
        $response->headers->set('X-Frame-Options', 'DENY');
        return $response;
    }
}
