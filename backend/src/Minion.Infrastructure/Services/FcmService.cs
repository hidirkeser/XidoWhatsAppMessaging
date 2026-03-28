using FirebaseAdmin;
using FirebaseAdmin.Messaging;
using Google.Apis.Auth.OAuth2;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Minion.Domain.Interfaces;

namespace Minion.Infrastructure.Services;

/// <summary>
/// Firebase Cloud Messaging (FCM) push notification service.
///
/// Dev mode (Firebase:Enabled=false):
///   Logs the push payload to console — no Firebase project needed.
///
/// Setup (Firebase:Enabled=true):
///   1. Create a Firebase project at https://console.firebase.google.com
///   2. Project Settings → Service accounts → Generate new private key
///   3. Save the JSON file to a secure location
///   4. Set either:
///      - Firebase:ServiceAccountPath = "/secure/path/firebase-sa.json"
///      - Firebase:ServiceAccountJson = "{ ...entire JSON content... }"
///
/// Flutter side:
///   Run: flutterfire configure --project=YOUR_PROJECT_ID
///   This generates lib/firebase_options.dart automatically.
/// </summary>
public class FcmService : IFcmService
{
    private readonly bool _enabled;
    private readonly ILogger<FcmService> _logger;

    public FcmService(IConfiguration config, ILogger<FcmService> logger)
    {
        _logger = logger;
        _enabled = config["Firebase:Enabled"] == "true";

        if (_enabled)
            EnsureFirebaseInitialized(config, logger);
    }

    private static void EnsureFirebaseInitialized(IConfiguration config, ILogger logger)
    {
        if (FirebaseApp.DefaultInstance != null) return; // already initialized

        GoogleCredential credential;

        var jsonPath    = config["Firebase:ServiceAccountPath"];
        var jsonContent = config["Firebase:ServiceAccountJson"];

        if (!string.IsNullOrWhiteSpace(jsonContent))
        {
            credential = GoogleCredential.FromJson(jsonContent);
            logger.LogInformation("[FCM] Initialized Firebase from inline JSON config.");
        }
        else if (!string.IsNullOrWhiteSpace(jsonPath) && File.Exists(jsonPath))
        {
            credential = GoogleCredential.FromFile(jsonPath);
            logger.LogInformation("[FCM] Initialized Firebase from service account file: {Path}", jsonPath);
        }
        else
        {
            throw new InvalidOperationException(
                "Firebase is enabled but service account credentials are missing. " +
                "Set Firebase:ServiceAccountPath or Firebase:ServiceAccountJson in appsettings.");
        }

        FirebaseApp.Create(new AppOptions { Credential = credential });
    }

    public async Task SendAsync(
        IEnumerable<string> deviceTokens,
        string title,
        string body,
        string notificationType,
        Guid? referenceId = null,
        CancellationToken ct = default)
    {
        var tokens = deviceTokens.ToList();
        if (tokens.Count == 0) return;

        if (!_enabled)
        {
            _logger.LogInformation(
                "[FCM-DEV] Push to {Count} device(s) | Type: {Type} | Title: {Title} | Body: {Body}",
                tokens.Count, notificationType, title, body);
            return;
        }

        var data = new Dictionary<string, string>
        {
            ["type"]        = notificationType,
            ["referenceId"] = referenceId?.ToString() ?? string.Empty,
        };

        // FCM MulticastMessage handles up to 500 tokens per batch
        foreach (var chunk in tokens.Chunk(500))
        {
            var multicast = new MulticastMessage
            {
                Tokens = chunk.ToList(),
                Notification = new Notification
                {
                    Title = title,
                    Body  = body,
                },
                Data = data,
                Android = new AndroidConfig
                {
                    Priority = Priority.High,
                    Notification = new AndroidNotification
                    {
                        ChannelId = "minion_channel",
                        Sound     = "default",
                        Icon      = "ic_notification",
                    },
                },
                Apns = new ApnsConfig
                {
                    Aps = new Aps
                    {
                        Sound = "default",
                        Badge = 1,
                        ContentAvailable = true,
                    },
                },
            };

            var response = await FirebaseMessaging.DefaultInstance
                .SendEachForMulticastAsync(multicast, ct);

            _logger.LogInformation(
                "[FCM] Batch sent to {Total} device(s). ✓ {Success} / ✗ {Fail}",
                chunk.Length, response.SuccessCount, response.FailureCount);

            // Log per-token failures (in production: deactivate stale tokens)
            for (var i = 0; i < response.Responses.Count; i++)
            {
                if (!response.Responses[i].IsSuccess)
                    _logger.LogWarning("[FCM] Token failed: {Token} | {Error}",
                        chunk[i], response.Responses[i].Exception?.Message);
            }
        }
    }
}
