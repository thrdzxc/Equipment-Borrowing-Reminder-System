<?php
namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

/** Reject plaintext API transport in hosted environments; set no-store on responses. */
class SecureApiTransport
{
    public function handle(Request $request, Closure $next): Response
    {
        $required = app()->environment('production', 'staging')
            || (bool) config('secure_exchange.require_https', false);
        if ($required && !$request->isSecure()) {
            return response()->json(['message' => 'HTTPS is required for this API.', 'code' => 'HTTPS_REQUIRED'], 403)
                ->withHeaders([
                    'Cache-Control' => 'no-store, private',
                    'X-Content-Type-Options' => 'nosniff',
                ]);
        }

        $response = $next($request);
        $response->headers->set('Cache-Control', 'no-store, private');
        $response->headers->set('X-Content-Type-Options', 'nosniff');
        $response->headers->set('Referrer-Policy', 'no-referrer');
        return $response;
    }
}
