<?php
/**
 * gRPC Health Check Service
 * Implements the standard gRPC health checking protocol
 */
namespace \Health;

use Grpc\Health\V1\HealthCheckRequest;
use Grpc\Health\V1\HealthCheckResponse;
use Grpc\Health\V1\HealthInterface;

class HealthCheckService implements HealthInterface
{
    private array $services = [];

    public function setServiceStatus(string $service, int $status): void
    {
        $this->services[$service] = $status;
    }

    public function check(HealthCheckRequest $request, $context): HealthCheckResponse
    {
        $service = $request->getService();
        $response = new HealthCheckResponse();

        if (empty($service)) {
            // Overall health
            $status = empty($this->services)
                ? HealthCheckResponse\ServingStatus::SERVING
                : min($this->services);
        } else {
            // Specific service health
            $status = $this->services[$service]
                ?? HealthCheckResponse\ServingStatus::SERVICE_UNKNOWN;
        }

        $response->setStatus($status);
        return $response;
    }

    public function watch(HealthCheckRequest $request, $context)
    {
        // Streaming health updates not implemented in this example
        throw new \RuntimeException('Watch not implemented');
    }
}
