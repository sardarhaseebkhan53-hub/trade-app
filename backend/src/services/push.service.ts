export interface PushService {
  send(input: { deviceToken: string; title: string; body: string; data?: Record<string, string> }): Promise<void>;
}

/// Phase 6 port only. An FCM/APNs adapter is configured server-side in deployment.
export class DisabledPushService implements PushService {
  async send(): Promise<void> {
    // Intentionally no-op until a consent-aware provider adapter is configured.
  }
}
